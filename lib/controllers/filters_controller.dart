import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FiltersController extends GetxController {
  // Categories (IDs أو names)
  final categories = <String>[
    'Dresses','Pants','Skirts','Shorts','Jackets',
    'Hoodies','Shirts','Polo','T-shirts','Tunics',
  ];

  final selectedCategories = <String>{}.obs;

  // Tabs: Clothes / Shoes
  final segment = 'Clothes'.obs;

  // Sizes
  final sizes = <String>['XS', 'S', 'M', 'L', 'XL', '2XL'];
  final selectedSize = ''.obs; // single select

  // Colors (as int to be stable)
  final colors = <int>[
    0xFF111827, // black
    0xFF6B7280, // gray
    0xFF2563EB, // blue
    0xFFDC2626, // red
    0xFF06B6D4, // cyan
    0xFFF59E0B, // orange
    0xFF8B5CF6, // purple
  ];
  final selectedColor = 0.obs; // store index, 0 = none
  final hasColor = false.obs;

  // Price range
  final minPrice = 10.0.obs;
  final maxPrice = 150.0.obs;
  final range = const RangeValues(10, 150).obs;

  // Sort
  final sort = 'Popular'.obs; // Popular / Newest / HighToLow / LowToHigh

  int get activeCount {
    int count = 0;
    if (selectedCategories.isNotEmpty) count++;
    if (selectedSize.value.isNotEmpty) count++;
    if (hasColor.value) count++;
    if (range.value.start != minPrice.value || range.value.end != maxPrice.value) count++;
    if (sort.value != 'Popular') count++;
    if (segment.value != 'Clothes') count++;
    return count;
  }

  void toggleCategory(String c) {
    final s = selectedCategories;
    if (s.contains(c)) {
      s.remove(c);
    } else {
      s.add(c);
    }
  }

  void setSize(String s) => selectedSize.value = s;

  void setSegment(String v) => segment.value = v;

  void setColorIndex(int idx) {
    selectedColor.value = idx;
    hasColor.value = true;
  }

  void clearColor() {
    hasColor.value = false;
    selectedColor.value = 0;
  }

  void setRange(RangeValues v) => range.value = v;

  void setSort(String v) => sort.value = v;

  void clearAll() {
    selectedCategories.clear();
    selectedSize.value = '';
    clearColor();
    range.value = RangeValues(minPrice.value, maxPrice.value);
    sort.value = 'Popular';
    segment.value = 'Clothes';
  }
}