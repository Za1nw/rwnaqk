import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/login_service.dart';
import 'package:rwnaqk_frontend/routes/app_route_args.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_notifier.dart';

/// الكنترولر الرئيسي لشاشة تسجيل الدخول.
class LoginController extends GetxController {
  LoginController(this._service);

  final LoginService _service;
  final isLoading = false.obs;

  /// مفتاح الفورم ومتحكمات الحقول
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  /// للتوافق مع أي استدعاءات سابقة لـ ui
  LoginController get ui => this;

  /// تنفيذ عملية تسجيل الدخول
  Future<void> login() async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid || isLoading.value) {
      return;
    }

    isLoading.value = true;

    try {
      final email = emailController.text.trim();
      final password = passwordController.text;

      final result = await _service.login(email: email, password: password);

      if (result.requiresTwoFactor) {
        Get.toNamed(
          AppRoutes.twoFactorChallenge,
          arguments: <String, dynamic>{
            AppRouteArgs.loginEmail: email,
            AppRouteArgs.loginPassword: password,
            AppRouteArgs.target: email,
          },
        );
        return;
      }

      if (result.requiresEmailVerification) {
        AppNotifier.success(Tk.loginVerifyEmailHint);
        Get.offAllNamed(
          AppRoutes.emailVerify,
          arguments: <String, dynamic>{'email': email},
        );
        return;
      } else {
        AppNotifier.success(Tk.loginSuccess);
      }

      Get.offAllNamed(AppRoutes.main);
    } catch (error) {
      AppNotifier.errorFrom(error);
    } finally {
      isLoading.value = false;
    }
  }

  /// تسجيل الدخول عبر Google (Mock)
  void loginWithGoogle() {
    AppNotifier.info(Tk.loginWithGoogle.tr, isKey: false, title: Tk.commonSocial.tr);
  }

  /// تسجيل الدخول عبر Apple (Mock)
  void loginWithApple() {
    AppNotifier.info(Tk.loginWithApple.tr, isKey: false, title: Tk.commonSocial.tr);
  }

  /// تسجيل الدخول عبر Facebook (Mock)
  void loginWithFacebook() {
    AppNotifier.info(Tk.loginWithFacebook.tr, isKey: false, title: Tk.commonSocial.tr);
  }

  /// الانتقال إلى شاشة استعادة كلمة المرور
  void goToForgotPassword() {
    Get.toNamed(
      AppRoutes.forgot,
      arguments: <String, dynamic>{
        AppRouteArgs.target: emailController.text.trim(),
      },
    );
  }

  /// الانتقال إلى شاشة إنشاء حساب جديد
  void goToRegister() {
    Get.toNamed(AppRoutes.register);
  }

  /// تجاوز شاشة تسجيل الدخول والمتابعة كزائر (وضع التصميم)
  void continueAsGuest() {
    if (Get.isRegistered<AuthSessionService>()) {
      Get.find<AuthSessionService>().enterGuestMode();
    }
    Get.offAllNamed(AppRoutes.main);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
