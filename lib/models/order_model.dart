class OrderModel {
  final String id;
  final DateTime createdAt;
  final double total;
  final int itemsCount;

  /// مثل: pending, confirmed, shipped, delivered, canceled
  final String status;

  /// Optional
  final String? addressLine;
  final String? deliveryName;
  final String? deliveryPhone;

  const OrderModel({
    required this.id,
    required this.createdAt,
    required this.total,
    required this.itemsCount,
    required this.status,
    this.addressLine,
    this.deliveryName,
    this.deliveryPhone,
  });
}

class OrderStatusStep {
  final String key; // pending/confirmed/shipped/delivered/canceled...
  final String title;
  final String? subtitle;
  final DateTime? time;

  const OrderStatusStep({
    required this.key,
    required this.title,
    this.subtitle,
    this.time,
  });
}