import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/forgot_password/forgot_password_service.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

import '../../controllers/forgot_password/forgot_password_controller.dart';
import '../../widgets/auth_blob_background.dart';
import '../../widgets/app_button.dart';
import '../../widgets/auth/auth_centered_container.dart';

class ForgotPasswordMethodScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    color: context.card.withOpacity(0.95),
                    border: Border.all(color: context.border.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: context.shadow
                            .withOpacity(context.isDark ? 0.35 : 0.16),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(Icons.lock_reset_rounded,
                      color: context.primary, size: 40),
                ),
                const SizedBox(height: 16),

                AuthTitleBlock(
                  title: 'fp.title'.tr,
                  subtitle: 'fp.subtitle'.tr,
                ),
                const SizedBox(height: 18),

                Obx(() {
                  return _ChoiceCard(
                    selected: controller.method.value == RecoveryMethod.sms,
                    title: 'fp.sms'.tr,
                    icon: Icons.sms_outlined,
                    onTap: () => controller.selectMethod(RecoveryMethod.sms),
                  );
                }),
                const SizedBox(height: 10),
                Obx(() {
                  return _ChoiceCard(
                    selected: controller.method.value == RecoveryMethod.email,
                    title: 'fp.email'.tr,
                    icon: Icons.email_outlined,
                    onTap: () => controller.selectMethod(RecoveryMethod.email),
                  );
                }),

                const SizedBox(height: 20),

                AppButton(
                  text: 'fp.next'.tr,
                  icon: Icons.arrow_forward_rounded,
                  onPressed: controller.goNextFromMethod,
                  height: 54,
                ),
                const SizedBox(height: 10),

                TextButton(
                  onPressed: controller.cancel,
                  child: Text(
                    'fp.cancel'.tr,
                    style: TextStyle(color: context.mutedForeground),
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
    final bg = context.card.withOpacity(context.isDark ? 0.92 : 0.96);
    final border = selected
        ? context.primary.withOpacity(0.65)
        : context.border.withOpacity(0.55);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: selected ? 1.4 : 1),
          boxShadow: [
            BoxShadow(
              color: context.shadow.withOpacity(context.isDark ? 0.30 : 0.12),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? context.primary : context.mutedForeground),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: context.foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: border),
                color: selected ? context.primary : Colors.transparent,
              ),
              child: selected
                  ? Icon(Icons.check,
                      size: 14, color: context.primaryForeground)
                  : null,
            )
          ],
        ),
      ),
    );
  }
}
