import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: AppColorSchemes.dark,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColorSchemes.dark.background,
  primaryColor: AppColorSchemes.dark.primary,
  cardColor: AppColorSchemes.dark.surface,
  dividerColor: AppColorSchemes.dark.outline,
  fontFamily: 'Tajawal',
  textTheme: Typography.material2021().white.apply(
    fontFamily: 'Tajawal',
    bodyColor: AppColorSchemes.dark.onBackground,
    displayColor: AppColorSchemes.dark.onBackground,
  ),
);