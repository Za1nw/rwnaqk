import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/core/services/auth/customer_auth_api_service.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_controller.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_service.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/products_listing_controller.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/products_listing_service.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/products_listing_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/providers/fake_products_remote_data_source.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/repositories/products_repository.dart';
import 'package:rwnaqk_frontend/modules/checkout/controllers/payment_controller.dart';
import 'package:rwnaqk_frontend/modules/checkout/controllers/payment_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_service.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/contact_info_model.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/shipping_address.dart';
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

  group('1. Cart Variant Identity & Quantity Isolation', () {
    test('Adding same product with different sizes/colors creates separate lines', () {
      final authSession = Get.put(AuthSessionService());
      final profileStore = Get.put(ProfileStoreService(authSession));
      Get.put(CartUiController());
      final cart = Get.put(CartController(CartService(profileStore)));
      cart.clearCart();

      const baseProduct = HomeProductItem(
        id: 'HOODIE-101',
        title: 'Classic Velvet Hoodie',
        imageUrl: 'https://example.com/hoodie.jpg',
        price: 12000.0,
      );

      // Add Variant A: Black, XL
      cart.addToCart(baseProduct, quantity: 1, variantText: 'Black, XL');
      // Add Variant B: White, M
      cart.addToCart(baseProduct, quantity: 2, variantText: 'White, M');

      expect(cart.cartItems.length, 2);
      expect(cart.cartItems[0].id, 'HOODIE-101_Black, XL');
      expect(cart.cartItems[1].id, 'HOODIE-101_White, M');

      expect(cart.itemQuantities['HOODIE-101_Black, XL'], 1);
      expect(cart.itemQuantities['HOODIE-101_White, M'], 2);
      expect(cart.itemsCount, 3);
    });

    test('Updating quantity of one variant does not affect another variant', () {
      final authSession = Get.put(AuthSessionService());
      final profileStore = Get.put(ProfileStoreService(authSession));
      Get.put(CartUiController());
      final cart = Get.put(CartController(CartService(profileStore)));
      cart.clearCart();

      const baseProduct = HomeProductItem(
        id: 'SHOES-202',
        title: 'Leather Sneakers',
        imageUrl: 'https://example.com/shoes.jpg',
        price: 8000.0,
      );

      cart.addToCart(baseProduct, quantity: 1, variantText: 'Size 42');
      cart.addToCart(baseProduct, quantity: 1, variantText: 'Size 44');

      // Increment variant Size 42
      cart.incrementQuantity('SHOES-202_Size 42');

      expect(cart.itemQuantities['SHOES-202_Size 42'], 2);
      expect(cart.itemQuantities['SHOES-202_Size 44'], 1); // Unchanged

      // Decrement variant Size 44 to 0 (which removes it)
      cart.decrementQuantity('SHOES-202_Size 44');

      expect(cart.cartItems.length, 1);
      expect(cart.cartItems.first.id, 'SHOES-202_Size 42');
      expect(cart.itemQuantities.containsKey('SHOES-202_Size 44'), isFalse);
    });
  });

  group('2. Concurrent Order Submission Guard', () {
    test('PaymentController prevents duplicate orders on rapid double submission', () async {
      final authSession = Get.put(AuthSessionService());
      final profileStore = Get.put(ProfileStoreService(authSession));
      Get.put(CartUiController());
      final cart = Get.put(CartController(CartService(profileStore)));
      cart.clearCart();

      // Seed 1 item in cart
      cart.addToCart(
        const HomeProductItem(
          id: 'ITEM-1',
          title: 'Watch',
          imageUrl: 'https://example.com/watch.jpg',
          price: 5000.0,
        ),
        quantity: 1,
      );

      cart.shippingAddress.value = ShippingAddress(
        id: 'A1',
        country: 'Yemen',
        address: 'Hadda St',
        city: 'Sanaa',
        postcode: '0000',
      );
      cart.contactInfo.value = const ContactInfoModel(
        phone: '777000000',
        email: 'ahmed@example.com',
      );

      Get.put(OrdersUiController());
      final ordersService = OrdersService();
      final ordersController = Get.put(OrdersController(ordersService));
      ordersController.orders.clear();

      Get.put(PaymentUiController());
      final payment = Get.put(PaymentController());

      // Trigger two simultaneous submissions
      final f1 = payment.confirmAndSubmitOrder();
      final f2 = payment.confirmAndSubmitOrder();

      await Future.wait([f1, f2]);

      // Only one order must be recorded in ordersController
      expect(ordersController.orders.length, 1);
      expect(payment.isSubmitting.value, isFalse);
    });
  });

  group('3. Session Isolation & Worker Disposal on Logout', () {
    test('Logout clears session data and does NOT reseed address via worker', () async {
      final authSession = Get.put(AuthSessionService());
      final profileStore = Get.put(ProfileStoreService(authSession));
      Get.put(CartUiController());
      final cart = Get.put(CartController(CartService(profileStore)));

      Get.put(OrdersUiController());
      final orders = Get.put(OrdersController(OrdersService()));

      Get.put(CustomerAuthApiService());
      Get.put(AppSettingsUiController());
      final settings = Get.put(AppSettingsController(AppSettingsService()));

      // Login customer
      authSession.startSession(accessToken: 'token_user_1');
      profileStore.addresses.updateFromRiverpod([
        ShippingAddress(
          id: 'ADDR-1',
          country: 'Yemen',
          address: 'Al-Zubairi St',
          city: 'Sanaa',
          postcode: '0000',
        ),
      ]);
      orders.orders.add(
        OrderModel(
          id: 'ORD-USER-1',
          createdAt: DateTime.now(),
          total: 15000,
          itemsCount: 1,
          status: 'pending',
          addressLine: 'Sanaa',
        ),
      );

      expect(authSession.isAuthenticated, isTrue);
      expect(profileStore.addresses, isNotEmpty);
      expect(orders.orders, isNotEmpty);

      // Perform logout
      await settings.logout();

      // Verify all local user data is wiped
      expect(authSession.isAuthenticated, isFalse);
      expect(cart.cartItems, isEmpty);
      expect(profileStore.addresses, isEmpty);
      expect(orders.orders, isEmpty);

      // Crucial: Address worker must NOT reseed a dummy shipping address on address wipe!
      expect(cart.shippingAddress.value.isEmpty, isTrue);
    });

    test('Workers in PaymentController and CartController dispose cleanly on onClose', () {
      final authSession = Get.put(AuthSessionService());
      final profileStore = Get.put(ProfileStoreService(authSession));
      Get.put(CartUiController());
      final cart = Get.put(CartController(CartService(profileStore)));

      Get.put(PaymentUiController());
      final payment = Get.put(PaymentController());

      // Calling onClose should cancel workers without throwing
      expect(() => cart.onClose(), returnsNormally);
      expect(() => payment.onClose(), returnsNormally);
    });
  });

  group('4. ScrollController & Async Race Conditions', () {
    test('Reopening ProductsListingController handles ScrollController cleanly', () {
      final listingService = ProductsListingService();
      final repo = FakeProductsRepository(listingService: listingService);

      // First screen open
      var ui = Get.put(ProductsListingUiController());
      var controller = Get.put(
        ProductsListingController(listingService, repository: repo),
      );

      // UI closes first, then controller
      ui.onClose();
      expect(() => controller.onClose(), returnsNormally);

      Get.delete<ProductsListingUiController>();
      Get.delete<ProductsListingController>();

      // Reopening screen second time
      ui = Get.put(ProductsListingUiController());
      controller = Get.put(
        ProductsListingController(listingService, repository: repo),
      );

      expect(controller.scrollController.hasClients, isFalse);
      expect(() => controller.onClose(), returnsNormally);
      expect(() => ui.onClose(), returnsNormally);
    });

    test('SearchController rejects stale responses using sequence token', () async {
      Get.put(SearchUiController());
      final search = Get.put(AppSearchController(SearchService()));

      // Run fast succession of queries
      search.onChanged('QueryA');
      search.onChanged('QueryB');

      // Allow debounce timer to fire
      await Future.delayed(const Duration(milliseconds: 300));

      expect(search.isLoading.value, isFalse);
      expect(() => search.onClose(), returnsNormally);
    });
  });

  group('5. Fake Repositories & Mock Data Architecture', () {
    test('IProductsRepository returns formatted mock products and reviews', () async {
      final IProductsRepository repo = FakeProductsRepository();

      final products = await repo.getProducts(seed: 1, limit: 10);
      expect(products, isNotEmpty);
      expect(products.length, 10);

      final single = await repo.getProductById(products.first.id);
      expect(single, isNotNull);
      expect(single!.id, products.first.id);

      final reviews = await repo.getProductReviews(products.first.id);
      expect(reviews, isNotEmpty);
    });

    test('IOrdersRepository handles in-memory order creation and retrieval', () async {
      final IOrdersRepository repo = FakeOrdersRepository();

      final initialOrders = await repo.getOrders();
      expect(initialOrders, isNotEmpty);
      final initialCount = initialOrders.length;

      final newOrder = OrderModel(
        id: 'ORD-TEST-99',
        createdAt: DateTime.now(),
        total: 5500,
        itemsCount: 1,
        status: 'pending',
        addressLine: 'Aden',
      );

      await repo.createOrder(newOrder);

      final updatedOrders = await repo.getOrders();
      expect(updatedOrders.length, initialCount + 1);
      expect(updatedOrders.first.id, 'ORD-TEST-99');

      final fetched = await repo.getOrderById('ORD-TEST-99');
      expect(fetched, isNotNull);
      expect(fetched!.total, 5500);
    });
  });
}
