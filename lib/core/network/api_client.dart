import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rwnaqk_frontend/core/constants/app_env.dart';
import 'package:rwnaqk_frontend/core/network/api_exceptions.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/core/services/auth/models/auth_session_state.dart'
    show AuthSessionStatus;
import 'package:rwnaqk_frontend/modules/auth/data/auth_endpoints.dart';

/// سياسة التحكم بحقن التوكن في عميل الشبكة
enum TokenInjectionPolicy {
  /// مسموح بالحقن: الجلسة مصادقة رسمياً ومؤهلة لاستخدام التوكن
  allowed,

  /// ممنوع الحقن: الجلسة غير مصادقة، محظورة، ضيف، أو المسار عام
  denied,

  /// مجهول / خطأ: تعذر قراءة الحالة أو غياب الكولباك (Fail-Closed)
  unknown,
}

/// لقطة سياق الجلسة الموحدة للتحقق من حقن التوكن [SessionTokenContext]
@immutable
class SessionTokenContext {
  final TokenInjectionPolicy policy;
  final String? currentSessionToken;
  final int sessionGeneration;
  final AuthSessionStatus? sessionStatus;
  final bool isBanned;

  const SessionTokenContext({
    required this.policy,
    this.currentSessionToken,
    this.sessionGeneration = 0,
    this.sessionStatus,
    this.isBanned = false,
  });

  const SessionTokenContext.unknown()
      : policy = TokenInjectionPolicy.unknown,
        currentSessionToken = null,
        sessionGeneration = 0,
        sessionStatus = null,
        isBanned = false;

  const SessionTokenContext.denied({
    int generation = 0,
    AuthSessionStatus? status,
    bool banned = false,
  })  : policy = TokenInjectionPolicy.denied,
        currentSessionToken = null,
        sessionGeneration = generation,
        sessionStatus = status,
        isBanned = banned;
}

/// عميل اتصال شبكي موحد ونقي مبني على Dio
///
/// مستقل تماماً عن GetX أو أي إطار واجهات، ويوفر:
/// - إدراج توكن الجلسة تلقائياً وفق سياسة أمان صارمة واعية بالمصادقة
/// - تحويل استثناءات Dio إلى [ApiException] متوافقة مع Laravel
/// - دعم المفاتيح الآمنة مثل X-Idempotency-Key
/// - حماية كاملة من سباقات تبديل الحسابات والحظر واستعادة الجلسة
class ApiClient {
  ApiClient({
    Dio? dio,
    IAuthTokenStorage? tokenStorage,
    String? baseUrl,
    this.onUnauthorized,
    this.onUnauthorizedWithToken,
    this.onUnauthorizedWithDetails,
    this.onAccountBanned,
    this.getSessionGeneration,
    this.getSessionTokenContext,
  })  : _tokenStorage = tokenStorage ?? SecureAuthTokenStorage() {
    _dio = dio ??
        Dio(
          BaseOptions(
            baseUrl: baseUrl ?? AppEnv.apiBaseUrl,
            connectTimeout: Duration(seconds: AppEnv.apiTimeoutSeconds),
            receiveTimeout: Duration(seconds: AppEnv.apiTimeoutSeconds),
            sendTimeout: Duration(seconds: AppEnv.apiTimeoutSeconds),
            headers: const <String, dynamic>{
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        );

    _setupInterceptors();
  }

  late final Dio _dio;
  final IAuthTokenStorage _tokenStorage;
  final void Function()? onUnauthorized;
  final void Function(String failedToken)? onUnauthorizedWithToken;
  final void Function(String? failedToken, int? sessionGeneration)?
      onUnauthorizedWithDetails;
  final void Function(Map<String, dynamic>? customerData, String? reason)?
      onAccountBanned;
  final int? Function()? getSessionGeneration;
  final SessionTokenContext Function(RequestOptions options)?
      getSessionTokenContext;

  Dio get dio => _dio;

  /// التحقق الدقيق مما إذا كان المسار مسار مصادقة عام لا يتطلب توكن
  static bool isPublicAuthEndpoint(String method, String rawPath) {
    if (method.toUpperCase() != 'POST') return false;
    final cleanPath = Uri.tryParse(rawPath)?.path ?? rawPath;
    return cleanPath == AuthEndpoints.login ||
        cleanPath == AuthEndpoints.register ||
        cleanPath == AuthEndpoints.forgotPassword ||
        cleanPath == AuthEndpoints.verifyPasswordResetCode ||
        cleanPath == AuthEndpoints.resetPassword;
  }

  /// التحقق الدقيق مما إذا كان المسار هو مسار التحقق الأولي auth/me
  static bool isMeEndpoint(String method, String rawPath) {
    if (method.toUpperCase() != 'GET') return false;
    final cleanPath = Uri.tryParse(rawPath)?.path ?? rawPath;
    return cleanPath == AuthEndpoints.me;
  }

  /// تطهير شامل لترويسات Authorization بحيادية تامة لحالة الأحرف
  void _sanitizeAuthorizationHeaders(RequestOptions options) {
    final authKeys = options.headers.keys
        .where((k) => k.toLowerCase() == 'authorization')
        .toList();
    for (final key in authKeys) {
      options.headers.remove(key);
    }
    options.extra.remove('requestToken');
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          // 1. تنظيف مسبق لبيانات الطلب لضمان عدم إعادة استخدام قيم قديمة من محاولات سابقة
          options.extra.remove('requestToken');
          options.extra.remove('requestSessionGeneration');

          // 2. إذا كان الطلب مسار مصادقة عام: تجريد الترويسات وتمرير الطلب كطلب غير موثق
          if (isPublicAuthEndpoint(options.method, options.path)) {
            _sanitizeAuthorizationHeaders(options);
            if (AppEnv.enableDebugLogs && kDebugMode) {
              debugPrint('[HTTP Request (Public Auth)] ${options.method} ${options.uri.path}');
            }
            return handler.next(options);
          }

          // 3. استدعاء كولباك السياق بحماية Fail-Closed صارمة
          SessionTokenContext context;
          try {
            if (getSessionTokenContext != null) {
              context = getSessionTokenContext!(options);
            } else {
              context = const SessionTokenContext.unknown();
            }
          } catch (e, st) {
            debugPrint('[ApiClient] Fail-closed: getSessionTokenContext threw exception: $e\n$st');
            context = const SessionTokenContext.unknown();
          }

          // 4. تقييم السياسة: إذا لم تكن الجلسة مؤهلة صراحة، تجريد الترويسات وتمرير الطلب دون توكن
          if (context.policy != TokenInjectionPolicy.allowed) {
            _sanitizeAuthorizationHeaders(options);
            if (AppEnv.enableDebugLogs && kDebugMode) {
              debugPrint('[HTTP Request (${context.policy.name})] ${options.method} ${options.uri.path}');
            }
            return handler.next(options);
          }

          // 5. إذا كانت السياسة allowed: التقاط جيل الجلسة الأولي وتحديد التوكن
          final initialGen = context.sessionGeneration;
          String? tokenToInject = context.currentSessionToken?.trim();

          // إذا لم يتوفر التوكن في سياق الذاكرة، قراءته من التخزين كخيار احتياطي
          if (tokenToInject == null || tokenToInject.isEmpty) {
            try {
              final diskToken = await _tokenStorage.readToken();
              tokenToInject = diskToken?.trim();
            } catch (e, st) {
              debugPrint('[ApiClient] Error reading storage for allowed request: $e\n$st');
              _sanitizeAuthorizationHeaders(options);
              return handler.next(options);
            }
          }

          // 6. التحقق البعدي المزدوج لمنع حالات السباق وتبدل الحسابات (Post-Verification Double-Check)
          SessionTokenContext postContext;
          try {
            if (getSessionTokenContext != null) {
              postContext = getSessionTokenContext!(options);
            } else {
              postContext = const SessionTokenContext.unknown();
            }
          } catch (e, st) {
            debugPrint('[ApiClient] Fail-closed: post-verification check threw exception: $e\n$st');
            _sanitizeAuthorizationHeaders(options);
            return handler.next(options);
          }

          final isSameGen = postContext.sessionGeneration == initialGen;
          final isStillAllowed = postContext.policy == TokenInjectionPolicy.allowed;
          final isTokenValid = tokenToInject != null && tokenToInject.isNotEmpty;
          final isMatchingToken = postContext.currentSessionToken == null ||
              postContext.currentSessionToken!.trim().isEmpty ||
              postContext.currentSessionToken!.trim() == tokenToInject;

          if (!isSameGen || !isStillAllowed || !isTokenValid || !isMatchingToken) {
            debugPrint(
              '[ApiClient] Generation/Session race prevented: initialGen=$initialGen, '
              'postGen=${postContext.sessionGeneration}, policy=${postContext.policy.name}. Token withheld.',
            );
            _sanitizeAuthorizationHeaders(options);
            return handler.next(options);
          }

          // 7. إرفاق التوكن المعتمد فقط وتطهير أي ترويسة قديمة أو غير مطابقة
          _sanitizeAuthorizationHeaders(options);
          options.headers['Authorization'] = 'Bearer $tokenToInject';
          options.extra['requestToken'] = tokenToInject;
          options.extra['requestSessionGeneration'] = initialGen;

          if (AppEnv.enableDebugLogs && kDebugMode) {
            debugPrint('[HTTP Request (Authenticated)] ${options.method} ${options.uri.path}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (AppEnv.enableDebugLogs && kDebugMode) {
            debugPrint('[HTTP Response] ${response.statusCode} ${response.requestOptions.uri}');
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          final mappedException = _mapDioException(error);

          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: mappedException,
            ),
          );
        },
      ),
    );
  }

  ApiException _mapDioException(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;
    final data = response?.data;

    String errorMessage = 'حدث خطأ غير متوقع في الاتصال';
    if (data is Map<String, dynamic> && data['message'] is String) {
      errorMessage = data['message'] as String;
    }

    switch (statusCode) {
      case 401:
        final isPublicAuth = isPublicAuthEndpoint(
          error.requestOptions.method,
          error.requestOptions.path,
        );

        final authHeader =
            error.requestOptions.headers['Authorization'] as String?;
        final failedToken = (authHeader != null &&
                authHeader.startsWith('Bearer '))
            ? authHeader.substring(7).trim()
            : error.requestOptions.extra['requestToken'] as String?;
        final requestGen =
            error.requestOptions.extra['requestSessionGeneration'] as int?;

        // استدعاء معالجات انتهاء الجلسة فقط للطلبات الخاصة التي حملت توكناً مصادقاً فعلياً
        if (!isPublicAuth && failedToken != null && failedToken.isNotEmpty) {
          if (onUnauthorizedWithDetails != null) {
            onUnauthorizedWithDetails?.call(failedToken, requestGen);
          } else if (onUnauthorizedWithToken != null) {
            onUnauthorizedWithToken?.call(failedToken);
          } else {
            onUnauthorized?.call();
          }
        }
        return UnauthorizedException(
          message: errorMessage,
          statusCode: 401,
          rawResponse: data,
        );

      case 403:
        if (data is Map<String, dynamic> &&
            (data['error_code'] == 'ACCOUNT_BANNED' ||
                data['is_banned'] == true)) {
          final customerData = data['customer'] is Map<String, dynamic>
              ? data['customer'] as Map<String, dynamic>
              : null;
          onAccountBanned?.call(customerData, errorMessage);
          return AccountBannedException(
            message: errorMessage,
            statusCode: 403,
            rawResponse: data,
            customerData: customerData,
          );
        }
        return ForbiddenException(
          message: errorMessage,
          statusCode: 403,
          rawResponse: data,
        );

      case 404:
        return NotFoundException(
          message: errorMessage,
          statusCode: 404,
          rawResponse: data,
        );

      case 422:
        final parsedErrors = <String, List<String>>{};
        if (data is Map<String, dynamic> && data['errors'] is Map) {
          final rawErrors = data['errors'] as Map<dynamic, dynamic>;
          rawErrors.forEach((key, value) {
            if (value is List) {
              parsedErrors[key.toString()] =
                  value.map((e) => e.toString()).toList();
            } else if (value != null) {
              parsedErrors[key.toString()] = [value.toString()];
            }
          });
        }
        return ValidationException(
          message: errorMessage,
          errors: parsedErrors,
          rawResponse: data,
        );

      case 429:
        return RateLimitException(
          message: errorMessage,
          statusCode: 429,
          rawResponse: data,
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          message: errorMessage,
          statusCode: statusCode,
          rawResponse: data,
        );

      default:
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.connectionError) {
          return NetworkException(
            message: 'تعذر الاتصال بالخادم، يرجى التحقق من اتصال الإنترنت',
            statusCode: statusCode,
            rawResponse: data,
          );
        }

        return ApiException(
          message: errorMessage,
          statusCode: statusCode,
          rawResponse: data,
        );
    }
  }

  // Helper Request Methods
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw _mapDioException(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw _mapDioException(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw _mapDioException(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw _mapDioException(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw _mapDioException(e);
    }
  }

  /// رفع ملف وسائط (مثل صورة سند التحويل البنكي)
  Future<Response<T>> uploadFile<T>(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? extraData,
    String? fileName,
    String? idempotencyKey,
    CancelToken? cancelToken,
  }) async {
    try {
      final multipartFile = await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      );

      final map = <String, dynamic>{
        fieldName: multipartFile,
        ...?extraData,
      };

      final formData = FormData.fromMap(map);

      final headers = <String, dynamic>{
        if (idempotencyKey != null && idempotencyKey.isNotEmpty)
          'X-Idempotency-Key': idempotencyKey,
      };

      return await _dio.post<T>(
        path,
        data: formData,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw _mapDioException(e);
    }
  }
}
