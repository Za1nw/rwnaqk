import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/core/services/auth/models/auth_session_state.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:rwnaqk_frontend/routes/app_router.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StubTokenStorage implements IAuthTokenStorage {
  String? token;
  int clearCallCount = 0;
  bool shouldThrowOnClear = false;

  @override
  Future<void> clearToken() async {
    clearCallCount++;
    if (shouldThrowOnClear) {
      throw const FormatException('Simulated Keystore deletion failure on clearToken');
    }
    token = null;
  }

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> writeToken(String newToken) async => token = newToken;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Package C: SEC-05 Route Guards Fail-Safe Tests', () {
    test('Unauthenticated user attempting to access auth-only routes is redirected to login', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = StubTokenStorage();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          authTokenStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);
      globalProviderContainer = container;

      // Ensure session is unauthenticated
      expect(container.read(authSessionProvider).isAuthenticated, isFalse);

      // Auth-only routes must redirect to login
      expect(AppRouter.checkRouteGuards(AppRoutes.profile), equals(AppRoutes.login));
      expect(AppRouter.checkRouteGuards(AppRoutes.orders), equals(AppRoutes.login));
      expect(AppRouter.checkRouteGuards(AppRoutes.addresses), equals(AppRoutes.login));
      expect(AppRouter.checkRouteGuards(AppRoutes.cart), equals(AppRoutes.login));

      // Guest routes must allow entry (null redirect)
      expect(AppRouter.checkRouteGuards(AppRoutes.login), isNull);
      expect(AppRouter.checkRouteGuards(AppRoutes.register), isNull);
      expect(AppRouter.checkRouteGuards(AppRoutes.onboarding), isNull);
    });

    test('Fail-Safe: When container read throws, auth-only routes fail-closed to login', () {
      // Intentionally dispose or disrupt globalProviderContainer to simulate fatal exception
      final container = ProviderContainer();
      container.dispose();
      globalProviderContainer = container;

      // CRITICAL SEC-05 TEST:
      // Even if session reading crashes, protected routes must NEVER allow entry!
      expect(AppRouter.checkRouteGuards(AppRoutes.profile), equals(AppRoutes.login));
      expect(AppRouter.checkRouteGuards(AppRoutes.orders), equals(AppRoutes.login));
      expect(AppRouter.checkRouteGuards(AppRoutes.payment), equals(AppRoutes.login));

      // Public / guest routes allow entry rather than crashing the router
      expect(AppRouter.checkRouteGuards(AppRoutes.login), isNull);
      expect(AppRouter.checkRouteGuards(AppRoutes.onboarding), isNull);
    });

    test('Banned user is strictly locked out of all routes and redirected to AppRoutes.banned', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = StubTokenStorage();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          authTokenStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);
      globalProviderContainer = container;

      final sessionNotifier = container.read(authSessionProvider.notifier);
      sessionNotifier.markAsBanned(reason: 'مخالفة الشروط');

      expect(container.read(authSessionProvider).isBanned, isTrue);

      // Any navigation attempt must redirect to banned screen
      expect(AppRouter.checkRouteGuards(AppRoutes.home), equals(AppRoutes.banned));
      expect(AppRouter.checkRouteGuards(AppRoutes.profile), equals(AppRoutes.banned));
      expect(AppRouter.checkRouteGuards(AppRoutes.cart), equals(AppRoutes.banned));
      expect(AppRouter.checkRouteGuards(AppRoutes.login), equals(AppRoutes.banned));

      // Accessing banned screen itself is permitted
      expect(AppRouter.checkRouteGuards(AppRoutes.banned), isNull);
    });
  });

  group('Package C: SEC-06 ApiClient Callbacks & Safe Handlers Tests', () {
    test('onUnauthorizedWithDetails clears token and sets session unauthenticated without throwing', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = StubTokenStorage()..token = 'active_expired_token';

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          authTokenStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      final sessionNotifier = container.read(authSessionProvider.notifier);
      await sessionNotifier.startSession(
        accessToken: 'active_expired_token',
        customerPayload: const CustomerModel(id: 42, fullName: 'مستخدم نشط'),
      );

      expect(container.read(authSessionProvider).isAuthenticated, isTrue);

      final apiClient = container.read(apiClientProvider);

      // Trigger 401 callback with matching token and valid generation
      final currentGen = container.read(authSessionProvider).sessionGeneration;
      apiClient.onUnauthorizedWithDetails?.call('active_expired_token', currentGen);

      // Allow async cleanup
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = container.read(authSessionProvider);
      expect(state.status, equals(AuthSessionStatus.unauthenticated));
      expect(state.token, isNull);
      expect(state.customer, isNull);
      expect(storage.token, isNull);
      expect(storage.clearCallCount, greaterThanOrEqualTo(1));
    });

    test('onAccountBanned safely handles valid and invalid customer payload without crashing', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = StubTokenStorage();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          authTokenStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      final apiClient = container.read(apiClientProvider);

      // 1. Valid customer data in 403 response
      apiClient.onAccountBanned?.call({
        'id': 99,
        'full_name': 'عميل محظور',
        'email': 'banned@test.com',
      }, 'تم إيقاف حسابك بسبب نشاط مشبوه');

      await Future<void>.delayed(Duration.zero);
      var state = container.read(authSessionProvider);
      expect(state.isBanned, isTrue);
      expect(state.customer?.id, equals(99));
      expect(state.errorMessage, contains('نشاط مشبوه'));

      // 2. Corrupt / invalid customer data in 403 response does not crash
      expect(
        () => apiClient.onAccountBanned?.call(
          {'id': 'not_an_int_invalid'},
          'حظر جديد',
        ),
        returnsNormally,
      );
    });

    test('T01: Late 401 arriving after banned state does NOT reset banned status or unauthenticated', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = StubTokenStorage()..token = 'banned_user_token';

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          authTokenStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);
      globalProviderContainer = container;

      final sessionNotifier = container.read(authSessionProvider.notifier);
      await sessionNotifier.startSession(
        accessToken: 'banned_user_token',
        customerPayload: const CustomerModel(id: 777, fullName: 'عميل تم حظره'),
      );
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);

      // 1. Account is marked as banned (e.g. 403 arrived)
      sessionNotifier.markAsBanned(reason: 'مخالفة الشروط والأحكام');
      var state = container.read(authSessionProvider);
      expect(state.isBanned, isTrue);
      expect(state.status, equals(AuthSessionStatus.banned));

      // 2. Late 401 arrives from a previous in-flight request
      final apiClient = container.read(apiClientProvider);
      apiClient.onUnauthorizedWithDetails?.call('banned_user_token', 1);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      // 3. VERIFICATION (FIX-01):
      // Late 401 MUST be completely rejected and state must remain BANNED
      state = container.read(authSessionProvider);
      expect(state.isBanned, isTrue);
      expect(state.status, equals(AuthSessionStatus.banned));
      expect(state.errorMessage, contains('مخالفة الشروط والأحكام'));

      // Route guards must still strictly lock user to banned screen
      expect(AppRouter.checkRouteGuards(AppRoutes.main), equals(AppRoutes.banned));
      expect(AppRouter.checkRouteGuards(AppRoutes.profile), equals(AppRoutes.banned));
    });

    test('T02: Multiple concurrent 401 responses after banned state are all safely rejected', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = StubTokenStorage()..token = 'banned_token_abc';

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          authTokenStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);
      globalProviderContainer = container;

      final sessionNotifier = container.read(authSessionProvider.notifier);
      await sessionNotifier.startSession(
        accessToken: 'banned_token_abc',
        customerPayload: const CustomerModel(id: 888, fullName: 'مستخدم محظور متعدد الطلبات'),
      );

      // Mark as banned
      sessionNotifier.markAsBanned(reason: 'نشاط احتيالي');
      expect(container.read(authSessionProvider).isBanned, isTrue);

      // Fire 5 concurrent 401 callbacks
      await Future.wait([
        sessionNotifier.handleUnauthorized(failedToken: 'banned_token_abc'),
        sessionNotifier.handleUnauthorized(failedToken: 'banned_token_abc'),
        sessionNotifier.handleUnauthorized(failedToken: 'banned_token_abc'),
        sessionNotifier.handleUnauthorized(failedToken: 'banned_token_abc'),
        sessionNotifier.handleUnauthorized(failedToken: 'banned_token_abc'),
      ]);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = container.read(authSessionProvider);
      expect(state.isBanned, isTrue);
      expect(state.status, equals(AuthSessionStatus.banned));
    });

    test('T01_SwitchAccount: User can still switch account from banned state via clearSession', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = StubTokenStorage();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          authTokenStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);
      globalProviderContainer = container;

      final sessionNotifier = container.read(authSessionProvider.notifier);
      sessionNotifier.markAsBanned(reason: 'حظر مؤقت');
      expect(container.read(authSessionProvider).isBanned, isTrue);

      // User taps "تسجيل الدخول بحساب آخر" (Simulates BannedScreen._switchAccount)
      await sessionNotifier.clearSession();

      final state = container.read(authSessionProvider);
      expect(state.isBanned, isFalse);
      expect(state.status, equals(AuthSessionStatus.unauthenticated));
      expect(AppRouter.checkRouteGuards(AppRoutes.login), isNull);
    });

    test('T01_BannedWithFailingClearToken: clearToken failure does not crash or break banned state', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = StubTokenStorage()
        ..token = 'active_token'
        ..shouldThrowOnClear = true;

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          authTokenStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);
      globalProviderContainer = container;

      final sessionNotifier = container.read(authSessionProvider.notifier);

      // 1. Mark as banned while clearToken is guaranteed to throw
      sessionNotifier.markAsBanned(reason: 'حظر تجريبي مع تعطل الحذف');

      // Allow microtasks to complete the clearToken Future rejection
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // 2. Status must remain banned despite clearToken failure
      final state = container.read(authSessionProvider);
      expect(state.isBanned, isTrue);
      expect(state.status, equals(AuthSessionStatus.banned));
      expect(state.errorMessage, contains('حظر تجريبي مع تعطل الحذف'));
      expect(storage.clearCallCount, equals(1));

      // 3. User can still switch account manually
      storage.shouldThrowOnClear = false;
      await sessionNotifier.clearSession();
      final stateAfterSwitch = container.read(authSessionProvider);
      expect(stateAfterSwitch.isBanned, isFalse);
      expect(stateAfterSwitch.status, equals(AuthSessionStatus.unauthenticated));
    });
  });
}
