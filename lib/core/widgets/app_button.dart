import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';

/// زر رَوْنَقُك الملكي الموحد مع انميشن ضغط فيزيائي فوري (Boutique Tactile Action Button)
///
/// مصمم وفق هوية المتجر الراقية:
/// - انميشن ضغط ارتدادي سلس (`AnimatedScale: 0.96`)
/// - استجابة لمسية واضحة (`HapticFeedback.lightImpact()`)
/// - تدرجات لونية ملكية متناسقة في الوضعين الفاتح والداكن
/// - دعم الأيقونة، التحميل، والحالة المفرغة (Outlined)
/// - حماية كاملة من فيض النصوص (Zero Overflow)
class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;

  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool outlined;
  final double height;
  final bool isLoading;
  final double borderRadius;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.outlined = false,
    this.height = 50,
    this.isLoading = false,
    this.borderRadius = 15,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBg = widget.outlined
        ? Colors.transparent
        : (widget.backgroundColor ??
              (isDark ? BrandColors.gold : BrandColors.burgundy));

    final defaultFg = widget.outlined
        ? (widget.foregroundColor ??
              (isDark ? BrandColors.gold : BrandColors.burgundy))
        : (widget.foregroundColor ??
              (isDark ? const Color(0xFF1E0A17) : Colors.white));

    final bool isActionable = widget.onPressed != null && !widget.isLoading;
    final bool showShadow = !widget.outlined && isActionable;

    return GestureDetector(
      onTapDown: isActionable ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isActionable ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isActionable
          ? () => setState(() => _isPressed = false)
          : null,
      child: AnimatedScale(
        scale: (_isPressed && isActionable) ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: (!widget.outlined && widget.backgroundColor == null)
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [BrandColors.gold, const Color(0xFFE59C00)]
                        : [const Color(0xFF7E033A), BrandColors.burgundy],
                  )
                : null,
            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: (isDark ? BrandColors.gold : BrandColors.burgundy)
                          .withValues(alpha: isDark ? 0.32 : 0.22),
                      blurRadius: _isPressed ? 8 : 16,
                      offset: Offset(0, _isPressed ? 2 : 5),
                    ),
                  ]
                : null,
          ),
          child: ElevatedButton(
            onPressed: !isActionable
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    widget.onPressed!();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  (!widget.outlined && widget.backgroundColor == null)
                  ? Colors.transparent
                  : defaultBg,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                side: widget.outlined
                    ? BorderSide(color: defaultFg, width: 1.2)
                    : BorderSide.none,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(defaultFg),
                      backgroundColor: defaultBg.withValues(alpha: 0.2),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 17, color: defaultFg),
                        const SizedBox(width: 5),
                      ],
                      Flexible(
                        child: Text(
                          widget.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTextTheme.cairo(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            color: defaultFg,
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
