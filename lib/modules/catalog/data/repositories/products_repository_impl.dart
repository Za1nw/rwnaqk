import 'package:dio/dio.dart';
import 'package:rwnaqk_frontend/core/constants/app_env.dart';
import 'package:rwnaqk_frontend/core/network/api_client.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/catalog_endpoints.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/products_listing_service.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_review.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/providers/fake_products_remote_data_source.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/repositories/products_repository.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_category_item.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

/// تطبيق مستودع الكتالوج النقي المتصل بخادم Laravel API عبر [ApiClient]
/// مع إمكانية التبديل مع [FakeProductsRepository] عند تفعيل وضع Mock Data.
class ProductsRepositoryImpl implements IProductsRepository {
  ProductsRepositoryImpl({
    required ApiClient apiClient,
    FakeProductsRepository? fallbackRepository,
  }) : _api = apiClient,
       _fallback = fallbackRepository ?? FakeProductsRepository();

  final ApiClient _api;
  final FakeProductsRepository _fallback;

  @override
  Future<List<HomeProductItem>> getProducts({
    int seed = 1,
    int limit = 10,
    ListingSort sort = ListingSort.newest,
    double? minPrice,
    double? maxPrice,
    String? categoryId,
    String? search,
    bool? isFeatured,
  }) async {
    if (AppEnv.enableMockData) {
      return _fallback.getProducts(
        seed: seed,
        limit: limit,
        sort: sort,
        minPrice: minPrice,
        maxPrice: maxPrice,
        categoryId: categoryId,
        search: search,
        isFeatured: isFeatured,
      );
    }

    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'page': seed,
        'sort': sort.name,
        'min_price': ?minPrice,
        'max_price': ?maxPrice,
        if (categoryId != null && categoryId.isNotEmpty)
          'category_id': categoryId,
        if (search != null && search.isNotEmpty) 'search': search,
        if (isFeatured != null) 'is_featured': isFeatured ? 1 : 0,
      };

      final response = await _api.get<dynamic>(
        CatalogEndpoints.products,
        queryParameters: queryParams,
      );

      final data = response.data;
      final rawList = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List
          : data is List
          ? data
          : const [];

      return rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => HomeProductItem.fromJson(json))
          .toList();
    } catch (_) {
      // لا نفعّل الـ Mock Fallback تلقائياً عند فشل الـ API لضمان ظهور رسائل الخطأ الحقيقية
      rethrow;
    }
  }

  @override
  Future<HomeProductItem?> getProductById(String id) async {
    if (AppEnv.enableMockData) {
      return _fallback.getProductById(id);
    }

    try {
      final response = await _api.get<dynamic>(CatalogEndpoints.productDetails(id));
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final productJson = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
        return HomeProductItem.fromJson(productJson);
      }
      return null;
    } catch (_) {
      // لا نفعّل الـ Mock Fallback تلقائياً عند فشل الـ API
      rethrow;
    }
  }

  @override
  Future<List<ProductReview>> getProductReviews(
    String productId, {
    dynamic rawReviews,
  }) async {
    if (AppEnv.enableMockData) {
      return _fallback.getProductReviews(productId, rawReviews: rawReviews);
    }

    try {
      final response = await _api.get<dynamic>(
        CatalogEndpoints.productReviews(productId),
      );

      final data = response.data;
      final rawList = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List
          : data is List
          ? data
          : const [];

      return rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => ProductReview.fromJson(json))
          .toList();
    } catch (_) {
      // لا نفعّل الـ Mock Fallback تلقائياً عند فشل الـ API
      rethrow;
    }
  }

  @override
  Future<List<HomeProductItem>> searchProducts(
    String query, {
    CancelToken? cancelToken,
  }) async {
    if (AppEnv.enableMockData) {
      return _fallback.searchProducts(query, cancelToken: cancelToken);
    }

    try {
      final response = await _api.get<dynamic>(
        CatalogEndpoints.products,
        queryParameters: {'q': query.trim()},
        cancelToken: cancelToken,
      );

      final data = response.data;
      final rawList = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List
          : data is List
          ? data
          : const [];

      return rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => HomeProductItem.fromJson(json))
          .toList();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<HomeCategoryItem>> getCategories({
    String? parentId,
    bool? isFeatured,
    bool? isTop,
  }) async {
    if (AppEnv.enableMockData) {
      return _fallback.getCategories(
        parentId: parentId,
        isFeatured: isFeatured,
        isTop: isTop,
      );
    }

    try {
      final queryParams = <String, dynamic>{
        'parent_id': ?parentId,
        if (isFeatured != null) 'is_featured': isFeatured ? 1 : 0,
        if (isTop != null) 'is_top': isTop ? 1 : 0,
      };

      final response = await _api.get<dynamic>(
        CatalogEndpoints.categories,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final data = response.data;
      final rawList = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List
          : data is List
          ? data
          : const [];

      return rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => HomeCategoryItem.fromJson(json))
          .toList();
    } catch (_) {
      rethrow;
    }
  }
}
