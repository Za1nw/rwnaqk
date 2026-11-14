import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/main.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_controller.dart';
import 'package:rwnaqk_frontend/modules/checkout/controllers/payment_controller.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/shipping_address.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/contact_info_model.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    dotenv.loadFromString(envString: 'APP_ENV=development\nENABLE_MOCK_DATA=true');
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('Official Integration Test: End-to-End Shopping Journey on UI Layer', (WidgetTester tester) async {
    // 1. Launch complete Flutter App widget tree with ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(
          initialRoute: AppRoutes.main,
          initialAccessToken: 'integration_test_token',
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify App rendered with authenticated session
    final authSession = Get.find<AuthSessionService>();
    expect(authSession.isAuthenticated, isTrue);

    final cart = Get.find<CartController>();
    final orders = Get.find<OrdersController>();
    final payment = Get.find<PaymentController>();

    cart.clearCart();
    orders.clearOrders();
    await tester.pumpAndSettle();

    // 2. Add product with specific variants to cart
    const testProduct = HomeProductItem(
      id: 'INTEG-PROD-01',
      title: 'Embroidered Velvet Abaya',
      imageUrl: 'https://example.com/abaya.jpg',
      price: 28000.0,
    );

    cart.addToCart(
      testProduct,
      quantity: 1,
      variantText: 'Size 56, Deep Black',
    );
    await tester.pumpAndSettle();

    expect(cart.cartItems.length, 1);
    expect(cart.cartItems.first.productId, 'INTEG-PROD-01');
    expect(cart.itemsCount, 1);

    // 3. Apply Coupon Discount in Cart
    final couponResult = cart.applyCoupon('RAWNAQ');
    expect(couponResult, isTrue);
    expect(cart.hasCoupon, isTrue);
    await tester.pumpAndSettle();

    // 4. Fill Shipping Address and Contact Info
    cart.shippingAddress.value = ShippingAddress(
      id: 'ADDR-INTEG',
      country: 'Yemen',
      address: 'Al-Khamseen St',
      city: 'Sanaa',
      postcode: '0000',
    );
    cart.contactInfo.value = const ContactInfoModel(
      phone: '+967 770 123 456',
      email: 'integration@rawnaqk.com',
    );
    await tester.pumpAndSettle();

    expect(payment.validateCheckoutPrerequisites(), isTrue);

    // 5. Select Cash on Delivery payment
    payment.setPaymentMethodId('cod');
    await tester.pumpAndSettle();

    // 6. Confirm and finalize order
    await payment.confirmAndSubmitOrder();
    await tester.pumpAndSettle();

    // 7. Verify order placed and recorded in OrdersController
    expect(orders.orders.length, 1);
    expect(orders.orders.first.itemsCount, 1);
    expect(orders.orders.first.status, 'pending');

    // Cart is emptied post purchase
    expect(cart.cartItems, isEmpty);
    expect(cart.hasCoupon, isFalse);
  });

  testWidgets('Official Integration Test: Session Logout and Data Isolation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(
          initialRoute: AppRoutes.main,
          initialAccessToken: 'integration_user_A',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final authSession = Get.find<AuthSessionService>();
    final cart = Get.find<CartController>();
    final orders = Get.find<OrdersController>();
    final profile = Get.find<ProfileStoreService>();
    final settings = Get.find<AppSettingsController>();
    final wishlist = Get.find<WishlistController>();

    // Seed session data
    cart.addToCart(
      const HomeProductItem(
        id: 'PROD-A',
        title: 'User A Product',
        imageUrl: 'https://example.com/a.jpg',
        price: 5000,
      ),
    );
    profile.addresses.add(
      ShippingAddress(
        id: 'A1',
        country: 'Yemen',
        address: 'St 1',
        city: 'Aden',
        postcode: '0000',
      ),
    );
    wishlist.wishlist.add(
      const HomeProductItem(
        id: 'FAV-A',
        title: 'User A Favorite',
        imageUrl: 'https://example.com/fav.jpg',
        price: 9000,
      ),
    );
    await tester.pumpAndSettle();

    expect(authSession.isAuthenticated, isTrue);
    expect(cart.cartItems, isNotEmpty);
    expect(profile.addresses, isNotEmpty);
    expect(wishlist.wishlist, isNotEmpty);

    // Logout
    await settings.logout();
    await tester.pumpAndSettle();

    expect(authSession.isAuthenticated, isFalse);
    expect(cart.cartItems, isEmpty);
    expect(profile.addresses, isEmpty);
    expect(orders.orders, isEmpty);
    expect(wishlist.wishlist, isEmpty);
    expect(cart.shippingAddress.value.isEmpty, isTrue);
  });
}

