import 'package:rwnaqk_frontend/modules/orders/data/models/order_details_model.dart';

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
  final OrderDetailsModel? details;

  const OrderModel({
    required this.id,
    required this.createdAt,
    required this.total,
    required this.itemsCount,
    required this.status,
    this.addressLine,
    this.deliveryName,
    this.deliveryPhone,
    this.details,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawTotal = json['total'] ?? json['total_amount'] ?? 0;
    final totalParsed = rawTotal is num
        ? rawTotal.toDouble()
        : double.tryParse(rawTotal.toString()) ?? 0.0;

    DateTime parsedDate;
    if (json['created_at'] is String) {
      parsedDate =
          DateTime.tryParse(json['created_at'] as String) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return OrderModel(
      id: (json['id'] ?? json['order_code'] ?? '').toString(),
      createdAt: parsedDate,
      total: totalParsed,
      itemsCount: json['items_count'] is int
          ? json['items_count'] as int
          : (json['order_items'] is List
              ? (json['order_items'] as List).length
              : 1),
      status: (json['status'] ?? json['delivery_status'] ?? 'pending').toString(),
      addressLine:
          json['address_line']?.toString() ?? json['shipping_address']?.toString(),
      deliveryName: json['delivery_name']?.toString(),
      deliveryPhone: json['delivery_phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'total': total,
      'items_count': itemsCount,
      'status': status,
      if (addressLine != null) 'address_line': addressLine,
      if (deliveryName != null) 'delivery_name': deliveryName,
      if (deliveryPhone != null) 'delivery_phone': deliveryPhone,
    };
  }
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
