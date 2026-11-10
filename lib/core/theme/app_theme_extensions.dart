import 'package:flutter/material.dart';

/// امتدادات ملائمة لـ BuildContext للوصول للسمة والأبعاد
extension AppThemeContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  double get width => MediaQuery.sizeOf(this).width;
  double get height => MediaQuery.sizeOf(this).height;
}
