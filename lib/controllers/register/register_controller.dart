import 'package:get/get.dart';
import 'package:rwnaqk/controllers/register/register_service.dart';
import 'package:rwnaqk/controllers/register/register_ui_controller.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/core/utils/app_notifier.dart';

/// هذا الملف هو الكنترولر الرئيسي لشاشة إنشاء الحساب.
///
/// نستخدمه لإدارة:
/// - تنفيذ عملية التسجيل
/// - التحقق النهائي قبل الإرسال
/// - التنقل إلى شاشة تسجيل الدخول
///
/// كما أنه يعمل كحلقة ربط بين:
/// - RegisterUiController الخاص بحقول الواجهة
/// - RegisterService الخاص بالمنطق المساعد
class RegisterController extends GetxController {
  RegisterController(this._service);

  final RegisterService _service;
  final isLoading = false.obs;

  late final RegisterUiController ui;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  get formKey => ui.formKey;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  get firstNameController => ui.firstNameController;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  get lastNameController => ui.lastNameController;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  get phoneController => ui.phoneController;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  get emailController => ui.emailController;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  get passwordController => ui.passwordController;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  get confirmPasswordController => ui.confirmPasswordController;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  RxnString get governorate => ui.governorate;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  RxBool get agreed => ui.agreed;

  /// هذا getter يعيد قائمة المحافظات من الخدمة.
  List<String> get governorates => _service.governorates;

  @override
  /// هذه الدالة تُستدعى عند إنشاء الكنترولر لأول مرة.
  /// نستخدمها لتهيئة الـ UI controller.
  void onInit() {
    super.onInit();
    ui = Get.find<RegisterUiController>();
     _loadGovernorates();
  }

  /// هذه الدالة تبدّل حالة الموافقة على الشروط.
  void toggleAgreed() {
    ui.toggleAgreed();
  }

  Future<void> _loadGovernorates() async {
    try {
      await _service.loadGovernorates();

      if (governorate.value == null || governorate.value!.trim().isEmpty) {
        governorate.value = _service.defaultGovernorate();
      }
    } catch (_) {
      if (governorate.value == null || governorate.value!.trim().isEmpty) {
        governorate.value = _service.defaultGovernorate();
      }
    }
  }

  /// هذه الدالة تنفذ عملية إنشاء الحساب الحالية.
  ///
  /// حاليًا:
  /// - تتحقق من صحة الفورم
  /// - تتحقق من اختيار المحافظة
  /// - تتحقق من الموافقة على الشروط
  /// - ثم تعرض رسالة نجاح تجريبية
  ///
  /// لاحقًا يتم استبدال هذا السلوك باستدعاء API حقيقي.
  Future<void> register() async {
    final isValid = formKey.currentState?.validate() ?? false;

    final canContinue = _service.canRegister(
      isFormValid: isValid,
      governorate: governorate.value,
      password: passwordController.text,
      passwordConfirmation: confirmPasswordController.text,
      agreed: agreed.value,
    );

    if (!isValid) return;

    if (governorate.value == null || governorate.value!.trim().isEmpty) {
      AppNotifier.error(Tk.registerGovernorateRequired);
      return;
    }

    if (!agreed.value) {
      AppNotifier.error(Tk.registerTermsRequired);
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      AppNotifier.error(Tk.registerPasswordMismatch);
      return;
    }

    if (!canContinue || isLoading.value) return;

    isLoading.value = true;

    try {
      final result = await _service.register(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        phone: phoneController.text,
        email: emailController.text,
        country: _service.defaultCountryName(),
        governorate: governorate.value!.trim(),
        password: passwordController.text,
        passwordConfirmation: confirmPasswordController.text,
        termsAccepted: agreed.value,
        privacyPolicyAccepted: agreed.value,
      );

      AppNotifier.success(Tk.registerSuccess);

      if (result.requiresEmailVerification) {
        AppNotifier.success(Tk.registerVerifyEmailHint);
        Get.offAllNamed(
          AppRoutes.emailVerify,
          arguments: <String, dynamic>{
            'email': emailController.text.trim(),
          },
        );
        return;
      }

      Get.offAllNamed(AppRoutes.main);
    } catch (error) {
      AppNotifier.errorFrom(error);
    } finally {
      isLoading.value = false;
    }
  }

  /// هذه الدالة تنقل المستخدم إلى شاشة تسجيل الدخول.
  void goToLogin() {
    Get.back();
  }
}
