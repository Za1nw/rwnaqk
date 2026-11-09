class OrderDetailsItem {
  final String title;
  final String subtitle;
  final int quantity;
  final double unitPrice;

  const OrderDetailsItem({
    required this.title,
    required this.subtitle,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderDetailsItem.fromJson(Map<String, dynamic> json) {
    final rawQty = json['quantity'] ?? json['qty'] ?? 1;
    final qty = rawQty is num
        ? rawQty.toInt()
        : int.tryParse(rawQty.toString()) ?? 1;
    final rawPrice = json['unit_price'] ?? json['price'] ?? 0.0;
    final price = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice.toString()) ?? 0.0;

    return OrderDetailsItem(
      title: (json['title'] ?? json['product_name'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? json['sku'] ?? '').toString(),
      quantity: qty,
      unitPrice: price,
    );
  }

  double get lineTotal => quantity * unitPrice;
}

class OrderDetailsModel {
  final List<OrderDetailsItem> items;
  final double subtotal;
  final double shippingFee;
  final double discountAmount;
  final String shippingMethodKey;
  final String paymentMethodKey;
  final String deliveryName;
  final String deliveryPhone;
  final String addressLine;

  const OrderDetailsModel({
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    this.discountAmount = 0.0,
    required this.shippingMethodKey,
    required this.paymentMethodKey,
    required this.deliveryName,
    required this.deliveryPhone,
    required this.addressLine,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    final detailsMap = json['details'] is Map<String, dynamic>
        ? json['details'] as Map<String, dynamic>
        : json;

    final rawItems = detailsMap['items'] ?? json['items'] ?? const [];
    final itemsList = (rawItems is List ? rawItems : const [])
        .whereType<Map<String, dynamic>>()
        .map((e) => OrderDetailsItem.fromJson(e))
        .toList();

    final rawSubtotal = detailsMap['subtotal'] ?? json['subtotal'] ?? 0.0;
    final subtotal = rawSubtotal is num
        ? rawSubtotal.toDouble()
        : double.tryParse(rawSubtotal.toString()) ?? 0.0;

    final rawShipping = detailsMap['shippingFee'] ??
        detailsMap['shipping_fee'] ??
        json['shipping_fee'] ??
        0.0;
    final shippingFee = rawShipping is num
        ? rawShipping.toDouble()
        : double.tryParse(rawShipping.toString()) ?? 0.0;

    final rawDiscount = detailsMap['discountAmount'] ??
        detailsMap['discount_amount'] ??
        json['discount_amount'] ??
        0.0;
    final discountAmount = rawDiscount is num
        ? rawDiscount.toDouble()
        : double.tryParse(rawDiscount.toString()) ?? 0.0;

    return OrderDetailsModel(
      items: itemsList,
      subtotal: subtotal,
      shippingFee: shippingFee,
      discountAmount: discountAmount,
      shippingMethodKey: (detailsMap['shippingMethodKey'] ??
              detailsMap['shipping_method'] ??
              json['logistic_name'] ??
              '')
          .toString(),
      paymentMethodKey: (detailsMap['paymentMethodKey'] ??
              detailsMap['payment_method'] ??
              json['payment_method'] ??
              '')
          .toString(),
      deliveryName: (detailsMap['deliveryName'] ??
              detailsMap['delivery_name'] ??
              json['delivery_name'] ??
              '')
          .toString(),
      deliveryPhone: (detailsMap['deliveryPhone'] ??
              detailsMap['delivery_phone'] ??
              json['delivery_phone'] ??
              '')
          .toString(),
      addressLine: (detailsMap['addressLine'] ??
              detailsMap['address_line'] ??
              json['address_line'] ??
              '')
          .toString(),
    );
  }

  double get total =>
      (subtotal - discountAmount + shippingFee).clamp(0.0, double.infinity);

  String get paymentMethod => paymentMethodKey;
  String get shippingMethod => shippingMethodKey;
}
