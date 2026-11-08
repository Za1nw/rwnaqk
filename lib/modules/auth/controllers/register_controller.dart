import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/register_service.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_notifier.dart';

/// الكنترولر الرئيسي لشاشة إنشاء الحساب.
///
/// يدير حالات حقول الواجهة، والتحقق، والاتصال بخدمة التسجيل والتنقل.
class RegisterController extends GetxController {
  RegisterController(this._service);

  final RegisterService _service;
  final isLoading = false.obs;

  /// مفتاح الفورم للتحقق من صحة المدخلات
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// متحكمات حقول الإدخال
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  /// المحافظة المختارة حالياً
  final governorate = RxnString();

  /// حالة الموافقة على الشروط وسياسة الخصوصية
  final agreed = false.obs;

  /// للتوافق مع أي استدعاءات سابقة لـ ui
  RegisterController get ui => this;

  /// قائمة المحافظات من الخدمة
  List<String> get governorates => _service.governorates;

  @override
  void onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>();
    _loadGovernorates();
  }

  /// تبديل حالة الموافقة على الشروط
  void toggleAgreed() {
    agreed.value = !agreed.value;
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

  /// تنفيذ عملية إنشاء الحساب
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
          arguments: <String, dynamic>{'email': emailController.text.trim()},
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

  /// الانتقال إلى شاشة تسجيل الدخول
  void goToLogin() {
    Get.back();
  }

  /// تجاوز شاشة التسجيل والمتابعة كزائر (وضع التصميم)
  void continueAsGuest() {
    if (Get.isRegistered<AuthSessionService>()) {
      Get.find<AuthSessionService>().enterGuestMode();
    }
    Get.offAllNamed(AppRoutes.main);
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
