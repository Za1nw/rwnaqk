import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_validators.dart';

import 'package:rwnaqk_frontend/modules/auth/controllers/forgot_password_controller.dart';
import 'package:rwnaqk_frontend/core/widgets/app_button.dart';
import 'package:rwnaqk_frontend/core/widgets/app_input_field.dart';
import 'package:rwnaqk_frontend/core/widgets/app_password_field.dart';
import 'package:rwnaqk_frontend/modules/auth/widgets/auth_centered_container.dart';
import 'package:rwnaqk_frontend/modules/auth/widgets/auth_blob_background.dart';

class ResetPasswordScreen extends GetView<ForgotPasswordController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.background,
      body: AuthBlobBackground(
        child: SafeArea(
          child: AuthCenteredContainer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark.withValues(alpha: 0.94)
                    : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? AppColors.borderDark.withValues(alpha: 0.6)
                      : AppColors.borderLight,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
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
                    const SizedBox(height: 18),
                    AppInputField(
                      controller: controller.targetController,
                      label: Tk.loginEmailLabel.tr,
                      hint: Tk.loginEmailHint.tr,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: AppValidators.email,
                    ),
                    const SizedBox(height: 14),
                    AppInputField(
                      controller: controller.resetTokenController,
                      label: 'Reset Token',
                      hint: 'Paste token from reset link',
                      prefixIcon: Icons.key_outlined,
                      validator: (v) =>
                          AppValidators.required(v, Tk.fpResetTokenRequired.tr),
                    ),
                    const SizedBox(height: 14),
                    AppPasswordField(
                      controller: controller.passwordController,
                      label: Tk.fpNewPassword.tr,
                      hint: Tk.fpNewPassword.tr,
                      prefixIcon: Icons.lock_outline_rounded,
                      textInputAction: TextInputAction.next,
                      validator: (v) => AppValidators.password(
                        v,
                        requiredMsg: Tk.loginPasswordRequired.tr,
                        shortMsg: Tk.fpNewShort.tr,
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppPasswordField(
                      controller: controller.confirmController,
                      label: Tk.fpNewConfirm.tr,
                      hint: Tk.fpNewConfirm.tr,
                      prefixIcon: Icons.lock_reset_rounded,
                      textInputAction: TextInputAction.done,
                      validator: (v) => AppValidators.confirmPassword(
                        v,
                        controller.passwordController.text,
                        requiredMsg: Tk.fpNewShort.tr,
                        mismatchMsg: Tk.fpNewMismatch.tr,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(() {
                      return AppButton(
                        text: controller.isLoading.value
                            ? '...'
                            : Tk.fpNewSave.tr,
                        icon: Icons.save_rounded,
                        isLoading: controller.isLoading.value,
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.saveNewPassword,
                        height: 52,
                      );
                    }),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: controller.cancel,
                      child: Text(
                        Tk.fpCancel.tr,
                        style: TextStyle(
                          fontFamily: AppTextTheme.fontFamily,
                          color: context.mutedForeground,
                          fontSize: 14,
                        ),
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
