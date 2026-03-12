import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/products_listing/products_listing_service.dart';
import 'package:rwnaqk/controllers/products_listing/products_listing_ui_controller.dart';
import 'package:rwnaqk/core/utils/app_filter_utils.dart';
import 'package:rwnaqk/models/home_product_item.dart';
import 'package:rwnaqk/widgets/app_filter_sheet.dart';

/// هذا الملف هو الكنترولر الرئيسي لشاشة عرض المنتجات.
/// نستخدمه لإدارة بيانات الشاشة الأساسية مثل:
/// - عنوان الصفحة
/// - مصدر البيانات
/// - العناصر المعروضة
/// - حالات التحميل والخطأ
/// - التحميل الإضافي
///
/// كما أنه يعمل كحلقة ربط بين:
/// - ProductsListingService الخاص بالبيانات
/// - ProductsListingUiController الخاص بحالات الواجهة
class ProductsListingController extends GetxController {
  ProductsListingController(this._service);

  final ProductsListingService _service;

  late final ProductsListingUiController ui;

  /// عنوان الصفحة الظاهر أعلى الشاشة.
  final title = 'Products'.obs;

  /// مصدر البيانات الحالي، مثل categories أو flash sale أو غيرها.
  final source = 'generic'.obs;

  /// العناصر القادمة من الشاشة السابقة.
  final initialItems = <HomeProductItem>[].obs;

  /// العناصر المعروضة فعليًا داخل الشبكة.
  final items = <HomeProductItem>[].obs;

  /// حالة تحميل القائمة الرئيسية.
  final isLoading = false.obs;

  /// حالة تحميل المزيد عند الوصول لنهاية القائمة.
  final isLoadingMore = false.obs;

  /// هل يوجد المزيد من العناصر أم لا.
  final hasMore = true.obs;

  /// رسالة الخطأ الحالية إن وجدت.
  final errorMessage = RxnString();

  /// هذا bridge لإبقاء الاستدعاءات الحالية في الشاشة والودجت كما هي.
  Rx<ListingSort> get sort => ui.sort;

  /// هذا bridge لإبقاء الاستدعاءات الحالية في الشاشة والودجت كما هي.
  Rxn<AppFilterResult> get filterResult => ui.filterResult;

  /// هذا bridge لإبقاء الاستدعاءات الحالية في الشاشة والودجت كما هي.
  RxInt get activeFilterCount => ui.activeFilterCount;

  /// هذا bridge لإبقاء الاستدعاءات الحالية في الشاشة والودجت كما هي.
  ScrollController get scrollController => ui.scrollController;

  @override
  /// هذه الدالة تُستدعى عند إنشاء الكنترولر لأول مرة.
  /// نستخدمها لقراءة البيانات القادمة من route arguments
  /// وتحميل القائمة لأول مرة وربط مراقب السكرول.
  void onInit() {
    super.onInit();

    ui = Get.find<ProductsListingUiController>();

    _readArguments(Get.arguments);
    refreshList();

    scrollController.addListener(_onScroll);
  }

  /// هذه الدالة تقرأ البيانات القادمة من الصفحة السابقة،
  /// مثل عنوان الصفحة، مصدر العناصر، والعناصر الأولية نفسها.
  void _readArguments(dynamic args) {
    final map = args is Map ? args : {};

    final t = map['title'];
    if (t is String) title.value = t;

    final s = map['source'];
    if (s is String) source.value = s;

    final raw = map['items'];
    initialItems.assignAll(_service.resolveItems(raw));
  }

  /// هذه الدالة تقوم بإعادة بناء القائمة المعروضة من جديد.
  /// نستخدمها في أول تحميل، وعند تغيير الفلاتر، وعند إعادة المحاولة بعد الخطأ.
  Future<void> refreshList() async {
    errorMessage.value = null;
    isLoading.value = true;

    try {
      final base = initialItems.isNotEmpty
          ? initialItems.toList()
          : _service.mockProducts();

      final sorted = _service.applySort(
        list: base,
        sort: sort.value,
      );

      final filtered = _service.applyFilters(
        list: sorted,
        filterResult: filterResult.value,
      );

      items.assignAll(filtered);
      hasMore.value = true;
    } catch (_) {
      errorMessage.value = 'Something went wrong';
    } finally {
      isLoading.value = false;
    }
  }

  /// هذه الدالة تقوم بتحميل المزيد من العناصر عند وصول المستخدم
  /// إلى نهاية القائمة تقريبًا.
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value || isLoading.value) return;

    isLoadingMore.value = true;

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final more = _service.mockProducts(seed: items.length + 1);

      if (more.isEmpty) {
        hasMore.value = false;
      } else {
        final merged = [...items, ...more];

        final sorted = _service.applySort(
          list: merged,
          sort: sort.value,
        );

        final filtered = _service.applyFilters(
          list: sorted,
          filterResult: filterResult.value,
        );

        items.assignAll(filtered);
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// هذه الدالة تراقب موضع السكرول،
  /// وعند الاقتراب من نهاية القائمة تقوم بطلب تحميل المزيد.
  void _onScroll() {
    if (!scrollController.hasClients) return;

    final pos = scrollController.position;

    if (pos.pixels >= pos.maxScrollExtent - 300) {
      loadMore();
    }
  }

  /// هذه الدالة تفتح نافذة الفلاتر السفلية،
  /// ثم تحفظ النتيجة وتعيد تحديث القائمة بعد تطبيق الفلاتر.
  Future<void> openFilters() async {
    final result = await Get.bottomSheet<AppFilterResult>(
      AppFilterSheet(initial: filterResult.value),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    if (result == null) return;

    ui.setFilterResult(
      result: result,
      count: AppFilterUtils.countActive(result),
    );

    refreshList();
  }

  /// هذه الدالة تقوم بتغيير نوع الترتيب الحالي،
  /// ثم تعيد تطبيق الترتيب والفلاتر مباشرة على العناصر المعروضة.
  void setSort(ListingSort value) {
    ui.setSort(value);

    final sorted = _service.applySort(
      list: items.toList(),
      sort: sort.value,
    );

    final filtered = _service.applyFilters(
      list: sorted,
      filterResult: filterResult.value,
    );

    items.assignAll(filtered);
  }
}