import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/forgot_password/forgot_password_service.dart';

/// هذا الملف مسؤول عن حالات الواجهة الخاصة بمنظومة استعادة كلمة المرور.
///
/// نستخدمه لعزل:
/// - طريقة الاستعادة الحالية
/// - رمز التحقق
/// - حالة إعادة الإرسال
/// - حقول كلمة المرور الجديدة
/// - حالة التحميل
///
/// الهدف أن يبقى الكنترولر الرئيسي مسؤولًا عن التنقل والمنطق العام،
/// بينما تبقى تفاصيل الواجهة والتفاعل المحلي هنا.
class ForgotPasswordUiController extends GetxController {
  /// طريقة الاستعادة المختارة حاليًا.
  final method = RecoveryMethod.sms.obs;

  /// رمز التحقق الحالي.
  final otp = ''.obs;

  /// هل أصبح مسموحًا بإعادة إرسال الرمز؟
  final canResend = false.obs;

  /// عدد الثواني المتبقية قبل السماح بإعادة الإرسال.
  final resendSeconds = 30.obs;

  /// مفتاح فورم تعيين كلمة المرور الجديدة.
  final formKey = GlobalKey<FormState>();

  /// متحكم حقل كلمة المرور الجديدة.
  final passwordController = TextEditingController();

  /// متحكم حقل تأكيد كلمة المرور.
  final confirmController = TextEditingController();

  /// حالة التحميل الحالية.
  final isLoading = false.obs;

  Timer? _timer;

  /// هذه الدالة تغيّر طريقة الاستعادة الحالية.
  void selectMethod(RecoveryMethod value) {
    method.value = value;
  }

  /// هذه الدالة تحدّث رمز التحقق الحالي.
  void setOtp(String value) {
    otp.value = value;
  }

  /// هذه الدالة تغيّر حالة التحميل الحالية.
  void setLoading(bool value) {
    isLoading.value = value;
  }

  /// هذه الدالة تبدأ مؤقت إعادة الإرسال من جديد.
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

  /// هذه الدالة توقف المؤقت الحالي إذا كان يعمل.
  void stopTimer() {
    _timer?.cancel();
  }

  @override
  /// هذه الدالة تُستدعى عند التخلص من الكنترولر.
  /// نستخدمها لتحرير المؤقت ومتحكمات الحقول.
  void onClose() {
    _timer?.cancel();
    passwordController.dispose();
    confirmController.dispose();
    super.onClose();
  }
}