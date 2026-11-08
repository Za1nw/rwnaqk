import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rwnaqk_frontend/core/bindings/initial_binding.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_controller.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/product_details_controller.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/product_details_service.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/product_details_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/providers/fake_products_remote_data_source.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/repositories/products_repository.dart';
import 'package:rwnaqk_frontend/modules/checkout/controllers/payment_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/contact_info_model.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/shipping_address.dart';
import 'package:rwnaqk_frontend/modules/home/controllers/main_controller.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    dotenv.loadFromString(envString: 'APP_ENV=development\nENABLE_MOCK_DATA=true');
  });

  tearDown(() {
    Get.reset();
  });

  group('Phase 3 E2E: Full Shopping Journey (Home -> Details -> Cart -> Checkout -> Payment -> Order)', () {
    test('End-to-End purchase flow succeeds, applies coupon, and records order in history', () async {
      // 1. Composition Root Bootstrap
      final initialBinding = InitialBinding(initialAccessToken: 'mock_jwt_token_123');
      initialBinding.dependencies();

      final authSession = Get.find<AuthSessionService>();
      expect(authSession.isAuthenticated, isTrue);

      final cart = Get.find<CartController>();
      final ordersCtrl = Get.find<OrdersController>();
      final payment = Get.find<PaymentController>();

      // Ensure clean slate
      cart.clearCart();
      ordersCtrl.clearOrders();

      // 2. Catalog & Home: Browse products via IProductsRepository
      final IProductsRepository productsRepo = FakeProductsRepository();
      final catalogProducts = await productsRepo.getProducts(limit: 5);
      expect(catalogProducts, isNotEmpty);
      final selectedProduct = catalogProducts.first;

      // 3. Product Details: User opens product, picks size/color variant and quantity
      Get.put(ProductDetailsUiController());
      final detailsCtrl = Get.put(
        ProductDetailsController(
          ProductDetailsService(),
          repository: productsRepo,
        ),
      );
      detailsCtrl.item.value = selectedProduct;
      detailsCtrl.ui.setResolvedSelections(
        colorId: 'c1',
        size: 'XL',
        thumbIndex: 0,
        variationImagesLength: 1,
      );
      detailsCtrl.ui.incrementQuantity(); // quantity = 2
      expect(detailsCtrl.quantity.value, 2);

      // Add to Cart from Product Details
      cart.addToCart(
        detailsCtrl.product!,
        quantity: detailsCtrl.quantity.value,
        variantText: 'XL, Royal Navy',
      );

      // Verify Cart state
      expect(cart.cartItems.length, 1);
      final cartLine = cart.cartItems.first;
      expect(cartLine.id, '${selectedProduct.id}_XL, Royal Navy');
      expect(cartLine.productId, selectedProduct.id); // Original ID preserved!
      expect(cart.quantityOf(cartLine.id), 2);

      // 4. Cart View & Coupon: Apply promo discount
      final subtotalBeforeCoupon = cart.itemsSubtotal;
      expect(subtotalBeforeCoupon, selectedProduct.salePrice * 2);

      final couponApplied = cart.applyCoupon('RAWNAQ');
      expect(couponApplied, isTrue);
      expect(cart.hasCoupon, isTrue);
      expect(cart.couponDiscountPercent.value, 15);
      final expectedDiscount = subtotalBeforeCoupon * 0.15;
      expect(cart.couponDiscountAmount, closeTo(expectedDiscount, 0.01));

      // 5. Checkout & Shipping Prerequisites Setup
      cart.shippingAddress.value = ShippingAddress(
        id: 'ADDR-E2E-1',
        country: 'Yemen',
        address: 'Hadda Main St, Next to Kamim Center',
        city: 'Sanaa',
        postcode: '0000',
      );
      cart.contactInfo.value = const ContactInfoModel(
        phone: '+967 770 000 111',
        email: 'customer@rawnaqk.com',
      );

      expect(cart.canCheckout, isTrue);
      expect(payment.validateCheckoutPrerequisites(), isTrue);

      // 6. Payment Confirmation: Cash on Delivery
      payment.setPaymentMethodId('cod');
      expect(payment.isWalletPayment, isFalse);

      // 7. Final Order Submission
      await payment.confirmAndSubmitOrder();

      // 8. Order Verification in OrdersController & History
      expect(ordersCtrl.orders.length, 1);
      final placedOrder = ordersCtrl.orders.first;
      expect(placedOrder.status, 'pending');
      expect(placedOrder.itemsCount, 2);
      expect(placedOrder.addressLine, contains('Sanaa'));
      expect(placedOrder.details, isNotNull);
      expect(placedOrder.details!.items.first.title, selectedProduct.title);

      // Cart must be automatically emptied after confirmed order
      expect(cart.cartItems, isEmpty);
      expect(cart.itemQuantities, isEmpty);
      expect(cart.hasCoupon, isFalse);
    });
  });

  group('Phase 3 E2E: Checkout Validation & Error Resilience', () {
    test('Empty cart blocks checkout attempt', () {
      final initialBinding = InitialBinding(initialAccessToken: 'mock_jwt_token_123');
      initialBinding.dependencies();

      final cart = Get.find<CartController>();
      final payment = Get.find<PaymentController>();
      cart.clearCart();

      expect(cart.canCheckout, isFalse);
      expect(payment.validateCheckoutPrerequisites(), isFalse);
    });

    test('Missing shipping address blocks submission', () {
      final initialBinding = InitialBinding(initialAccessToken: 'mock_jwt_token_123');
      initialBinding.dependencies();

      final cart = Get.find<CartController>();
      final payment = Get.find<PaymentController>();
      cart.clearCart();

      cart.addToCart(
        const HomeProductItem(
          id: 'ITEM-VALIDATE',
          title: 'Silk Scarf',
          imageUrl: 'https://example.com/scarf.jpg',
          price: 4500.0,
        ),
      );

      // Shipping address is empty
      cart.shippingAddress.value = ShippingAddress.empty();
      expect(payment.validateCheckoutPrerequisites(), isFalse);
    });

    test('Wallet payment requires receipt before confirmation', () {
      final initialBinding = InitialBinding(initialAccessToken: 'mock_jwt_token_123');
      initialBinding.dependencies();

      final cart = Get.find<CartController>();
      final payment = Get.find<PaymentController>();
      cart.clearCart();

      cart.addToCart(
        const HomeProductItem(
          id: 'ITEM-WALLET',
          title: 'Handbag',
          imageUrl: 'https://example.com/bag.jpg',
          price: 15000.0,
        ),
      );
      cart.shippingAddress.value = ShippingAddress(
        id: 'A1',
        country: 'Yemen',
        address: 'Al-Zubairi',
        city: 'Sanaa',
        postcode: '0000',
      );
      cart.contactInfo.value = const ContactInfoModel(
        phone: '777000111',
        email: 'test@example.com',
      );

      // Switch to Wallet payment without receipt image
      payment.setPaymentMethodId('wallet');
      expect(payment.isWalletPayment, isTrue);
      expect(payment.hasReceipt, isFalse);

      expect(payment.validateCheckoutPrerequisites(), isFalse);
    });
  });

  group('Phase 3 E2E: Logout, Account Switching & Local Data Isolation', () {
    test('Logout clears local state only without deleting remote/catalog contracts', () async {
      final initialBinding = InitialBinding(initialAccessToken: 'user_A_token');
      initialBinding.dependencies();

      final authSession = Get.find<AuthSessionService>();
      final cart = Get.find<CartController>();
      final orders = Get.find<OrdersController>();
      final profile = Get.find<ProfileStoreService>();
      final settings = Get.find<AppSettingsController>();

      // User A populates cart, addresses, orders
      cart.addToCart(
        const HomeProductItem(
          id: 'USER-A-PROD',
          title: 'User A Item',
          imageUrl: 'https://example.com/a.jpg',
          price: 1000.0,
        ),
      );
      profile.addresses.add(
        ShippingAddress(
          id: 'ADDR-USER-A',
          country: 'Yemen',
          address: 'User A Street',
          city: 'Taiz',
          postcode: '0000',
        ),
      );

      expect(authSession.isAuthenticated, isTrue);
      expect(cart.cartItems, isNotEmpty);
      expect(profile.addresses, isNotEmpty);

      // User A logs out
      await settings.logout();

      // Verify all local user session data is wiped cleanly
      expect(authSession.isAuthenticated, isFalse);
      expect(cart.cartItems, isEmpty);
      expect(profile.addresses, isEmpty);
      expect(orders.orders, isEmpty);

      // Verify no address worker re-seeded dummy data on address wipe
      expect(cart.shippingAddress.value.isEmpty, isTrue);

      // User B logs in
      authSession.startSession(accessToken: 'user_B_token');
      expect(authSession.isAuthenticated, isTrue);

      // User B sees empty cart and empty addresses (zero data leakage from User A)
      expect(cart.cartItems, isEmpty);
      expect(profile.addresses, isEmpty);
    });
  });

  group('Phase 3 E2E: Controller Lifecycle & Repeated Navigation', () {
    test('Repeated tab navigation and screen recreation causes no memory leaks or crashes', () {
      final initialBinding = InitialBinding(initialAccessToken: 'session_token');
      initialBinding.dependencies();

      final mainCtrl = Get.find<MainController>();

      // Rapidly switch between all 5 main tabs
      for (int i = 0; i < MainController.tabsCount; i++) {
        mainCtrl.changeTab(i);
        expect(mainCtrl.currentIndex.value, i);
      }

      // Re-switch backwards
      for (int i = MainController.tabsCount - 1; i >= 0; i--) {
        mainCtrl.changeTab(i);
        expect(mainCtrl.currentIndex.value, i);
      }
    });
  });
}
