import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/errors/exceptions.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/network/api_client.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/core/services/auth/models/auth_session_state.dart';
import 'package:rwnaqk_frontend/core/services/geo/geo_lookup_api_service.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/forgot_password_service.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/login_service.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/register_service.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository_impl.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/passkey_model.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/user_session_model.dart';
import 'package:rwnaqk_frontend/modules/customer/providers/customer_profile_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// مخزن توكن تتبعي يحصي عدد استدعاءات writeToken و clearToken بدقة
class TrackingTokenStorage implements IAuthTokenStorage {
  String? token;
  int writeCount = 0;
  int readCount = 0;
  int clearCount = 0;
  bool shouldThrowOnWrite = false;
  bool shouldThrowOnClear = false;

  @override
  Future<String?> readToken() async {
    readCount++;
    return token;
  }

  @override
  Future<void> writeToken(String newToken) async {
    writeCount++;
    if (shouldThrowOnWrite) {
      throw const CacheException(message: 'Storage write failed: KeyStore locked');
    }
    token = newToken.trim();
  }

  @override
  Future<void> clearToken() async {
    clearCount++;
    if (shouldThrowOnClear) {
      throw const CacheException(message: 'Storage clear failed');
    }
    token = null;
  }
}

/// Fake IAuthRepository لا يمس التخزين إطلاقاً
class FakeAuthRepository implements IAuthRepository {
  bool shouldFail = false;
  bool shouldMeFail = false;
  bool isBannedResponse = false;
  bool requiresEmailVerification = false;
  bool requires2FA = false;
  String returnedToken = 'jwt_valid_sample_token';
  CustomerModel? returnedCustomer = const CustomerModel(
    id: 101,
    firstName: 'أحمد',
    lastName: 'علي',
    email: 'ahmed@example.com',
  );
  CustomerModel? meCustomer;

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
    String? code,
    String? recoveryCode,
    String? deviceName,
  }) async {
    if (shouldFail) {
      throw Exception('API login request failed');
    }
    if (isBannedResponse) {
      return LoginResult(
        isSuccess: false,
        requiresTwoFactor: false,
        requiresEmailVerification: false,
        isBanned: true,
        message: 'تم حظر حسابك.',
        customer: returnedCustomer?.copyWith(isBanned: true),
      );
    }
    return LoginResult(
      isSuccess: true,
      requiresTwoFactor: requires2FA,
      requiresEmailVerification: requiresEmailVerification,
      token: returnedToken,
      customer: returnedCustomer,
    );
  }

  @override
  Future<LoginResult> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String country,
    required String governorate,
    required String password,
    required String passwordConfirmation,
    required bool termsAccepted,
    required bool privacyPolicyAccepted,
    String? gender,
    String? deviceName,
  }) async {
    if (shouldFail) {
      throw Exception('API register request failed');
    }
    if (isBannedResponse) {
      return LoginResult(
        isSuccess: false,
        requiresTwoFactor: false,
        requiresEmailVerification: false,
        isBanned: true,
        message: 'تم حظر حسابك.',
        customer: returnedCustomer?.copyWith(isBanned: true),
      );
    }
    return LoginResult(
      isSuccess: true,
      requiresTwoFactor: false,
      requiresEmailVerification: requiresEmailVerification,
      token: returnedToken,
      customer: returnedCustomer,
    );
  }

  @override
  Future<CustomerModel> me() async {
    if (shouldFail || shouldMeFail) throw Exception('API me failed');
    return meCustomer ?? returnedCustomer!;
  }

  @override
  Future<void> logout() async {
    if (shouldFail) throw Exception('API logout failed');
  }

  @override
  Future<void> forgotPassword({required String email}) async {}

  @override
  Future<void> verifyPasswordResetCode({required String email, required String code}) async {}

  @override
  Future<void> resetPassword({required String token, required String email, required String password}) async {}

  @override
  Future<void> sendEmailVerificationCode() async {}

  @override
  Future<void> verifyEmailCode({required String code}) async {}

  @override
  Future<CustomerModel> updateProfile({
    String? firstName,
    String? lastName,
    String? name,
    String? email,
    String? mobile,
    String? gender,
    String? avatarFilePath,
  }) async {
    return returnedCustomer!;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {}

  @override
  Future<List<UserSessionModel>> getSessions() async => [];

  @override
  Future<void> revokeSession(int id) async {}

  @override
  Future<void> revokeOtherSessions() async {}

  @override
  Future<List<PasskeyModel>> getPasskeys() async => [];

  @override
  Future<PasskeyModel> storePasskey({
    required String name,
    String? credentialId,
    Map<String, dynamic>? credential,
  }) async {
    return const PasskeyModel(id: 1, name: 'Default Passkey');
  }

  @override
  Future<LoginResult> passkeyLogin({required String credentialId, String? secret, String? email}) async {
    return LoginResult(
      isSuccess: true,
      requiresTwoFactor: false,
      requiresEmailVerification: false,
      token: returnedToken,
      customer: returnedCustomer,
    );
  }

  @override
  Future<void> deletePasskey(int id) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TrackingTokenStorage trackingStorage;
  late FakeAuthRepository fakeRepo;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    trackingStorage = TrackingTokenStorage();
    fakeRepo = FakeAuthRepository();

    container = ProviderContainer(
      overrides: [
        authTokenStorageProvider.overrideWithValue(trackingStorage),
        sharedPreferencesInstanceProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Group A — Repository Ownership (AuthRepositoryImpl)', () {
    test('1. AuthRepositoryImpl.login يعيد التوكن دون استدعاء writeToken في التخزين', () async {
      // إعداد ApiClient مع محاكي استجابة تسجيل الدخول
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'token': 'repo_login_token_123',
                  'customer': {
                    'id': 1,
                    'first_name': 'سالم',
                    'last_name': 'عمر',
                    'email': 'salem@example.com',
                  },
                },
              ),
            );
          },
        ),
      );

      final apiClient = ApiClient(dio: dio, tokenStorage: trackingStorage);
      final repo = AuthRepositoryImpl(apiClient: apiClient);

      final result = await repo.login(
        email: 'salem@example.com',
        password: 'Password123!',
      );

      expect(result.isSuccess, isTrue);
      expect(result.token, equals('repo_login_token_123'));
      // التأكد الصارم: المستودع لا يكتب التوكن إطلاقاً
      expect(trackingStorage.writeCount, equals(0));
      expect(trackingStorage.token, isNull);
    });

    test('2. AuthRepositoryImpl.register يعيد التوكن دون استدعاء writeToken', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: {
                  'token': 'repo_register_token_456',
                  'requires_email_verification': true,
                  'customer': {
                    'id': 2,
                    'first_name': 'فاطمة',
                    'last_name': 'علي',
                    'email': 'fatima@example.com',
                  },
                },
              ),
            );
          },
        ),
      );

      final apiClient = ApiClient(dio: dio, tokenStorage: trackingStorage);
      final repo = AuthRepositoryImpl(apiClient: apiClient);

      final result = await repo.register(
        firstName: 'فاطمة',
        lastName: 'علي',
        phone: '777123456',
        email: 'fatima@example.com',
        country: 'اليمن',
        governorate: 'صنعاء',
        password: 'Password123!',
        passwordConfirmation: 'Password123!',
        termsAccepted: true,
        privacyPolicyAccepted: true,
      );

      expect(result.isSuccess, isTrue);
      expect(result.token, equals('repo_register_token_456'));
      expect(result.requiresEmailVerification, isTrue);
      // لم يتم استدعاء writeToken من المستودع
      expect(trackingStorage.writeCount, equals(0));
      expect(trackingStorage.token, isNull);
    });

    test('3. فشل طلب API في AuthRepositoryImpl لا يستدعي writeToken', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 422,
                  data: {'message': 'البريد أو كلمة المرور غير صحيحة'},
                ),
              ),
            );
          },
        ),
      );

      final apiClient = ApiClient(dio: dio, tokenStorage: trackingStorage);
      final repo = AuthRepositoryImpl(apiClient: apiClient);

      expect(
        () => repo.login(email: 'fail@example.com', password: 'wrong'),
        throwsA(isA<Exception>()),
      );
      expect(trackingStorage.writeCount, equals(0));
    });

    test('4. AuthRepositoryImpl.passkeyLogin يعيد التوكن دون استدعاء writeToken', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'token': 'passkey_token_789',
                  'customer': {'id': 3, 'first_name': 'ياسر'},
                },
              ),
            );
          },
        ),
      );

      final apiClient = ApiClient(dio: dio, tokenStorage: trackingStorage);
      final repo = AuthRepositoryImpl(apiClient: apiClient);

      final result = await repo.passkeyLogin(credentialId: 'cred_123');

      expect(result.isSuccess, isTrue);
      expect(result.token, equals('passkey_token_789'));
      expect(trackingStorage.writeCount, equals(0));
    });
  });

  group('Group B — Single Writer (AuthSessionNotifier)', () {
    test('1. AuthSessionNotifier.startSession يكتب التوكن مرة واحدة فقط', () async {
      final notifier = container.read(authSessionProvider.notifier);

      await notifier.startSession(accessToken: 'auth_session_token_1');

      expect(trackingStorage.writeCount, equals(1));
      expect(trackingStorage.token, equals('auth_session_token_1'));
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);
      expect(container.read(authSessionProvider).sessionGeneration, equals(1));
    });

    test('2. تسجيل الدخول الناجح عبر LoginService ينتج عنه كتابة واحدة فقط', () async {
      final notifier = container.read(authSessionProvider.notifier);
      final loginService = LoginService(fakeRepo, notifier);

      fakeRepo.returnedToken = 'login_single_write_token';

      final result = await loginService.login(
        email: 'ahmed@example.com',
        password: 'secretPassword',
      );

      expect(result.isSuccess, isTrue);
      expect(trackingStorage.writeCount, equals(1));
      expect(trackingStorage.token, equals('login_single_write_token'));
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);
    });

    test('3. التسجيل الذي يسمح بجلسة نشطة ينتج عنه كتابة واحدة فقط', () async {
      final notifier = container.read(authSessionProvider.notifier);
      final geoService = GeoLookupApiService(dio: Dio());
      final registerService = RegisterService(fakeRepo, notifier, geoService);

      fakeRepo.returnedToken = 'register_single_write_token';
      fakeRepo.requiresEmailVerification = false;

      final result = await registerService.register(
        firstName: 'أحمد',
        lastName: 'علي',
        phone: '777000000',
        email: 'ahmed@example.com',
        country: 'اليمن',
        governorate: 'صنعاء',
        password: 'Pass1234!',
        passwordConfirmation: 'Pass1234!',
        termsAccepted: true,
        privacyPolicyAccepted: true,
      );

      expect(result.requiresEmailVerification, isFalse);
      expect(trackingStorage.writeCount, equals(1));
      expect(trackingStorage.token, equals('register_single_write_token'));
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);
    });

    test('4. لا تحدث كتابة مكررة إذا كان التوكن مطابقاً للمخزن مسبقاً', () async {
      final notifier = container.read(authSessionProvider.notifier);

      await notifier.startSession(accessToken: 'idempotent_token');
      expect(trackingStorage.writeCount, equals(1));

      // إعادة استدعاء startSession بنفس التوكن
      await notifier.startSession(accessToken: 'idempotent_token');
      expect(trackingStorage.writeCount, equals(1));
    });

    test('5. فشل التخزين الآمن في startSession لا ينتج عنه جلسة مصادق عليها ولا زيادة generation', () async {
      final notifier = container.read(authSessionProvider.notifier);
      trackingStorage.shouldThrowOnWrite = true;

      final initialGen = container.read(authSessionProvider).sessionGeneration;

      expect(
        () => notifier.startSession(accessToken: 'unpersisted_token'),
        throwsA(isA<CacheException>()),
      );

      final state = container.read(authSessionProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.status, equals(AuthSessionStatus.unauthenticated));
      expect(state.token, isNull);
      expect(state.sessionGeneration, equals(initialGen));
    });

    test('6. التوكن الجديد لا يستبدل جلسة سابقة إذا فشلت كتابته في التخزين', () async {
      final notifier = container.read(authSessionProvider.notifier);

      // جلسة صالحة أولية
      await notifier.startSession(
        accessToken: 'initial_valid_token',
        customerPayload: const CustomerModel(id: 1, email: 'initial@test.com'),
      );
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);
      expect(container.read(authSessionProvider).sessionGeneration, equals(1));

      // محاولة تسجيل دخول ثانٍ يفشل في التخزين
      trackingStorage.shouldThrowOnWrite = true;

      expect(
        () => notifier.startSession(
          accessToken: 'second_failing_token',
          customerPayload: const CustomerModel(id: 2, email: 'second@test.com'),
        ),
        throwsA(isA<CacheException>()),
      );

      // الجلسة الحالية لا تزال تحتفظ بالتوكن القديم في التخزين ولم تُستبدل بالتوكن الفاشل
      expect(trackingStorage.token, equals('initial_valid_token'));
    });
  });

  group('Group C — Authentication Flow Regression', () {
    test('1. التسجيل الذي يتطلب تأكيد البريد لا يخزن التوكن في Secure Storage', () async {
      final notifier = container.read(authSessionProvider.notifier);
      final geoService = GeoLookupApiService(dio: Dio());
      final registerService = RegisterService(fakeRepo, notifier, geoService);

      fakeRepo.returnedToken = 'unverified_token_abc';
      fakeRepo.requiresEmailVerification = true;

      final result = await registerService.register(
        firstName: 'محمد',
        lastName: 'صالح',
        phone: '777111222',
        email: 'mohamed@example.com',
        country: 'اليمن',
        governorate: 'عدن',
        password: 'Pass1234!',
        passwordConfirmation: 'Pass1234!',
        termsAccepted: true,
        privacyPolicyAccepted: true,
      );

      expect(result.requiresEmailVerification, isTrue);
      // التوكن غير المفعل لا يُحفظ في التخزين الآمن
      expect(trackingStorage.writeCount, equals(0));
      expect(trackingStorage.token, isNull);

      final state = container.read(authSessionProvider);
      expect(state.status, equals(AuthSessionStatus.emailVerificationRequired));
      expect(state.isAuthenticated, isFalse);
    });

    test('2. تأكيد البريد الإلكتروني completeEmailVerification يكتب التوكن لأول مرة ويصل للجلسة النشطة', () async {
      final notifier = container.read(authSessionProvider.notifier);

      // بدء جلسة بانتظار تأكيد البريد
      await notifier.startSession(
        accessToken: 'verified_after_otp_token',
        emailVerificationRequired: true,
      );
      expect(trackingStorage.writeCount, equals(0));
      expect(container.read(authSessionProvider).isAuthenticated, isFalse);

      // إكمال تأكيد البريد
      await notifier.completeEmailVerification();

      expect(trackingStorage.writeCount, equals(1));
      expect(trackingStorage.token, equals('verified_after_otp_token'));
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);
    });

    test('3. استعادة كلمة المرور sendPasswordResetLink لا تنشئ جلسة أو تكتب توكن', () async {
      final notifier = container.read(authSessionProvider.notifier);
      final forgotService = ForgotPasswordService(fakeRepo, notifier);

      final message = await forgotService.sendPasswordResetLink(email: 'user@example.com');

      expect(message, contains('Password reset link sent'));
      expect(trackingStorage.writeCount, equals(0));
      expect(container.read(authSessionProvider).isAuthenticated, isFalse);
    });

    test('4. تسجيل الخروج logout يستدعي clearToken ويصفي الجلسة', () async {
      final notifier = container.read(authSessionProvider.notifier);

      await notifier.startSession(accessToken: 'active_session_token');
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);
      expect(trackingStorage.token, isNotNull);

      await notifier.logout();

      expect(trackingStorage.clearCount, greaterThanOrEqualTo(1));
      expect(trackingStorage.token, isNull);
      expect(container.read(authSessionProvider).isAuthenticated, isFalse);
    });
  });

  group('Group D — Security & Resilience Regression (FIX-01 & FIX-02)', () {
    test('1. سياسة حقن التوكن تظل denied أثناء الحظر والـ Single Writer لا يتجاوزها', () async {
      final notifier = container.read(authSessionProvider.notifier);

      await notifier.startSession(accessToken: 'token_to_ban');
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);

      notifier.markAsBanned();
      final state = container.read(authSessionProvider);

      expect(state.isBanned, isTrue);
      expect(state.status, equals(AuthSessionStatus.banned));
      expect(state.token, isNull);
    });

    test('2. handleUnauthorized يتجاهل الاستجابات ذات الـ Generation القديم', () async {
      final notifier = container.read(authSessionProvider.notifier);

      await notifier.startSession(accessToken: 'account_1_token');
      final gen1 = container.read(authSessionProvider).sessionGeneration;

      await notifier.startSession(accessToken: 'account_2_token');
      final gen2 = container.read(authSessionProvider).sessionGeneration;
      expect(gen2, greaterThan(gen1));

      // وصول استجابة 401 قديمة تحمل رقم الجيل القديم gen1
      await notifier.handleUnauthorized(
        failedToken: 'account_1_token',
        staleGeneration: gen1,
      );

      // الجلسة الحالية gen2 تظل نشطة ومحمية
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);
      expect(container.read(authSessionProvider).token, equals('account_2_token'));
    });
  });

  group('Group E — Passkey & Biometric & Two-Factor Flow Integration', () {
    test('1. Passkey Login: نجاح المصادقة ينشئ جلسة مع كتابة واحدة فقط دون تكرار', () async {
      final notifier = container.read(authSessionProvider.notifier);

      fakeRepo.returnedToken = 'passkey_flow_jwt';
      final passkeyResult = await fakeRepo.passkeyLogin(credentialId: 'cred_valid');

      expect(passkeyResult.isSuccess, isTrue);
      expect(trackingStorage.writeCount, equals(0)); // المستودع لا يكتب التوكن

      await notifier.startSession(
        accessToken: passkeyResult.token!,
        customerPayload: passkeyResult.customer,
      );

      expect(trackingStorage.writeCount, equals(1));
      expect(trackingStorage.token, equals('passkey_flow_jwt'));
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);
    });

    test('2. Passkey Login: فشل التخزين الآمن يمنع إنشاء جلسة مصادقة وهمية', () async {
      final notifier = container.read(authSessionProvider.notifier);
      trackingStorage.shouldThrowOnWrite = true;

      final passkeyResult = await fakeRepo.passkeyLogin(credentialId: 'cred_valid');
      expect(passkeyResult.isSuccess, isTrue);

      expect(
        () => notifier.startSession(
          accessToken: passkeyResult.token!,
          customerPayload: passkeyResult.customer,
        ),
        throwsA(isA<CacheException>()),
      );

      expect(container.read(authSessionProvider).isAuthenticated, isFalse);
    });

    test('3. Biometric Fallback: التوكن البديل يبدأ الجلسة بكتابة واحدة فقط', () async {
      final notifier = container.read(authSessionProvider.notifier);
      const fallbackToken = 'biometric_fallback_token_999';

      // المسار البديل يبدأ الجلسة عبر startSession مباشرة دون writeToken مسبق
      await notifier.startSession(accessToken: fallbackToken);

      expect(trackingStorage.writeCount, equals(1));
      expect(trackingStorage.token, equals(fallbackToken));
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);
    });

    test('4. Two-Factor Login: نجاح verifyTwoFactorLogin يمرر التوكن إلى startSession بكتابة واحدة', () async {
      final notifier = container.read(authSessionProvider.notifier);
      final forgotService = ForgotPasswordService(fakeRepo, notifier);

      fakeRepo.returnedToken = '2fa_verified_jwt';
      final result = await forgotService.verifyTwoFactorLogin(
        email: 'ahmed@example.com',
        password: 'Password123',
        code: '123456',
      );

      expect(result.success, isTrue);
      expect(trackingStorage.writeCount, equals(1));
      expect(trackingStorage.token, equals('2fa_verified_jwt'));
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);
    });

    test('5. Two-Factor Login: فشل التحقق لا ينشئ جلسة ولا يكتب توكناً', () async {
      final notifier = container.read(authSessionProvider.notifier);
      final forgotService = ForgotPasswordService(fakeRepo, notifier);

      fakeRepo.shouldFail = true;

      expect(
        () => forgotService.verifyTwoFactorLogin(
          email: 'ahmed@example.com',
          password: 'Password123',
          code: 'wrong_code',
        ),
        throwsA(isA<Exception>()),
      );

      expect(trackingStorage.writeCount, equals(0));
      expect(container.read(authSessionProvider).isAuthenticated, isFalse);
    });
  });

  group('Group F — Banned Account Protection & Pre-session Verification', () {
    test('1. استدعاء startSession مع customerPayload محظور يرفض الجلسة فوراً ولا يكتب التوكن', () async {
      final notifier = container.read(authSessionProvider.notifier);

      const bannedCustomer = CustomerModel(id: 999, email: 'banned@test.com', isBanned: true);

      await notifier.startSession(
        accessToken: 'banned_user_token',
        customerPayload: bannedCustomer,
      );

      expect(trackingStorage.writeCount, equals(0));
      expect(trackingStorage.token, isNull);
      expect(container.read(authSessionProvider).isAuthenticated, isFalse);
      expect(container.read(authSessionProvider).isBanned, isTrue);
      expect(container.read(authSessionProvider).status, equals(AuthSessionStatus.banned));
    });

    test('2. recoverCustomerProfile مع حساب محظور يرفض الحساب ويحوله إلى banned', () async {
      final notifier = container.read(authSessionProvider.notifier);

      await notifier.startSession(
        accessToken: 'token_to_recover_banned',
        customerPayload: null,
      );

      // المستودع سيعيد عميلاً محظوراً عند طلب me()
      fakeRepo.returnedCustomer = const CustomerModel(id: 888, email: 'ghost_banned@test.com', isBanned: true);

      final recovered = await notifier.recoverCustomerProfile();

      expect(recovered, isNull);
      expect(container.read(authSessionProvider).isAuthenticated, isFalse);
      expect(container.read(authSessionProvider).isBanned, isTrue);
      expect(container.read(authSessionProvider).status, equals(AuthSessionStatus.banned));
    });

    test('3. LoginService مع حساب محظور يرفض إنشاء الجلسة فوراً ولا يستدعي writeToken', () async {
      final notifier = container.read(authSessionProvider.notifier);
      final loginService = LoginService(fakeRepo, notifier);

      fakeRepo.isBannedResponse = true;

      final result = await loginService.login(
        email: 'banned@example.com',
        password: 'anyPassword',
      );

      expect(result.isBanned, isTrue);
      expect(trackingStorage.writeCount, equals(0));
      expect(container.read(authSessionProvider).isAuthenticated, isFalse);
      expect(container.read(authSessionProvider).isBanned, isTrue);
    });
  });

  group('Group G — Logout Ownership Verification', () {
    test('1. CustomerSettingsNotifier.logout يفوض AuthSessionNotifier.logout وينظف التخزين والجلسة', () async {
      final notifier = container.read(authSessionProvider.notifier);

      // تأسيس جلسة نشطة
      await notifier.startSession(accessToken: 'settings_logout_token');
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);
      expect(trackingStorage.token, isNotNull);

      // تنفيذ تسجيل الخروج عبر شاشة الإعدادات
      final settingsNotifier = container.read(customerSettingsProvider.notifier);
      await settingsNotifier.logout();

      // تأكيد تنظيف التخزين الآمن والجلسة بالكامل
      expect(trackingStorage.clearCount, greaterThanOrEqualTo(1));
      expect(trackingStorage.token, isNull);
      expect(container.read(authSessionProvider).isAuthenticated, isFalse);
    });
  });

  group('Group H — FIX-03 Final Hardening: Banned Cleanup & Login Bootstrap Safety', () {
    test('1. markAsBanned مع وجود توكن مخزن ينتظر تفريغ التخزين الآمن وينظف الذاكرة', () async {
      final notifier = container.read(authSessionProvider.notifier);

      await notifier.startSession(
        accessToken: 'banned_cleanup_token',
        customerPayload: const CustomerModel(id: 42, email: 'user@test.com'),
      );
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);
      expect(trackingStorage.token, equals('banned_cleanup_token'));

      await notifier.markAsBanned(
        customerPayload: const CustomerModel(id: 42, email: 'user@test.com', isBanned: true),
        reason: 'حظر أمني',
      );

      expect(trackingStorage.clearCount, greaterThanOrEqualTo(1));
      expect(trackingStorage.token, isNull);
      final state = container.read(authSessionProvider);
      expect(state.isBanned, isTrue);
      expect(state.isAuthenticated, isFalse);
      expect(state.token, isNull);
      expect(state.status, equals(AuthSessionStatus.banned));
    });

    test('2. markAsBanned يتعامل مع فشل التخزين الآمن بأمان دون تسريب ودون كسر حالة الحظر', () async {
      final notifier = container.read(authSessionProvider.notifier);

      await notifier.startSession(
        accessToken: 'cache_exception_token',
        customerPayload: const CustomerModel(id: 43, email: 'user2@test.com'),
      );
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);

      trackingStorage.shouldThrowOnClear = true;

      await notifier.markAsBanned(
        customerPayload: const CustomerModel(id: 43, email: 'user2@test.com', isBanned: true),
        reason: 'حظر فوري',
      );

      final state = container.read(authSessionProvider);
      expect(state.isBanned, isTrue);
      expect(state.isAuthenticated, isFalse);
      expect(state.token, isNull);
      expect(state.status, equals(AuthSessionStatus.banned));
    });

    test('3. LoginService مع بيانات العميل (Path A): نجاح فوري، كتابة واحدة، جلسة موثقة', () async {
      final notifier = container.read(authSessionProvider.notifier);
      final loginService = LoginService(fakeRepo, notifier);

      fakeRepo.returnedCustomer = const CustomerModel(id: 201, email: 'pathA@test.com');
      fakeRepo.returnedToken = 'path_a_jwt_token';

      final result = await loginService.login(
        email: 'pathA@test.com',
        password: 'password123',
      );

      expect(result.isSuccess, isTrue);
      expect(result.customer?.id, equals(201));
      expect(trackingStorage.writeCount, equals(1));
      expect(trackingStorage.token, equals('path_a_jwt_token'));

      final state = container.read(authSessionProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.customer?.id, equals(201));
    });

    test('4. LoginService بدون بيانات العميل (Path B): نجاح me() يؤدي إلى جلسة موثقة وكتابة واحدة للتوكن', () async {
      final notifier = container.read(authSessionProvider.notifier);
      final loginService = LoginService(fakeRepo, notifier);

      fakeRepo.returnedCustomer = null;
      fakeRepo.meCustomer = CustomerModel(
        id: 301,
        email: 'verified@test.com',
        emailVerifiedAt: DateTime.now(),
      );
      fakeRepo.returnedToken = 'path_b_jwt_token';

      final result = await loginService.login(
        email: 'pathB@test.com',
        password: 'password123',
      );

      expect(result.isSuccess, isTrue);
      expect(result.customer?.id, equals(301));
      expect(trackingStorage.writeCount, equals(1));
      expect(trackingStorage.token, equals('path_b_jwt_token'));

      final state = container.read(authSessionProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.customer?.id, equals(301));
      expect(state.isBootstrapping, isFalse);
    });

    test('5. LoginService بدون بيانات العميل (Path B): فشل me() يفشل بشكل آمن وينظف التخزين والجلسة', () async {
      final notifier = container.read(authSessionProvider.notifier);
      final loginService = LoginService(fakeRepo, notifier);

      fakeRepo.returnedCustomer = null;
      fakeRepo.shouldMeFail = true;
      fakeRepo.returnedToken = 'path_b_failed_token';

      final result = await loginService.login(
        email: 'pathB_fail@test.com',
        password: 'password123',
      );

      expect(result.isSuccess, isFalse);
      expect(result.customer, isNull);

      final state = container.read(authSessionProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.token, isNull);
      expect(trackingStorage.token, isNull);
      expect(trackingStorage.clearCount, greaterThanOrEqualTo(1));
    });

    test('6. LoginService بدون بيانات العميل (Path B): اكتشاف الحظر عبر me() يوسم الحساب كمحظور وينظف التخزين', () async {
      final notifier = container.read(authSessionProvider.notifier);
      final loginService = LoginService(fakeRepo, notifier);

      fakeRepo.returnedCustomer = null;
      fakeRepo.meCustomer = const CustomerModel(id: 401, email: 'banned_me@test.com', isBanned: true);
      fakeRepo.returnedToken = 'path_b_banned_token';

      final result = await loginService.login(
        email: 'pathB_banned@test.com',
        password: 'password123',
      );

      expect(result.isSuccess, isFalse);
      expect(result.isBanned, isTrue);

      final state = container.read(authSessionProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.isBanned, isTrue);
      expect(state.token, isNull);
      expect(trackingStorage.token, isNull);
    });

    test('7. LoginService بدون بيانات العميل (Path B): فشل التخزين يمنع الجلسة الوهمية تماماً', () async {
      final notifier = container.read(authSessionProvider.notifier);
      final loginService = LoginService(fakeRepo, notifier);

      fakeRepo.returnedCustomer = null;
      fakeRepo.meCustomer = const CustomerModel(id: 501, email: 'store_fail@test.com');
      fakeRepo.returnedToken = 'path_b_fail_store_token';
      trackingStorage.shouldThrowOnWrite = true;

      final result = await loginService.login(
        email: 'store_fail@test.com',
        password: 'password123',
      );

      expect(result.isSuccess, isFalse);
      expect(result.customer, isNull);

      final state = container.read(authSessionProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.token, isNull);
      expect(trackingStorage.token, isNull);
    });
  });
}
