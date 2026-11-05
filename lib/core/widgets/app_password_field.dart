import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';

class AppPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final TextInputAction textInputAction;
  final bool enabled;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const AppPasswordField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.textInputAction = TextInputAction.done,
    this.enabled = true,
    this.validator,
    this.onChanged,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

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
        controller: widget.controller,
        obscureText: _hidden,
        textInputAction: widget.textInputAction,
        enabled: widget.enabled,
        validator: widget.validator,
        onChanged: widget.onChanged,
        style: TextStyle(
          fontFamily: AppTextTheme.fontFamily,
          color: context.foreground,
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          filled: true,
          fillColor: Colors.transparent,

          prefixIcon: widget.prefixIcon == null
              ? null
              : Icon(
                  widget.prefixIcon,
                  color: context.mutedForeground.withValues(alpha: 0.85),
                  size: 20,
                ),

          suffixIcon: IconButton(
            onPressed: () => setState(() => _hidden = !_hidden),
            icon: Icon(
              _hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: context.mutedForeground.withValues(alpha: 0.85),
              size: 20,
            ),
            splashRadius: 20,
          ),

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

          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }
}
