import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/forgot_password_service.dart';
import 'package:rwnaqk_frontend/routes/app_route_args.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_notifier.dart';

/// الكنترولر الرئيسي لمنظومة استعادة كلمة المرور والتحقق.
class ForgotPasswordController extends GetxController {
  ForgotPasswordController(this._service);

  final ForgotPasswordService _service;

  /// الهدف الحقيقي الحالي الذي سيتم إرسال الرمز إليه
  final target = ''.obs;

  /// الهدف الحالي بعد إخفائه للعرض في الواجهة
  final maskedTarget = ''.obs;

  final otpFlow = OtpFlow.forgotPassword.obs;
  final loginEmail = ''.obs;
  final loginPassword = ''.obs;

  bool get isTwoFactorFlow => otpFlow.value == OtpFlow.twoFactorLogin;

  /// طريقة الاستعادة
  final method = RecoveryMethod.email.obs;

  /// رمز التحقق
  final otp = ''.obs;

  /// حالة إعادة الإرسال
  final canResend = false.obs;
  final resendSeconds = 30.obs;

  /// مفاتيح ومتحكمات الحقول
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final targetController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final resetTokenController = TextEditingController();

  /// حالة التحميل
  final isLoading = false.obs;

  /// مؤقت إعادة الإرسال
  Timer? _timer;

  /// للتوافق مع أي استدعاءات سابقة لـ ui
  ForgotPasswordController get ui => this;

  @override
  void onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>();

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

  void selectMethod(RecoveryMethod value) {
    method.value = value;
  }

  void setOtp(String value) {
    otp.value = value;
  }

  void setLoading(bool value) {
    isLoading.value = value;
  }

  void startResendTimer() {
    _timer?.cancel();
    canResend.value = false;
    resendSeconds.value = 30;

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      resendSeconds.value -= 1;

      if (resendSeconds.value <= 0) {
        t.cancel();
        canResend.value = true;
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  /// الانتقال من شاشة اختيار الوسيلة إلى شاشة التحقق
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

    setLoading(true);
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
      setLoading(false);
    }
  }

  /// التحقق من صحة رمز التحقق
  Future<void> verifyOtp() async {
    if (!_service.isValidOtp(otp.value)) {
      AppNotifier.error(Tk.fpVerifyInvalid);
      return;
    }

    if (otpFlow.value == OtpFlow.twoFactorLogin) {
      setLoading(true);
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
        setLoading(false);
      }

      return;
    }

    Get.toNamed(AppRoutes.reset);
  }

  /// إعادة إرسال رمز التحقق
  void resendCode() {
    if (otpFlow.value == OtpFlow.twoFactorLogin) {
      AppNotifier.error(Tk.fpUseAuthenticator);
      return;
    }

    if (!canResend.value) return;

    startResendTimer();
    AppNotifier.success(Tk.fpVerifySent);
  }

  /// حفظ كلمة المرور الجديدة
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

    setLoading(true);

    try {
      await _service.resetPassword(token: token, email: email, password: p1);

      AppNotifier.success(Tk.fpDone);
      Get.offAllNamed(AppRoutes.login);
    } catch (error) {
      AppNotifier.errorFrom(error);
    } finally {
      setLoading(false);
    }
  }

  void cancel() {
    Get.back();
  }

  @override
  void onClose() {
    stopTimer();
    targetController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    resetTokenController.dispose();
    super.onClose();
  }
}
