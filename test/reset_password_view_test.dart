import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/modules/auth/views/reset_password_view.dart';

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
        home: ResetPasswordScreen(),
      ),
    );
  }

  group('ResetPasswordScreen UI/UX Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets(
        'Renders hero key icon, password fields, security checklist, and save button',
        (tester) async {
      await tester.pumpWidget(buildTestableScreen(container: container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Verify Hero Key Icon
      expect(find.byIcon(Icons.key_rounded), findsOneWidget);

      // Verify Password text fields (2 password fields)
      expect(find.byType(TextFormField), findsNWidgets(2));

      // Verify Security checklist items
      expect(find.text('8 أحرف على الأقل'), findsOneWidget);
      expect(find.text('أرقام أو رموز خاصة'), findsOneWidget);
      expect(find.text('تطابق كلمتي المرور'), findsOneWidget);

      // Verify Buttons
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets(
        'Typing password dynamically updates strength meter and security checklist',
        (tester) async {
      await tester.pumpWidget(buildTestableScreen(container: container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      final textFields = find.byType(TextFormField);

      // Enter new password
      await tester.enterText(textFields.at(0), 'Secret123!');
      await tester.pump(const Duration(milliseconds: 100));

      // Strength meter appears
      expect(find.text('قوة كلمة المرور'), findsOneWidget);
      expect(find.text('كلمة مرور قوية وممتازة'), findsOneWidget);

      // Enter matching confirm password
      await tester.enterText(textFields.at(1), 'Secret123!');
      await tester.pump(const Duration(milliseconds: 100));

      // Matching checkmark is visible
      expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);
    });
  });
}

