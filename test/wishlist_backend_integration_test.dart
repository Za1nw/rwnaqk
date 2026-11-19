import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/modules/catalog/providers/catalog_providers.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/wishlist/data/repositories/wishlist_repository.dart';
import 'package:rwnaqk_frontend/modules/wishlist/providers/wishlist_providers.dart';

class MockWishlistRepository implements IWishlistRepository {
  List<HomeProductItem> serverItems = [];
  bool toggleShouldReturn = true;
  int toggleCallCount = 0;
  int getWishlistCallCount = 0;
  int removeFromWishlistCallCount = 0;
  int syncWishlistCallCount = 0;

  @override
  Future<List<HomeProductItem>> getWishlist() async {
    getWishlistCallCount++;
    return serverItems;
  }

  @override
  Future<bool> toggleWishlist(String productId) async {
    toggleCallCount++;
    return toggleShouldReturn;
  }

  @override
  Future<void> addToWishlist(String productId) async {}

  @override
  Future<void> removeFromWishlist(String productId) async {
    removeFromWishlistCallCount++;
    serverItems.removeWhere((e) => e.id == productId);
  }

  @override
  Future<List<HomeProductItem>> syncWishlist(List<String> productIds) async {
    syncWishlistCallCount++;
    return serverItems;
  }

  @override
  Future<List<String>> getWishlistIds() async {
    return serverItems.map((e) => e.id).toList();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Wishlist Integration & Backend Tests', () {
    const sampleProduct = HomeProductItem(
      id: '1',
      title: 'بنطال تشينو',
      imageUrl: 'http://example.com/1.jpg',
      price: 15000,
    );

    test('WishlistState initializes cleanly with NO fake data', () {
      final mockRepo = MockWishlistRepository();
      final container = ProviderContainer(
        overrides: [
          wishlistRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(wishlistProvider);
      expect(state.items, isEmpty);
      expect(state.recentlyViewed, isEmpty);
      expect(state.isEmpty, isTrue);
    });

    test('WishlistNotifier toggle optimistically updates and calls backend', () async {
      final mockRepo = MockWishlistRepository();
      final container = ProviderContainer(
        overrides: [
          wishlistRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(wishlistProvider.notifier);
      expect(container.read(wishlistProvider).isInWishlist('1'), isFalse);

      await notifier.toggle(sampleProduct);

      expect(container.read(wishlistProvider).isInWishlist('1'), isTrue);
      expect(mockRepo.toggleCallCount, equals(1));
    });

    test('ProductDetailsNotifier favorite toggle does NOT erase loaded product or get stuck in skeleton', () async {
      final mockRepo = MockWishlistRepository();
      final container = ProviderContainer(
        overrides: [
          wishlistRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final productNotifier = container.read(productDetailsFamily('1').notifier);
      await productNotifier.loadProduct(initialItem: sampleProduct);

      final stateBefore = container.read(productDetailsFamily('1'));
      expect(stateBefore.product, isNotNull);
      expect(stateBefore.isLoading, isFalse);
      expect(stateBefore.title, equals('بنطال تشينو'));

      // Toggle favorite from product details
      productNotifier.toggleFavorite();

      final stateAfter = container.read(productDetailsFamily('1'));
      // Product must remain loaded and NOT reset to skeleton loading!
      expect(stateAfter.product, isNotNull);
      expect(stateAfter.isLoading, isFalse);
      expect(stateAfter.title, equals('بنطال تشينو'));
      expect(stateAfter.isFavorite, isTrue);
    });

    test('WishlistNotifier syncWithSession merges guest items on login', () async {
      final mockRepo = MockWishlistRepository();
      mockRepo.serverItems = [sampleProduct];

      final container = ProviderContainer(
        overrides: [
          wishlistRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(wishlistProvider.notifier);
      await notifier.syncWithSession(userId: '42', generation: 1, isLogin: true);

      expect(mockRepo.syncWishlistCallCount, equals(1));
      expect(container.read(wishlistProvider).items.length, equals(1));
      expect(container.read(wishlistProvider).activeUserId, equals('42'));
    });
  });
}
