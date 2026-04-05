import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: AppColorSchemes.light,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColorSchemes.light.background,
  primaryColor: AppColorSchemes.light.primary,
  cardColor: AppColorSchemes.light.surface,
  dividerColor: AppColorSchemes.light.outline,
  fontFamily: 'Tajawal',
  textTheme: Typography.material2021().black.apply(
    fontFamily: 'Tajawal',
    bodyColor: AppColorSchemes.light.onBackground,
    displayColor: AppColorSchemes.light.onBackground,
  ),
);
