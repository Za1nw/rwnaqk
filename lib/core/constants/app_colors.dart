import 'package:flutter/material.dart';

class LightColors {
  // الألوان الرئيسية للهوية الجديدة (النسخة الفاتحة)
  static const background = Color(0xFFFFFFFF); // أبيض للخلفية
  static const foreground = Color(0xFF101626); // brand-ink للنص الرئيسي
  static const card = Color(0xFFF8FAFC); // فاتح قليلاً للبطاقات
  static const cardForeground = Color(0xFF101626); // brand-ink
  static const popover = Color(0xFFFFFFFF);
  static const popoverForeground = Color(0xFF101626);
  static const primary = Color(0xFFDE706B); // brand-main (اللون الأساسي)
  static const primaryForeground = Color(0xFFFFFFFF); // أبيض للنص على الأساسي
  static const secondary = Color(0xFFD88869); // brand-secondary
  static const secondaryForeground = Color(0xFFFFFFFF);
  static const muted = Color(0xFFF1F5F9);
  static const mutedForeground = Color(0xFFA7B2C0); // brand-slate
  static const accent = Color(0xFFFF7378); // brand-coral
  static const accentForeground = Color(0xFFFFFFFF);
  static const destructive = Color(0xFFDE706B); // استخدام brand-main لل destructive
  static const border = Color(0xFFE2E8F0);
  static const input = Color(0xFFF1F5F9);
  static const ring = Color(0xFFDE706B); // brand-main

  // ألوان المخططات (charts)
  static const chart1 = Color(0xFFDE706B); // brand-main
  static const chart2 = Color(0xFFD88869); // brand-secondary
  static const chart3 = Color(0xFFFF7378); // brand-coral
  static const chart4 = Color(0xFFA7B2C0); // brand-slate
  static const chart5 = Color(0xFF061A2C); // brand-teal
  
  static const sidebar = Color(0xFFFFFFFF);
  static const sidebarForeground = Color(0xFF101626); // brand-ink
  
  // حالة الألوان
  static const success = Color(0xFF22C55E); // تم الإبقاء عليه (أخضر)
  static const info = Color(0xFF0EA5E9); // تم الإبقاء عليه (أزرق فاتح)
  static const warning = Color(0xFFF59E0B); // تم الإبقاء عليه (برتقالي)

  // Shadow
  static const shadow = Color(0x1A000000);
}

class DarkColors {
  // الألوان الرئيسية للهوية الجديدة (النسخة الداكنة)
  static const background = Color(0xFF061A2C); // brand-teal للخلفية الداكنة
  static const foreground = Color(0xFFF8FAFC); // فاتح للنص في الوضع الداكن
  static const card = Color(0xFF0F1E2E); // أغمق قليلاً من الخلفية
  static const cardForeground = Color(0xFFF8FAFC);
  static const popover = Color(0xFF0F1E2E);
  static const popoverForeground = Color(0xFFF8FAFC);
  static const primary = Color(0xFFDE706B); // brand-main
  static const primaryForeground = Color(0xFFFFFFFF);
  static const secondary = Color(0xFFD88869); // brand-secondary
  static const secondaryForeground = Color(0xFFFFFFFF);
  static const muted = Color(0xFF0F1E2E);
  static const mutedForeground = Color(0xFFA7B2C0); // brand-slate
  static const accent = Color(0xFFFF7378); // brand-coral
  static const accentForeground = Color(0xFFFFFFFF);
  static const destructive = Color(0xFFFF7378); // brand-coral لل destructive في الداكن
  static const border = Color(0xFF1A2A3A);
  static const input = Color(0xFF0F1E2E);
  static const ring = Color(0xFFDE706B); // brand-main

  // ألوان المخططات (charts) - نفس الألوان مع تعديل بسيط للتباين
  static const chart1 = Color(0xFFDE706B);
  static const chart2 = Color(0xFFD88869);
  static const chart3 = Color(0xFFFF7378);
  static const chart4 = Color(0xFFA7B2C0);
  static const chart5 = Color(0xFF3B7A9E); // نسخة أفتح من brand-teal للتباين
  
  static const sidebar = Color(0xFF061A2C);
  static const sidebarForeground = Color(0xFFF8FAFC);
  
  // حالة الألوان للوضع الداكن
  static const success = Color(0xFF4ADE80);
  static const info = Color(0xFF38BDF8);
  static const warning = Color(0xFFFBBF24);

  // Shadow
  static const shadow = Color(0x66000000);
}

// ColorSchemes مركزية (مصدر الحقيقة للألوان داخل ThemeData)
class AppColorSchemes {
  static const ColorScheme light = ColorScheme.light(
    primary: LightColors.primary,
    onPrimary: LightColors.primaryForeground,
    secondary: LightColors.secondary,
    onSecondary: LightColors.secondaryForeground,
    surface: LightColors.card,
    onSurface: LightColors.cardForeground,
    background: LightColors.background,
    onBackground: LightColors.foreground,
    error: LightColors.destructive,
    onError: Colors.white,
    outline: LightColors.border,
    surfaceTint: LightColors.primary,
    shadow: LightColors.shadow,
  );

  static const ColorScheme dark = ColorScheme.dark(
    primary: DarkColors.primary,
    onPrimary: DarkColors.primaryForeground,
    secondary: DarkColors.secondary,
    onSecondary: DarkColors.secondaryForeground,
    surface: DarkColors.card,
    onSurface: DarkColors.cardForeground,
    background: DarkColors.background,
    onBackground: DarkColors.foreground,
    error: DarkColors.destructive,
    onError: Colors.white,
    outline: DarkColors.border,
    surfaceTint: DarkColors.primary,
    shadow: DarkColors.shadow,
  );
}

// امتداد سياقي للوصول للألوان من الـ Theme مباشرةً
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