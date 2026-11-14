import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rwnaqk_frontend/core/constants/local_storage_keys.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/translations/app_translations.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/core/services/auth/customer_auth_api_service.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_service.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/onboarding/controllers/onboarding_service.dart';
import 'package:rwnaqk_frontend/modules/onboarding/providers/onboarding_providers.dart';
import 'package:rwnaqk_frontend/modules/onboarding/views/onboarding_view.dart';
import 'package:rwnaqk_frontend/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:rwnaqk_frontend/modules/wishlist/controllers/wishlist_service.dart';
import 'package:rwnaqk_frontend/modules/wishlist/controllers/wishlist_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/wishlist/models/wishlist_state.dart';
import 'package:rwnaqk_frontend/modules/wishlist/providers/wishlist_providers.dart';
import 'package:rwnaqk_frontend/modules/wishlist/views/wishlist_view.dart';

class FakeTokenStorage implements IAuthTokenStorage {
  String? _token;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> writeToken(String token) async => _token = token;

  @override
  Future<void> clearToken() async => _token = null;
}

Widget _buildTestApp({
  required Widget child,
  ProviderContainer? container,
}) {
  Get.testMode = true;

  if (!Get.isRegistered<IAuthTokenStorage>()) {
    Get.put<IAuthTokenStorage>(FakeTokenStorage());
  }
  if (!Get.isRegistered<CustomerAuthApiService>()) {
    Get.put(CustomerAuthApiService());
  }
  if (!Get.isRegistered<AuthSessionService>()) {
    Get.put(AuthSessionService(tokenStorage: Get.find<IAuthTokenStorage>()));
  }

  if (!Get.isRegistered<AppSettingsUiController>()) {
    Get.put(AppSettingsUiController());
  }
  if (!Get.isRegistered<AppSettingsService>()) {
    Get.put(AppSettingsService());
  }
  if (!Get.isRegistered<AppSettingsController>()) {
    Get.put(AppSettingsController(Get.find<AppSettingsService>()));
  }

  if (!Get.isRegistered<WishlistService>()) {
    Get.put(WishlistService());
  }
  if (!Get.isRegistered<WishlistController>()) {
    Get.put(WishlistController(Get.find<WishlistService>(), container));
  }

  final app = GetMaterialApp(
    translations: AppTranslations(),
    locale: const Locale('ar', 'YE'),
    fallbackLocale: const Locale('en', 'US'),
    routes: {
      '/login': (_) => const Scaffold(body: Text('Login Screen')),
      '/main': (_) => const Scaffold(body: Text('Main Screen')),
    },
    home: child,
  );

  if (container != null) {
    return UncontrolledProviderScope(
      container: container,
      child: app,
    );
  }

  return ProviderScope(child: app);
}

HomeProductItem _createMockProduct(String id, String title) {
  return HomeProductItem(
    id: id,
    title: title,
    price: 15000,
    imageUrl: 'https://images.test.com/product_$id.jpg',
    tagKey: 'dresses',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 03: Onboarding Service & Persistent State', () {
    test('OnboardingService returns slides and checks last page', () {
      final service = OnboardingService();
      expect(service.slides.length, 3);
      expect(service.slides.first.icon, Icons.shopping_bag_rounded);
      expect(service.isLastPage(currentIndex: 0, totalSlides: 3), isFalse);
      expect(service.isLastPage(currentIndex: 1, totalSlides: 3), isFalse);
      expect(service.isLastPage(currentIndex: 2, totalSlides: 3), isTrue);
    });

    test('OnboardingService persists completion flag to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final service = OnboardingService();

      expect(await service.hasSeenOnboarding(), isFalse);
      final saved = await service.markOnboardingAsSeen();
      expect(saved, isTrue);
      expect(await service.hasSeenOnboarding(), isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(LocalStorageKeys.onboardingSeen), isTrue);
    });

    test('OnboardingCompletionNotifier updates state and saves to storage', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(onboardingCompletionProvider), isFalse);

      final notifier = container.read(onboardingCompletionProvider.notifier);
      final success = await notifier.completeOnboarding();

      expect(success, isTrue);
      expect(container.read(onboardingCompletionProvider), isTrue);

      final service = container.read(onboardingServiceProvider);
      expect(await service.hasSeenOnboarding(), isTrue);
    });

    test('OnboardingCompletionNotifier initializes synchronously to true when SharedPreferences has onboarding_seen', () async {
      SharedPreferences.setMockInitialValues({
        LocalStorageKeys.onboardingSeen: true,
      });
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      // Value is immediately true synchronously on build()
      expect(container.read(onboardingCompletionProvider), isTrue);
    });
  });

  group('Phase 03: Onboarding Widget & Lifecycle', () {
    testWidgets('OnboardingScreen renders, paginates, skips and disposes cleanly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          container: container,
          child: const OnboardingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Screen is rendered
      expect(find.byType(OnboardingScreen), findsOneWidget);

      // Verify Skip button is present on initial page
      final skipFinder = find.text(Tk.onboardingSkip.tr);
      expect(skipFinder, findsOneWidget);

      // Verify Next button is present
      final nextFinder = find.text(Tk.onboardingNext.tr);
      expect(nextFinder, findsOneWidget);

      // Tap Next to advance to page 2
      await tester.tap(nextFinder);
      await tester.pumpAndSettle();

      // Tap Skip to jump to the last page
      await tester.tap(skipFinder);
      await tester.pumpAndSettle();

      // On the last page, button changes to Get Started and Skip is replaced
      expect(find.text(Tk.onboardingGetStarted.tr), findsOneWidget);
      expect(find.text(Tk.onboardingSkip.tr), findsNothing);

      // Tap Get Started
      await tester.tap(find.text(Tk.onboardingGetStarted.tr));
      await tester.pumpAndSettle();

      // Verify completion state updated
      expect(container.read(onboardingCompletionProvider), isTrue);

      // Test clean disposal
      await tester.pumpWidget(
        _buildTestApp(
          container: container,
          child: const SizedBox.shrink(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen), findsNothing);
    });

    testWidgets('OnboardingScreen tapping already have account completes onboarding and navigates', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          container: container,
          child: const OnboardingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(container.read(onboardingCompletionProvider), isFalse);

      final haveAccountFinder = find.text(Tk.onboardingHaveAccount.tr);
      expect(haveAccountFinder, findsOneWidget);

      await tester.tap(haveAccountFinder);
      await tester.pumpAndSettle();

      // Completion state is updated to true
      expect(container.read(onboardingCompletionProvider), isTrue);
    });
  });

  group('Phase 03: Wishlist Models & Pure State', () {
    test('WishlistState defaults, isInWishlist and copyWith', () {
      final p1 = _createMockProduct('101', 'فستان وردي');
      final p2 = _createMockProduct('102', 'عباية حرير');

      const initial = WishlistState();
      expect(initial.items, isEmpty);
      expect(initial.recentlyViewed, isEmpty);
      expect(initial.tabIndex, 0);
      expect(initial.recentFilter, RecentFilter.today);
      expect(initial.selectedDate, isNull);
      expect(initial.activeUserId, isNull);
      expect(initial.sessionGeneration, 0);
      expect(initial.count, 0);
      expect(initial.isEmpty, isTrue);

      final updated = initial.copyWith(
        items: [p1, p2],
        tabIndex: 1,
        recentFilter: RecentFilter.yesterday,
        activeUserId: 'usr_42',
        sessionGeneration: 2,
      );

      expect(updated.count, 2);
      expect(updated.isEmpty, isFalse);
      expect(updated.isInWishlist('101'), isTrue);
      expect(updated.isInWishlist('999'), isFalse);
      expect(updated.tabIndex, 1);
      expect(updated.recentFilter, RecentFilter.yesterday);
      expect(updated.activeUserId, 'usr_42');
      expect(updated.sessionGeneration, 2);

      // Test clearSelectedDate
      final withDate = updated.copyWith(
        selectedDate: DateTime(2026, 11, 9),
        recentFilter: RecentFilter.date,
      );
      expect(withDate.selectedDate, isNotNull);
      final clearedDate = withDate.copyWith(clearSelectedDate: true);
      expect(clearedDate.selectedDate, isNull);
    });
  });

  group('Phase 03: WishlistNotifier Operations & Single-Writer', () {
    test('WishlistNotifier manages add, remove, and toggle operations', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(wishlistProvider.notifier);

      // Clear seeded data for deterministic testing
      notifier.clearWishlist();
      expect(container.read(wishlistProvider).items, isEmpty);

      final p1 = _createMockProduct('p_1', 'حقيبة يد فاخرة');
      final p2 = _createMockProduct('p_2', 'حذاء كلاسيكي');

      // Add product
      notifier.addToWishlist(p1);
      expect(container.read(wishlistProvider).count, 1);
      expect(notifier.isInWishlist('p_1'), isTrue);

      // Add duplicate is ignored
      notifier.addToWishlist(p1);
      expect(container.read(wishlistProvider).count, 1);

      // Toggle existing removes it
      notifier.toggleWishlist(p1);
      expect(container.read(wishlistProvider).count, 0);
      expect(notifier.isInWishlist('p_1'), isFalse);

      // Toggle non-existing adds it
      notifier.toggleWishlist(p2);
      expect(container.read(wishlistProvider).count, 1);
      expect(notifier.isInWishlist('p_2'), isTrue);

      // Remove from wishlist
      notifier.removeFromWishlist('p_2');
      expect(container.read(wishlistProvider).count, 0);
    });

    test('WishlistNotifier manages tab switching, filters, and recently viewed', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(wishlistProvider.notifier);

      notifier.setTab(1);
      expect(container.read(wishlistProvider).tabIndex, 1);

      notifier.setRecentFilter(RecentFilter.yesterday);
      expect(container.read(wishlistProvider).recentFilter, RecentFilter.yesterday);

      final customDate = DateTime(2026, 11, 5);
      notifier.chooseDate(customDate);
      expect(container.read(wishlistProvider).selectedDate, DateTime(2026, 11, 5));
      expect(container.read(wishlistProvider).recentFilter, RecentFilter.date);

      final p = _createMockProduct('rec_1', 'منتج حديث');
      notifier.addRecentlyViewed(p);
      expect(container.read(wishlistProvider).recentlyViewed.first.id, 'rec_1');
    });

    test('Wishlist bulk actions: addAllToCart and clearWishlist', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(wishlistProvider.notifier);
      notifier.clearWishlist();

      // Empty wishlist: addAllToCart is a safe no-op
      expect(() => notifier.addAllToCart(), returnsNormally);

      // Add items
      final p1 = _createMockProduct('b_1', 'فستان سهرة');
      final p2 = _createMockProduct('b_2', 'حقيبة كلاسيكية');
      notifier.addToWishlist(p1);
      notifier.addToWishlist(p2);
      expect(container.read(wishlistProvider).count, 2);

      // Bulk clear
      notifier.clearWishlist();
      expect(container.read(wishlistProvider).items, isEmpty);
      expect(container.read(wishlistProvider).count, 0);
    });
  });

  group('Phase 03: Security & Session Isolation (Mandatory Scenarios)', () {
    test('Scenario 1 & 2: User A items are wiped on logout; User B sees clean state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(wishlistProvider.notifier);

      // User A logs in
      notifier.syncWithSession(userId: 'user_A', generation: 1);
      notifier.clearWishlist();

      final itemA = _createMockProduct('fav_A', 'عطر خاص بالمستخدم A');
      notifier.addToWishlist(itemA);
      expect(container.read(wishlistProvider).count, 1);
      expect(container.read(wishlistProvider).items.first.id, 'fav_A');

      // User A logs out -> clearWishlist called
      notifier.clearWishlist();
      expect(container.read(wishlistProvider).items, isEmpty);

      // User B logs in
      notifier.syncWithSession(userId: 'user_B', generation: 2);
      expect(container.read(wishlistProvider).items, isEmpty);
      expect(container.read(wishlistProvider).activeUserId, 'user_B');

      // User B adds their own item
      final itemB = _createMockProduct('fav_B', 'ساعة مستخدم B');
      notifier.addToWishlist(itemB);
      expect(container.read(wishlistProvider).count, 1);
      expect(container.read(wishlistProvider).items.first.id, 'fav_B');
      expect(container.read(wishlistProvider).isInWishlist('fav_A'), isFalse);
    });

    test('Scenario 3: Delayed/Stale response from User A cannot clear or corrupt User B', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(wishlistProvider.notifier);

      // User B is active
      notifier.syncWithSession(userId: 'user_B', generation: 2);
      notifier.clearWishlist();
      notifier.addToWishlist(_createMockProduct('b_item', 'منتج B'));
      expect(container.read(wishlistProvider).count, 1);

      // Stale cleanup for user_A arrives
      notifier.clearWishlist(expectedUserId: 'user_A', expectedGeneration: 1);

      // User B's state remains intact!
      expect(container.read(wishlistProvider).count, 1);
      expect(container.read(wishlistProvider).isInWishlist('b_item'), isTrue);
    });

    test('Scenario 4: Stale generation response is rejected', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(wishlistProvider.notifier);
      notifier.syncWithSession(userId: 'user_B', generation: 5);
      notifier.clearWishlist();
      notifier.addToWishlist(_createMockProduct('active_gen', 'منتج الجيل 5'));

      // Stale request with older generation 3
      notifier.clearWishlist(expectedUserId: 'user_B', expectedGeneration: 3);

      // State is protected
      expect(container.read(wishlistProvider).count, 1);
    });

    test('Scenario 5: Switching user ID via syncWithSession wipes previous cached data and recently viewed automatically', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(wishlistProvider.notifier);
      notifier.syncWithSession(userId: 'account_1', generation: 1);
      notifier.clearWishlist();
      notifier.addToWishlist(_createMockProduct('acc1_item', 'منتج حساب 1'));
      notifier.addRecentlyViewed(_createMockProduct('acc1_rec', 'مشاهدة حساب 1'));
      notifier.setTab(1);
      notifier.setRecentFilter(RecentFilter.yesterday);
      expect(container.read(wishlistProvider).count, 1);
      expect(container.read(wishlistProvider).recentlyViewed, isNotEmpty);
      expect(container.read(wishlistProvider).tabIndex, 1);

      // Direct switch to account_2 without explicit clear
      notifier.syncWithSession(userId: 'account_2', generation: 2);

      // Items and recently viewed are automatically purged, and tab index is reset!
      expect(container.read(wishlistProvider).items, isEmpty);
      expect(container.read(wishlistProvider).recentlyViewed, isEmpty);
      expect(container.read(wishlistProvider).tabIndex, 0);
      expect(container.read(wishlistProvider).recentFilter, RecentFilter.today);
      expect(container.read(wishlistProvider).activeUserId, 'account_2');
    });

    test('Scenario 6: Guest mode transitions — user logout transitions cleanly to guest state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(wishlistProvider.notifier);

      // User logs in and adds private items
      notifier.syncWithSession(userId: 'user_private', generation: 1);
      notifier.clearWishlist();
      notifier.addToWishlist(_createMockProduct('p_priv', 'منتج خاص'));
      expect(container.read(wishlistProvider).count, 1);

      // User logs out -> session becomes guest (userId == null)
      notifier.syncWithSession(userId: null, generation: 2);

      // Private items are purged automatically upon leaving the authenticated session!
      expect(container.read(wishlistProvider).items, isEmpty);
      expect(container.read(wishlistProvider).activeUserId, isNull);
    });

    test('ProviderContainer isolation: separate containers maintain isolated wishlist state', () {
      final containerA = ProviderContainer();
      final containerB = ProviderContainer();
      addTearDown(() {
        containerA.dispose();
        containerB.dispose();
      });

      containerA.read(wishlistProvider.notifier).clearWishlist();
      containerB.read(wishlistProvider.notifier).clearWishlist();

      containerA.read(wishlistProvider.notifier).addToWishlist(_createMockProduct('in_a', 'منتج في A'));

      expect(containerA.read(wishlistProvider).count, 1);
      expect(containerB.read(wishlistProvider).count, 0);
    });
  });

  group('Phase 03: WishlistController Compatibility Bridge (Single Writer)', () {
    test('WishlistController delegates writes to Riverpod and syncs read projection', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Inject custom container into bridge
      final bridge = WishlistController(WishlistService(), container);
      bridge.onInit();
      addTearDown(bridge.onClose);

      // Clear through bridge
      bridge.clearWishlist();
      expect(container.read(wishlistProvider).items, isEmpty);
      expect(bridge.wishlist, isEmpty);

      // Add through bridge delegates to Riverpod
      final product = _createMockProduct('bridge_1', 'منتج عبر الجسر');
      bridge.toggleWishlist(product);

      // Both Riverpod and GetX projection are updated!
      expect(container.read(wishlistProvider).isInWishlist('bridge_1'), isTrue);
      expect(bridge.wishlist.length, 1);
      expect(bridge.isInWishlist('bridge_1'), isTrue);

      // Remove through bridge
      bridge.removeFromWishlist('bridge_1');
      expect(container.read(wishlistProvider).count, 0);
      expect(bridge.wishlist, isEmpty);
    });

    test('Single-Writer invariant: external writes are routed to Riverpod and unsupported raw mutations throw', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final bridge = WishlistController(WishlistService(), container);
      bridge.onInit();
      addTearDown(bridge.onClose);

      final item = _createMockProduct('ext_hack', 'إضافة عبر الإسقاط');

      // Direct write is safely routed to Riverpod as authoritative writer
      bridge.wishlist.add(item);
      expect(container.read(wishlistProvider).isInWishlist('ext_hack'), isTrue);

      // Raw index-based manipulation throws UnsupportedError to preserve single-writer integrity
      expect(() => bridge.wishlist.insert(0, item), throwsUnsupportedError);
      expect(() => bridge.wishlist.removeAt(0), throwsUnsupportedError);
      expect(() => bridge.wishlist.removeLast(), throwsUnsupportedError);
    });
  });

  group('Phase 03: Wishlist Widget Smoke & UI Tests', () {
    testWidgets('WishlistScreen renders within ProviderScope with tabs and empty state', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Clear items to show empty state
      container.read(wishlistProvider.notifier).clearWishlist();

      await tester.pumpWidget(
        _buildTestApp(
          container: container,
          child: const WishlistScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WishlistScreen), findsOneWidget);

      // Empty state glowing heart and explore button rendered
      expect(find.text('قائمة أمنياتك فارغة'), findsOneWidget);
      expect(find.text('ابدأ التسوق الآن'), findsOneWidget);

      // Switch to Recently viewed tab
      final recentTab = find.textContaining(Tk.wishlistRecentlyViewed.tr);
      expect(recentTab, findsOneWidget);
      await tester.tap(recentTab);
      await tester.pumpAndSettle();

      // State updated to tab 1
      expect(container.read(wishlistProvider).tabIndex, 1);
    });
  });
}
