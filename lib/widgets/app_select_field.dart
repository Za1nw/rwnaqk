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
  final bool enabled;

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
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final fill = context.input;
    final currentValue = value;
    final selectedLabel =
        currentValue == null ? null : itemLabel(currentValue as T);
    final borderColor = context.border.withValues(alpha: enabled ? .38 : .20);
    final itemBorderColor = context.border.withValues(alpha: .28);
    final selectedItemColor = context.primary.withValues(alpha: .10);
    final disabledFill = context.input.withValues(alpha: .72);

    return Container(
      decoration: BoxDecoration(
        color: enabled ? fill : disabledFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: .16),
            offset: const Offset(-4, -4),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            offset: const Offset(6, 6),
            blurRadius: 14,
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        onChanged: enabled ? onChanged : null,
        validator: validator,
        menuMaxHeight: 320,
        dropdownColor: context.card,
        borderRadius: BorderRadius.circular(20),
        iconEnabledColor: context.primary,
        iconDisabledColor: context.mutedForeground.withValues(alpha: .55),
        style: TextStyle(
          color: context.foreground,
          fontWeight: FontWeight.w700,
          fontSize: 14,
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
                      color: context.foreground,
                      fontWeight: FontWeight.w800,
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
          fillColor: enabled ? fill : disabledFill,
          prefixIcon: prefixIcon == null
              ? null
              : Icon(prefixIcon, color: context.mutedForeground),
          labelStyle: TextStyle(color: context.mutedForeground),
          floatingLabelStyle: TextStyle(
            color: enabled ? context.primary : context.mutedForeground,
            fontWeight: FontWeight.w700,
          ),
          hintStyle:
              TextStyle(color: context.mutedForeground.withValues(alpha: .80)),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          isDense: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: context.destructive),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: context.destructive, width: 1.6),
          ),
          contentPadding: const EdgeInsetsDirectional.fromSTEB(14, 18, 14, 14),
        ),
        items: items
            .map(
              (e) => DropdownMenuItem<T>(
                value: e,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: e == value ? selectedItemColor : context.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: e == value
                            ? context.primary.withValues(alpha: .24)
                            : itemBorderColor,
                      ),
                    ),
                    child: Text(
                      itemLabel(e),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
