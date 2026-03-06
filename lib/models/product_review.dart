class ProductReview {
  final String name;
  final double rating;
  final String text;
  final String? avatarUrl;
  final String? dateText;

  const ProductReview({
    required this.name,
    required this.rating,
    required this.text,
    this.avatarUrl,
    this.dateText,
  });

  factory ProductReview.fromMap(Map<String, dynamic> map) {
    return ProductReview(
      name: (map['name'] ?? '').toString(),
      rating: double.tryParse((map['rating'] ?? 0).toString()) ?? 0,
      text: (map['text'] ?? '').toString(),
      avatarUrl: map['avatarUrl']?.toString(),
      dateText: map['dateText']?.toString(),
    );
  }
}