import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/shipping_address.dart';

class AddressesController extends GetxController {
  // ====== Mock countries
  final countries = <String>[
    'Yemen',
    'Saudi Arabia',
    'UAE',
    'Egypt',
  ];

  // ====== Form controllers (نستخدم نفس الكنترولرات مع الشيت)
  final addressCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final postcodeCtrl = TextEditingController();

  final country = RxnString();

  // ====== Addresses list
  final addresses = <ShippingAddress>[].obs;

  // ====== editing state
  String? _editingId;

  @override
  void onInit() {
    super.onInit();

    // seed demo
    addresses.assignAll([
      ShippingAddress(
        id: '1',
        country: 'Yemen',
        address: 'Street 10, near the mall',
        city: 'Taiz',
        postcode: '12345',
        isDefault: true,
      ),
      ShippingAddress(
        id: '2',
        country: 'Saudi Arabia',
        address: 'King Road 22',
        city: 'Riyadh',
        postcode: '65432',
      ),
    ]);
  }

  @override
  void onClose() {
    addressCtrl.dispose();
    cityCtrl.dispose();
    postcodeCtrl.dispose();
    super.onClose();
  }

  // =========================
  // UI actions
  // =========================

  void setCountry(String? v) => country.value = v;

  void openAddSheet(BuildContext context) {
    _editingId = null;
    addressCtrl.text = '';
    cityCtrl.text = '';
    postcodeCtrl.text = '';
    country.value = null;

    // ✅ تستدعي الشيت الجاهز
    // ملاحظة: استدعاء الشيت من الشاشة نفسه أفضل (عشان imports)،
    // لكن هنا تمام إذا تحب.
  }

  void openEditSheet(ShippingAddress item) {
    _editingId = item.id;
    addressCtrl.text = item.address;
    cityCtrl.text = item.city;
    postcodeCtrl.text = item.postcode;
    country.value = item.country;
  }

  void saveFromSheet() {
    final c = (country.value ?? '').trim();
    final a = addressCtrl.text.trim();
    final city = cityCtrl.text.trim();
    final p = postcodeCtrl.text.trim();

    if (c.isEmpty || a.isEmpty || city.isEmpty || p.isEmpty) {
      Get.snackbar('Error'.tr, 'Please fill all fields'.tr);
      return;
    }

    if (_editingId == null) {
      final hasDefault = addresses.any((e) => e.isDefault);

      final newItem = ShippingAddress(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        country: c,
        address: a,
        city: city,
        postcode: p,
        isDefault: !hasDefault, // أول عنوان يصير افتراضي تلقائيًا
      );

      addresses.add(newItem);
    } else {
      final idx = addresses.indexWhere((e) => e.id == _editingId);
      if (idx != -1) {
        addresses[idx] = addresses[idx].copyWith(
          country: c,
          address: a,
          city: city,
          postcode: p,
        );
      }
    }

    Get.back(); // يقفل الشيت
  }

  void setDefault(String id) {
    final list = addresses.toList();
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(isDefault: list[i].id == id);
    }
    addresses.assignAll(list);
  }

  void deleteAddress(String id) {
    final wasDefault = addresses.firstWhereOrNull((e) => e.id == id)?.isDefault ?? false;

    addresses.removeWhere((e) => e.id == id);

    // لو حذفنا الافتراضي، خلّ أول واحد افتراضي
    if (wasDefault && addresses.isNotEmpty) {
      setDefault(addresses.first.id);
    }
  }
}