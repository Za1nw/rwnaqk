import 'package:rwnaqk_frontend/modules/orders/data/models/order_details_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';

/// عقد المستودع الخاص بالطلبات.
///
/// مستقل تماماً عن GetX وخالٍ من Rx Types.
abstract class IOrdersRepository {
  /// جلب قائمة جميع الطلبات
  Future<List<OrderModel>> getOrders();

  /// جلب تفاصيل طلب محدد بالمعرف
  Future<OrderModel?> getOrderById(String orderId);

  /// جلب أو بناء كائن تفاصيل الطلب
  Future<OrderDetailsModel> getOrderDetails(OrderModel order);

  /// إنشاء طلب جديد وتخزينه
  Future<OrderModel> createOrder(OrderModel order);

  /// إرسال واستكمال طلب الشراء الفعلي عبر Backend API مع منع التكرار
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
  });

  /// إلغاء الطلب المتاح إلغاؤه للعميل واستعادة المخزون ذرياً
  Future<OrderModel> cancelOrder(String orderId);

  /// تفريغ الكاش المحلي المؤقت للطلبات لضمان عزل الجلسة عند تسجيل الخروج
  /// (تنظيف محلي فقط ولا يفرض دلالة حذف دائم على خادم Backend)
  Future<void> clearLocalCache();
}

