import 'package:get/get.dart';
import 'package:rwnaqk/controllers/login/login_service.dart';
import 'package:rwnaqk/controllers/login/login_ui_controller.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';

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
  void login() {
    final isValid = formKey.currentState?.validate() ?? false;

    if (!_service.canLogin(isValid)) return;

    Get.offAllNamed(AppRoutes.home);
  }

  /// هذه الدالة تمثل تسجيل الدخول عبر Google.
  ///
  /// حاليًا هي mock فقط، ولاحقًا تُربط بـ Google Sign-In الحقيقي.
  void loginWithGoogle() {
    Get.snackbar('Social', 'login.with_google'.tr);
  }

  /// هذه الدالة تمثل تسجيل الدخول عبر Apple.
  ///
  /// حاليًا هي mock فقط، ولاحقًا تُربط بالتكامل الحقيقي.
  void loginWithApple() {
    Get.snackbar('Social', 'login.with_apple'.tr);
  }

  /// هذه الدالة تمثل تسجيل الدخول عبر Facebook.
  ///
  /// حاليًا هي mock فقط، ولاحقًا تُربط بالتكامل الحقيقي.
  void loginWithFacebook() {
    Get.snackbar('Social', 'login.with_facebook'.tr);
  }

  /// هذه الدالة تنقل المستخدم إلى شاشة استعادة كلمة المرور.
  void goToForgotPassword() {
    Get.toNamed(AppRoutes.forgot);
  }

  /// هذه الدالة تنقل المستخدم إلى شاشة إنشاء حساب جديد.
  void goToRegister() {
    Get.toNamed(AppRoutes.register);
  }
}