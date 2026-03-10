class AppMoneyUtils {
  AppMoneyUtils._();

  static String format(
    num value, {
    int digits = 2,
    String symbol = '',
    String suffix = '',
    bool trimZeroDecimals = false,
  }) {
    String text = value.toStringAsFixed(digits);

    if (trimZeroDecimals && digits > 0) {
      final zeroTail = '.${'0' * digits}';
      if (text.endsWith(zeroTail)) {
        text = value.toStringAsFixed(0);
      }
    }

    return '$symbol$text$suffix';
  }

  static String whole(
    num value, {
    String symbol = '',
    String suffix = '',
  }) {
    return '$symbol${value.toStringAsFixed(0)}$suffix';
  }

  static String currency(
    num value, {
    String symbol = r'$',
    int digits = 2,
    bool trimZeroDecimals = false,
  }) {
    return format(
      value,
      digits: digits,
      symbol: symbol,
      trimZeroDecimals: trimZeroDecimals,
    );
  }

  static String riyal(num value) {
    return whole(value, suffix: ' ر.ي');
  }
}