import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';

/// أنواع إشعارات وتنبيهات تطبيق رَوْنَقُك الملكي
enum RawnaqkToastType { success, error, warning, info, copied }

/// موضع ظهور الإشعار (أعلى أو أسفل الشاشة)
enum RawnaqkToastPosition { top, bottom }

/// المكون الموحد لتقديم تجربة إشعارات وتنبيهات فاخرة وخاصة بتطبيق "رَوْنَقُك"
/// استبدال كامل للـ Snackbars الافتراضية بمظهر ملوكي يعكس هوية المتجر
abstract final class RawnaqkToast {
  const RawnaqkToast._();

  /// عرض إشعار نجاح ملكي (Emerald & Luxury Gold)
  static void success(
    String message, {
    String? title,
    Duration duration = const Duration(milliseconds: 3200),
    VoidCallback? onAction,
    String? actionLabel,
    RawnaqkToastPosition position = RawnaqkToastPosition.top,
  }) {
    show(
      message: message,
      title: title ?? Tk.commonSuccess.tr,
      type: RawnaqkToastType.success,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
      position: position,
    );
  }

  /// عرض إشعار خطأ / تنبيه حرج (Ruby Crimson & Royal Burgundy)
  static void error(
    String message, {
    String? title,
    Duration duration = const Duration(milliseconds: 3800),
    VoidCallback? onAction,
    String? actionLabel,
    RawnaqkToastPosition position = RawnaqkToastPosition.top,
  }) {
    show(
      message: message,
      title: title ?? Tk.commonError.tr,
      type: RawnaqkToastType.error,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
      position: position,
    );
  }

  /// عرض تحذير ذهبي (Radiant Amber Gold)
  static void warning(
    String message, {
    String? title,
    Duration duration = const Duration(milliseconds: 3400),
    VoidCallback? onAction,
    String? actionLabel,
    RawnaqkToastPosition position = RawnaqkToastPosition.top,
  }) {
    show(
      message: message,
      title: title ?? 'تنبيه',
      type: RawnaqkToastType.warning,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
      position: position,
    );
  }

  /// عرض معلومة أو إشعار عام من رَوْنَقُك (Royal Burgundy & Gold Sparkle)
  static void info(
    String message, {
    String? title,
    Duration duration = const Duration(milliseconds: 3000),
    VoidCallback? onAction,
    String? actionLabel,
    RawnaqkToastPosition position = RawnaqkToastPosition.top,
  }) {
    show(
      message: message,
      title: title ?? 'إشعار رَوْنَقُك',
      type: RawnaqkToastType.info,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
      position: position,
    );
  }

  /// إشعار نسخ سريع وأنيق (Copied to Clipboard)
  static void copied({
    String? message,
    String? title,
    Duration duration = const Duration(milliseconds: 2400),
    RawnaqkToastPosition position = RawnaqkToastPosition.top,
  }) {
    show(
      message: message ?? Tk.commonCopied.tr,
      title: title ?? 'تم النسخ بنجاح',
      type: RawnaqkToastType.copied,
      duration: duration,
      position: position,
    );
  }

  /// إشعار كبسولة عائم وصغير للأحداث السريعة (Micro Pill Toast)
  static void pill(
    String message, {
    IconData icon = Icons.check_circle_outline_rounded,
    Color? accentColor,
    Duration duration = const Duration(milliseconds: 2200),
    RawnaqkToastPosition position = RawnaqkToastPosition.top,
  }) {
    _triggerHaptic(RawnaqkToastType.success);

    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    final snackPosition = position == RawnaqkToastPosition.top
        ? SnackPosition.TOP
        : SnackPosition.BOTTOM;

    Get.showSnackbar(
      GetSnackBar(
        snackPosition: snackPosition,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        borderRadius: 24,
        duration: duration,
        animationDuration: const Duration(milliseconds: 320),
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeInCubic,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        boxShadows: const [],
        messageText: RawnaqkPillToastCard(
          message: message,
          icon: icon,
          accentColor: accentColor,
        ),
      ),
    );
  }

  /// المحرك الأساسي لعرض الإشعار المخصص
  static void show({
    required String message,
    String? title,
    RawnaqkToastType type = RawnaqkToastType.info,
    Duration duration = const Duration(milliseconds: 3200),
    IconData? customIcon,
    VoidCallback? onAction,
    String? actionLabel,
    RawnaqkToastPosition position = RawnaqkToastPosition.top,
  }) {
    _triggerHaptic(type);

    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    final snackPosition = position == RawnaqkToastPosition.top
        ? SnackPosition.TOP
        : SnackPosition.BOTTOM;

    Get.showSnackbar(
      GetSnackBar(
        snackPosition: snackPosition,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 18,
        duration: duration,
        animationDuration: const Duration(milliseconds: 360),
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeInCubic,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        boxShadows: const [],
        messageText: RawnaqkToastCard(
          message: message,
          title: title,
          type: type,
          customIcon: customIcon,
          onAction: onAction,
          actionLabel: actionLabel,
          duration: duration,
        ),
      ),
    );
  }

  static void _triggerHaptic(RawnaqkToastType type) {
    try {
      switch (type) {
        case RawnaqkToastType.success:
          HapticFeedback.lightImpact();
          break;
        case RawnaqkToastType.error:
          HapticFeedback.heavyImpact();
          break;
        case RawnaqkToastType.warning:
          HapticFeedback.mediumImpact();
          break;
        case RawnaqkToastType.info:
          HapticFeedback.selectionClick();
          break;
        case RawnaqkToastType.copied:
          HapticFeedback.lightImpact();
          break;
      }
    } catch (_) {
      // إخفاق صامت في بيئات لا تدعم الهزاز
    }
  }
}

/// بطاقة الإشعار الملكية الكاملة
class RawnaqkToastCard extends StatelessWidget {
  final String message;
  final String? title;
  final RawnaqkToastType type;
  final IconData? customIcon;
  final VoidCallback? onAction;
  final String? actionLabel;
  final Duration duration;

  const RawnaqkToastCard({
    super.key,
    required this.message,
    this.title,
    this.type = RawnaqkToastType.info,
    this.customIcon,
    this.onAction,
    this.actionLabel,
    this.duration = const Duration(milliseconds: 3200),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visual = _resolveVisualTokens(context, isDark);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: visual.cardBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: visual.borderColor, width: 1.2),
            boxShadow: [
              // ظل ناعم عميق
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.55 : 0.08),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
              // هالة مضيئة بلون الإشعار
              BoxShadow(
                color: visual.accentColor.withValues(
                  alpha: isDark ? 0.22 : 0.08,
                ),
                blurRadius: 14,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // شريط العلامة الملكية الرأسي
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            visual.accentColor,
                            visual.accentColor.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // أيقونة الجوهرة الملكية
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            visual.accentColor.withValues(
                              alpha: isDark ? 0.26 : 0.15,
                            ),
                            visual.accentColor.withValues(
                              alpha: isDark ? 0.10 : 0.04,
                            ),
                          ],
                        ),
                        border: Border.all(
                          color: visual.accentColor.withValues(
                            alpha: isDark ? 0.45 : 0.28,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          customIcon ?? visual.icon,
                          color: visual.iconColor,
                          size: 21,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // نصوص الإشعار (العنوان + الرسالة)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (title != null && title!.trim().isNotEmpty) ...[
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    title!,
                                    style: AppTextTheme.cairo(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: visual.titleColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (type == RawnaqkToastType.success) ...[
                                  const SizedBox(width: 4),
                                  const Text(
                                    '👑',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            message,
                            style: AppTextTheme.cairo(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              color: visual.messageColor,
                              height: 1.35,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // زر إجراء اختياري (مثل: تراجع، نسخ، عرض)
                    if (actionLabel != null && onAction != null) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          onAction!();
                          if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: visual.accentColor.withValues(
                              alpha: isDark ? 0.22 : 0.12,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: visual.accentColor.withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            actionLabel!,
                            style: AppTextTheme.cairo(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: visual.accentColor,
                            ),
                          ),
                        ),
                      ),
                    ],

                    // زر الإغلاق السريع
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: visual.messageColor.withValues(alpha: 0.06),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 15,
                          color: visual.messageColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // مؤشر التوقيت الزمني الدقيق (Progress Bar)
              _ToastCountdownBar(
                duration: duration,
                accentColor: visual.accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _ToastVisualTokens _resolveVisualTokens(BuildContext context, bool isDark) {
    switch (type) {
      case RawnaqkToastType.success:
        final accent = isDark
            ? const Color(0xFF75D6A5)
            : const Color(0xFF176B45);
        return _ToastVisualTokens(
          accentColor: accent,
          iconColor: isDark ? AppColors.gold : accent,
          borderColor: isDark
              ? AppColors.gold.withValues(alpha: 0.35)
              : accent.withValues(alpha: 0.25),
          cardBackground: isDark
              ? const Color(0xFF22121E)
              : const Color(0xFFFFFFFF),
          titleColor: isDark ? AppColors.pearlWhite : const Color(0xFF1B0713),
          messageColor: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          icon: Icons.verified_rounded,
        );

      case RawnaqkToastType.error:
        final accent = isDark
            ? const Color(0xFFFFB4AB)
            : const Color(0xFFB42318);
        return _ToastVisualTokens(
          accentColor: accent,
          iconColor: accent,
          borderColor: accent.withValues(alpha: isDark ? 0.45 : 0.30),
          cardBackground: isDark
              ? const Color(0xFF261019)
              : const Color(0xFFFFF9FA),
          titleColor: isDark ? AppColors.pearlWhite : const Color(0xFF900B1B),
          messageColor: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          icon: Icons.error_outline_rounded,
        );

      case RawnaqkToastType.warning:
        final accent = isDark
            ? const Color(0xFFFFD454)
            : const Color(0xFFB57400);
        return _ToastVisualTokens(
          accentColor: accent,
          iconColor: isDark ? AppColors.gold : accent,
          borderColor: accent.withValues(alpha: isDark ? 0.45 : 0.30),
          cardBackground: isDark
              ? const Color(0xFF241416)
              : const Color(0xFFFFFDF8),
          titleColor: isDark ? AppColors.pearlWhite : const Color(0xFF7A4A00),
          messageColor: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          icon: Icons.warning_amber_rounded,
        );

      case RawnaqkToastType.info:
        final accent = isDark ? AppColors.gold : AppColors.burgundy;
        return _ToastVisualTokens(
          accentColor: accent,
          iconColor: accent,
          borderColor: accent.withValues(alpha: isDark ? 0.40 : 0.22),
          cardBackground: isDark
              ? const Color(0xFF22111E)
              : const Color(0xFFFFFFFF),
          titleColor: isDark ? AppColors.pearlWhite : AppColors.burgundy,
          messageColor: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          icon: Icons.auto_awesome_rounded,
        );

      case RawnaqkToastType.copied:
        final accent = AppColors.gold;
        return _ToastVisualTokens(
          accentColor: accent,
          iconColor: accent,
          borderColor: accent.withValues(alpha: isDark ? 0.45 : 0.35),
          cardBackground: isDark
              ? const Color(0xFF23141B)
              : const Color(0xFFFFFFFF),
          titleColor: isDark ? AppColors.pearlWhite : const Color(0xFF26141E),
          messageColor: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          icon: Icons.content_copy_rounded,
        );
    }
  }
}

/// شريط المؤشر الزمني التنازلي أسفل بطاقة الإشعار
class _ToastCountdownBar extends StatelessWidget {
  final Duration duration;
  final Color accentColor;

  const _ToastCountdownBar({required this.duration, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2.4,
      width: double.infinity,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        duration: duration,
        curve: Curves.linear,
        builder: (context, value, _) {
          return FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor, accentColor.withValues(alpha: 0.4)],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// بطاقة الكبسولة المصغرة العائمة (Pill Toast)
class RawnaqkPillToastCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? accentColor;

  const RawnaqkPillToastCard({
    super.key,
    required this.message,
    required this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = accentColor ?? (isDark ? AppColors.gold : AppColors.burgundy);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF24111F) : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.40 : 0.28),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.50 : 0.09),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.15),
                ),
                child: Center(child: Icon(icon, size: 14, color: color)),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message,
                  style: AppTextTheme.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.pearlWhite
                        : const Color(0xFF26141E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// فئة مخصصة لحمل درجات ألوان الإشعار حسب الوضع الليلي والنهاري
class _ToastVisualTokens {
  final Color accentColor;
  final Color iconColor;
  final Color borderColor;
  final Color cardBackground;
  final Color titleColor;
  final Color messageColor;
  final IconData icon;

  const _ToastVisualTokens({
    required this.accentColor,
    required this.iconColor,
    required this.borderColor,
    required this.cardBackground,
    required this.titleColor,
    required this.messageColor,
    required this.icon,
  });
}

/// اسم بديل متوافق لسهولة الاستدعاء
typedef AppToast = RawnaqkToast;
