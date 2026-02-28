import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

/// عنوان قسم موحّد مع نمط قابل للتخصيص.
class AppSectionTitle extends StatelessWidget {
  final String title;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;

  const AppSectionTitle({
    super.key,
    required this.title,
    this.fontSize = 18,
    this.fontWeight = FontWeight.w900,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: color ?? context.foreground,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}
