  import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/search/search_service.dart';
import 'package:rwnaqk/controllers/search/search_ui_controller.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/models/home_product_item.dart';
import 'package:rwnaqk/widgets/app_filter_sheet.dart';

/// هذا الملف هو الكنترولر الرئيسي لمنظومة البحث كاملة.
///
/// نستخدمه لإدارة:
/// - سجل البحث
/// - الاقتراحات
/// - منتجات Discover
/// - نتائج البحث
/// - حالة التحميل
/// - الفلاتر
/// - التنقل إلى صفحة النتائج أو المنتج
///
/// هذا الكنترولر يخدم:
/// - SearchScreen
/// - SearchResultsScreen
///
/// والهدف من ذلك هو جعل البحث كله يدار من مكان واحد
/// بدل تكرار المنطق في أكثر من كنترولر.
class AppSearchController extends GetxController {
  AppSearchController(this._service);

  final SearchService _service;

  late final SearchUiController ui;

  /// سجل البحث السابق.
  final history = <String>[].obs;

  /// الاقتراحات الجاهزة للبحث.
  final recommendations = <String>[].obs;

  /// المنتجات المقترحة في قسم Discover.
  final discover = <HomeProductItem>[].obs;

  /// نتائج البحث الحالية.
  final results = <HomeProductItem>[].obs;

  /// حالة التحميل الحالية.
  final isLoading = false.obs;

  /// عدد الفلاتر النشطة حاليًا.
  final activeFilters = 0.obs;

  Timer? _debounce;

  /// هذا bridge لإبقاء نفس أسلوب الاستدعاء في الشاشات.
  TextEditingController get searchC => ui.searchC;

  /// هذا bridge لإبقاء نفس أسلوب الاستدعاء في الشاشات.
  RxString get query => ui.query;

  @override
  /// هذه الدالة تُستدعى عند إنشاء الكنترولر لأول مرة.
  ///
  /// نستخدمها لتهيئة:
  /// - سجل البحث
  /// - الاقتراحات
  /// - discover
  void onInit() {
    super.onInit();

    ui = Get.find<SearchUiController>();

    history.assignAll(_service.initialHistory());
    recommendations.assignAll(_service.initialRecommendations());
    discover.assignAll(_service.sampleProducts(10, seed: 900));
  }

  /// هذه الدالة تُستدعى عند تغيير النص داخل حقل البحث.
  ///
  /// نستخدم debounce حتى لا يتم تشغيل البحث عند كل حرف مباشرة.
  void onChanged(String value) {
    ui.onChanged(value);

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      _runSearch(value);
    });
  }

  /// هذه الدالة تُستدعى عند تنفيذ البحث من لوحة المفاتيح.
  ///
  /// نستخدمها من:
  /// - شاشة البحث
  /// - شاشة نتائج البحث
  ///
  /// وإذا وُجد نص صحيح:
  /// - نضيفه إلى history
  /// - ننفذ البحث
  /// - ننتقل إلى شاشة النتائج إذا لم نكن فيها
  void onSubmitted(String value) {
    final q = value.trim();
    if (q.isEmpty) return;

    ui.onSubmitted(q);
    _commitToHistory(q);
    _runSearch(q);
    _openResultsScreenIfNeeded();
  }

  /// هذه الدالة تُستخدم عند الضغط على عنصر من history أو recommendations.
  ///
  /// تقوم بوضع النص في الحقل ثم تنفيذ البحث والانتقال إلى شاشة النتائج.
  void onTapChip(String text) {
    ui.setQueryText(text);
    _commitToHistory(text);
    _runSearch(text);
    _openResultsScreenIfNeeded();
  }

  /// هذه الدالة تمسح سجل البحث بالكامل.
  void clearHistory() {
    history.clear();
  }

  /// هذه الدالة تمسح النص الحالي وتفرغ نتائج البحث.
  void clearQuery() {
    ui.clearQuery();
    results.clear();
  }

  /// هذه الدالة مخصصة لفتح الكاميرا لاحقًا للبحث بالصورة.
  void openCamera() {
    Get.snackbar(Tk.commonCamera.tr, Tk.commonNotImplementedYet.tr);
  }

  /// هذه الدالة تفتح نافذة الفلاتر السفلية.
  ///
  /// حاليًا نحتفظ بها كما هي من مشروعك الحالي،
  /// ويمكن لاحقًا ربطها بمنطق فلترة فعلي.
  void openFilters() {
    Get.bottomSheet(
      const AppFilterSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// هذه الدالة تفتح صفحة المنتج عند الضغط على أي عنصر من النتائج.
  void openProduct(HomeProductItem item) {
    final isSale = (item.discountPercent ?? 0) > 0;

    Get.toNamed(
      AppRoutes.product,
      arguments: {
        'item': item,
        'forceSale': isSale,
      },
    );
  }

  /// هذه الدالة تضيف النص إلى سجل البحث بطريقة منظمة.
  void _commitToHistory(String value) {
    history.assignAll(
      _service.commitToHistory(
        currentHistory: history,
        query: value,
      ),
    );
  }

  /// هذه الدالة تنفذ البحث المحلي الحالي على منتجات discover.
  ///
  /// لاحقًا هذا هو المكان المناسب لاستبدال البحث المحلي بـ API.
  void _runSearch(String raw) {
    final filtered = _service.runLocalSearch(
      source: discover,
      rawQuery: raw,
    );

    results.assignAll(filtered);
  }

  /// هذه الدالة تفتح شاشة نتائج البحث فقط إذا لم تكن مفتوحة بالفعل.
  ///
  /// الهدف منها منع تكرار push لنفس الصفحة.
  void _openResultsScreenIfNeeded() {
    if (Get.currentRoute != AppRoutes.searchResults) {
      Get.toNamed(AppRoutes.searchResults);
    }
  }

  @override
  /// هذه الدالة تُستدعى عند التخلص من الكنترولر.
  /// نستخدمها لإلغاء الـ debounce.
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
