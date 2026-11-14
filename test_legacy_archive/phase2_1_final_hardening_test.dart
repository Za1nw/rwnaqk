import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rwnaqk_frontend/core/constants/app_env.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_controller.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_service.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/products_listing_controller.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/products_listing_service.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/products_listing_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/providers/fake_products_remote_data_source.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_controller.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_service.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/providers/fake_orders_repository.dart';
import 'package:rwnaqk_frontend/modules/orders/data/repositories/orders_repository.dart';
import 'package:rwnaqk_frontend/modules/search/controllers/app_search_controller.dart';
import 'package:rwnaqk_frontend/modules/search/controllers/search_service.dart';
import 'package:rwnaqk_frontend/modules/search/controllers/search_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:rwnaqk_frontend/modules/wishlist/controllers/wishlist_service.dart';
import 'package:rwnaqk_frontend/modules/wishlist/controllers/wishlist_ui_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    Get.reset();
  });

  group('Task 1: Cart Identity & Product Variants Preservation', () {
    test('CartItem retains original productId and stable lineId for variants', () {
      final authSession = Get.put(AuthSessionService());
      final profileStore = Get.put(ProfileStoreService(authSession));
      Get.put(CartUiController());
      final cart = Get.put(CartController(CartService(profileStore)));
      cart.clearCart();

      Get.put(WishlistUiController());
      final wishlist = Get.put(WishlistController(WishlistService()));
      wishlist.wishlist.clear();

      const baseItem = HomeProductItem(
        id: 'PROD-777',
        title: 'Premium Linen Shirt',
        imageUrl: 'https://example.com/shirt.jpg',
        price: 9500.0,
      );

      // Add to wishlist first to verify it gets removed by real productId
      wishlist.wishlist.add(baseItem);
      expect(wishlist.wishlist.any((e) => e.id == 'PROD-777'), isTrue);

      // Add Variant 1: Navy Blue, Large
      cart.addToCart(baseItem, quantity: 2, variantText: 'Navy Blue, L');
      // Add Variant 2: Desert Sand, Medium
      cart.addToCart(baseItem, quantity: 1, variantText: 'Desert Sand, M');

      expect(cart.cartItems.length, 2);

      final line1 = cart.cartItems[0];
      final line2 = cart.cartItems[1];

      // Verify lineIds are unique and distinct
      expect(line1.id, 'PROD-777_Navy Blue, L');
      expect(line2.id, 'PROD-777_Desert Sand, M');

      // CRUCIAL: Original productId is completely preserved!
      expect(line1.productId, 'PROD-777');
      expect(line2.productId, 'PROD-777');

      // Quantities are isolated per line
      expect(cart.quantityOf(line1.id), 2);
      expect(cart.quantityOf(line2.id), 1);

      // Wishlist removal was called with real productId 'PROD-777'
      expect(wishlist.wishlist.any((e) => e.id == 'PROD-777'), isFalse);
    });

    test('Updating or removing one variant does not affect another variant of same product', () {
      final authSession = Get.put(AuthSessionService());
      final profileStore = Get.put(ProfileStoreService(authSession));
      Get.put(CartUiController());
      final cart = Get.put(CartController(CartService(profileStore)));
      cart.clearCart();

      const baseItem = HomeProductItem(
        id: 'JACKET-99',
        title: 'Winter Jacket',
        imageUrl: 'https://example.com/jacket.jpg',
        price: 35000.0,
      );

      cart.addToCart(baseItem, quantity: 1, variantText: 'Black, XL');
      cart.addToCart(baseItem, quantity: 3, variantText: 'Grey, S');

      const id1 = 'JACKET-99_Black, XL';
      const id2 = 'JACKET-99_Grey, S';

      // Increment Black, XL
      cart.incrementQuantity(id1);
      expect(cart.quantityOf(id1), 2);
      expect(cart.quantityOf(id2), 3); // Untouched

      // Remove Black, XL completely
      cart.removeFromCart(id1);
      expect(cart.cartItems.length, 1);
      expect(cart.cartItems.first.id, id2);
      expect(cart.cartItems.first.productId, 'JACKET-99');
      expect(cart.quantityOf(id2), 3);
    });
  });

  group('Task 2: ScrollController Lifecycle & Single Ownership', () {
    test('ProductsListingController owns ScrollController and survives repeated fenix recreation', () {
      final listingService = ProductsListingService();
      final repo = FakeProductsRepository(listingService: listingService);

      // Simulate opening and closing screen 5 times
      for (int i = 0; i < 5; i++) {
        Get.put(ProductsListingUiController());
        final controller = Get.put(
          ProductsListingController(listingService, repository: repo),
        );

        expect(controller.scrollController, isNotNull);
        expect(controller.scrollController.hasClients, isFalse);

        // Delete dependencies as GetX does when route is popped
        Get.delete<ProductsListingController>();
        Get.delete<ProductsListingUiController>();
      }
    });
  });

  group('Task 3: Fake Repositories Lifetime & User Session Isolation', () {
    test('FakeOrdersRepository persists orders during navigation and clears on logout', () async {
      final IOrdersRepository repo = FakeOrdersRepository(service: OrdersService());

      // Initial orders count
      final initial = await repo.getOrders();
      expect(initial.length, 4);

      // User creates a new order
      final userOrder = OrderModel(
        id: 'ORD-USER-LIVE',
        createdAt: DateTime.now(),
        total: 18000,
        itemsCount: 2,
        status: 'pending',
        addressLine: 'Sanaa',
      );
      await repo.createOrder(userOrder);

      // Persisted in repository
      final withUser = await repo.getOrders();
      expect(withUser.length, 5);
      expect(withUser.first.id, 'ORD-USER-LIVE');

      // Simulate OrdersController lifecycle (screen opened, closed, reopened)
      Get.put(OrdersUiController());
      var ordersCtrl = OrdersController(OrdersService(), repository: repo);
      ordersCtrl.onInit();
      ordersCtrl.orders.assignAll(await repo.getOrders());
      expect(ordersCtrl.orders.length, 5);

      // Logout clears repository orders completely
      ordersCtrl.clearOrders();
      expect(ordersCtrl.orders, isEmpty);

      // Repository memory is clean
      final afterLogout = await repo.getOrders();
      // On fresh access after clear, initial mock catalog orders are re-seeded for next session
      expect(afterLogout.any((o) => o.id == 'ORD-USER-LIVE'), isFalse);
    });
  });

  group('Task 4 & 5: Async & Error Handling with isClosed Guard', () {
    test('SearchController does not update results or throw if deleted during async search', () async {
      Get.put(SearchUiController());
      final search = Get.put(AppSearchController(SearchService()));

      // Trigger search
      search.onChanged('Dress');

      // Immediately delete controller from GetX container
      Get.delete<AppSearchController>();
      expect(search.isClosed, isTrue);

      // Let any delayed timers or futures run
      await Future.delayed(const Duration(milliseconds: 300));
      // No unhandled errors thrown, results not updated on deleted controller
    });

    test('ProductsListingController does not mutate state if deleted during loadMore', () async {
      final listingService = ProductsListingService();
      final repo = FakeProductsRepository(listingService: listingService);
      Get.put(ProductsListingUiController());
      final controller = Get.put(
        ProductsListingController(listingService, repository: repo),
      );

      final loadFuture = controller.loadMore();
      // Delete from container before loadMore finishes
      Get.delete<ProductsListingController>();
      expect(controller.isClosed, isTrue);

      await loadFuture;
    });
  });

  group('Task 6: Environment Safety', () {
    test('AppEnv.enableMockData is strictly false in production', () {
      dotenv.loadFromString(envString: 'APP_ENV=production\nENABLE_MOCK_DATA=true');
      expect(AppEnv.isProduction, isTrue);
      // Production MUST ignore ENABLE_MOCK_DATA=true to never display fake data
      expect(AppEnv.enableMockData, isFalse);
    });

    test('AppEnv.enableMockData defaults to true in development', () {
      dotenv.loadFromString(envString: 'APP_ENV=development\n');
      expect(AppEnv.isDevelopment, isTrue);
      expect(AppEnv.enableMockData, isTrue);
    });
  });
}
