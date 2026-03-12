import 'package:rwnaqk/models/home_product_item.dart';

/// هذا الملف مسؤول عن منطق البيانات الخاص بشاشة المفضلة.
///
/// نستخدمه لفصل:
/// - البيانات التجريبية
/// - إنشاء عناصر المفضلة
/// - إنشاء العناصر التي تمت مشاهدتها مؤخرًا
///
/// لاحقًا عند ربط API الحقيقي، سيكون هذا الملف هو المكان الطبيعي
/// لجلب المفضلة والمشاهدة مؤخرًا من السيرفر.
class WishlistService {
  /// هذه الدالة تعيد عناصر المفضلة التجريبية.
  List<HomeProductItem> seedWishlist() {
    return sampleProducts(
      4,
      seed: 900,
      discount: 20,
      tagKey: 'Pink',
    );
  }

  /// هذه الدالة تعيد العناصر التي تمت مشاهدتها مؤخرًا بشكل تجريبي.
  List<HomeProductItem> seedRecentlyViewed() {
    return sampleProducts(6, seed: 800);
  }

  /// هذه الدالة تنشئ قائمة منتجات تجريبية.
  ///
  /// نستخدمها أثناء التطوير إلى أن يتم ربط البيانات الحقيقية لاحقًا.
  List<HomeProductItem> sampleProducts(
    int count, {
    required int seed,
    int? discount,
    String tagKey = '',
  }) {
    return List.generate(count, (index) {
      final id = '${seed}_$index';

      return HomeProductItem(
        id: id,
        title: 'Item $id',
        imageUrl: 'https://picsum.photos/400/500?$id',
        price: 17 + (index * 5).toDouble(),
        discountPercent: discount,
        isNew: index % 3 == 0,
        tagKey: tagKey,
      );
    });
  }
} 