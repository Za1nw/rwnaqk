import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/utils/app_mask_utils.dart';

enum RecoveryMethod { sms, email }

class ForgotPasswordController extends GetxController {
  final method = RecoveryMethod.sms.obs;

  final target = ''.obs;
  final maskedTarget = ''.obs;

  final otp = ''.obs;

  final canResend = false.obs;
  final resendSeconds = 30.obs;

  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  final isLoading = false.obs;

  Timer? _timer;

  void selectMethod(RecoveryMethod m) => method.value = m;

  void goNextFromMethod() {
    if (method.value == RecoveryMethod.sms) {
      target.value = '+967777777777';
      maskedTarget.value = AppMaskUtils.maskPhone(target.value);
    } else {
      target.value = 'name@example.com';
      maskedTarget.value = AppMaskUtils.maskEmail(target.value);
    }

    _startResendTimer();
    Get.toNamed(AppRoutes.otp);
    Get.snackbar('OK', 'fp.verify.sent'.tr);
  }

  void setOtp(String v) {
    otp.value = v;
  }

  void verifyOtp() {
    if (otp.value.length != 4) {
      Get.snackbar('Error', 'fp.verify.invalid'.tr);
      return;
    }

    Get.toNamed(AppRoutes.reset);
  }

  void resendCode() {
    if (!canResend.value) return;

    _startResendTimer();
    Get.snackbar('OK', 'fp.verify.sent'.tr);
  }

  void _startResendTimer() {
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

  Future<void> saveNewPassword() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final p1 = passwordController.text;
    final p2 = confirmController.text;

    if (p1 != p2) {
      Get.snackbar('Error', 'fp.new.mismatch'.tr);
      return;
    }

    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 600));

      Get.snackbar('OK', 'fp.done'.tr);
      Get.offAllNamed(AppRoutes.login);
    } finally {
      isLoading.value = false;
    }
  }

  void cancel() => Get.back();

 
  @override
  void onClose() {
    _timer?.cancel();
    passwordController.dispose();
    confirmController.dispose();
    super.onClose();
  }
}
