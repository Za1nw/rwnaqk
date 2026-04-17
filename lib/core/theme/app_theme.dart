import 'package:flutter/material.dart';

ThemeData buildAppTheme({
  required Brightness brightness,
  required ColorScheme colorScheme,
  required Color? scaffoldBackgroundColor,
}) {
  final isDark = brightness == Brightness.dark;

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: brightness,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    primaryColor: colorScheme.primary,
    cardColor: colorScheme.surface,
    dividerColor: colorScheme.outline,
    fontFamily: 'Tajawal',
    textTheme:
        (isDark
                ? Typography.material2021().white
                : Typography.material2021().black)
            .apply(
              fontFamily: 'Tajawal',
              bodyColor: colorScheme.onBackground,
              displayColor: colorScheme.onBackground,
            ),
  );
}
