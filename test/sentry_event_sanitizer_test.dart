import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/services/monitoring/sentry_event_sanitizer.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  group('SentryEventSanitizer Tests', () {
    test('sanitizes sensitive headers and cookies in SentryRequest', () {
      final request = SentryRequest(
        url: 'https://example.com/api/v1/customer/profile',
        method: 'POST',
        headers: {
          'Authorization': 'Bearer secret_token_12345',
          'Accept': 'application/json',
          'Cookie': 'session_id=abc123xyz',
        },
        data: {
          'password': 'super_secret_password',
          'email': 'customer@example.com',
          'name': 'Valid Name',
        },
      );

      final event = SentryEvent(
        request: request,
        exceptions: [
          SentryException(
            type: 'TestException',
            value: 'Something went wrong',
            stackTrace: SentryStackTrace(frames: [
              SentryStackFrame(absPath: 'lib/main.dart', lineNo: 42),
            ]),
          ),
        ],
      );

      final sanitized = SentryEventSanitizer.sanitize(event, Hint());

      expect(sanitized, isNotNull);
      final sanitizedReq = sanitized!.request!;

      // Verify headers sanitized
      expect(sanitizedReq.headers['Authorization'], SentryEventSanitizer.redactedPlaceholder);
      expect(sanitizedReq.headers.containsKey('Cookie'), isFalse);
      expect(sanitizedReq.headers['Accept'], 'application/json');

      // Verify cookies removed
      expect(sanitizedReq.cookies, isNull);

      // Verify sensitive data fields sanitized
      final dataMap = sanitizedReq.data as Map;
      expect(dataMap['password'], SentryEventSanitizer.redactedPlaceholder);
      expect(dataMap['email'], SentryEventSanitizer.redactedPlaceholder);
      expect(dataMap['name'], 'Valid Name');

      // Verify stack traces and exception preserved
      expect(sanitized.exceptions, isNotEmpty);
      expect(sanitized.exceptions!.first.type, 'TestException');
      expect(sanitized.exceptions!.first.stackTrace!.frames.first.lineNo, 42);
    });

    test('sanitizes user, tags, contexts and breadcrumbs', () {
      final event = SentryEvent(
        user: SentryUser(
          id: 'user_123',
          email: 'real_customer@test.com',
          ipAddress: '192.168.1.1',
          username: 'customer123',
        ),
        tags: {
          'authStatus': 'logged_in',
          'authToken': 'sensitive_tag',
        },
        contexts: Contexts(
          app: SentryApp(name: 'rwnaqk'),
        ),
        breadcrumbs: [
          Breadcrumb(
            message: 'User logged in with Bearer abc.xyz.123',
            data: {
              'otp': '123456',
              'page': 'checkout',
            },
          ),
        ],
      );
      event.contexts['sessionData'] = {
        'requestToken': 'jwt.token.here',
        'customerPhone': '+967770000000',
        'itemsCount': 5,
      };

      final sanitized = SentryEventSanitizer.sanitize(event, Hint());

      expect(sanitized, isNotNull);

      // User PII is stripped / anonymized
      expect(sanitized!.user!.email, isNull);
      expect(sanitized.user!.ipAddress, isNull);
      expect(sanitized.user!.username, isNull);
      expect(sanitized.user!.id, SentryEventSanitizer.redactedPlaceholder);

      // Tags
      expect(sanitized.tags!['authToken'], SentryEventSanitizer.redactedPlaceholder);
      expect(sanitized.tags!['authStatus'], SentryEventSanitizer.redactedPlaceholder);

      // Contexts
      final sessionCtx = sanitized.contexts['sessionData'] as Map<String, dynamic>;
      expect(sessionCtx['requestToken'], SentryEventSanitizer.redactedPlaceholder);
      expect(sessionCtx['customerPhone'], SentryEventSanitizer.redactedPlaceholder);
      expect(sessionCtx['itemsCount'], 5);

      // Breadcrumbs
      final b = sanitized.breadcrumbs!.first;
      expect(b.message, 'User logged in with Bearer [REDACTED]');
      expect(b.data!['otp'], SentryEventSanitizer.redactedPlaceholder);
      expect(b.data!['page'], 'checkout');
    });

    test('sanitizes Bearer Token inside exception message', () {
      final event = SentryEvent(
        exceptions: [
          SentryException(
            type: 'DioException',
            value: '401 Unauthorized: Request failed with Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xyz',
          ),
        ],
      );

      final sanitized = SentryEventSanitizer.sanitize(event, Hint());
      expect(sanitized, isNotNull);
      expect(
        sanitized!.exceptions!.first.value,
        '401 Unauthorized: Request failed with Bearer [REDACTED]',
      );
    });

    test('sanitizes Password in password=value format inside exception message', () {
      final event = SentryEvent(
        exceptions: [
          SentryException(
            type: 'DatabaseException',
            value: 'Connection failed with password=super_secret_123 for user admin',
          ),
        ],
      );

      final sanitized = SentryEventSanitizer.sanitize(event, Hint());
      expect(sanitized, isNotNull);
      expect(
        sanitized!.exceptions!.first.value,
        'Connection failed with password=[REDACTED] for user admin',
      );
    });

    test('sanitizes Token in token: value format inside exception message', () {
      final event = SentryEvent(
        exceptions: [
          SentryException(
            type: 'AuthException',
            value: 'Session expired for token: tok_live_9948293847293847 please re-login',
          ),
        ],
      );

      final sanitized = SentryEventSanitizer.sanitize(event, Hint());
      expect(sanitized, isNotNull);
      expect(
        sanitized!.exceptions!.first.value,
        'Session expired for token: [REDACTED] please re-login',
      );
    });

    test('sanitizes API Key in known formats inside exception message', () {
      final event = SentryEvent(
        exceptions: [
          SentryException(
            type: 'MapsApiException',
            value: 'Google Maps request failed with api_key=AIzaSyD-789xyz and apiKey: "secret_client_key"',
          ),
        ],
      );

      final sanitized = SentryEventSanitizer.sanitize(event, Hint());
      expect(sanitized, isNotNull);
      expect(
        sanitized!.exceptions!.first.value,
        'Google Maps request failed with api_key=[REDACTED] and apiKey: [REDACTED]',
      );
    });

    test('preserves normal exception message without secrets', () {
      const normalMsg =
          "SocketException: Failed host lookup: 'api.rwnaqk.com' (OS Error: No address associated with hostname, errno = 7)";
      final event = SentryEvent(
        exceptions: [
          SentryException(
            type: 'SocketException',
            value: normalMsg,
          ),
        ],
      );

      final sanitized = SentryEventSanitizer.sanitize(event, Hint());
      expect(sanitized, isNotNull);
      expect(sanitized!.exceptions!.first.value, normalMsg);
    });

    test('sanitizes exception containing multiple sensitive values in the same message', () {
      final event = SentryEvent(
        exceptions: [
          SentryException(
            type: 'ComplexAuthException',
            value:
                'Auth error: password=secret123, token: tok_abc456, api_key=key_9999 and Bearer my_jwt_token occurred on /checkout',
          ),
        ],
      );

      final sanitized = SentryEventSanitizer.sanitize(event, Hint());
      expect(sanitized, isNotNull);
      expect(
        sanitized!.exceptions!.first.value,
        'Auth error: password=[REDACTED], token: [REDACTED], api_key=[REDACTED] and Bearer [REDACTED] occurred on /checkout',
      );
    });
  });
}
