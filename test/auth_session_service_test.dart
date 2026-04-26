import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk/core/constants/local_storage_keys.dart';
import 'package:rwnaqk/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk/models/customer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('completeEmailVerification keeps the session active', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final session = AuthSessionService(initialAccessToken: 'token-123');
    session.setCustomer(
      const CustomerModel(
        email: 'customer@example.com',
      ),
    );
    session.setEmailVerificationRequired(true);

    await session.completeEmailVerification();

    expect(session.token.value, 'token-123');
    expect(session.requiresEmailVerification.value, false);
    expect(session.customer.value?.emailVerifiedAt, isNotNull);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(LocalStorageKeys.authToken), 'token-123');
  });
}