import 'package:sentry_flutter/sentry_flutter.dart';

/// مصفاة أمنية متقدمة لتنقية أحداث Sentry قبل إرسالها (Privacy & Data Sanitization)
///
/// تحجب وتطهر البيانات الحساسة مثل التوكنات، كلمات المرور، رموز التحقق OTP،
/// وترويسات المصادقة، مع الحفاظ الكامل على Stack Trace وتفاصيل الاستثناءات.
class SentryEventSanitizer {
  const SentryEventSanitizer._();

  static const String redactedPlaceholder = '[REDACTED]';

  /// قائمة بالكلمات المفتاحية الحساسة التي يجب حجب قيمها
  static final RegExp _sensitiveKeyPattern = RegExp(
    r'(password|passphrase|token|requesttoken|authorization|cookie|set-cookie|'
    r'session|otp|secret|bearer|auth|credit_card|cvv|phone|email|national_id|id_number)',
    caseSensitive: false,
  );

  /// تعقيم ترويسة Bearer داخل النصوص (يدعم Base64 وBase64Url وJWT)
  static final RegExp _bearerPattern = RegExp(
    r'Bearer\s+[A-Za-z0-9_\-\.\+\/=]+',
    caseSensitive: false,
  );

  /// أنماط المفاتيح الحساسة بصيغ key=value أو key: value
  static final RegExp _keyValueSecretPattern = RegExp(
    r'''\b(password|passphrase|token|auth_token|access_token|refresh_token|app_token|session_token|api_key|apiKey|apikey|secret|client_secret)(\s*[:=]\s*)(?:["'][^"'\r\n]*["']|[^\s"'`,;]+)''',
    caseSensitive: false,
  );

  /// معالج beforeSend المخصص لـ Sentry
  static SentryEvent? sanitize(SentryEvent event, Hint hint) {
    try {
      // 1. تنقية بيانات المستخدم (حماية بيانات العملاء PII)
      if (event.user != null) {
        event.user = SentryUser(
          id: redactedPlaceholder,
          ipAddress: null,
          email: null,
          username: null,
        );
      }

      // 2. تنقية طلب الشبكة إن وجد (SentryRequest)
      final request = event.request;
      if (request != null) {
        final sanitizedHeaders = <String, String>{};
        for (final entry in request.headers.entries) {
          final lowerKey = entry.key.toLowerCase();
          // حذف ملفات تعريف الارتباط بالكامل لمنع تسريب الجلسات
          if (lowerKey == 'cookie' || lowerKey == 'set-cookie') {
            continue;
          }
          if (_sensitiveKeyPattern.hasMatch(entry.key)) {
            sanitizedHeaders[entry.key] = redactedPlaceholder;
          } else {
            sanitizedHeaders[entry.key] = entry.value;
          }
        }

        dynamic sanitizedData = request.data;
        if (sanitizedData is Map<String, dynamic>) {
          sanitizedData = _sanitizeMap(sanitizedData);
        } else if (sanitizedData is Map) {
          sanitizedData = _sanitizeMap(Map<String, dynamic>.from(sanitizedData));
        } else if (sanitizedData is String && _sensitiveKeyPattern.hasMatch(sanitizedData)) {
          sanitizedData = redactedPlaceholder;
        }

        final sanitizedQuery = request.queryString != null && _sensitiveKeyPattern.hasMatch(request.queryString!)
            ? redactedPlaceholder
            : request.queryString;

        event.request = SentryRequest(
          url: request.url,
          method: request.method,
          queryString: sanitizedQuery,
          cookies: null,
          fragment: request.fragment,
          data: sanitizedData,
          headers: sanitizedHeaders,
          env: request.env,
          apiTarget: request.apiTarget,
        );
      }

      // 3. تنقية Breadcrumbs
      final breadcrumbs = event.breadcrumbs;
      if (breadcrumbs != null) {
        for (final b in breadcrumbs) {
          if (b.message != null && _bearerPattern.hasMatch(b.message!)) {
            b.message = b.message!.replaceAll(_bearerPattern, 'Bearer $redactedPlaceholder');
          }
          if (b.data != null) {
            b.data = _sanitizeMap(b.data);
          }
        }
      }

      // 4. تنقية الوسوم (Tags)
      final tags = event.tags;
      if (tags != null) {
        final sanitizedTags = <String, String>{};
        for (final entry in tags.entries) {
          if (_sensitiveKeyPattern.hasMatch(entry.key)) {
            sanitizedTags[entry.key] = redactedPlaceholder;
          } else {
            sanitizedTags[entry.key] = entry.value;
          }
        }
        event.tags = sanitizedTags;
      }

      // 5. تنقية السياق (Contexts)
      for (final key in event.contexts.keys) {
        final dynamic val = event.contexts[key];
        if (val is Map<String, dynamic>) {
          event.contexts[key] = _sanitizeMap(val);
        } else if (val is Map) {
          event.contexts[key] = _sanitizeMap(Map<String, dynamic>.from(val));
        }
      }

      // 6. تنقية رسائل الاستثناءات (Exception Messages)
      final exceptions = event.exceptions;
      if (exceptions != null && exceptions.isNotEmpty) {
        for (final e in exceptions) {
          final val = e.value;
          if (val != null && val.isNotEmpty) {
            e.value = sanitizeExceptionMessage(val);
          }
        }
      }

      return event;
    } catch (_) {
      // في حال حدوث أي خطأ غير متوقع أثناء التعقيم، نضمن عدم تعطل التطبيق ونعيد الحدث
      return event;
    }
  }

  /// تنقية نصوص رسائل الاستثناءات لإخفاء أي أسرار أو رموز حساسة
  static String sanitizeExceptionMessage(String message) {
    var sanitized = message;

    // 1. تنقية Bearer tokens
    if (_bearerPattern.hasMatch(sanitized)) {
      sanitized = sanitized.replaceAll(_bearerPattern, 'Bearer $redactedPlaceholder');
    }

    // 2. تنقية القيم المقترنة بالمفاتيح الحساسة (password=..., token: ..., api_key=...)
    if (_keyValueSecretPattern.hasMatch(sanitized)) {
      sanitized = sanitized.replaceAllMapped(_keyValueSecretPattern, (match) {
        final key = match.group(1) ?? '';
        final delimiter = match.group(2) ?? '';
        return '$key$delimiter$redactedPlaceholder';
      });
    }

    return sanitized;
  }

  static Map<String, dynamic>? _sanitizeMap(Map<String, dynamic>? source) {
    if (source == null) return null;

    final result = <String, dynamic>{};
    for (final entry in source.entries) {
      final key = entry.key;
      final val = entry.value;

      if (_sensitiveKeyPattern.hasMatch(key)) {
        result[key] = redactedPlaceholder;
      } else if (val is Map<String, dynamic>) {
        result[key] = _sanitizeMap(val);
      } else if (val is Map) {
        result[key] = _sanitizeMap(Map<String, dynamic>.from(val));
      } else if (val is List) {
        result[key] = val.map((item) {
          if (item is Map<String, dynamic>) return _sanitizeMap(item);
          if (item is Map) return _sanitizeMap(Map<String, dynamic>.from(item));
          if (item is String && _sensitiveKeyPattern.hasMatch(item)) {
            return redactedPlaceholder;
          }
          return item;
        }).toList();
      } else if (val is String && _bearerPattern.hasMatch(val)) {
        result[key] = val.replaceAll(_bearerPattern, 'Bearer $redactedPlaceholder');
      } else {
        result[key] = val;
      }
    }
    return result;
  }
}
