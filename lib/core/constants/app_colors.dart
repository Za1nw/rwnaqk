import 'package:flutter/material.dart';

/// Abstract final class matching Rawnaquk Designer & Developer Guide (Page 18)
abstract final class BrandColors {
  // Brand Identity Core
  static const Color burgundy = Color(0xFF6E0131); // عنابي ملكي
  static const Color burgundyDark = Color(0xFF500A2A); // عنابي داكن
  static const Color gold = Color(0xFFFAAD01); // ذهبي فاخر
  static const Color deepNight = Color(0xFF140A13); // ليلي عميق
  static const Color lightBackground = Color(0xFFFFFFFF); // أبيض
  static const Color darkBackground = Color(0xFF140A13); // ليلي عميق
  static const Color lightText = Color(0xFF26141E); // نص رئيسي نهاري
  static const Color darkText = Color(0xFFFCFCFC); // أبيض لؤلؤي
}

/// Gradients specified in Rawnaquk Designer & Developer Guide (Page 7)
class BrandGradients {
  BrandGradients._();

  /// Royal Burgundy 135° (#33091F 0% / #6E0131 55% / #920B4E 100%)
  static const LinearGradient royalBurgundy = LinearGradient(
    begin: Alignment(-0.71, -0.71),
    end: Alignment(0.71, 0.71),
    stops: [0.0, 0.55, 1.0],
    colors: [
      Color(0xFF33091F),
      Color(0xFF6E0131),
      Color(0xFF920B4E),
    ],
  );

  /// Luxury Gold 110° (#D78D00 0% / #FAAD01 55% / #FFD669 100%)
  static const LinearGradient luxuryGold = LinearGradient(
    begin: Alignment(-0.87, -0.50),
    end: Alignment(0.87, 0.50),
    stops: [0.0, 0.55, 1.0],
    colors: [
      Color(0xFFD78D00),
      Color(0xFFFAAD01),
      Color(0xFFFFD669),
    ],
  );

  /// Convenient alias for luxuryGold
  static const LinearGradient gold = luxuryGold;

  /// Deep Night 145° (#140A13 0% / #33091F 100%)
  static const LinearGradient deepNight = LinearGradient(
    begin: Alignment(-0.57, -0.82),
    end: Alignment(0.57, 0.82),
    stops: [0.0, 1.0],
    colors: [
      Color(0xFF140A13),
      Color(0xFF33091F),
    ],
  );
}

/// Centralized application color palette based on Rawnaquk Brand Identity Guide (v1.0).
class AppColors {
  AppColors._();

  // 1. Core Brand Colors (Table 5 & 10)
  static const Color burgundy = Color(0xFF6E0131); // عنابي ملكي #6E0131
  static const Color burgundyHover = Color(0xFF500A2A); // عنابي داكن للتحويم #500A2A
  static const Color gold = Color(0xFFFAAD01); // ذهبي فاخر #FAAD01
  static const Color deepNight = Color(0xFF140A13); // ليلي عميق #140A13
  static const Color white = Color(0xFFFFFFFF); // أبيض #FFFFFF
  static const Color pearlWhite = Color(0xFFFCFCFC); // أبيض لؤلؤي #FCFCFC

  // Primary Brand Identity Reference
  static const Color primary = burgundy; // #6E0131
  static const Color primaryLight = burgundy500; // #A6225F
  static const Color primaryDark = burgundy800; // #500A2A

  // Secondary Brand Reference
  static const Color secondary = burgundyHover; // #500A2A
  static const Color secondaryLight = burgundy700; // #6E0131
  static const Color secondaryDark = burgundy900; // #33091F

  // Accent Reference (Gold)
  static const Color accent = gold; // #FAAD01
  static const Color warning = Color(0xFF7B4C06); // تنبيه نهاري #7B4C06

  // Background & Surfaces
  static const Color backgroundLight = Color(0xFFFFFFFF); // نهاري #FFFFFF
  static const Color surfaceVariant = Color(0xFFF8E3ED); // سطحي مساعد (Burgundy 100) #F8E3ED
  static const Color surfaceLight = Color(0xFFFCF8FA); // بطاقة نهارية #FCF8FA
  static const Color onboardingBackground = Color(0xFFFCF8FA);

  // Dark Theme Background & Surface
  static const Color backgroundDark = Color(0xFF140A13); // ليلي عميق #140A13
  static const Color surfaceDark = Color(0xFF24111F); // بطاقة ليلية #24111F

  // Typography Colors (Page 6 & 8)
  static const Color textPrimaryLight = Color(0xFF26141E); // نص رئيسي نهاري #26141E
  static const Color textSecondaryLight = Color(0xFF78606C); // نص ثانوي نهاري #78606C
  static const Color textPrimaryDark = Color(0xFFFCFCFC); // نص رئيسي ليلي (لؤلؤي) #FCFCFC
  static const Color textSecondaryDark = Color(0xFFC8B9C1); // نص ثانوي ليلي #C8B9C1

  // Status & Utility Colors (Page 8)
  static const Color success = Color(0xFF176B45); // نجاح نهاري #176B45
  static const Color successDark = Color(0xFF75D6A5); // نجاح ليلي #75D6A5
  static const Color error = Color(0xFFB42318); // خطأ نهاري #B42318
  static const Color errorDark = Color(0xFFFFB4AB); // خطأ ليلي #FFB4AB
  static const Color warningDark = Color(0xFFFFD454); // تنبيه ليلي #FFD454
  static const Color info = Color(0xFF175CD3); // معلومة نهاري #175CD3
  static const Color infoDark = Color(0xFFA8C7FA); // معلومة ليلي #A8C7FA

  // Borders & Dividers (Page 6 & 8)
  static const Color borderLight = Color(0xFFEADDE4); // فاصل نهاري #EADDE4
  static const Color borderDark = Color(0xFF493244); // فاصل ليلي #493244
  static const Color inputBorderLight = Color(0xFF92717F); // حدود الحقول نهارية #92717F
  static const Color inputBorderDark = Color(0xFF947F8C); // حدود الحقول ليلية #947F8C

  // ----------------------------------------------------
  // Burgundy Scale سلم درجات العنابي (Page 6)
  // ----------------------------------------------------
  static const Color burgundy50 = Color(0xFFFCF2F7); // سطح شديد الخفة
  static const Color burgundy100 = Color(0xFFF8E3ED); // سطح مساعد
  static const Color burgundy200 = Color(0xFFEFC2D5); // حدود وزخارف
  static const Color burgundy300 = Color(0xFFDE91B0); // إبراز خفيف
  static const Color burgundy400 = Color(0xFFC65785); // عناصر زخرفية
  static const Color burgundy500 = Color(0xFFA6225F); // إبراز أساسي
  static const Color burgundy600 = Color(0xFF860E46); // تفاصيل أغمق
  static const Color burgundy700 = Color(0xFF6E0131); // لون العلامة العنابي
  static const Color burgundy800 = Color(0xFF500A2A); // تحويم وعمق
  static const Color burgundy900 = Color(0xFF33091F); // خلفيات داكنة
  static const Color burgundy950 = Color(0xFF1D0714); // سطح شديد الداكنة

  // ----------------------------------------------------
  // Gold Scale سلم درجات الذهبي (Page 6)
  // ----------------------------------------------------
  static const Color gold50 = Color(0xFFFFF9E8);
  static const Color gold100 = Color(0xFFFFF0BD);
  static const Color gold200 = Color(0xFFFFE48A);
  static const Color gold300 = Color(0xFFFFD454);
  static const Color gold400 = Color(0xFFFFC327);
  static const Color gold500 = Color(0xFFFAAD01); // لون الذهبي الأساسي
  static const Color gold600 = Color(0xFFD78D00);
  static const Color gold700 = Color(0xFFA96B00);
  static const Color gold800 = Color(0xFF7B4C06);
  static const Color gold900 = Color(0xFF533406);
}

/// Rawnaquk Light Mode Semantic Tokens (Page 8 Table)
class LightColors {
  static const Color background = AppColors.backgroundLight; // #FFFFFF
  static const Color foreground = AppColors.textPrimaryLight; // #26141E
  static const Color card = AppColors.surfaceLight; // #FCF8FA
  static const Color cardForeground = AppColors.textPrimaryLight; // #26141E
  static const Color popover = AppColors.surfaceLight; // #FCF8FA
  static const Color popoverForeground = AppColors.textPrimaryLight;

  // Semantic Primary (Royal Burgundy for Light)
  static const Color primary = AppColors.burgundy; // #6E0131
  static const Color primaryHover = AppColors.burgundyHover; // #500A2A
  static const Color primaryForeground = AppColors.white; // #FFFFFF

  // Semantic Secondary
  static const Color secondary = AppColors.burgundyHover; // #500A2A
  static const Color secondaryForeground = AppColors.white;

  // Muted Surfaces & Texts
  static const Color muted = AppColors.surfaceVariant; // #F8E3ED (Burgundy 100)
  static const Color mutedForeground = AppColors.textSecondaryLight; // #78606C

  // Accent & Focus
  static const Color accent = AppColors.gold; // #FAAD01
  static const Color accentForeground = AppColors.textPrimaryLight; // #26141E
  static const Color ring = AppColors.burgundy; // #6E0131

  // Status & Utility
  static const Color destructive = AppColors.error; // #B42318
  static const Color success = AppColors.success; // #176B45
  static const Color info = AppColors.info; // #175CD3
  static const Color warning = AppColors.warning; // #7B4C06

  // Borders & Inputs
  static const Color border = AppColors.borderLight; // #EADDE4 (Decorative)
  static const Color input = AppColors.inputBorderLight; // #92717F (Field Border)

  // Charts
  static const Color chart1 = AppColors.burgundy;
  static const Color chart2 = AppColors.burgundy500;
  static const Color chart3 = AppColors.gold;
  static const Color chart4 = AppColors.success;
  static const Color chart5 = AppColors.info;

  // Sidebar
  static const Color sidebar = AppColors.surfaceLight;
  static const Color sidebarForeground = AppColors.textPrimaryLight;

  // Shadow
  static const Color shadow = Color(0x1A26141E);
}

/// Rawnaquk Dark Mode Semantic Tokens (Page 8 Table)
class DarkColors {
  static const Color background = AppColors.backgroundDark; // #140A13
  static const Color foreground = AppColors.textPrimaryDark; // #FCFCFC
  static const Color card = AppColors.surfaceDark; // #24111F
  static const Color cardForeground = AppColors.textPrimaryDark; // #FCFCFC
  static const Color popover = AppColors.surfaceDark; // #24111F
  static const Color popoverForeground = AppColors.textPrimaryDark;

  // Semantic Primary (Luxury Gold for Dark buttons as per guide)
  static const Color primary = AppColors.gold; // #FAAD01
  static const Color primaryHover = Color(0xFFFFC327); // #FFC327
  static const Color primaryForeground = Color(0xFF26141E); // #26141E (Dark text on gold button)

  // Semantic Secondary (Burgundy in dark mode)
  static const Color secondary = AppColors.burgundy; // #6E0131
  static const Color secondaryForeground = AppColors.white;

  // Muted Surfaces & Texts
  static const Color muted = AppColors.burgundy900; // #33091F
  static const Color mutedForeground = AppColors.textSecondaryDark; // #C8B9C1

  // Accent & Focus
  static const Color accent = AppColors.gold; // #FAAD01
  static const Color accentForeground = Color(0xFF26141E);
  static const Color ring = AppColors.gold; // #FAAD01

  // Status & Utility
  static const Color destructive = AppColors.errorDark; // #FFB4AB
  static const Color success = AppColors.successDark; // #75D6A5
  static const Color info = AppColors.infoDark; // #A8C7FA
  static const Color warning = AppColors.warningDark; // #FFD454

  // Borders & Inputs
  static const Color border = AppColors.borderDark; // #493244 (Decorative)
  static const Color input = AppColors.inputBorderDark; // #947F8C (Field Border)

  // Charts
  static const Color chart1 = AppColors.gold;
  static const Color chart2 = AppColors.burgundy300;
  static const Color chart3 = AppColors.successDark;
  static const Color chart4 = AppColors.infoDark;
  static const Color chart5 = AppColors.warningDark;

  // Sidebar
  static const Color sidebar = AppColors.backgroundDark;
  static const Color sidebarForeground = AppColors.textPrimaryDark;

  // Shadow
  static const Color shadow = Color(0x66000000);
}

/// Centralized Material 3 ColorSchemes for Light & Dark Modes
class AppColorSchemes {
  static const ColorScheme light = ColorScheme.light(
    primary: LightColors.primary, // #6E0131
    onPrimary: LightColors.primaryForeground, // #FFFFFF
    secondary: LightColors.secondary, // #500A2A
    onSecondary: LightColors.secondaryForeground, // #FFFFFF
    tertiary: LightColors.accent, // #FAAD01
    onTertiary: LightColors.accentForeground, // #26141E
    surface: LightColors.card, // #FCF8FA
    onSurface: LightColors.foreground, // #26141E
    surfaceContainerHighest: LightColors.muted, // #F8E3ED
    error: LightColors.destructive, // #B42318
    onError: Colors.white,
    outline: LightColors.border, // #EADDE4
    surfaceTint: LightColors.primary,
    shadow: LightColors.shadow,
  );

  static const ColorScheme dark = ColorScheme.dark(
    primary: DarkColors.primary, // #FAAD01
    onPrimary: DarkColors.primaryForeground, // #26141E
    secondary: DarkColors.secondary, // #6E0131
    onSecondary: DarkColors.secondaryForeground, // #FFFFFF
    tertiary: DarkColors.accent, // #FAAD01
    onTertiary: DarkColors.accentForeground, // #26141E
    surface: DarkColors.card, // #24111F
    onSurface: DarkColors.foreground, // #FCFCFC
    surfaceContainerHighest: DarkColors.muted, // #33091F
    error: DarkColors.destructive, // #FFB4AB
    onError: Color(0xFF26141E),
    outline: DarkColors.border, // #493244
    surfaceTint: DarkColors.primary,
    shadow: DarkColors.shadow,
  );
}

/// Context Extension for direct, clean theme color resolution
extension ContextColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  ColorScheme get colors => Theme.of(this).colorScheme;

  Color get background =>
      isDark ? DarkColors.background : LightColors.background;
  Color get foreground =>
      isDark ? DarkColors.foreground : LightColors.foreground;
  Color get card => isDark ? DarkColors.card : LightColors.card;
  Color get border => isDark ? DarkColors.border : LightColors.border;
  Color get primary => isDark ? DarkColors.primary : LightColors.primary;
  Color get primaryForeground =>
      isDark ? DarkColors.primaryForeground : LightColors.primaryForeground;
  Color get secondary => isDark ? DarkColors.secondary : LightColors.secondary;
  Color get secondaryForeground =>
      isDark ? DarkColors.secondaryForeground : LightColors.secondaryForeground;
  Color get muted => isDark ? DarkColors.muted : LightColors.muted;
  Color get mutedForeground =>
      isDark ? DarkColors.mutedForeground : LightColors.mutedForeground;
  Color get accent => isDark ? DarkColors.accent : LightColors.accent;
  Color get accentForeground =>
      isDark ? DarkColors.accentForeground : LightColors.accentForeground;
  Color get destructive =>
      isDark ? DarkColors.destructive : LightColors.destructive;
  Color get input => isDark ? DarkColors.input : LightColors.input;
  Color get ring => isDark ? DarkColors.ring : LightColors.ring;
  Color get popover => isDark ? DarkColors.popover : LightColors.popover;
  Color get popoverForeground =>
      isDark ? DarkColors.popoverForeground : LightColors.popoverForeground;
  Color get chart1 => isDark ? DarkColors.chart1 : LightColors.chart1;
  Color get chart2 => isDark ? DarkColors.chart2 : LightColors.chart2;
  Color get chart3 => isDark ? DarkColors.chart3 : LightColors.chart3;
  Color get chart4 => isDark ? DarkColors.chart4 : LightColors.chart4;
  Color get chart5 => isDark ? DarkColors.chart5 : LightColors.chart5;
  Color get sidebar => isDark ? DarkColors.sidebar : LightColors.sidebar;
  Color get sidebarForeground =>
      isDark ? DarkColors.sidebarForeground : LightColors.sidebarForeground;
  Color get success => isDark ? DarkColors.success : LightColors.success;
  Color get info => isDark ? DarkColors.info : LightColors.info;
  Color get warning => isDark ? DarkColors.warning : LightColors.warning;
  Color get shadow => isDark ? DarkColors.shadow : LightColors.shadow;
}
