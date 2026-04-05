import 'package:get/get.dart';
import 'package:rwnaqk/controllers/forgot_password/forgot_password_service.dart';
import 'package:rwnaqk/controllers/forgot_password/forgot_password_ui_controller.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';

/// هذا الملف هو الكنترولر الرئيسي لمنظومة استعادة كلمة المرور.
///
/// نستخدمه لإدارة:
/// - تحديد الهدف الحالي للإرسال
/// - الانتقال بين خطوات الاستعادة
/// - التحقق من OTP
/// - حفظ كلمة المرور الجديدة
///
/// كما أنه يعمل كحلقة ربط بين:
/// - ForgotPasswordUiController الخاص بحالات الواجهة
/// - ForgotPasswordService الخاص بالمنطق المساعد
class ForgotPasswordController extends GetxController {
  ForgotPasswordController(this._service);

  final ForgotPasswordService _service;

  late final ForgotPasswordUiController ui;

  /// الهدف الحقيقي الحالي الذي سيتم إرسال الرمز إليه.
  final target = ''.obs;

  /// الهدف الحالي بعد إخفائه للعرض في الواجهة.
  final maskedTarget = ''.obs;

  // =========================
  // UI BRIDGES
  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  Rx<RecoveryMethod> get method => ui.method;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  RxString get otp => ui.otp;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  RxBool get canResend => ui.canResend;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  RxInt get resendSeconds => ui.resendSeconds;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  get formKey => ui.formKey;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  get passwordController => ui.passwordController;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  get confirmController => ui.confirmController;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  RxBool get isLoading => ui.isLoading;

  @override
  /// هذه الدالة تُستدعى عند إنشاء الكنترولر لأول مرة.
  /// نستخدمها لتهيئة الـ UI controller.
  void onInit() {
    super.onInit();
    ui = Get.find<ForgotPasswordUiController>();
  }

  /// هذه الدالة تغيّر وسيلة استعادة كلمة المرور الحالية.
  void selectMethod(RecoveryMethod value) {
    ui.selectMethod(value);
  }

  /// هذه الدالة تنتقل من شاشة اختيار الوسيلة إلى شاشة التحقق.
  ///
  /// عند التنفيذ:
  /// - نحدد الهدف الحقيقي
  /// - نبني النص المخفي المناسب
  /// - نبدأ مؤقت إعادة الإرسال
  /// - ننتقل إلى شاشة OTP
  void goNextFromMethod() {
    final resolvedTarget = _service.resolveTarget(method.value);

    target.value = resolvedTarget;
    maskedTarget.value = _service.resolveMaskedTarget(
      method: method.value,
      target: resolvedTarget,
    );

    ui.startResendTimer();

    Get.toNamed(AppRoutes.otp);
    Get.snackbar(Tk.commonOk.tr, Tk.fpVerifySent.tr);
  }

  /// هذه الدالة تحدّث رمز التحقق الحالي.
  void setOtp(String value) {
    ui.setOtp(value);
  }

  /// هذه الدالة تتحقق من صحة رمز التحقق الحالي.
  ///
  /// إذا كان صحيحًا ننتقل إلى شاشة إعادة تعيين كلمة المرور.
  void verifyOtp() {
    if (!_service.isValidOtp(otp.value)) {
      Get.snackbar(Tk.commonError.tr, Tk.fpVerifyInvalid.tr);
      return;
    }

    Get.toNamed(AppRoutes.reset);
  }

  /// هذه الدالة تعيد إرسال رمز التحقق إذا أصبح مسموحًا بذلك.
  void resendCode() {
    if (!canResend.value) return;

    ui.startResendTimer();
    Get.snackbar(Tk.commonOk.tr, Tk.fpVerifySent.tr);
  }

  /// هذه الدالة تحفظ كلمة المرور الجديدة بعد التحقق من صحة البيانات.
  ///
  /// حاليًا:
  /// - نتحقق من صحة الفورم
  /// - نتحقق من تطابق كلمة المرور
  /// - نعرض نجاحًا تجريبيًا
  /// - ثم نعيد المستخدم إلى شاشة الدخول
  ///
  /// لاحقًا يتم استبدال هذا السلوك باستدعاء API حقيقي.
  Future<void> saveNewPassword() async {
    final isValid = formKey.currentState?.validate() ?? false;
    final p1 = passwordController.text;
    final p2 = confirmController.text;

    if (!_service.canSaveNewPassword(
      isFormValid: isValid,
      password: p1,
      confirmPassword: p2,
    )) {
      if (isValid && p1 != p2) {
        Get.snackbar(Tk.commonError.tr, Tk.fpNewMismatch.tr);
      }
      return;
    }

    ui.setLoading(true);

    try {
      await Future.delayed(const Duration(milliseconds: 600));

      Get.snackbar(Tk.commonOk.tr, Tk.fpDone.tr);
      Get.offAllNamed(AppRoutes.login);
    } finally {
      ui.setLoading(false);
    }
  }

  /// هذه الدالة تعيد المستخدم إلى الشاشة السابقة.
  void cancel() {
    Get.back();
  }

  @override
  /// هذه الدالة تُستدعى عند التخلص من الكنترولر.
  /// نستخدمها لإيقاف المؤقت الحالي إن وجد.
  void onClose() {
    ui.stopTimer();
    super.onClose();
  }
}
