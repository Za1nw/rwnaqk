class AppMaskUtils {
  AppMaskUtils._();

  static String maskPhone(String phone) {
    if (phone.length <= 6) return phone;

    final start = phone.substring(0, 3);
    final end = phone.substring(phone.length - 2);

    return '$start******$end';
  }

  static String maskEmail(String email) {
    final parts = email.split('@');

    if (parts.length != 2) return email;

    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 2) {
      return '$name***@$domain';
    }

    final start = name.substring(0, 2);
    return '$start***@$domain';
  }
}