import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

/// عنصر إعدادات موحّد:
/// - icon + title + (subtitle اختياري)
/// - onTap أو routeName (اختياري)
/// - trailing (اختياري) مثل Switch / زر / Text
/// - showChevron (افتراضي true إذا ما فيه trailing)
/// - يدعم تقييد عرض trailing لمنع overflow
/// - IMPORTANT: إذا tapWholeTile=false -> ما فيه InkWell إطلاقاً (عشان السويتش ما يعلّق)
class SettingsListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  /// إمّا تمرر onTap مباشرة…
  final VoidCallback? onTap;

  /// … أو تمرر routeName (اختياري) وسيتم Get.toNamed(routeName)
  final String? routeName;
  final dynamic routeArgs;

  /// Widget على اليمين (Switch, Button, Text...)
  final Widget? trailing;

  /// أقصى عرض للـ trailing لتجنب RenderFlex overflow
  final double trailingMaxWidth;

  /// لو true: كامل الصف قابل للنقر (مناسب لما ما عندك trailing أو trailing مجرد مؤشر)
  /// لو false: التفاعل يكون للـ trailing فقط (مهم للسويتش)
  final bool tapWholeTile;

  /// إظهار سهم على اليمين
  final bool? showChevron;

  /// تحكم عام
  final bool enabled;

  /// Styling
  final EdgeInsetsGeometry padding;
  final double radius;

  const SettingsListTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.routeName,
    this.routeArgs,
    this.trailing,
    this.trailingMaxWidth = 160,
    this.tapWholeTile = true,
    this.showChevron,
    this.enabled = true,
    this.padding = const EdgeInsetsDirectional.fromSTEB(14, 12, 12, 12),
    this.radius = 18,
  });

  bool get _hasAction => onTap != null || routeName != null;

  void _handleTap() {
    if (!enabled) return;

    if (onTap != null) {
      onTap!.call();
      return;
    }
    if (routeName != null) {
      Get.toNamed(routeName!, arguments: routeArgs);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canTap = enabled && _hasAction;
    final showArrow = showChevron ?? (trailing == null);

    // ✅ هوية التطبيق
    final primarySoft = context.primary.withOpacity(.08);
    final primaryBorder = context.primary.withOpacity(.18);

    final tile = Material(
      color: context.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(
          color: canTap ? primaryBorder : context.border.withOpacity(.35),
        ),
      ),
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            // Leading icon
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: primarySoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: primaryBorder),
              ),
              child: Icon(icon, size: 20, color: context.primary),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _Texts(
                title: title,
                subtitle: subtitle,
                enabled: enabled,
              ),
            ),

            const SizedBox(width: 10),

            // ✅ FIX: منع overflow نهائيًا
            if (trailing != null)
              Flexible(
                fit: FlexFit.loose,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: trailingMaxWidth),
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: trailing!,
                  ),
                ),
              ),

            if (showArrow) ...[
              if (trailing != null) const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: context.primary.withOpacity(.6),
                size: 22,
              ),
            ],
          ],
        ),
      ),
    );

    // ✅ إذا ما نبغى tile tappable (مثل حالة Switch) نخلي التفاعل للـ trailing فقط
    if (!tapWholeTile) {
      return Opacity(opacity: enabled ? 1 : 0.55, child: tile);
    }

    // ✅ tile tappable فقط إذا فيه action
    if (canTap) {
      return InkWell(
        borderRadius: BorderRadius.circular(radius),
        splashColor: context.primary.withOpacity(.08),
        highlightColor: context.primary.withOpacity(.05),
        onTap: _handleTap,
        child: tile,
      );
    }

    return Opacity(opacity: enabled ? 1 : 0.55, child: tile);
  }
}

class _Texts extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool enabled;

  const _Texts({
    required this.title,
    required this.subtitle,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.foreground,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.muted,
              fontWeight: FontWeight.w700,
              fontSize: 12.3,
            ),
          ),
        ],
      ],
    );
  }
}