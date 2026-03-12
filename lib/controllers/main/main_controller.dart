import 'package:get/get.dart';
import 'package:rwnaqk/controllers/main/main_service.dart';
import 'package:rwnaqk/controllers/main/main_ui_controller.dart';

/// هذا الملف هو الكنترولر الرئيسي للشاشة الرئيسية.
///
/// نستخدمه لإدارة:
/// - التنقل بين التبويبات الرئيسية
/// - تقديم حالة التبويب الحالي إلى MainScreen
///
/// كما أنه يعمل كحلقة ربط بين:
/// - MainUiController الخاص بحالة الواجهة
/// - MainService الخاص بالمنطق المساعد
class MainController extends GetxController {
  MainController(this._service);

  final MainService _service;

  late final MainUiController ui;

  /// عدد التبويبات الحالية داخل الشاشة الرئيسية.
  ///
  /// هذا الرقم مطابق للصفحات الموجودة داخل MainScreen حاليًا.
  static const int tabsCount = 5;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  RxInt get currentIndex => ui.currentIndex;

  @override
  /// هذه الدالة تُستدعى عند إنشاء الكنترولر لأول مرة.
  /// نستخدمها لتهيئة الـ UI controller.
  void onInit() {
    super.onInit();
    ui = Get.find<MainUiController>();
  }

  /// هذه الدالة تغيّر التبويب الحالي بعد التحقق من صحته.
  void changeTab(int index) {
    final safeIndex = _service.sanitizeTabIndex(
      index: index,
      maxTabs: tabsCount,
    );

    ui.changeTab(safeIndex);
  }
}