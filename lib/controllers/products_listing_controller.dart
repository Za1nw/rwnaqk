import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/models/home_product_item.dart';
import 'package:rwnaqk/core/utils/app_filter_utils.dart';
// عدّل المسار إذا كان مختلف
import 'package:rwnaqk/widgets/app_filter_sheet.dart';

enum ListingSort { newest, priceLow, priceHigh, discountHigh }

class ProductsListingController extends GetxController {
  /// عنوان الصفحة
  final title = 'Products'.obs;

  /// مصدر البيانات
  final source = 'generic'.obs;

  /// المنتجات القادمة من الصفحة السابقة
  final initialItems = <HomeProductItem>[].obs;

  /// المنتجات المعروضة
  final items = <HomeProductItem>[].obs;

  /// loading states
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;

  /// error
  final errorMessage = RxnString();

  /// scroll
  final scrollController = ScrollController();

  /// sort
  final sort = ListingSort.newest.obs;

  /// filter result
  final filterResult = Rxn<AppFilterResult>();

  /// عدد الفلاتر
  final activeFilterCount = 0.obs;

  @override
  void onInit() {
    super.onInit();

    _readArguments(Get.arguments);

    refreshList();

    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  /// قراءة البيانات القادمة من Home
  void _readArguments(dynamic args) {
    final map = args is Map ? args : {};

    final t = map['title'];
    if (t is String) title.value = t;

    final s = map['source'];
    if (s is String) source.value = s;

    final raw = map['items'];
    initialItems.assignAll(_resolveItems(raw));
  }

  List<HomeProductItem> _resolveItems(dynamic raw) {
    if (raw is List<HomeProductItem>) return raw;
    if (raw is List) return raw.whereType<HomeProductItem>().toList();
    return [];
  }

  /// تحديث القائمة
  Future<void> refreshList() async {
    errorMessage.value = null;

    isLoading.value = true;

    try {
      final base = initialItems.isNotEmpty
          ? initialItems.toList()
          : _mockProducts();

      final sorted = _applySort(base);

      final filtered = _applyFilters(sorted);

      items.assignAll(filtered);

      hasMore.value = true;
    } catch (_) {
      errorMessage.value = 'Something went wrong';
    } finally {
      isLoading.value = false;
    }
  }

  /// تحميل المزيد
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value || isLoading.value) return;

    isLoadingMore.value = true;

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final more = _mockProducts(seed: items.length + 1);

      if (more.isEmpty) {
        hasMore.value = false;
      } else {
        final merged = [...items, ...more];

        final sorted = _applySort(merged);

        final filtered = _applyFilters(sorted);

        items.assignAll(filtered);
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// pagination trigger
  void _onScroll() {
    if (!scrollController.hasClients) return;

    final pos = scrollController.position;

    if (pos.pixels >= pos.maxScrollExtent - 300) {
      loadMore();
    }
  }

  /// فتح الفلاتر
  Future<void> openFilters() async {
    final result = await Get.bottomSheet<AppFilterResult>(
      AppFilterSheet(initial: filterResult.value),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    if (result == null) return;

    filterResult.value = result;

    activeFilterCount.value = AppFilterUtils.countActive(result);
    refreshList();
  }

  /// تغيير الترتيب
  void setSort(ListingSort v) {
    sort.value = v;

    final sorted = _applySort(items.toList());

    final filtered = _applyFilters(sorted);

    items.assignAll(filtered);
  }

  /// تطبيق الفرز
  List<HomeProductItem> _applySort(List<HomeProductItem> list) {
    final out = list.toList();

    switch (sort.value) {
      case ListingSort.newest:
        return out;

      case ListingSort.priceLow:
        out.sort((a, b) => a.price.compareTo(b.price));
        return out;

      case ListingSort.priceHigh:
        out.sort((a, b) => b.price.compareTo(a.price));
        return out;

      case ListingSort.discountHigh:
        out.sort(
          (a, b) => (b.discountPercent ?? 0).compareTo(a.discountPercent ?? 0),
        );
        return out;
    }
  }

  /// تطبيق الفلاتر
  List<HomeProductItem> _applyFilters(List<HomeProductItem> list) {
    final f = filterResult.value;

    if (f == null) return list;

    final min = f.priceRange.start;
    final max = f.priceRange.end;

    return list.where((p) {
      if (p.price < min) return false;

      if (p.price > max) return false;

      return true;
    }).toList();
  }

  /// حساب عدد الفلاتر

  /// بيانات تجريبية
  List<HomeProductItem> _mockProducts({int seed = 1}) {
    return List.generate(10, (i) {
      final id = (seed * 1000 + i).toString();

      final discount = (i % 4 == 0) ? 20 : (i % 7 == 0 ? 35 : 0);

      return HomeProductItem(
        id: id,
        title: 'Product $id',
        imageUrl: 'https://picsum.photos/400/520?listing=$id',
        price: 12 + (i * 4).toDouble(),
        discountPercent: discount == 0 ? null : discount,
      );
    });
  }
}
