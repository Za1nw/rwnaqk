import 'package:get/get.dart';
import 'package:rwnaqk/controllers/orders/orders_service.dart';
import 'package:rwnaqk/controllers/orders/orders_ui_controller.dart';
import 'package:rwnaqk/models/order_model.dart';

/// هذا الملف هو الكنترولر الرئيسي لمنظومة الطلبات.
///
/// نستخدمه لإدارة:
/// - قائمة الطلبات
/// - الطلبات المعروضة حسب الفلتر
/// - منطق شاشة تتبع الطلب
///
/// كما أنه يعمل كحلقة ربط بين:
/// - OrdersUiController الخاص بحالة الواجهة
/// - OrdersService الخاص بالبيانات والتجهيزات
class OrdersController extends GetxController {
  OrdersController(this._service);

  final OrdersService _service;

  late final OrdersUiController ui;

  /// قائمة الطلبات الحالية.
  final orders = <OrderModel>[].obs;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  Rx<OrdersFilter> get filter => ui.filter;

  @override
  /// هذه الدالة تُستدعى عند إنشاء الكنترولر لأول مرة.
  /// نستخدمها لتهيئة الـ UI controller وتحميل البيانات التجريبية.
  void onInit() {
    super.onInit();

    ui = Get.find<OrdersUiController>();
    seedMockData();
  }

  /// هذه الدالة تغيّر الفلتر الحالي.
  void setFilter(OrdersFilter value) {
    ui.setFilter(value);
  }

  /// هذه الدالة تعيد الطلبات بعد تطبيق الفلتر الحالي.
  List<OrderModel> get filteredOrders {
    return _service.filterOrders(
      orders: orders,
      filter: filter.value,
    );
  }

  /// هذه الدالة تبني خطوات تتبع الطلب حسب حالته الحالية.
  List<OrderStatusStep> buildTrackingSteps(OrderModel order) {
    return _service.buildTrackingSteps(order);
  }

  /// هذه الدالة تهيئ البيانات التجريبية الحالية للطلبات.
  void seedMockData() {
    orders.assignAll(_service.seedMockOrders());
  }
}