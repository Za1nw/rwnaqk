class CustomerModel {
  final int? id;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? mobile;
  final String? gender;
  final String? avatarUrl;
  final bool? isBanned;
  final DateTime? emailVerifiedAt;
  final double? walletBalance;
  final Map<String, dynamic> raw;

  const CustomerModel({
    this.id,
    this.fullName,
    this.firstName,
    this.lastName,
    this.email,
    this.mobile,
    this.gender,
    this.avatarUrl,
    this.isBanned,
    this.emailVerifiedAt,
    this.walletBalance,
    this.raw = const <String, dynamic>{},
  });

  String? get name => fullName;

  String? get phone => mobile;

  bool get emailVerified => emailVerifiedAt != null;

  bool get hasVerifiedEmail => emailVerifiedAt != null;

  String get displayName {
    final composedName = [
      firstName?.trim() ?? '',
      lastName?.trim() ?? '',
    ].where((value) => value.isNotEmpty).join(' ');

    if (composedName.isNotEmpty) {
      return composedName;
    }

    final resourceName = fullName?.trim() ?? '';

    if (resourceName.isNotEmpty) {
      return resourceName;
    }

    if ((email ?? '').trim().isNotEmpty) {
      return email!.trim();
    }

    return '';
  }

  CustomerModel copyWith({
    int? id,
    String? fullName,
    String? firstName,
    String? lastName,
    String? email,
    String? mobile,
    String? gender,
    String? avatarUrl,
    bool? isBanned,
    DateTime? emailVerifiedAt,
    double? walletBalance,
    Map<String, dynamic>? raw,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isBanned: isBanned ?? this.isBanned,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      walletBalance: walletBalance ?? this.walletBalance,
      raw: raw ?? this.raw,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...raw,
      'id': id,
      'full_name': fullName,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'mobile': mobile,
      'gender': gender,
      'avatar_url': avatarUrl,
      'is_banned': isBanned,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'wallet_balance': walletBalance,
    }..removeWhere((key, value) => value == null);
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final verifiedAt = _toDateTime(json['email_verified_at']);

    return CustomerModel(
      id: _toInt(json['id']),
      fullName: _toString(json['full_name']) ?? _toString(json['name']),
      firstName: _toString(json['first_name']),
      lastName: _toString(json['last_name']),
      email: _toString(json['email']),
      mobile: _toString(json['mobile']) ?? _toString(json['phone']),
      gender: _toString(json['gender']),
      avatarUrl:
          _toString(json['avatar_url']) ?? _toString(json['profile_image']),
      isBanned: _toBool(json['is_banned']),
      emailVerifiedAt: verifiedAt,
      walletBalance:
          _toDouble(json['wallet_balance']) ??
          _toDouble(json['wallet_balance_formatted']),
      raw: Map<String, dynamic>.from(json),
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.tryParse(value.trim());
    }

    return null;
  }

  static String? _toString(dynamic value) {
    if (value == null) {
      return null;
    }

    return value.toString();
  }

  static bool? _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') {
        return true;
      }
      if (normalized == 'false' || normalized == '0') {
        return false;
      }
    }

    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value.trim());
    }

    return null;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value.trim());
    }

    return null;
  }
}
