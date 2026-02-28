class HomeProductItem {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final int? discountPercent;
  final bool isNew;
  final String tagKey;

  const HomeProductItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.discountPercent,
    this.isNew = false,
    this.tagKey = '',
    
  });
}
