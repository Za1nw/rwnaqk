import 'package:rwnaqk_frontend/modules/catalog/data/models/product_color_option.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_size_guide.dart';

class HomeProductItem {
  final String id;
  /// معرف المنتج الأصلي في الكتالوج، يمنع فقدان هوية المنتج عند استخدام id كـ lineId فريد في السلة
  final String? originalProductId;
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
  final ProductSizeGuide? sizeGuide;

  const HomeProductItem({
    required this.id,
    this.originalProductId,
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
    this.sizeGuide,
  });

  /// معرف المنتج الحقيقي الدائم
  String get productId =>
      (originalProductId != null && originalProductId!.isNotEmpty)
          ? originalProductId!
          : id;

  bool get hasDiscount => discountPercent != null && discountPercent! > 0;

  double get salePrice {
    if (!hasDiscount) return price;
    return price * (1 - discountPercent! / 100);
  }

  HomeProductItem copyWith({
    String? id,
    String? originalProductId,
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
    ProductSizeGuide? sizeGuide,
  }) {
    return HomeProductItem(
      id: id ?? this.id,
      originalProductId: originalProductId ?? this.originalProductId,
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
      sizeGuide: sizeGuide ?? this.sizeGuide,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'originalProductId': originalProductId,
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
      'sizeGuide': sizeGuide?.toMap(),
    };
  }

  factory HomeProductItem.fromMap(Map<String, dynamic> map) =>
      HomeProductItem.fromJson(map);

  factory HomeProductItem.fromJson(Map<String, dynamic> json) {
    final imagesList = (json['images'] as List?)?.map((e) => e.toString()).toList() ??
        (json['media'] as List?)
            ?.map((e) => e is Map ? (e['original_url'] ?? '').toString() : e.toString())
            .where((s) => s.isNotEmpty)
            .toList() ??
        const [];

    final rawPrice = json['price'] ?? json['min_price'] ?? 0;
    final parsedPrice = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice.toString()) ?? 0.0;

    return HomeProductItem(
      id: (json['id'] ?? '').toString(),
      originalProductId: (json['originalProductId'] ?? json['product_id'])?.toString(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? json['feature_image'] ?? json['image_url'] ?? (imagesList.isNotEmpty ? imagesList.first : '')).toString(),
      price: parsedPrice,
      discountPercent: json['discountPercent'] != null
          ? int.tryParse(json['discountPercent'].toString())
          : json['discount_percent'] != null
              ? int.tryParse(json['discount_percent'].toString())
              : null,
      isNew: json['isNew'] == true || json['is_new'] == true,
      tagKey: (json['tagKey'] ?? json['tag_key'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      material: json['material']?.toString(),
      brand: json['brand'] is Map
          ? (json['brand']['name'] ?? '').toString()
          : (json['brand'] ?? '').toString(),
      sku: (json['sku'] ?? '').toString(),
      stockText: (json['stockText'] ??
              (json['stock_qty'] != null ? '${json['stock_qty']} متوفر' : ''))
          .toString(),
      soldText: (json['soldText'] ?? '').toString(),
      images: imagesList,
      availableColors: (json['availableColors'] ?? json['colors'] as List?)
              ?.whereType<Map>()
              .map((e) => ProductColorOption.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      availableSizes: (json['availableSizes'] ?? json['sizes'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      sizeGuide: json['sizeGuide'] != null && json['sizeGuide'] is Map
          ? ProductSizeGuide.fromMap(
              Map<String, dynamic>.from(json['sizeGuide'] as Map),
            )
          : null,
    );
  }
}
