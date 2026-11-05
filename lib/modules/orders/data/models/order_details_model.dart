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

  double get lineTotal => quantity * unitPrice;
}

class OrderDetailsModel {
  final List<OrderDetailsItem> items;
  final double subtotal;
  final double shippingFee;
  final String shippingMethodKey;
  final String paymentMethodKey;
  final String deliveryName;
  final String deliveryPhone;
  final String addressLine;

  const OrderDetailsModel({
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.shippingMethodKey,
    required this.paymentMethodKey,
    required this.deliveryName,
    required this.deliveryPhone,
    required this.addressLine,
  });

  double get total => subtotal + shippingFee;
}
