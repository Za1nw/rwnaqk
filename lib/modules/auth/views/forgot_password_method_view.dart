import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/utils/app_validators.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/forgot_password_service.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';

import 'package:rwnaqk_frontend/modules/auth/controllers/forgot_password_controller.dart';
import 'package:rwnaqk_frontend/modules/auth/widgets/auth_blob_background.dart';
import 'package:rwnaqk_frontend/core/widgets/app_button.dart';
import 'package:rwnaqk_frontend/core/widgets/app_input_field.dart';
import 'package:rwnaqk_frontend/modules/auth/widgets/auth_centered_container.dart';

class ForgotPasswordMethodScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.background,
      body: AuthBlobBackground(
        child: SafeArea(
          child: AuthCenteredContainer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? AppColors.surfaceDark.withValues(alpha: 0.95)
                        : Colors.white,
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark.withValues(alpha: 0.6)
                          : AppColors.borderLight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.35 : 0.08,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.lock_reset_rounded,
                    color: context.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),

                AuthTitleBlock(
                  title: Tk.fpTitle.tr,
                  subtitle: Tk.fpSubtitle.tr,
                ),
                const SizedBox(height: 18),

                Obx(() {
                  return _ChoiceCard(
                    selected: controller.method.value == RecoveryMethod.sms,
                    title: Tk.fpSms.tr,
                    icon: Icons.sms_outlined,
                    onTap: () => controller.selectMethod(RecoveryMethod.sms),
                  );
                }),
                const SizedBox(height: 10),
                Obx(() {
                  return _ChoiceCard(
                    selected: controller.method.value == RecoveryMethod.email,
                    title: Tk.fpEmail.tr,
                    icon: Icons.email_outlined,
                    onTap: () => controller.selectMethod(RecoveryMethod.email),
                  );
                }),

                const SizedBox(height: 14),
                AppInputField(
                  controller: controller.targetController,
                  label: Tk.loginEmailLabel.tr,
                  hint: Tk.loginEmailHint.tr,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidators.email,
                ),

                const SizedBox(height: 20),

                Obx(() {
                  return AppButton(
                    text: controller.isLoading.value ? '...' : Tk.fpNext.tr,
                    icon: Icons.arrow_forward_rounded,
                    isLoading: controller.isLoading.value,
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.goNextFromMethod,
                    height: 52,
                  );
                }),
                const SizedBox(height: 10),

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
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final bool selected;
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.selected,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg = isDark
        ? AppColors.surfaceDark.withValues(alpha: 0.94)
        : Colors.white;

    final border = selected
        ? context.primary
        : (isDark
              ? AppColors.borderDark.withValues(alpha: 0.6)
              : AppColors.borderLight);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: selected ? 1.5 : 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? context.primary : context.mutedForeground,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: AppTextTheme.fontFamily,
                  color: context.foreground,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                ),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? context.primary
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: 1.5,
                ),
                color: selected ? context.primary : Colors.transparent,
              ),
              child: selected
                  ? Icon(
                      Icons.check,
                      size: 14,
                      color: context.primaryForeground,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
