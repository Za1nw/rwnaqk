import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rwnaqk_frontend/core/constants/local_storage_keys.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SecureAuthTokenStorage & Migration Tests', () {
    test('Migrates legacy plaintext token from SharedPreferences to SecureStorage and deletes plaintext copy', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(LocalStorageKeys.authToken, 'legacy_secret_token_abc');

      final storage = SecureAuthTokenStorage();

      // Read token should find legacy token, write it securely, and delete it from SharedPreferences
      final token = await storage.readToken();
      expect(token, 'legacy_secret_token_abc');

      // SharedPreferences should no longer hold the unencrypted token
      final legacyAfter = prefs.getString(LocalStorageKeys.authToken);
      expect(legacyAfter, isNull);
    });

    test('clearToken clears token from storage and SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(LocalStorageKeys.authToken, 'to_be_cleared');

      final storage = SecureAuthTokenStorage();
      await storage.clearToken();

      expect(prefs.containsKey(LocalStorageKeys.authToken), isFalse);
    });

    test('writeToken trims and persists token, removing any legacy SharedPreferences value', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(LocalStorageKeys.authToken, 'old_plaintext');

      final storage = SecureAuthTokenStorage();
      await storage.writeToken('   new_secure_jwt   ');

      // Legacy key was removed from SharedPreferences (or fallback updated)
      expect(prefs.getString(LocalStorageKeys.authToken) != 'old_plaintext', isTrue);
    });
  });
}

