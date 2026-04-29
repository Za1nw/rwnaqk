class RefundStatusModel {
  final String refundId;
  final String orderId;
  final double amount;
  final String status;
  final String message;

  const RefundStatusModel({
    required this.refundId,
    required this.orderId,
    required this.amount,
    required this.status,
    required this.message,
  });

  RefundStatusModel copyWith({
    String? refundId,
    String? orderId,
    double? amount,
    String? status,
    String? message,
  }) {
    return RefundStatusModel(
      refundId: refundId ?? this.refundId,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  factory RefundStatusModel.fromJson(Map<String, dynamic> json) {
    return RefundStatusModel(
      refundId: json['refundId'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      amount: (json['amount'] as num? ?? 0).toDouble(),
      status: json['status'] as String? ?? 'pending',
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'refundId': refundId,
      'orderId': orderId,
      'amount': amount,
      'status': status,
      'message': message,
    };
  }
}
