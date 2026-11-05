import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/constants/app_dimensions.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';

/// Centralized Material 3 Theme Configuration using bundled Cairo Font & Rawnaquk Brand Colors.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final textTheme = AppTextTheme.lightTextTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTextTheme.fontFamily,
      primaryColor: LightColors.primary,
      scaffoldBackgroundColor: LightColors.background, // #FFFFFF

      colorScheme: AppColorSchemes.light,

      appBarTheme: const AppBarTheme(
        backgroundColor: LightColors.background,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 1,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          fontFamily: AppTextTheme.fontFamily,
          color: LightColors.foreground,
          fontSize: AppDimensions.font18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: LightColors.foreground),
      ),

      textTheme: textTheme,

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LightColors.primary,
          foregroundColor: LightColors.primaryForeground,
          minimumSize: const Size.fromHeight(48),
          padding: AppDimensions.paddingH24,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius12),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: AppTextTheme.fontFamily,
            fontSize: AppDimensions.font16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LightColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space16,
        ),
        hintStyle: const TextStyle(
          fontFamily: AppTextTheme.fontFamily,
          color: LightColors.mutedForeground,
          fontSize: AppDimensions.font14,
        ),
        labelStyle: const TextStyle(
          fontFamily: AppTextTheme.fontFamily,
          color: LightColors.foreground,
          fontSize: AppDimensions.font14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
          borderSide: const BorderSide(color: LightColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
          borderSide: const BorderSide(color: LightColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
          borderSide: const BorderSide(color: LightColors.ring, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
          borderSide: const BorderSide(color: LightColors.destructive),
        ),
      ),

      cardTheme: CardThemeData(
        color: LightColors.card,
        elevation: 0,
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
          side: const BorderSide(color: LightColors.border),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: LightColors.card,
        indicatorColor: LightColors.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: AppTextTheme.fontFamily,
            fontSize: AppDimensions.font12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? LightColors.primary : LightColors.mutedForeground,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected ? LightColors.primary : LightColors.mutedForeground,
            size: 24,
          );
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    final textTheme = AppTextTheme.darkTextTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTextTheme.fontFamily,
      primaryColor: DarkColors.primary,
      scaffoldBackgroundColor: DarkColors.background, // #140A13

      colorScheme: AppColorSchemes.dark,

      appBarTheme: const AppBarTheme(
        backgroundColor: DarkColors.card,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 1,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          fontFamily: AppTextTheme.fontFamily,
          color: DarkColors.foreground,
          fontSize: AppDimensions.font18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: DarkColors.foreground),
      ),

      textTheme: textTheme,

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DarkColors.primary,
          foregroundColor: DarkColors.primaryForeground,
          minimumSize: const Size.fromHeight(48),
          padding: AppDimensions.paddingH24,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius12),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: AppTextTheme.fontFamily,
            fontSize: AppDimensions.font16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DarkColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space16,
        ),
        hintStyle: const TextStyle(
          fontFamily: AppTextTheme.fontFamily,
          color: DarkColors.mutedForeground,
          fontSize: AppDimensions.font14,
        ),
        labelStyle: const TextStyle(
          fontFamily: AppTextTheme.fontFamily,
          color: DarkColors.foreground,
          fontSize: AppDimensions.font14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
          borderSide: const BorderSide(color: DarkColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
          borderSide: const BorderSide(color: DarkColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
          borderSide: const BorderSide(color: DarkColors.ring, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
          borderSide: const BorderSide(color: DarkColors.destructive),
        ),
      ),

      cardTheme: CardThemeData(
        color: DarkColors.card,
        elevation: 0,
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
          side: const BorderSide(color: DarkColors.border),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: DarkColors.card,
        indicatorColor: DarkColors.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: AppTextTheme.fontFamily,
            fontSize: AppDimensions.font12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? DarkColors.primary : DarkColors.mutedForeground,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected ? DarkColors.primary : DarkColors.mutedForeground,
            size: 24,
          );
        }),
      ),
    );
  }
}

/// Helper function for backward compatibility
ThemeData buildAppTheme({
  required Brightness brightness,
  required ColorScheme colorScheme,
  required Color? scaffoldBackgroundColor,
}) {
  return brightness == Brightness.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
}
