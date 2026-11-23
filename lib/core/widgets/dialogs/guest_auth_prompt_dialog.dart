import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/widgets/app_button.dart';
import 'package:rwnaqk_frontend/core/widgets/dialogs/app_dialog_shell.dart';
import 'package:rwnaqk_frontend/routes/app_route_args.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

/// حوار اعتراض الزائر عند محاولة استخدام وظائف تتطلب تسجيل الدخول (مثل إضافة منتج للسلة والشراء الفوري)
class GuestAuthPromptDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? returnRoute;
  final Object? returnArgs;

  const GuestAuthPromptDialog({
    super.key,
    this.title = 'تسجيل الدخول مطلوب',
    this.message = 'يرجى تسجيل الدخول إلى حسابك لتتمكن من إضافة المنتجات إلى سلة التسوق ومتابعة الطلب.',
    this.returnRoute,
    this.returnArgs,
  });

  /// عرض الحوار للزائر مع توجيه آمن لمسار تسجيل الدخول عند الموافقة
  static Future<bool?> show(
    BuildContext context, {
    String title = 'تسجيل الدخول مطلوب',
    String message = 'يرجى تسجيل الدخول إلى حسابك لتتمكن من إضافة المنتجات إلى سلة التسوق ومتابعة الطلب.',
    String? returnRoute,
    Object? returnArgs,
  }) {
    return AppNav.dialog<bool>(
      child: GuestAuthPromptDialog(
        title: title,
        message: message,
        returnRoute: returnRoute ?? AppNav.currentRoute,
        returnArgs: returnArgs ?? AppNav.currentArguments,
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? BrandColors.gold : BrandColors.burgundy;

    return AppDialogShell(
      title: title,
      showCloseButton: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // أيقونة قفل فاخرة متدرجة
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
                Icons.lock_outline_rounded,
                color: primaryColor,
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // رسالة التوضيح
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextTheme.cairo(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // أزرار الحوار
          Row(
            children: [
              // زر الإلغاء الثانوي (إغلاق الحوار دون أثر جانبي)
              Expanded(
                child: AppButton(
                  text: 'إلغاء',
                  outlined: true,
                  height: 46,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: 12),
              // زر تسجيل الدخول الأساسي
              Expanded(
                child: AppButton(
                  text: 'تسجيل الدخول',
                  height: 46,
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    final safeRoute = returnRoute ?? AppNav.currentRoute;
                    AppNav.toNamed(
                      AppRoutes.login,
                      arguments: <String, dynamic>{
                        if (safeRoute != null && safeRoute.isNotEmpty && safeRoute != AppRoutes.login)
                          AppRouteArgs.returnRoute: safeRoute,
                        if (returnArgs != null)
                          AppRouteArgs.returnArgs: returnArgs,
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
