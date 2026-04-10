import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/utils/app_mock_content_utils.dart';
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
  late final TextEditingController shippingAddressCtrl;
  late final TextEditingController shippingCityCtrl;
  late final TextEditingController shippingPostcodeCtrl;

  /// متحكمات معلومات التواصل.
  late final TextEditingController contactPhoneCtrl;
  late final TextEditingController contactEmailCtrl;

  /// هل المستخدم الآن في شاشة الدفع؟
  bool get isPayment => step.value == CartStep.payment;

  @override
  void onInit() {
    super.onInit();

    shippingAddressCtrl = TextEditingController();
    shippingCityCtrl = TextEditingController();
    shippingPostcodeCtrl = TextEditingController();

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

  /// تحديث دولة عنوان الشحن داخل الـ model.
  void setShippingCountry({
    required ShippingAddress current,
    required String value,
    required void Function(ShippingAddress next) updateAddress,
  }) {
    updateAddress(
      current.copyWith(
        country: AppMockContentUtils.resolveCountryKey(value),
      ),
    );
  }

  /// تعبئة حقول النموذج النصية من قيمة عنوان الشحن الحالية.
  void fillShippingFormFromState(ShippingAddress address) {
    shippingAddressCtrl.text = address.address;
    shippingCityCtrl.text = address.city;
    shippingPostcodeCtrl.text = address.postcode;
  }

  /// تنظيف نموذج الشحن مع إبقاء الدولة الافتراضية إن وجدت.
  void clearShippingForm({
    required ShippingAddress current,
    required void Function(ShippingAddress next) updateAddress,
  }) {
    shippingAddressCtrl.clear();
    shippingCityCtrl.clear();
    shippingPostcodeCtrl.clear();

    updateAddress(
      current.copyWith(
        country: current.country.isEmpty
            ? AppMockContentUtils.resolveCountryKey(null)
            : AppMockContentUtils.resolveCountryKey(current.country),
      ),
    );
  }

  /// تجهيز النموذج لإضافة عنوان جديد.
  void prepareAddShipping({
    required void Function(ShippingAddress next) updateAddress,
  }) {
    updateAddress(ShippingAddress.empty());

    clearShippingForm(
      current: ShippingAddress.empty(),
      updateAddress: updateAddress,
    );
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
      country: current.country,
      address: shippingAddressCtrl.text.trim(),
      city: shippingCityCtrl.text.trim(),
      postcode: shippingPostcodeCtrl.text.trim(),
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
    shippingAddressCtrl.dispose();
    shippingCityCtrl.dispose();
    shippingPostcodeCtrl.dispose();
    contactPhoneCtrl.dispose();
    contactEmailCtrl.dispose();
    super.onClose();
  }
}

/// enum يحدد المرحلة الحالية داخل منظومة السلة والدفع.
enum CartStep { cart, payment }

