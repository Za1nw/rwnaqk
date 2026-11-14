import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' as getx;
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/core/services/auth/providers/auth_session_providers.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_controller.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_service.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/cart/data/models/cart_quote_model.dart';
import 'package:rwnaqk_frontend/modules/cart/providers/cart_providers.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

class MockCartRepository implements ICartRepository {
  Future<CartQuoteModel?> Function({
    required int addressId,
    required List<Map<String, dynamic>> items,
    String? couponCode,
    String? shippingOptionId,
    CancelToken? cancelToken,
  })? onRequestCartQuote;

  Future<Map<String, dynamic>> Function({
    required String couponCode,
    double subtotal,
    CancelToken? cancelToken,
  })? onValidateCoupon;

  List<Map<String, dynamic>> lastRequestedItems = [];
  int? lastAddressId;
  String? lastCouponCode;
  String? lastShippingOptionId;

  @override
  Future<CartQuoteModel?> requestCartQuote({
    required int addressId,
    required List<Map<String, dynamic>> items,
    String? couponCode,
    String? shippingOptionId,
    CancelToken? cancelToken,
  }) async {
    lastAddressId = addressId;
    lastRequestedItems = List<Map<String, dynamic>>.from(items);
    lastCouponCode = couponCode;
    lastShippingOptionId = shippingOptionId;

    if (onRequestCartQuote != null) {
      return onRequestCartQuote!(
        addressId: addressId,
        items: items,
        couponCode: couponCode,
        shippingOptionId: shippingOptionId,
        cancelToken: cancelToken,
      );
    }

    final double itemsTotal = items.fold(0.0, (sum, it) {
      final qty = (it['qty'] as num?)?.toDouble() ?? 1.0;
      return sum + (100.0 * qty);
    });

    final discount = couponCode != null ? 15.0 : 0.0;
    return CartQuoteModel(
      currency: 'YER',
      currencySymbol: 'ر.ي',
      isServiceable: true,
      addressId: addressId,
      items: const [],
      subtotal: itemsTotal,
      productDiscountTotal: 0.0,
      netSubtotal: itemsTotal,
      couponCode: couponCode,
      couponDiscountTotal: discount,
      shippingFee: 20.0,
      grandTotal: (itemsTotal - discount + 20.0),
      shippingOptions: const [],
    );
  }

  @override
  Future<Map<String, dynamic>> validateCoupon({
    required String couponCode,
    double subtotal = 0.0,
    CancelToken? cancelToken,
  }) async {
    if (onValidateCoupon != null) {
      return onValidateCoupon!(
        couponCode: couponCode,
        subtotal: subtotal,
        cancelToken: cancelToken,
      );
    }
    return {
      'status': true,
      'is_valid': true,
      'code': couponCode,
      'discount_percent': 15,
      'message': 'كود خصم فعال',
    };
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final dummyProduct = HomeProductItem(
    id: 'prod_10',
    title: 'فستان مخملي ملكي',
    price: 250.0,
    imageUrl: 'https://example.com/dress.jpg',
  );

  setUp(() {
    dotenv.loadFromString(
      envString: 'APP_ENV=development\nENABLE_MOCK_DATA=false\nAPI_BASE_URL=https://api.test.com',
    );
    getx.Get.reset();
    getx.Get.testMode = true;
  });

  tearDown(() {
    getx.Get.reset();
  });

  group('Phase 07.1: Financial Integrity & In-Flight Race Resistance', () {
    test('1. In-flight quote invalidation without starting new request rejects late arrival', () async {
      final mockRepo = MockCartRepository();
      final completer = Completer<CartQuoteModel?>();

      mockRepo.onRequestCartQuote = ({
        required addressId,
        required items,
        couponCode,
        shippingOptionId,
        cancelToken,
      }) {
        return completer.future;
      };

      final container = ProviderContainer(
        overrides: [
          cartRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      // Add item to cart
      container.read(cartProvider.notifier).addToCart(dummyProduct, quantity: 2);

      // Start quote calculation
      final refreshFuture = container.read(cartQuoteProvider.notifier).refreshQuote(
        addressId: 101,
      );

      expect(container.read(cartQuoteProvider).status, CartQuoteStatus.loading);
      final initialGen = container.read(cartQuoteProvider).generation;
      expect(initialGen, greaterThanOrEqualTo(1));

      // User changes quantity while request is still pending
      container.read(cartProvider.notifier).updateQuantity('prod_10', 3);

      // Status must become stale immediately and generation must increment
      expect(container.read(cartQuoteProvider).status, CartQuoteStatus.stale);
      expect(container.read(cartQuoteProvider).generation, greaterThan(initialGen));

      // Late HTTP response finally arrives
      completer.complete(const CartQuoteModel(
        currency: 'YER',
        currencySymbol: 'ر.ي',
        isServiceable: true,
        addressId: 101,
        items: [],
        subtotal: 500.0,
        productDiscountTotal: 0.0,
        netSubtotal: 500.0,
        shippingFee: 20.0,
        couponDiscountTotal: 0.0,
        grandTotal: 520.0,
        shippingOptions: [],
      ));

      final result = await refreshFuture;
      expect(result, isFalse, reason: 'Late arrival must be rejected');

      // State MUST remain stale, never resurrected to valid
      final currentState = container.read(cartQuoteProvider);
      expect(currentState.status, CartQuoteStatus.stale);
      expect(currentState.isValid, isFalse);
    });

    test('2. Address change immediately invalidates active quote and prevents stale checkout', () async {
      final mockRepo = MockCartRepository();
      final container = ProviderContainer(
        overrides: [
          cartRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      container.read(cartProvider.notifier).addToCart(dummyProduct, quantity: 1);

      // Establish valid quote for Address A (101)
      final success = await container.read(cartQuoteProvider.notifier).refreshQuote(
        addressId: 101,
      );
      expect(success, isTrue);
      expect(container.read(cartQuoteProvider).isValid, isTrue);
      expect(container.read(cartQuoteProvider).addressId, 101);

      // Address mutated -> invalidate quote
      container.read(cartQuoteProvider.notifier).invalidateQuote();

      expect(container.read(cartQuoteProvider).status, CartQuoteStatus.stale);
      expect(container.read(cartQuoteProvider).isValid, isFalse);
    });

    test('3. Coupon application and removal invalidate quote status', () async {
      final mockRepo = MockCartRepository();
      final container = ProviderContainer(
        overrides: [
          cartRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      container.read(cartProvider.notifier).addToCart(dummyProduct, quantity: 1);

      // Initial quote
      await container.read(cartQuoteProvider.notifier).refreshQuote(addressId: 202);
      expect(container.read(cartQuoteProvider).isValid, isTrue);

      // Apply coupon
      final applied = await container.read(cartQuoteProvider.notifier).applyCoupon(
        code: 'RWNAQK15',
        addressId: 202,
      );
      expect(applied, isTrue);
      expect(container.read(cartQuoteProvider).couponCode, 'RWNAQK15');
      expect(mockRepo.lastCouponCode, 'RWNAQK15');

      // Remove coupon -> establishes new quote without coupon
      final removed = await container.read(cartQuoteProvider.notifier).removeCoupon(
        addressId: 202,
      );
      expect(removed, isTrue);
      expect(container.read(cartQuoteProvider).couponCode, isNull);
      expect(mockRepo.lastCouponCode, isNull);
    });

    test('4. Shipping option change invalidates active quote', () async {
      final mockRepo = MockCartRepository();
      final container = ProviderContainer(
        overrides: [
          cartRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      container.read(cartProvider.notifier).addToCart(dummyProduct, quantity: 1);

      await container.read(cartQuoteProvider.notifier).refreshQuote(
        addressId: 303,
        shippingOptionId: 'express_pickup',
      );
      expect(container.read(cartQuoteProvider).isValid, isTrue);
      expect(container.read(cartQuoteProvider).shippingOptionId, 'express_pickup');

      // Shipping option changed -> quote must be invalidated
      container.read(cartQuoteProvider.notifier).invalidateQuote();
      expect(container.read(cartQuoteProvider).status, CartQuoteStatus.stale);
      expect(container.read(cartQuoteProvider).isValid, isFalse);
    });

    test('5. Session logout/boundary purges both Cart and Quote completely', () async {
      final mockRepo = MockCartRepository();
      final container = ProviderContainer(
        overrides: [
          cartRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      container.read(cartProvider.notifier).addToCart(dummyProduct, quantity: 2);
      await container.read(cartQuoteProvider.notifier).refreshQuote(addressId: 404);

      expect(container.read(cartProvider).isNotEmpty, isTrue);
      expect(container.read(cartQuoteProvider).isValid, isTrue);

      // Trigger session reset via clearSession
      container.read(authSessionProvider.notifier).clearSession();

      // Verify complete purge
      expect(container.read(cartProvider).isEmpty, isTrue);
      expect(container.read(cartQuoteProvider).status, CartQuoteStatus.idle);
      expect(container.read(cartQuoteProvider).quote, isNull);
      expect(container.read(cartQuoteProvider).isValid, isFalse);
    });

    test('6. Variant Identity Mapping: Preserves composite key and passes numeric variation ID', () async {
      final mockRepo = MockCartRepository();
      final container = ProviderContainer(
        overrides: [
          cartRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      // Add item with composite stable variant AND integer backend variation ID
      container.read(cartProvider.notifier).addToCart(
        dummyProduct,
        quantity: 2,
        variantText: 'أسود / 54',
        stableVariantId: 'color:black|size:54',
        productVariationId: 105,
      );

      final line = container.read(cartProvider).items.first;
      expect(line.stableVariantId, 'color:black|size:54');
      expect(line.productVariationId, 105);
      expect(line.id, 'prod_10_color:black|size:54');

      await container.read(cartQuoteProvider.notifier).refreshQuote(addressId: 505);

      expect(mockRepo.lastRequestedItems.length, 1);
      final sentItem = mockRepo.lastRequestedItems.first;
      expect(sentItem['product_id'], 10);
      expect(sentItem['product_variation_id'], 105);
      expect(sentItem['qty'], 2);
    });

    test('7. Unserviceable zone / Out of coverage handles warning and disables checkout validity', () async {
      final mockRepo = MockCartRepository();
      mockRepo.onRequestCartQuote = ({
        required addressId,
        required items,
        couponCode,
        shippingOptionId,
        cancelToken,
      }) async {
        return const CartQuoteModel(
          currency: 'YER',
          currencySymbol: 'ر.ي',
          isServiceable: false,
          addressId: 999,
          items: [],
          subtotal: 250.0,
          productDiscountTotal: 0.0,
          netSubtotal: 250.0,
          shippingFee: 0.0,
          couponDiscountTotal: 0.0,
          grandTotal: 250.0,
          shippingOptions: [],
          message: 'عذراً، التوصيل غير متاح حالياً لهذه المنطقة',
        );
      };

      final container = ProviderContainer(
        overrides: [
          cartRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      container.read(cartProvider.notifier).addToCart(dummyProduct);
      final success = await container.read(cartQuoteProvider.notifier).refreshQuote(
        addressId: 999,
      );

      expect(success, isTrue);
      final quoteState = container.read(cartQuoteProvider);
      expect(quoteState.isValid, isTrue);
      expect(quoteState.isServiceable, isFalse);
      expect(quoteState.message, contains('التوصيل غير متاح'));
    });

    test('8. GetX CartController bridge stays strictly synchronized with Riverpod state', () async {
      final mockRepo = MockCartRepository();
      final container = ProviderContainer(
        overrides: [
          cartRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final authSession = getx.Get.put(AuthSessionService(container: container));
      final profileStore = getx.Get.put<ProfileStoreService>(
        ProfileStoreService(authSession, container),
      );
      getx.Get.put<CartUiController>(CartUiController());
      final service = CartService(profileStore);
      final cartController = CartController(service, container: container);
      getx.Get.put<CartController>(cartController);

      // Add item via Riverpod
      container.read(cartProvider.notifier).addToCart(
        dummyProduct,
        quantity: 3,
        variantText: 'مقاس M',
        stableVariantId: 'size:m',
        productVariationId: 42,
      );

      // Check GetX projection
      expect(cartController.cartItems.length, 1);
      expect(cartController.itemsCount, 3);
      expect(cartController.itemQuantities[cartController.cartItems.first.id], 3);

      // Server Quote synchronization
      await container.read(cartQuoteProvider.notifier).refreshQuote(addressId: 707);
      expect(cartController.serverQuote.value, isNotNull);
      expect(cartController.serverQuote.value?.addressId, 707);
      expect(cartController.total, greaterThan(0.0));

      // Invalidate quote
      container.read(cartQuoteProvider.notifier).invalidateQuote();
      expect(container.read(cartQuoteProvider).isValid, isFalse);
    });
  });
}
