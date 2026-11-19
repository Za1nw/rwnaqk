import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/services/auth/models/auth_session_state.dart';
import 'package:rwnaqk_frontend/core/services/auth/providers/auth_session_providers.dart';
import 'package:rwnaqk_frontend/modules/auth/views/network_error_view.dart';

class _FakeAuthSessionNotifier extends AuthSessionNotifier {
  _FakeAuthSessionNotifier(this._initial);
  final AuthSessionState _initial;
  bool retried = false;
  bool loggedOut = false;

  @override
  AuthSessionState build() => _initial;

  @override
  Future<bool> retryBootstrap() async {
    retried = true;
    return true;
  }

  @override
  Future<void> logout() async {
    loggedOut = true;
    state = const AuthSessionState();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NetworkErrorScreen Tests', () {
    testWidgets('Renders wifi off icon, title, retry button and logout option',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(
              () => _FakeAuthSessionNotifier(
                const AuthSessionState(
                  status: AuthSessionStatus.serverError,
                  token: 'my_token',
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: NetworkErrorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify title & messages
      expect(find.text('تعذر الاتصال بالخادم'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
      expect(
        find.text('تسجيل الخروج أو استخدام حساب آخر'),
        findsOneWidget,
      );
    });

    testWidgets('Tapping retry invokes retryBootstrap', (tester) async {
      final notifier = _FakeAuthSessionNotifier(
        const AuthSessionState(
          status: AuthSessionStatus.serverError,
          token: 'my_token',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(() => notifier),
          ],
          child: const MaterialApp(
            home: NetworkErrorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pumpAndSettle();

      expect(notifier.retried, isTrue);
    });

    testWidgets('Tapping logout clears session and proceeds', (tester) async {
      final notifier = _FakeAuthSessionNotifier(
        const AuthSessionState(
          status: AuthSessionStatus.serverError,
          token: 'my_token',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(() => notifier),
          ],
          child: const MaterialApp(
            home: NetworkErrorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('تسجيل الخروج أو استخدام حساب آخر'));
      await tester.pumpAndSettle();

      expect(notifier.loggedOut, isTrue);
    });
  });
}
