import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/models/shipping_address.dart';

/// هذا الملف مسؤول عن حالات الواجهة الخاصة بشاشة العناوين.
///
/// نستخدمه لعزل:
/// - متحكمات الحقول
/// - الدولة المختارة
/// - حالة التعديل الحالية
///
/// الهدف أن يبقى الكنترولر الرئيسي مسؤولًا عن قائمة العناوين
/// والعمليات الأساسية، بينما تبقى تفاصيل الفورم هنا.
class AddressesUiController extends GetxController {
  /// متحكم حقل العنوان.
  final addressCtrl = TextEditingController();

  /// متحكم حقل المدينة.
  final cityCtrl = TextEditingController();

  /// متحكم حقل الرمز البريدي.
  final postcodeCtrl = TextEditingController();

  /// الدولة المختارة حاليًا في النموذج.
  final country = RxnString();

  /// معرّف العنوان الجاري تعديله.
  /// إذا كانت القيمة null فهذا يعني أننا في وضع الإضافة.
  String? editingId;

  /// هذه الدالة تغيّر الدولة المختارة في النموذج.
  void setCountry(String? value) {
    country.value = value;
  }

  /// هذه الدالة تنظف النموذج وتجهزه لإضافة عنوان جديد.
  void openAddSheet() {
    editingId = null;
    clearForm();
  }

  /// هذه الدالة تعبئ الحقول ببيانات عنوان موجود
  /// وتجهز النموذج لوضع التعديل.
  void openEditSheet(ShippingAddress item) {
    editingId = item.id;
    addressCtrl.text = item.address;
    cityCtrl.text = item.city;
    postcodeCtrl.text = item.postcode;
    country.value = item.country;
  }

  /// هذه الدالة تنظف حقول النموذج بالكامل.
  void clearForm() {
    addressCtrl.clear();
    cityCtrl.clear();
    postcodeCtrl.clear();
    country.value = null;
  }

  /// هذه الدالة تبني عنوانًا جديدًا من بيانات النموذج الحالية.
  ShippingAddress buildAddressFromForm({
    required String id,
    required bool isDefault,
  }) {
    return ShippingAddress(
      id: id,
      country: (country.value ?? '').trim(),
      address: addressCtrl.text.trim(),
      city: cityCtrl.text.trim(),
      postcode: postcodeCtrl.text.trim(),
      isDefault: isDefault,
    );
  }

  @override
  /// هذه الدالة تُستدعى عند التخلص من الكنترولر.
  /// نستخدمها لتحرير متحكمات الحقول.
  void onClose() {
    addressCtrl.dispose();
    cityCtrl.dispose();
    postcodeCtrl.dispose();
    super.onClose();
  }
}