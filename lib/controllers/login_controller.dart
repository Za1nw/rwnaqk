import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';

class LoginController extends GetxController {
  // مفتاح الفورم للتحقق من صحة الحقول (Validation)
  final formKey = GlobalKey<FormState>();

  // Controllers لحقول الإدخال
  // تستخدم لقراءة النصوص والتحكم بها
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // ===============================
  // تنفيذ تسجيل الدخول
  // ===============================
  void login() {
    // نتحقق أولاً من أن جميع الحقول صالحة
    // إذا فشل التحقق نوقف التنفيذ مباشرة
    if (!(formKey.currentState?.validate() ?? false)) return;

    // حالياً مجرد Snackbar كتجربة للواجهة
    // في مرحلة لاحقة يتم استبداله باستدعاء API
    Get.offAllNamed(AppRoutes.home);
  }

  // ===============================
  // تسجيل الدخول عبر Google
  // ===============================
  void loginWithGoogle() {
    Get.snackbar('Social', 'login.with_google'.tr);
  }

  // ===============================
  // تسجيل الدخول عبر Apple
  // ===============================
  void loginWithApple() {
    Get.snackbar('Social', 'login.with_apple'.tr);
  }

  // ===============================
  // تسجيل الدخول عبر Facebook
  // ===============================
  void loginWithFacebook() {
    Get.snackbar('Social', 'login.with_facebook'.tr);
  }

  // ===============================
  // الانتقال إلى صفحة استعادة كلمة المرور
  // ===============================
  void goToForgotPassword() {
    Get.toNamed(AppRoutes.forgot);
  }

  // ===============================
  // الانتقال إلى صفحة إنشاء حساب
  // ===============================
  void goToRegister() {
    Get.toNamed(AppRoutes.register);
  }

  // ===============================
  // تنظيف الموارد عند إغلاق الكنترولر
  // ===============================
  @override
  void onClose() {
    // مهم جداً لتجنب تسريب الذاكرة (Memory Leak)
    emailController.dispose();
    passwordController.dispose();

    super.onClose();
  }
}
