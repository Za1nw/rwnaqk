import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rwnaqk_frontend/core/network/api_client.dart';
import 'package:rwnaqk_frontend/core/network/api_endpoints.dart';
import 'package:rwnaqk_frontend/core/network/api_exceptions.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository_impl.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/repositories/products_repository_impl.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/repositories/orders_repository_impl.dart';

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
}
