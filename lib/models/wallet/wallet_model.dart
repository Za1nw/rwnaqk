class WalletModel {
  final String id;
  final double balance;
  final String currency;
  final DateTime updatedAt;

  const WalletModel({
    required this.id,
    required this.balance,
    required this.currency,
    required this.updatedAt,
  });

  WalletModel copyWith({
    String? id,
    double? balance,
    String? currency,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String? ?? '',
      balance: (json['balance'] as num? ?? 0).toDouble(),
      currency: json['currency'] as String? ?? 'YER',
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'balance': balance,
      'currency': currency,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
