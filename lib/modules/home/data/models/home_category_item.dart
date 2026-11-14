class HomeCategoryItem {
  final String id;
  final String name;
  final int count;
  final List<String> imageUrls;

  const HomeCategoryItem({
    required this.id,
    required this.name,
    required this.count,
    required this.imageUrls,
  });

  factory HomeCategoryItem.fromJson(Map<String, dynamic> json) {
    final rawImages = json['image_urls'] ?? json['images'] ?? json['image'];
    final parsedImages = <String>[];
    if (rawImages is List) {
      parsedImages.addAll(rawImages.map((e) => e.toString()));
    } else if (rawImages is String && rawImages.isNotEmpty) {
      parsedImages.add(rawImages);
    }

    return HomeCategoryItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['title']?.toString() ?? '',
      count: int.tryParse(json['count']?.toString() ?? json['products_count']?.toString() ?? '0') ?? 0,
      imageUrls: parsedImages,
    );
  }
}
