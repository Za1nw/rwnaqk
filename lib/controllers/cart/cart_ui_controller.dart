import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/models/contact_info_model.dart';
import 'package:rwnaqk/models/shipping_address.dart';

/// هذا الملف مسؤول عن حالات الواجهة الخاصة بمنظومة السلة.
///
/// الهدف أن يبقى `CartController` مسؤولاً عن بيانات السلة والمنطق العام،
/// بينما تفاصيل الواجهة والتفاعل المحلي تكون هنا.
class CartUiController extends GetxController {
  /// الخطوة الحالية في تدفق السلة/الدفع.
  final step = CartStep.cart.obs;

  /// معرف خيار الشحن المختار حالياً.
  final selectedShippingId = 'standard'.obs;

  /// متحكمات نموذج عنوان الشحن.
  late final TextEditingController shippingGovernorateCtrl;
  late final TextEditingController shippingDistrictCtrl;
  late final TextEditingController shippingStreetCtrl;
  late final TextEditingController shippingAddressDetailsCtrl;

  /// متحكمات معلومات التواصل.
  late final TextEditingController contactPhoneCtrl;
  late final TextEditingController contactEmailCtrl;

  /// هل المستخدم الآن في شاشة الدفع؟
  bool get isPayment => step.value == CartStep.payment;

  @override
  void onInit() {
    super.onInit();

    shippingGovernorateCtrl = TextEditingController();
    shippingDistrictCtrl = TextEditingController();
    shippingStreetCtrl = TextEditingController();
    shippingAddressDetailsCtrl = TextEditingController();

    contactPhoneCtrl = TextEditingController();
    contactEmailCtrl = TextEditingController();
  }

  /// فتح شاشة الدفع.
  void openPayment() {
    step.value = CartStep.payment;
    Get.toNamed(AppRoutes.payment);
  }

  /// الرجوع إلى شاشة السلة.
  void backToCart() {
    step.value = CartStep.cart;

    if (Get.currentRoute == AppRoutes.payment &&
        (Get.key.currentState?.canPop() ?? false)) {
      Get.back();
    }
  }

  /// إعادة الحالة المنطقية إلى السلة بعد إتمام الطلب.
  void completeCheckout() {
    step.value = CartStep.cart;
  }

  /// تغيير خيار الشحن الحالي.
  void setShipping(String id) {
    selectedShippingId.value = id;
  }

  /// تعبئة حقول النموذج النصية من قيمة عنوان الشحن الحالية.
  void fillShippingFormFromState(ShippingAddress address) {
    shippingGovernorateCtrl.text = address.governorate;
    shippingDistrictCtrl.text = address.district;
    shippingStreetCtrl.text = address.street;
    shippingAddressDetailsCtrl.text = address.addressDetails;
  }

  /// تنظيف نموذج الشحن.
  void clearShippingForm() {
    shippingGovernorateCtrl.clear();
    shippingDistrictCtrl.clear();
    shippingStreetCtrl.clear();
    shippingAddressDetailsCtrl.clear();
  }

  /// تجهيز النموذج لإضافة عنوان جديد.
  void prepareAddShipping({
    required void Function(ShippingAddress next) updateAddress,
  }) {
    updateAddress(ShippingAddress.empty());
    clearShippingForm();
  }

  /// تجهيز النموذج لتعديل عنوان موجود.
  void prepareEditShipping(ShippingAddress address) {
    fillShippingFormFromState(address);
  }

  /// بناء عنوان شحن جاهز من حقول النموذج.
  ShippingAddress buildShippingFromForm({
    required ShippingAddress current,
  }) {
    return ShippingAddress(
      id: current.id,
      governorate: shippingGovernorateCtrl.text.trim(),
      district: shippingDistrictCtrl.text.trim(),
      street: shippingStreetCtrl.text.trim(),
      addressDetails: shippingAddressDetailsCtrl.text.trim(),
      isDefault: current.isDefault,
    );
  }

  /// تعبئة نموذج التواصل من الحالة الحالية.
  void fillContactFormFromState(ContactInfoModel info) {
    contactPhoneCtrl.text = info.phone;
    contactEmailCtrl.text = info.email;
  }

  /// تجهيز نموذج التواصل للتعديل.
  void prepareEditContact(ContactInfoModel info) {
    fillContactFormFromState(info);
  }

  /// بناء بيانات التواصل من حقول النموذج الحالية.
  ContactInfoModel buildContactFromForm({
    required ContactInfoModel current,
  }) {
    return current.copyWith(
      phone: contactPhoneCtrl.text.trim(),
      email: contactEmailCtrl.text.trim(),
    );
  }

  @override
  void onClose() {
    shippingGovernorateCtrl.dispose();
    shippingDistrictCtrl.dispose();
    shippingStreetCtrl.dispose();
    shippingAddressDetailsCtrl.dispose();
    contactPhoneCtrl.dispose();
    contactEmailCtrl.dispose();
    super.onClose();
  }
}

/// enum يحدد المرحلة الحالية داخل منظومة السلة والدفع.
enum CartStep { cart, payment }
