import 'package:get/get.dart';
import 'package:rwnaqk/controllers/login/login_service.dart';
import 'package:rwnaqk/controllers/login/login_ui_controller.dart';
import 'package:rwnaqk/core/routes/app_route_args.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/core/utils/app_notifier.dart';

/// هذا الملف هو الكنترولر الرئيسي لشاشة تسجيل الدخول.
///
/// نستخدمه لإدارة:
/// - تنفيذ تسجيل الدخول
/// - تسجيل الدخول الاجتماعي
/// - التنقل إلى شاشة إنشاء الحساب
/// - التنقل إلى شاشة استعادة كلمة المرور
///
/// كما أنه يعمل كحلقة ربط بين:
/// - LoginUiController الخاص بحقول الواجهة
/// - LoginService الخاص بالمنطق المساعد
class LoginController extends GetxController {
  LoginController(this._service);

  final LoginService _service;
  final isLoading = false.obs;

  late final LoginUiController ui;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  get formKey => ui.formKey;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  get emailController => ui.emailController;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  get passwordController => ui.passwordController;

  @override
  /// هذه الدالة تُستدعى عند إنشاء الكنترولر لأول مرة.
  /// نستخدمها لتهيئة الـ UI controller.
  void onInit() {
    super.onInit();
    ui = Get.find<LoginUiController>();
  }

  /// هذه الدالة تنفذ عملية تسجيل الدخول الحالية.
  ///
  /// حاليًا:
  /// - تتحقق من صحة الفورم
  /// - ثم تنقل المستخدم مباشرة إلى الصفحة الرئيسية
  ///
  /// لاحقًا يتم استبدال هذا السلوك باستدعاء API حقيقي.
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

  /// هذه الدالة تمثل تسجيل الدخول عبر Google.
  ///
  /// حاليًا هي mock فقط، ولاحقًا تُربط بـ Google Sign-In الحقيقي.
  void loginWithGoogle() {
    Get.snackbar(Tk.commonSocial.tr, Tk.loginWithGoogle.tr);
  }

  /// هذه الدالة تمثل تسجيل الدخول عبر Apple.
  ///
  /// حاليًا هي mock فقط، ولاحقًا تُربط بالتكامل الحقيقي.
  void loginWithApple() {
    Get.snackbar(Tk.commonSocial.tr, Tk.loginWithApple.tr);
  }

  /// هذه الدالة تمثل تسجيل الدخول عبر Facebook.
  ///
  /// حاليًا هي mock فقط، ولاحقًا تُربط بالتكامل الحقيقي.
  void loginWithFacebook() {
    Get.snackbar(Tk.commonSocial.tr, Tk.loginWithFacebook.tr);
  }

  /// هذه الدالة تنقل المستخدم إلى شاشة استعادة كلمة المرور.
  void goToForgotPassword() {
    Get.toNamed(
      AppRoutes.forgot,
      arguments: <String, dynamic>{
        AppRouteArgs.target: emailController.text.trim(),
      },
    );
  }

  /// هذه الدالة تنقل المستخدم إلى شاشة إنشاء حساب جديد.
  void goToRegister() {
    Get.toNamed(AppRoutes.register);
  }
}
