import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rwnaqk_frontend/core/network/api_client.dart';
import 'package:rwnaqk_frontend/core/network/api_endpoints.dart';
import 'package:rwnaqk_frontend/core/network/api_exceptions.dart';
import 'package:rwnaqk_frontend/modules/cart/data/models/cart_quote_model.dart';

/// واجهة مستودع عمليات السلة والتسعير الخادمي الموثق (Cart Repository Contract)
abstract class ICartRepository {
  /// طلب احتساب عرض السعر النهائي الموثق من خادم Laravel
  Future<CartQuoteModel?> requestCartQuote({
    required int addressId,
    required List<Map<String, dynamic>> items,
    String? couponCode,
    String? shippingOptionId,
    CancelToken? cancelToken,
  });

  /// التحقق من صلاحية كود الخصم المطبق مع الخادم
  Future<Map<String, dynamic>> validateCoupon({
    required String couponCode,
    double subtotal = 0.0,
    CancelToken? cancelToken,
  });
}

/// تطبيق مستودع السلة المتصل مباشرة بـ Laravel API
class CartRepositoryImpl implements ICartRepository {
  const CartRepositoryImpl({
    required ApiClient apiClient,
  }) : _api = apiClient;

  final ApiClient _api;

  @override
  Future<CartQuoteModel?> requestCartQuote({
    required int addressId,
    required List<Map<String, dynamic>> items,
    String? couponCode,
    String? shippingOptionId,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        ApiEndpoints.cartQuote,
        data: {
          'address_id': addressId,
          'items': items,
          if (couponCode != null && couponCode.trim().isNotEmpty)
            'coupon_code': couponCode.trim(),
          if (shippingOptionId != null && shippingOptionId.trim().isNotEmpty)
            'shipping_option_id': shippingOptionId.trim(),
        },
        cancelToken: cancelToken,
      );

      final data = response.data;
      if (data != null && data['data'] is Map<String, dynamic>) {
        return CartQuoteModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        rethrow;
      }
      if (kDebugMode) {
        debugPrint('[CartRepositoryImpl.requestCartQuote] Network error: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CartRepositoryImpl.requestCartQuote] Unexpected error: $e');
      }
      throw NetworkException(
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> validateCoupon({
    required String couponCode,
    double subtotal = 0.0,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        ApiEndpoints.validateCoupon,
        data: {
          'coupon_code': couponCode.trim(),
          'subtotal': subtotal,
        },
        cancelToken: cancelToken,
      );
      return response.data ?? {};
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        rethrow;
      }
      rethrow;
    } catch (e) {
      throw NetworkException(
        message: e.toString(),
        statusCode: 500,
      );
    }
  }
}

