import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_env.dart';
import 'package:rwnaqk_frontend/core/widgets/feedback/app_toast.dart';
import 'package:rwnaqk_frontend/modules/home/controllers/main_controller.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_service.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_details_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/providers/fake_orders_repository.dart';
import 'package:rwnaqk_frontend/modules/orders/data/repositories/orders_repository.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

/// هذا الملف هو الكنترولر الرئيسي لمنظومة الطلبات.
///
/// نستخدمه لإدارة:
/// - قائمة الطلبات
/// - الطلبات المعروضة حسب الفلتر
/// - منطق شاشة تتبع الطلب
///
/// كما أنه يعمل كحلقة ربط بين:
/// - OrdersUiController الخاص بحالة الواجهة
/// - IOrdersRepository / OrdersService الخاص بالبيانات والتجهيزات
class OrdersController extends GetxController {
  OrdersController(this._service, {IOrdersRepository? repository})
      : _repository = repository ?? FakeOrdersRepository(service: _service);

  final OrdersService _service;
  final IOrdersRepository _repository;

  /// وصول مباشر للمستودع المعتمد
  IOrdersRepository get repository => _repository;

  late final OrdersUiController ui;

  /// قائمة الطلبات الحالية.
  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  Rx<OrdersFilter> get filter => ui.filter;

  @override
  /// هذه الدالة تُستدعى عند إنشاء الكنترولر لأول مرة.
  /// نستخدمها لتهيئة الـ UI controller وتحميل البيانات التجريبية أو الحقيقية.
  void onInit() {
    super.onInit();

    ui = Get.find<OrdersUiController>();
    if (AppEnv.enableMockData) {
      seedMockData();
    } else {
      loadOrders();
    }
  }

  /// هذه الدالة تغيّر الفلتر الحالي.
  void setFilter(OrdersFilter value) {
    ui.setFilter(value);
  }

  /// هذه الدالة تضيف طلبًا جديدًا في أعلى القائمة.
  void addOrder(OrderModel order) {
    orders.insert(0, order);
    _repository.createOrder(order);
    ui.setFilter(OrdersFilter.all);
  }

  /// هذه الدالة تعيد الطلبات بعد تطبيق الفلتر الحالي.
  List<OrderModel> get filteredOrders {
    return _service.filterOrders(orders: orders, filter: filter.value);
  }

  /// هذه الدالة تبني خطوات تتبع الطلب حسب حالته الحالية.
  List<OrderStatusStep> buildTrackingSteps(OrderModel order) {
    return _service.buildTrackingSteps(order);
  }

  OrderDetailsModel buildOrderDetails(OrderModel order) {
    return _service.buildOrderDetails(order);
  }

  /// الانتقال إلى الصفحة الرئيسية للتسوق
  void goToHome() {
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().changeTab(0);
    } else {
      Get.offAllNamed(AppRoutes.main);
    }
  }

  /// فتح السلة
  void openCart() {
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().changeTab(3);
    } else {
      Get.toNamed(AppRoutes.cart);
    }
  }

  /// هذه الدالة تفرغ قائمة الطلبات الحالية والكاش المحلي لعزل الجلسة.
  void clearOrders() {
    orders.clear();
    _repository.clearLocalCache();
  }

  /// هذه الدالة تهيئ البيانات التجريبية الحالية للطلبات.
  void seedMockData() {
    orders.assignAll(_service.seedMockOrders());
  }

  /// تحميل الطلبات من المستودع بطريقة غير متزامنة مع حماية الكنترولر المنتهي.
  Future<void> loadOrders({bool refresh = false}) async {
    if (AppEnv.enableMockData) {
      if (orders.isEmpty || refresh) {
        seedMockData();
      }
      return;
    }

    try {
      isLoading.value = true;
      final list = await _repository.getOrders();
      if (!isClosed) {
        orders.assignAll(list);
      }
    } catch (e) {
      debugPrint('[OrdersController.loadOrders] error: $e');
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  /// إلغاء الطلب من قبل العميل وتحديث حالته فورياً في القائمة
  Future<bool> cancelOrder(String orderId) async {
    try {
      isLoading.value = true;
      final updatedOrder = await _repository.cancelOrder(orderId);
      final index = orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        orders[index] = updatedOrder;
        orders.refresh();
      }
      AppToast.success('تم إلغاء الطلب بنجاح واستعادة المخزون.');
      return true;
    } catch (e) {
      final msg = e is DioException && e.response?.data is Map
          ? (e.response!.data['message']?.toString() ?? e.toString())
          : e.toString();
      AppToast.error(msg, title: 'تعذر إلغاء الطلب');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
