import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rwnaqk/controllers/profile/edit_profile_service.dart';
import 'package:rwnaqk/controllers/profile/edit_profile_ui_controller.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';

class EditProfileController extends GetxController {
  EditProfileController(this._service);

  final EditProfileService _service;

  late final EditProfileUiController ui;

  get nameCtrl => ui.nameCtrl;
  get emailCtrl => ui.emailCtrl;
  get passwordPreviewCtrl => ui.passwordPreviewCtrl;

  String get avatarPath => _service.avatarPath();
  String get avatarUrl => _service.avatarUrl();

  @override
  void onInit() {
    super.onInit();

    ui = Get.find<EditProfileUiController>();
    ui.fillInitialValues(
      name: _service.initialName(),
      email: _service.initialEmail(),
      passwordPreview: _service.passwordPreview(),
    );
  }

  Future<void> pickAvatar(ImageSource source) async {
    try {
      final result = await _service.pickAvatar(source);
      if (result == null) return;
      Get.snackbar(Tk.commonDone.tr, Tk.profileEditPhotoUpdated.tr);
    } catch (_) {
      Get.snackbar(Tk.commonError.tr, Tk.profileEditPhotoPickFailed.tr);
    }
  }

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

  void goToForgotPassword() {
    Get.toNamed(AppRoutes.forgot);
  }
}
