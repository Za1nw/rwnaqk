import 'dart:async';

import 'package:get/get.dart';
import 'package:rwnaqk/controllers/flash_sale/flash_sale_service.dart';
import 'package:rwnaqk/controllers/flash_sale/flash_sale_ui_controller.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/models/home_product_item.dart';

/// هذا الملف هو الكنترولر الرئيسي لشاشة العروض السريعة.
///
/// نستخدمه لإدارة:
/// - مؤقت العرض
/// - قائمة المنتجات المعروضة
/// - فتح صفحة المنتج
/// - إعادة تحميل المنتجات عند تغيير نسبة الخصم
///
/// كما أنه يعمل كحلقة ربط بين:
/// - FlashSaleUiController الخاص بحالة الواجهة
/// - FlashSaleService الخاص بالبيانات والتجهيزات
class FlashSaleController extends GetxController {
  FlashSaleController(this._service);

  final FlashSaleService _service;

  late final FlashSaleUiController ui;

  /// الساعات المتبقية في المؤقت.
  final hh = 0.obs;

  /// الدقائق المتبقية في المؤقت.
  final mm = 36.obs;

  /// الثواني المتبقية في المؤقت.
  final ss = 58.obs;

  Timer? _timer;

  /// قائمة منتجات العروض الحالية.
  final flashSaleProducts = <HomeProductItem>[].obs;

  // =========================
  // UI BRIDGES
  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  RxInt get selectedDiscount => ui.selectedDiscount;

  /// هذا getter يعيد نسب الخصومات المتاحة من الخدمة.
  List<int> get discounts => _service.discounts;

  @override
  /// هذه الدالة تُستدعى عند إنشاء الكنترولر لأول مرة.
  /// نستخدمها لتهيئة الـ UI controller وتشغيل المؤقت وتحميل المنتجات.
  void onInit() {
    super.onInit();

    ui = Get.find<FlashSaleUiController>();
    _startFlashTimer();
    _loadFlashSaleProducts();
  }

  /// هذه الدالة تشغل مؤقت العد التنازلي الخاص بالعروض.
  void _startFlashTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      int total = (hh.value * 3600) + (mm.value * 60) + ss.value;

      if (total <= 0) {
        _timer?.cancel();
        return;
      }

      total -= 1;

      hh.value = total ~/ 3600;
      mm.value = (total % 3600) ~/ 60;
      ss.value = total % 60;
    });
  }

  /// هذه الدالة تقوم بتحميل منتجات العروض الحالية
  /// بناءً على نسبة الخصم المختارة من الواجهة.
  void _loadFlashSaleProducts() {
    flashSaleProducts.assignAll(
      _service.loadFlashSaleProducts(
        selectedDiscount: selectedDiscount.value,
      ),
    );
  }

  /// هذه الدالة تغيّر نسبة الخصم الحالية ثم تعيد تحميل المنتجات.
  void selectDiscount(int discount) {
    ui.selectDiscount(discount);
    _loadFlashSaleProducts();
  }

  /// هذه الدالة تفتح صفحة تفاصيل المنتج عند الضغط على أي عنصر.
  void openProduct(HomeProductItem item) {
    final isSale = (item.discountPercent ?? 0) > 0;

    Get.toNamed(
      AppRoutes.product,
      arguments: {
        'item': item,
        'forceSale': isSale,
      },
    );
  }

  @override
  /// هذه الدالة تُستدعى عند التخلص من الكنترولر.
  /// نستخدمها لإيقاف المؤقت.
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}