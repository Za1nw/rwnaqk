import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/wishlist/data/repositories/wishlist_repository.dart';
import 'package:rwnaqk_frontend/modules/wishlist/providers/wishlist_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StubWishlistRepository implements IWishlistRepository {
  List<String> serverIds = ['101', '102'];

  @override
  Future<List<String>> getWishlistIds() async => serverIds;

  @override
  Future<List<HomeProductItem>> getWishlist() async => [];

  @override
  Future<bool> toggleWishlist(String productId) async => true;

  @override
  Future<void> addToWishlist(String productId) async {}

  @override
  Future<void> removeFromWishlist(String productId) async {}

  @override
  Future<List<HomeProductItem>> syncWishlist(List<String> productIds) async => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('WishlistNotifier initializes favorite IDs and count synchronously on frame 0', () async {
    SharedPreferences.setMockInitialValues({
      'cached_wishlist_ids': ['10', '20', '30'],
      'cached_wishlist_count': 3,
    });
    final prefs = await SharedPreferences.getInstance();

    final repo = StubWishlistRepository();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesInstanceProvider.overrideWithValue(prefs),
        wishlistRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    // Synchronous initial state check on startup
    final initialWishlistState = container.read(wishlistProvider);

    // 1. Count must be 3 immediately without any network calls!
    expect(initialWishlistState.itemCount, equals(3));
    expect(initialWishlistState.count, equals(3));

    // 2. Products 10, 20, 30 must be recognized as favorites immediately on the Home screen!
    expect(initialWishlistState.isInWishlist('10'), isTrue);
    expect(initialWishlistState.isInWishlist('20'), isTrue);
    expect(initialWishlistState.isInWishlist('30'), isTrue);
    expect(initialWishlistState.isInWishlist('99'), isFalse);

    // 3. Full products list must still be empty (lazy loading preserved)
    expect(initialWishlistState.hasLoaded, isFalse);
    expect(initialWishlistState.items, isEmpty);
  });
}
