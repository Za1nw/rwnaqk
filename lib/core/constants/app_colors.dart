import 'package:flutter/material.dart';

class LightColors {
  static const background = Color(0xFFF3F6FA);
  static const foreground = Color(0xFF1F2937);
  static const card = Color(0xFFF7FAFD);
  static const cardForeground = Color(0xFF1F2937);
  static const popover = Color(0xFFEEF3F8);
  static const popoverForeground = Color(0xFF1F2937);
  static const primary = Color(0xFF2563EB);
  static const primaryForeground = Color(0xFFFFFFFF);
  static const secondary = Color(0xFFE2E8F0);
  static const secondaryForeground = Color(0xFF334155);
  static const muted = Color(0xFF64748B);
  static const mutedForeground = Color(0xFF64748B);
  static const accent = Color(0xFFDCE7FF);
  static const accentForeground = Color(0xFF1E40AF);
  static const destructive = Color(0xFFDC2626);
  static const border = Color(0xFFE2E8F0);
  static const input = Color(0xFFEDF3F8);
  static const ring = Color(0xFF2563EB);

  static const chart1 = Color(0xFF2563EB);
  static const chart2 = Color(0xFF06B6D4);
  static const chart3 = Color(0xFF6366F1);
  static const chart4 = Color(0xFF22C55E);
  static const chart5 = Color(0xFF0EA5E9);
  static const sidebar = Color(0xFFF3F6FA);
  static const sidebarForeground = Color(0xFF1F2937);
  static const success = Color(0xFF22C55E);
  static const info = Color(0xFF0EA5E9);
  static const warning = Color(0xFFF59E0B);

  // Shadow
  static const shadow = Color(0x1A000000);
}

class DarkColors {
  static const background = Color(0xFF0F172A);
  static const foreground = Color(0xFFF8FAFC);
  static const card = Color(0xFF1E293B);
  static const cardForeground = Color(0xFFF8FAFC);
  static const popover = Color(0xFF1E293B);
  static const popoverForeground = Color(0xFFF8FAFC);
  static const primary = Color(0xFF3B82F6);
  static const primaryForeground = Color(0xFFFFFFFF);
  static const secondary = Color(0xFF334155);
  static const secondaryForeground = Color(0xFFF1F5F9);
  static const muted = Color(0xFF334155);
  static const mutedForeground = Color(0xFF94A3B8);
  static const accent = Color(0xFF1E3A8A);
  static const accentForeground = Color(0xFFE0E7FF);
  static const destructive = Color(0xFFEF4444);
  static const border = Color(0xFF334155);
  static const input = Color(0xFF1E293B);
  static const ring = Color(0xFF3B82F6);

  static const chart1 = Color(0xFF3B82F6);
  static const chart2 = Color(0xFF22D3EE);
  static const chart3 = Color(0xFF818CF8);
  static const chart4 = Color(0xFF4ADE80);
  static const chart5 = Color(0xFF38BDF8);
  static const sidebar = Color(0xFF020617);
  static const sidebarForeground = Color(0xFFF8FAFC);
  static const success = Color(0xFF22C55E);
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
