import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/widgets/app_bottom_nav.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/home/providers/home_providers.dart';
import 'package:rwnaqk_frontend/modules/home/views/main_view.dart';
import 'package:rwnaqk_frontend/modules/orders/providers/orders_providers.dart';
import 'package:rwnaqk_frontend/modules/wishlist/data/repositories/wishlist_repository.dart';
import 'package:rwnaqk_frontend/modules/wishlist/providers/wishlist_providers.dart';
import 'package:rwnaqk_frontend/routes/app_route_args.dart';
import 'package:rwnaqk_frontend/routes/app_router.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestHomeContentNotifier extends HomeContentNotifier {
  @override
  HomeContentState build() {
    return const HomeContentState(
      banners: [],
      categories: [],
      flashSale: [],
      newItems: [],
      isLoading: false,
      hasLoaded: true,
    );
  }
}

class FakeWishlistRepository implements IWishlistRepository {
  @override
  Future<List<HomeProductItem>> getWishlist() async => [];
  @override
  Future<List<String>> getWishlistIds() async => [];
  @override
  Future<bool> toggleWishlist(String productId) async => true;
  @override
  Future<void> addToWishlist(String productId) async {}
  @override
  Future<void> removeFromWishlist(String productId) async {}
  @override
  Future<List<HomeProductItem>> syncWishlist(List<String> productIds) async => [];
}

class FakeOrdersNotifier extends OrdersNotifier {
  @override
  OrdersState build() => const OrdersState();
  @override
  Future<void> loadOrders({bool refresh = false}) async {}
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late StubTokenStorage tokenStorage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    tokenStorage = StubTokenStorage();

    container = ProviderContainer(
      overrides: [
        sharedPreferencesInstanceProvider.overrideWithValue(prefs),
        authTokenStorageProvider.overrideWithValue(tokenStorage),
        homeContentProvider.overrideWith(TestHomeContentNotifier.new),
        wishlistRepositoryProvider.overrideWithValue(FakeWishlistRepository()),
        ordersProvider.overrideWith(FakeOrdersNotifier.new),
      ],
    );
    globalProviderContainer = container;
  });

  tearDown(() {
    container.dispose();
  });

  group('FIX-GUEST-02: Flutter Route Guards & Access Control', () {
    test('Public routes allow access for unauthenticated guest without redirect', () {
      final publicRoutes = [
        AppRoutes.onboarding,
        AppRoutes.main,
        AppRoutes.home,
        AppRoutes.search,
        AppRoutes.searchResults,
        AppRoutes.flashSale,
        AppRoutes.product,
        AppRoutes.reviews,
        AppRoutes.listing,
        AppRoutes.helpCenter,
        AppRoutes.supportChat,
        AppRoutes.wishlist,
        AppRoutes.settings,
        AppRoutes.cart,
        AppRoutes.orders,
      ];

      for (final route in publicRoutes) {
        final redirect = AppRouter.checkRouteGuards(route);
        expect(
          redirect,
          isNull,
          reason: 'Expected public route $route to be accessible without redirect',
        );
      }
    });

    test('Protected routes strictly reject unauthenticated user and redirect to login', () {
      final protectedRoutes = [
        AppRoutes.payment,
        AppRoutes.orderConfirmation,
        AppRoutes.orderSuccess,
        AppRoutes.orderDetails,
        AppRoutes.orderTracking,
        AppRoutes.addresses,
        AppRoutes.profile,
        AppRoutes.editProfile,
        AppRoutes.passwordAndSecurity,
        AppRoutes.twoFactorAndPasskeys,
      ];

      for (final route in protectedRoutes) {
        final redirect = AppRouter.checkRouteGuards(route);
        expect(
          redirect,
          AppRoutes.login,
          reason: 'Expected unauthenticated user to be redirected to login for $route',
        );
      }
    });

    test('Protected routes strictly reject guest user and redirect to login', () async {
      await container.read(authSessionProvider.notifier).enterGuestMode();

      final session = container.read(authSessionProvider);
      expect(session.isGuest, isTrue);
      expect(session.isAuthenticated, isFalse);

      final protectedRoutes = [
        AppRoutes.payment,
        AppRoutes.orderConfirmation,
        AppRoutes.orderSuccess,
        AppRoutes.orderDetails,
        AppRoutes.orderTracking,
        AppRoutes.addresses,
        AppRoutes.profile,
        AppRoutes.editProfile,
        AppRoutes.passwordAndSecurity,
        AppRoutes.twoFactorAndPasskeys,
      ];

      for (final route in protectedRoutes) {
        final redirect = AppRouter.checkRouteGuards(route);
        expect(
          redirect,
          AppRoutes.login,
          reason: 'Expected guest user to be redirected to login for protected route $route',
        );
      }
    });

    test('Protected routes allow access for authenticated user', () async {
      await container.read(authSessionProvider.notifier).startSession(
            accessToken: 'valid_sanctum_token',
            customerPayload: const CustomerModel(
              id: 1,
              email: 'test@rwnaqk.com',
              firstName: 'أحمد',
              lastName: 'علي',
              fullName: 'أحمد علي',
            ),
          );

      final session = container.read(authSessionProvider);
      expect(session.isAuthenticated, isTrue);
      expect(session.isGuest, isFalse);

      final protectedRoutes = [
        AppRoutes.payment,
        AppRoutes.orderConfirmation,
        AppRoutes.orderSuccess,
        AppRoutes.orderDetails,
        AppRoutes.orderTracking,
        AppRoutes.addresses,
        AppRoutes.profile,
        AppRoutes.editProfile,
        AppRoutes.passwordAndSecurity,
        AppRoutes.twoFactorAndPasskeys,
      ];

      for (final route in protectedRoutes) {
        final redirect = AppRouter.checkRouteGuards(route);
        expect(
          redirect,
          isNull,
          reason: 'Expected authenticated user to access protected route $route without redirect',
        );
      }
    });

    test('Auth flow routes redirect authenticated user to main', () async {
      await container.read(authSessionProvider.notifier).startSession(
            accessToken: 'valid_sanctum_token',
            customerPayload: const CustomerModel(id: 1, email: 'test@rwnaqk.com'),
          );

      final authFlowRoutes = [
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgot,
        AppRoutes.otp,
        AppRoutes.reset,
        AppRoutes.twoFactorChallenge,
      ];

      for (final route in authFlowRoutes) {
        final redirect = AppRouter.checkRouteGuards(route);
        expect(
          redirect,
          AppRoutes.main,
          reason: 'Expected authenticated user to be redirected away from $route to main',
        );
      }
    });

    test('Auth flow routes remain accessible to guests and unauthenticated', () async {
      await container.read(authSessionProvider.notifier).enterGuestMode();

      final authFlowRoutes = [
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgot,
        AppRoutes.otp,
        AppRoutes.reset,
        AppRoutes.twoFactorChallenge,
      ];

      for (final route in authFlowRoutes) {
        final redirect = AppRouter.checkRouteGuards(route);
        expect(
          redirect,
          isNull,
          reason: 'Expected guest user to be able to access auth flow route $route',
        );
      }
    });

    test('Banned user is locked to banned screen across all routes', () async {
      await container.read(authSessionProvider.notifier).markAsBanned();

      expect(AppRouter.checkRouteGuards(AppRoutes.home), AppRoutes.banned);
      expect(AppRouter.checkRouteGuards(AppRoutes.cart), AppRoutes.banned);
      expect(AppRouter.checkRouteGuards(AppRoutes.login), AppRoutes.banned);
      expect(AppRouter.checkRouteGuards(AppRoutes.banned), isNull);
    });

    test('Unverified email user is locked to email verification screen', () async {
      await container.read(authSessionProvider.notifier).startSession(
            accessToken: 'valid_token',
            emailVerificationRequired: true,
            customerPayload: const CustomerModel(
              id: 1,
              email: 'test@rwnaqk.com',
              emailVerifiedAt: null,
            ),
          );

      final session = container.read(authSessionProvider);
      expect(session.requiresEmailVerification, isTrue);

      expect(AppRouter.checkRouteGuards(AppRoutes.home), AppRoutes.emailVerify);
      expect(AppRouter.checkRouteGuards(AppRoutes.cart), AppRoutes.emailVerify);
      expect(AppRouter.checkRouteGuards(AppRoutes.emailVerify), isNull);
      expect(AppRouter.checkRouteGuards(AppRoutes.login), isNull);
    });
  });

  group('FIX-GUEST-02: onGenerateRoute & Return Route Attachment', () {
    test('onGenerateRoute attaches returnRoute when redirecting protected route to login', () {
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(name: AppRoutes.payment),
      );

      expect(route, isNotNull);
      expect(route!.settings.name, AppRoutes.login);

      final args = route.settings.arguments as Map<String, dynamic>?;
      expect(args, isNotNull);
      expect(args![AppRouteArgs.returnRoute], AppRoutes.payment);
    });

    test('onGenerateRoute preserves custom arguments inside returnArgs', () {
      final customArgs = <String, dynamic>{'order_id': 105, 'track': true};
      final route = AppRouter.onGenerateRoute(
        RouteSettings(name: AppRoutes.orderDetails, arguments: customArgs),
      );

      expect(route, isNotNull);
      expect(route!.settings.name, AppRoutes.login);

      final args = route.settings.arguments as Map<String, dynamic>?;
      expect(args, isNotNull);
      expect(args![AppRouteArgs.returnRoute], AppRoutes.orderDetails);
      expect(args[AppRouteArgs.returnArgs], customArgs);
    });
  });

  group('FIX-GUEST-02: MainScreen Bottom Navigation Interception', () {
    testWidgets('Tapping Cart (tab 3) as a guest switches tab and allows viewing without forced login redirect',
        (tester) async {
      await container.read(authSessionProvider.notifier).enterGuestMode();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: MainScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Ensure we are initially on Home tab (0)
      expect(container.read(mainNavigationProvider), 0);

      // Find Cart navigation button inside AppBottomNav
      final cartNavTab = find.descendant(
        of: find.byType(AppBottomNav),
        matching: find.byIcon(Icons.shopping_bag_outlined),
      );
      expect(cartNavTab, findsOneWidget);

      // Tap on Cart tab in Bottom Navigation
      await tester.tap(cartNavTab);
      await tester.pumpAndSettle();

      // Verification: Active tab in state switched to Cart (3)
      expect(container.read(mainNavigationProvider), 3);
    });

    testWidgets('Tapping Orders (tab 2) as a guest switches tab and allows viewing without forced login redirect',
        (tester) async {
      await container.read(authSessionProvider.notifier).enterGuestMode();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: MainScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Ensure we are initially on Home tab (0)
      expect(container.read(mainNavigationProvider), 0);

      // Find Orders navigation icon inside AppBottomNav
      final ordersNavTab = find.descendant(
        of: find.byType(AppBottomNav),
        matching: find.byIcon(Icons.inventory_2_outlined),
      );
      expect(ordersNavTab, findsOneWidget);

      // Tap on Orders tab
      await tester.tap(ordersNavTab);
      await tester.pumpAndSettle();

      // Verification: Active tab in state switched to Orders (2)
      expect(container.read(mainNavigationProvider), 2);
    });

    testWidgets('Tapping Cart and Orders as an authenticated user switches tabs normally',
        (tester) async {
      await container.read(authSessionProvider.notifier).startSession(
            accessToken: 'valid_token',
            customerPayload: const CustomerModel(
              id: 1,
              email: 'auth@rwnaqk.com',
              firstName: 'أحمد',
            ),
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: MainScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(container.read(mainNavigationProvider), 0);

      // Tap Orders (Tab 2)
      final ordersNavTab = find.descendant(
        of: find.byType(AppBottomNav),
        matching: find.byIcon(Icons.inventory_2_outlined),
      );
      await tester.tap(ordersNavTab);
      await tester.pumpAndSettle();
      expect(container.read(mainNavigationProvider), 2);

      // Tap Cart (Tab 3)
      final cartNavTab = find.descendant(
        of: find.byType(AppBottomNav),
        matching: find.byIcon(Icons.shopping_bag_outlined),
      );
      await tester.tap(cartNavTab);
      await tester.pumpAndSettle();
      expect(container.read(mainNavigationProvider), 3);
    });
  });
}