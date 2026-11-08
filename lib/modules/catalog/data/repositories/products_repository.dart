import 'package:rwnaqk_frontend/modules/catalog/controllers/products_listing_service.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_review.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

/// عقد المستودع الخاص ببيانات المنتجات والكتالوج.
///
/// هذا العقد مستقل تماماً عن GetX ولا يحتوي على أي Rx Types أو Widgets،
/// مما يسمح بإعادة استخدامه لاحقاً مع Riverpod أو BLoC أو أي مدير حالة آخر.
abstract class IProductsRepository {
  /// جلب قائمة المنتجات مع دعم الترتيب والفلاتر
  Future<List<HomeProductItem>> getProducts({
    int seed = 1,
    int limit = 10,
    ListingSort sort = ListingSort.newest,
    double? minPrice,
    double? maxPrice,
  });

  /// جلب منتج محدد بالمعرف
  Future<HomeProductItem?> getProductById(String id);

  /// جلب مراجعات منتج محدد
  Future<List<ProductReview>> getProductReviews(
    String productId, {
    dynamic rawReviews,
  });
}

