import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rwnaqk_frontend/core/network/api_client.dart';
import 'package:rwnaqk_frontend/core/network/api_endpoints.dart';
import 'package:rwnaqk_frontend/core/network/api_exceptions.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/login_service.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository_impl.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/repositories/products_repository_impl.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/shipping_address.dart';
import 'package:rwnaqk_frontend/modules/customer/data/repositories/addresses_repository_impl.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/repositories/orders_repository_impl.dart';
import 'package:rwnaqk_frontend/modules/cart/data/models/cart_quote_model.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_service.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';

class MockTokenStorage implements IAuthTokenStorage {
  String? currentToken;

  @override
  Future<String?> readToken() async => currentToken;

  @override
  Future<void> writeToken(String token) async => currentToken = token;

  @override
  Future<void> clearToken() async => currentToken = null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockTokenStorage tokenStorage;
  late Dio testDio;
  late ApiClient apiClient;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dotenv.loadFromString(
      envString: 'APP_ENV=development\nENABLE_MOCK_DATA=true\nAPI_BASE_URL=https://api.test.com',
    );
    tokenStorage = MockTokenStorage();
    testDio = Dio(BaseOptions(baseUrl: 'https://api.test.com'));
    apiClient = ApiClient(dio: testDio, tokenStorage: tokenStorage);
  });

  group('ApiClient Core & Exception Mapping', () {
    test('TokenInterceptor attaches Bearer token when token is stored', () async {
      tokenStorage.currentToken = 'secret_jwt_token_123';

      testDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            // Verify that the interceptor injected the header
            expect(options.headers['Authorization'], 'Bearer secret_jwt_token_123');
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'status': 'ok'},
              ),
            );
          },
        ),
      );

      final response = await apiClient.get<dynamic>('/test-endpoint');
      expect(response.statusCode, 200);
    });

    test('Maps Laravel 422 validation response to ValidationException with field errors', () async {
      testDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 422,
                  data: {
                    'message': 'The given data was invalid.',
                    'errors': {
                      'email': ['البريد الإلكتروني مستخدم بالفعل.'],
                      'password': ['كلمة المرور غير متطابقة.'],
                    },
                  },
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      expect(
        () => apiClient.post<dynamic>('/register', data: {}),
        throwsA(
          isA<ValidationException>()
              .having((e) => e.statusCode, 'statusCode', 422)
              .having((e) => e.hasErrorFor('email'), 'hasErrorFor email', isTrue)
              .having(
                (e) => e.firstErrorFor('email'),
                'firstErrorFor email',
                'البريد الإلكتروني مستخدم بالفعل.',
              ),
        ),
      );
    });

    test('Maps 401 Unauthorized response to UnauthorizedException and triggers callback', () async {
      bool unauthorizedTriggered = false;
      final customDio = Dio(BaseOptions(baseUrl: 'https://api.test.com'));
      final clientWithCallback = ApiClient(
        dio: customDio,
        tokenStorage: tokenStorage,
        onUnauthorized: () {
          unauthorizedTriggered = true;
        },
      );

      customDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 401,
                  data: {'message': 'Unauthenticated.'},
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      await expectLater(
        () => clientWithCallback.get<dynamic>('/me'),
        throwsA(isA<UnauthorizedException>()),
      );
      expect(unauthorizedTriggered, isTrue);
    });
  });

  group('AuthRepositoryImpl Integration Tests', () {
    test('login stores token and returns LoginResult on 200', () async {
      testDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.login) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'token': 'sanctum_token_abc',
                    'customer': {
                      'id': 1,
                      'first_name': 'سارة',
                      'last_name': 'أحمد',
                      'email': 'sara@test.com',
                    },
                    'requires_email_verification': false,
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final authRepo = AuthRepositoryImpl(
        apiClient: apiClient,
        tokenStorage: tokenStorage,
      );

      final result = await authRepo.login(
        email: 'sara@test.com',
        password: 'password123',
      );

      expect(result.isSuccess, isTrue);
      expect(result.requiresEmailVerification, isFalse);
      expect(tokenStorage.currentToken, 'sanctum_token_abc');
    });

    test('logout clears secure token storage', () async {
      tokenStorage.currentToken = 'token_to_clear';

      testDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'message': 'Logged out successfully'},
              ),
            );
          },
        ),
      );

      final authRepo = AuthRepositoryImpl(
        apiClient: apiClient,
        tokenStorage: tokenStorage,
      );

      await authRepo.logout();
      expect(tokenStorage.currentToken, isNull);
    });

    test('LoginService delegates to IAuthRepository and starts session', () async {
      testDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.login) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'token': 'sanctum_token_login_service',
                    'customer': {
                      'id': 10,
                      'first_name': 'مريم',
                      'last_name': 'سالم',
                      'email': 'maryam@test.com',
                    },
                    'requires_email_verification': false,
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final authRepo = AuthRepositoryImpl(
        apiClient: apiClient,
        tokenStorage: tokenStorage,
      );
      final session = AuthSessionService(tokenStorage: tokenStorage);
      final loginService = LoginService(authRepo, session);

      final result = await loginService.login(
        email: 'maryam@test.com',
        password: 'password123',
      );

      expect(result.isSuccess, isTrue);
      expect(session.isAuthenticated, isTrue);
      expect(session.token.value, 'sanctum_token_login_service');
      expect(session.customer.value?.firstName, 'مريم');
    });
  });

  group('OrdersRepositoryImpl & Idempotency Header', () {
    test('createOrder injects X-Idempotency-Key and handles API payload', () async {
      // Set to false to test real network dispatch
      dotenv.loadFromString(
        envString: 'APP_ENV=staging\nENABLE_MOCK_DATA=false\nAPI_BASE_URL=https://api.test.com',
      );

      String? capturedIdempotencyKey;

      testDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.orders) {
              capturedIdempotencyKey =
                  options.headers['X-Idempotency-Key']?.toString();
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 201,
                  data: {
                    'data': {
                      'id': 'ORD-LARAVEL-99',
                      'created_at': DateTime.now().toIso8601String(),
                      'total_amount': 45000.0,
                      'items_count': 2,
                      'delivery_status': 'pending',
                    },
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final ordersRepo = OrdersRepositoryImpl(apiClient: apiClient);

      final newOrder = OrderModel(
        id: 'TEMP-1',
        createdAt: DateTime.now(),
        total: 45000.0,
        itemsCount: 2,
        status: 'pending',
      );

      final created = await ordersRepo.createOrder(newOrder);

      expect(created.id, 'ORD-LARAVEL-99');
      expect(created.total, 45000.0);
      expect(capturedIdempotencyKey, isNotNull);
      expect(capturedIdempotencyKey!.length, greaterThan(10)); // UUID v4 length
    });

    test('submitCheckout sends structured payload and X-Idempotency-Key header', () async {
      dotenv.loadFromString(
        envString: 'APP_ENV=staging\nENABLE_MOCK_DATA=false\nAPI_BASE_URL=https://api.test.com',
      );

      String? capturedKey;
      Map<String, dynamic>? capturedBody;

      testDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.orders) {
              capturedKey = options.headers['X-Idempotency-Key']?.toString();
              capturedBody = options.data is Map<String, dynamic>
                  ? options.data as Map<String, dynamic>
                  : null;
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 201,
                  data: {
                    'status': 'success',
                    'data': {
                      'id': '100042',
                      'order_code': '100042',
                      'created_at': DateTime.now().toIso8601String(),
                      'total': 28550.0,
                      'items_count': 1,
                      'delivery_status': 'order_placed',
                      'payment_method': 'wallet',
                      'payment_status': 'unpaid',
                      'delivery_name': 'عميل تجريبي',
                      'delivery_phone': '777000111',
                    },
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final ordersRepo = OrdersRepositoryImpl(apiClient: apiClient);

      final result = await ordersRepo.submitCheckout(
        addressId: 10,
        items: [
          {'product_variation_id': 5, 'qty': 1},
        ],
        paymentMethod: 'wallet',
        couponCode: 'SALE10',
        shippingOptionId: 'zone-1',
        expectedGrandTotal: 28550.0,
        walletAccount: {
          'company': 'كريمي جوال',
          'number': '123456',
        },
        receiptImageUrl: 'https://rwnaqk.com/receipt.jpg',
        notes: 'يرجى التوصيل بعد العصر',
        idempotencyKey: 'custom-uuid-key-12345',
      );

      expect(result.id, '100042');
      expect(result.total, 28550.0);
      expect(result.status, 'order_placed');
      expect(capturedKey, 'custom-uuid-key-12345');
      expect(capturedBody?['address_id'], 10);
      expect(capturedBody?['payment_method'], 'wallet');
      expect(capturedBody?['coupon_code'], 'SALE10');
      expect(capturedBody?['receipt_image_url'], 'https://rwnaqk.com/receipt.jpg');
    });

    test('cancelOrder posts to cancel endpoint and parses updated cancelled order', () async {
      dotenv.loadFromString(
        envString: 'APP_ENV=staging\nENABLE_MOCK_DATA=false\nAPI_BASE_URL=https://api.test.com',
      );

      testDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.cancelOrder('100042')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'status': 'success',
                    'message': 'تم إلغاء الطلب بنجاح واستعادة المخزون.',
                    'data': {
                      'id': '100042',
                      'order_code': '100042',
                      'created_at': DateTime.now().toIso8601String(),
                      'total': 28550.0,
                      'items_count': 1,
                      'delivery_status': 'cancelled',
                    },
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final ordersRepo = OrdersRepositoryImpl(apiClient: apiClient);
      final cancelled = await ordersRepo.cancelOrder('100042');

      expect(cancelled.id, '100042');
      expect(cancelled.status, 'cancelled');
    });
  });

  group('ProductsRepositoryImpl Integration & Fallback', () {
    test('Returns mock catalog data when ENABLE_MOCK_DATA=true', () async {
      dotenv.loadFromString(
        envString: 'APP_ENV=development\nENABLE_MOCK_DATA=true\nAPI_BASE_URL=https://api.test.com',
      );

      final productsRepo = ProductsRepositoryImpl(apiClient: apiClient);
      final products = await productsRepo.getProducts(limit: 5);

      expect(products, isNotEmpty);
      expect(products.first.title, isNotEmpty);
    });

    test('Fetches from Laravel API and parses HomeProductItem when ENABLE_MOCK_DATA=false', () async {
      dotenv.loadFromString(
        envString: 'APP_ENV=staging\nENABLE_MOCK_DATA=false\nAPI_BASE_URL=https://api.test.com',
      );

      testDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.products) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'data': [
                      {
                        'id': 'PROD-API-10',
                        'name': 'فستان سهرة كلاسيكي مطرز',
                        'min_price': 35000,
                        'feature_image': 'https://rwnaqk.com/img1.jpg',
                        'stock_qty': 8,
                      },
                    ],
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final productsRepo = ProductsRepositoryImpl(apiClient: apiClient);
      final products = await productsRepo.getProducts(limit: 1);

      expect(products.length, 1);
      expect(products.first.id, 'PROD-API-10');
      expect(products.first.title, 'فستان سهرة كلاسيكي مطرز');
      expect(products.first.price, 35000.0);
    });
  });

  group('AddressesRepositoryImpl & Geographic Coverage', () {
    test('Returns mock addresses when ENABLE_MOCK_DATA=true', () async {
      dotenv.loadFromString(
        envString: 'APP_ENV=development\nENABLE_MOCK_DATA=true\nAPI_BASE_URL=https://api.test.com',
      );

      final repo = AddressesRepositoryImpl(apiClient: apiClient);
      final addresses = await repo.getAddresses();

      expect(addresses.isNotEmpty, true);
      expect(addresses.first.id, '1');
      expect(addresses.first.isDefault, true);
      expect(addresses.first.isServiceable, true);
    });

    test('Fetches from Laravel API and parses ShippingAddress when ENABLE_MOCK_DATA=false', () async {
      dotenv.loadFromString(
        envString: 'APP_ENV=development\nENABLE_MOCK_DATA=false\nAPI_BASE_URL=https://api.test.com',
      );

      testDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.customerAddresses) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'data': [
                      {
                        'id': '101',
                        'label': 'المنزل',
                        'description': 'صنعاء - حدة - شارع الستين',
                        'address': 'صنعاء - حدة - شارع الستين',
                        'contact_phone': '777112233',
                        'city': 'أمانة العاصمة',
                        'country': 'اليمن',
                        'postcode': 'الوحدة',
                        'is_primary': true,
                        'is_serviceable': true,
                        'coverage_status': 'in_district',
                        'latitude': 15.345,
                        'longitude': 44.185,
                      },
                    ],
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final repo = AddressesRepositoryImpl(apiClient: apiClient);
      final list = await repo.getAddresses();

      expect(list.length, 1);
      expect(list.first.id, '101');
      expect(list.first.address, 'صنعاء - حدة - شارع الستين');
      expect(list.first.city, 'أمانة العاصمة');
      expect(list.first.isDefault, true);
      expect(list.first.isServiceable, true);
      expect(list.first.coverageStatus, 'in_district');
    });

    test('Creates address and parses response with coverage status', () async {
      dotenv.loadFromString(
        envString: 'APP_ENV=development\nENABLE_MOCK_DATA=false\nAPI_BASE_URL=https://api.test.com',
      );

      testDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.customerAddresses && options.method == 'POST') {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 201,
                  data: {
                    'message': 'تمت إضافة العنوان بنجاح.',
                    'data': {
                      'id': '202',
                      'description': 'عدن - كريتر',
                      'address': 'عدن - كريتر',
                      'city': 'عدن',
                      'postcode': 'كريتر',
                      'country': 'اليمن',
                      'is_primary': false,
                      'is_serviceable': true,
                      'coverage_status': 'in_district',
                    },
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final repo = AddressesRepositoryImpl(apiClient: apiClient);
      const newAddr = ShippingAddress(
        id: '',
        country: 'اليمن',
        address: 'عدن - كريتر',
        city: 'عدن',
        postcode: 'كريتر',
      );

      final created = await repo.createAddress(newAddr);
      expect(created.id, '202');
      expect(created.city, 'عدن');
      expect(created.isServiceable, true);
      expect(created.coverageStatus, 'in_district');
    });

    test('Sets primary address and sends PATCH request to ApiEndpoints.customerAddressPrimary', () async {
      dotenv.loadFromString(
        envString: 'APP_ENV=development\nENABLE_MOCK_DATA=false\nAPI_BASE_URL=https://api.test.com',
      );

      testDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.customerAddressPrimary('202') && options.method == 'PATCH') {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'data': {
                      'id': '202',
                      'address': 'عدن - كريتر',
                      'city': 'عدن',
                      'postcode': 'كريتر',
                      'country': 'اليمن',
                      'is_primary': true,
                      'is_serviceable': true,
                    },
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final repo = AddressesRepositoryImpl(apiClient: apiClient);
      final updated = await repo.setPrimaryAddress('202');
      expect(updated.id, '202');
      expect(updated.isDefault, true);
    });
  });

  group('CartQuoteModel & Dynamic Pricing API Integration', () {
    test('CartQuoteModel.fromJson parses Laravel JSON quote response correctly', () {
      final sampleJson = {
        'currency': 'YER',
        'currency_symbol': 'ر.ي',
        'is_serviceable': true,
        'address_id': 10,
        'items': [
          {
            'product_id': 1,
            'product_variation_id': 5,
            'name': 'فستان سهرة أنيق',
            'sku': 'EVE-RED-S',
            'qty': 2,
            'unit_price': 10000.0,
            'unit_discount': 2000.0,
            'effective_unit_price': 8000.0,
            'line_subtotal': 20000.0,
            'line_product_discount': 4000.0,
            'line_total': 16000.0,
          }
        ],
        'subtotal': 26000.0,
        'product_discount_total': 4000.0,
        'net_subtotal': 22000.0,
        'coupon_code': 'RAWNAQ',
        'coupon_discount_total': 1800.0,
        'shipping_fee': 1500.0,
        'grand_total': 21700.0,
        'shipping_options': [
          {
            'id': '1',
            'name': 'التوصيل المباشر',
            'zone_name': 'نطاق الأمانة الداخلي',
            'fee': 1500.0,
            'formatted_fee': '1,500 ر.ي',
            'duration_minutes': 35,
            'duration_text': '35 دقيقة تقريباً',
          }
        ],
        'message': null,
      };

      final quote = CartQuoteModel.fromJson(sampleJson);
      expect(quote.currency, 'YER');
      expect(quote.currencySymbol, 'ر.ي');
      expect(quote.isServiceable, isTrue);
      expect(quote.addressId, 10);
      expect(quote.subtotal, 26000.0);
      expect(quote.productDiscountTotal, 4000.0);
      expect(quote.netSubtotal, 22000.0);
      expect(quote.couponCode, 'RAWNAQ');
      expect(quote.couponDiscountTotal, 1800.0);
      expect(quote.shippingFee, 1500.0);
      expect(quote.grandTotal, 21700.0);
      expect(quote.items.length, 1);
      expect(quote.items.first.effectiveUnitPrice, 8000.0);
      expect(quote.items.first.lineTotal, 16000.0);
      expect(quote.shippingOptions.length, 1);
      expect(quote.shippingOptions.first.formattedFee, '1,500 ر.ي');
    });

    test('CartService.requestCartQuote calls ApiEndpoints.cartQuote and returns CartQuoteModel', () async {
      testDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.cartQuote && options.method == 'POST') {
              final body = options.data as Map<String, dynamic>;
              expect(body['address_id'], 10);
              expect(body['coupon_code'], 'RAWNAQ');

              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'status': 'success',
                    'message': 'تم احتساب عرض سعر السلة بنجاح.',
                    'data': {
                      'currency': 'YER',
                      'currency_symbol': 'ر.ي',
                      'is_serviceable': true,
                      'address_id': 10,
                      'items': [],
                      'subtotal': 12000.0,
                      'product_discount_total': 0.0,
                      'net_subtotal': 12000.0,
                      'coupon_code': 'RAWNAQ',
                      'coupon_discount_total': 1800.0,
                      'shipping_fee': 1500.0,
                      'grand_total': 11700.0,
                      'shipping_options': [],
                    },
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final service = CartService(
        ProfileStoreService(AuthSessionService()),
        apiClient: apiClient,
      );

      final quote = await service.requestCartQuote(
        addressId: 10,
        items: [
          {'product_variation_id': 5, 'qty': 2},
        ],
        couponCode: 'RAWNAQ',
      );

      expect(quote, isNotNull);
      expect(quote!.isServiceable, isTrue);
      expect(quote.couponCode, 'RAWNAQ');
      expect(quote.couponDiscountTotal, 1800.0);
      expect(quote.grandTotal, 11700.0);
    });

    test('CartService.validateCouponOnline calls ApiEndpoints.validateCoupon with subtotal', () async {
      testDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.validateCoupon && options.method == 'POST') {
              final body = options.data as Map<String, dynamic>;
              expect(body['coupon_code'], 'RAWNAQ');
              expect(body['subtotal'], 10000.0);

              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'status': 'success',
                    'message': 'تم تفعيل كود الخصم (RAWNAQ) بنجاح (خصم 15%).',
                    'data': {
                      'valid': true,
                      'coupon_code': 'RAWNAQ',
                      'discount_percent': 15,
                      'discount_amount': 1500.0,
                    },
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final service = CartService(
        ProfileStoreService(AuthSessionService()),
        apiClient: apiClient,
      );

      final result = await service.validateCouponOnline(
        couponCode: 'RAWNAQ',
        subtotal: 10000.0,
      );

      expect(result['status'], 'success');
      expect(result['data']['valid'], isTrue);
      expect(result['data']['discount_percent'], 15);
      expect(result['data']['discount_amount'], 1500.0);
    });
  });
}
