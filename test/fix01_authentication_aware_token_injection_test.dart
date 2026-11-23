import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/network/api_client.dart';
import 'package:rwnaqk_frontend/core/network/api_exceptions.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/core/services/auth/models/auth_session_state.dart';
import 'package:rwnaqk_frontend/modules/auth/data/auth_endpoints.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StubTokenStorage implements IAuthTokenStorage {
  String? token;
  int clearCallCount = 0;
  bool shouldThrowOnClear = false;
  Duration? readDelay;

  StubTokenStorage({this.token});

  @override
  Future<void> clearToken() async {
    clearCallCount++;
    if (shouldThrowOnClear) {
      throw const FormatException('Simulated SecureStorage deletion failure');
    }
    token = null;
  }

  @override
  Future<String?> readToken() async {
    if (readDelay != null) {
      await Future<void>.delayed(readDelay!);
    }
    return token;
  }

  @override
  Future<void> writeToken(String newToken) async => token = newToken;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FIX-01: Authentication-Aware Token Injection Tests (24 Scenarios)', () {
    // -------------------------------------------------------------------------
    // المجموعة الأولى: الاختبارات الأساسية (1-11)
    // -------------------------------------------------------------------------

    test('1. unauthenticated مع stale token في التخزين: لا يرسل التوكن', () async {
      final storage = StubTokenStorage(token: 'stale_token_from_old_session');
      final dio = Dio();
      RequestOptions? interceptedOptions;

      final client = ApiClient(
        dio: dio,
        tokenStorage: storage,
        getSessionTokenContext: (options) {
          return const SessionTokenContext.denied(status: AuthSessionStatus.unauthenticated);
        },
      );

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          interceptedOptions = options;
          return handler.resolve(Response(requestOptions: options, statusCode: 200));
        },
      ));

      await client.get<dynamic>('/api/v1/customer/orders');

      expect(interceptedOptions, isNotNull);
      expect(interceptedOptions!.headers.containsKey('Authorization'), isFalse);
      expect(interceptedOptions!.extra['requestToken'], isNull);
    });

    test('2. banned مع stale token: لا يرسل التوكن وتُجرّد الترويسات', () async {
      final storage = StubTokenStorage(token: 'banned_user_token_999');
      final dio = Dio();
      RequestOptions? interceptedOptions;

      final client = ApiClient(
        dio: dio,
        tokenStorage: storage,
        getSessionTokenContext: (options) {
          return const SessionTokenContext.denied(status: AuthSessionStatus.banned, banned: true);
        },
      );

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          interceptedOptions = options;
          return handler.resolve(Response(requestOptions: options, statusCode: 200));
        },
      ));

      await client.get<dynamic>('/api/v1/customer/profile');

      expect(interceptedOptions, isNotNull);
      expect(interceptedOptions!.headers.containsKey('Authorization'), isFalse);
      expect(interceptedOptions!.extra['requestToken'], isNull);
    });

    test('3. authenticated مع توكن صحيح: يعمل التوكن بشكل طبيعي', () async {
      final storage = StubTokenStorage(token: 'active_valid_token_xyz');
      final dio = Dio();
      RequestOptions? interceptedOptions;

      final client = ApiClient(
        dio: dio,
        tokenStorage: storage,
        getSessionTokenContext: (options) {
          return const SessionTokenContext(
            policy: TokenInjectionPolicy.allowed,
            currentSessionToken: 'active_valid_token_xyz',
            sessionGeneration: 5,
            sessionStatus: AuthSessionStatus.authenticated,
          );
        },
      );

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          interceptedOptions = options;
          return handler.resolve(Response(requestOptions: options, statusCode: 200));
        },
      ));

      await client.get<dynamic>('/api/v1/customer/profile');

      expect(interceptedOptions, isNotNull);
      expect(interceptedOptions!.headers['Authorization'], equals('Bearer active_valid_token_xyz'));
      expect(interceptedOptions!.extra['requestToken'], equals('active_valid_token_xyz'));
      expect(interceptedOptions!.extra['requestSessionGeneration'], equals(5));
    });

    test('4. Bootstrap يسمح بـ /auth/me فقط: التوكن يُحقن لـ /auth/me', () async {
      final storage = StubTokenStorage(token: 'bootstrap_token_test');
      final dio = Dio();
      RequestOptions? interceptedOptions;

      final client = ApiClient(
        dio: dio,
        tokenStorage: storage,
        getSessionTokenContext: (options) {
          final isMe = ApiClient.isMeEndpoint(options.method, options.path);
          if (isMe) {
            return const SessionTokenContext(
              policy: TokenInjectionPolicy.allowed,
              currentSessionToken: 'bootstrap_token_test',
              sessionGeneration: 1,
              sessionStatus: AuthSessionStatus.authenticating,
            );
          }
          return const SessionTokenContext.denied(status: AuthSessionStatus.authenticating);
        },
      );

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          interceptedOptions = options;
          return handler.resolve(Response(requestOptions: options, statusCode: 200));
        },
      ));

      await client.get<dynamic>(AuthEndpoints.me);

      expect(interceptedOptions, isNotNull);
      expect(interceptedOptions!.headers['Authorization'], equals('Bearer bootstrap_token_test'));
      expect(interceptedOptions!.extra['requestToken'], equals('bootstrap_token_test'));
    });

    test('5. Switch Account مع تأخر clearToken: لا يرسل توكن الحساب القديم', () async {
      final storage = StubTokenStorage(token: 'old_account_token');
      final dio = Dio();
      RequestOptions? interceptedOptions;

      // حالة الذاكرة تحولت إلى unauthenticated قبل انتهاء حذف التخزين
      final client = ApiClient(
        dio: dio,
        tokenStorage: storage,
        getSessionTokenContext: (options) {
          return const SessionTokenContext.denied(
            status: AuthSessionStatus.unauthenticated,
            generation: 2,
          );
        },
      );

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          interceptedOptions = options;
          return handler.resolve(Response(requestOptions: options, statusCode: 200));
        },
      ));

      await client.get<dynamic>('/api/v1/customer/orders');

      expect(interceptedOptions, isNotNull);
      expect(interceptedOptions!.headers.containsKey('Authorization'), isFalse);
      expect(interceptedOptions!.extra['requestToken'], isNull);
    });

    test('6. Switch Account مع فشل clearToken: فشل التخزين لا يسرب التوكن', () async {
      final storage = StubTokenStorage(token: 'unwipable_token');
      storage.shouldThrowOnClear = true;
      final dio = Dio();
      RequestOptions? interceptedOptions;

      final client = ApiClient(
        dio: dio,
        tokenStorage: storage,
        getSessionTokenContext: (options) {
          return const SessionTokenContext.denied(
            status: AuthSessionStatus.unauthenticated,
            generation: 3,
          );
        },
      );

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          interceptedOptions = options;
          return handler.resolve(Response(requestOptions: options, statusCode: 200));
        },
      ));

      await client.get<dynamic>('/api/v1/customer/wishlist');

      expect(interceptedOptions, isNotNull);
      expect(interceptedOptions!.headers.containsKey('Authorization'), isFalse);
      expect(interceptedOptions!.extra['requestToken'], isNull);
    });

    test('7. ApiClient دون Callback: Fail-closed ولا يُحقن أي توكن', () async {
      final storage = StubTokenStorage(token: 'orphaned_token');
      final dio = Dio();
      RequestOptions? interceptedOptions;

      // getSessionTokenContext is null
      final client = ApiClient(
        dio: dio,
        tokenStorage: storage,
      );

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          interceptedOptions = options;
          return handler.resolve(Response(requestOptions: options, statusCode: 200));
        },
      ));

      await client.get<dynamic>('/api/v1/catalog/products');

      expect(interceptedOptions, isNotNull);
      expect(interceptedOptions!.headers.containsKey('Authorization'), isFalse);
      expect(interceptedOptions!.extra['requestToken'], isNull);
    });

    test('8. Callback يرمي Exception: Fail-closed ولا يُحقن أي توكن', () async {
      final storage = StubTokenStorage(token: 'token_on_crash');
      final dio = Dio();
      RequestOptions? interceptedOptions;

      final client = ApiClient(
        dio: dio,
        tokenStorage: storage,
        getSessionTokenContext: (options) {
          throw StateError('Simulated container disposed or session read crash');
        },
      );

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          interceptedOptions = options;
          return handler.resolve(Response(requestOptions: options, statusCode: 200));
        },
      ));

      await client.get<dynamic>('/api/v1/customer/settings');

      expect(interceptedOptions, isNotNull);
      expect(interceptedOptions!.headers.containsKey('Authorization'), isFalse);
      expect(interceptedOptions!.extra['requestToken'], isNull);
    });

    test('9. Login مع Authorization Header مسبق: يُجرّد الترويسة تماماً', () async {
      final dio = Dio();
      RequestOptions? interceptedOptions;

      final client = ApiClient(
        dio: dio,
        getSessionTokenContext: (options) => const SessionTokenContext.unknown(),
      );

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          interceptedOptions = options;
          return handler.resolve(Response(requestOptions: options, statusCode: 200));
        },
      ));

      // محاكاة إرسال ترويسة authorization يدوياً بحالة أحرف مختلفة
      await client.post<dynamic>(
        AuthEndpoints.login,
        data: {'email': 'test@test.com', 'password': '123'},
        options: Options(headers: {'authorization': 'Bearer rogue_pre_existing_token'}),
      );

      expect(interceptedOptions, isNotNull);
      expect(interceptedOptions!.headers.containsKey('authorization'), isFalse);
      expect(interceptedOptions!.headers.containsKey('Authorization'), isFalse);
      expect(interceptedOptions!.extra['requestToken'], isNull);
    });

    test('10. Login يعيد 401 دون استدعاء معالجات مسح الجلسة', () async {
      final dio = Dio();
      int unauthCallCount = 0;

      final client = ApiClient(
        dio: dio,
        onUnauthorized: () => unauthCallCount++,
        onUnauthorizedWithToken: (_) => unauthCallCount++,
        onUnauthorizedWithDetails: (token, gen) => unauthCallCount++,
      );

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.reject(DioException(
            requestOptions: options,
            response: Response(requestOptions: options, statusCode: 401, data: {'message': 'بيانات الدخول غير صحيحة'}),
          ));
        },
      ));

      try {
        await client.post<dynamic>(
          AuthEndpoints.login,
          data: {'login': 'user@rwnaqk.com', 'password': 'wrong_password'},
        );
        fail('Expected UnauthorizedException');
      } on UnauthorizedException catch (e) {
        expect(e.statusCode, equals(401));
      }

      // يجب ألا يُستدعى أي كولباك لمسح الجلسة على مسار تسجيل الدخول
      expect(unauthCallCount, equals(0));
    });

    test('11. إعادة استخدام RequestOptions مع requestToken قديم: يُطهّر التوكن المتبقي', () async {
      final dio = Dio();
      RequestOptions? interceptedOptions;

      final client = ApiClient(
        dio: dio,
        getSessionTokenContext: (options) => const SessionTokenContext.denied(banned: true),
      );

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          interceptedOptions = options;
          return handler.resolve(Response(requestOptions: options, statusCode: 200));
        },
      ));

      // تمرير options ملوثة بـ requestToken قديم
      final pollutedOptions = Options(extra: {'requestToken': 'polluted_stale_token'});
      await client.get<dynamic>('/api/v1/customer/orders', options: pollutedOptions);

      expect(interceptedOptions, isNotNull);
      expect(interceptedOptions!.extra['requestToken'], isNull);
      expect(interceptedOptions!.headers.containsKey('Authorization'), isFalse);
    });

    // -------------------------------------------------------------------------
    // المجموعة الثانية: اختبارات السباق والحدود الأمنية (12-24)
    // -------------------------------------------------------------------------

    test('12. Authenticated A إلى Authenticated B أثناء انتظار readToken: منع السباق', () async {
      final storage = StubTokenStorage(token: 'token_account_A');
      storage.readDelay = const Duration(milliseconds: 30);
      final dio = Dio();
      RequestOptions? interceptedOptions;

      int currentGen = 1;
      String? currentTok;

      final client = ApiClient(
        dio: dio,
        tokenStorage: storage,
        getSessionTokenContext: (options) {
          return SessionTokenContext(
            policy: TokenInjectionPolicy.allowed,
            currentSessionToken: currentTok,
            sessionGeneration: currentGen,
            sessionStatus: AuthSessionStatus.authenticated,
          );
        },
      );

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          interceptedOptions = options;
          return handler.resolve(Response(requestOptions: options, statusCode: 200));
        },
      ));

      // أثناء انتظار قراءة التوكن، تبدل الحساب فورياً إلى B وتغير الجيل
      final requestFuture = client.get<dynamic>('/api/v1/customer/profile');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      currentGen = 2;
      currentTok = 'token_account_B';
      storage.token = 'token_account_B';

      await requestFuture;

      // الفحص البعدي رصد تغير الجيل ومنع حقن توكن A
      expect(interceptedOptions, isNotNull);
      expect(interceptedOptions!.headers.containsKey('Authorization'), isFalse);
    });

    test('13. Bootstrap مع طلب آخر متزامن: يُحجب التوكن عن الطلب الآخر', () async {
      final storage = StubTokenStorage(token: 'bootstrap_session_token');
      final dio = Dio();
      RequestOptions? interceptedOptions;

      final client = ApiClient(
        dio: dio,
        tokenStorage: storage,
        getSessionTokenContext: (options) {
          final isMe = ApiClient.isMeEndpoint(options.method, options.path);
          if (isMe) {
            return const SessionTokenContext(
              policy: TokenInjectionPolicy.allowed,
              currentSessionToken: 'bootstrap_session_token',
              sessionStatus: AuthSessionStatus.authenticating,
            );
          }
          // أي طلب آخر غير auth/me أثناء الـ bootstrapping يكون denied
          return const SessionTokenContext.denied(status: AuthSessionStatus.authenticating);
        },
      );

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          interceptedOptions = options;
          return handler.resolve(Response(requestOptions: options, statusCode: 200));
        },
      ));

      await client.get<dynamic>('/api/v1/customer/cart');

      expect(interceptedOptions, isNotNull);
      expect(interceptedOptions!.headers.containsKey('Authorization'), isFalse);
      expect(interceptedOptions!.extra['requestToken'], isNull);
    });

    test('14. /auth/me failure during bootstrap: الجلسة تعود لـ unauthenticated', () async {
      final storage = StubTokenStorage(token: 'invalid_bootstrap_token');
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          authTokenStorageProvider.overrideWithValue(storage),
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      // محاكاة فشل /auth/me بـ 401
      final notifier = container.read(authSessionProvider.notifier);
      await notifier.bootstrapSession(initialToken: 'invalid_bootstrap_token');

      final finalState = container.read(authSessionProvider);
      expect(finalState.isBootstrapping, isFalse);
      // الجلسة لم تُعتمد وتم إنهاؤها بأمان
      expect(finalState.isAuthenticated, isFalse);
    });

    test('15. Authorization يحتوي توكن حساب مختلف: يُستبدل بتوكن الجلسة المعتمد', () async {
      final storage = StubTokenStorage(token: 'active_session_token');
      final dio = Dio();
      RequestOptions? interceptedOptions;

      final client = ApiClient(
        dio: dio,
        tokenStorage: storage,
        getSessionTokenContext: (options) {
          return const SessionTokenContext(
            policy: TokenInjectionPolicy.allowed,
            currentSessionToken: 'active_session_token',
            sessionGeneration: 1,
            sessionStatus: AuthSessionStatus.authenticated,
          );
        },
      );

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          interceptedOptions = options;
          return handler.resolve(Response(requestOptions: options, statusCode: 200));
        },
      ));

      // تمرير ترويسة خارجية تحمل توكناً مختلفاً
      await client.get<dynamic>(
        '/api/v1/customer/orders',
        options: Options(headers: {'Authorization': 'Bearer rogue_different_token'}),
      );

      expect(interceptedOptions, isNotNull);
      // تم استبدال الترويسة بتوكن الجلسة المعتمد
      expect(interceptedOptions!.headers['Authorization'], equals('Bearer active_session_token'));
      expect(interceptedOptions!.extra['requestToken'], equals('active_session_token'));
    });

    test('16. Authorization غير Bearer: يُستبدل بترويسة Bearer المعتمدة أو يُجرّد', () async {
      final storage = StubTokenStorage(token: 'active_session_token');
      final dio = Dio();
      RequestOptions? interceptedOptions;

      final client = ApiClient(
        dio: dio,
        tokenStorage: storage,
        getSessionTokenContext: (options) {
          return const SessionTokenContext(
            policy: TokenInjectionPolicy.allowed,
            currentSessionToken: 'active_session_token',
            sessionGeneration: 1,
            sessionStatus: AuthSessionStatus.authenticated,
          );
        },
      );

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          interceptedOptions = options;
          return handler.resolve(Response(requestOptions: options, statusCode: 200));
        },
      ));

      // تمرير ترويسة Basic غير معروفة
      await client.get<dynamic>(
        '/api/v1/customer/orders',
        options: Options(headers: {'Authorization': 'Basic dXNlcjpwYXNz'}),
      );

      expect(interceptedOptions, isNotNull);
      expect(interceptedOptions!.headers['Authorization'], equals('Bearer active_session_token'));
    });

    test('17. getSessionGeneration / context callback throws: Fail-closed دون انهيار', () async {
      final storage = StubTokenStorage(token: 'token_safe');
      final dio = Dio();
      RequestOptions? interceptedOptions;

      final client = ApiClient(
        dio: dio,
        tokenStorage: storage,
        getSessionGeneration: () => throw Exception('Session generation evaluation crashed'),
        getSessionTokenContext: (_) => throw Exception('Session context evaluation crashed'),
      );

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          interceptedOptions = options;
          return handler.resolve(Response(requestOptions: options, statusCode: 200));
        },
      ));

      await client.get<dynamic>('/api/v1/customer/profile');

      expect(interceptedOptions, isNotNull);
      expect(interceptedOptions!.headers.containsKey('Authorization'), isFalse);
    });

    test('18. إعادة استخدام RequestOptions مع requestSessionGeneration قديم: يُعاد تعيينه', () async {
      final storage = StubTokenStorage(token: 'valid_token');
      final dio = Dio();
      RequestOptions? interceptedOptions;

      final client = ApiClient(
        dio: dio,
        tokenStorage: storage,
        getSessionTokenContext: (options) {
          return const SessionTokenContext(
            policy: TokenInjectionPolicy.allowed,
            currentSessionToken: 'valid_token',
            sessionGeneration: 10,
            sessionStatus: AuthSessionStatus.authenticated,
          );
        },
      );

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          interceptedOptions = options;
          return handler.resolve(Response(requestOptions: options, statusCode: 200));
        },
      ));

      final dirtyOptions = Options(extra: {'requestSessionGeneration': 1});
      await client.get<dynamic>('/api/v1/customer/profile', options: dirtyOptions);

      expect(interceptedOptions, isNotNull);
      expect(interceptedOptions!.extra['requestSessionGeneration'], equals(10));
    });

    test('19. طلب خاص يعيد 401 دون أن يحمل توكناً: لا يستدعي معالجات مسح الجلسة', () async {
      final dio = Dio();
      int unauthWithTokenCalls = 0;
      int unauthWithDetailsCalls = 0;

      final client = ApiClient(
        dio: dio,
        onUnauthorizedWithToken: (_) => unauthWithTokenCalls++,
        onUnauthorizedWithDetails: (token, gen) => unauthWithDetailsCalls++,
      );

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.reject(DioException(
            requestOptions: options,
            response: Response(requestOptions: options, statusCode: 401, data: {'message': 'Unauthenticated'}),
          ));
        },
      ));

      try {
        await client.get<dynamic>('/api/v1/customer/private-orders');
      } catch (_) {}

      // لم يحمل الطلب توكناً، فلا يجوز استدعاء ردود النداء التي تمسح جلسة المستخدم
      expect(unauthWithTokenCalls, equals(0));
      expect(unauthWithDetailsCalls, equals(0));
    });

    test('20. 401 متأخرة من A بعد بدء B: يتم تجاهلها ولا تمسح جلسة B', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = StubTokenStorage(token: 'token_B');

      final container = ProviderContainer(
        overrides: [
          authTokenStorageProvider.overrideWithValue(storage),
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authSessionProvider.notifier);

      // جلسة الحساب B في الجيل 2
      await notifier.startSession(
        accessToken: 'token_B',
        customerPayload: const CustomerModel(id: 20, firstName: 'User', lastName: 'B', email: 'b@b.com'),
      );
      expect(container.read(authSessionProvider).sessionGeneration, equals(1));

      // وصول استجابة 401 قديمة من الحساب A بجيل أقدم وتوكن قديم
      await notifier.handleUnauthorized(
        failedToken: 'token_A',
        staleGeneration: 0,
      );

      // جلسة B تظل قائمة ونشطة دون تأثر
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);
      expect(container.read(authSessionProvider).token, equals('token_B'));
    });

    test('21. customer.isBanned=true مع حالة جلسة غير محظورة: السياسة تكون denied فوراً', () async {
      final storage = StubTokenStorage(token: 'token_conflict');
      final dio = Dio();
      RequestOptions? interceptedOptions;

      final client = ApiClient(
        dio: dio,
        tokenStorage: storage,
        getSessionTokenContext: (options) {
          // وجود تعارض: الحالة authenticated لكن العميل محظور
          const customer = CustomerModel(id: 5, isBanned: true);
          const session = AuthSessionState(
            status: AuthSessionStatus.authenticated,
            customer: customer,
          );
          if (session.isBanned) {
            return const SessionTokenContext.denied(banned: true);
          }
          return const SessionTokenContext(policy: TokenInjectionPolicy.allowed);
        },
      );

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          interceptedOptions = options;
          return handler.resolve(Response(requestOptions: options, statusCode: 200));
        },
      ));

      await client.get<dynamic>('/api/v1/customer/profile');

      expect(interceptedOptions, isNotNull);
      expect(interceptedOptions!.headers.containsKey('Authorization'), isFalse);
    });

    test('22. Public Auth path مع HTTP method غير صحيح: لا يُعامل كمسار مصادقة عام', () {
      // GET على مسار تسجيل الدخول ليس طلباً مصرحاً كـ public auth
      expect(ApiClient.isPublicAuthEndpoint('GET', AuthEndpoints.login), isFalse);
      expect(ApiClient.isPublicAuthEndpoint('PUT', AuthEndpoints.register), isFalse);
      expect(ApiClient.isPublicAuthEndpoint('DELETE', AuthEndpoints.forgotPassword), isFalse);
      // POST فقط هي المطابقة الصحيحة
      expect(ApiClient.isPublicAuthEndpoint('POST', AuthEndpoints.login), isTrue);
    });

    test('23. مسار مشابه لمسار Login لكنه ليس Endpoint معتمداً: لا يطابق المسارات العامة', () {
      expect(ApiClient.isPublicAuthEndpoint('POST', '/api/v1/customer/auth/login-fast'), isFalse);
      expect(ApiClient.isPublicAuthEndpoint('POST', '/api/v1/customer/auth/login/verify'), isFalse);
      expect(ApiClient.isPublicAuthEndpoint('POST', '/api/v1/admin/auth/login'), isFalse);
      expect(ApiClient.isPublicAuthEndpoint('POST', AuthEndpoints.login), isTrue);
    });

    test('24. عدة استجابات 401 متزامنة: معالجة آمنة دون سباق أو انهيار', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = StubTokenStorage(token: 'token_to_expire');

      final container = ProviderContainer(
        overrides: [
          authTokenStorageProvider.overrideWithValue(storage),
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authSessionProvider.notifier);
      await notifier.startSession(
        accessToken: 'token_to_expire',
        customerPayload: const CustomerModel(id: 1, firstName: 'A', lastName: 'B', email: 'a@b.com'),
      );

      final currentGen = container.read(authSessionProvider).sessionGeneration;

      // إطلاق عدة استدعاءات متزامنة لـ handleUnauthorized
      await Future.wait([
        notifier.handleUnauthorized(failedToken: 'token_to_expire', staleGeneration: currentGen),
        notifier.handleUnauthorized(failedToken: 'token_to_expire', staleGeneration: currentGen),
        notifier.handleUnauthorized(failedToken: 'token_to_expire', staleGeneration: currentGen),
      ]);

      expect(container.read(authSessionProvider).isAuthenticated, isFalse);
      expect(container.read(authSessionProvider).token, isNull);
    });
  });
}
