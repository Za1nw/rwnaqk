import 'package:flutter/foundation.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/products_listing_service.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/app_filter_sheet.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

/// الحالة غير القابلة للتعديل لشاشة عرض المنتجات والكتالوج [ProductsListingState]
@immutable
class ProductsListingState {
  const ProductsListingState({
    required this.items,
    this.initialItems = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 1,
    this.title = 'Products',
    this.source = 'generic',
    this.errorMessage,
    this.sort = ListingSort.newest,
    this.filterResult,
    this.activeFilterCount = 0,
  });

  final List<HomeProductItem> items;
  final List<HomeProductItem> initialItems;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String title;
  final String source;
  final String? errorMessage;
  final ListingSort sort;
  final AppFilterResult? filterResult;
  final int activeFilterCount;

  factory ProductsListingState.initial() {
    return const ProductsListingState(
      items: <HomeProductItem>[],
      initialItems: <HomeProductItem>[],
      isLoading: false,
      isLoadingMore: false,
      hasMore: true,
      page: 1,
      title: 'Products',
      source: 'generic',
      errorMessage: null,
      sort: ListingSort.newest,
      filterResult: null,
      activeFilterCount: 0,
    );
  }

  ProductsListingState copyWith({
    List<HomeProductItem>? items,
    List<HomeProductItem>? initialItems,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? title,
    String? source,
    String? Function()? errorMessage,
    ListingSort? sort,
    AppFilterResult? Function()? filterResult,
    int? activeFilterCount,
  }) {
    return ProductsListingState(
      items: items ?? this.items,
      initialItems: initialItems ?? this.initialItems,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      title: title ?? this.title,
      source: source ?? this.source,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      sort: sort ?? this.sort,
      filterResult: filterResult != null ? filterResult() : this.filterResult,
      activeFilterCount: activeFilterCount ?? this.activeFilterCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductsListingState &&
        listEquals(other.items, items) &&
        listEquals(other.initialItems, initialItems) &&
        other.isLoading == isLoading &&
        other.isLoadingMore == isLoadingMore &&
        other.hasMore == hasMore &&
        other.page == page &&
        other.title == title &&
        other.source == source &&
        other.errorMessage == errorMessage &&
        other.sort == sort &&
        other.filterResult == filterResult &&
        other.activeFilterCount == activeFilterCount;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(items),
        Object.hashAll(initialItems),
        isLoading,
        isLoadingMore,
        hasMore,
        page,
        title,
        source,
        errorMessage,
        sort,
        filterResult,
        activeFilterCount,
      );
}

