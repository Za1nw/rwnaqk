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

  static String whole(num value, {String symbol = '', String suffix = ''}) {
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

  static String commaFormat(num value) {
    final str = value.toStringAsFixed(0);
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (m) => '${m[1]},');
  }

  static String riyal(num value) {
    return '${commaFormat(value)} ر.ي';
  }
}
