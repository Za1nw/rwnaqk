import 'package:flutter/foundation.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_mock_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_attribute_group.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_color_option.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_review.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_size_guide.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

/// الحالة غير القابلة للتعديل لشاشة تفاصيل المنتج [ProductDetailsState]
@immutable
class ProductDetailsState {
  const ProductDetailsState({
    this.product,
    this.isLoading = false,
    this.errorMessage,
    this.selectedColorId = '',
    this.selectedSize = '',
    this.selectedAttributes = const {},
    this.attributeGroups = const [],
    this.selectedThumb = 0,
    this.quantity = 1,
    this.deliverySelected = 'express',
    this.reviews = const [],
    this.mostPopular = const [],
    this.recommended = const [],
    this.isFavorite = false,
  });

  final HomeProductItem? product;
  final bool isLoading;
  final String? errorMessage;
  final String selectedColorId;
  final String selectedSize;
  final Map<String, String> selectedAttributes;
  final List<ProductAttributeGroup> attributeGroups;
  final int selectedThumb;
  final int quantity;
  final String deliverySelected;
  final List<ProductReview> reviews;
  final List<HomeProductItem> mostPopular;
  final List<HomeProductItem> recommended;
  final bool isFavorite;

  factory ProductDetailsState.initial() {
    return const ProductDetailsState(
      product: null,
      isLoading: false,
      errorMessage: null,
      selectedColorId: '',
      selectedSize: '',
      selectedAttributes: {},
      attributeGroups: [],
      selectedThumb: 0,
      quantity: 1,
      deliverySelected: 'express',
      reviews: [],
      mostPopular: [],
      recommended: [],
      isFavorite: false,
    );
  }

  // =========================================================
  // Getters & Calculations
  // =========================================================
  String get title {
    final value = product?.title.trim() ?? '';
    return value.isEmpty ? Mk.productDefaultTitle.tr : value.tr;
  }

  String get description {
    final value = product?.description.trim() ?? '';
    return value.isEmpty ? Mk.productDefaultDescription.tr : value.tr;
  }

  String get imageUrl => product?.imageUrl ?? '';

  String get brand => product?.brand ?? '';
  String get sku => product?.sku ?? '';
  String get stockText => product?.stockText ?? '';
  String get salePriceText => (product?.salePrice ?? unitPrice).toStringAsFixed(2);
  String get oldPriceText => price.toStringAsFixed(2);

  double get price => product?.price ?? 0;

  int get discount => product?.discountPercent ?? 0;

  bool get hasDiscount => discount > 0;

  double get unitPrice => hasDiscount ? (price * (1 - discount / 100)) : price;

  double get totalPrice => unitPrice * quantity;

  String get totalPriceText => totalPrice.toStringAsFixed(2);

  List<String> get images {
    final list = product?.images ?? [];
    if (list.isNotEmpty) return list;
    if (imageUrl.trim().isNotEmpty) return [imageUrl];
    return const [];
  }

  List<String> get variationImages {
    final imgs = images;
    if (imgs.isEmpty) return const [];
    return imgs.take(4).toList();
  }

  List<ProductColorOption> get availableColors {
    final raw = product?.availableColors;
    if (raw == null || raw.isEmpty) return const [];
    return raw
        .where(
          (e) =>
              e.id.trim().isNotEmpty &&
              e.name.trim().isNotEmpty &&
              e.imageUrl.trim().isNotEmpty,
        )
        .toList();
  }

  List<String> get availableSizes {
    final raw = product?.availableSizes;
    if (raw == null || raw.isEmpty) return const [];
    return raw.where((e) => e.trim().isNotEmpty).toList();
  }

  ProductColorOption? get selectedColorOption {
    if (selectedColorId.trim().isEmpty) return null;
    for (final color in availableColors) {
      if (color.id == selectedColorId) return color;
    }
    return null;
  }

  List<String> get selectedOptionChips {
    if (attributeGroups.isNotEmpty) {
      final chips = <String>[];
      for (final group in attributeGroups) {
        final optId = selectedAttributes[group.id];
        if (optId != null) {
          for (final opt in group.options) {
            if (opt.id == optId) {
              chips.add(opt.label.tr);
              break;
            }
          }
        }
      }
      if (chips.isNotEmpty) return chips;
    }

    final chips = <String>[];
    final colorName = selectedColorOption?.name.trim() ?? '';
    if (colorName.isNotEmpty) {
      chips.add(colorName.tr);
    }
    if (selectedSize.trim().isNotEmpty) {
      chips.add(selectedSize.trim());
    }
    return chips;
  }

  /// معرف مستقر وغير مترجم للمتغيرات لحماية معرف سطر السلة من تغيير اللغة وترتيب الخصائص
  String get stableVariantKey {
    if (selectedAttributes.isNotEmpty) {
      final sortedKeys = selectedAttributes.keys.toList()..sort();
      final parts = <String>[];
      for (final key in sortedKeys) {
        final val = selectedAttributes[key];
        if (val != null && val.trim().isNotEmpty) {
          parts.add('$key:${val.trim()}');
        }
      }
      if (parts.isNotEmpty) return parts.join('|');
    }

    final parts = <String>[];
    if (selectedColorId.trim().isNotEmpty) {
      parts.add('color:${selectedColorId.trim()}');
    }
    if (selectedSize.trim().isNotEmpty) {
      parts.add('size:${selectedSize.trim()}');
    }
    return parts.join('|');
  }

  String get selectedOptionsSummary {
    if (attributeGroups.isEmpty) {
      final chips = selectedOptionChips;
      return chips.isEmpty ? 'اختر الخيارات' : chips.join(' • ');
    }
    final summaryList = <String>[];
    for (final group in attributeGroups) {
      final optId = selectedAttributes[group.id];
      if (optId != null) {
        for (final opt in group.options) {
          if (opt.id == optId) {
            summaryList.add('${group.name}: ${opt.label}');
            break;
          }
        }
      }
    }
    return summaryList.isEmpty ? 'اختر الخيارات' : summaryList.join(' • ');
  }

  ProductSizeGuide get sizeGuide {
    if (product?.sizeGuide != null) {
      return product!.sizeGuide!;
    }
    return ProductSizeGuide.forProductTitle(title, availableSizes);
  }

  int get photosCount => images.length;

  bool get hasReviews => reviews.isNotEmpty;

  int get reviewsCount => reviews.length;

  double get averageRating {
    if (reviews.isEmpty) return 0;
    final total = reviews.fold<double>(0, (sum, r) => sum + r.rating);
    return total / reviews.length;
  }

  ProductDetailsState copyWith({
    HomeProductItem? Function()? product,
    bool? isLoading,
    String? Function()? errorMessage,
    String? selectedColorId,
    String? selectedSize,
    Map<String, String>? selectedAttributes,
    List<ProductAttributeGroup>? attributeGroups,
    int? selectedThumb,
    int? quantity,
    String? deliverySelected,
    List<ProductReview>? reviews,
    List<HomeProductItem>? mostPopular,
    List<HomeProductItem>? recommended,
    bool? isFavorite,
  }) {
    return ProductDetailsState(
      product: product != null ? product() : this.product,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      selectedColorId: selectedColorId ?? this.selectedColorId,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedAttributes: selectedAttributes ?? this.selectedAttributes,
      attributeGroups: attributeGroups ?? this.attributeGroups,
      selectedThumb: selectedThumb ?? this.selectedThumb,
      quantity: quantity ?? this.quantity,
      deliverySelected: deliverySelected ?? this.deliverySelected,
      reviews: reviews ?? this.reviews,
      mostPopular: mostPopular ?? this.mostPopular,
      recommended: recommended ?? this.recommended,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductDetailsState &&
        other.product == product &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        other.selectedColorId == selectedColorId &&
        other.selectedSize == selectedSize &&
        mapEquals(other.selectedAttributes, selectedAttributes) &&
        listEquals(other.attributeGroups, attributeGroups) &&
        other.selectedThumb == selectedThumb &&
        other.quantity == quantity &&
        other.deliverySelected == deliverySelected &&
        listEquals(other.reviews, reviews) &&
        listEquals(other.mostPopular, mostPopular) &&
        listEquals(other.recommended, recommended) &&
        other.isFavorite == isFavorite;
  }

  @override
  int get hashCode => Object.hash(
        product,
        isLoading,
        errorMessage,
        selectedColorId,
        selectedSize,
        Object.hashAll(selectedAttributes.entries),
        Object.hashAll(attributeGroups),
        selectedThumb,
        quantity,
        deliverySelected,
        Object.hashAll(reviews),
        Object.hashAll(mostPopular),
        Object.hashAll(recommended),
        isFavorite,
      );
}

