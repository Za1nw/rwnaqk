class AppBreakpoints {
  static const double compact = 520;
  static const double medium = 760;
  static const double large = 900;

  static bool isCompact(double width) => width < compact;
  static bool isMedium(double width) => width >= compact && width < medium;
  static bool isLarge(double width) => width >= large;

  static int productGridColumns(double width) {
    if (width >= large) return 4;
    if (width >= compact) return 3;
    return 2;
  }
}
