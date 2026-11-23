import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/constants/local_storage_keys.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/errors/exceptions.dart' show CacheException;
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/network/api_exceptions.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/core/services/auth/models/auth_session_state.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Fake Stubs ---

class FailingSecureStorageStub implements FlutterSecureStorage {
  bool shouldThrowPlatformException = false;
  String exceptionCode = 'KEYSTORE_ERROR';
  String? exceptionMessage = 'Transient Keystore failure';
  int deleteAllCallCount = 0;
  final Map<String, String> values = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (shouldThrowPlatformException) {
      throw PlatformException(
        code: exceptionCode,
        message: exceptionMessage,
      );
    }
    return values[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      values[key] = value;
    } else {
      values.remove(key);
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    values.remove(key);
  }

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    deleteAllCallCount++;
    values.clear();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class InMemoryTokenStorage implements IAuthTokenStorage {
  String? _token;

  @override
  Future<void> clearToken() async {
    _token = null;
  }

  @override
  Future<String?> readToken() async {
    return _token;
  }

  @override
  Future<void> writeToken(String token) async {
    _token = token;
  }
}

class FakeAuthRepoForPackageA implements IAuthRepository {
  CustomerModel? meCustomer;
  bool meFails = false;

  @override
  Future<CustomerModel> me() async {
    if (meFails) {
      throw const NetworkException(message: 'Network failure during me()');
    }
    return meCustomer ??
        const CustomerModel(
          id: 999,
          fullName: 'عميل افتراضي',
          email: 'default@test.com',
        );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Package A: SEC-01 Secure Storage Protection Tests', () {
    test('PlatformException during readToken does NOT trigger deleteAll and preserves biometric keys', () async {
      final fakeStorage = FailingSecureStorageStub();
      // Store biometric and passkey credentials in the same storage
      fakeStorage.values['biometric_auth_token'] = 'bio_token_secret_123';
      fakeStorage.values['biometric_credential_id'] = 'cred_id_xyz';
      fakeStorage.values[LocalStorageKeys.authToken] = 'active_jwt_token';

      fakeStorage.shouldThrowPlatformException = true;
      fakeStorage.exceptionCode = 'TEMPORARY_KEYSTORE_BUSY';
      fakeStorage.exceptionMessage = 'Android Keystore is temporarily locked';

      final tokenStorage = SecureAuthTokenStorage(secureStorage: fakeStorage);

      // Must throw CacheException and preserve stack trace, NOT deleteAll
      await expectLater(
        () => tokenStorage.readToken(),
        throwsA(isA<CacheException>()),
      );

      // Verify deleteAll was NEVER called
      expect(fakeStorage.deleteAllCallCount, equals(0));

      // Verify biometric and passkey credentials were NOT wiped
      expect(fakeStorage.values['biometric_auth_token'], equals('bio_token_secret_123'));
      expect(fakeStorage.values['biometric_credential_id'], equals('cred_id_xyz'));
    });

    test('Permanent key corruption (KEY_PERMANENTLY_INVALIDATED) deletes only authToken key, not deleteAll', () async {
      final fakeStorage = FailingSecureStorageStub();
      fakeStorage.values['biometric_auth_token'] = 'bio_token_safe';
      fakeStorage.values[LocalStorageKeys.authToken] = 'corrupted_token';

      fakeStorage.shouldThrowPlatformException = true;
      fakeStorage.exceptionCode = 'KEY_PERMANENTLY_INVALIDATED';
      fakeStorage.exceptionMessage = 'KeyPermanentlyInvalidatedException';

      final tokenStorage = SecureAuthTokenStorage(secureStorage: fakeStorage);

      await expectLater(
        () => tokenStorage.readToken(),
        throwsA(isA<CacheException>()),
      );

      // deleteAll was NEVER called
      expect(fakeStorage.deleteAllCallCount, equals(0));
      // Only the specific authToken key was deleted
      expect(fakeStorage.values.containsKey(LocalStorageKeys.authToken), isFalse);
      // Biometric credentials remain intact
      expect(fakeStorage.values['biometric_auth_token'], equals('bio_token_safe'));
    });

    test('readToken returns null when token key is genuinely missing (no exception)', () async {
      final fakeStorage = FailingSecureStorageStub();
      final tokenStorage = SecureAuthTokenStorage(secureStorage: fakeStorage);

      final token = await tokenStorage.readToken();
      expect(token, isNull);
    });

    test('bootstrapSession handles storage CacheException by setting serverError without kicking user to unauthenticated', () async {
      final fakeStorage = FailingSecureStorageStub();
      fakeStorage.shouldThrowPlatformException = true;
      fakeStorage.exceptionCode = 'KEYSTORE_ERROR';

      final tokenStorage = SecureAuthTokenStorage(secureStorage: fakeStorage);
      final container = ProviderContainer(
        overrides: [
          authTokenStorageProvider.overrideWithValue(tokenStorage),
        ],
      );
      addTearDown(container.dispose);

      final sessionNotifier = container.read(authSessionProvider.notifier);

      // Run bootstrap
      await sessionNotifier.bootstrapSession();

      final state = container.read(authSessionProvider);
      // Must NOT be unauthenticated or kick to login; must reflect serverError / storage error
      expect(state.status, equals(AuthSessionStatus.serverError));
      expect(state.errorMessage, contains('التخزين الآمن'));
    });
  });

  group('Package A: SEC-02 Customer Profile Isolation Tests', () {
    test('Client B logging in without customer payload does NOT receive Client A cached profile', () async {
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          authTokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
        ],
      );
      addTearDown(container.dispose);

      final sessionNotifier = container.read(authSessionProvider.notifier);

      // 1. Client A logs in with verified customer payload
      const clientA = CustomerModel(
        id: 101,
        fullName: 'العميل الأول',
        email: 'clientA@test.com',
      );
      await sessionNotifier.startSession(
        accessToken: 'token_client_A',
        customerPayload: clientA,
      );
      await Future<void>.delayed(Duration.zero);

      final stateA = container.read(authSessionProvider);
      expect(stateA.customer?.id, equals(101));
      expect(stateA.customer?.fullName, equals('العميل الأول'));

      // Verify Client A is stored with isolated user_id key
      expect(prefs.containsKey('cached_customer_profile_101'), isTrue);
      expect(prefs.getString('last_authenticated_user_id'), equals('101'));

      // 2. Client A logs out
      sessionNotifier.clearSession();
      await Future<void>.delayed(Duration.zero);
      expect(container.read(authSessionProvider).status, equals(AuthSessionStatus.unauthenticated));
      expect(prefs.containsKey('last_authenticated_user_id'), isFalse);

      // 3. Client B logs in, BUT me() failed so customerPayload is null
      await sessionNotifier.startSession(
        accessToken: 'token_client_B',
        customerPayload: null, // No verified customer for B
      );

      final stateB = container.read(authSessionProvider);
      // CRITICAL SECURITY ASSERTION:
      // Client B must NOT inherit Client A's profile!
      expect(stateB.customer, isNull);
      expect(stateB.token, equals('token_client_B'));
    });

    test('bootstrapSession only restores isolated cache if last_authenticated_user_id matches envelope', () async {
      final prefs = await SharedPreferences.getInstance();

      // Tampered / mismatched envelope
      final forgedEnvelope = {
        'user_id': 999, // Mismatched
        'email': 'hacker@test.com',
        'customer': const CustomerModel(id: 999, fullName: 'مخترق', email: 'hacker@test.com').toJson(),
      };
      await prefs.setString('cached_customer_profile_555', jsonEncode(forgedEnvelope));
      await prefs.setString('last_authenticated_user_id', '555');

      final fakeAuthRepo = FakeAuthRepoForPackageA()..meFails = true;

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          authTokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
          authRepositoryProvider.overrideWithValue(fakeAuthRepo),
        ],
      );
      addTearDown(container.dispose);

      final sessionNotifier = container.read(authSessionProvider.notifier);
      await sessionNotifier.bootstrapSession(initialToken: 'valid_token_123');

      // Due to user_id mismatch in envelope, customer profile must NOT be restored
      final state = container.read(authSessionProvider);
      expect(state.customer, isNull);
    });

    test('recoverCustomerProfile fetches real profile for Client B and caches under isolated key', () async {
      final prefs = await SharedPreferences.getInstance();

      const realClientB = CustomerModel(
        id: 202,
        fullName: 'العميل الثاني الحقيقي',
        email: 'clientB@test.com',
      );
      final fakeAuthRepo = FakeAuthRepoForPackageA()..meCustomer = realClientB;

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          authTokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
          authRepositoryProvider.overrideWithValue(fakeAuthRepo),
        ],
      );
      addTearDown(container.dispose);

      final sessionNotifier = container.read(authSessionProvider.notifier);
      await sessionNotifier.startSession(accessToken: 'token_client_B', customerPayload: null);

      expect(container.read(authSessionProvider).customer, isNull);

      // Now recovery runs
      final recovered = await sessionNotifier.recoverCustomerProfile();
      await Future<void>.delayed(Duration.zero);
      expect(recovered?.id, equals(202));
      expect(recovered?.fullName, equals('العميل الثاني الحقيقي'));

      // Check that it's cached under isolated key 202
      expect(prefs.containsKey('cached_customer_profile_202'), isTrue);
      expect(prefs.getString('last_authenticated_user_id'), equals('202'));
    });
  });
}
