class ProductColorOption {
  final String id;
  final String name;
  final String imageUrl;
  final String? colorCode;

  const ProductColorOption({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.colorCode,
  });

  ProductColorOption copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? colorCode,
  }) {
    return ProductColorOption(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      colorCode: colorCode ?? this.colorCode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'colorCode': colorCode,
      'color_code': colorCode,
    };
  }

  factory ProductColorOption.fromMap(Map<String, dynamic> map) {
    return ProductColorOption(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      imageUrl: (map['imageUrl'] ?? '').toString(),
      colorCode: (map['colorCode'] ?? map['color_code'])?.toString(),
    );
  }
}
