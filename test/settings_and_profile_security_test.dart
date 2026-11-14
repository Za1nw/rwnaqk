import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:rwnaqk_frontend/modules/customer/views/edit_profile_view.dart';
import 'package:rwnaqk_frontend/modules/customer/views/profile_view.dart';
import 'package:rwnaqk_frontend/modules/customer/views/settings_view.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/settings/settings_user_header.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testCustomer = CustomerModel(
    id: 10,
    firstName: 'أحمد',
    lastName: 'يحيى',
    fullName: 'أحمد يحيى',
    email: 'ahmed@rawnaqk.com',
    mobile: '771508902',
    emailVerifiedAt: DateTime.now(),
  );

  group('Settings & Profile Screen Refactoring Tests', () {
    testWidgets('SettingsUserHeader displays name and phone without membership or discount ribbon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsUserHeader(
              name: testCustomer.displayName,
              phone: testCustomer.phone ?? '',
            ),
          ),
        ),
      );
      await tester.pump();

      // Verified user first name and phone (first name only, not full name)
      expect(find.text('أحمد'), findsOneWidget);
      expect(find.text('أحمد يحيى'), findsNothing);
      expect(find.text('771508902'), findsOneWidget);
      expect(find.text('موثق'), findsOneWidget);

      // Membership & perk ribbons MUST NOT be present
      expect(find.text('عضوية VIP الذهبية'), findsNothing);
      expect(find.text('ROYAL MEMBER'), findsNothing);
      expect(find.textContaining('توصيل مجاني لكافة طلباتك'), findsNothing);
    });

    testWidgets('SettingsScreen displays Security section with Change Password and 2FA', (tester) async {
      final container = ProviderContainer(
        overrides: [
          currentCustomerProvider.overrideWithValue(testCustomer),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Security section title and tiles
      expect(find.text('الأمان وحماية الحساب'), findsOneWidget);
      expect(find.text('كلمة المرور والأمان'), findsOneWidget);
      expect(find.text('المصادقة الثنائية ومفاتيح المرور'), findsOneWidget);
    });

    testWidgets('ProfileScreen removes membership banner and two-factor card', (tester) async {
      final container = ProviderContainer(
        overrides: [
          currentCustomerProvider.overrideWithValue(testCustomer),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Membership banner and 2FA card MUST NOT exist on ProfileScreen
      expect(find.text('عضوية VIP الذهبية'), findsNothing);
      expect(find.text('ROYAL MEMBER'), findsNothing);
      expect(find.textContaining('توصيل مجاني لكافة طلباتك'), findsNothing);
      expect(find.text('الأمان والخصوصية'), findsNothing);
    });

    testWidgets('EditProfileScreen renders user data including gender selector and updates state on selection', (tester) async {
      final container = ProviderContainer(
        overrides: [
          currentCustomerProvider.overrideWithValue(testCustomer),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: EditProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check fields are rendered
      expect(find.text('البيانات الشخصية'), findsOneWidget);
      expect(find.text('أحمد يحيى'), findsOneWidget);
      expect(find.text('ahmed@rawnaqk.com'), findsOneWidget);
      expect(find.text('771508902'), findsOneWidget);

      // Check Gender options
      expect(find.text('الجنس'), findsOneWidget);
      expect(find.text('ذكر'), findsOneWidget);
      expect(find.text('أنثى'), findsOneWidget);

      // Verify change password section is deleted from EditProfileScreen
      expect(find.text('الأمان وكلمة المرور'), findsNothing);

      // Tap female option
      await tester.tap(find.text('أنثى'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('EditProfileScreen save shows in-button success animation without showing dialog', (tester) async {
      final container = ProviderContainer(
        overrides: [
          currentCustomerProvider.overrideWithValue(testCustomer),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: EditProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap save button
      await tester.tap(find.byKey(const ValueKey('save_action_btn')));
      await tester.pump();

      // In-button success state appears with checkmark and 'تم الحفظ بنجاح'
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('تم الحفظ بنجاح'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      // Verify no dialog appears
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(Dialog), findsNothing);

      // Advance timer for delayed pop
      await tester.pump(const Duration(seconds: 1));
    });
  });
}

