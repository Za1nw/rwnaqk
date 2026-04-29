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
  /// متحكم حقل المحافظة.
  final governorateCtrl = TextEditingController();

  /// متحكم حقل المديرية.
  final districtCtrl = TextEditingController();

  /// متحكم حقل الشارع.
  final streetCtrl = TextEditingController();

  /// متحكم حقل العنوان التفصيلي.
  final addressDetailsCtrl = TextEditingController();

  /// معرّف العنوان الجاري تعديله.
  /// إذا كانت القيمة null فهذا يعني أننا في وضع الإضافة.
  String? editingId;

  /// هذه الدالة تنظف النموذج وتجهزه لإضافة عنوان جديد.
  void openAddSheet() {
    editingId = null;
    clearForm();
  }

  /// هذه الدالة تعبئ الحقول ببيانات عنوان موجود
  /// وتجهز النموذج لوضع التعديل.
  void openEditSheet(ShippingAddress item) {
    editingId = item.id;
    governorateCtrl.text = item.governorate;
    districtCtrl.text = item.district;
    streetCtrl.text = item.street;
    addressDetailsCtrl.text = item.addressDetails;
  }

  /// هذه الدالة تنظف حقول النموذج بالكامل.
  void clearForm() {
    governorateCtrl.clear();
    districtCtrl.clear();
    streetCtrl.clear();
    addressDetailsCtrl.clear();
  }

  /// هذه الدالة تبني عنوانًا جديدًا من بيانات النموذج الحالية.
  ShippingAddress buildAddressFromForm({
    required String id,
    required bool isDefault,
  }) {
    return ShippingAddress(
      id: id,
      governorate: governorateCtrl.text.trim(),
      district: districtCtrl.text.trim(),
      street: streetCtrl.text.trim(),
      addressDetails: addressDetailsCtrl.text.trim(),
      isDefault: isDefault,
    );
  }

  @override

  /// هذه الدالة تُستدعى عند التخلص من الكنترولر.
  /// نستخدمها لتحرير متحكمات الحقول.
  void onClose() {
    governorateCtrl.dispose();
    districtCtrl.dispose();
    streetCtrl.dispose();
    addressDetailsCtrl.dispose();
    super.onClose();
  }
}
