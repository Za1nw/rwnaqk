import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/services/auth/models/auth_session_state.dart';
import 'package:rwnaqk_frontend/modules/auth/views/banned_view.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:rwnaqk_frontend/routes/app_router.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Banned Customer Session & Guard Tests', () {
    test('AuthSessionState properly computes isBanned and denies isAuthenticated', () {
      // 1. Unauthenticated state
      const unauth = AuthSessionState();
      expect(unauth.isBanned, isFalse);
      expect(unauth.isAuthenticated, isFalse);

      // 2. Banned status
      const bannedSession = AuthSessionState(
        status: AuthSessionStatus.banned,
        errorMessage: 'حسابك محظور',
      );
      expect(bannedSession.isBanned, isTrue);
      expect(bannedSession.isAuthenticated, isFalse);

      // 3. Customer model with isBanned: true
      final bannedCustomer = CustomerModel(
        id: 42,
        fullName: 'أحمد المحظور',
        email: 'banned@rawnaqk.com',
        isBanned: true,
      );
      final sessionWithBannedCustomer = AuthSessionState(
        status: AuthSessionStatus.authenticated,
        customer: bannedCustomer,
      );
      expect(sessionWithBannedCustomer.isBanned, isTrue);
      expect(sessionWithBannedCustomer.isAuthenticated, isFalse);
    });

    test('Route Guards strictly lock banned customer to AppRoutes.banned', () {
      final container = globalProviderContainer;
      final notifier = container.read(authSessionProvider.notifier);

      final bannedCustomer = CustomerModel(
        id: 99,
        fullName: 'عميل محظور',
        email: 'banned-guard@rawnaqk.com',
        isBanned: true,
      );

      notifier.markAsBanned(
        customerPayload: bannedCustomer,
        reason: 'مخالفة سياسة الاستخدام',
      );

      final state = container.read(authSessionProvider);
      expect(state.isBanned, isTrue);
      expect(state.isAuthenticated, isFalse);

      // Any attempt to access storefront routes redirects to AppRoutes.banned
      final mainRoute = AppRouter.onGenerateRoute(const RouteSettings(name: AppRoutes.main));
      expect(mainRoute?.settings.name, AppRoutes.banned);

      final homeRoute = AppRouter.onGenerateRoute(const RouteSettings(name: AppRoutes.home));
      expect(homeRoute?.settings.name, AppRoutes.banned);

      final cartRoute = AppRouter.onGenerateRoute(const RouteSettings(name: AppRoutes.cart));
      expect(cartRoute?.settings.name, AppRoutes.banned);

      final profileRoute = AppRouter.onGenerateRoute(const RouteSettings(name: AppRoutes.profile));
      expect(profileRoute?.settings.name, AppRoutes.banned);

      final loginRoute = AppRouter.onGenerateRoute(const RouteSettings(name: AppRoutes.login));
      expect(loginRoute?.settings.name, AppRoutes.banned);

      final regRoute = AppRouter.onGenerateRoute(const RouteSettings(name: AppRoutes.register));
      expect(regRoute?.settings.name, AppRoutes.banned);

      // Visiting AppRoutes.banned is allowed directly without redirecting
      final bannedRoute = AppRouter.onGenerateRoute(const RouteSettings(name: AppRoutes.banned));
      expect(bannedRoute?.settings.name, AppRoutes.banned);
    });

    test('Clearing session frees the user from ban lockdown and allows login', () {
      final container = globalProviderContainer;
      final notifier = container.read(authSessionProvider.notifier);

      // Clear session (simulates user tapping "تسجيل الدخول بحساب آخر")
      notifier.clearSession();

      final state = container.read(authSessionProvider);
      expect(state.isBanned, isFalse);
      expect(state.status, AuthSessionStatus.unauthenticated);

      // When unbanned and unauthenticated, visiting /login is allowed
      final loginRoute = AppRouter.onGenerateRoute(const RouteSettings(name: AppRoutes.login));
      expect(loginRoute?.settings.name, AppRoutes.login);

      // When unbanned and unauthenticated, visiting /banned redirects to /login
      final bannedRoute = AppRouter.onGenerateRoute(const RouteSettings(name: AppRoutes.banned));
      expect(bannedRoute?.settings.name, AppRoutes.login);
    });

    testWidgets('BannedScreen renders hero badge, customer info, and switch account button', (tester) async {
      final bannedCustomer = CustomerModel(
        id: 123,
        fullName: 'محمد علي',
        email: 'mohammed@rawnaqk.com',
        isBanned: true,
      );

      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => _MockBannedSessionNotifier(bannedCustomer)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: BannedScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('الحساب محظور'), findsOneWidget);
      expect(find.text('محمد علي'), findsOneWidget);
      expect(find.text('mohammed@rawnaqk.com'), findsOneWidget);
      expect(find.text('محظور'), findsOneWidget);
      expect(find.text('تسجيل الدخول بحساب آخر'), findsOneWidget);
      expect(find.text('واتساب'), findsOneWidget);
      expect(find.text('البريد'), findsOneWidget);
    });
  });
}

class _MockBannedSessionNotifier extends AuthSessionNotifier {
  _MockBannedSessionNotifier(this._customer);
  final CustomerModel _customer;

  @override
  AuthSessionState build() {
    return AuthSessionState(
      status: AuthSessionStatus.banned,
      customer: _customer,
      errorMessage: 'تم إيقاف الحساب لمخالفة سياسة الاستخدام.',
    );
  }
}

