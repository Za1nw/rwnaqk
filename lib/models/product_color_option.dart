class ProductColorOption {
  final String id;
  final String name;
  final String imageUrl;

  const ProductColorOption({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  ProductColorOption copyWith({
    String? id,
    String? name,
    String? imageUrl,
  }) {
    return ProductColorOption(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
    };
  }

  factory ProductColorOption.fromMap(Map<String, dynamic> map) {
    return ProductColorOption(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      imageUrl: (map['imageUrl'] ?? '').toString(),
    );
  }
}