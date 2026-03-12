import 'package:get/get.dart';

/// هذا الملف مسؤول عن حالات الواجهة الخاصة بشاشة المراجعات.
///
/// حاليًا الشاشة بسيطة ولا تحتوي على تفاعلات كثيرة،
/// لكننا نحافظ على نفس النمط المعماري الموحد في المشروع
/// بحيث تصبح جاهزة لاحقًا لأي توسع مثل:
/// - التحميل
/// - إعادة الجلب
/// - pagination
/// - إضافة مراجعة
class ReviewsUiController extends GetxController {
  /// حالة التحميل الحالية لشاشة المراجعات.
  final isLoading = false.obs;

  /// هذه الدالة تغيّر حالة التحميل الحالية.
  void setLoading(bool value) {
    isLoading.value = value;
  }
}