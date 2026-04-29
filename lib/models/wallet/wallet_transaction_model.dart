enum WalletTransactionFilter { all, deposit, withdraw, refund }

abstract final class WalletTransactionType {
  static const deposit = 'deposit';
  static const withdraw = 'withdraw';
  static const refund = 'refund';
}

abstract final class WalletTransactionStatus {
  static const pending = 'pending';
  static const approved = 'approved';
  static const rejected = 'rejected';
  static const refunded = 'refunded';
  static const completed = 'completed';
  static const failed = 'failed';
}

class WalletTransactionModel {
  final String id;
  final String type;
  final double amount;
  final String status;
  final String description;
  final DateTime createdAt;

  const WalletTransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.description,
    required this.createdAt,
  });

  WalletTransactionModel copyWith({
    String? id,
    String? type,
    double? amount,
    String? status,
    String? description,
    DateTime? createdAt,
  }) {
    return WalletTransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isCredit =>
      type == WalletTransactionType.deposit ||
      type == WalletTransactionType.refund;

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? WalletTransactionType.deposit,
      amount: (json['amount'] as num? ?? 0).toDouble(),
      status: json['status'] as String? ?? WalletTransactionStatus.pending,
      description: json['description'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'status': status,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
