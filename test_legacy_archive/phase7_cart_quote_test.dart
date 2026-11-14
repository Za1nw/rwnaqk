import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/core/translations/app_translations.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_controller.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_service.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/cart/data/models/cart_quote_model.dart';
import 'package:rwnaqk_frontend/modules/cart/providers/cart_providers.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_color_option.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

class MockCartRepository implements ICartRepository {
  CartQuoteModel? quoteToReturn;
  bool shouldThrowNetworkError = false;
  int delayMs = 0;
  Completer<CartQuoteModel?>? delayedQuoteCompleter;
  List<CancelToken?> cancelTokens = <CancelToken?>[];
  int requestQuoteCalls = 0;
  String? lastCouponCode;
  int? lastAddressId;

  @override
  Future<CartQuoteModel?> requestCartQuote({
    required int addressId,
    required List<Map<String, dynamic>> items,
    String? couponCode,
    String? shippingOptionId,
    CancelToken? cancelToken,
  }) async {
    requestQuoteCalls++;
    lastAddressId = addressId;
    lastCouponCode = couponCode;
    cancelTokens.add(cancelToken);

    if (shouldThrowNetworkError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/cart/quote'),
        error: 'Network connection error',
        type: DioExceptionType.connectionError,
      );
    }

    if (delayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: delayMs));
    }

    if (cancelToken?.isCancelled == true) {
      throw DioException(
        requestOptions: RequestOptions(path: '/cart/quote'),
        type: DioExceptionType.cancel,
      );
    }

    if (delayedQuoteCompleter != null) {
      return delayedQuoteCompleter!.future;
    }

    return quoteToReturn;
  }

  @override
  Future<Map<String, dynamic>> validateCoupon({
    required String couponCode,
    double subtotal = 0.0,
    CancelToken? cancelToken,
  }) async {
    lastCouponCode = couponCode;
    if (couponCode.toUpperCase() == 'VALID10') {
      return {'is_valid': true, 'discount_amount': 10.0};
    }
    return {'is_valid': false, 'message': 'Invalid coupon'};
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    Get.testMode = true;
    Get.clearTranslations();
    Get.addTranslations(AppTranslations().keys);
  });

  tearDown(() {
    Get.reset();
  });

  final itemAbaya = HomeProductItem(
    id: 'prod_10',
    title: 'عباية مخملية ملكية',
    price: 200.0,
    discountPercent: 10, // sale price: 180.0
    imageUrl: 'https://images.unsplash.com/abaya.jpg',
    availableColors: const [
      ProductColorOption(id: 'black', name: 'أسود', imageUrl: 'black.jpg'),
      ProductColorOption(id: 'navy', name: 'كحلي', imageUrl: 'navy.jpg'),
    ],
    availableSizes: const ['52', '54', '56'],
  );

  final itemDress = HomeProductItem(
    id: 'prod_20',
    title: 'فستان سهرة كلاسيك',
    price: 350.0,
    discountPercent: 0,
    imageUrl: 'https://images.unsplash.com/dress.jpg',
  );

  ProviderContainer createContainer({MockCartRepository? repo}) {
    final container = ProviderContainer(
      overrides: [
        if (repo != null) cartRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('Phase 07: CartState & Immutable Operations', () {
    test('Initial CartState is empty with zero subtotal and quantities', () {
      final container = createContainer();
      final state = container.read(cartProvider);

      expect(state.isEmpty, isTrue);
      expect(state.isNotEmpty, isFalse);
      expect(state.linesCount, 0);
      expect(state.totalQuantity, 0);
      expect(state.subtotal, 0.0);
    });

    test('addToCart creates immutable CartLineItem with effective discounted unit price', () {
      final container = createContainer();
      final notifier = container.read(cartProvider.notifier);

      final success = notifier.addToCart(
        itemAbaya,
        quantity: 2,
        variantText: 'أسود - 54',
        stableVariantId: 'color:black|size:54',
      );

      expect(success, isTrue);
      final state = container.read(cartProvider);

      expect(state.linesCount, 1);
      expect(state.totalQuantity, 2);
      expect(state.subtotal, 360.0); // 180.0 * 2

      final line = state.items.first;
      expect(line.id, 'prod_10_color:black|size:54');
      expect(line.productId, 'prod_10');
      expect(line.unitPrice, 180.0);
      expect(line.lineTotal, 360.0);
      expect(line.quantity, 2);
      expect(line.variantText, 'أسود - 54');
      expect(line.stableVariantId, 'color:black|size:54');
    });

    test('Adding same variant merges quantity into existing line without duplicating', () {
      final container = createContainer();
      final notifier = container.read(cartProvider.notifier);

      notifier.addToCart(
        itemAbaya,
        quantity: 1,
        variantText: 'أسود - 54',
        stableVariantId: 'color:black|size:54',
      );

      // Add same item and variant with quantity 3
      notifier.addToCart(
        itemAbaya,
        quantity: 3,
        variantText: 'Black - 54', // different text locale
        stableVariantId: 'color:black|size:54', // same canonical ID
      );

      final state = container.read(cartProvider);
      expect(state.linesCount, 1);
      expect(state.totalQuantity, 4);
      expect(state.subtotal, 720.0); // 180.0 * 4
      expect(state.items.first.quantity, 4);
    });

    test('Adding different variant of same product produces distinct line items', () {
      final container = createContainer();
      final notifier = container.read(cartProvider.notifier);

      notifier.addToCart(
        itemAbaya,
        quantity: 1,
        stableVariantId: 'color:black|size:52',
      );

      notifier.addToCart(
        itemAbaya,
        quantity: 2,
        stableVariantId: 'color:navy|size:56',
      );

      final state = container.read(cartProvider);
      expect(state.linesCount, 2);
      expect(state.totalQuantity, 3);
      expect(state.subtotal, 540.0); // 180.0 * 3
      expect(state.quantityOf('prod_10_color:black|size:52'), 1);
      expect(state.quantityOf('prod_10_color:navy|size:56'), 2);
    });

    test('Quantity update, decrement and remove operations behave predictably', () {
      final container = createContainer();
      final notifier = container.read(cartProvider.notifier);

      notifier.addToCart(itemDress, quantity: 2);
      var state = container.read(cartProvider);
      expect(state.totalQuantity, 2);

      // Increment
      notifier.incrementQuantity('prod_20');
      state = container.read(cartProvider);
      expect(state.totalQuantity, 3);

      // Decrement
      notifier.decrementQuantity('prod_20');
      state = container.read(cartProvider);
      expect(state.totalQuantity, 2);

      // Update quantity directly
      notifier.updateQuantity('prod_20', 5);
      state = container.read(cartProvider);
      expect(state.totalQuantity, 5);

      // Decrement below 1 removes line item
      notifier.updateQuantity('prod_20', 0);
      state = container.read(cartProvider);
      expect(state.isEmpty, isTrue);
    });

    test('clearCart empties all items and resets quote state', () {
      final container = createContainer();
      final notifier = container.read(cartProvider.notifier);

      notifier.addToCart(itemAbaya, quantity: 1);
      notifier.addToCart(itemDress, quantity: 2);
      expect(container.read(cartProvider).linesCount, 2);

      notifier.clearCart();
      final state = container.read(cartProvider);
      expect(state.isEmpty, isTrue);
      expect(state.linesCount, 0);
      expect(state.totalQuantity, 0);
    });
  });

  group('Phase 07: Authoritative Server Pricing Quote (Laravel Authority)', () {
    test('Successful quote returns valid server subtotal, shipping fee, discount, and grandTotal', () async {
      final sampleServerQuote = CartQuoteModel(
        currency: 'YER',
        currencySymbol: 'ر.ي',
        isServiceable: true,
        addressId: 101,
        items: const [],
        subtotal: 500.0,
        productDiscountTotal: 50.0,
        netSubtotal: 450.0,
        shippingFee: 25.0,
        couponCode: 'WELCOME',
        couponDiscountTotal: 45.0,
        grandTotal: 430.0, // 450 - 45 + 25
        shippingOptions: const [],
      );

      final mockRepo = MockCartRepository()..quoteToReturn = sampleServerQuote;
      final container = createContainer(repo: mockRepo);

      // Add item to cart first
      container.read(cartProvider.notifier).addToCart(itemDress, quantity: 1);

      final quoteNotifier = container.read(cartQuoteProvider.notifier);
      final ok = await quoteNotifier.refreshQuote(addressId: 101, couponCode: 'WELCOME');

      expect(ok, isTrue);
      final quoteState = container.read(cartQuoteProvider);

      expect(quoteState.status, CartQuoteStatus.valid);
      expect(quoteState.isValid, isTrue);
      expect(quoteState.subtotal, 500.0);
      expect(quoteState.productDiscountTotal, 50.0);
      expect(quoteState.couponDiscountTotal, 45.0);
      expect(quoteState.shippingFee, 25.0);
      expect(quoteState.grandTotal, 430.0);
      expect(quoteState.isServiceable, isTrue);
    });

    test('Unserviceable geographical coverage reports message and serviceable flag', () async {
      final unserviceableQuote = CartQuoteModel(
        currency: 'YER',
        currencySymbol: 'ر.ي',
        isServiceable: false,
        addressId: 999,
        items: const [],
        subtotal: 200.0,
        productDiscountTotal: 0.0,
        netSubtotal: 200.0,
        shippingFee: 0.0,
        couponDiscountTotal: 0.0,
        grandTotal: 200.0,
        shippingOptions: const [],
        message: 'عذراً، التوصيل غير متاح حالياً لهذه المنطقة',
      );

      final mockRepo = MockCartRepository()..quoteToReturn = unserviceableQuote;
      final container = createContainer(repo: mockRepo);

      container.read(cartProvider.notifier).addToCart(itemDress, quantity: 1);
      final quoteNotifier = container.read(cartQuoteProvider.notifier);

      await quoteNotifier.refreshQuote(addressId: 999);
      final quoteState = container.read(cartQuoteProvider);

      expect(quoteState.isValid, isTrue);
      expect(quoteState.isServiceable, isFalse);
      expect(quoteState.message, contains('غير متاح حالياً'));
    });

    test('Network error transitions quote status to failed with message', () async {
      final mockRepo = MockCartRepository()..shouldThrowNetworkError = true;
      final container = createContainer(repo: mockRepo);

      container.read(cartProvider.notifier).addToCart(itemDress, quantity: 1);
      final quoteNotifier = container.read(cartQuoteProvider.notifier);

      final ok = await quoteNotifier.refreshQuote(addressId: 101);
      expect(ok, isFalse);

      final quoteState = container.read(cartQuoteProvider);
      expect(quoteState.status, CartQuoteStatus.failed);
      expect(quoteState.isFailed, isTrue);
      expect(quoteState.errorMessage, isNotNull);
    });
  });

  group('Phase 07: Quote Invalidation on Cart & Option Mutations', () {
    test('Mutating cart state marks active quote as stale immediately', () async {
      final sampleServerQuote = CartQuoteModel(
        currency: 'YER',
        currencySymbol: 'ر.ي',
        isServiceable: true,
        addressId: 101,
        items: const [],
        subtotal: 350.0,
        productDiscountTotal: 0.0,
        netSubtotal: 350.0,
        shippingFee: 20.0,
        couponDiscountTotal: 0.0,
        grandTotal: 370.0,
        shippingOptions: const [],
      );

      final mockRepo = MockCartRepository()..quoteToReturn = sampleServerQuote;
      final container = createContainer(repo: mockRepo);

      final cartNotifier = container.read(cartProvider.notifier);
      final quoteNotifier = container.read(cartQuoteProvider.notifier);

      cartNotifier.addToCart(itemDress, quantity: 1);
      await quoteNotifier.refreshQuote(addressId: 101);

      expect(container.read(cartQuoteProvider).status, CartQuoteStatus.valid);

      // Mutating cart by incrementing quantity
      cartNotifier.incrementQuantity('prod_20');

      // Must be invalidated to stale immediately!
      expect(container.read(cartQuoteProvider).status, CartQuoteStatus.stale);
      expect(container.read(cartQuoteProvider).isStale, isTrue);
    });

    test('Removing an item marks active quote as stale', () async {
      final sampleServerQuote = CartQuoteModel(
        currency: 'YER',
        currencySymbol: 'ر.ي',
        isServiceable: true,
        addressId: 101,
        items: const [],
        subtotal: 550.0,
        productDiscountTotal: 0.0,
        netSubtotal: 550.0,
        shippingFee: 20.0,
        couponDiscountTotal: 0.0,
        grandTotal: 570.0,
        shippingOptions: const [],
      );

      final mockRepo = MockCartRepository()..quoteToReturn = sampleServerQuote;
      final container = createContainer(repo: mockRepo);

      final cartNotifier = container.read(cartProvider.notifier);
      final quoteNotifier = container.read(cartQuoteProvider.notifier);

      cartNotifier.addToCart(itemDress, quantity: 1);
      cartNotifier.addToCart(itemAbaya, quantity: 1);
      await quoteNotifier.refreshQuote(addressId: 101);

      expect(container.read(cartQuoteProvider).status, CartQuoteStatus.valid);

      // Remove item
      cartNotifier.removeFromCart('prod_20');

      expect(container.read(cartQuoteProvider).status, CartQuoteStatus.stale);
    });
  });

  group('Phase 07: Stale Quote Response Rejection (Race Condition Protection)', () {
    test('Delayed response from older quote generation is rejected when newer generation completes', () async {
      final mockRepo = MockCartRepository();
      final completer1 = Completer<CartQuoteModel?>();
      mockRepo.delayedQuoteCompleter = completer1;
      final container = createContainer(repo: mockRepo);

      final cartNotifier = container.read(cartProvider.notifier);
      final quoteNotifier = container.read(cartQuoteProvider.notifier);

      cartNotifier.addToCart(itemDress, quantity: 1);

      // Trigger Quote Request 1 (delayed)
      final future1 = quoteNotifier.refreshQuote(addressId: 100);
      final gen1 = container.read(cartQuoteProvider).generation;

      // User immediately modifies quantity to 2, triggering Quote Request 2
      cartNotifier.incrementQuantity('prod_20');
      mockRepo.delayedQuoteCompleter = null; // Next request completes immediately
      final quote2 = CartQuoteModel(
        currency: 'YER',
        currencySymbol: 'ر.ي',
        isServiceable: true,
        addressId: 100,
        items: const [],
        subtotal: 700.0,
        productDiscountTotal: 0.0,
        netSubtotal: 700.0,
        shippingFee: 20.0,
        couponDiscountTotal: 0.0,
        grandTotal: 720.0,
        shippingOptions: const [],
      );
      mockRepo.quoteToReturn = quote2;

      final ok2 = await quoteNotifier.refreshQuote(addressId: 100);
      expect(ok2, isTrue);
      final gen2 = container.read(cartQuoteProvider).generation;
      expect(gen2, greaterThan(gen1));
      expect(container.read(cartQuoteProvider).grandTotal, 720.0);

      // Now Quote Request 1's network call finally completes with older stale data ($370.0)
      final oldQuote1 = CartQuoteModel(
        currency: 'YER',
        currencySymbol: 'ر.ي',
        isServiceable: true,
        addressId: 100,
        items: const [],
        subtotal: 350.0,
        productDiscountTotal: 0.0,
        netSubtotal: 350.0,
        shippingFee: 20.0,
        couponDiscountTotal: 0.0,
        grandTotal: 370.0,
        shippingOptions: const [],
      );

      // Finish future1 by completing the pending future
      completer1.complete(oldQuote1);
      final ok1 = await future1;
      expect(ok1, isFalse); // Stale request rejected!

      // State MUST maintain Quote 2 data ($720.0), NOT reverted to old Quote 1 ($370.0)
      final currentState = container.read(cartQuoteProvider);
      expect(currentState.grandTotal, 720.0);
    });
  });

  group('Phase 07: Single-Writer Delegation Facade & GetX Compatibility', () {
    test('CartController delegates mutations to Riverpod and reflects updates seamlessly', () {
      final container = createContainer();
      final profileStore = Get.put(
        ProfileStoreService(
          Get.put(AuthSessionService(container: container)),
          container,
        ),
      );
      Get.put(CartUiController());
      final cartController = Get.put(CartController(CartService(profileStore), container: container));
      cartController.clearCart();

      expect(cartController.cartItems, isEmpty);
      expect(cartController.itemsCount, 0);

      // Add item via CartController
      cartController.addToCart(
        itemAbaya,
        quantity: 2,
        variantText: 'أسود - 54',
        stableVariantId: 'color:black|size:54',
      );

      // Both Riverpod and GetX reflect state change
      expect(container.read(cartProvider).linesCount, 1);
      expect(cartController.cartItems.length, 1);
      expect(cartController.itemsCount, 2);
      expect(cartController.itemsSubtotal, 360.0);

      // Increment via CartController
      final lineId = cartController.cartItems.first.id;
      cartController.incrementQuantity(lineId);
      expect(cartController.itemsCount, 3);
      expect(cartController.itemsSubtotal, 540.0);

      // Decrement via CartController
      cartController.decrementQuantity(lineId);
      expect(cartController.itemsCount, 2);
      expect(cartController.itemsSubtotal, 360.0);

      // Clear via CartController
      cartController.clearCart();
      expect(cartController.cartItems, isEmpty);
      expect(cartController.itemsCount, 0);
      expect(container.read(cartProvider).isEmpty, isTrue);
    });

    test('Riverpod external mutation automatically syncs to GetX CartController observables', () {
      final container = createContainer();
      final profileStore = Get.put(
        ProfileStoreService(
          Get.put(AuthSessionService(container: container)),
          container,
        ),
      );
      Get.put(CartUiController());
      final cartController = Get.put(CartController(CartService(profileStore), container: container));
      cartController.clearCart();

      // Directly mutate Riverpod state
      container.read(cartProvider.notifier).addToCart(itemDress, quantity: 4);

      // GetX CartController should immediately project this change
      expect(cartController.cartItems.length, 1);
      expect(cartController.itemsCount, 4);
      expect(cartController.itemsSubtotal, 1400.0); // 350 * 4
    });
  });

  group('Phase 07: Session Scoping & Data Isolation', () {
    test('Session logout cleans Riverpod cart state and prevents cross-account leak', () {
      final container = createContainer();
      final profileStore = Get.put(
        ProfileStoreService(
          Get.put(AuthSessionService(container: container)),
          container,
        ),
      );
      Get.put(CartUiController());
      final cartController = Get.put(CartController(CartService(profileStore), container: container));

      // User adds items to cart
      container.read(cartProvider.notifier).addToCart(itemDress, quantity: 2);
      expect(container.read(cartProvider).isNotEmpty, isTrue);
      expect(cartController.cartItems.isNotEmpty, isTrue);

      // Trigger session purge
      container.read(cartProvider.notifier).clearCart();

      expect(container.read(cartProvider).isEmpty, isTrue);
      expect(cartController.cartItems.isEmpty, isTrue);
      expect(cartController.itemsCount, 0);
    });
  });
}
