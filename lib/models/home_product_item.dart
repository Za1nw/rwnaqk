import 'product_color_option.dart';

class ProductPurchaseLimit {
  final int? minQty;
  final int? maxQty;
  final int stepQty;

  const ProductPurchaseLimit({
    this.minQty,
    this.maxQty,
    this.stepQty = 1,
  });

  bool get hasValues => minQty != null || maxQty != null || stepQty > 1;

  ProductPurchaseLimit copyWith({
    int? minQty,
    int? maxQty,
    int? stepQty,
  }) {
    return ProductPurchaseLimit(
      minQty: minQty ?? this.minQty,
      maxQty: maxQty ?? this.maxQty,
      stepQty: stepQty ?? this.stepQty,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'minQty': minQty,
      'maxQty': maxQty,
      'stepQty': stepQty,
    };
  }

  factory ProductPurchaseLimit.fromMap(Map<String, dynamic> map) {
    return ProductPurchaseLimit(
      minQty:
          map['minQty'] == null ? null : int.tryParse(map['minQty'].toString()),
      maxQty:
          map['maxQty'] == null ? null : int.tryParse(map['maxQty'].toString()),
      stepQty: int.tryParse((map['stepQty'] ?? 1).toString()) ?? 1,
    );
  }
}

class ProductSizeGuideRow {
  final String size;
  final String chest;
  final String waist;
  final String hips;
  final String length;

  const ProductSizeGuideRow({
    required this.size,
    required this.chest,
    required this.waist,
    required this.hips,
    required this.length,
  });

  ProductSizeGuideRow copyWith({
    String? size,
    String? chest,
    String? waist,
    String? hips,
    String? length,
  }) {
    return ProductSizeGuideRow(
      size: size ?? this.size,
      chest: chest ?? this.chest,
      waist: waist ?? this.waist,
      hips: hips ?? this.hips,
      length: length ?? this.length,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'size': size,
      'chest': chest,
      'waist': waist,
      'hips': hips,
      'length': length,
    };
  }

  factory ProductSizeGuideRow.fromMap(Map<String, dynamic> map) {
    return ProductSizeGuideRow(
      size: (map['size'] ?? '').toString(),
      chest: (map['chest'] ?? '').toString(),
      waist: (map['waist'] ?? '').toString(),
      hips: (map['hips'] ?? '').toString(),
      length: (map['length'] ?? '').toString(),
    );
  }
}

class HomeProductItem {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final int? discountPercent;
  final bool isNew;
  final String tagKey;

  // ===== تفاصيل المنتج =====
  final String description;
  final String? material;
  final String brand;
  final String sku;
  final String stockText;
  final String soldText;

  final List<String> images;
  final List<ProductColorOption> availableColors;
  final List<String> availableSizes;
  final ProductPurchaseLimit? purchaseLimit;
  final List<ProductSizeGuideRow> sizeGuide;

  const HomeProductItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.discountPercent,
    this.isNew = false,
    this.tagKey = '',
    this.description = '',
    this.material,
    this.brand = '',
    this.sku = '',
    this.stockText = '',
    this.soldText = '',
    this.images = const [],
    this.availableColors = const [],
    this.availableSizes = const [],
    this.purchaseLimit,
    this.sizeGuide = const [],
  });

  bool get hasDiscount => discountPercent != null && discountPercent! > 0;

  double get salePrice {
    if (!hasDiscount) return price;
    return price * (1 - discountPercent! / 100);
  }

  HomeProductItem copyWith({
    String? id,
    String? title,
    String? imageUrl,
    double? price,
    int? discountPercent,
    bool? isNew,
    String? tagKey,
    String? description,
    String? material,
    String? brand,
    String? sku,
    String? stockText,
    String? soldText,
    List<String>? images,
    List<ProductColorOption>? availableColors,
    List<String>? availableSizes,
    ProductPurchaseLimit? purchaseLimit,
    List<ProductSizeGuideRow>? sizeGuide,
  }) {
    return HomeProductItem(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      discountPercent: discountPercent ?? this.discountPercent,
      isNew: isNew ?? this.isNew,
      tagKey: tagKey ?? this.tagKey,
      description: description ?? this.description,
      material: material ?? this.material,
      brand: brand ?? this.brand,
      sku: sku ?? this.sku,
      stockText: stockText ?? this.stockText,
      soldText: soldText ?? this.soldText,
      images: images ?? this.images,
      availableColors: availableColors ?? this.availableColors,
      availableSizes: availableSizes ?? this.availableSizes,
      purchaseLimit: purchaseLimit ?? this.purchaseLimit,
      sizeGuide: sizeGuide ?? this.sizeGuide,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'discountPercent': discountPercent,
      'isNew': isNew,
      'tagKey': tagKey,
      'description': description,
      'material': material,
      'brand': brand,
      'sku': sku,
      'stockText': stockText,
      'soldText': soldText,
      'images': images,
      'availableColors': availableColors.map((e) => e.toMap()).toList(),
      'availableSizes': availableSizes,
      'purchaseLimit': purchaseLimit?.toMap(),
      'sizeGuide': sizeGuide.map((e) => e.toMap()).toList(),
    };
  }

  factory HomeProductItem.fromMap(Map<String, dynamic> map) {
    return HomeProductItem(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      imageUrl: (map['imageUrl'] ?? '').toString(),
      price: (map['price'] ?? 0).toDouble(),
      discountPercent: map['discountPercent'] == null
          ? null
          : int.tryParse(map['discountPercent'].toString()),
      isNew: map['isNew'] == true,
      tagKey: (map['tagKey'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      material: map['material']?.toString(),
      brand: (map['brand'] ?? '').toString(),
      sku: (map['sku'] ?? '').toString(),
      stockText: (map['stockText'] ?? '').toString(),
      soldText: (map['soldText'] ?? '').toString(),
      images: (map['images'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      availableColors: (map['availableColors'] as List?)
              ?.map(
                (e) => ProductColorOption.fromMap(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          const [],
      availableSizes:
          (map['availableSizes'] as List?)?.map((e) => e.toString()).toList() ??
              const [],
      purchaseLimit: map['purchaseLimit'] is Map<String, dynamic>
          ? ProductPurchaseLimit.fromMap(map['purchaseLimit'])
          : map['purchaseLimit'] is Map
              ? ProductPurchaseLimit.fromMap(
                  Map<String, dynamic>.from(map['purchaseLimit'] as Map),
                )
              : null,
      sizeGuide: (map['sizeGuide'] as List?)
              ?.map(
                (e) => ProductSizeGuideRow.fromMap(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          const [],
    );
  }
}
