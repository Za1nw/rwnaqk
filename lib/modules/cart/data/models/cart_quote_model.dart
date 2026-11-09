/// نموذج بيانات عرض سعر السلة والتوصيل والخصومات الوارد من خادم Laravel
class CartQuoteModel {
  const CartQuoteModel({
    required this.currency,
    required this.currencySymbol,
    required this.isServiceable,
    this.addressId,
    required this.items,
    required this.subtotal,
    required this.productDiscountTotal,
    required this.netSubtotal,
    this.couponCode,
    required this.couponDiscountTotal,
    required this.shippingFee,
    required this.grandTotal,
    required this.shippingOptions,
    this.selectedShippingOption,
    this.message,
  });

  final String currency;
  final String currencySymbol;
  final bool isServiceable;
  final int? addressId;
  final List<CartQuoteItemModel> items;
  final double subtotal;
  final double productDiscountTotal;
  final double netSubtotal;
  final String? couponCode;
  final double couponDiscountTotal;
  final double shippingFee;
  final double grandTotal;
  final List<CartShippingOptionModel> shippingOptions;
  final CartShippingOptionModel? selectedShippingOption;
  final String? message;

  factory CartQuoteModel.fromJson(Map<String, dynamic> json) {
    return CartQuoteModel(
      currency: (json['currency'] ?? 'YER').toString(),
      currencySymbol: (json['currency_symbol'] ?? 'ر.ي').toString(),
      isServiceable: json['is_serviceable'] == true,
      addressId: json['address_id'] != null
          ? int.tryParse(json['address_id'].toString())
          : null,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) =>
                  CartQuoteItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
      subtotal: _toDouble(json['subtotal']),
      productDiscountTotal: _toDouble(json['product_discount_total']),
      netSubtotal: _toDouble(json['net_subtotal']),
      couponCode: json['coupon_code']?.toString(),
      couponDiscountTotal: _toDouble(json['coupon_discount_total']),
      shippingFee: _toDouble(json['shipping_fee']),
      grandTotal: _toDouble(json['grand_total']),
      shippingOptions: (json['shipping_options'] as List<dynamic>?)
              ?.map((opt) =>
                  CartShippingOptionModel.fromJson(opt as Map<String, dynamic>))
              .toList() ??
          const [],
      selectedShippingOption: json['selected_shipping_option'] != null
          ? CartShippingOptionModel.fromJson(
              json['selected_shipping_option'] as Map<String, dynamic>)
          : null,
      message: json['message']?.toString(),
    );
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }
}

/// تفاصيل سطر المنتج المحسوب من السيرفر
class CartQuoteItemModel {
  const CartQuoteItemModel({
    required this.productId,
    required this.productVariationId,
    required this.name,
    required this.sku,
    required this.qty,
    required this.unitPrice,
    required this.unitDiscount,
    required this.effectiveUnitPrice,
    required this.lineSubtotal,
    required this.lineProductDiscount,
    required this.lineTotal,
  });

  final int productId;
  final int productVariationId;
  final String name;
  final String sku;
  final int qty;
  final double unitPrice;
  final double unitDiscount;
  final double effectiveUnitPrice;
  final double lineSubtotal;
  final double lineProductDiscount;
  final double lineTotal;

  factory CartQuoteItemModel.fromJson(Map<String, dynamic> json) {
    return CartQuoteItemModel(
      productId: int.tryParse(json['product_id']?.toString() ?? '0') ?? 0,
      productVariationId:
          int.tryParse(json['product_variation_id']?.toString() ?? '0') ?? 0,
      name: (json['name'] ?? '').toString(),
      sku: (json['sku'] ?? '').toString(),
      qty: int.tryParse(json['qty']?.toString() ?? '1') ?? 1,
      unitPrice: CartQuoteModel._toDouble(json['unit_price']),
      unitDiscount: CartQuoteModel._toDouble(json['unit_discount']),
      effectiveUnitPrice:
          CartQuoteModel._toDouble(json['effective_unit_price']),
      lineSubtotal: CartQuoteModel._toDouble(json['line_subtotal']),
      lineProductDiscount:
          CartQuoteModel._toDouble(json['line_product_discount']),
      lineTotal: CartQuoteModel._toDouble(json['line_total']),
    );
  }
}

/// خيار الشحن والتوصيل الجغرافي المسترجع من السيرفر
class CartShippingOptionModel {
  const CartShippingOptionModel({
    required this.id,
    required this.name,
    required this.zoneName,
    required this.fee,
    required this.formattedFee,
    required this.durationMinutes,
    required this.durationText,
  });

  final String id;
  final String name;
  final String zoneName;
  final double fee;
  final String formattedFee;
  final int durationMinutes;
  final String durationText;

  factory CartShippingOptionModel.fromJson(Map<String, dynamic> json) {
    return CartShippingOptionModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      zoneName: (json['zone_name'] ?? '').toString(),
      fee: CartQuoteModel._toDouble(json['fee']),
      formattedFee: (json['formatted_fee'] ?? '').toString(),
      durationMinutes:
          int.tryParse(json['duration_minutes']?.toString() ?? '0') ?? 0,
      durationText: (json['duration_text'] ?? '').toString(),
    );
  }
}

