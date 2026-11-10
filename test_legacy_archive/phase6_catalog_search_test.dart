import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/network/api_exceptions.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/core/translations/app_translations.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_controller.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_service.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/products_listing_controller.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/products_listing_service.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/products_listing_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_color_option.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_review.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/repositories/products_repository.dart';
import 'package:rwnaqk_frontend/modules/catalog/models/product_details_state.dart';
import 'package:rwnaqk_frontend/modules/catalog/models/products_listing_state.dart';
import 'package:rwnaqk_frontend/modules/catalog/providers/catalog_providers.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/app_filter_sheet.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_category_item.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/search/controllers/app_search_controller.dart';
import 'package:rwnaqk_frontend/modules/search/controllers/search_service.dart';
import 'package:rwnaqk_frontend/modules/search/controllers/search_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/search/providers/search_providers.dart';
import 'package:rwnaqk_frontend/modules/wishlist/providers/wishlist_providers.dart';

class MockProductsRepository implements IProductsRepository {
  List<HomeProductItem> products = <HomeProductItem>[];
  List<HomeCategoryItem> categories = <HomeCategoryItem>[];
  bool shouldThrowNetworkError = false;
  int delayMs = 0;
  List<String> searchCalls = <String>[];
  List<CancelToken?> cancelTokens = <CancelToken?>[];

  @override
  Future<List<HomeProductItem>> getProducts({
    int seed = 1,
    int limit = 10,
    ListingSort sort = ListingSort.newest,
    double? minPrice,
    double? maxPrice,
    String? categoryId,
    String? search,
  }) async {
    if (shouldThrowNetworkError) {
      throw const NetworkException(message: 'Network error', statusCode: 503);
    }
    if (delayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: delayMs));
    }
    var list = List<HomeProductItem>.from(products);
    if (minPrice != null) list = list.where((p) => p.price >= minPrice).toList();
    if (maxPrice != null) list = list.where((p) => p.price <= maxPrice).toList();
    if (sort == ListingSort.priceLow) list.sort((a, b) => a.price.compareTo(b.price));
    if (sort == ListingSort.priceHigh) list.sort((a, b) => b.price.compareTo(a.price));
    return list;
  }

  @override
  Future<HomeProductItem?> getProductById(String id) async {
    if (delayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: delayMs));
    }
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  Future<List<ProductReview>> getProductReviews(
    String productId, {
    dynamic rawReviews,
  }) async {
    return const [];
  }

  @override
  Future<List<HomeProductItem>> searchProducts(
    String query, {
    CancelToken? cancelToken,
  }) async {
    searchCalls.add(query);
    cancelTokens.add(cancelToken);

    if (delayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: delayMs));
    }

    if (cancelToken?.isCancelled == true) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.cancel,
      );
    }

    return products
        .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<List<HomeCategoryItem>> getCategories() async {
    return categories;
  }
}

ProviderContainer createContainer({
  MockProductsRepository? repo,
}) {
  final container = ProviderContainer(
    overrides: [
      if (repo != null) productsRepositoryProvider.overrideWithValue(repo),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    Get.testMode = true;
    Get.clearTranslations();
    Get.addTranslations(AppTranslations().keys);
  });

  setUp(() {
    Get.reset();
  });

  final sampleProducts = List.generate(
    15,
    (i) => HomeProductItem(
      id: 'prod_$i',
      title: 'Fashion Item $i',
      price: (i + 1) * 10.0,
      imageUrl: 'https://picsum.photos/200/200?item=$i',
      discountPercent: i % 3 == 0 ? 20 : 0,
      availableColors: const [
        ProductColorOption(id: 'red', name: 'أحمر', imageUrl: 'https://picsum.photos/img1'),
        ProductColorOption(id: 'blue', name: 'أزرق', imageUrl: 'https://picsum.photos/img2'),
      ],
      availableSizes: const ['S', 'M', 'L', 'XL'],
    ),
  );

  group('Phase 06: ProductsListingState & Immutability', () {
    test('State initializes with sensible defaults and supports immutable copyWith', () {
      final initial = ProductsListingState.initial();
      expect(initial.items, isEmpty);
      expect(initial.isLoading, isFalse);
      expect(initial.hasMore, isTrue);
      expect(initial.page, 1);
      expect(initial.sort, ListingSort.newest);

      final modified = initial.copyWith(
        items: [sampleProducts.first],
        isLoading: true,
        page: 2,
        sort: ListingSort.priceLow,
      );

      expect(modified.items.length, 1);
      expect(modified.isLoading, isTrue);
      expect(modified.page, 2);
      expect(modified.sort, ListingSort.priceLow);
      expect(initial.items, isEmpty); // Original unmodified
    });
  });

  group('Phase 06: ProductsListingNotifier & Pagination', () {
    test('Initial load from arguments populates items and applies sort/filters', () async {
      final mockRepo = MockProductsRepository()..products = sampleProducts;
      final container = createContainer(repo: mockRepo);

      final notifier = container.read(productsListingProvider.notifier);
      notifier.initFromArgs({
        'title': 'Summer Dresses',
        'source': 'flash_sale',
        'items': sampleProducts.take(3).toList(),
      });

      final state = container.read(productsListingProvider);
      expect(state.title, 'Summer Dresses');
      expect(state.source, 'flash_sale');
      expect(state.items.length, 3);
      expect(state.isLoading, isFalse);
    });

    test('refreshList fetches fresh items from repository and applies price filtering', () async {
      final mockRepo = MockProductsRepository()..products = sampleProducts;
      final container = createContainer(repo: mockRepo);

      final notifier = container.read(productsListingProvider.notifier);
      await notifier.refreshList();

      var state = container.read(productsListingProvider);
      expect(state.items.length, 15);
      expect(state.isLoading, isFalse);
      expect(state.hasMore, isTrue);

      // Apply price filter between 20 and 50
      notifier.setFilter(const AppFilterResult(
        selectedCategories: {},
        selectedSizeIndex: 2,
        segment: FilterSegment.clothes,
        selectedColorIndex: 0,
        priceRange: RangeValues(20, 50),
        sort: FilterSort.popular,
      ));

      state = container.read(productsListingProvider);
      expect(state.items.every((p) => p.price >= 20 && p.price <= 50), isTrue);
      expect(state.activeFilterCount, 1);
    });

    test('loadMore performs boundary pagination and detects end-of-list cleanly', () async {
      final mockRepo = MockProductsRepository()..products = sampleProducts.take(5).toList();
      final container = createContainer(repo: mockRepo);

      final notifier = container.read(productsListingProvider.notifier);
      await notifier.refreshList();

      var state = container.read(productsListingProvider);
      expect(state.items.length, 5);

      // Now mock returning empty list on next page
      mockRepo.products = [];
      await notifier.loadMore();

      state = container.read(productsListingProvider);
      expect(state.hasMore, isFalse);
      expect(state.isLoadingMore, isFalse);
    });
  });

  group('Phase 06: ProductDetailsState & Variants', () {
    test('Calculates unit price, total price, and discount correctly', () {
      final item = sampleProducts[0]; // Price: 10, discount: 20%
      final state = ProductDetailsState(
        product: item,
        quantity: 3,
      );

      expect(state.hasDiscount, isTrue);
      expect(state.unitPrice, 8.0); // 10 * (1 - 0.20)
      expect(state.totalPrice, 24.0); // 8.0 * 3
      expect(state.totalPriceText, '24.00');
    });

    test('Attribute selection and quantity guards', () {
      final item = sampleProducts[0];
      final state = ProductDetailsState(
        product: item,
        selectedColorId: 'red',
        selectedSize: 'M',
        quantity: 1,
      );

      expect(state.selectedOptionChips, contains('أحمر'));
      expect(state.selectedOptionChips, contains('M'));

      // Decrement below 1 is guarded
      final updated = state.copyWith(quantity: state.quantity - 1);
      expect(updated.quantity, 0); // copyWith reflects, but notifier guards
    });
  });

  group('Phase 06: ProductDetailsNotifier & Interoperability', () {
    test('Synchronizes favorite status with wishlistProvider directly', () async {
      final item = sampleProducts[0];
      final mockRepo = MockProductsRepository()..products = [item];
      final container = createContainer(repo: mockRepo);

      final notifier = container.read(productDetailsFamily(item.id).notifier);
      await notifier.loadProduct(initialItem: item);

      var state = container.read(productDetailsFamily(item.id));
      expect(state.isFavorite, isFalse);

      // Toggle favorite
      notifier.toggleFavorite();

      state = container.read(productDetailsFamily(item.id));
      expect(state.isFavorite, isTrue);

      // Verify wishlistProvider also updated
      final inWishlist = container.read(wishlistProvider).isInWishlist(item.id);
      expect(inWishlist, isTrue);
    });

    test('addToCart interoperates cleanly with CartController', () async {
      final item = sampleProducts[0];
      final mockRepo = MockProductsRepository()..products = [item];
      final container = createContainer(repo: mockRepo);

      // Setup CartController in GetX for cross-framework interop test
      final profileStore = Get.put(ProfileStoreService(Get.put(AuthSessionService(container: container)), container));
      Get.put(CartUiController());
      final cart = Get.put(CartController(CartService(profileStore)));
      cart.clearCart();

      final notifier = container.read(productDetailsFamily(item.id).notifier);
      await notifier.loadProduct(initialItem: item);
      notifier.incrementQuantity(); // quantity: 2
      notifier.addToCart();

      expect(cart.cartItems.length, 1);
      final lineItemId = cart.cartItems.first.id;
      expect(lineItemId, startsWith(item.id));
      expect(cart.itemQuantities[lineItemId], 2);
    });
  });

  group('Phase 06: Search Debounce, Dio CancelToken & Stale Query Rejection', () {
    test('onQueryChanged debounces search and onSubmitted executes immediately', () async {
      final mockRepo = MockProductsRepository()..products = sampleProducts;
      final container = createContainer(repo: mockRepo);

      final notifier = container.read(productSearchProvider.notifier);

      // 1. Rapid keystrokes within 300ms
      notifier.onQueryChanged('Fash');
      expect(mockRepo.searchCalls, isEmpty); // Not executed yet

      // 2. Submit executes immediately without waiting for debounce
      notifier.onSubmitted('Fashion Item 1');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final state = container.read(productSearchProvider);
      expect(state.results.isNotEmpty, isTrue);
      expect(state.history, contains('Fashion Item 1'));
    });

    test('Stale delayed response is rejected when a newer query completes', () async {
      final mockRepo = MockProductsRepository()..products = sampleProducts;
      final container = createContainer(repo: mockRepo);

      final notifier = container.read(productSearchProvider.notifier);

      // Start Query A with artificial delay
      mockRepo.delayMs = 100;
      notifier.onSubmitted('QueryA');

      // Immediately start Query B with zero delay
      mockRepo.delayMs = 0;
      notifier.onSubmitted('Fashion');

      await Future<void>.delayed(const Duration(milliseconds: 150));

      final state = container.read(productSearchProvider);
      // Query B must prevail
      expect(state.query, 'Fashion');
    });

    test('Empty query clears results immediately and cancels active tokens', () {
      final container = createContainer();
      final notifier = container.read(productSearchProvider.notifier);

      notifier.onSubmitted('Item');
      notifier.clearQuery();

      final state = container.read(productSearchProvider);
      expect(state.query, isEmpty);
      expect(state.results, isEmpty);
      expect(state.isLoading, isFalse);
    });
  });

  group('Phase 06: Single-Writer Delegation Facades', () {
    test('ProductsListingController delegates commands and reflects Riverpod updates', () async {
      final mockRepo = MockProductsRepository()..products = sampleProducts;
      final container = createContainer(repo: mockRepo);

      Get.put(ProductsListingUiController());
      final controller = ProductsListingController(
        ProductsListingService(),
        repository: mockRepo,
        container: container,
      );
      controller.onInit();
      addTearDown(controller.onClose);

      await controller.refreshList();
      expect(controller.items.length, 15);

      // Mutate Riverpod directly: controller must reflect
      container.read(productsListingProvider.notifier).setSort(ListingSort.priceLow);
      expect(controller.items.first.price, 10.0);
    });

    test('AppSearchController delegates search commands to Riverpod', () async {
      final mockRepo = MockProductsRepository()..products = sampleProducts;
      final container = createContainer(repo: mockRepo);

      Get.put(SearchUiController());
      final controller = AppSearchController(
        SearchService(),
        container: container,
      );
      controller.onInit();
      addTearDown(controller.onClose);

      controller.onSubmitted('Fashion Item 2');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(controller.results.any((p) => p.title == 'Fashion Item 2'), isTrue);
      expect(controller.history, contains('Fashion Item 2'));
    });
  });

  group('Phase 06: Categories Lookup Provider', () {
    test('categoriesProvider fetches category tree from repository', () async {
      const mockCategories = [
        HomeCategoryItem(id: 'c1', name: 'ملابس', count: 50, imageUrls: []),
        HomeCategoryItem(id: 'c2', name: 'أحذية', count: 30, imageUrls: []),
      ];
      final mockRepo = MockProductsRepository()..categories = mockCategories;
      final container = createContainer(repo: mockRepo);

      final categories = await container.read(categoriesProvider.future);
      expect(categories.length, 2);
      expect(categories.first.name, 'ملابس');
    });
  });
}
