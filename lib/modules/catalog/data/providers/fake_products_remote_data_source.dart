import 'package:dio/dio.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/product_details_service.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/products_listing_service.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_review.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/repositories/products_repository.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_category_item.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

/// تطبيق وهمي (Fake) لمستودع المنتجات يعتمد على البيانات التجريبية الحالية في التطبيق.
///
/// لا يرتبط بـ GetX إطلاقاً ويسمح لاحقاً باستبداله بـ RemoteProductsRepository
/// المرتبط بـ Laravel API دون تغيير أي واجهة في الكنترولر.
class FakeProductsRepository implements IProductsRepository {
  FakeProductsRepository({
    ProductsListingService? listingService,
    ProductDetailsService? detailsService,
  })  : _listingService = listingService ?? ProductsListingService(),
        _detailsService = detailsService ?? ProductDetailsService();

  final ProductsListingService _listingService;
  final ProductDetailsService _detailsService;

  @override
  Future<List<HomeProductItem>> getProducts({
    int seed = 1,
    int limit = 10,
    ListingSort sort = ListingSort.newest,
    double? minPrice,
    double? maxPrice,
    String? categoryId,
    String? search,
  }) async {
    final list = _listingService.mockProducts(seed: seed);
    var filtered = list;
    if (minPrice != null || maxPrice != null) {
      filtered = filtered.where((p) {
        if (minPrice != null && p.price < minPrice) return false;
        if (maxPrice != null && p.price > maxPrice) return false;
        return true;
      }).toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      filtered = filtered.where((p) => p.title.toLowerCase().contains(q)).toList();
    }
    return _listingService.applySort(list: filtered, sort: sort);
  }

  @override
  Future<HomeProductItem?> getProductById(String id) async {
    final products = _listingService.mockProducts(seed: 1);
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  Future<List<ProductReview>> getProductReviews(
    String productId, {
    dynamic rawReviews,
  }) async {
    return _detailsService.resolveReviews(rawReviews);
  }

  @override
  Future<List<HomeProductItem>> searchProducts(
    String query, {
    CancelToken? cancelToken,
  }) async {
    if (cancelToken?.isCancelled == true) return const [];
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    final list = _listingService.mockProducts(seed: 1);
    final more = _listingService.mockProducts(seed: 2);
    final all = [...list, ...more];
    return all.where((p) => p.title.toLowerCase().contains(q)).toList();
  }

  @override
  Future<List<HomeCategoryItem>> getCategories() async {
    return const [
      HomeCategoryItem(
        id: '1',
        name: 'الملابس النسائية',
        count: 120,
        imageUrls: ['https://picsum.photos/200/200?cat=1'],
      ),
      HomeCategoryItem(
        id: '2',
        name: 'الأحذية والحقائب',
        count: 85,
        imageUrls: ['https://picsum.photos/200/200?cat=2'],
      ),
      HomeCategoryItem(
        id: '3',
        name: 'الإكسسوارات',
        count: 45,
        imageUrls: ['https://picsum.photos/200/200?cat=3'],
      ),
      HomeCategoryItem(
        id: '4',
        name: 'العطور ومستحضرات التجميل',
        count: 60,
        imageUrls: ['https://picsum.photos/200/200?cat=4'],
      ),
    ];
  }
}

