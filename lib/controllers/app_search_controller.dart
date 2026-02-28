import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/home_product_item.dart';

class AppSearchController extends GetxController {
  final searchC = TextEditingController();
  final query = ''.obs;

  final history = <String>[].obs;
  final recommendations = <String>[].obs;

  final discover = <HomeProductItem>[].obs;
  final results = <HomeProductItem>[].obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();

    // ✅ بيانات تجريبية مثل الصورة
    history.assignAll(['Socks', 'Red Dress', 'Sunglasses', 'Mustard Pants', '80-s Skirt']);
    recommendations.assignAll(['Skirt', 'Accessories', 'Black T-Shirt', 'Jeans', 'White Shoes']);

    discover.assignAll(_sampleProducts(10, seed: 900));
  }

  void onChanged(String v) {
    query.value = v;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      _runSearch(v);
    });
  }

  void onSubmitted(String v) {
    final q = v.trim();
    if (q.isEmpty) return;
    _commitToHistory(q);
    _runSearch(q);
  }

  void onTapChip(String text) {
    searchC.text = text;
    searchC.selection = TextSelection.collapsed(offset: text.length);
    query.value = text;
    _commitToHistory(text);
    _runSearch(text);
  }

  void clearHistory() => history.clear();

  void openCamera() {
    // لاحقاً: بحث بالصورة
    Get.snackbar('Camera', 'Not implemented yet');
  }

  void _commitToHistory(String q) {
    final t = q.trim();
    if (t.isEmpty) return;

    history.removeWhere((e) => e.toLowerCase() == t.toLowerCase());
    history.insert(0, t);

    if (history.length > 10) {
      history.removeRange(10, history.length);
    }
  }

  void _runSearch(String raw) {
    final q = raw.trim().toLowerCase();
    if (q.isEmpty) {
      results.clear();
      return;
    }

    // هنا demo: نفلتر من discover فقط
    results.assignAll(
      discover.where((p) => p.title.toLowerCase().contains(q)).toList(),
    );
  }

  List<HomeProductItem> _sampleProducts(int n, {required int seed}) {
    return List.generate(n, (i) {
      final id = '${seed}_$i';
      return HomeProductItem(
        id: id,
        title: 'Item $id',
        imageUrl: 'https://picsum.photos/400/500?$id',
        price: 12 + (i * 5).toDouble(),
        discountPercent: i % 4 == 0 ? 15 : null,
        isNew: i % 3 == 0,
        tagKey: '',
      );
    });
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchC.dispose();
    super.onClose();
  }
}