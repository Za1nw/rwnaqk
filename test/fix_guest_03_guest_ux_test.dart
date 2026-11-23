import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/core/widgets/dialogs/guest_auth_prompt_dialog.dart';
import 'package:rwnaqk_frontend/modules/cart/providers/cart_providers.dart';
import 'package:rwnaqk_frontend/modules/cart/views/cart_view.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/products_listing_service.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_review.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/repositories/products_repository.dart';
import 'package:rwnaqk_frontend/modules/catalog/providers/catalog_providers.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_category_item.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_details_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/repositories/orders_repository.dart';
import 'package:rwnaqk_frontend/modules/orders/providers/orders_providers.dart';
import 'package:rwnaqk_frontend/modules/orders/views/orders_view.dart';
import 'package:rwnaqk_frontend/modules/wishlist/data/repositories/wishlist_repository.dart';
import 'package:rwnaqk_frontend/modules/wishlist/providers/wishlist_providers.dart';
import 'package:rwnaqk_frontend/routes/app_route_args.dart';
import 'package:rwnaqk_frontend/routes/app_router.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StubOrdersRepository implements IOrdersRepository {
  int getOrdersCallCount = 0;
  List<OrderModel> ordersToReturn = [];

  @override
  Future<List<OrderModel>> getOrders() async {
    getOrdersCallCount++;
    return ordersToReturn;
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async => null;

  @override
  Future<OrderDetailsModel> getOrderDetails(OrderModel order) async {
    throw UnimplementedError();
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    throw UnimplementedError();
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
    throw UnimplementedError();
  }

  @override
  Future<OrderModel> cancelOrder(String orderId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> clearLocalCache() async {}
}

class StubTokenStorage implements IAuthTokenStorage {
  String? token;
  StubTokenStorage({this.token});
  @override
  Future<String?> readToken() async => token;
  @override
  Future<void> writeToken(String newToken) async => token = newToken.trim();
  @override
  Future<void> clearToken() async => token = null;
}

class StubWishlistRepository implements IWishlistRepository {
  List<HomeProductItem> items = [];
  @override
  Future<List<HomeProductItem>> getWishlist() async => items;
  @override
  Future<List<String>> getWishlistIds() async => items.map((e) => e.id).toList();
  @override
  Future<bool> toggleWishlist(String productId) async => true;
  @override
  Future<void> addToWishlist(String productId) async {}
  @override
  Future<void> removeFromWishlist(String productId) async {}
  @override
  Future<List<HomeProductItem>> syncWishlist(List<String> productIds) async => items;
}

class StubProductsRepository implements IProductsRepository {
  @override
  Future<HomeProductItem?> getProductById(String id) async => _sampleItem(id: id);

  @override
  Future<List<ProductReview>> getProductReviews(String productId, {dynamic rawReviews}) async => [];

  @override
  Future<List<HomeProductItem>> getProducts({
    int seed = 1,
    int limit = 10,
    ListingSort sort = ListingSort.newest,
    double? minPrice,
    double? maxPrice,
    String? categoryId,
    String? search,
    bool? isFeatured,
    CancelToken? cancelToken,
  }) async => [];

  @override
  Future<List<HomeProductItem>> searchProducts(String query, {CancelToken? cancelToken}) async => [];

  @override
  Future<List<HomeCategoryItem>> getCategories({
    String? parentId,
    bool? isFeatured,
    bool? isTop,
    CancelToken? cancelToken,
  }) async => [];
}

HomeProductItem _sampleItem({String id = 'prod-1', String title = 'Test Perfume'}) {
  return HomeProductItem(
    id: id,
    title: title,
    brand: 'Rwnaqk',
    price: 150.0,
    imageUrl: 'https://example.com/p.jpg',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late StubOrdersRepository stubOrdersRepo;
  late StubTokenStorage stubTokenStorage;
  late StubWishlistRepository stubWishlistRepo;
  late StubProductsRepository stubProductsRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    stubOrdersRepo = StubOrdersRepository();
    stubTokenStorage = StubTokenStorage();
    stubWishlistRepo = StubWishlistRepository();
    stubProductsRepo = StubProductsRepository();

    container = ProviderContainer(
      overrides: [
        sharedPreferencesInstanceProvider.overrideWithValue(prefs),
        authTokenStorageProvider.overrideWithValue(stubTokenStorage),
        ordersRepositoryProvider.overrideWithValue(stubOrdersRepo),
        wishlistRepositoryProvider.overrideWithValue(stubWishlistRepo),
        productsRepositoryProvider.overrideWithValue(stubProductsRepo),
      ],
    );
    globalProviderContainer = container;
  });

  tearDown(() {
    container.dispose();
  });

  Widget buildTestApp({required Widget home, NavigatorObserver? observer}) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        navigatorKey: AppNav.navigatorKey,
        navigatorObservers: observer != null ? [observer] : [],
        home: home,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => Scaffold(body: Text('Route: ${settings.name}')),
          );
        },
      ),
    );
  }

  group('FIX-GUEST-03 — Part 1: Cart Access & Guest UX', () {
    test('Router allows guest to access AppRoutes.cart without redirection', () async {
      await container.read(authSessionProvider.notifier).enterGuestMode();
      final route = AppRouter.checkRouteGuards(AppRoutes.cart);
      expect(route, isNull);
    });

    testWidgets('Guest opens CartScreen and sees Guest Empty State with login CTA', (tester) async {
      await container.read(authSessionProvider.notifier).enterGuestMode();
      expect(container.read(authSessionProvider).isGuest, isTrue);

      await tester.pumpWidget(buildTestApp(home: const CartScreen()));
      await tester.pumpAndSettle();

      // Guest empty state title and message should be rendered
      expect(find.text('تسجيل الدخول مطلوب'), findsOneWidget);
      expect(find.text('يرجى تسجيل الدخول لعرض سلة التسوق الخاصة بك وإتمام عمليات الشراء'), findsOneWidget);

      // Verify CTA button exists
      final loginBtn = find.text('تسجيل الدخول / إنشاء حساب');
      expect(loginBtn, findsOneWidget);
    });

    testWidgets('Guest tapping Login CTA in CartScreen navigates to Login with returnRoute=cart', (tester) async {
      await container.read(authSessionProvider.notifier).enterGuestMode();

      String? pushedRoute;
      Object? pushedArgs;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            navigatorKey: AppNav.navigatorKey,
            onGenerateRoute: (settings) {
              pushedRoute = settings.name;
              pushedArgs = settings.arguments;
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => Scaffold(body: Text('Screen: ${settings.name}')),
              );
            },
            home: const CartScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final loginBtn = find.text('تسجيل الدخول / إنشاء حساب');
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(pushedRoute, AppRoutes.login);
      expect(pushedArgs, isA<Map<String, dynamic>>());
      final args = pushedArgs as Map<String, dynamic>;
      expect(args[AppRouteArgs.returnRoute], AppRoutes.cart);
    });

    test('Guest opening Cart does NOT create items or mutate state', () async {
      await container.read(authSessionProvider.notifier).enterGuestMode();

      final cartState = container.read(cartProvider);
      expect(cartState.isEmpty, isTrue);
      expect(cartState.items, isEmpty);
      expect(cartState.totalQuantity, 0);
    });

    testWidgets('Authenticated user opens CartScreen and sees normal cart content', (tester) async {
      await container.read(authSessionProvider.notifier).startSession(
            accessToken: 'valid_auth_token',
            customerPayload: const CustomerModel(id: 1, email: 'user@rwnaqk.com'),
          );

      // Add item to cart
      final added = container.read(cartProvider.notifier).addToCart(_sampleItem());
      expect(added, isTrue);

      await tester.pumpWidget(buildTestApp(home: const CartScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Normal cart does NOT show guest empty state
      expect(find.text('تسجيل الدخول مطلوب'), findsNothing);
      expect(find.text('Test Perfume'), findsOneWidget);
    });
  });

  group('FIX-GUEST-03 — Part 2: Orders Access & Guest UX', () {
    test('Router allows guest to access AppRoutes.orders without redirection', () async {
      await container.read(authSessionProvider.notifier).enterGuestMode();
      final route = AppRouter.checkRouteGuards(AppRoutes.orders);
      expect(route, isNull);
    });

    testWidgets('Guest opens OrdersScreen and sees Orders Guest Empty State', (tester) async {
      await container.read(authSessionProvider.notifier).enterGuestMode();

      await tester.pumpWidget(buildTestApp(home: const OrdersScreen()));
      await tester.pumpAndSettle();

      expect(find.text('تسجيل الدخول مطلوب'), findsOneWidget);
      expect(find.text('يرجى تسجيل الدخول إلى حسابك لمشاهدة قائمة طلباتك وتتبع حالة الشحنات'), findsOneWidget);
      expect(find.text('تسجيل الدخول / إنشاء حساب'), findsOneWidget);
    });

    testWidgets('OrdersScreen initState does NOT call loadOrders() for Guest', (tester) async {
      await container.read(authSessionProvider.notifier).enterGuestMode();

      await tester.pumpWidget(buildTestApp(home: const OrdersScreen()));
      await tester.pumpAndSettle();

      // Verify no API repository calls were made
      expect(stubOrdersRepo.getOrdersCallCount, 0);
      expect(container.read(ordersProvider).orders, isEmpty);
    });

    testWidgets('Guest tapping Login CTA in OrdersScreen navigates to Login with returnRoute=orders', (tester) async {
      await container.read(authSessionProvider.notifier).enterGuestMode();

      String? pushedRoute;
      Object? pushedArgs;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            navigatorKey: AppNav.navigatorKey,
            onGenerateRoute: (settings) {
              pushedRoute = settings.name;
              pushedArgs = settings.arguments;
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => Scaffold(body: Text('Screen: ${settings.name}')),
              );
            },
            home: const OrdersScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final loginBtn = find.text('تسجيل الدخول / إنشاء حساب');
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(pushedRoute, AppRoutes.login);
      expect(pushedArgs, isA<Map<String, dynamic>>());
      final args = pushedArgs as Map<String, dynamic>;
      expect(args[AppRouteArgs.returnRoute], AppRoutes.orders);
    });

    testWidgets('Authenticated user opening OrdersScreen triggers loadOrders and shows orders', (tester) async {
      await container.read(authSessionProvider.notifier).startSession(
            accessToken: 'valid_auth_token',
            customerPayload: const CustomerModel(id: 1, email: 'user@rwnaqk.com'),
          );

      stubOrdersRepo.ordersToReturn = [
        OrderModel(
          id: 'ORD-999',
          createdAt: DateTime.now(),
          total: 450,
          itemsCount: 1,
          status: 'confirmed',
        ),
      ];

      await tester.pumpWidget(buildTestApp(home: const OrdersScreen()));
      await tester.pumpAndSettle();

      expect(stubOrdersRepo.getOrdersCallCount, 1);
      expect(container.read(ordersProvider).orders.length, 1);
      expect(find.text('ORD-999'), findsOneWidget);
    });
  });

  group('FIX-GUEST-03 — Part 3: Add-to-Cart & buyNow Interception', () {
    test('CartNotifier.addToCart returns false and rejects insertion when session is Guest', () async {
      await container.read(authSessionProvider.notifier).enterGuestMode();

      final result = container.read(cartProvider.notifier).addToCart(_sampleItem());

      expect(result, isFalse);
      expect(container.read(cartProvider).isEmpty, isTrue);
      expect(container.read(cartProvider).items, isEmpty);
    });

    test('CartNotifier.addToCart returns false and rejects insertion when unauthenticated', () {
      expect(container.read(authSessionProvider).isAuthenticated, isFalse);

      final result = container.read(cartProvider.notifier).addToCart(_sampleItem());

      expect(result, isFalse);
      expect(container.read(cartProvider).isEmpty, isTrue);
    });

    test('CartNotifier.addToCart returns true and inserts item when Authenticated', () async {
      await container.read(authSessionProvider.notifier).startSession(
            accessToken: 'token_123',
            customerPayload: const CustomerModel(id: 5, email: 'shopper@rwnaqk.com'),
          );

      final result = container.read(cartProvider.notifier).addToCart(_sampleItem(id: 'auth-item-1'));

      expect(result, isTrue);
      expect(container.read(cartProvider).items.length, 1);
      expect(container.read(cartProvider).items.first.productId, 'auth-item-1');
    });

    testWidgets('Guest tapping Add-to-Cart in ProductDetails shows GuestAuthPromptDialog and does not add item', (tester) async {
      await container.read(authSessionProvider.notifier).enterGuestMode();

      late BuildContext capturedContext;
      await tester.pumpWidget(
        buildTestApp(
          home: Builder(
            builder: (ctx) {
              capturedContext = ctx;
              return const Scaffold(body: Text('Product Screen'));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final catalogNotifier = container.read(productDetailsFamily('prod-1').notifier);
      await catalogNotifier.loadProduct(initialItem: _sampleItem(id: 'prod-1'));

      // Invoke addToCart
      final result = catalogNotifier.addToCart(capturedContext);
      await tester.pumpAndSettle();

      // Dialog is displayed
      expect(result, isFalse);
      expect(find.byType(GuestAuthPromptDialog), findsOneWidget);
      expect(find.text('تسجيل الدخول مطلوب'), findsOneWidget);
      expect(find.text('يرجى تسجيل الدخول إلى حسابك لتتمكن من إضافة المنتجات إلى سلة التسوق ومتابعة الطلب.'), findsOneWidget);

      // Cart remains empty
      expect(container.read(cartProvider).isEmpty, isTrue);
    });

    testWidgets('Guest tapping buyNow in ProductDetails shows GuestAuthPromptDialog and does NOT navigate to payment', (tester) async {
      await container.read(authSessionProvider.notifier).enterGuestMode();

      String? pushedRoute;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            navigatorKey: AppNav.navigatorKey,
            onGenerateRoute: (settings) {
              pushedRoute = settings.name;
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => Scaffold(body: Text('Route: ${settings.name}')),
              );
            },
            home: Builder(
              builder: (ctx) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      final catalogNotifier = container.read(productDetailsFamily('prod-2').notifier);
                      await catalogNotifier.loadProduct(initialItem: _sampleItem(id: 'prod-2'));
                      catalogNotifier.buyNow(ctx);
                    },
                    child: const Text('Buy Now Button'),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Buy Now Button'));
      await tester.pumpAndSettle();

      // Dialog shown, no navigation to payment
      expect(find.byType(GuestAuthPromptDialog), findsOneWidget);
      expect(pushedRoute, isNull);
      expect(container.read(cartProvider).isEmpty, isTrue);
    });

    testWidgets('GuestAuthPromptDialog Cancel button closes dialog without navigation or side effects', (tester) async {
      await container.read(authSessionProvider.notifier).enterGuestMode();

      await tester.pumpWidget(
        buildTestApp(
          home: Builder(
            builder: (ctx) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => GuestAuthPromptDialog.show(ctx),
                  child: const Text('Show Dialog'),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(GuestAuthPromptDialog), findsOneWidget);

      // Tap Cancel button
      final cancelBtn = find.text('إلغاء');
      await tester.tap(cancelBtn);
      await tester.pumpAndSettle();

      // Dialog dismissed
      expect(find.byType(GuestAuthPromptDialog), findsNothing);
      expect(container.read(cartProvider).isEmpty, isTrue);
    });

    testWidgets('GuestAuthPromptDialog Login button navigates to AppRoutes.login with returnRoute', (tester) async {
      await container.read(authSessionProvider.notifier).enterGuestMode();

      String? pushedRoute;
      Object? pushedArgs;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            navigatorKey: AppNav.navigatorKey,
            onGenerateRoute: (settings) {
              pushedRoute = settings.name;
              pushedArgs = settings.arguments;
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => Scaffold(body: Text('Route: ${settings.name}')),
              );
            },
            home: Builder(
              builder: (ctx) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () => GuestAuthPromptDialog.show(
                      ctx,
                      returnRoute: AppRoutes.product,
                      returnArgs: {'id': 'prod-99'},
                    ),
                    child: const Text('Show Dialog'),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      final loginBtn = find.text('تسجيل الدخول');
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(pushedRoute, AppRoutes.login);
      expect(pushedArgs, isA<Map<String, dynamic>>());
      final args = pushedArgs as Map<String, dynamic>;
      expect(args[AppRouteArgs.returnRoute], AppRoutes.product);
      expect(args[AppRouteArgs.returnArgs], {'id': 'prod-99'});
    });

    testWidgets('Wishlist addToCart as Guest shows GuestAuthPromptDialog and does not add item', (tester) async {
      await container.read(authSessionProvider.notifier).enterGuestMode();

      await tester.pumpWidget(
        buildTestApp(
          home: const Scaffold(body: Text('Wishlist Screen')),
        ),
      );
      await tester.pumpAndSettle();

      container.read(wishlistProvider.notifier).addToCart(_sampleItem(id: 'wish-1'));
      await tester.pumpAndSettle();

      expect(find.byType(GuestAuthPromptDialog), findsOneWidget);
      expect(container.read(cartProvider).isEmpty, isTrue);
    });

    testWidgets('Wishlist addAllToCart as Guest shows GuestAuthPromptDialog and does not add items', (tester) async {
      await container.read(authSessionProvider.notifier).enterGuestMode();

      stubWishlistRepo.items = [_sampleItem(id: 'wish-1'), _sampleItem(id: 'wish-2')];

      await tester.pumpWidget(
        buildTestApp(
          home: const Scaffold(body: Text('Wishlist Screen')),
        ),
      );
      await tester.pumpAndSettle();

      container.read(wishlistProvider.notifier).addAllToCart();
      await tester.pumpAndSettle();

      expect(find.byType(GuestAuthPromptDialog), findsOneWidget);
      expect(container.read(cartProvider).isEmpty, isTrue);
    });
  });

  group('FIX-GUEST-03 — Part 4: Session Isolation & Cleansing', () {
    test('Switching from Authenticated to Guest immediately clears Cart and Orders', () async {
      // 1. Authenticated session
      await container.read(authSessionProvider.notifier).startSession(
            accessToken: 'active_token',
            customerPayload: const CustomerModel(id: 10, email: 'active@rwnaqk.com'),
          );

      container.read(cartProvider.notifier).addToCart(_sampleItem(id: 'item-10'));
      container.read(ordersProvider.notifier).addOrder(
            OrderModel(
              id: 'AUTH-ORD-1',
              createdAt: DateTime.now(),
              total: 200,
              itemsCount: 1,
              status: 'confirmed',
            ),
          );

      expect(container.read(cartProvider).items.length, 1);
      expect(container.read(ordersProvider).orders.length, 1);

      // 2. Transition to Guest mode
      await container.read(authSessionProvider.notifier).enterGuestMode();

      // 3. Both Cart and Orders must be purged
      expect(container.read(cartProvider).items, isEmpty);
      expect(container.read(cartProvider).isEmpty, isTrue);
      expect(container.read(ordersProvider).orders, isEmpty);
    });
  });
}

