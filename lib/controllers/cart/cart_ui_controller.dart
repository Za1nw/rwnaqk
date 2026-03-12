import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/models/shipping_address_model.dart';

/// هذا الملف مسؤول عن حالات الواجهة الخاصة بمنظومة السلة والدفع.
///
/// نستخدمه لعزل:
/// - حالة الخطوة الحالية
/// - اختيارات الشحن
/// - اختيارات الدفع
/// - حقول النماذج
///
/// الهدف أن يبقى الكنترولر الرئيسي مسؤولًا عن بيانات السلة والمنطق العام،
/// بينما تبقى تفاصيل الواجهة والتفاعل المحلي هنا.
class CartUiController extends GetxController {
  /// الخطوة الحالية في تدفق السلة/الدفع.
  final step = CartStep.cart.obs;

  /// معرّف خيار الشحن المختار حاليًا.
  final selectedShippingId = 'standard'.obs;

  /// معرّف طريقة الدفع الحالية.
  final paymentMethodId = 'cod'.obs;

  /// اسم المستلم المستخدم عند الدفع بالمحفظة.
  final receiverName = 'Zain'.obs;

  /// رقم المحفظة المستخدم عند الدفع بالمحفظة.
  final walletNumber = '777123456'.obs;

  /// متحكم حقل عنوان الشحن.
  late final TextEditingController shippingAddressCtrl;

  /// متحكم حقل المدينة.
  late final TextEditingController shippingCityCtrl;

  /// متحكم حقل الرمز البريدي.
  late final TextEditingController shippingPostcodeCtrl;

  /// هل المستخدم الآن في شاشة الدفع؟
  bool get isPayment => step.value == CartStep.payment;

  /// هل طريقة الدفع الحالية هي محفظة؟
  bool get isWalletPayment => paymentMethodId.value == 'wallet';

  @override
  /// هذه الدالة تُستدعى عند إنشاء الكنترولر.
  /// نستخدمها لتهيئة متحكمات حقول العنوان.
  void onInit() {
    super.onInit();

    shippingAddressCtrl = TextEditingController();
    shippingCityCtrl = TextEditingController();
    shippingPostcodeCtrl = TextEditingController();
  }

  /// هذه الدالة تفتح شاشة الدفع.
  /// نستخدمها عند الضغط على زر المتابعة من السلة.
  void openPayment() {
    step.value = CartStep.payment;
    Get.toNamed('/payment');
  }

  /// هذه الدالة تعيد الحالة إلى شاشة السلة.
  void backToCart() {
    step.value = CartStep.cart;
  }

  /// هذه الدالة تغيّر خيار الشحن الحالي.
  void setShipping(String id) {
    selectedShippingId.value = id;
  }

  /// هذه الدالة تغيّر طريقة الدفع الحالية.
  void setPaymentMethodId(String id) {
    paymentMethodId.value = id;
  }

  /// هذه الدالة تحدّث اسم المستلم.
  void setReceiverName(String value) {
    receiverName.value = value;
  }

  /// هذه الدالة تحدّث رقم المحفظة.
  void setWalletNumber(String value) {
    walletNumber.value = value;
  }

  /// هذه الدالة تحدّث دولة عنوان الشحن داخل الـ model.
  void setShippingCountry({
    required ShippingAddressModel current,
    required String value,
    required void Function(ShippingAddressModel next) updateAddress,
  }) {
    updateAddress(current.copyWith(country: value));
  }

  /// هذه الدالة تعبئ الحقول النصية من قيمة عنوان الشحن الحالية.
  void fillShippingFormFromState(ShippingAddressModel address) {
    shippingAddressCtrl.text = address.addressLine;
    shippingCityCtrl.text = address.city;
    shippingPostcodeCtrl.text = address.postcode;
  }

  /// هذه الدالة تنظف نموذج الشحن وتبقي الدولة الافتراضية إن وُجدت.
  void clearShippingForm({
    required ShippingAddressModel current,
    required void Function(ShippingAddressModel next) updateAddress,
  }) {
    shippingAddressCtrl.clear();
    shippingCityCtrl.clear();
    shippingPostcodeCtrl.clear();

    updateAddress(
      current.copyWith(
        country: current.country.isEmpty ? 'Yemen' : current.country,
      ),
    );
  }

  /// هذه الدالة تجهز النموذج لإضافة عنوان جديد.
  void prepareAddShipping({
    required void Function(ShippingAddressModel next) updateAddress,
  }) {
    updateAddress(ShippingAddressModel.empty());

    clearShippingForm(
      current: ShippingAddressModel.empty(),
      updateAddress: updateAddress,
    );
  }

  /// هذه الدالة تجهز النموذج لتعديل عنوان موجود.
  void prepareEditShipping(ShippingAddressModel address) {
    fillShippingFormFromState(address);
  }

  /// هذه الدالة تحفظ بيانات النموذج وتعيد عنوان شحن جاهز.
  ShippingAddressModel buildShippingFromForm({
    required ShippingAddressModel current,
  }) {
    return ShippingAddressModel(
      country: current.country,
      addressLine: shippingAddressCtrl.text.trim(),
      city: shippingCityCtrl.text.trim(),
      postcode: shippingPostcodeCtrl.text.trim(),
    );
  }

  @override
  /// هذه الدالة تُستدعى عند التخلص من الكنترولر.
  /// نستخدمها لتحرير TextEditingController.
  void onClose() {
    shippingAddressCtrl.dispose();
    shippingCityCtrl.dispose();
    shippingPostcodeCtrl.dispose();
    super.onClose();
  }
}

/// هذا الـ enum يحدد المرحلة الحالية داخل منظومة السلة والدفع.
enum CartStep { cart, payment }