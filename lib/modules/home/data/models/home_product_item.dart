import 'package:rwnaqk_frontend/core/constants/app_env.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_attribute_group.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_color_option.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_size_guide.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/products_models.dart';

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
  final String? shortDescription;
  final String description;
  final String? material;
  final String brand;
  final String sku;
  final String stockText;
  final String soldText;

  final List<String> images;
  final bool hasVariation;
  final bool hasSizeGuide;
  final List<ProductColorOption> availableColors;
  final List<String> availableSizes;
  final ProductSizeGuide? sizeGuide;
  final List<ProductAttributeGroup> attributeGroups;
  final List<ProductVariationItem> variations;

  const HomeProductItem({
    required this.id,
    this.originalProductId,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.discountPercent,
    this.isNew = false,
    this.tagKey = '',
    this.shortDescription,
    this.description = '',
    this.material,
    this.brand = '',
    this.sku = '',
    this.stockText = '',
    this.soldText = '',
    this.images = const [],
    this.hasVariation = false,
    this.hasSizeGuide = false,
    this.availableColors = const [],
    this.availableSizes = const [],
    this.sizeGuide,
    this.attributeGroups = const [],
    this.variations = const [],
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
    String? shortDescription,
    String? description,
    String? material,
    String? brand,
    String? sku,
    String? stockText,
    String? soldText,
    List<String>? images,
    bool? hasVariation,
    bool? hasSizeGuide,
    List<ProductColorOption>? availableColors,
    List<String>? availableSizes,
    ProductSizeGuide? sizeGuide,
    List<ProductAttributeGroup>? attributeGroups,
    List<ProductVariationItem>? variations,
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
      shortDescription: shortDescription ?? this.shortDescription,
      description: description ?? this.description,
      material: material ?? this.material,
      brand: brand ?? this.brand,
      sku: sku ?? this.sku,
      stockText: stockText ?? this.stockText,
      soldText: soldText ?? this.soldText,
      images: images ?? this.images,
      hasVariation: hasVariation ?? this.hasVariation,
      hasSizeGuide: hasSizeGuide ?? this.hasSizeGuide,
      availableColors: availableColors ?? this.availableColors,
      availableSizes: availableSizes ?? this.availableSizes,
      sizeGuide: sizeGuide ?? this.sizeGuide,
      attributeGroups: attributeGroups ?? this.attributeGroups,
      variations: variations ?? this.variations,
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
      'shortDescription': shortDescription,
      'description': description,
      'material': material,
      'brand': brand,
      'sku': sku,
      'stockText': stockText,
      'soldText': soldText,
      'images': images,
      'hasVariation': hasVariation,
      'has_variation': hasVariation,
      'hasSizeGuide': hasSizeGuide,
      'has_size_guide': hasSizeGuide,
      'availableColors': availableColors.map((e) => e.toMap()).toList(),
      'availableSizes': availableSizes,
      'sizeGuide': sizeGuide?.toMap(),
      'attributeGroups': attributeGroups.map((e) => e.toMap()).toList(),
      'variations': variations.map((e) => e.toJson()).toList(),
    };
  }

  /// البحث عن المتغير المطابق لاختيارات المستخدم الحالية (اللون، المقاس، أو أي خصائص مخصصة)
  ProductVariationItem? findMatchingVariation({
    String? colorId,
    String? colorName,
    String? size,
    Map<String, String>? attributes,
  }) {
    if (variations.isEmpty) return null;

    final hasColor = (colorId != null && colorId.isNotEmpty) ||
        (colorName != null && colorName.isNotEmpty);
    final hasSize = size != null && size.isNotEmpty;
    final hasAttrs = attributes != null &&
        attributes.values.any((v) => v.trim().isNotEmpty);

    if (!hasColor && !hasSize && !hasAttrs) {
      return null;
    }

    // 1. مطابقة تامة لجميع الخصائص المحددة
    for (final v in variations) {
      if (v.matches(
        selectedColorId: colorId,
        selectedColorName: colorName,
        selectedSize: size,
        selectedAttributes: attributes,
      )) {
        return v;
      }
    }

    // 2. إذا لم يتوفر تطابق تام، نختار المتغير الأقرب (الأعلى تطابقاً مع الخصائص المحددة)
    ProductVariationItem? bestMatch;
    int maxMatches = 0;

    for (final v in variations) {
      int score = 0;
      for (final combo in v.combinations) {
        final varIdStr = combo.variationId.toString();
        final varName = combo.variationName.trim();
        final varNameLower = varName.toLowerCase();

        final selectedVal = attributes?[varIdStr] ??
            attributes?[varName] ??
            attributes?[varNameLower] ??
            (varNameLower.contains('color') || varNameLower.contains('لون')
                ? (colorId ?? colorName)
                : null) ??
            (varNameLower.contains('size') || varNameLower.contains('مقاس')
                ? size
                : null);

        if (selectedVal != null && selectedVal.isNotEmpty) {
          final target = selectedVal.trim().toLowerCase();
          if (combo.valueId.toString() == selectedVal ||
              combo.valueName.trim().toLowerCase() == target ||
              combo.valueColor.trim().toLowerCase() == target) {
            score++;
          }
        }
      }

      if (score > maxMatches) {
        maxMatches = score;
        bestMatch = v;
      }
    }

    return bestMatch;
  }

  static String resolveImageUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    var url = raw.trim();
    final baseUrl = AppEnv.apiBaseUrl.trim();
    if (baseUrl.isNotEmpty) {
      final baseUri = Uri.tryParse(baseUrl);
      if (baseUri != null && baseUri.hasAuthority) {
        if (url.startsWith('/')) {
          return '${baseUri.scheme}://${baseUri.authority}$url';
        }
        final imgUri = Uri.tryParse(url);
        if (imgUri != null &&
            (imgUri.host == '127.0.0.1' || imgUri.host == 'localhost')) {
          url = imgUri
              .replace(
                scheme: baseUri.scheme,
                host: baseUri.host,
                port: baseUri.hasPort ? baseUri.port : null,
              )
              .toString();
        }
      }
    }
    return url;
  }

  factory HomeProductItem.fromMap(Map<String, dynamic> map) =>
      HomeProductItem.fromJson(map);

  factory HomeProductItem.fromJson(Map<String, dynamic> json) {
    final rawImagesList = <String>[];

    void addUrl(dynamic raw) {
      if (raw == null) return;
      String? candidate;
      if (raw is String) {
        candidate = raw;
      } else if (raw is Map) {
        candidate = raw['url']?.toString() ??
            raw['original_url']?.toString() ??
            raw['full_url']?.toString() ??
            raw['thumb']?.toString() ??
            raw['thumb300']?.toString() ??
            raw['image_path']?.toString() ??
            raw['feature_image']?.toString() ??
            raw['file_name']?.toString();
      }
      if (candidate != null && candidate.trim().isNotEmpty) {
        final u = resolveImageUrl(candidate);
        if (u.isNotEmpty && !rawImagesList.contains(u)) {
          rawImagesList.add(u);
        }
      }
    }

    // 1. Feature image
    final rawImageUrl =
        (json['imageUrl'] ?? json['feature_image'] ?? json['image_url'])
            ?.toString();
    addUrl(rawImageUrl);

    // 2. Images list (strings or maps)
    if (json['images'] is List) {
      for (final e in json['images'] as List) {
        addUrl(e);
      }
    }

    // 3. Gallery list (strings or maps from ProductShowResource / ProductGalleryMediaResource)
    if (json['gallery'] is List) {
      for (final e in json['gallery'] as List) {
        addUrl(e);
      }
    }

    // 4. Gallery media collection
    if (json['gallery_media'] is List) {
      for (final e in json['gallery_media'] as List) {
        addUrl(e);
      }
    }

    // 5. Gallery URLs
    if (json['gallery_urls'] is List) {
      for (final e in json['gallery_urls'] as List) {
        addUrl(e);
      }
    }

    // 6. Media collection
    if (json['media'] is List) {
      for (final e in json['media'] as List) {
        addUrl(e);
      }
    }

    final finalImageUrl = resolveImageUrl(
      rawImageUrl ?? (rawImagesList.isNotEmpty ? rawImagesList.first : ''),
    );

    final rawPrice = json['price'] ?? json['min_price'] ?? 0;
    final parsedPrice = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice.toString()) ?? 0.0;

    return HomeProductItem(
      id: (json['id'] ?? '').toString(),
      originalProductId: (json['originalProductId'] ?? json['product_id'])
          ?.toString(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      imageUrl: finalImageUrl,
      price: parsedPrice,
      discountPercent: json['discountPercent'] != null
          ? int.tryParse(json['discountPercent'].toString())
          : json['discount_percent'] != null
          ? int.tryParse(json['discount_percent'].toString())
          : null,
      isNew: json['isNew'] == true || json['is_new'] == true,
      tagKey: (json['tagKey'] ?? json['tag_key'] ?? '').toString(),
      shortDescription:
          json['short_description']?.toString() ??
          json['shortDescription']?.toString(),
      description: (json['description'] ?? '').toString(),
      material: json['material']?.toString(),
      brand: json['brand'] is Map
          ? (json['brand']['name'] ?? '').toString()
          : (json['brand'] ?? '').toString(),
      sku: (json['sku'] ?? '').toString(),
      stockText:
          (json['stockText'] ??
                  (json['stock_qty'] != null
                      ? '${json['stock_qty']} متوفر'
                      : ''))
              .toString(),
      soldText: (json['soldText'] ?? '').toString(),
      images: rawImagesList,
      hasVariation: () {
        final val = json['has_variation'] ?? json['hasVariation'];
        if (val != null) {
          if (val is bool) return val;
          if (val is num) return val != 0;
          final s = val.toString().trim().toLowerCase();
          return s == 'true' || s == '1';
        }
        return json['variations'] is List && (json['variations'] as List).isNotEmpty;
      }(),
      availableColors: () {
        final raw = json['availableColors'] ?? json['colors'];
        if (raw is List) {
          return raw
              .whereType<Map>()
              .map(
                (e) => ProductColorOption.fromMap(Map<String, dynamic>.from(e)),
              )
              .toList();
        }
        return const <ProductColorOption>[];
      }(),
      availableSizes: () {
        final raw = json['availableSizes'] ?? json['sizes'];
        if (raw is List) {
          return raw
              .map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
        }
        return const <String>[];
      }(),
      hasSizeGuide: () {
        final val = json['has_size_guide'] ?? json['hasSizeGuide'];
        if (val != null) {
          if (val is bool) return val;
          if (val is num) return val != 0;
          final s = val.toString().trim().toLowerCase();
          return s == 'true' || s == '1';
        }
        final guide = ProductSizeGuide.tryParse(json['size_guide'] ?? json['sizeGuide']);
        return guide != null && (guide.rows.isNotEmpty || (guide.note != null && guide.note!.trim().isNotEmpty));
      }(),
      sizeGuide: ProductSizeGuide.tryParse(
        json['size_guide'] ?? json['sizeGuide'],
      ),
      attributeGroups: () {
        final raw = json['attribute_groups'] ?? json['attributeGroups'];
        if (raw is List && raw.isNotEmpty) {
          return raw
              .whereType<Map>()
              .map((e) => ProductAttributeGroup.fromMap(Map<String, dynamic>.from(e)))
              .toList();
        }

        // استخراج المجموعات ديناميكياً من variations.combinations إن لم تكن متوفرة كحقل منفصل
        final vars = (json['variations'] as List?)?.whereType<Map>().toList();
        if (vars != null && vars.isNotEmpty) {
          final groupsMap = <String, Map<String, dynamic>>{};
          for (final v in vars) {
            final combos = (v['combinations'] as List?)?.whereType<Map>().toList() ?? const [];
            for (final c in combos) {
              final vId = (c['variation_id'] ?? c['id'] ?? '').toString();
              final vName = (c['variation_name'] ?? c['name'] ?? '').toString();
              final vType = (c['variation_type'] ?? c['type'] ?? 'text').toString();
              final valId = (c['value_id'] ?? '').toString();
              final valName = (c['value_name'] ?? '').toString();
              final valColor = (c['value_color'] ?? c['value'] ?? '').toString();
              final imgUrl = (c['image_url'] ?? c['imageUrl'])?.toString();

              if (vId.isEmpty && vName.isEmpty) continue;
              final key = vId.isNotEmpty ? vId : vName;

              groupsMap.putIfAbsent(key, () => {
                'id': key,
                'name': vName.isNotEmpty ? vName : key,
                'type': vType,
                'options': <Map<String, dynamic>>[],
              });

              final opts = groupsMap[key]!['options'] as List<Map<String, dynamic>>;
              if (!opts.any((o) => o['id'] == valId || o['label'] == valName)) {
                opts.add({
                  'id': valId.isNotEmpty ? valId : valName,
                  'label': valName,
                  'value': valColor,
                  'imageUrl': imgUrl,
                });
              }
            }
          }

          if (groupsMap.isNotEmpty) {
            return groupsMap.values
                .map((m) => ProductAttributeGroup.fromMap(m))
                .toList();
          }
        }

        return const <ProductAttributeGroup>[];
      }(),
      variations: () {
        final raw = json['variations'];
        if (raw is List) {
          return raw
              .whereType<Map>()
              .map(
                (e) =>
                    ProductVariationItem.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList();
        }
        return const <ProductVariationItem>[];
      }(),
    );
  }
}
