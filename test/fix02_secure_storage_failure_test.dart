import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/constants/local_storage_keys.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/errors/exceptions.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/core/services/auth/models/auth_session_state.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeFlutterSecureStorage extends FlutterSecureStorage {
  bool shouldThrowOnWrite = false;
  bool shouldThrowOnRead = false;
  bool shouldThrowOnDelete = false;
  PlatformException? writeException;
  PlatformException? readException;
  PlatformException? deleteException;
  final Map<String, String> storage = {};

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
    if (shouldThrowOnWrite) {
      throw writeException ??
          PlatformException(
            code: 'KEYSTORE_ERROR',
            message: 'Android KeyStore KeystoreOperation failed / KEYMINT_ERROR',
          );
    }
    if (value != null) {
      storage[key] = value;
    } else {
      storage.remove(key);
    }
  }

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
    if (shouldThrowOnRead) {
      throw readException ??
          PlatformException(
            code: 'KEYSTORE_READ_ERROR',
            message: 'KeyStore operation failed: KEYMINT_BLOB_CORRUPTED',
          );
    }
    return storage[key];
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
    if (shouldThrowOnDelete) {
      throw deleteException ??
          PlatformException(
            code: 'KEYSTORE_DELETE_ERROR',
            message: 'KeyStore operation failed: KEYMINT_DELETE_FAILED',
          );
    }
    storage.remove(key);
  }
}

class StubAuthRepository implements IAuthRepository {
  int logoutCallCount = 0;

  @override
  Future<void> logout() async {
    logoutCallCount++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ControllableTokenStorage implements IAuthTokenStorage {
  String? _token;
  bool shouldThrowOnWrite = false;
  bool shouldThrowOnClear = false;
  Exception? writeException;
  Exception? clearException;
  int clearCallCount = 0;

  ControllableTokenStorage({String? initialToken}) : _token = initialToken;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> writeToken(String token) async {
    if (shouldThrowOnWrite) {
      throw writeException ??
          const CacheException(message: 'تعذر حفظ بيانات الجلسة بشكل آمن.');
    }
    _token = token;
  }

  @override
  Future<void> clearToken() async {
    clearCallCount++;
    if (shouldThrowOnClear) {
      throw clearException ??
          const CacheException(message: 'تعذر حذف بيانات الجلسة بشكل آمن.');
    }
    _token = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FIX-02 Part A: SecureAuthTokenStorage Consistency & Error Handling', () {
    test('1. writeToken ناجح: يحفظ التوكن ويضع علامة has_auth_session', () async {
      final fakeStorage = FakeFlutterSecureStorage();
      final storage = SecureAuthTokenStorage(secureStorage: fakeStorage);

      await storage.writeToken('  valid_secure_token  ');

      expect(fakeStorage.storage[LocalStorageKeys.authToken], 'valid_secure_token');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_auth_session'), isTrue);
    });

    test('2. فشل SecureStorage يرمي CacheException ولا يبلع الخطأ', () async {
      final fakeStorage = FakeFlutterSecureStorage()..shouldThrowOnWrite = true;
      final storage = SecureAuthTokenStorage(secureStorage: fakeStorage);

      expect(
        () => storage.writeToken('any_token'),
        throwsA(isA<CacheException>()),
      );
    });

    test('3. CacheException وسجلات التشخيص لا تكشف تفاصيل Keystore أو المنصة الداخلية', () async {
      final fakeStorage = FakeFlutterSecureStorage()
        ..shouldThrowOnWrite = true
        ..writeException = PlatformException(
          code: 'KEYSTORE_EXCEPTION_1003',
          message: 'KeyStore operation failed: KEYMINT_BLOB_CORRUPTED in hardware crypto engine',
        );
      final storage = SecureAuthTokenStorage(secureStorage: fakeStorage);

      final capturedLogs = <String>[];
      final originalDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) {
          capturedLogs.add(message);
        }
      };

      try {
        await storage.writeToken('secret_token');
        fail('Should have thrown CacheException');
      } on CacheException catch (e) {
        expect(e.message, 'تعذر حفظ بيانات الجلسة بشكل آمن.');
        expect(e.message.contains('KEYMINT'), isFalse);
        expect(e.message.contains('KEYSTORE'), isFalse);
        expect(e.message.contains('PlatformException'), isFalse);
      } finally {
        debugPrint = originalDebugPrint;
      }

      // التحقق من أن السجلات التشخيصية لا تسرب نصوص المنصة الخام
      expect(capturedLogs, contains('[SecureStorage] Failed to write auth token.'));
      expect(
        capturedLogs.any((log) =>
            log.contains('KEYMINT') ||
            log.contains('KEYSTORE') ||
            log.contains('hardware crypto engine') ||
            log.contains('PlatformException')),
        isFalse,
      );
    });

    test('4. writeToken يحافظ على الـ StackTrace عند رمي CacheException', () async {
      final fakeStorage = FakeFlutterSecureStorage()..shouldThrowOnWrite = true;
      final storage = SecureAuthTokenStorage(secureStorage: fakeStorage);

      try {
        await storage.writeToken('secret_token');
        fail('Should have thrown CacheException');
      } catch (e, st) {
        expect(e, isA<CacheException>());
        expect(st.toString(), isNotEmpty);
      }
    });

    test('5. عند فشل SecureStorage لا يتم حفظ علامة has_auth_session في SharedPreferences', () async {
      final fakeStorage = FakeFlutterSecureStorage()..shouldThrowOnWrite = true;
      final storage = SecureAuthTokenStorage(secureStorage: fakeStorage);

      try {
        await storage.writeToken('secret_token');
      } catch (_) {}

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_auth_session'), isNull);
    });

    test('6. writeToken بقيمة فارغة يستدعي clearToken ولا يرمي CacheException', () async {
      final fakeStorage = FakeFlutterSecureStorage();
      fakeStorage.storage[LocalStorageKeys.authToken] = 'existing_token';
      final storage = SecureAuthTokenStorage(secureStorage: fakeStorage);

      await storage.writeToken('   ');

      expect(fakeStorage.storage[LocalStorageKeys.authToken], isNull);
    });

    test('6-B. readToken عند حدوث PlatformException يسجل رسالة تشخيصية معقمة ولا يسرب تفاصيل المنصة', () async {
      final fakeStorage = FakeFlutterSecureStorage()
        ..shouldThrowOnRead = true
        ..readException = PlatformException(
          code: 'KEYMINT_ERROR_44',
          message: 'Hardware backed keystore failed to decrypt blob',
        );
      final storage = SecureAuthTokenStorage(secureStorage: fakeStorage);

      final capturedLogs = <String>[];
      final originalDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) {
          capturedLogs.add(message);
        }
      };

      try {
        await storage.readToken();
        fail('Should have thrown CacheException');
      } on CacheException catch (e) {
        expect(e.message, 'تعذر الوصول إلى التخزين الآمن.');
        expect(e.message.contains('KEYMINT'), isFalse);
      } finally {
        debugPrint = originalDebugPrint;
      }

      expect(capturedLogs, contains('[SecureStorage] Platform exception occurred while reading secure token.'));
      expect(
        capturedLogs.any((log) =>
            log.contains('KEYMINT') ||
            log.contains('keystore') ||
            log.contains('decrypt blob')),
        isFalse,
      );
    });

    test('6-C. clearToken ناجح: يحذف التوكن وينظف علامة has_auth_session في SharedPreferences', () async {
      final fakeStorage = FakeFlutterSecureStorage();
      fakeStorage.storage[LocalStorageKeys.authToken] = 'token_to_delete';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_auth_session', true);
      await prefs.setString(LocalStorageKeys.authToken, 'legacy_copy');

      final storage = SecureAuthTokenStorage(secureStorage: fakeStorage);
      await storage.clearToken();

      expect(fakeStorage.storage[LocalStorageKeys.authToken], isNull);
      expect(prefs.getBool('has_auth_session'), isNull);
      expect(prefs.getString(LocalStorageKeys.authToken), isNull);
    });

    test('6-D. فشل clearToken يرمي CacheException مع StackTrace ورسالة وسجل معقمين', () async {
      final fakeStorage = FakeFlutterSecureStorage()
        ..shouldThrowOnDelete = true
        ..deleteException = PlatformException(
          code: 'KEYSTORE_DELETE_FAILED',
          message: 'KEYMINT_BLOB_CORRUPTED in hardware crypto engine on deletion',
        );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_auth_session', true);

      final storage = SecureAuthTokenStorage(secureStorage: fakeStorage);

      final capturedLogs = <String>[];
      final originalDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) {
          capturedLogs.add(message);
        }
      };

      try {
        await storage.clearToken();
        fail('Should have thrown CacheException');
      } on CacheException catch (e, st) {
        expect(e.message, 'تعذر حذف بيانات الجلسة بشكل آمن.');
        expect(e.message.contains('KEYMINT'), isFalse);
        expect(e.message.contains('KEYSTORE'), isFalse);
        expect(st.toString(), isNotEmpty);
      } finally {
        debugPrint = originalDebugPrint;
      }

      // لا يتم حذف علامة has_auth_session عند فشل العملية الأساسية
      expect(prefs.getBool('has_auth_session'), isTrue);

      // السجلات لا تكشف تفاصيل Keystore أو الاستثناء الخام
      expect(capturedLogs, contains('[SecureStorage] Failed to delete auth token.'));
      expect(
        capturedLogs.any((log) =>
            log.contains('KEYMINT') ||
            log.contains('KEYSTORE') ||
            log.contains('hardware crypto engine') ||
            log.contains('PlatformException')),
        isFalse,
      );
    });
  });

  group('FIX-02 Part B: AuthSessionNotifier & Phantom Session Prevention', () {
    test('7. تسجيل دخول ناجح: يحدث الجلسة إلى authenticated ويزيد sessionGeneration', () async {
      final mockStorage = ControllableTokenStorage();
      final container = ProviderContainer(
        overrides: [
          authTokenStorageProvider.overrideWithValue(mockStorage),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authSessionProvider.notifier);
      expect(container.read(authSessionProvider).status, AuthSessionStatus.unauthenticated);
      expect(container.read(authSessionProvider).sessionGeneration, 0);

      await notifier.startSession(
        accessToken: 'valid_jwt_token',
        customerPayload: const CustomerModel(id: 1, fullName: 'Ahmed', email: 'ahmed@example.com'),
      );

      final state = container.read(authSessionProvider);
      expect(state.status, AuthSessionStatus.authenticated);
      expect(state.token, 'valid_jwt_token');
      expect(state.sessionGeneration, 1);
      expect(state.customer?.id, 1);
      expect(await mockStorage.readToken(), 'valid_jwt_token');

      // انتظار انتهاء مزامنة الموفرات المعتمدة على الجلسة لتفادي نداء container بعد الإتلاف
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });

    test('8. فشل التخزين الآمن يمنع إنشاء جلسة وهمية (Phantom Authenticated Session)', () async {
      final failingStorage = ControllableTokenStorage()..shouldThrowOnWrite = true;
      final container = ProviderContainer(
        overrides: [
          authTokenStorageProvider.overrideWithValue(failingStorage),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authSessionProvider.notifier);
      final initialState = container.read(authSessionProvider);
      expect(initialState.status, AuthSessionStatus.unauthenticated);
      expect(initialState.token, isNull);
      expect(initialState.sessionGeneration, 0);

      // استدعاء startSession يجب أن يرمي CacheException
      await expectLater(
        () => notifier.startSession(
          accessToken: 'new_token_attempt',
          customerPayload: const CustomerModel(id: 42, fullName: 'Fail User', email: 'fail@example.com'),
        ),
        throwsA(isA<CacheException>().having(
          (e) => e.message,
          'message',
          'تعذر حفظ بيانات الجلسة بشكل آمن.',
        )),
      );

      // الحالة بالذاكرة يجب أن تبقى unauthenticated تماماً دون أي توكن أو عميل
      final afterState = container.read(authSessionProvider);
      expect(afterState.status, AuthSessionStatus.unauthenticated);
      expect(afterState.token, isNull);
      expect(afterState.customer, isNull);
      expect(afterState.sessionGeneration, 0);
    });

    test('9. الحفاظ على الجلسة السابقة الصحيحة عند فشل تخزين جلسة جديدة', () async {
      final controllableStorage = ControllableTokenStorage();
      final container = ProviderContainer(
        overrides: [
          authTokenStorageProvider.overrideWithValue(controllableStorage),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authSessionProvider.notifier);

      // 1. بدء جلسة أولى ناجحة
      await notifier.startSession(
        accessToken: 'session_1_token',
        customerPayload: const CustomerModel(id: 10, fullName: 'User 10', email: 'u10@example.com'),
      );
      expect(container.read(authSessionProvider).status, AuthSessionStatus.authenticated);
      expect(container.read(authSessionProvider).token, 'session_1_token');
      expect(container.read(authSessionProvider).sessionGeneration, 1);

      // 2. محاكاة فشل التخزين عند محاولة تسجيل دخول بجلسة ثانية
      controllableStorage.shouldThrowOnWrite = true;

      await expectLater(
        () => notifier.startSession(
          accessToken: 'session_2_token',
          customerPayload: const CustomerModel(id: 20, fullName: 'User 20', email: 'u20@example.com'),
        ),
        throwsA(isA<CacheException>()),
      );

      // 3. التحقق من بقاء الجلسة الأولى وعدم تلفها أو استبدالها بجلسة وهمية
      final currentState = container.read(authSessionProvider);
      expect(currentState.status, AuthSessionStatus.authenticated);
      expect(currentState.token, 'session_1_token');
      expect(currentState.customer?.id, 10);
      expect(currentState.sessionGeneration, 1);

      await Future<void>.delayed(const Duration(milliseconds: 100));
    });

    test('10. عند عدم توفر Storage يرمي CacheException ويبقى unauthenticated', () async {
      final container = ProviderContainer(
        overrides: [
          authTokenStorageProvider.overrideWith((ref) => throw Exception('Storage provider unavailable')),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authSessionProvider.notifier);

      await expectLater(
        () => notifier.startSession(accessToken: 'token_no_storage'),
        throwsA(isA<CacheException>()),
      );

      final state = container.read(authSessionProvider);
      expect(state.status, AuthSessionStatus.unauthenticated);
      expect(state.sessionGeneration, 0);
    });

    test('11. مسار emailVerificationRequired لا يخزن التوكن ويحدد الحالة بدقة', () async {
      final storage = ControllableTokenStorage();
      final container = ProviderContainer(
        overrides: [
          authTokenStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authSessionProvider.notifier);

      await notifier.startSession(
        accessToken: 'unverified_token',
        emailVerificationRequired: true,
      );

      final state = container.read(authSessionProvider);
      expect(state.status, AuthSessionStatus.emailVerificationRequired);
      expect(state.sessionGeneration, 1);
      // لم يتم استدعاء writeToken في التخزين الآمن لمسار البريد غير المؤكد
      expect(await storage.readToken(), isNull);
    });

    test('12. فشل حذف التوكن أثناء logout يرمي CacheException ولا يعلن نجاح الخروج وهمياً', () async {
      final stubRepo = StubAuthRepository();
      final controllableStorage = ControllableTokenStorage(initialToken: 'active_session_token')
        ..shouldThrowOnClear = true;

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(stubRepo),
          authTokenStorageProvider.overrideWithValue(controllableStorage),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authSessionProvider.notifier);

      // بدء جلسة ناجحة أولاً
      await notifier.startSession(
        accessToken: 'active_session_token',
        customerPayload: const CustomerModel(id: 7, fullName: 'Active User', email: 'user@example.com'),
      );
      expect(container.read(authSessionProvider).status, AuthSessionStatus.authenticated);

      // محاولة تسجيل الخروج مع فشل Secure Storage في الحذف
      await expectLater(
        () => notifier.logout(),
        throwsA(isA<CacheException>().having(
          (e) => e.message,
          'message',
          'تعذر حذف بيانات الجلسة بشكل آمن.',
        )),
      );

      // استدعاء logout تم على خادم API ولكن محلياً رمى CacheException
      expect(stubRepo.logoutCallCount, 1);
      expect(controllableStorage.clearCallCount, 1);
    });

    test('13. فشل حذف التوكن أثناء logout يمنع استدعاء onSessionTerminated', () async {
      final stubRepo = StubAuthRepository();
      final controllableStorage = ControllableTokenStorage(initialToken: 'test_token')
        ..shouldThrowOnClear = true;

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(stubRepo),
          authTokenStorageProvider.overrideWithValue(controllableStorage),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authSessionProvider.notifier);
      bool sessionTerminatedCallbackCalled = false;
      notifier.onSessionTerminated = () {
        sessionTerminatedCallbackCalled = true;
      };

      await expectLater(
        () => notifier.logout(),
        throwsA(isA<CacheException>()),
      );

      // عدم استدعاء callback انتهاء الجلسة عند فشل الحذف
      expect(sessionTerminatedCallbackCalled, isFalse);
    });

    test('14. فشل حذف التوكن أثناء clearSession يرمي CacheException دون ابتلاع', () async {
      final controllableStorage = ControllableTokenStorage(initialToken: 'test_token')
        ..shouldThrowOnClear = true;

      final container = ProviderContainer(
        overrides: [
          authTokenStorageProvider.overrideWithValue(controllableStorage),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authSessionProvider.notifier);

      await expectLater(
        () => notifier.clearSession(),
        throwsA(isA<CacheException>().having(
          (e) => e.message,
          'message',
          'تعذر حذف بيانات الجلسة بشكل آمن.',
        )),
      );
      expect(controllableStorage.clearCallCount, 1);
    });

    test('15. نجاح logout الطبيعي عند حذف التوكن بنجاح', () async {
      final stubRepo = StubAuthRepository();
      final controllableStorage = ControllableTokenStorage(initialToken: 'session_token');

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(stubRepo),
          authTokenStorageProvider.overrideWithValue(controllableStorage),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authSessionProvider.notifier);
      bool sessionTerminatedCalled = false;
      notifier.onSessionTerminated = () {
        sessionTerminatedCalled = true;
      };

      await notifier.startSession(
        accessToken: 'session_token',
        customerPayload: const CustomerModel(id: 99, fullName: 'Good User', email: 'good@example.com'),
      );
      expect(container.read(authSessionProvider).status, AuthSessionStatus.authenticated);

      await notifier.logout();

      expect(stubRepo.logoutCallCount, 1);
      expect(sessionTerminatedCalled, isTrue);
      expect(container.read(authSessionProvider).status, AuthSessionStatus.unauthenticated);
      expect(container.read(authSessionProvider).token, isNull);

      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
  });
}
