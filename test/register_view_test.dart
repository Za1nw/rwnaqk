import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/modules/auth/providers/auth_flow_providers.dart';
import 'package:rwnaqk_frontend/modules/auth/views/register_view.dart';
import 'package:rwnaqk_frontend/modules/auth/widgets/auth_form_page_layout.dart';

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
        home: RegisterScreen(),
      ),
    );
  }

  group('RegisterScreen UI/UX Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets(
        'Renders boutique hero icon, modular pod headers, re-ordered inputs, and terms agreement without old badge',
        (tester) async {
      await tester.pumpWidget(buildTestableScreen(container: container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // 1. Verify "عضوية جديدة في رونقك" is removed
      expect(find.text('عضوية جديدة في رَوْنَقُك'), findsNothing);
      expect(find.text('عضوية جديدة في رونقك'), findsNothing);

      // 2. Verify Modern Boutique Icon
      expect(find.byIcon(Icons.person_add_alt_1_rounded), findsWidgets);

      // 3. Verify Modular Pod Headers
      expect(find.text('البيانات الشخصية والاتصال'), findsOneWidget);
      expect(find.text('الأمان وكلمة المرور'), findsOneWidget);

      // 4. Verify Form Fields (6 TextFormField fields: First, Last, Email, Phone, Pass, Confirm)
      expect(find.byType(TextFormField), findsNWidgets(6));

      // 5. Verify Terms Agreement & Page Layout
      expect(find.byType(AuthFormPageLayout), findsOneWidget);
      expect(find.text('تصفح المتجر كزائر'), findsOneWidget);
    });

    testWidgets(
        'Typing password dynamically displays strength meter and match indicator',
        (tester) async {
      await tester.pumpWidget(buildTestableScreen(container: container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      final textFields = find.byType(TextFormField);

      // Index 4 is Password field, Index 5 is Confirm Password field
      await tester.enterText(textFields.at(4), 'SecretP@ss123');
      await tester.pump(const Duration(milliseconds: 100));

      // Strength meter should appear
      expect(find.text('قوة كلمة المرور'), findsOneWidget);
      expect(find.text('كلمة مرور قوية وممتازة'), findsOneWidget);

      // Enter matching confirm password
      await tester.enterText(textFields.at(5), 'SecretP@ss123');
      await tester.pump(const Duration(milliseconds: 100));

      // Matching checkmark is visible
      expect(find.text('كلمتا المرور متطابقتان تماماً'), findsOneWidget);
    });

    testWidgets(
        'Renders gender selector with male and female options, and updates state on tap',
        (tester) async {
      await tester.pumpWidget(buildTestableScreen(container: container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // 1. Verify Gender header & options exist
      expect(find.text('الجنس'), findsOneWidget);
      expect(find.text('ذكر'), findsOneWidget);
      expect(find.text('أنثى'), findsOneWidget);
      expect(find.byIcon(Icons.male_rounded), findsOneWidget);
      expect(find.byIcon(Icons.female_rounded), findsOneWidget);

      // Initially no gender selected
      expect(container.read(registerFormProvider).selectedGender, isNull);

      // 2. Tap Male option
      await tester.tap(find.text('ذكر'));
      await tester.pump();
      expect(container.read(registerFormProvider).selectedGender, 'male');

      // 3. Tap Female option
      await tester.tap(find.text('أنثى'));
      await tester.pump();
      expect(container.read(registerFormProvider).selectedGender, 'female');
    });

    testWidgets(
        'Phone number validator rejects invalid non-Yemeni phone numbers',
        (tester) async {
      await tester.pumpWidget(buildTestableScreen(container: container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      final textFields = find.byType(TextFormField);
      // Index 3 is Phone field (0: First, 1: Last, 2: Email, 3: Phone)
      final phoneField = textFields.at(3);

      // Enter invalid non-Yemeni phone number (e.g. Saudi Arabia 0512345678)
      await tester.enterText(phoneField, '0512345678');
      await tester.pump();

      // Submit form or trigger validation
      final formState = tester.state<FormState>(find.byType(Form));
      final isValid = formState.validate();
      await tester.pump();

      expect(isValid, isFalse);
      expect(
        find.text('يرجى إدخال رقم هاتف يمني صالح (يبدأ بـ 77، 78، 73، 71، أو 70)'),
        findsOneWidget,
      );

      // Enter valid Yemeni phone number
      await tester.enterText(phoneField, '771234567');
      await tester.pump();
      formState.validate();
      await tester.pump();

      expect(
        find.text('يرجى إدخال رقم هاتف يمني صالح (يبدأ بـ 77، 78، 73، 71، أو 70)'),
        findsNothing,
      );
    });
  });
}
