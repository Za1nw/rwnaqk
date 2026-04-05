import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeUiController extends GetxController {
  final bannerIndex = 0.obs;

  final searchC = TextEditingController();
  final query = ''.obs;

  void onBannerChanged(int index) {
    bannerIndex.value = index;
  }

  void onSearchChanged(String value) {
    query.value = value;
  }

  void clearSearch() {
    searchC.clear();
    query.value = '';
  }

  @override
  void onClose() {
    searchC.dispose();
    super.onClose();
  }
}