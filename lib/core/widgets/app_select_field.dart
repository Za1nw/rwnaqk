import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';

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
    final isDark = context.isDark;

    final fillColor = isDark ? const Color(0xFF190C18) : Colors.white;

    final defaultBorderColor = isDark
        ? AppColors.borderDark.withValues(alpha: 0.75)
        : AppColors.borderLight;

    final focusedBorderColor = context.primary;
    final selectedLabel = value == null ? null : itemLabel(value as T);

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
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        onChanged: onChanged,
        validator: validator,
        menuMaxHeight: 320,
        dropdownColor: isDark ? const Color(0xFF24111F) : Colors.white,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: context.mutedForeground.withValues(alpha: 0.85),
          size: 22,
        ),
        style: TextStyle(
          fontFamily: AppTextTheme.fontFamily,
          color: context.foreground,
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
        ),
        selectedItemBuilder: (_) {
          return items
              .map(
                (item) => Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    itemLabel(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTextTheme.fontFamily,
                      color: context.foreground,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(growable: false);
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: selectedLabel == null ? hint : null,
          filled: true,
          fillColor: Colors.transparent,
          prefixIcon: prefixIcon == null
              ? null
              : Icon(
                  prefixIcon,
                  color: context.mutedForeground.withValues(alpha: 0.85),
                  size: 20,
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
        items: items
            .map(
              (e) => DropdownMenuItem<T>(
                value: e,
                child: Text(
                  itemLabel(e),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTextTheme.fontFamily,
                    color: context.foreground,
                    fontSize: 14,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
