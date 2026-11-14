import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/modules/auth/providers/auth_flow_providers.dart';
import 'package:rwnaqk_frontend/modules/auth/views/two_factor_challenge_view.dart';
import 'package:rwnaqk_frontend/routes/app_route_args.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    dotenv.loadFromString(
      envString:
          'APP_ENV=development\nENABLE_MOCK_DATA=true\nAPI_BASE_URL=https://staging.rawnaqk.test/api/v1',
    );
  });

  Widget buildTestableScreen({
    required ProviderContainer container,
    String email = 'm77683586@gmail.com',
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            settings: RouteSettings(
              name: '/two-factor-challenge',
              arguments: <String, dynamic>{
                AppRouteArgs.loginEmail: email,
                AppRouteArgs.loginPassword: 'secretPassword123',
                AppRouteArgs.target: email,
              },
            ),
            builder: (_) => const TwoFactorChallengeScreen(),
          );
        },
      ),
    );
  }

  group('TwoFactorChallengeScreen UI/UX Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('Renders hero icon, title, email capsule, and 6 split OTP pods',
        (tester) async {
      await tester.pumpWidget(buildTestableScreen(container: container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Verify Hero Icon
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);

      // Verify Title & Subtitle for Authenticator Code
      expect(find.text('رمز المصادقة'), findsOneWidget);
      expect(
        find.text('أدخل رمز تطبيق المصادقة لهذا الحساب'),
        findsOneWidget,
      );

      // Verify Email Capsule
      expect(find.text('m77683586@gmail.com'), findsOneWidget);
      expect(find.byIcon(Icons.alternate_email_rounded), findsOneWidget);

      // Verify 6 OTP boxes
      expect(find.byType(TextField), findsNWidgets(6));

      // Verify Continue Button and Switch Button
      expect(find.text('متابعة'), findsOneWidget);
      expect(
        find.text('سجّل الدخول باستخدام رمز الاسترداد'),
        findsOneWidget,
      );
      expect(find.text('إلغاء'), findsOneWidget);
    });

    testWidgets('Toggling mode switches between OTP pods and Recovery Code input',
        (tester) async {
      await tester.pumpWidget(buildTestableScreen(container: container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Tap Switch to Recovery Code
      final switchBtn = find.text('سجّل الدخول باستخدام رمز الاسترداد');
      expect(switchBtn, findsOneWidget);
      await tester.tap(switchBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Now in Recovery Code Mode
      expect(find.text('رمز الاسترداد'), findsOneWidget);
      expect(
        find.text('يرجى إدخال أحد رموز الاسترداد للمتابعة.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.vpn_key_outlined), findsAtLeastNWidgets(1));
      expect(find.text('أدخل رمز الاسترداد'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Verify switch back button is available
      expect(
        find.text('سجّل الدخول باستخدام رمز المصادقة'),
        findsOneWidget,
      );

      // Switch back to Authenticator code
      await tester.tap(find.text('سجّل الدخول باستخدام رمز المصادقة'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Back to OTP mode
      expect(find.text('رمز المصادقة'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(6));
    });

    testWidgets('Typing 6 digits in OTP pods updates the provider code',
        (tester) async {
      await tester.pumpWidget(buildTestableScreen(container: container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(6));

      // Enter digits
      for (int i = 0; i < 6; i++) {
        await tester.enterText(textFields.at(i), '${i + 1}');
        await tester.pump();
      }

      final state = container.read(twoFactorChallengeFlowProvider);
      expect(state.code, '123456');
      expect(state.canSubmit, isTrue);
    });

    testWidgets('Error state triggers red border and error message',
        (tester) async {
      await tester.pumpWidget(buildTestableScreen(container: container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Trigger error in state
      container.read(twoFactorChallengeFlowProvider.notifier).state =
          container.read(twoFactorChallengeFlowProvider).copyWith(
                hasError: true,
                errorTicks: 1,
              );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify error alert row appears
      expect(
        find.text('رمز المصادقة غير صحيح، أدخل الرمز الحالي بالتطبيق'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.error_outline_rounded), findsAtLeastNWidgets(1));

      // Typing any new digit clears the error
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, '9');
      await tester.pump();

      final state = container.read(twoFactorChallengeFlowProvider);
      expect(state.hasError, isFalse);
    });
  });
}
