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
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    if (AppEnv.enableMockData) {
      return _fallback.getOrderById(orderId);
    }

    final response = await _api.get<dynamic>(ApiEndpoints.orderDetails(orderId));
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final orderJson = data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data;
      return OrderModel.fromJson(orderJson);
    }
    return null;
  }

  @override
  Future<OrderDetailsModel> getOrderDetails(OrderModel order) async {
    if (AppEnv.enableMockData) {
      return _fallback.getOrderDetails(order);
    }

    try {
      final response = await _api.get<dynamic>(ApiEndpoints.orderDetails(order.id));
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final orderJson = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
        return OrderDetailsModel.fromJson(orderJson);
      }
    } catch (_) {
      // في حال تعذر جلب التفاصيل بالكامل، نعود للمستودع الاحتياطي
    }

    return _fallback.getOrderDetails(order);
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    if (AppEnv.enableMockData) {
      return _fallback.createOrder(order);
    }

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
  }

  @override
  Future<OrderModel> submitCheckout({
    required int addressId,
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
    String? couponCode,
    String? shippingOptionId,
    double? expectedGrandTotal,
    Map<String, dynamic>? walletAccount,
    String? receiptImageUrl,
    String? notes,
    String? idempotencyKey,
  }) async {
    if (AppEnv.enableMockData) {
      return _fallback.submitCheckout(
        addressId: addressId,
        items: items,
        paymentMethod: paymentMethod,
        couponCode: couponCode,
        shippingOptionId: shippingOptionId,
        expectedGrandTotal: expectedGrandTotal,
        walletAccount: walletAccount,
        receiptImageUrl: receiptImageUrl,
        notes: notes,
        idempotencyKey: idempotencyKey,
      );
    }

    final key = (idempotencyKey != null && idempotencyKey.trim().isNotEmpty)
        ? idempotencyKey
        : _uuid.v4();

    final payload = <String, dynamic>{
      'address_id': addressId,
      'items': items,
      'payment_method': paymentMethod,
    };
    if (couponCode != null && couponCode.isNotEmpty) {
      payload['coupon_code'] = couponCode;
    }
    if (shippingOptionId != null && shippingOptionId.isNotEmpty) {
      payload['shipping_option_id'] = shippingOptionId;
    }
    if (expectedGrandTotal != null) {
      payload['expected_grand_total'] = expectedGrandTotal;
    }
    if (walletAccount != null) {
      payload['wallet_account'] = walletAccount;
    }
    if (receiptImageUrl != null && receiptImageUrl.isNotEmpty) {
      payload['receipt_image_url'] = receiptImageUrl;
    }
    if (notes != null && notes.isNotEmpty) {
      payload['notes'] = notes;
    }

    final response = await _api.post<dynamic>(
      ApiEndpoints.orders,
      data: payload,
      options: Options(
        headers: <String, dynamic>{
          'X-Idempotency-Key': key,
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

    throw const FormatException('Invalid server response for order creation');
  }

  @override
  Future<OrderModel> cancelOrder(String orderId) async {
    if (AppEnv.enableMockData) {
      return _fallback.cancelOrder(orderId);
    }

    final response =
        await _api.post<dynamic>(ApiEndpoints.cancelOrder(orderId));
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final orderJson = data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data;
      return OrderModel.fromJson(orderJson);
    }

    throw const FormatException('Invalid server response for order cancellation');
  }

  @override
  Future<void> clearLocalCache() async {
    await _fallback.clearLocalCache();
  }
}
