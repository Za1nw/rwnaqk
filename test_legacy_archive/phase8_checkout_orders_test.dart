import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' as getx;
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_controller.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_service.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/cart/data/models/cart_quote_model.dart';
import 'package:rwnaqk_frontend/modules/cart/providers/cart_providers.dart';
import 'package:rwnaqk_frontend/modules/checkout/controllers/payment_controller.dart';
import 'package:rwnaqk_frontend/modules/checkout/providers/checkout_providers.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/contact_info_model.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/shipping_address.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_controller.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_service.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_details_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/repositories/orders_repository.dart';
import 'package:rwnaqk_frontend/modules/orders/providers/orders_providers.dart';

class MockOrdersRepository implements IOrdersRepository {
  List<OrderModel> orders = [];
  int submitCalls = 0;
  String? lastIdempotencyKey;
  double? lastExpectedGrandTotal;
  String? lastPaymentMethod;
  bool shouldThrowOnSubmit = false;
  Completer<OrderModel>? delayedSubmitCompleter;

  @override
  Future<List<OrderModel>> getOrders() async {
    return List.unmodifiable(orders);
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    for (final o in orders) {
      if (o.id == orderId) return o;
    }
    return null;
  }

  @override
  Future<OrderDetailsModel> getOrderDetails(OrderModel order) async {
    return const OrderDetailsModel(
      items: [],
      subtotal: 100.0,
      shippingFee: 20.0,
      shippingMethodKey: 'standard',
      paymentMethodKey: 'cod',
      deliveryName: 'Ahmed',
      deliveryPhone: '777000000',
      addressLine: 'Sanaa',
    );
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    orders.insert(0, order);
    return order;
  }

  @override
  Future<OrderModel> submitCheckout({
    required int addressId,
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
    String? couponCode,
    String? shippingOptionId,
    double? expectedGrandTotal,
    Map<String, dynamic>? walletAccount,
    String? receiptImageUrl,
    String? notes,
    String? idempotencyKey,
  }) async {
    submitCalls++;
    lastIdempotencyKey = idempotencyKey;
    lastExpectedGrandTotal = expectedGrandTotal;
    lastPaymentMethod = paymentMethod;

    if (delayedSubmitCompleter != null) {
      return delayedSubmitCompleter!.future;
    }

    if (shouldThrowOnSubmit) {
      throw Exception('Simulated gateway timeout error');
    }

    final newOrder = OrderModel(
      id: 'ORD-${1000 + orders.length}',
      status: paymentMethod == 'wallet' ? 'pending' : 'processing',
      total: expectedGrandTotal ?? 250.0,
      createdAt: DateTime.now(),
      itemsCount: items.fold(0, (sum, i) => sum + ((i['qty'] as num?)?.toInt() ?? 1)),
    );

    orders.insert(0, newOrder);
    return newOrder;
  }

  @override
  Future<OrderModel> cancelOrder(String orderId) async {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final old = orders[index];
      final cancelled = OrderModel(
        id: old.id,
        createdAt: old.createdAt,
        total: old.total,
        itemsCount: old.itemsCount,
        status: 'cancelled',
      );
      orders[index] = cancelled;
      return cancelled;
    }
    throw Exception('Order not found');
  }

  @override
  Future<void> clearLocalCache() async {
    orders.clear();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final dummyProduct = HomeProductItem(
    id: 'prod_99',
    title: 'عباية كريب فاخرة',
    price: 300.0,
    imageUrl: 'https://example.com/abaya.jpg',
  );

  final sampleValidQuote = CartQuoteModel(
    currency: 'YER',
    currencySymbol: 'ر.ي',
    isServiceable: true,
    addressId: 10,
    items: const [],
    subtotal: 300.0,
    productDiscountTotal: 0.0,
    netSubtotal: 300.0,
    shippingFee: 25.0,
    grandTotal: 325.0,
    couponDiscountTotal: 0.0,
    shippingOptions: const [],
  );

  const sampleAddress = ShippingAddress(
    id: '10',
    country: 'اليمن',
    city: 'صنعاء',
    address: 'شارع حدة',
    postcode: '0000',
    isServiceable: true,
  );

  const sampleContact = ContactInfoModel(
    phone: '777123456',
    email: 'test@rawnaqk.com',
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

  group('Phase 08: Checkout, Orders & Payment Riverpod 3 Migration', () {
    test('1. Pre-submission validation guards prevent invalid checkout', () async {
      final mockOrdersRepo = MockOrdersRepository();
      final container = ProviderContainer(
        overrides: [
          ordersRepositoryProvider.overrideWithValue(mockOrdersRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(checkoutFlowProvider.notifier);

      // A: Empty cart guard
      final resEmpty = await notifier.submitCheckout(
        cart: const CartState(items: []),
        quote: CartQuoteState(status: CartQuoteStatus.valid, quote: sampleValidQuote),
        address: sampleAddress,
        contact: sampleContact,
      );
      expect(resEmpty, isNull);
      expect(container.read(checkoutFlowProvider).isFailed, isTrue);
      expect(container.read(checkoutFlowProvider).errorMessage, contains('السلة فارغة'));

      // B: Stale quote guard
      container.read(cartProvider.notifier).addToCart(dummyProduct);
      final resStale = await notifier.submitCheckout(
        cart: container.read(cartProvider),
        quote: const CartQuoteState(status: CartQuoteStatus.stale),
        address: sampleAddress,
        contact: sampleContact,
      );
      expect(resStale, isNull);
      expect(container.read(checkoutFlowProvider).errorMessage, contains('عرض السعر غير صالح'));

      // C: Unserviceable address guard
      final unserviceableAddr = sampleAddress.copyWith(isServiceable: false);
      final resUnserviceable = await notifier.submitCheckout(
        cart: container.read(cartProvider),
        quote: CartQuoteState(status: CartQuoteStatus.valid, quote: sampleValidQuote),
        address: unserviceableAddr,
        contact: sampleContact,
      );
      expect(resUnserviceable, isNull);
      expect(container.read(checkoutFlowProvider).errorMessage, contains('نطاق التغطية'));

      // D: Wallet without receipt guard
      notifier.setPaymentMethod('wallet');
      final resNoReceipt = await notifier.submitCheckout(
        cart: container.read(cartProvider),
        quote: CartQuoteState(status: CartQuoteStatus.valid, quote: sampleValidQuote),
        address: sampleAddress,
        contact: sampleContact,
      );
      expect(resNoReceipt, isNull);
      expect(container.read(checkoutFlowProvider).errorMessage, contains('سند التحويل'));
    });

    test('2. Double-tap guard rejects concurrent submission attempts', () async {
      final mockOrdersRepo = MockOrdersRepository();
      final completer = Completer<OrderModel>();
      mockOrdersRepo.delayedSubmitCompleter = completer;

      final container = ProviderContainer(
        overrides: [
          ordersRepositoryProvider.overrideWithValue(mockOrdersRepo),
        ],
      );
      addTearDown(container.dispose);

      container.read(cartProvider.notifier).addToCart(dummyProduct);
      final notifier = container.read(checkoutFlowProvider.notifier);

      // Start submission 1
      final future1 = notifier.submitCheckout(
        cart: container.read(cartProvider),
        quote: CartQuoteState(status: CartQuoteStatus.valid, quote: sampleValidQuote),
        address: sampleAddress,
        contact: sampleContact,
      );

      expect(container.read(checkoutFlowProvider).isSubmitting, isTrue);

      // Immediate concurrent submission 2 while 1 is in-flight
      final future2 = notifier.submitCheckout(
        cart: container.read(cartProvider),
        quote: CartQuoteState(status: CartQuoteStatus.valid, quote: sampleValidQuote),
        address: sampleAddress,
        contact: sampleContact,
      );

      final res2 = await future2;
      expect(res2, isNull, reason: 'Concurrent second tap must be rejected by double-tap guard');
      expect(mockOrdersRepo.submitCalls, 1, reason: 'Only one HTTP call should be dispatched');

      // Complete submission 1
      completer.complete(OrderModel(
        id: 'ORD-101',
        status: 'processing',
        total: 325.0,
        createdAt: DateTime.now(),
        itemsCount: 1,
      ));

      final res1 = await future1;
      expect(res1, isNotNull);
      expect(res1?.id, 'ORD-101');
      expect(container.read(checkoutFlowProvider).isSuccess, isTrue);
    });

    test('3. Idempotency key is preserved during retry and cleared on success', () async {
      final mockOrdersRepo = MockOrdersRepository();
      mockOrdersRepo.shouldThrowOnSubmit = true; // First attempt fails

      final container = ProviderContainer(
        overrides: [
          ordersRepositoryProvider.overrideWithValue(mockOrdersRepo),
        ],
      );
      addTearDown(container.dispose);

      container.read(cartProvider.notifier).addToCart(dummyProduct);
      final notifier = container.read(checkoutFlowProvider.notifier);

      // Attempt 1 fails
      final failResult = await notifier.submitCheckout(
        cart: container.read(cartProvider),
        quote: CartQuoteState(status: CartQuoteStatus.valid, quote: sampleValidQuote),
        address: sampleAddress,
        contact: sampleContact,
      );
      expect(failResult, isNull);
      expect(container.read(checkoutFlowProvider).isFailed, isTrue);

      final originalKey = container.read(checkoutFlowProvider).activeIdempotencyKey;
      expect(originalKey, isNotNull);
      expect(mockOrdersRepo.lastIdempotencyKey, originalKey);

      // Attempt 2: Retry after failure -> MUST retain the same idempotency key
      mockOrdersRepo.shouldThrowOnSubmit = false;
      final retryResult = await notifier.submitCheckout(
        cart: container.read(cartProvider),
        quote: CartQuoteState(status: CartQuoteStatus.valid, quote: sampleValidQuote),
        address: sampleAddress,
        contact: sampleContact,
      );
      expect(retryResult, isNotNull);
      expect(mockOrdersRepo.lastIdempotencyKey, originalKey, reason: 'Retry must reuse stable idempotency key');
      expect(container.read(checkoutFlowProvider).activeIdempotencyKey, isNull, reason: 'Key must be cleared after success');
    });

    test('4. Orders list filtering and status state machine in Riverpod', () async {
      final mockOrdersRepo = MockOrdersRepository();
      final now = DateTime.now();
      mockOrdersRepo.orders = [
        OrderModel(id: 'ORD-1', status: 'pending', total: 100.0, createdAt: now, itemsCount: 1),
        OrderModel(id: 'ORD-2', status: 'delivered', total: 200.0, createdAt: now, itemsCount: 2),
        OrderModel(id: 'ORD-3', status: 'cancelled', total: 150.0, createdAt: now, itemsCount: 1),
      ];

      final container = ProviderContainer(
        overrides: [
          ordersRepositoryProvider.overrideWithValue(mockOrdersRepo),
        ],
      );
      addTearDown(container.dispose);

      final ordersNotifier = container.read(ordersProvider.notifier);
      await ordersNotifier.loadOrders();

      expect(container.read(ordersProvider).orders.length, 3);
      expect(container.read(filteredOrdersProvider).length, 3);

      // Filter: Active
      ordersNotifier.setFilter(OrdersFilter.active);
      expect(container.read(filteredOrdersProvider).length, 1);
      expect(container.read(filteredOrdersProvider).first.id, 'ORD-1');

      // Filter: Delivered
      ordersNotifier.setFilter(OrdersFilter.delivered);
      expect(container.read(filteredOrdersProvider).length, 1);
      expect(container.read(filteredOrdersProvider).first.id, 'ORD-2');

      // Filter: Canceled
      ordersNotifier.setFilter(OrdersFilter.canceled);
      expect(container.read(filteredOrdersProvider).length, 1);
      expect(container.read(filteredOrdersProvider).first.id, 'ORD-3');
    });

    test('5. Customer cancel order updates state in Riverpod', () async {
      final mockOrdersRepo = MockOrdersRepository();
      mockOrdersRepo.orders = [
        OrderModel(id: 'ORD-10', status: 'processing', total: 500.0, createdAt: DateTime.now(), itemsCount: 2),
      ];

      final container = ProviderContainer(
        overrides: [
          ordersRepositoryProvider.overrideWithValue(mockOrdersRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(ordersProvider.notifier).loadOrders();
      expect(container.read(ordersProvider).orders.first.status, 'processing');

      final cancelled = await container.read(ordersProvider.notifier).cancelOrder('ORD-10');
      expect(cancelled, isTrue);
      expect(container.read(ordersProvider).orders.first.status, 'cancelled');
    });

    test('6. Session Boundary Isolation: User A orders and checkout are purged on logout', () async {
      final mockOrdersRepo = MockOrdersRepository();
      final container = ProviderContainer(
        overrides: [
          ordersRepositoryProvider.overrideWithValue(mockOrdersRepo),
        ],
      );
      addTearDown(container.dispose);

      // User A creates order
      container.read(ordersProvider.notifier).syncWithSession(userId: 'user_A', generation: 1);
      container.read(ordersProvider.notifier).addOrder(
        OrderModel(id: 'ORD-USER-A', status: 'processing', total: 400.0, createdAt: DateTime.now(), itemsCount: 1),
      );
      expect(container.read(ordersProvider).orders.length, 1);

      // User A logs out
      container.read(authSessionProvider.notifier).clearSession();

      // Check User A's data was completely purged
      expect(container.read(ordersProvider).orders.isEmpty, isTrue);
      expect(container.read(checkoutFlowProvider).isSuccess, isFalse);
      expect(container.read(checkoutFlowProvider).createdOrder, isNull);

      // User B enters session
      container.read(ordersProvider.notifier).syncWithSession(userId: 'user_B', generation: 2);
      expect(container.read(ordersProvider).orders.isEmpty, isTrue, reason: 'Zero data leakage to User B');
    });

    test('7. Single-Writer GetX Facade: PaymentController and OrdersController delegate to Riverpod', () async {
      final mockOrdersRepo = MockOrdersRepository();
      final container = ProviderContainer(
        overrides: [
          ordersRepositoryProvider.overrideWithValue(mockOrdersRepo),
        ],
      );
      addTearDown(container.dispose);

      final authSession = getx.Get.put(AuthSessionService(container: container));
      final profileStore = getx.Get.put(ProfileStoreService(authSession, container));
      getx.Get.put(CartUiController());
      getx.Get.put(CartController(CartService(profileStore), container: container));
      final payment = getx.Get.put(PaymentController(container: container));
      getx.Get.put(OrdersUiController());
      final orders = getx.Get.put(OrdersController(OrdersService(), repository: mockOrdersRepo, container: container));

      // Delegate payment method selection
      payment.setPaymentMethodId('wallet');
      expect(container.read(checkoutFlowProvider).paymentMethodId, 'wallet');
      expect(payment.isWalletPayment, isTrue);

      // Add order through Riverpod and verify GetX projection
      final testOrder = OrderModel(id: 'ORD-FACADE', status: 'pending', total: 220.0, createdAt: DateTime.now(), itemsCount: 1);
      container.read(ordersProvider.notifier).addOrder(testOrder);
      expect(orders.orders.length, 1);
      expect(orders.orders.first.id, 'ORD-FACADE');

      // Clear orders via controller delegates to Riverpod
      orders.clearOrders();
      expect(container.read(ordersProvider).orders.isEmpty, isTrue);
      expect(orders.orders.isEmpty, isTrue);
    });
  });
}
