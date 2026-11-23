import 'package:dio/dio.dart';
import 'package:rwnaqk_frontend/core/network/api_client.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/wishlist/data/guest_token_storage.dart';
import 'package:rwnaqk_frontend/modules/wishlist/data/repositories/wishlist_repository.dart';
import 'package:rwnaqk_frontend/modules/wishlist/data/wishlist_endpoints.dart';
import 'package:rwnaqk_frontend/modules/wishlist/data/wishlist_local_cache.dart';

/// تطبيق مستودع المفضلة المتصل بخادم Laravel API عبر [ApiClient]
class WishlistRepositoryImpl implements IWishlistRepository {
  WishlistRepositoryImpl({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<Options> _buildOptions() async {
    final guestToken = await GuestTokenStorage.getGuestToken();
    return Options(
      headers: {
        'X-Guest-Token': guestToken,
      },
    );
  }

  @override
  Future<List<HomeProductItem>> getWishlist() async {
    try {
      final options = await _buildOptions();
      final response = await _api.get<dynamic>(
        WishlistEndpoints.wishlist,
        options: options,
      );

      final data = response.data;
      final rawList = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List
          : (data is List ? data : const []);

      final items = rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => HomeProductItem.fromJson(json))
          .toList();

      final ids = items.map((e) => e.id).toList();
      await WishlistLocalCache.saveFavoriteIds(ids);
      return items;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<String>> getWishlistIds() async {
    try {
      final options = await _buildOptions();
      final response = await _api.get<dynamic>(
        WishlistEndpoints.ids,
        options: options,
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['ids'] is List) {
        final ids = (data['ids'] as List).map((e) => e.toString()).toList();
        await WishlistLocalCache.saveFavoriteIds(ids);
        return ids;
      }
      return const [];
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<bool> toggleWishlist(String productId) async {
    try {
      final options = await _buildOptions();
      final idInt = int.tryParse(productId);

      final response = await _api.post<dynamic>(
        WishlistEndpoints.toggle,
        data: {'product_id': idInt ?? productId},
        options: options,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final serverCount = data['wishlist_count'] ?? data['count'];
        if (serverCount is int) {
          await WishlistLocalCache.saveCount(serverCount);
        }
        if (data.containsKey('is_favorite')) {
          return data['is_favorite'] == true;
        }
      }
      return false;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> addToWishlist(String productId) async {
    try {
      final options = await _buildOptions();
      final idInt = int.tryParse(productId);

      final response = await _api.post<dynamic>(
        WishlistEndpoints.store,
        data: {'product_id': idInt ?? productId},
        options: options,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final serverCount = data['wishlist_count'] ?? data['count'];
        if (serverCount is int) {
          await WishlistLocalCache.saveCount(serverCount);
        }
      }
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> removeFromWishlist(String productId) async {
    try {
      final options = await _buildOptions();
      final response = await _api.delete<dynamic>(
        WishlistEndpoints.delete(productId),
        options: options,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final serverCount = data['wishlist_count'] ?? data['count'];
        if (serverCount is int) {
          await WishlistLocalCache.saveCount(serverCount);
        }
      }
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<HomeProductItem>> syncWishlist(List<String> productIds) async {
    try {
      final options = await _buildOptions();
      final guestToken = await GuestTokenStorage.getGuestToken();
      final idInts = productIds
          .map((e) => int.tryParse(e))
          .whereType<int>()
          .toList();

      final response = await _api.post<dynamic>(
        WishlistEndpoints.sync,
        data: {
          'guest_token': guestToken,
          'product_ids': idInts,
        },
        options: options,
      );

      final data = response.data;
      final rawList = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List
          : (data is List ? data : const []);

      final serverItems = rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => HomeProductItem.fromJson(json))
          .toList();

      final ids = serverItems.map((e) => e.id).toList();
      await WishlistLocalCache.saveFavoriteIds(ids);
      return serverItems;
    } catch (_) {
      rethrow;
    }
  }
}
