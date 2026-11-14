import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/network/api_client.dart';
import 'package:rwnaqk_frontend/core/network/api_exceptions.dart';
import 'package:rwnaqk_frontend/modules/cart/providers/cart_providers.dart';
import 'package:rwnaqk_frontend/modules/checkout/providers/checkout_providers.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/contact_info_model.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/shipping_address.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/orders/data/repositories/orders_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    dotenv.loadFromString(
      envString: 'APP_ENV=development\nENABLE_MOCK_DATA=false\nAPI_BASE_URL=http://127.0.0.1:8000/api/v1',
    );
  });

  group('Phase 08.1 — Real Laravel Backend Contract & Flutter Integration Tests', () {
    late Dio testDio;
    late ApiClient testApiClient;
    late CartRepositoryImpl cartRepository;
    late OrdersRepositoryImpl ordersRepository;

    setUp(() {
      testDio = Dio(BaseOptions(
        baseUrl: 'http://127.0.0.1:8000/api/v1',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ));

      testApiClient = ApiClient(dio: testDio);
      cartRepository = CartRepositoryImpl(apiClient: testApiClient);
      ordersRepository = OrdersRepositoryImpl(apiClient: testApiClient);
    });

    // -------------------------------------------------------------------------
    // 1. Cart Quote Endpoint Integration & DTO Deserialization
    // -------------------------------------------------------------------------
    test('1. CartRepositoryImpl parses real Laravel CartQuote JSON accurately', () async {
      testDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.endsWith('/customer/cart/quote')) {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'status': 'success',
                'message': 'تم احتساب عرض سعر السلة بنجاح.',
                'data': {
                  'currency': 'YER',
                  'currency_symbol': 'ر.ي',
                  'is_serviceable': true,
                  'address_id': 211,
                  'items': [
                    {
                      'product_id': 3,
                      'product_variation_id': 3,
                      'name': 'بنطال جينز أسود بقصّة قصة ضيقة وخمسة جيوب',
                      'sku': 'SKU-JEANS-003',
                      'qty': 2,
                      'unit_price': 15000.0,
                      'unit_discount': 0.0,
                      'effective_unit_price': 15000.0,
                      'line_subtotal': 30000.0,
                      'line_product_discount': 0.0,
                      'line_total': 30000.0,
                    }
                  ],
                  'subtotal': 30000.0,
                  'product_discount_total': 0.0,
                  'net_subtotal': 30000.0,
                  'coupon_code': 'RAWNAQ',
                  'coupon_discount_total': 4500.0,
                  'shipping_fee': 1000.0,
                  'grand_total': 26500.0,
                  'shipping_options': [
                    {
                      'id': 'standard',
                      'name': 'التوصيل المباشر - صنعاء',
                      'zone_name': 'أمانة العاصمة',
                      'fee': 1000.0,
                      'formatted_fee': '1,000 ر.ي',
                      'duration_minutes': 35,
                      'duration_text': '35 دقيقة تقريباً',
                    }
                  ],
                  'selected_shipping_option': {
                    'id': 'standard',
                    'name': 'التوصيل المباشر - صنعاء',
                    'zone_name': 'أمانة العاصمة',
                    'fee': 1000.0,
                    'formatted_fee': '1,000 ر.ي',
                    'duration_minutes': 35,
                    'duration_text': '35 دقيقة تقريباً',
                  },
                  'message': 'تم تفعيل كود الخصم (RAWNAQ) بنجاح (خصم 15%).',
                },
              },
            ));
          }
          return handler.next(options);
        },
      ));

      final quote = await cartRepository.requestCartQuote(
        addressId: 211,
        items: [
          {'product_variation_id': 3, 'qty': 2}
        ],
        couponCode: 'RAWNAQ',
      );

      expect(quote, isNotNull);
      expect(quote!.isServiceable, isTrue);
      expect(quote.currency, 'YER');
      expect(quote.currencySymbol, 'ر.ي');
      expect(quote.subtotal, 30000.0);
      expect(quote.couponDiscountTotal, 4500.0);
      expect(quote.shippingFee, 1000.0);
      expect(quote.grandTotal, 26500.0);
      expect(quote.items.length, 1);
      expect(quote.items.first.effectiveUnitPrice, 15000.0);
      expect(quote.shippingOptions.length, 1);
      expect(quote.selectedShippingOption?.fee, 1000.0);
    });

    // -------------------------------------------------------------------------
    // 2. Standalone Coupon Validation Contract
    // -------------------------------------------------------------------------
    test('2. Standalone coupon validation parses Laravel success and error schemas', () async {
      testDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.endsWith('/customer/cart/validate-coupon')) {
            final data = options.data as Map<String, dynamic>;
            if (data['coupon_code'] == 'RWNAQK15') {
              return handler.resolve(Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'status': 'success',
                  'message': 'تم تفعيل كود الخصم (RWNAQK15) بنجاح (خصم 15%).',
                  'data': {
                    'valid': true,
                    'coupon_code': 'RWNAQK15',
                    'discount_percent': 15,
                    'discount_amount': 3000.0,
                    'message': 'تم تفعيل كود الخصم (RWNAQK15) بنجاح (خصم 15%).',
                  },
                },
              ));
            } else {
              return handler.reject(DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 422,
                  data: {
                    'status': 'error',
                    'message': 'كود الكوبون غير صالح أو منتهي الصلاحية.',
                    'errors': {
                      'coupon_code': ['كود الكوبون غير صالح أو منتهي الصلاحية.']
                    },
                  },
                ),
              ));
            }
          }
          return handler.next(options);
        },
      ));

      final validRes = await cartRepository.validateCoupon(
        couponCode: 'RWNAQK15',
        subtotal: 20000.0,
      );
      expect(validRes['status'], 'success');
      expect(validRes['data']['discount_amount'], 3000.0);

      expect(
        () => cartRepository.validateCoupon(couponCode: 'INVALID_CODE'),
        throwsA(isA<ApiException>().having(
          (e) => e.message,
          'error message',
          contains('غير صالح'),
        )),
      );
    });

    // -------------------------------------------------------------------------
    // 3. Order Creation & Idempotency Header Injection
    // -------------------------------------------------------------------------
    test('3. OrdersRepositoryImpl injects X-Idempotency-Key and creates OrderModel', () async {
      String? capturedIdempotencyHeader;
      Map<String, dynamic>? capturedBody;

      testDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.endsWith('/customer/orders') && options.method == 'POST') {
            capturedIdempotencyHeader = options.headers['X-Idempotency-Key']?.toString();
            capturedBody = options.data as Map<String, dynamic>;

            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 201,
              data: {
                'status': 'success',
                'message': 'تم إنشاء طلبك بنجاح.',
                'data': {
                  'id': '100015',
                  'order_id': 15,
                  'order_group_id': 15,
                  'order_code': '100015',
                  'created_at': DateTime.now().toIso8601String(),
                  'total': 31000.0,
                  'subtotal': 30000.0,
                  'shipping_fee': 1000.0,
                  'discount_amount': 0.0,
                  'items_count': 2,
                  'status': 'order_placed',
                  'delivery_status': 'order_placed',
                  'payment_status': 'unpaid',
                  'payment_method': 'cash_on_delivery',
                  'address_line': 'صنعاء، بني مطر، شارع الستين',
                  'delivery_name': 'عميل تجريبي',
                  'delivery_phone': '770000003',
                  'logistic_name': 'شركة توصيل رونقك السريع',
                  'items': [
                    {
                      'id': '45',
                      'product_id': 3,
                      'product_variation_id': 3,
                      'title': 'بنطال جينز أسود',
                      'subtitle': 'SKU-3',
                      'quantity': 2,
                      'unit_price': 15000.0,
                      'total_price': 30000.0,
                    }
                  ],
                },
              },
            ));
          }
          return handler.next(options);
        },
      ));

      final createdOrder = await ordersRepository.submitCheckout(
        addressId: 211,
        items: [
          {'product_variation_id': 3, 'qty': 2}
        ],
        paymentMethod: 'cash_on_delivery',
        expectedGrandTotal: 31000.0,
        notes: 'ملاحظة خاصة بالطلب التجريبي',
        idempotencyKey: 'idemp-test-uuid-42',
      );

      expect(capturedIdempotencyHeader, 'idemp-test-uuid-42');
      expect(capturedBody?['address_id'], 211);
      expect(capturedBody?['payment_method'], 'cash_on_delivery');
      expect(capturedBody?['expected_grand_total'], 31000.0);

      expect(createdOrder.id, '100015');
      expect(createdOrder.total, 31000.0);
      expect(createdOrder.status, 'order_placed');
      expect(createdOrder.itemsCount, 2);
      expect(createdOrder.addressLine, contains('بني مطر'));
    });

    // -------------------------------------------------------------------------
    // 4. Server Price Mismatch Guard (HTTP 409 Conflict)
    // -------------------------------------------------------------------------
    test('4. Price mismatch is rejected with 409 Conflict and handled gracefully', () async {
      testDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.endsWith('/customer/orders') && options.method == 'POST') {
            return handler.reject(DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: 409,
                data: {
                  'message': 'حدث تغيير في الأسعار أو رسوم التوصيل، يرجى مراجعة الإجمالي وإعادة التأكيد.',
                },
              ),
            ));
          }
          return handler.next(options);
        },
      ));

      expect(
        () => ordersRepository.submitCheckout(
          addressId: 211,
          items: [
            {'product_variation_id': 3, 'qty': 2}
          ],
          paymentMethod: 'cash_on_delivery',
          expectedGrandTotal: 20000.0, // Stale client total
        ),
        throwsA(isA<ApiException>().having(
          (e) => e.statusCode,
          'status code',
          409,
        )),
      );
    });

    // -------------------------------------------------------------------------
    // 5. Malicious Receipt Injection Rejection (HTTP 422 Unprocessable Content)
    // -------------------------------------------------------------------------
    test('5. Malicious external receipt URL is rejected with 422 Unprocessable Content', () async {
      testDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.endsWith('/customer/orders') && options.method == 'POST') {
            return handler.reject(DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: 422,
                data: {
                  'message': 'رابط سند التحويل غير صالح، يجب رفع السند عبر التطبيق حصراً.',
                  'errors': {
                    'receipt_image_url': ['رابط سند التحويل غير صالح، يجب رفع السند عبر التطبيق حصراً.']
                  },
                },
              ),
            ));
          }
          return handler.next(options);
        },
      ));

      expect(
        () => ordersRepository.submitCheckout(
          addressId: 211,
          items: [
            {'product_variation_id': 3, 'qty': 1}
          ],
          paymentMethod: 'wallet',
          receiptImageUrl: 'https://attacker-domain.com/fake-receipt.png',
        ),
        throwsA(isA<ValidationException>().having(
          (e) => e.errors['receipt_image_url']?.first,
          'validation error message',
          contains('سند التحويل غير صالح'),
        )),
      );
    });

    // -------------------------------------------------------------------------
    // 6. Orders Listing & Pagination Deserialization
    // -------------------------------------------------------------------------
    test('6. getOrders correctly deserializes paginated Laravel orders list', () async {
      testDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.endsWith('/customer/orders') && options.method == 'GET') {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'status': 'success',
                'data': [
                  {
                    'id': '100015',
                    'order_id': 15,
                    'order_group_id': 15,
                    'order_code': '100015',
                    'created_at': '2026-11-09T20:45:00.000000Z',
                    'total': 31000.0,
                    'items_count': 2,
                    'status': 'order_placed',
                    'delivery_status': 'order_placed',
                    'payment_status': 'unpaid',
                    'payment_method': 'cash_on_delivery',
                    'address_line': 'صنعاء، بني مطر، شارع الستين',
                    'delivery_name': 'عميل تجريبي',
                    'delivery_phone': '770000003',
                  },
                  {
                    'id': '100016',
                    'order_id': 16,
                    'order_group_id': 16,
                    'order_code': '100016',
                    'created_at': '2026-11-09T20:45:30.000000Z',
                    'total': 16000.0,
                    'items_count': 1,
                    'status': 'order_placed',
                    'delivery_status': 'order_placed',
                    'payment_status': 'unpaid',
                    'payment_method': 'wallet',
                    'address_line': 'صنعاء، بني مطر، شارع الستين',
                    'delivery_name': 'عميل تجريبي',
                    'delivery_phone': '770000003',
                  }
                ],
                'meta': {
                  'current_page': 1,
                  'last_page': 1,
                  'per_page': 15,
                  'total': 2,
                },
              },
            ));
          }
          return handler.next(options);
        },
      ));

      final orders = await ordersRepository.getOrders();
      expect(orders.length, 2);
      expect(orders[0].id, '100015');
      expect(orders[0].total, 31000.0);
      expect(orders[1].id, '100016');
      expect(orders[1].total, 16000.0);
    });

    // -------------------------------------------------------------------------
    // 7. Order Cancellation & Stock Restoration Contract
    // -------------------------------------------------------------------------
    test('7. cancelOrder deserializes cancelled order and rejects double cancellation', () async {
      bool isCancelled = false;

      testDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.endsWith('/customer/orders/100015/cancel') && options.method == 'POST') {
            if (!isCancelled) {
              isCancelled = true;
              return handler.resolve(Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'status': 'success',
                  'message': 'تم إلغاء الطلب بنجاح واستعادة المخزون.',
                  'data': {
                    'id': '100015',
                    'order_id': 15,
                    'order_code': '100015',
                    'status': 'cancelled',
                    'delivery_status': 'cancelled',
                    'total': 31000.0,
                    'items_count': 2,
                    'created_at': DateTime.now().toIso8601String(),
                  },
                },
              ));
            } else {
              return handler.reject(DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 409,
                  data: {
                    'message': 'تم إلغاء هذا الطلب مسبقاً.',
                  },
                ),
              ));
            }
          }
          return handler.next(options);
        },
      ));

      final cancelledOrder = await ordersRepository.cancelOrder('100015');
      expect(cancelledOrder.status, 'cancelled');
      expect(cancelledOrder.id, '100015');

      // Attempt double cancellation
      expect(
        () => ordersRepository.cancelOrder('100015'),
        throwsA(isA<ApiException>().having(
          (e) => e.statusCode,
          'status code',
          409,
        )),
      );
    });

    // -------------------------------------------------------------------------
    // 8. Riverpod Full Purchase Lifecycle Integration
    // -------------------------------------------------------------------------
    test('8. Full Riverpod State Flow: Cart -> Server Quote -> Checkout -> Order', () async {
      final container = ProviderContainer(
        overrides: [
          cartRepositoryProvider.overrideWithValue(cartRepository),
          ordersRepositoryProvider.overrideWithValue(ordersRepository),
        ],
      );
      addTearDown(container.dispose);

      // A. Populate Cart
      final cartNotifier = container.read(cartProvider.notifier);
      const product = HomeProductItem(
        id: '3',
        title: 'بنطال جينز أسود',
        price: 15000.0,
        imageUrl: 'https://example.com/jeans.png',
      );
      cartNotifier.addToCart(product, quantity: 2);

      expect(container.read(cartProvider).totalQuantity, 2);
      expect(container.read(cartProvider).subtotal, 30000.0);

      // B. Mock Quote & Order Responses
      testDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.endsWith('/customer/cart/quote')) {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'status': 'success',
                'data': {
                  'currency': 'YER',
                  'currency_symbol': 'ر.ي',
                  'is_serviceable': true,
                  'address_id': 211,
                  'items': [
                    {
                      'product_id': 3,
                      'product_variation_id': 3,
                      'name': 'بنطال جينز أسود',
                      'sku': 'SKU-3',
                      'qty': 2,
                      'unit_price': 15000.0,
                      'unit_discount': 0.0,
                      'effective_unit_price': 15000.0,
                      'line_subtotal': 30000.0,
                      'line_product_discount': 0.0,
                      'line_total': 30000.0,
                    }
                  ],
                  'subtotal': 30000.0,
                  'product_discount_total': 0.0,
                  'net_subtotal': 30000.0,
                  'coupon_code': null,
                  'coupon_discount_total': 0.0,
                  'shipping_fee': 1000.0,
                  'grand_total': 31000.0,
                  'shipping_options': [
                    {
                      'id': 'standard',
                      'name': 'التوصيل المباشر',
                      'zone_name': 'صنعاء',
                      'fee': 1000.0,
                      'formatted_fee': '1,000 ر.ي',
                      'duration_minutes': 35,
                      'duration_text': '35 دقيقة',
                    }
                  ],
                },
              },
            ));
          } else if (options.path.endsWith('/customer/orders') && options.method == 'POST') {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 201,
              data: {
                'status': 'success',
                'data': {
                  'id': '100042',
                  'order_id': 42,
                  'order_code': '100042',
                  'status': 'order_placed',
                  'total': 31000.0,
                  'items_count': 2,
                  'created_at': DateTime.now().toIso8601String(),
                },
              },
            ));
          }
          return handler.next(options);
        },
      ));

      // C. Request Quote via Riverpod
      final quoteNotifier = container.read(cartQuoteProvider.notifier);
      await quoteNotifier.refreshQuote(addressId: 211);

      final quoteState = container.read(cartQuoteProvider);
      expect(quoteState.isValid, isTrue);
      expect(quoteState.quote?.grandTotal, 31000.0);
      expect(quoteState.isServiceable, isTrue);

      // D. Execute Checkout via Riverpod checkoutFlowProvider
      final checkoutNotifier = container.read(checkoutFlowProvider.notifier);
      const testAddress = ShippingAddress(
        id: '211',
        country: 'اليمن',
        city: 'صنعاء',
        address: 'شارع الستين',
        postcode: '0000',
        isServiceable: true,
      );
      const testContact = ContactInfoModel(
        phone: '770000003',
        email: 'customer@example.com',
      );

      final orderResult = await checkoutNotifier.submitCheckout(
        cart: container.read(cartProvider),
        quote: quoteState,
        address: testAddress,
        contact: testContact,
      );

      expect(orderResult, isNotNull);
      expect(orderResult!.id, '100042');
      expect(orderResult.total, 31000.0);
      expect(container.read(checkoutFlowProvider).isSubmitting, isFalse);
    });
  });
}
