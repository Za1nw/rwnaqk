import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rwnaqk/controllers/profile/edit_profile_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/widgets/app_button.dart';
import 'package:rwnaqk/widgets/app_input_field.dart';
import 'package:rwnaqk/widgets/common/app_action_icon_button.dart';
import 'package:rwnaqk/widgets/profile/profile_avatar.dart';

class EditProfileScreen extends GetView<EditProfileController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Obx(
          () => Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(18, 10, 18, 14),
            child: AppButton(
              text: Tk.profileEditSaveChanges.tr,
              onPressed: () => controller.save(),
              enabled: !controller.isUploadingAvatar,
              isLoading: controller.isSaving,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 14, 18, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Tk.profileEditTitle.tr,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: context.foreground,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                Tk.profileEditSubtitle.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.foreground,
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: _EditableAvatar(controller: controller),
              ),
              const SizedBox(height: 26),
              _SoftField(
                child: AppInputField(
                  controller: controller.nameCtrl,
                  label: Tk.profileEditName.tr,
                  hint: Tk.profileEditNameHint.tr,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 14),
              _SoftField(
                child: AppInputField(
                  controller: controller.emailCtrl,
                  label: Tk.profileEditEmail.tr,
                  hint: Tk.profileEditEmailHint.tr,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 14),
              _SoftField(
                child: AppInputField(
                  controller: controller.passwordPreviewCtrl,
                  label: Tk.profileEditPassword.tr,
                  hint: '************',
                  enabled: false,
                  textInputAction: TextInputAction.done,
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: controller.goToForgotPassword,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: Text(
                    Tk.loginForgot.tr,
                    style: TextStyle(
                      color: context.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditableAvatar extends StatelessWidget {
  final EditProfileController controller;

  const _EditableAvatar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller.nameCtrl,
      builder: (_, __) {
        return Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.card,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.08),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ProfileAvatar(
                            name: controller.nameCtrl.text.trim().isEmpty
                                ? 'User'
                                : controller.nameCtrl.text,
                            imagePath: controller.avatarPath,
                            imageUrl: controller.avatarUrl,
                            size: 124,
                            fontSize: 42,
                          ),
                          if (controller.isUploadingAvatar)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(.20),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                    PositionedDirectional(
                      end: 8,
                      top: 18,
                      child: AppActionIconButton(
                        icon: Icons.edit_rounded,
                        onTap: controller.isUploadingAvatar
                            ? null
                            : () => _showPhotoActions(context),
                        size: 44,
                        radius: 22,
                        backgroundColor: context.primary,
                        iconColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: controller.isUploadingAvatar
                    ? Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: SizedBox(
                          width: 160,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              minHeight: 6,
                              backgroundColor: context.border.withOpacity(.18),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                context.primary,
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPhotoActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BottomSheetTile(
                  icon: Icons.photo_library_outlined,
                  title: Tk.commonGallery.tr,
                  onTap: () {
                    Get.back();
                    controller.pickAvatar(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 10),
                _BottomSheetTile(
                  icon: Icons.photo_camera_outlined,
                  title: Tk.commonCamera.tr,
                  onTap: () {
                    Get.back();
                    controller.pickAvatar(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BottomSheetTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _BottomSheetTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: context.input,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border.withOpacity(.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: context.foreground),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: context.foreground,
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftField extends StatelessWidget {
  final Widget child;

  const _SoftField({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.input.withOpacity(context.isDark ? .55 : .75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.border.withOpacity(.20)),
      ),
      child: child,
    );
  }
}
