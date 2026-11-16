import 'package:flutter/material.dart';

enum ProductAttributeType {
  color, // خيار لوني (كود لوني أو اسم لون)
  image, // خيار صورة (صورة مصغرة للنمط أو الموديل)
  text, // خيار نصي (مثل المقاسات، الطول، نوع القماش)
}

class ProductAttributeOption {
  final String id;
  final String label;
  final String? value; // e.g. hex code #6E0131 for colors or specific value
  final String? imageUrl; // image preview for image-type or color-type
  final bool isAvailable;

  const ProductAttributeOption({
    required this.id,
    required this.label,
    this.value,
    this.imageUrl,
    this.isAvailable = true,
  });

  factory ProductAttributeOption.fromMap(Map<String, dynamic> map) {
    return ProductAttributeOption(
      id: (map['id'] ?? map['value_id'] ?? '').toString(),
      label: (map['label'] ?? map['name'] ?? map['value_name'] ?? '').toString(),
      value: (map['value'] ?? map['color_code'] ?? map['value_color'])?.toString(),
      imageUrl: (map['imageUrl'] ?? map['image_url'])?.toString(),
      isAvailable: map['isAvailable'] != false && map['is_available'] != false,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label,
    'value': value,
    'imageUrl': imageUrl,
    'isAvailable': isAvailable,
  };

  Color? get colorValue {
    if (value != null && value!.trim().isNotEmpty) {
      final clean = value!.replaceAll('#', '').trim();
      if (clean.length == 6) {
        final intVal = int.tryParse('FF$clean', radix: 16);
        if (intVal != null) return Color(intVal);
      } else if (clean.length == 8) {
        final intVal = int.tryParse(clean, radix: 16);
        if (intVal != null) return Color(intVal);
      }
    }
    return _parseColorFromName(label) ?? _parseColorFromName(id);
  }

  static Color? _parseColorFromName(String name) {
    final lower = name.trim().toLowerCase();
    if (lower.contains('أسود') || lower.contains('black')) {
      return const Color(0xFF18181B);
    }
    if (lower.contains('أبيض') || lower.contains('white')) {
      return const Color(0xFFFFFFFF);
    }
    if (lower.contains('بيج') || lower.contains('beige')) {
      return const Color(0xFFE8DCC4);
    }
    if (lower.contains('عنابي') ||
        lower.contains('خمري') ||
        lower.contains('burgundy') ||
        lower.contains('maroon')) {
      return const Color(0xFF6E0131);
    }
    if (lower.contains('أحمر') || lower.contains('red')) {
      return const Color(0xFFDC2626);
    }
    if (lower.contains('كحلي') || lower.contains('navy')) {
      return const Color(0xFF1E293B);
    }
    if (lower.contains('أزرق') || lower.contains('blue')) {
      return const Color(0xFF2563EB);
    }
    if (lower.contains('أخضر') || lower.contains('green')) {
      return const Color(0xFF16A34A);
    }
    if (lower.contains('زيتوني') || lower.contains('olive')) {
      return const Color(0xFF556B2F);
    }
    if (lower.contains('رمادي') ||
        lower.contains('رصاصي') ||
        lower.contains('grey') ||
        lower.contains('gray')) {
      return const Color(0xFF6B7280);
    }
    if (lower.contains('وردي') ||
        lower.contains('زهري') ||
        lower.contains('pink')) {
      return const Color(0xFFF472B6);
    }
    if (lower.contains('بني') || lower.contains('brown')) {
      return const Color(0xFF78350F);
    }
    if (lower.contains('ذهبي') || lower.contains('gold')) {
      return const Color(0xFFFAAD01);
    }
    if (lower.contains('أصفر') || lower.contains('yellow')) {
      return const Color(0xFFEAB308);
    }
    if (lower.contains('بنفسجي') ||
        lower.contains('موف') ||
        lower.contains('purple')) {
      return const Color(0xFF9333EA);
    }
    return null;
  }
}

class ProductAttributeGroup {
  final String id;
  final String name; // e.g. "اللون", "المقاس", "الخامة"
  final ProductAttributeType type;
  final List<ProductAttributeOption> options;
  final bool isRequired;

  const ProductAttributeGroup({
    required this.id,
    required this.name,
    required this.type,
    required this.options,
    this.isRequired = true,
  });

  factory ProductAttributeGroup.fromMap(Map<String, dynamic> map) {
    final rawType = (map['type'] ?? 'text').toString().toLowerCase();
    final type = rawType == 'color'
        ? ProductAttributeType.color
        : (rawType == 'image' ? ProductAttributeType.image : ProductAttributeType.text);

    final rawOptions = map['options'] as List? ?? const [];
    final options = rawOptions
        .whereType<Map>()
        .map((e) => ProductAttributeOption.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    return ProductAttributeGroup(
      id: (map['id'] ?? map['variation_id'] ?? '').toString(),
      name: (map['name'] ?? map['variation_name'] ?? '').toString(),
      type: type,
      options: options,
      isRequired: map['isRequired'] != false && map['is_required'] != false,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'type': type.name,
    'options': options.map((e) => e.toMap()).toList(),
    'isRequired': isRequired,
  };
}
