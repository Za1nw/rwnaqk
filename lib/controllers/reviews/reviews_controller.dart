import 'package:get/get.dart';
import 'package:rwnaqk/controllers/reviews/reviews_service.dart';
import 'package:rwnaqk/controllers/reviews/reviews_ui_controller.dart';
import 'package:rwnaqk/models/product_review.dart';

/// هذا الملف هو الكنترولر الرئيسي لشاشة المراجعات.
///
/// نستخدمه لإدارة:
/// - قائمة المراجعات الحالية
/// - تحميل البيانات القادمة من route arguments
///
/// كما أنه يعمل كحلقة ربط بين:
/// - ReviewsUiController الخاص بحالة الواجهة
/// - ReviewsService الخاص بتحليل البيانات والتجهيزات
class ReviewsController extends GetxController {
  ReviewsController(this._service);

  final ReviewsService _service;

  late final ReviewsUiController ui;

  /// قائمة المراجعات الحالية المعروضة في الشاشة.
  final reviews = <ProductReview>[].obs;

  /// هذا bridge للإبقاء على نفس أسلوب الوصول من الشاشة.
  RxBool get isLoading => ui.isLoading;

  @override
  /// هذه الدالة تُستدعى عند إنشاء الكنترولر لأول مرة.
  ///
  /// نستخدمها لتهيئة الـ UI controller ثم تحميل المراجعات
  /// القادمة من route arguments أو استخدام بيانات افتراضية.
  void onInit() {
    super.onInit();

    ui = Get.find<ReviewsUiController>();
    loadReviews(Get.arguments);
  }

  /// هذه الدالة تقوم بتحميل المراجعات وتحويلها إلى صيغة موحدة.
  void loadReviews(dynamic args) {
    ui.setLoading(true);

    try {
      reviews.assignAll(_service.resolveReviews(args));
    } finally {
      ui.setLoading(false);
    }
  }
}