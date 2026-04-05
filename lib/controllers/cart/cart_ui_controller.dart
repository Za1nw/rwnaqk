import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/utils/app_mock_content_utils.dart';
import 'package:rwnaqk/models/contact_info_model.dart';
import 'package:rwnaqk/models/shipping_address.dart';

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

  /// متحكمات معلومات التواصل.
  late final TextEditingController contactPhoneCtrl;
  late final TextEditingController contactEmailCtrl;

  /// متحكمات بيانات المحفظة.
  late final TextEditingController receiverNameCtrl;
  late final TextEditingController walletNumberCtrl;

  /// هل المستخدم الآن في شاشة الدفع؟
  bool get isPayment => step.value == CartStep.payment;

  /// هل طريقة الدفع الحالية هي محفظة؟
  bool get isWalletPayment => paymentMethodId.value == 'wallet';

  @override

  /// هذه الدالة تُستدعى عند إنشاء الكنترولر.
  /// نستخدمها لتهيئة متحكمات الحقول.
  void onInit() {
    super.onInit();

    shippingAddressCtrl = TextEditingController();
    shippingCityCtrl = TextEditingController();
    shippingPostcodeCtrl = TextEditingController();

    contactPhoneCtrl = TextEditingController();
    contactEmailCtrl = TextEditingController();

    receiverNameCtrl = TextEditingController(text: receiverName.value);
    walletNumberCtrl = TextEditingController(text: walletNumber.value);
  }

  /// هذه الدالة تفتح شاشة الدفع.
  /// نستخدمها عند الضغط على زر المتابعة من السلة.
  void openPayment() {
    step.value = CartStep.payment;
    Get.toNamed(AppRoutes.payment);
  }

  /// هذه الدالة تعيد الحالة إلى شاشة السلة.
  void backToCart() {
    step.value = CartStep.cart;

    if (Get.currentRoute == AppRoutes.payment &&
        (Get.key.currentState?.canPop() ?? false)) {
      Get.back();
    }
  }

  /// هذه الدالة تعيد الحالة المنطقية إلى السلة بعد إتمام الطلب.
  void completeCheckout() {
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
    receiverNameCtrl.text = value;
  }

  /// هذه الدالة تحدّث رقم المحفظة.
  void setWalletNumber(String value) {
    walletNumber.value = value;
    walletNumberCtrl.text = value;
  }

  /// هذه الدالة تحدّث دولة عنوان الشحن داخل الـ model.
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

  /// هذه الدالة تعبئ الحقول النصية من قيمة عنوان الشحن الحالية.
  void fillShippingFormFromState(ShippingAddress address) {
    shippingAddressCtrl.text = address.address;
    shippingCityCtrl.text = address.city;
    shippingPostcodeCtrl.text = address.postcode;
  }

  /// هذه الدالة تنظف نموذج الشحن وتبقي الدولة الافتراضية إن وُجدت.
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

  /// هذه الدالة تجهز النموذج لإضافة عنوان جديد.
  void prepareAddShipping({
    required void Function(ShippingAddress next) updateAddress,
  }) {
    updateAddress(ShippingAddress.empty());

    clearShippingForm(
      current: ShippingAddress.empty(),
      updateAddress: updateAddress,
    );
  }

  /// هذه الدالة تجهز النموذج لتعديل عنوان موجود.
  void prepareEditShipping(ShippingAddress address) {
    fillShippingFormFromState(address);
  }

  /// هذه الدالة تحفظ بيانات النموذج وتعيد عنوان شحن جاهز.
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

  /// هذه الدالة تعبئ نموذج التواصل من الحالة الحالية.
  void fillContactFormFromState(ContactInfoModel info) {
    contactPhoneCtrl.text = info.phone;
    contactEmailCtrl.text = info.email;
  }

  /// هذه الدالة تجهز نموذج التواصل للتعديل.
  void prepareEditContact(ContactInfoModel info) {
    fillContactFormFromState(info);
  }

  /// هذه الدالة تبني بيانات التواصل من الحقول الحالية.
  ContactInfoModel buildContactFromForm({
    required ContactInfoModel current,
  }) {
    return current.copyWith(
      phone: contactPhoneCtrl.text.trim(),
      email: contactEmailCtrl.text.trim(),
    );
  }

  /// هذه الدالة تعبئ نموذج المحفظة من الحالة الحالية.
  void fillWalletFormFromState() {
    receiverNameCtrl.text = receiverName.value;
    walletNumberCtrl.text = walletNumber.value;
  }

  /// هذه الدالة تجهز نموذج المحفظة للتعديل.
  void prepareEditWalletInfo() {
    fillWalletFormFromState();
  }

  /// هذه الدالة تحفظ بيانات المحفظة من الحقول الحالية.
  void saveWalletFromForm() {
    receiverName.value = receiverNameCtrl.text.trim();
    walletNumber.value = walletNumberCtrl.text.trim();
  }

  @override

  /// هذه الدالة تُستدعى عند التخلص من الكنترولر.
  /// نستخدمها لتحرير TextEditingController.
  void onClose() {
    shippingAddressCtrl.dispose();
    shippingCityCtrl.dispose();
    shippingPostcodeCtrl.dispose();
    contactPhoneCtrl.dispose();
    contactEmailCtrl.dispose();
    receiverNameCtrl.dispose();
    walletNumberCtrl.dispose();
    super.onClose();
  }
}

/// هذا الـ enum يحدد المرحلة الحالية داخل منظومة السلة والدفع.
enum CartStep { cart, payment }
