import 'package:get/get.dart';
import 'package:rwnaqk/controllers/register/register_service.dart';
import 'package:rwnaqk/controllers/register/register_ui_controller.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';

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
  }

  /// هذه الدالة تبدّل حالة الموافقة على الشروط.
  void toggleAgreed() {
    ui.toggleAgreed();
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
  void register() {
    final isValid = formKey.currentState?.validate() ?? false;

    final canContinue = _service.canRegister(
      isFormValid: isValid,
      governorate: governorate.value,
      agreed: agreed.value,
    );

    if (!isValid) return;

    if (governorate.value == null || governorate.value!.trim().isEmpty) {
      Get.snackbar(Tk.registerTitle.tr, Tk.registerGovernorateRequired.tr);
      return;
    }

    if (!agreed.value) {
      Get.snackbar(Tk.registerTitle.tr, Tk.registerTermsRequired.tr);
      return;
    }

    if (!canContinue) return;

    Get.snackbar(Tk.commonOk.tr, Tk.registerSubmit.tr);
  }

  /// هذه الدالة تنقل المستخدم إلى شاشة تسجيل الدخول.
  void goToLogin() {
    Get.back();
  }
}
