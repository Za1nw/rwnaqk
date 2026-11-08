import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/widgets/app_button.dart';
import 'package:rwnaqk_frontend/core/widgets/dialogs/app_dialog_shell.dart';

/// نافذة تأكيد ملكية فاخرة خاصة بتطبيق رَوْنَقُك
/// تدعم الحالات التحذيرية (Destructive) والعامة مع أيقونة دائرية متدرجة
class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmLabel;
  final String? cancelLabel;
  final IconData icon;
  final Color? iconColor;
  final bool isDestructive;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel,
    this.cancelLabel,
    this.icon = Icons.warning_amber_rounded,
    this.iconColor,
    this.isDestructive = false,
  });

  static Future<bool?> show({
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    IconData icon = Icons.warning_amber_rounded,
    Color? iconColor,
    bool isDestructive = false,
  }) {
    return Get.dialog<bool>(
      AppConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        icon: icon,
        iconColor: iconColor,
        isDestructive: isDestructive,
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = iconColor ??
        (isDestructive
            ? (isDark ? const Color(0xFFFFB4AB) : const Color(0xFFB42318))
            : (isDark ? AppColors.gold : AppColors.burgundy));

    return AppDialogShell(
      title: title,
      showCloseButton: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          // أيقونة دائرية فاخرة
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: isDark ? 0.20 : 0.10),
              border: Border.all(
                color: primaryColor.withValues(alpha: isDark ? 0.45 : 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: primaryColor,
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // نص الرسالة
          Text(
            message.tr,
            textAlign: TextAlign.center,
            style: AppTextTheme.cairo(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          // أزرار الإجراء
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back<bool>(result: false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    (cancelLabel ?? Tk.commonCancel).tr,
                    style: AppTextTheme.cairo(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: (confirmLabel ?? Tk.commonYes).tr,
                  backgroundColor: isDestructive
                      ? (isDark
                          ? const Color(0xFF93000A)
                          : const Color(0xFFB42318))
                      : null,
                  onPressed: () => Get.back<bool>(result: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

