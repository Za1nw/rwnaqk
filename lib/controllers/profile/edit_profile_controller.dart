import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rwnaqk/controllers/profile/edit_profile_service.dart';
import 'package:rwnaqk/controllers/profile/edit_profile_ui_controller.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/widgets/dialogs/app_saved_dialog.dart';

class EditProfileController extends GetxController {
  EditProfileController(this._service);

  final EditProfileService _service;
  final _avatarPath = ''.obs;
  final _avatarUrl = ''.obs;
  final _isUploadingAvatar = false.obs;
  final _isSaving = false.obs;

  late final EditProfileUiController ui;

  get nameCtrl => ui.nameCtrl;
  get emailCtrl => ui.emailCtrl;
  get mobileCtrl => ui.mobileCtrl;
  get passwordPreviewCtrl => ui.passwordPreviewCtrl;

  String get avatarPath => _avatarPath.value;
  String get avatarUrl => _avatarUrl.value;
  bool get isUploadingAvatar => _isUploadingAvatar.value;
  bool get isSaving => _isSaving.value;
  bool get isBusy => _isUploadingAvatar.value || _isSaving.value;

  @override
  void onInit() {
    super.onInit();
    ui = Get.find<EditProfileUiController>();
    ui.fillInitialValues(
      name: _service.initialName(),
      email: _service.initialEmail(),
      mobile: _service.initialMobile(),
      passwordPreview: _service.passwordPreview(),
    );
    _avatarPath.value = _service.avatarPath();
    _avatarUrl.value = _service.avatarUrl();
  }

  Future<void> pickAvatar(ImageSource source) async {
    if (isBusy) return;
    _isUploadingAvatar.value = true;
    try {
      final result = await _service.pickAvatar(source);
      if (result == null) return;
      Get.snackbar(Tk.commonDone.tr, Tk.profileEditPhotoUpdated.tr);
      _avatarPath.value = result;
      _avatarUrl.value = '';
    } catch (_) {
      Get.snackbar(Tk.commonError.tr, Tk.profileEditPhotoPickFailed.tr);
    } finally {
      _isUploadingAvatar.value = false;
    }
  }

  Future<void> save() async {
    if (isBusy) return;

    final canSave = _service.canSave(
      name: nameCtrl.text,
      email: emailCtrl.text,
      mobile: mobileCtrl.text,
    );
    if (!canSave) {
      Get.snackbar(Tk.commonError.tr, Tk.profileEditFillAll.tr);
      return;
    }

    _isSaving.value = true;
    try {
      _service.saveProfileData(
        name: nameCtrl.text,
        email: emailCtrl.text,
        mobile: mobileCtrl.text,
        avatarPath: avatarPath,
      );
      await AppSavedDialog.show(messageKey: Tk.profileEditUpdated);
      if (Get.key.currentState?.canPop() ?? false) {
        Get.back<void>();
      }
    } catch (_) {
      Get.snackbar(Tk.commonError.tr, Tk.commonUnexpectedError.tr);
    } finally {
      if (!isClosed) {
        _isSaving.value = false;
      }
    }
  }

  void goToForgotPassword() {
    Get.toNamed(AppRoutes.forgot);
  }
}
