import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

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
        controller: widget.controller,
        obscureText: _hidden,
        textInputAction: widget.textInputAction,
        enabled: widget.enabled,
        validator: widget.validator,
        onChanged: widget.onChanged,
        style: TextStyle(color: context.foreground),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,

          // ✅ Clay look: rely on Container shadows instead of borders
          filled: true,
          fillColor: fill,

          prefixIcon: widget.prefixIcon == null
              ? null
              : Icon(widget.prefixIcon, color: context.mutedForeground),

          suffixIcon: IconButton(
            onPressed: () => setState(() => _hidden = !_hidden),
            icon: Icon(
              _hidden ? Icons.visibility_off : Icons.visibility,
              color: context.mutedForeground,
            ),
          ),

          labelStyle: TextStyle(color: context.mutedForeground),
          hintStyle: TextStyle(color: context.mutedForeground.withOpacity(0.8)),

          // ✅ remove hard borders (keep radius)
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.transparent),
          ),

          // ✅ keep error borders visible (important UX)
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
