import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/core/services/auth/customer_auth_api_service.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_controller.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_service.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/checkout/controllers/payment_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_service.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/shipping_address.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_controller.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_service.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
  });

  group('P0-1: Double-Submission Guard & Worker Lifecycle in PaymentController', () {
    test('PaymentController prevents submission if isSubmitting is already true', () async {
      final authSession = Get.put(AuthSessionService());
      Get.put(ProfileStoreService(authSession));
      final payment = Get.put(PaymentController());

      // Set isSubmitting to true simulating an in-flight request
      payment.isSubmitting.value = true;

      // Invoking confirmAndSubmitOrder must immediately abort without altering state
      await payment.confirmAndSubmitOrder();

      // Ensure state remains locked
      expect(payment.isSubmitting.value, isTrue);

      // Cleanup
      payment.onClose();
    });

    test('PaymentController disposes owned worker cleanly on onClose', () {
      final authSession = Get.put(AuthSessionService());
      Get.put(ProfileStoreService(authSession));
      final payment = Get.put(PaymentController());

      // Ensure controller initializes and closes without error
      expect(() => payment.onClose(), returnsNormally);
    });
  });

  group('P0-2: Session Isolation & Cache Clearing on Logout', () {
    test('AppSettingsController logout clears cart, orders, and addresses', () async {
      final authSession = Get.put(AuthSessionService());
      Get.put(CustomerAuthApiService());
      final profileStore = Get.put(ProfileStoreService(authSession));

      Get.put(CartUiController());
      final cartService = CartService(profileStore);
      final cartController = Get.put(CartController(cartService));

      Get.put(OrdersUiController());
      final ordersService = OrdersService();
      final ordersController = Get.put(OrdersController(ordersService));

      Get.put(AppSettingsUiController());
      final settingsService = AppSettingsService();
      final settingsController = Get.put(AppSettingsController(settingsService));

      // Seed dummy user data
      const sampleItem = HomeProductItem(
        id: 'P99',
        title: 'Sample Product',
        imageUrl: 'https://example.com/img.jpg',
        price: 100.0,
      );
      cartController.cartItems.add(sampleItem);
      cartController.itemQuantities['P99'] = 2;

      profileStore.addresses.updateFromRiverpod([
        ShippingAddress(
          id: 'A1',
          country: 'Yemen',
          address: 'Street 1',
          city: 'Sanaa',
          postcode: '1234',
        ),
      ]);

      ordersController.orders.add(
        OrderModel(
          id: 'ORD-999',
          createdAt: DateTime.now(),
          total: 200.0,
          itemsCount: 1,
          status: 'pending',
          addressLine: 'Sanaa',
          deliveryName: 'Ahmed',
          deliveryPhone: '777000000',
        ),
      );

      // Verify data is present prior to logout
      expect(cartController.cartItems, isNotEmpty);
      expect(profileStore.addresses, isNotEmpty);
      expect(ordersController.orders, isNotEmpty);

      // Execute logout
      await settingsController.logout();

      // Verify that all user-specific data is wiped
      expect(cartController.cartItems, isEmpty);
      expect(cartController.itemQuantities, isEmpty);
      expect(profileStore.addresses, isEmpty);
      expect(ordersController.orders, isEmpty);
      expect(authSession.isAuthenticated, isFalse);
    });
  });

  group('CartController & ProductDetailsController Encapsulation', () {
    test('CartController.addToCart handles quantity directly and properly', () {
      final authSession = Get.put(AuthSessionService());
      final profileStore = Get.put(ProfileStoreService(authSession));
      Get.put(CartUiController());
      final cart = Get.put(CartController(CartService(profileStore)));

      // Clear any pre-seeded mock cart items for isolated test
      cart.clearCart();

      const sampleItem = HomeProductItem(
        id: 'PROD_1',
        title: 'Sneakers',
        imageUrl: 'https://example.com/shoe.jpg',
        price: 250.0,
      );

      // Add 3 units at once
      cart.addToCart(sampleItem, quantity: 3, variantText: 'Size 42');

      expect(cart.cartItems.length, 1);
      const lineId = 'PROD_1_Size 42';
      expect(cart.cartItems.first.id, lineId);
      expect(cart.itemQuantities[lineId], 3);
      expect(cart.itemVariantTexts[lineId], 'Size 42');

      // Add 2 more units of the same variant item
      cart.addToCart(sampleItem, quantity: 2, variantText: 'Size 42');
      expect(cart.itemQuantities[lineId], 5);

      // Worker closes without error
      cart.onClose();
    });
  });
}
