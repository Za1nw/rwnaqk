import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AppSelectField<T> extends StatelessWidget {
  final String label;
  final String? hint;
  final List<T> items;
  final T? value;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;
  final IconData? prefixIcon;
  final String? Function(T?)? validator;

  const AppSelectField({
    super.key,
    required this.label,
    this.hint,
    required this.items,
    required this.value,
    required this.itemLabel,
    required this.onChanged,
    this.prefixIcon,
    this.validator,
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
      child: DropdownButtonFormField<T>(
        value: value,
        onChanged: onChanged,
        validator: validator,
        dropdownColor: context.card,
        iconEnabledColor: context.mutedForeground,
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

          // ✅ remove hard borders (clay uses shadows)
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.transparent),
          ),

          // ✅ keep error borders
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
        items: items
            .map(
              (e) => DropdownMenuItem<T>(
                value: e,
                child: Text(itemLabel(e)),
              ),
            )
            .toList(),
      ),
    );
  }
}
