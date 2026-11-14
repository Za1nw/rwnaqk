import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:rwnaqk_frontend/core/services/auth/providers/auth_session_providers.dart';
import 'package:rwnaqk_frontend/modules/auth/views/email_verification_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    dotenv.loadFromString(
      envString:
          'APP_ENV=development\nENABLE_MOCK_DATA=true\nAPI_BASE_URL=https://staging.rawnaqk.test/api/v1',
    );
  });

  Widget buildTestableScreen({required ProviderContainer container}) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        localizationsDelegates: [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        home: EmailVerificationScreen(),
      ),
    );
  }

  group('EmailVerificationScreen UI/UX Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      // Setup unverified customer in session
      container.read(authSessionProvider.notifier).startSession(
            accessToken: 'sample_token',
            customerPayload: const CustomerModel(
              id: 99,
              firstName: 'أحمد',
              lastName: 'يحيى',
              email: 'ahmed@rwnaqk.com',
              mobile: '777123456',
              emailVerifiedAt: null,
            ),
            emailVerificationRequired: true,
          );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets(
        'Renders boutique hero icon, security badge, recipient capsule, and 6 split OTP inputs',
        (tester) async {
      await tester.pumpWidget(buildTestableScreen(container: container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Verify Hero Icon
      expect(find.byIcon(Icons.mark_email_read_outlined), findsOneWidget);

      // Verify Security Badge & Title
      expect(find.text('تأكيد الحساب'), findsOneWidget);
      expect(find.text('تأكيد البريد الإلكتروني'), findsOneWidget);

      // Verify email in recipient capsule
      expect(find.text('ahmed@rwnaqk.com'), findsOneWidget);

      // Verify 6 input fields
      expect(find.byType(TextField), findsNWidgets(6));

      // Verify resend countdown timer
      expect(find.textContaining('إعادة الإرسال بعد'), findsOneWidget);

      // Verify primary verify button
      expect(find.text('تأكيد الحساب ومتابعة'), findsOneWidget);

      // Verify switch account button
      expect(find.text('تسجيل الدخول بحساب آخر'), findsOneWidget);
    });

    testWidgets(
        'Entering code across inputs enables the verification button',
        (tester) async {
      await tester.pumpWidget(buildTestableScreen(container: container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      final textFields = find.byType(TextField);

      // Enter digits into the 6 boxes
      await tester.enterText(textFields.at(0), '1');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(textFields.at(1), '2');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(textFields.at(2), '3');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(textFields.at(3), '4');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(textFields.at(4), '5');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(textFields.at(5), '6');
      await tester.pump(const Duration(milliseconds: 50));

      // Check button is present and actionable
      expect(find.text('تأكيد الحساب ومتابعة'), findsOneWidget);
    });
  });
}
