import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/widgets/app_filter_sheet.dart';

import '../models/home_product_item.dart';

class SearchResultsController extends GetxController {
  final searchC = TextEditingController();

  final query = ''.obs;

  // UI states
  final isLoading = false.obs;

  // data
  final results = <HomeProductItem>[].obs;

  // filters count (badge)
  final activeFilters = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // dummy data
    results.assignAll(_sampleProducts(12));
  }

  void onChanged(String v) {
    query.value = v;
    // لاحقاً: debounce + API
  }

  void onSubmitted(String v) {
    query.value = v;
    // لاحقاً: API call
  }

  void clearQuery() {
    searchC.clear();
    query.value = '';
  }

  void openCamera() {
    Get.snackbar('Camera', 'Pressed');
  }

  void openFilters() {
    Get.bottomSheet(
      const AppFilterSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void openProduct(HomeProductItem item) {
    final isSale = (item.discountPercent ?? 0) > 0;
    Get.toNamed(
      AppRoutes.product,
      arguments: {'item': item, 'forceSale': isSale},
    );
  }

  List<HomeProductItem> _sampleProducts(int n) {
    return List.generate(n, (i) {
      final id = 'r_$i';
      return HomeProductItem(
        id: id,
        title: 'Item $id',
        imageUrl: 'https://picsum.photos/400/500?$id',
        price: 17,
        discountPercent: null,
        isNew: i % 3 == 0,
        tagKey: '',
      );
    });
  }

  @override
  void onClose() {
    searchC.dispose();
    super.onClose();
  }
}
