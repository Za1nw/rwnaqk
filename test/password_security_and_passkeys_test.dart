import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/login_service.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/passkey_model.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/user_session_model.dart';
import 'package:rwnaqk_frontend/modules/customer/views/password_and_security_view.dart';
import 'package:rwnaqk_frontend/modules/customer/views/settings_view.dart';
import 'package:rwnaqk_frontend/modules/customer/views/two_factor_and_passkeys_view.dart';

class FakeAuthRepository implements IAuthRepository {
  final List<UserSessionModel> sessions = [
    UserSessionModel(
      id: 101,
      deviceName: 'Current Phone (Galaxy S24)',
      isCurrent: true,
      lastUsedAt: DateTime.now(),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    UserSessionModel(
      id: 102,
      deviceName: 'Secondary Tablet (iPad Pro)',
      isCurrent: false,
      lastUsedAt: DateTime.now().subtract(const Duration(hours: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  final List<PasskeyModel> passkeys = [
    PasskeyModel(
      id: 201,
      name: 'بصمة الإصبع - Galaxy S24',
      lastUsedAt: DateTime.now(),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  bool changePasswordCalled = false;
  int? revokedSessionId;
  bool revokedOthersCalled = false;
  String? storedPasskeyName;
  int? deletedPasskeyId;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    changePasswordCalled = true;
  }

  @override
  Future<List<UserSessionModel>> getSessions() async {
    return List.from(sessions);
  }

  @override
  Future<void> revokeSession(int id) async {
    revokedSessionId = id;
    sessions.removeWhere((s) => s.id == id);
  }

  @override
  Future<void> revokeOtherSessions() async {
    revokedOthersCalled = true;
    sessions.removeWhere((s) => !s.isCurrent);
  }

  @override
  Future<List<PasskeyModel>> getPasskeys() async {
    return List.from(passkeys);
  }

  @override
  Future<PasskeyModel> storePasskey({
    required String name,
    String? credentialId,
    Map<String, dynamic>? credential,
  }) async {
    storedPasskeyName = name;
    final pk = PasskeyModel(
      id: 202,
      name: name,
      createdAt: DateTime.now(),
      lastUsedAt: DateTime.now(),
    );
    passkeys.add(pk);
    return pk;
  }

  @override
  Future<LoginResult> passkeyLogin({
    required String credentialId,
    String? secret,
    String? email,
  }) async =>
      const LoginResult(
        isSuccess: true,
        token: 'fake-passkey-token',
        requiresTwoFactor: false,
        requiresEmailVerification: false,
      );

  @override
  Future<void> deletePasskey(int id) async {
    deletedPasskeyId = id;
    passkeys.removeWhere((p) => p.id == id);
  }

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
    String? code,
    String? recoveryCode,
    String? deviceName,
  }) async =>
      const LoginResult(
        isSuccess: true,
        requiresTwoFactor: false,
        requiresEmailVerification: false,
      );

  @override
  Future<LoginResult> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String country,
    required String governorate,
    required String password,
    required String passwordConfirmation,
    required bool termsAccepted,
    required bool privacyPolicyAccepted,
    String? gender,
    String? deviceName,
  }) async =>
      const LoginResult(
        isSuccess: true,
        requiresTwoFactor: false,
        requiresEmailVerification: false,
      );

  @override
  Future<CustomerModel> me() async => const CustomerModel(
        id: 1,
        fullName: 'أحمد يحيى',
        firstName: 'أحمد',
        lastName: 'يحيى',
        email: 'ahmed@example.com',
        mobile: '771508902',
      );

  @override
  Future<void> logout() async {}

  @override
  Future<void> forgotPassword({required String email}) async {}

  @override
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {}

  @override
  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> sendEmailVerificationCode() async {}

  @override
  Future<void> verifyEmailCode({required String code}) async {}

  @override
  Future<CustomerModel> updateProfile({
    String? firstName,
    String? lastName,
    String? name,
    String? email,
    String? mobile,
    String? gender,
    String? avatarFilePath,
  }) async =>
      me();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserSessionModel and PasskeyModel Unit Tests', () {
    test('UserSessionModel parses JSON correctly', () {
      final json = {
        'id': 10,
        'device_name': 'Pixel 8',
        'is_current': true,
        'last_used_at': '2026-11-11T12:00:00.000Z',
        'created_at': '2026-11-10T12:00:00.000Z',
      };
      final model = UserSessionModel.fromJson(json);
      expect(model.id, 10);
      expect(model.deviceName, 'Pixel 8');
      expect(model.isCurrent, true);
      expect(model.lastUsedAt, isNotNull);
      expect(model.createdAt, isNotNull);
    });

    test('PasskeyModel parses JSON correctly', () {
      final json = {
        'id': 25,
        'name': 'بصمة الإصبع Mac',
        'created_at': '2026-11-11T10:00:00.000Z',
        'last_used_at': '2026-11-11T11:00:00.000Z',
      };
      final model = PasskeyModel.fromJson(json);
      expect(model.id, 25);
      expect(model.name, 'بصمة الإصبع Mac');
      expect(model.createdAt, isNotNull);
      expect(model.lastUsedAt, isNotNull);
    });
  });

  group('PasswordAndSecurityScreen Widget Tests', () {
    testWidgets('renders change password form and sessions list with current session protected',
        (tester) async {
      final fakeRepo = FakeAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: PasswordAndSecurityScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check change password fields
      expect(find.text('كلمة المرور والأمان'), findsOneWidget);
      expect(find.text('تغيير كلمة المرور'), findsOneWidget);
      expect(find.text('حفظ كلمة المرور الجديدة'), findsOneWidget);

      // Check sessions list
      expect(find.text('الجلسات والأجهزة النشطة'), findsOneWidget);
      expect(find.text('Current Phone (Galaxy S24)'), findsOneWidget);
      expect(find.text('Secondary Tablet (iPad Pro)'), findsOneWidget);

      // Verify Current Session badge
      expect(find.text('الجلسة الحالية'), findsOneWidget);
      expect(find.text('هذا الجهاز'), findsOneWidget);

      // Verify button to revoke other sessions
      expect(find.textContaining('تسجيل الخروج من جميع الجلسات الأخرى'), findsOneWidget);
    });
  });

  group('TwoFactorAndPasskeysScreen Widget Tests', () {
    testWidgets('renders passkeys section and activation button', (tester) async {
      final fakeRepo = FakeAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: TwoFactorAndPasskeysScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('المصادقة الثنائية ومفاتيح المرور'), findsOneWidget);
      expect(find.text('تسجيل الدخول بالبصمة وقفل الجهاز'), findsOneWidget);
      expect(find.text('تفعيل مفتاح مرور لهذا الجهاز'), findsOneWidget);
      expect(find.text('بصمة الإصبع - Galaxy S24'), findsOneWidget);
    });
  });

  group('SettingsScreen Security Tiles Test', () {
    testWidgets('SettingsScreen displays Password & Security and 2FA & Passkeys tiles',
        (tester) async {
      final fakeRepo = FakeAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('كلمة المرور والأمان'), findsOneWidget);
      expect(find.text('تغيير كلمة المرور وإدارة الجلسات والأجهزة النشطة'), findsOneWidget);
      expect(find.text('المصادقة الثنائية ومفاتيح المرور'), findsOneWidget);
    });
  });
}
