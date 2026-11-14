import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/modules/auth/providers/auth_flow_providers.dart';
import 'package:rwnaqk_frontend/modules/auth/views/otp_verify_view.dart';

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
        home: OtpVerifyScreen(),
      ),
    );
  }

  group('OtpVerifyScreen Modern Split Input Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets(
        'Renders modern split OTP inputs, hero icon, and 6 input fields without bulky cards',
        (tester) async {
      await tester.pumpWidget(buildTestableScreen(container: container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Verify Hero Icon
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);

      // Verify OTP Box fields (6 boxes)
      expect(find.byType(TextField), findsNWidgets(6));

      // Verify resend countdown section
      expect(find.textContaining('إعادة الإرسال بعد'), findsOneWidget);

      // Verify cancel button
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets(
        'Typing digits automatically updates state and advances focus across split pods',
        (tester) async {
      await tester.pumpWidget(buildTestableScreen(container: container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      final textFields = find.byType(TextField);

      // Enter first digit into box 0
      await tester.enterText(textFields.at(0), '7');
      await tester.pump(const Duration(milliseconds: 50));
      expect(container.read(forgotPasswordFlowProvider).otp, '7');

      // Enter second digit into box 1
      await tester.enterText(textFields.at(1), '3');
      await tester.pump(const Duration(milliseconds: 50));
      expect(container.read(forgotPasswordFlowProvider).otp, '73');

      // Enter third digit into box 2
      await tester.enterText(textFields.at(2), '5');
      await tester.pump(const Duration(milliseconds: 50));
      expect(container.read(forgotPasswordFlowProvider).otp, '735');

      // Enter across the 3+3 split to box 3, 4, 5
      await tester.enterText(textFields.at(3), '9');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(textFields.at(4), '2');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(textFields.at(5), '1');
      await tester.pump(const Duration(milliseconds: 300));

      expect(container.read(forgotPasswordFlowProvider).otp, '735921');
    });
  });
}
