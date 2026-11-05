import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';

class AppInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool enabled;
  final int maxLines;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const AppInputField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    // خلفية الحقل متسقة ومتناسقة:
    // في الوضع الليلي نستخدم سطحاً ليلياً غائراً راقياً يتباين بجمال داخل البطاقة
    // في الوضع النهاري نستخدم لوناً ناصعاً ومريحاً
    final fillColor = isDark ? const Color(0xFF190C18) : Colors.white;

    final defaultBorderColor = isDark
        ? AppColors.borderDark.withValues(alpha: 0.75)
        : AppColors.borderLight;

    final focusedBorderColor = context.primary;

    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          if (isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              offset: const Offset(0, 2),
              blurRadius: 4,
            )
          else
            BoxShadow(
              color: context.shadow.withValues(alpha: 0.05),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        enabled: enabled,
        maxLines: maxLines,
        validator: validator,
        onChanged: onChanged,
        style: TextStyle(
          fontFamily: AppTextTheme.fontFamily,
          color: context.foreground,
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.transparent,

          prefixIcon: prefixIcon == null
              ? null
              : Icon(
                  prefixIcon,
                  color: context.mutedForeground.withValues(alpha: 0.85),
                  size: 20,
                ),
          suffixIcon: suffixIcon,

          labelStyle: TextStyle(
            fontFamily: AppTextTheme.fontFamily,
            color: context.mutedForeground,
            fontSize: 13.5,
          ),
          floatingLabelStyle: TextStyle(
            fontFamily: AppTextTheme.fontFamily,
            color: focusedBorderColor,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: TextStyle(
            fontFamily: AppTextTheme.fontFamily,
            color: context.mutedForeground.withValues(alpha: 0.65),
            fontSize: 13.5,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: defaultBorderColor, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: focusedBorderColor, width: 1.6),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: context.destructive, width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: context.destructive, width: 1.8),
          ),
          errorStyle: TextStyle(
            fontFamily: AppTextTheme.fontFamily,
            color: context.destructive,
            fontSize: 11.5,
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}
