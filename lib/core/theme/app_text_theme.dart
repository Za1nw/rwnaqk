import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/constants/app_dimensions.dart';

/// Centralized TextTheme using bundled Cairo font family according to Rawnaquk Design Guide.
/// Implements typography scale from 10 to 44 with exact contrast-compliant brand colors.
class AppTextTheme {
  AppTextTheme._();

  static const String fontFamily = 'Cairo';

  /// Base Cairo TextStyle builder helper
  static TextStyle cairo({
    double fontSize = AppDimensions.font14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Light TextTheme using Cairo font (Sizes: 10 - 44)
  static TextTheme get lightTextTheme {
    return TextTheme(
      // 44pt - Hero / Banner
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font44,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryLight, // #26141E
        height: 1.2,
      ),
      // 36pt - Screen Big Titles
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font36,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryLight, // #26141E
        height: 1.25,
      ),
      // 32pt - Main Headings
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryLight, // #26141E
        height: 1.3,
      ),
      // 28pt - Section Headlines
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryLight, // #26141E
        height: 1.3,
      ),
      // 24pt - Card / Dialog Titles
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight, // #26141E
        height: 1.35,
      ),
      // 20pt - Sub-headlines
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight, // #26141E
        height: 1.4,
      ),
      // 18pt - AppBar & List Group Headers
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight, // #26141E
        height: 1.4,
      ),
      // 16pt - Card Subtitles & Form Labels
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight, // #26141E
        height: 1.45,
      ),
      // 14pt - Small Titles & Table Headers
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondaryLight, // #78606C
        height: 1.45,
      ),
      // 16pt - Primary Body Text
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimaryLight, // #26141E
        height: 1.5,
      ),
      // 14pt - Secondary Body Text
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font14,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimaryLight, // #26141E
        height: 1.5,
      ),
      // 12pt - Captions & Notes
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font12,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondaryLight, // #78606C
        height: 1.5,
      ),
      // 14pt - Button Text
      labelLarge: const TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font14,
        fontWeight: FontWeight.w600,
        color: LightColors.primaryForeground, // #FFFFFF
        height: 1.4,
      ),
      // 12pt - Badges & Tags
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondaryLight, // #78606C
        height: 1.4,
      ),
      // 10pt - Micro Labels & Timestamps
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font10,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondaryLight, // #78606C
        height: 1.4,
      ),
    );
  }

  /// Dark TextTheme using Cairo font (Sizes: 10 - 44)
  static TextTheme get darkTextTheme {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font44,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryDark, // #FCFCFC
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font36,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryDark, // #FCFCFC
        height: 1.25,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryDark, // #FCFCFC
        height: 1.3,
      ),
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryDark, // #FCFCFC
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark, // #FCFCFC
        height: 1.35,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark, // #FCFCFC
        height: 1.4,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark, // #FCFCFC
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark, // #FCFCFC
        height: 1.45,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondaryDark, // #C8B9C1
        height: 1.45,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimaryDark, // #FCFCFC
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font14,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimaryDark, // #FCFCFC
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font12,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondaryDark, // #C8B9C1
        height: 1.5,
      ),
      // 14pt - Button Text (Dark mode button is gold, so text is dark for 9.19:1 contrast)
      labelLarge: const TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font14,
        fontWeight: FontWeight.w600,
        color: DarkColors.primaryForeground, // #26141E
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondaryDark, // #C8B9C1
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: AppDimensions.font10,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondaryDark, // #C8B9C1
        height: 1.4,
      ),
    );
  }
}
