import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:rwnaqk_frontend/core/constants/app_env.dart';
import 'package:rwnaqk_frontend/core/network/api_client.dart';
import 'package:rwnaqk_frontend/core/network/api_endpoints.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_details_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/providers/fake_orders_repository.dart';
import 'package:rwnaqk_frontend/modules/orders/data/repositories/orders_repository.dart';

/// تطبيق مستودع الطلبات النقي المتصل بخادم Laravel API عبر [ApiClient]
/// مع دعم الحماية الصارمة من التكرار عبر [X-Idempotency-Key].
class OrdersRepositoryImpl implements IOrdersRepository {
  OrdersRepositoryImpl({
    required ApiClient apiClient,
    FakeOrdersRepository? fallbackRepository,
    Uuid? uuid,
  })  : _api = apiClient,
        _fallback = fallbackRepository ?? FakeOrdersRepository(),
        _uuid = uuid ?? const Uuid();

  final ApiClient _api;
  final FakeOrdersRepository _fallback;
  final Uuid _uuid;

  @override
  Future<List<OrderModel>> getOrders() async {
    if (AppEnv.enableMockData) {
      return _fallback.getOrders();
    }

    try {
      final response = await _api.get<dynamic>(ApiEndpoints.orders);
      final data = response.data;
      final rawList = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List
          : data is List
              ? data
              : const [];

      return rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => OrderModel.fromJson(json))
          .toList();
    } catch (_) {
      if (AppEnv.isDevelopment) {
        return _fallback.getOrders();
      }
      rethrow;
    }
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    if (AppEnv.enableMockData) {
      return _fallback.getOrderById(orderId);
    }

    try {
      final response = await _api.get<dynamic>(ApiEndpoints.orderDetails(orderId));
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final orderJson = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
        return OrderModel.fromJson(orderJson);
      }
      return null;
    } catch (_) {
      if (AppEnv.isDevelopment) {
        return _fallback.getOrderById(orderId);
      }
      rethrow;
    }
  }

  @override
  Future<OrderDetailsModel> getOrderDetails(OrderModel order) async {
    return _fallback.getOrderDetails(order);
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    if (AppEnv.enableMockData) {
      return _fallback.createOrder(order);
    }

    try {
      // توليد مفتاح منع تكرار فريد وموثوق لكل محاولة إنشاء طلب
      final idempotencyKey = _uuid.v4();

      final response = await _api.post<dynamic>(
        ApiEndpoints.orders,
        data: order.toJson(),
        options: Options(
          headers: <String, dynamic>{
            'X-Idempotency-Key': idempotencyKey,
          },
        ),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final orderJson = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
        return OrderModel.fromJson(orderJson);
      }

      return order;
    } catch (_) {
      if (AppEnv.isDevelopment) {
        return _fallback.createOrder(order);
      }
      rethrow;
    }
  }

  @override
  Future<void> clearLocalCache() async {
    await _fallback.clearLocalCache();
  }
}

