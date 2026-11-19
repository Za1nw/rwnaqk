import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/home/providers/home_providers.dart';
import 'package:rwnaqk_frontend/modules/home/views/home_view.dart';
import 'package:rwnaqk_frontend/modules/home/views/main_view.dart';
import 'package:rwnaqk_frontend/modules/orders/providers/orders_providers.dart';
import 'package:rwnaqk_frontend/modules/orders/views/orders_view.dart';
import 'package:rwnaqk_frontend/modules/wishlist/data/repositories/wishlist_repository.dart';
import 'package:rwnaqk_frontend/modules/wishlist/providers/wishlist_providers.dart';
import 'package:rwnaqk_frontend/modules/wishlist/views/wishlist_view.dart';

class TestHomeContentNotifier extends HomeContentNotifier {
  @override
  HomeContentState build() {
    return const HomeContentState(
      banners: [],
      categories: [],
      flashSale: [],
      newItems: [],
      isLoading: false,
      hasLoaded: true,
    );
  }
}

class FakeWishlistRepository implements IWishlistRepository {
  @override
  Future<List<HomeProductItem>> getWishlist() async => [];
  @override
  Future<List<String>> getWishlistIds() async => [];
  @override
  Future<bool> toggleWishlist(String productId) async => true;
  @override
  Future<void> addToWishlist(String productId) async {}
  @override
  Future<void> removeFromWishlist(String productId) async {}
  @override
  Future<List<HomeProductItem>> syncWishlist(List<String> productIds) async => [];
}

class FakeOrdersNotifier extends OrdersNotifier {
  @override
  OrdersState build() => const OrdersState();
  @override
  Future<void> loadOrders({bool refresh = false}) async {}
}

void main() {
  testWidgets('MainScreen lazily mounts tabs only when navigated to', (tester) async {
    final container = ProviderContainer(
      overrides: [
        homeContentProvider.overrideWith(TestHomeContentNotifier.new),
        wishlistRepositoryProvider.overrideWithValue(FakeWishlistRepository()),
        ordersProvider.overrideWith(FakeOrdersNotifier.new),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: MainScreen(),
        ),
      ),
    );

    // Initial render: index 0 (HomeScreen) is rendered
    expect(find.byType(HomeScreen), findsOneWidget);

    // WishlistScreen and OrdersScreen MUST NOT be built in the widget tree on startup!
    expect(find.byType(WishlistScreen), findsNothing);
    expect(find.byType(OrdersScreen), findsNothing);

    // Navigate to Tab 1 (Wishlist)
    container.read(mainNavigationProvider.notifier).state = 1;
    await tester.pump(const Duration(milliseconds: 50));

    // Now WishlistScreen is mounted
    expect(find.byType(WishlistScreen), findsOneWidget);
    expect(find.byType(OrdersScreen), findsNothing);

    // Navigate to Tab 2 (Orders)
    container.read(mainNavigationProvider.notifier).state = 2;
    await tester.pump(const Duration(milliseconds: 50));

    // Now both WishlistScreen and OrdersScreen exist in the tree (WishlistScreen is offstage in IndexedStack)
    expect(find.byType(WishlistScreen, skipOffstage: false), findsOneWidget);
    expect(find.byType(OrdersScreen), findsOneWidget);

    // Unmount widget cleanly before disposing
    await tester.pumpWidget(const SizedBox());
  });
}
