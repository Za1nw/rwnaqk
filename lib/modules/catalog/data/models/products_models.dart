import 'package:flutter/foundation.dart';

/// تركيبة سمة المتغير (Color, Size, Material, etc.) القادمة من Laravel API
@immutable
class ProductVariationCombination {
  final int variationId;
  final String variationName;
  final int valueId;
  final String valueName;
  final String valueColor;

  const ProductVariationCombination({
    required this.variationId,
    required this.variationName,
    required this.valueId,
    required this.valueName,
    required this.valueColor,
  });

  factory ProductVariationCombination.fromJson(Map<String, dynamic> json) {
    return ProductVariationCombination(
      variationId: int.tryParse(json['variation_id']?.toString() ?? '') ?? 0,
      variationName: (json['variation_name'] ?? '').toString(),
      valueId: int.tryParse(json['value_id']?.toString() ?? '') ?? 0,
      valueName: (json['value_name'] ?? '').toString(),
      valueColor: (json['value_color'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'variation_id': variationId,
    'variation_name': variationName,
    'value_id': valueId,
    'value_name': valueName,
    'value_color': valueColor,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductVariationCombination &&
        other.variationId == variationId &&
        other.variationName == variationName &&
        other.valueId == valueId &&
        other.valueName == valueName &&
        other.valueColor == valueColor;
  }

  @override
  int get hashCode =>
      Object.hash(variationId, variationName, valueId, valueName, valueColor);
}

/// تمثيل متغير المنتج (Product Variation) القادم من Laravel API
@immutable
class ProductVariationItem {
  final int id;
  final String sku;
  final String? code;
  final double price;
  final int stockQty;
  final List<ProductVariationCombination> combinations;

  const ProductVariationItem({
    required this.id,
    required this.sku,
    this.code,
    required this.price,
    required this.stockQty,
    this.combinations = const [],
  });

  factory ProductVariationItem.fromJson(Map<String, dynamic> json) {
    final rawCombos = json['combinations'] as List? ?? const [];
    final combos = rawCombos
        .whereType<Map>()
        .map(
          (e) => ProductVariationCombination.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();

    final rawPrice = json['price'] ?? 0;
    final parsedPrice = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice.toString()) ?? 0.0;

    return ProductVariationItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      sku: (json['sku'] ?? '').toString(),
      code: json['code']?.toString(),
      price: parsedPrice,
      stockQty: int.tryParse(json['stock_qty']?.toString() ?? '0') ?? 0,
      combinations: combos,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sku': sku,
    'code': code,
    'price': price,
    'stock_qty': stockQty,
    'combinations': combinations.map((e) => e.toJson()).toList(),
  };

  /// فحص مطابقة المتغير للخيارات التي حددها المستخدم ديناميكياً لكافة أنواع الخصائص
  bool matches({
    String? selectedColorId,
    String? selectedColorName,
    String? selectedSize,
    Map<String, String>? selectedAttributes,
  }) {
    final hasColor = (selectedColorId != null && selectedColorId.isNotEmpty) ||
        (selectedColorName != null && selectedColorName.isNotEmpty);
    final hasSize = selectedSize != null && selectedSize.isNotEmpty;
    final hasAttrs = selectedAttributes != null &&
        selectedAttributes.values.any((v) => v.trim().isNotEmpty);

    // إذا لم يتم تحديد أي معيار للبحث، فلا يوجد تطابق محدد
    if (!hasColor && !hasSize && !hasAttrs) {
      return false;
    }

    for (final combo in combinations) {
      final varIdStr = combo.variationId.toString();
      final varName = combo.variationName.trim();
      final varNameLower = varName.toLowerCase();

      final selectedVal = selectedAttributes?[varIdStr] ??
          selectedAttributes?[varName] ??
          selectedAttributes?[varNameLower] ??
          (varNameLower.contains('color') || varNameLower.contains('لون')
              ? (selectedColorId ?? selectedColorName)
              : null) ??
          (varNameLower.contains('size') || varNameLower.contains('مقاس')
              ? selectedSize
              : null);

      if (selectedVal != null && selectedVal.isNotEmpty) {
        final target = selectedVal.trim().toLowerCase();
        final matchValueId = combo.valueId.toString() == selectedVal;
        final matchValueName = combo.valueName.trim().toLowerCase() == target;
        final matchValueColor = combo.valueColor.trim().toLowerCase() == target;

        if (!matchValueId && !matchValueName && !matchValueColor) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductVariationItem &&
        other.id == id &&
        other.sku == sku &&
        other.code == code &&
        other.price == price &&
        other.stockQty == stockQty &&
        listEquals(other.combinations, combinations);
  }

  @override
  int get hashCode =>
      Object.hash(id, sku, code, price, stockQty, Object.hashAll(combinations));
}
