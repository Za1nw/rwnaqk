import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/common/app_action_icon_button.dart';

import '../../widgets/app_button.dart';
import '../../widgets/app_input_field.dart';
import '../../controllers/profile/edit_profile_controller.dart';

class EditProfileScreen extends GetView<EditProfileController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,

      // ✅ زر ثابت تحت مثل الصورة
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 10, 18, 14),
          child: AppButton(
            text: 'Save Changes'.tr,
            onPressed: controller.save,
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
                'Settings'.tr,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: context.foreground,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your Profile'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.foreground,
                ),
              ),
              const SizedBox(height: 18),

              // ===== Avatar + edit button overlay
              Center(
                child: _EditableAvatar(
                  onEdit: controller.pickAvatar,
                ),
              ),

              const SizedBox(height: 26),

              // ===== Fields (نفس شكل البطائق الرمادية بالصورة)
              _SoftField(
                child: AppInputField(
                  controller: controller.nameCtrl,
                  label: 'Name'.tr,
                  hint: 'Romina'.tr,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 14),

              _SoftField(
                child: AppInputField(
                  controller: controller.emailCtrl,
                  label: 'Email'.tr,
                  hint: 'gmail@example.com'.tr,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 14),

              _SoftField(
                child: AppInputField(
                  controller: controller.passwordPreviewCtrl,
                  label: 'Password'.tr,
                  hint: '************',
                  enabled: false, // ✅ مثل الصورة مجرد عرض
                  textInputAction: TextInputAction.done,
                ),
              ),

              const SizedBox(height: 6),

              // ✅ رابط يفتح شاشة تغيير كلمة السر
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: controller.goToForgotPassword,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: Text(
                    'login.forgot'.tr, // أو غيّرها لـ "Change Password".tr
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
  final VoidCallback onEdit;
  const _EditableAvatar({required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                )
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.input,
                border: Border.all(color: context.border.withOpacity(.25)),
              ),
              child: const Icon(Icons.person_rounded, size: 58),
              // لاحقاً: AppNetworkImage داخل ClipOval
            ),
          ),

          PositionedDirectional(
            end: 8,
            top: 18,
            child: AppActionIconButton(
              icon: Icons.edit_rounded,
              onTap: onEdit,
              size: 44,
              radius: 22,
              backgroundColor: context.primary,
              iconColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ حاوية “soft” مثل البلوك الرمادي بالصورة
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