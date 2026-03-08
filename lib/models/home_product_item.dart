import 'product_color_option.dart';

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
  final String brand;
  final String sku;
  final String stockText;
  final String soldText;

  final List<String> images;
  final List<ProductColorOption> availableColors;
  final List<String> availableSizes;

  const HomeProductItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.discountPercent,
    this.isNew = false,
    this.tagKey = '',
    this.description = '',
    this.brand = '',
    this.sku = '',
    this.stockText = '',
    this.soldText = '',
    this.images = const [],
    this.availableColors = const [],
    this.availableSizes = const [],
  });

  bool get hasDiscount =>
      discountPercent != null && discountPercent! > 0;

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
    String? brand,
    String? sku,
    String? stockText,
    String? soldText,
    List<String>? images,
    List<ProductColorOption>? availableColors,
    List<String>? availableSizes,
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
      brand: brand ?? this.brand,
      sku: sku ?? this.sku,
      stockText: stockText ?? this.stockText,
      soldText: soldText ?? this.soldText,
      images: images ?? this.images,
      availableColors: availableColors ?? this.availableColors,
      availableSizes: availableSizes ?? this.availableSizes,
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
      'brand': brand,
      'sku': sku,
      'stockText': stockText,
      'soldText': soldText,
      'images': images,
      'availableColors': availableColors.map((e) => e.toMap()).toList(),
      'availableSizes': availableSizes,
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
      brand: (map['brand'] ?? '').toString(),
      sku: (map['sku'] ?? '').toString(),
      stockText: (map['stockText'] ?? '').toString(),
      soldText: (map['soldText'] ?? '').toString(),
      images: (map['images'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      availableColors: (map['availableColors'] as List?)
              ?.map(
                (e) => ProductColorOption.fromMap(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          const [],
      availableSizes: (map['availableSizes'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}