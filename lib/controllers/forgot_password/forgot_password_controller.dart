import 'package:get/get.dart';
import 'package:rwnaqk/controllers/forgot_password/forgot_password_service.dart';
import 'package:rwnaqk/core/routes/app_route_args.dart';
import 'package:rwnaqk/controllers/forgot_password/forgot_password_ui_controller.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/core/utils/app_notifier.dart';

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

  final otpFlow = OtpFlow.forgotPassword.obs;
  final loginEmail = ''.obs;
  final loginPassword = ''.obs;

  bool get isTwoFactorFlow => otpFlow.value == OtpFlow.twoFactorLogin;

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
  get targetController => ui.targetController;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  get passwordController => ui.passwordController;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  get confirmController => ui.confirmController;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  get resetTokenController => ui.resetTokenController;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  RxBool get isLoading => ui.isLoading;

  @override
  /// هذه الدالة تُستدعى عند إنشاء الكنترولر لأول مرة.
  /// نستخدمها لتهيئة الـ UI controller.
  void onInit() {
    super.onInit();
    ui = Get.find<ForgotPasswordUiController>();

    final args = Get.arguments;
    if (args is Map) {
      final flowName = args[AppRouteArgs.otpFlow]?.toString();
      if (flowName == OtpFlow.twoFactorLogin.name) {
        otpFlow.value = OtpFlow.twoFactorLogin;
      }

      final initialTarget = args[AppRouteArgs.target]?.toString() ?? '';
      targetController.text = initialTarget;

      loginEmail.value = args[AppRouteArgs.loginEmail]?.toString() ?? '';
      loginPassword.value = args[AppRouteArgs.loginPassword]?.toString() ?? '';

      if (otpFlow.value == OtpFlow.twoFactorLogin &&
          loginEmail.value.isNotEmpty) {
        target.value = loginEmail.value;
        maskedTarget.value = _service.resolveMaskedTarget(
          method: RecoveryMethod.email,
          target: loginEmail.value,
        );
      }
    }
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
  Future<void> goNextFromMethod() async {
    if (isLoading.value) {
      return;
    }

    if (method.value == RecoveryMethod.sms) {
      AppNotifier.error(Tk.fpSmsNotAvailable);
      return;
    }

    final email = targetController.text.trim();
    if (!GetUtils.isEmail(email)) {
      AppNotifier.error(Tk.loginEmailInvalid);
      return;
    }

    ui.setLoading(true);
    try {
      await _service.sendPasswordResetLink(email: email);

      target.value = email;
      maskedTarget.value = _service.resolveMaskedTarget(
        method: RecoveryMethod.email,
        target: email,
      );

      AppNotifier.success(Tk.fpVerifySent);
      Get.offAllNamed(AppRoutes.login);
    } catch (error) {
      AppNotifier.errorFrom(error);
    } finally {
      ui.setLoading(false);
    }
  }

  /// هذه الدالة تحدّث رمز التحقق الحالي.
  void setOtp(String value) {
    ui.setOtp(value);
  }

  /// هذه الدالة تتحقق من صحة رمز التحقق الحالي.
  ///
  /// إذا كان صحيحًا ننتقل إلى شاشة إعادة تعيين كلمة المرور.
  Future<void> verifyOtp() async {
    if (!_service.isValidOtp(otp.value)) {
      AppNotifier.error(Tk.fpVerifyInvalid);
      return;
    }

    if (otpFlow.value == OtpFlow.twoFactorLogin) {
      ui.setLoading(true);
      try {
        final result = await _service.verifyTwoFactorLogin(
          email: loginEmail.value,
          password: loginPassword.value,
          code: otp.value,
        );

        AppNotifier.success(Tk.loginSuccess);

        if (result.requiresEmailVerification) {
          Get.offAllNamed(
            AppRoutes.emailVerify,
            arguments: <String, dynamic>{'email': loginEmail.value},
          );
        } else {
          Get.offAllNamed(AppRoutes.main);
        }
      } catch (error) {
        AppNotifier.errorFrom(error);
      } finally {
        ui.setLoading(false);
      }

      return;
    }

    Get.toNamed(AppRoutes.reset);
  }

  /// هذه الدالة تعيد إرسال رمز التحقق إذا أصبح مسموحًا بذلك.
  void resendCode() {
    if (otpFlow.value == OtpFlow.twoFactorLogin) {
      AppNotifier.error(Tk.fpUseAuthenticator);
      return;
    }

    if (!canResend.value) return;

    ui.startResendTimer();
    AppNotifier.success(Tk.fpVerifySent);
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
        AppNotifier.error(Tk.fpNewMismatch);
      }
      return;
    }

    final email = targetController.text.trim();
    final token = resetTokenController.text.trim();

    if (!GetUtils.isEmail(email)) {
      AppNotifier.error(Tk.loginEmailInvalid);
      return;
    }

    if (token.isEmpty) {
      AppNotifier.error(Tk.fpResetTokenRequired);
      return;
    }

    ui.setLoading(true);

    try {
      await _service.resetPassword(token: token, email: email, password: p1);

      AppNotifier.success(Tk.fpDone);
      Get.offAllNamed(AppRoutes.login);
    } catch (error) {
      AppNotifier.errorFrom(error);
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
