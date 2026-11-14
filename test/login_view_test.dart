import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/modules/auth/views/login_view.dart';

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
        home: LoginScreen(),
      ),
    );
  }

  group('LoginScreen UI/UX Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets(
        'Renders boutique hero lock icon, security badge, pod header, input fields, and social buttons',
        (tester) async {
      await tester.pumpWidget(buildTestableScreen(container: container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Verify Hero Icon & Security Badge
      expect(find.byIcon(Icons.lock_open_rounded), findsOneWidget);
      expect(find.text('تسجيل الدخول الآمن'), findsOneWidget);

      // Verify Title & Subtitle
      expect(find.text('مرحبًا بعودتك'), findsOneWidget);
      expect(
        find.text('سجّل دخولك للمتابعة والوصول إلى حقيبتك ومفضلاتك'),
        findsOneWidget,
      );

      // Verify Form Pod Header
      expect(find.text('بيانات الحساب'), findsOneWidget);

      // Verify Email and Password Fields
      expect(find.byType(TextField), findsNWidgets(2));

      // Verify Forgot Password
      expect(find.text('نسيت كلمة المرور؟'), findsOneWidget);

      // Verify Primary Button and Biometric Login Button
      expect(find.text('تسجيل الدخول'), findsOneWidget);
      expect(
        find.byTooltip('الدخول ببصمة الإصبع أو رمز قفل الهاتف'),
        findsOneWidget,
      );

      // Verify Social Buttons (Only Google is retained; Apple & Facebook removed)
      expect(find.textContaining('Google'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
      expect(find.text('Facebook'), findsNothing);

      // Verify Guest Exploration Card
      expect(find.text('تصفح المتجر كزائر'), findsOneWidget);

      // Verify Create Account Footer
      expect(find.text('إنشاء حساب'), findsOneWidget);
    });
  });
}

