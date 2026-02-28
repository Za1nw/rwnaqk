import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AppInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
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
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fill = context.input;

    return Container(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          // light shadow (top-left)
          BoxShadow(
            color: Colors.white.withOpacity(0.22),
            offset: const Offset(-4, -4),
            blurRadius: 10,
          ),
          // dark shadow (bottom-right)
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            offset: const Offset(6, 6),
            blurRadius: 14,
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
        style: TextStyle(color: context.foreground),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: fill,

          prefixIcon: prefixIcon == null
              ? null
              : Icon(prefixIcon, color: context.mutedForeground),

          labelStyle: TextStyle(color: context.mutedForeground),
          hintStyle: TextStyle(color: context.mutedForeground.withOpacity(0.8)),

          // ✅ no hard outline borders (clay uses shadows)
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.transparent),
          ),

          // ✅ keep error borders for clarity
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: context.destructive),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: context.destructive, width: 1.6),
          ),

          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}
