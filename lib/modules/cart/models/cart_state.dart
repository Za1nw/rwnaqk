import 'package:flutter/foundation.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

/// سطر عنصر السلة غير القابل للتعديل المباشر (Immutable Cart Line Item)
@immutable
class CartLineItem {
  const CartLineItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    this.variantText,
    this.stableVariantId,
    this.productVariationId,
    this.rating,
    this.reviewsCount,
    required this.originalProduct,
  });

  /// المعرف الفريد للسطر داخل السلة (مثل: prod_99_color:red|size:M أو prod_99)
  final String id;

  /// معرف المنتج الأساسي في الكتالوج
  final String productId;

  /// عنوان المنتج
  final String title;

  /// صورة المنتج
  final String imageUrl;

  /// سعر الوحدة بعد تطبيق أي خصم مباشر للمنتج
  final double unitPrice;

  /// الكمية المطلوبة (يجب أن تكون 1 على الأقل)
  final int quantity;

  /// النص التوضيحي للمتغيرات المعروض للمستخدم (مترجم)
  final String? variantText;

  /// المعرف المستقر للمتغيرات غير المعتمد على اللغة أو الترتيب
  final String? stableVariantId;

  /// معرف المتغير الرقمي في خادم Laravel (product_variation_id) إن وُجد
  final int? productVariationId;

  /// تقييم المنتج
  final double? rating;

  /// عدد المراجعات
  final int? reviewsCount;

  /// كائن المنتج الأصلي لدعم التوافقية السلسة مع سائر الشاشات
  final HomeProductItem originalProduct;

  /// إجمالي قيمة السطر = سعر الوحدة × الكمية
  double get lineTotal => unitPrice * quantity;

  CartLineItem copyWith({
    String? id,
    String? productId,
    String? title,
    String? imageUrl,
    double? unitPrice,
    int? quantity,
    String? variantText,
    String? stableVariantId,
    int? productVariationId,
    double? rating,
    int? reviewsCount,
    HomeProductItem? originalProduct,
  }) {
    return CartLineItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      variantText: variantText ?? this.variantText,
      stableVariantId: stableVariantId ?? this.stableVariantId,
      productVariationId: productVariationId ?? this.productVariationId,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      originalProduct: originalProduct ?? this.originalProduct,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartLineItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          productId == other.productId &&
          title == other.title &&
          imageUrl == other.imageUrl &&
          unitPrice == other.unitPrice &&
          quantity == other.quantity &&
          variantText == other.variantText &&
          stableVariantId == other.stableVariantId &&
          productVariationId == other.productVariationId &&
          rating == other.rating &&
          reviewsCount == other.reviewsCount;

  @override
  int get hashCode => Object.hash(
        id,
        productId,
        title,
        imageUrl,
        unitPrice,
        quantity,
        variantText,
        stableVariantId,
        productVariationId,
        rating,
        reviewsCount,
      );
}

/// حالة السلة غير القابلة للتغيير (Immutable Cart State)
@immutable
class CartState {
  const CartState({
    this.items = const [],
  });

  /// قائمة أسطر السلة
  final List<CartLineItem> items;

  /// هل السلة فارغة؟
  bool get isEmpty => items.isEmpty;

  /// هل السلة تحتوي على عناصر؟
  bool get isNotEmpty => items.isNotEmpty;

  /// عدد الأسطر الفريدة في السلة
  int get linesCount => items.length;

  /// إجمالي عدد القطع والوحدات داخل السلة
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
  int get itemCount => totalQuantity;
  int get itemsCount => totalQuantity;

  /// الإجمالي الفرعي لأسعار المنتجات في السلة بدون شحن أو خصم الكوبون
  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + item.lineTotal);

  /// معرفة كمية سطر معين
  int quantityOf(String lineId) {
    for (final item in items) {
      if (item.id == lineId || item.productId == lineId) return item.quantity;
    }
    return 0;
  }

  /// البحث عن سطر بالمعرف
  CartLineItem? findLine(String lineId) {
    for (final item in items) {
      if (item.id == lineId || item.productId == lineId) return item;
    }
    return null;
  }

  CartState copyWith({
    List<CartLineItem>? items,
  }) {
    return CartState(
      items: items ?? this.items,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartState &&
          runtimeType == other.runtimeType &&
          listEquals(items, other.items);

  @override
  int get hashCode => Object.hashAll(items);
}

