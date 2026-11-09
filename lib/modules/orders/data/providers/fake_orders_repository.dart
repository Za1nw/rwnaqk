import 'package:rwnaqk_frontend/modules/orders/controllers/orders_service.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_details_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/repositories/orders_repository.dart';

/// تطبيق وهمي (Fake) لمستودع الطلبات يعتمد على OrdersService الحالية.
///
/// مستقل عن GetX ويدير الطلبات في الذاكرة حالياً لحين ربط Laravel API.
class FakeOrdersRepository implements IOrdersRepository {
  FakeOrdersRepository({OrdersService? service})
      : _service = service ?? OrdersService();

  final OrdersService _service;
  final List<OrderModel> _inMemoryOrders = [];

  @override
  Future<List<OrderModel>> getOrders() async {
    if (_inMemoryOrders.isEmpty) {
      _inMemoryOrders.addAll(_service.seedMockOrders());
    }
    return List.unmodifiable(_inMemoryOrders);
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    final list = await getOrders();
    for (final order in list) {
      if (order.id == orderId) return order;
    }
    return null;
  }

  @override
  Future<OrderDetailsModel> getOrderDetails(OrderModel order) async {
    return _service.buildOrderDetails(order);
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    _inMemoryOrders.insert(0, order);
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
    final order = OrderModel(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      total: expectedGrandTotal ?? 0,
      itemsCount: items.length,
      status: 'pending',
    );
    _inMemoryOrders.insert(0, order);
    return order;
  }

  @override
  Future<OrderModel> cancelOrder(String orderId) async {
    final index = _inMemoryOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final updated = _inMemoryOrders[index].copyWith(status: 'cancelled');
      _inMemoryOrders[index] = updated;
      return updated;
    }
    throw Exception('Order not found');
  }

  @override
  Future<void> clearLocalCache() async {
    _inMemoryOrders.clear();
  }
}

