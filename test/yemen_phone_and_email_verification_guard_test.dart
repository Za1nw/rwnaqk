import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/utils/app_validators.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/routes/app_router.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Yemen Phone Number Validation Tests', () {
    test('Accepts valid Yemeni phone numbers across all mobile operators', () {
      // 77 (Yemen Mobile)
      expect(AppValidators.phone('771234567'), isNull);
      expect(AppValidators.phone('+967771234567'), isNull);
      expect(AppValidators.phone('00967771234567'), isNull);
      expect(AppValidators.phone('0771234567'), isNull);

      // 78 (Yemen Mobile)
      expect(AppValidators.phone('781234567'), isNull);
      expect(AppValidators.phone('+967781234567'), isNull);

      // 73 (You / MTN)
      expect(AppValidators.phone('731234567'), isNull);
      expect(AppValidators.phone('+967731234567'), isNull);

      // 71 (Sabafon)
      expect(AppValidators.phone('711234567'), isNull);
      expect(AppValidators.phone('+967711234567'), isNull);

      // 70 (Y Telecom)
      expect(AppValidators.phone('701234567'), isNull);
      expect(AppValidators.phone('+967701234567'), isNull);
    });

    test('Rejects non-Yemeni phone numbers and invalid lengths', () {
      // Saudi Arabia format (05xxxxxxxx)
      expect(AppValidators.phone('0512345678'), isNotNull);

      // US format
      expect(AppValidators.phone('+14155552671'), isNotNull);

      // Egyptian format
      expect(AppValidators.phone('01012345678'), isNotNull);

      // Random numbers or short digits
      expect(AppValidators.phone('1234567'), isNotNull);
      expect(AppValidators.phone('7712345'), isNotNull);
      expect(AppValidators.phone(''), isNotNull);
      expect(AppValidators.phone(null), isNotNull);
    });
  });

  group('Route Guards Mandatory Email Verification Tests', () {
    test('Unverified customer is strictly locked to AppRoutes.emailVerify', () {
      // Set session state to emailVerificationRequired
      final container = globalProviderContainer;
      container.read(authSessionProvider.notifier).startSession(
            accessToken: 'sample-test-token',
            emailVerificationRequired: true,
          );

      expect(container.read(authSessionProvider).requiresEmailVerification, isTrue);

      // Attempting to visit any storefront route redirects to AppRoutes.emailVerify
      final mainRoute = AppRouter.onGenerateRoute(const RouteSettings(name: AppRoutes.main));
      expect(mainRoute?.settings.name, AppRoutes.emailVerify);

      final cartRoute = AppRouter.onGenerateRoute(const RouteSettings(name: AppRoutes.cart));
      expect(cartRoute?.settings.name, AppRoutes.emailVerify);

      final homeRoute = AppRouter.onGenerateRoute(const RouteSettings(name: AppRoutes.home));
      expect(homeRoute?.settings.name, AppRoutes.emailVerify);

      // Attempting to visit register also redirects to emailVerify
      final regRoute = AppRouter.onGenerateRoute(const RouteSettings(name: AppRoutes.register));
      expect(regRoute?.settings.name, AppRoutes.emailVerify);

      // EmailVerify route is allowed without redirection
      final verifyRoute = AppRouter.onGenerateRoute(const RouteSettings(name: AppRoutes.emailVerify));
      expect(verifyRoute?.settings.name, AppRoutes.emailVerify);

      // Login route is allowed so user can switch account if desired
      final loginRoute = AppRouter.onGenerateRoute(const RouteSettings(name: AppRoutes.login));
      expect(loginRoute?.settings.name, AppRoutes.login);
    });
  });
}
