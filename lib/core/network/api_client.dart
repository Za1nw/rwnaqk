import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rwnaqk_frontend/core/constants/app_env.dart';
import 'package:rwnaqk_frontend/core/network/api_exceptions.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';

/// عميل اتصال شبكي موحد ونقي مبني على Dio
///
/// مستقل تماماً عن GetX أو أي إطار واجهات، ويوفر:
/// - إدراج توكن الجلسة تلقائياً من [IAuthTokenStorage]
/// - تحويل استثناءات Dio إلى [ApiException] متوافقة مع Laravel
/// - دعم المفاتيح الآمنة مثل X-Idempotency-Key
/// - التعامل مع رفع الملفات والسندات المالية
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

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          // تسجيل رقم الجيل الحالي والتوكن عند لحظة إنشاء الطلب (Request-Creation Time Capture)
          if (getSessionGeneration != null) {
            options.extra['requestSessionGeneration'] =
                getSessionGeneration?.call();
          }

          // إضافة التوكن إن لم يكن مضافاً يدوياً
          if (!options.headers.containsKey('Authorization')) {
            final token = await _tokenStorage.readToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
              options.extra['requestToken'] = token;
            }
          } else {
            final authHeader = options.headers['Authorization'] as String?;
            if (authHeader != null && authHeader.startsWith('Bearer ')) {
              options.extra['requestToken'] = authHeader.substring(7).trim();
            }
          }

          if (AppEnv.enableDebugLogs && kDebugMode) {
            debugPrint('[HTTP Request] ${options.method} ${options.uri}');
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
        final authHeader =
            error.requestOptions.headers['Authorization'] as String?;
        final failedToken = (authHeader != null &&
                authHeader.startsWith('Bearer '))
            ? authHeader.substring(7).trim()
            : error.requestOptions.extra['requestToken'] as String?;
        final requestGen =
            error.requestOptions.extra['requestSessionGeneration'] as int?;

        // إذا تم تزويد رد نداء مع التفاصيل الدقيقة (التوكن + الجيل الملتقط لحظة إنشاء الطلب)
        if (onUnauthorizedWithDetails != null) {
          onUnauthorizedWithDetails?.call(failedToken, requestGen);
        } else if (onUnauthorizedWithToken != null) {
          if (failedToken != null && failedToken.isNotEmpty) {
            onUnauthorizedWithToken?.call(failedToken);
          }
        } else {
          onUnauthorized?.call();
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
