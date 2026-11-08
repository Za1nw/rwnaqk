/// الفئة الأساسية لجميع استثناءات الشبكة والـ API في التطبيق.
///
/// مستقلة تماماً عن أي حزمة واجهات أو GetX.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.rawResponse,
  });

  final String message;
  final int? statusCode;
  final dynamic rawResponse;

  @override
  String toString() => message;
}

/// استثناء أخطاء التحقق من المدخلات (Laravel 422 Unprocessable Entity)
class ValidationException extends ApiException {
  const ValidationException({
    required super.message,
    required this.errors,
    super.statusCode = 422,
    super.rawResponse,
  });

  final Map<String, List<String>> errors;

  /// فحص وجود خطأ لحقل معين
  bool hasErrorFor(String field) =>
      errors.containsKey(field) && (errors[field]?.isNotEmpty ?? false);

  /// جلب أول رسالة خطأ لحقل معين
  String? firstErrorFor(String field) =>
      hasErrorFor(field) ? errors[field]!.first : null;

  /// جلب جميع أخطاء التحقق مدمجة كنص موحد
  String get combinedErrorMessage {
    if (errors.isEmpty) return message;
    final buffer = StringBuffer();
    for (final entry in errors.entries) {
      for (final msg in entry.value) {
        buffer.writeln('• $msg');
      }
    }
    return buffer.toString().trim();
  }
}

/// استثناء انتهاء الجلسة أو عدم الصلاحية (401 Unauthorized)
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'انتهت الجلسة، يرجى إعادة تسجيل الدخول',
    super.statusCode = 401,
    super.rawResponse,
  });
}

/// استثناء الوصول الممنوع (403 Forbidden)
class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'ليس لديك صلاحية للوصول إلى هذا المورد',
    super.statusCode = 403,
    super.rawResponse,
  });
}

/// استثناء عدم العثور على المورد (404 Not Found)
class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'المورد المطلوب غير موجود',
    super.statusCode = 404,
    super.rawResponse,
  });
}

/// استثناء تجاوز حد الطلبات (429 Too Many Requests)
class RateLimitException extends ApiException {
  const RateLimitException({
    super.message = 'تم تجاوز عدد الطلبات المسموح بها، يرجى المحاولة بعد قليل',
    super.statusCode = 429,
    super.rawResponse,
  });
}

/// استثناء أخطاء الخادم الداخلية (500/502/503/504 Server Errors)
class ServerException extends ApiException {
  const ServerException({
    super.message = 'حدث خطأ في الخادم، يرجى المحاولة لاحقاً',
    super.statusCode = 500,
    super.rawResponse,
  });
}

/// استثناء انقطاع الاتصال أو انتهاء المهلة الزمنية (Network / Timeout)
class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'تعذر الاتصال بالخادم، يرجى التحقق من اتصال الإنترنت',
    super.statusCode,
    super.rawResponse,
  });
}

