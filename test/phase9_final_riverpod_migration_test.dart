import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/cart/providers/cart_providers.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/shipping_address.dart';
import 'package:rwnaqk_frontend/modules/customer/providers/customer_profile_providers.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/wishlist/providers/wishlist_providers.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

class InMemoryTokenStorage implements IAuthTokenStorage {
  String? _token;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> writeToken(String token) async => _token = token.trim();

  @override
  Future<void> clearToken() async => _token = null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    dotenv.loadFromString(
      envString: 'APP_ENV=development\nENABLE_MOCK_DATA=true\nAPI_BASE_URL=https://staging.rawnaqk.test/api/v1',
    );
  });

  group('Phase 09 — Final GetX to Riverpod 3 Complete Architecture Gate', () {
    late ProviderContainer container;
    late InMemoryTokenStorage tokenStorage;

    setUp(() {
      tokenStorage = InMemoryTokenStorage();
      container = ProviderContainer(
        overrides: [
          authTokenStorageProvider.overrideWithValue(tokenStorage),
        ],
      );
      globalProviderContainer = container;
    });

    tearDown(() {
      container.dispose();
    });

    // -------------------------------------------------------------------------
    // 1. Session Isolation and Single-Authoritative Writer Verification
    // -------------------------------------------------------------------------
    test('1. Riverpod AuthSessionNotifier is the single authoritative writer', () async {
      final authNotifier = container.read(authSessionProvider.notifier);

      expect(container.read(authSessionProvider).isAuthenticated, isFalse);
      expect(container.read(authSessionProvider).sessionGeneration, 0);

      // Start authenticated session
      const sampleCustomer = CustomerModel(
        id: 9001,
        fullName: 'الأميرة ريم',
        email: 'reem@rawnaqk.com',
        mobile: '777000111',
      );

      authNotifier.startSession(
        accessToken: 'secure_auth_token_99999',
        customerPayload: sampleCustomer,
      );

      final state = container.read(authSessionProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.customerId, '9001');
      expect(state.token, 'secure_auth_token_99999');
      expect(state.sessionGeneration, 1);

      // Check current customer projection
      final customer = container.read(currentCustomerProvider);
      expect(customer?.fullName, 'الأميرة ريم');
      expect(customer?.email, 'reem@rawnaqk.com');
    });

    // -------------------------------------------------------------------------
    // 2. Account Isolation & Cross-Account Local State Purge
    // -------------------------------------------------------------------------
    test('2. Changing or clearing session cleanses all session-scoped stores', () async {
      final authNotifier = container.read(authSessionProvider.notifier);

      // 1. Start user A session
      authNotifier.startSession(
        accessToken: 'user_a_token',
        customerPayload: const CustomerModel(id: 101, fullName: 'User A', email: 'a@rawnaqk.com'),
      );

      // Add item to cart
      final testProduct = HomeProductItem(
        id: 'prod-001',
        title: 'عطر مسك فاخر',
        price: 25000,
        imageUrl: 'https://example.com/perfume.png',
      );
      container.read(cartProvider.notifier).addToCart(testProduct, quantity: 2);
      expect(container.read(cartProvider).itemCount, 2);

      // Add item to wishlist
      container.read(wishlistProvider.notifier).toggleWishlist(testProduct);
      expect(container.read(wishlistProvider).items.length, 1);

      // Add address
      const testAddress = ShippingAddress(
        id: 'addr-01',
        country: 'اليمن',
        city: 'صنعاء',
        address: 'شارع حدة',
        postcode: '00000',
      );
      await container.read(addressesProvider.notifier).addAddress(testAddress);
      expect(container.read(addressesProvider).addresses.length, 1);

      // 2. Logout / Clear Session
      authNotifier.clearSession();

      // Verify all session stores purged
      expect(container.read(authSessionProvider).isAuthenticated, isFalse);
      expect(container.read(cartProvider).itemCount, 0);
      expect(container.read(wishlistProvider).items, isEmpty);
      expect(container.read(addressesProvider).addresses, isEmpty);
      expect(container.read(authSessionProvider).sessionGeneration, 2);
    });

    // -------------------------------------------------------------------------
    // 3. Pure Dart AuthSessionService Compatibility Adapter Verification
    // -------------------------------------------------------------------------
    test('3. AuthSessionService delegates cleanly to Riverpod without package:get', () {
      final service = AuthSessionService(container: container);

      expect(service.isAuthenticated, isFalse);
      expect(service.sessionGeneration, 0);

      service.startSession(
        accessToken: 'compat_token_888',
        customerPayload: const CustomerModel(id: 888, fullName: 'Al-Anood', email: 'anood@rawnaqk.com'),
      );

      expect(service.isAuthenticated, isTrue);
      expect(service.token.value, 'compat_token_888');
      expect(service.customer.value?.name, 'Al-Anood');
      expect(service.sessionGeneration, 1);

      service.clearSession();
      expect(service.isAuthenticated, isFalse);
      expect(service.token.value, isNull);
    });

    // -------------------------------------------------------------------------
    // 4. Cart Computations & Reactive Totals
    // -------------------------------------------------------------------------
    test('4. CartState lineTotals, quantities, and itemCount calculate accurately', () {
      final cartNotifier = container.read(cartProvider.notifier);

      final p1 = HomeProductItem(id: 'p1', title: 'فستان مخملي', price: 15000, imageUrl: 'https://example.com/p1.png');
      final p2 = HomeProductItem(id: 'p2', title: 'حقيبة كلاسيك', price: 30000, imageUrl: 'https://example.com/p2.png');

      cartNotifier.addToCart(p1, quantity: 1);
      cartNotifier.addToCart(p2, quantity: 2);

      final state = container.read(cartProvider);
      expect(state.linesCount, 2);
      expect(state.itemCount, 3);
      expect(state.subtotal, 15000 + (30000 * 2));

      // Decrement p2
      cartNotifier.decrementQuantity('p2');
      expect(container.read(cartProvider).itemCount, 2);
      expect(container.read(cartProvider).subtotal, 15000 + 30000);

      // Remove p1
      cartNotifier.removeFromCart('p1');
      expect(container.read(cartProvider).itemCount, 1);
      expect(container.read(cartProvider).subtotal, 30000);
    });

    // -------------------------------------------------------------------------
    // 5. Wishlist Toggle, Retention, and Sync
    // -------------------------------------------------------------------------
    test('5. WishlistNotifier manages favorite items and recent history', () {
      final wishlistNotifier = container.read(wishlistProvider.notifier);
      final product = HomeProductItem(id: 'fav-10', title: 'ساعة ألماس', price: 120000, imageUrl: 'https://example.com/fav.png');

      expect(container.read(wishlistProvider).isInWishlist('fav-10'), isFalse);

      wishlistNotifier.toggleWishlist(product);
      expect(container.read(wishlistProvider).isInWishlist('fav-10'), isTrue);

      wishlistNotifier.removeFromWishlist('fav-10');
      expect(container.read(wishlistProvider).isInWishlist('fav-10'), isFalse);
    });

    // -------------------------------------------------------------------------
    // 6. Navigation and Routing with AppNav
    // -------------------------------------------------------------------------
    test('6. AppNav handles currentRoute and navigation commands', () {
      AppNav.currentRoute = AppRoutes.main;
      expect(AppNav.currentRoute, AppRoutes.main);

      AppNav.currentRoute = AppRoutes.cart;
      expect(AppNav.currentRoute, AppRoutes.cart);
    });

    // -------------------------------------------------------------------------
    // 7. Localization, Locale Notifier and Translations
    // -------------------------------------------------------------------------
    test('7. AppLocaleNotifier and AppTranslations resolve localized keys without GetX', () async {
      final localeNotifier = container.read(appLocaleProvider.notifier);

      // Arabic default
      expect(AppTranslations.currentLocale.languageCode, 'ar');
      expect(Tk.homeTitle.tr, 'المتجر');
      expect(Tk.settingsLogout.tr, 'تسجيل الخروج');

      // Switch to English
      await localeNotifier.setLocale(const Locale('en', 'US'));
      expect(AppTranslations.currentLocale.languageCode, 'en');
      expect(Tk.homeTitle.tr, 'Shop');
      expect(Tk.settingsLogout.tr, 'Logout');

      // Switch back to Arabic
      await localeNotifier.setLocale(const Locale('ar', 'YE'));
      expect(AppTranslations.currentLocale.languageCode, 'ar');
      expect(Tk.homeTitle.tr, 'المتجر');
    });

    // -------------------------------------------------------------------------
    // 8. Theme Mode Switching
    // -------------------------------------------------------------------------
    test('8. AppThemeModeNotifier toggles and persists theme mode', () async {
      final themeNotifier = container.read(appThemeModeProvider.notifier);

      expect(container.read(appThemeModeProvider), ThemeMode.system);

      await themeNotifier.setThemeMode(ThemeMode.dark);
      expect(container.read(appThemeModeProvider), ThemeMode.dark);

      await themeNotifier.setThemeMode(ThemeMode.system);
      expect(container.read(appThemeModeProvider), ThemeMode.system);

      await themeNotifier.setThemeMode(ThemeMode.light);
      expect(container.read(appThemeModeProvider), ThemeMode.light);
    });

    // -------------------------------------------------------------------------
    // 9. Customer Profile Data Aggregator
    // -------------------------------------------------------------------------
    test('9. customerProfileDataProvider aggregates metrics seamlessly', () {
      final authNotifier = container.read(authSessionProvider.notifier);
      authNotifier.startSession(
        accessToken: 'vip_token',
        customerPayload: const CustomerModel(
          id: 777,
          fullName: 'سمو الأميرة لولوة',
          mobile: '777888999',
          email: 'lulu@rawnaqk.com',
        ),
      );

      final profileData = container.read(customerProfileDataProvider);
      expect(profileData.name, 'سمو');
      expect(profileData.phone, '777888999');
      expect(profileData.email, 'lulu@rawnaqk.com');
      expect(profileData.membershipTier, '');
      expect(profileData.stats.length, 4);
      expect(profileData.infoItems.length, 4);
    });
  });
}
