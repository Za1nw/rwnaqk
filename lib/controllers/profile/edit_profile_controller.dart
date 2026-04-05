import 'package:get/get.dart';
import 'package:rwnaqk/controllers/profile/edit_profile_service.dart';
import 'package:rwnaqk/controllers/profile/edit_profile_ui_controller.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';

/// هذا الملف هو الكنترولر الرئيسي لشاشة تعديل الملف الشخصي.
///
/// نستخدمه لإدارة:
/// - تعبئة بيانات الفورم الابتدائية
/// - حفظ التعديلات
/// - الانتقال إلى شاشة تغيير كلمة المرور
/// - تنفيذ اختيار الصورة لاحقًا
///
/// كما أنه يعمل كحلقة ربط بين:
/// - EditProfileUiController الخاص بحقول الواجهة
/// - EditProfileService الخاص بالبيانات والتجهيزات
class EditProfileController extends GetxController {
  EditProfileController(this._service);

  final EditProfileService _service;

  late final EditProfileUiController ui;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  get nameCtrl => ui.nameCtrl;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  get emailCtrl => ui.emailCtrl;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  get passwordPreviewCtrl => ui.passwordPreviewCtrl;

  @override
  /// هذه الدالة تُستدعى عند إنشاء الكنترولر لأول مرة.
  /// نستخدمها لتهيئة الـ UI controller وتعبئة القيم الابتدائية.
  void onInit() {
    super.onInit();

    ui = Get.find<EditProfileUiController>();

    ui.fillInitialValues(
      name: _service.initialName(),
      email: _service.initialEmail(),
      passwordPreview: _service.passwordPreview(),
    );
  }

  /// هذه الدالة مخصصة لاختيار الصورة الشخصية لاحقًا.
  ///
  /// حاليًا هي placeholder حتى يتم ربط Image Picker أو رفع الصورة.
  void pickAvatar() {
    // لاحقاً: Image Picker
  }

  /// هذه الدالة تحفظ بيانات الملف الشخصي الحالية.
  ///
  /// حاليًا الحفظ mock فقط، ولاحقًا يمكن ربطها بـ API.
  void save() {
    final canSave = _service.canSave(
      name: nameCtrl.text,
      email: emailCtrl.text,
    );

    if (!canSave) {
      Get.snackbar(Tk.commonError.tr, Tk.profileEditFillAll.tr);
      return;
    }

    _service.saveProfile(
      name: nameCtrl.text,
      email: emailCtrl.text,
    );

    Get.snackbar(Tk.commonSaved.tr, Tk.profileEditUpdated.tr);
  }

  /// هذه الدالة تنقل المستخدم إلى شاشة تغيير كلمة المرور.
  void goToForgotPassword() {
    Get.toNamed(AppRoutes.forgot);
  }
}
