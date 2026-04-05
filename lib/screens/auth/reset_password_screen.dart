import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';

import '../../controllers/forgot_password/forgot_password_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_password_field.dart';
import '../../widgets/auth/auth_centered_container.dart';
import '../../widgets/auth_blob_background.dart';

class ResetPasswordScreen extends GetView<ForgotPasswordController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: AuthBlobBackground(
        child: SafeArea(
          child: AuthCenteredContainer(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: context.card.withOpacity(context.isDark ? 0.92 : 0.96),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color:
                      context.border.withOpacity(context.isDark ? 0.45 : 0.70),
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.shadow
                        .withOpacity(context.isDark ? 0.45 : 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AuthTitleBlock(
                      title: Tk.fpNewTitle.tr,
                      subtitle: Tk.fpNewSubtitle.tr,
                    ),
                    const SizedBox(height: 16),
                    AppPasswordField(
                      controller: controller.passwordController,
                      label: Tk.fpNewPassword.tr,
                      hint: Tk.fpNewPassword.tr,
                      prefixIcon: Icons.lock_outline_rounded,
                      validator: (v) {
                        final value = (v ?? '');
                        if (value.isEmpty) return Tk.fpNewShort.tr;
                        if (value.length < 6) return Tk.fpNewShort.tr;
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    AppPasswordField(
                      controller: controller.confirmController,
                      label: Tk.fpNewConfirm.tr,
                      hint: Tk.fpNewConfirm.tr,
                      prefixIcon: Icons.lock_reset_rounded,
                      textInputAction: TextInputAction.done,
                      validator: (v) {
                        final value = (v ?? '');
                        if (value.isEmpty) return Tk.fpNewShort.tr;
                        if (value.length < 6) return Tk.fpNewShort.tr;
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    Obx(() {
                      return AppButton(
                        text: controller.isLoading.value
                            ? '...'
                            : Tk.fpNewSave.tr,
                        icon: Icons.save_rounded,
                        onPressed: controller.isLoading.value
                            ? () {}
                            : controller.saveNewPassword,
                        height: 54,
                      );
                    }),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: controller.cancel,
                      child: Text(
                        Tk.fpCancel.tr,
                        style: TextStyle(color: context.mutedForeground),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}