import 'package:flutter/material.dart';

class AppDateUtils {
  AppDateUtils._();

  static String pad2(int value) {
    return value.toString().padLeft(2, '0');
  }

  static String monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final safeIndex = (month - 1).clamp(0, 11);
    return months[safeIndex];
  }

  static String formatYmd(DateTime date, {String separator = '/'}) {
    return '${date.year}$separator${pad2(date.month)}$separator${pad2(date.day)}';
  }

  static String formatHm(DateTime date, {String separator = ':'}) {
    return '${pad2(date.hour)}$separator${pad2(date.minute)}';
  }

  static String formatYmdHm(
    DateTime date, {
    String dateSeparator = '/',
    String timeSeparator = ':',
    String between = '  ',
  }) {
    return '${formatYmd(date, separator: dateSeparator)}$between${formatHm(date, separator: timeSeparator)}';
  }

  static String formatTimer({
    required int hh,
    required int mm,
    required int ss,
    String separator = ':',
  }) {
    return '${pad2(hh)}$separator${pad2(mm)}$separator${pad2(ss)}';
  }

  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String formatMonthDay(DateTime date, {String separator = ', '}) {
    return '${monthName(date.month)}$separator${date.day}';
  }

  static String formatPriceRangeLabel(RangeValues values, {String symbol = r'$'}) {
    return '$symbol${values.start.toInt()} — $symbol${values.end.toInt()}';
  }
}