import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/core/translations/app_translations.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_controller.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_service.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/products_listing_service.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_attribute_group.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_color_option.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_review.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/repositories/products_repository.dart';
import 'package:rwnaqk_frontend/modules/catalog/models/product_details_state.dart';
import 'package:rwnaqk_frontend/modules/catalog/providers/catalog_providers.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_category_item.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/search/providers/search_providers.dart';

class Phase61MockProductsRepository implements IProductsRepository {
  List<HomeProductItem> products = <HomeProductItem>[];
  int getProductsCallCount = 0;
  ListingSort? lastSortRequested;
  Completer<List<HomeProductItem>>? delayedSearchCompleter;
  CancelToken? lastCancelToken;

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
    getProductsCallCount++;
    lastSortRequested = sort;
    var list = List<HomeProductItem>.from(products);
    if (sort == ListingSort.priceLow) {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (sort == ListingSort.priceHigh) {
      list.sort((a, b) => b.price.compareTo(a.price));
    }
    return list;
  }

  @override
  Future<HomeProductItem?> getProductById(String id) async {
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
  Future<List<HomeCategoryItem>> getCategories() async {
    return const [];
  }

  @override
  Future<List<HomeProductItem>> searchProducts(
    String query, {
    CancelToken? cancelToken,
  }) async {
    lastCancelToken = cancelToken;
    if (delayedSearchCompleter != null) {
      return delayedSearchCompleter!.future;
    }
    return products
        .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    Get.testMode = true;
    Get.clearTranslations();
    Get.addTranslations(AppTranslations().keys);
  });

  tearDown(() {
    Get.reset();
  });

  final sampleItem = HomeProductItem(
    id: 'prod_99',
    title: 'فستان مخملي راقي',
    price: 150.0,
    discountPercent: 25,
    imageUrl: 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446',
    availableColors: const [
      ProductColorOption(
        id: 'red',
        name: 'أحمر',
        imageUrl: 'https://example.com/red.jpg',
      ),
      ProductColorOption(
        id: 'blue',
        name: 'أزرق',
        imageUrl: 'https://example.com/blue.jpg',
      ),
    ],
    availableSizes: const ['S', 'M', 'L'],
  );

  ProviderContainer createContainer({required Phase61MockProductsRepository repo}) {
    final container = ProviderContainer(
      overrides: [
        productsRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('Phase 06.1 Quality Closure — False Add-to-Cart Hardening', () {
    test('Unregistered CartController returns false and does not show dialog', () {
      final mockRepo = Phase61MockProductsRepository()..products = [sampleItem];
      final container = createContainer(repo: mockRepo);

      // Ensure CartController is NOT registered in GetX
      expect(Get.isRegistered<CartController>(), isFalse);

      final notifier = container.read(productDetailsFamily(sampleItem.id).notifier);
      notifier.loadProduct(initialItem: sampleItem);

      // Must return false cleanly without exception or false positive
      final result = notifier.addToCart();
      expect(result, isFalse);
    });

    test('Registered CartController adds item, returns true, and increments quantity', () {
      final mockRepo = Phase61MockProductsRepository()..products = [sampleItem];
      final container = createContainer(repo: mockRepo);

      // Setup GetX CartController dependencies
      final profileStore = Get.put(
        ProfileStoreService(
          Get.put(AuthSessionService(container: container)),
          container,
        ),
      );
      Get.put(CartUiController());
      final cart = Get.put(CartController(CartService(profileStore)));
      cart.clearCart();

      final notifier = container.read(productDetailsFamily(sampleItem.id).notifier);
      notifier.loadProduct(initialItem: sampleItem);

      // First addition
      final firstAdd = notifier.addToCart();
      expect(firstAdd, isTrue);
      expect(cart.cartItems.length, 1);

      final lineId = cart.cartItems.first.id;
      expect(lineId, startsWith(sampleItem.id));
      expect(cart.itemQuantities[lineId], 1);

      // Second addition of the same configuration increments quantity
      final secondAdd = notifier.addToCart();
      expect(secondAdd, isTrue);
      expect(cart.cartItems.length, 1);
      expect(cart.itemQuantities[lineId], 2);
    });
  });

  group('Phase 06.1 Quality Closure — Search Debounce & Stale Query Rejection', () {
    test('Typing new query immediately cancels active token and advances sequence', () {
      final mockRepo = Phase61MockProductsRepository()..products = [sampleItem];
      final container = createContainer(repo: mockRepo);

      final searchNotifier = container.read(productSearchProvider.notifier);
      final initialState = container.read(productSearchProvider);
      final initialSeq = initialState.searchSequence;

      // Type first query
      searchNotifier.onQueryChanged('فستان');
      final state1 = container.read(productSearchProvider);
      expect(state1.query, 'فستان');
      expect(state1.searchSequence, greaterThan(initialSeq));

      // Type second query immediately (before debounce timer completes)
      searchNotifier.onQueryChanged('فستان أحمر');
      final state2 = container.read(productSearchProvider);
      expect(state2.query, 'فستان أحمر');
      expect(state2.searchSequence, greaterThan(state1.searchSequence));
    });

    test('Obsolete in-flight response is rejected if sequence advanced', () async {
      final mockRepo = Phase61MockProductsRepository();
      // Setup a pending completer to simulate a delayed query A
      mockRepo.delayedSearchCompleter = Completer<List<HomeProductItem>>();
      final container = createContainer(repo: mockRepo);

      final searchNotifier = container.read(productSearchProvider.notifier);

      // Submit Query A directly
      searchNotifier.onSubmitted('Query A');
      final seqA = container.read(productSearchProvider).searchSequence;

      // While Query A is in-flight, user changes query to Query B
      searchNotifier.onQueryChanged('Query B');
      final seqB = container.read(productSearchProvider).searchSequence;
      expect(seqB, greaterThan(seqA));

      // Now Query A completes with old results
      mockRepo.delayedSearchCompleter!.complete([sampleItem]);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Query A's results MUST NOT be applied because sequence was advanced
      final currentState = container.read(productSearchProvider);
      expect(currentState.query, 'Query B');
      expect(currentState.results, isEmpty);
    });
  });

  group('Phase 06.1 Quality Closure — Stable Product Variant Identity', () {
    test('Generates identical stableVariantKey regardless of attribute selection order', () {
      final state1 = ProductDetailsState(
        product: sampleItem,
        selectedAttributes: {
          'size': 'M',
          'color': 'red',
        },
      );

      final state2 = ProductDetailsState(
        product: sampleItem,
        selectedAttributes: {
          'color': 'red',
          'size': 'M',
        },
      );

      expect(state1.stableVariantKey, 'color:red|size:M');
      expect(state2.stableVariantKey, 'color:red|size:M');
      expect(state1.stableVariantKey, equals(state2.stableVariantKey));
    });

    test('Stable variant key is language-agnostic and does not mutate lineId on locale change', () {
      final state = ProductDetailsState(
        product: sampleItem,
        selectedAttributes: {
          'color': 'red',
          'size': 'L',
        },
        attributeGroups: [
          ProductAttributeGroup(
            id: 'color',
            name: 'اللون',
            type: ProductAttributeType.color,
            options: const [
              ProductAttributeOption(id: 'red', label: 'أحمر'),
            ],
          ),
          ProductAttributeGroup(
            id: 'size',
            name: 'المقاس',
            type: ProductAttributeType.text,
            options: const [
              ProductAttributeOption(id: 'L', label: 'كبير L'),
            ],
          ),
        ],
      );

      // UI chips are localized
      expect(state.selectedOptionChips, contains('أحمر'));
      // Stable variant key uses raw IDs, NOT localized text
      expect(state.stableVariantKey, 'color:red|size:L');
      expect(state.stableVariantKey.contains('أحمر'), isFalse);
    });

    test('CartController uses stableVariantId to prevent duplicate line items across locales', () {
      final profileStore = Get.put(
        ProfileStoreService(
          Get.put(AuthSessionService(container: ProviderContainer())),
          ProviderContainer(),
        ),
      );
      Get.put(CartUiController());
      final cart = Get.put(CartController(CartService(profileStore)));
      cart.clearCart();

      // Add item with Arabic localized text but stable key
      cart.addToCart(
        sampleItem,
        quantity: 1,
        variantText: 'أحمر - كبير',
        stableVariantId: 'color:red|size:L',
      );

      expect(cart.cartItems.length, 1);
      final lineId1 = cart.cartItems.first.id;
      expect(lineId1, 'prod_99_color:red|size:L');
      expect(cart.itemQuantities[lineId1], 1);

      // Add same variant in English session
      cart.addToCart(
        sampleItem,
        quantity: 2,
        variantText: 'Red - Large',
        stableVariantId: 'color:red|size:L',
      );

      // Must merge into the same line item instead of creating a duplicate!
      expect(cart.cartItems.length, 1);
      expect(cart.itemQuantities[lineId1], 3);
    });
  });

  group('Phase 06.1 Quality Closure — Catalog Sorting & Server Pagination', () {
    test('Dynamic catalog triggers refreshList on setSort to fetch page 1 with new sort', () async {
      final mockRepo = Phase61MockProductsRepository()..products = [sampleItem];
      final container = createContainer(repo: mockRepo);

      final notifier = container.read(productsListingProvider.notifier);
      await notifier.refreshList();

      expect(mockRepo.getProductsCallCount, 1);
      expect(mockRepo.lastSortRequested, ListingSort.newest);

      // Change sort order on dynamic catalog (initialItems is empty)
      notifier.setSort(ListingSort.priceLow);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      // Must have requested page 1 from repository with ListingSort.priceLow
      expect(mockRepo.getProductsCallCount, 2);
      expect(mockRepo.lastSortRequested, ListingSort.priceLow);
    });

    test('Static catalog applies local sort without querying repository', () async {
      final itemCheap = sampleItem.copyWith(id: 'p1', price: 50.0);
      final itemExpensive = sampleItem.copyWith(id: 'p2', price: 500.0);
      final mockRepo = Phase61MockProductsRepository()..products = [itemCheap, itemExpensive];
      final container = createContainer(repo: mockRepo);

      final notifier = container.read(productsListingProvider.notifier);
      // Initialize with static items
      notifier.initFromArgs({'items': [itemExpensive, itemCheap]});

      expect(mockRepo.getProductsCallCount, 0);

      // Change sort
      notifier.setSort(ListingSort.priceLow);

      // Still 0 backend calls because it sorts in-memory
      expect(mockRepo.getProductsCallCount, 0);
      final currentItems = container.read(productsListingProvider).items;
      expect(currentItems.first.id, 'p1');
      expect(currentItems.last.id, 'p2');
    });
  });
}
