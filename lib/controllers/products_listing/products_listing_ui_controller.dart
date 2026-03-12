import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/products_listing/products_listing_service.dart';
import 'package:rwnaqk/widgets/app_filter_sheet.dart';

/// هذا الملف مسؤول عن حالات الواجهة فقط الخاصة بشاشة عرض المنتجات.
/// نستخدمه لعزل الحالات التفاعلية والبصرية عن الكنترولر الرئيسي،
/// مثل نوع الترتيب الحالي، نتيجة الفلترة، عدد الفلاتر النشطة، وحالة السكرول.
class ProductsListingUiController extends GetxController {
  /// نوع الترتيب الحالي المختار من المستخدم.
  final sort = ListingSort.newest.obs;

  /// نتيجة الفلاتر الحالية القادمة من Bottom Sheet.
  final filterResult = Rxn<AppFilterResult>();

  /// عدد الفلاتر المفعلة حاليًا لعرضه في الواجهة.
  final activeFilterCount = 0.obs;

  /// متحكم السكرول المستخدم لمراقبة نهاية القائمة وتشغيل التحميل الإضافي.
  final scrollController = ScrollController();

  /// هذه الدالة تقوم بتغيير نوع الترتيب الحالي.
  /// تُستخدم عند اختيار المستخدم خيارًا جديدًا من نافذة الترتيب.
  void setSort(ListingSort value) {
    sort.value = value;
  }

  /// هذه الدالة تقوم بحفظ نتيجة الفلاتر الجديدة
  /// وتحديث عدد الفلاتر النشطة لعرضها في الواجهة.
  void setFilterResult({
    required AppFilterResult result,
    required int count,
  }) {
    filterResult.value = result;
    activeFilterCount.value = count;
  }

  /// هذه الدالة تقوم بإعادة تعيين الفلاتر والقيم التابعة لها.
  /// تُستخدم إذا احتجنا مستقبلاً إلى مسح جميع الفلاتر.
  void clearFilters() {
    filterResult.value = null;
    activeFilterCount.value = 0;
  }

  @override
  /// هذه الدالة تُستدعى عند التخلص من الكنترولر.
  /// نستخدمها لتحرير ScrollController حتى لا يحدث تسريب في الذاكرة.
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}