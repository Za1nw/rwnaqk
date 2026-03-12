import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:rwnaqk/controllers/cart/cart_service.dart';
import 'package:rwnaqk/controllers/cart/cart_ui_controller.dart';
import 'package:rwnaqk/models/contact_info_model.dart';
import 'package:rwnaqk/models/home_product_item.dart';
import 'package:rwnaqk/models/shipping_address_model.dart';
import 'package:rwnaqk/models/shipping_option_model.dart';

/// هذا الملف هو الكنترولر الرئيسي لمنظومة السلة.
///
/// نستخدمه لإدارة:
/// - عناصر السلة
/// - عناصر المفضلة المقترحة
/// - عنوان الشحن الحالي
/// - بيانات التواصل
/// - العمليات الأساسية مثل الإضافة والحذف والدفع
///
/// كما أنه يعمل كحلقة ربط بين:
/// - CartUiController الخاص بحالات الواجهة
/// - CartService الخاص بالبيانات والتجهيزات
class CartController extends GetxController {
  CartController(this._service);

  final CartService _service;

  late final CartUiController ui;

  // =========================
  // CART DATA
  /// عناصر السلة الحالية.
  final cartItems = <HomeProductItem>[].obs;

  /// عناصر المفضلة المقترحة عند فراغ السلة.
  final wishlistItems = <HomeProductItem>[].obs;

  /// عنوان الشحن الحالي.
  final shippingAddress = ShippingAddressModel.empty().obs;

  /// بيانات التواصل الحالية.
  late final Rx<ContactInfoModel> contactInfo;

  /// هذا getter يحسب إجمالي السلة عبر الخدمة.
  double get total => _service.computeTotal(cartItems);

  /// هل السلة فارغة؟
  bool get isEmpty => cartItems.isEmpty;

  /// هل يوجد عنوان شحن محفوظ؟
  bool get hasShippingAddress => !shippingAddress.value.isEmpty;

  /// النص المنسق لعنوان الشحن.
  String get shippingAddressText => shippingAddress.value.formatted;

  /// السطور الجاهزة لعرض بيانات التواصل.
  List<String> get contactLines => contactInfo.value.lines;

  // =========================
  // UI BRIDGES
  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشات.
  Rx<CartStep> get step => ui.step;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشات.
  bool get isPayment => ui.isPayment;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشات.
  RxString get selectedShippingId => ui.selectedShippingId;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشات.
  RxString get paymentMethodId => ui.paymentMethodId;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشات.
  RxString get receiverName => ui.receiverName;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشات.
  RxString get walletNumber => ui.walletNumber;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشات.
  bool get isWalletPayment => ui.isWalletPayment;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشات.
  TextEditingController get shippingAddressCtrl => ui.shippingAddressCtrl;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشات.
  TextEditingController get shippingCityCtrl => ui.shippingCityCtrl;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشات.
  TextEditingController get shippingPostcodeCtrl => ui.shippingPostcodeCtrl;

  // =========================
  // STATIC DATA
  /// الدول المتاحة في نموذج عنوان الشحن.
  List<String> get shippingCountries => _service.shippingCountries;

  /// خيارات الشحن المتاحة في صفحة الدفع.
  List<ShippingOptionModel> get shippingOptions => _service.shippingOptions;

  // =========================
  // FLOW
  /// هذه الدالة تفتح صفحة الدفع إذا كانت السلة غير فارغة.
  void openPayment() {
    if (cartItems.isEmpty) return;
    ui.openPayment();
  }

  /// هذه الدالة تعيد المستخدم إلى شاشة السلة.
  void backToCart() {
    ui.backToCart();
  }

  // =========================
  // SHIPPING ADDRESS FORM
  /// هذه الدالة تغيّر دولة عنوان الشحن الحالي.
  void setShippingCountry(String value) {
    ui.setShippingCountry(
      current: shippingAddress.value,
      value: value,
      updateAddress: (next) => shippingAddress.value = next,
    );
  }

  /// هذه الدالة تعبئ النموذج من العنوان الحالي.
  void fillShippingFormFromState() {
    ui.fillShippingFormFromState(shippingAddress.value);
  }

  /// هذه الدالة تنظف النموذج الحالي.
  void clearShippingForm() {
    ui.clearShippingForm(
      current: shippingAddress.value,
      updateAddress: (next) => shippingAddress.value = next,
    );
  }

  /// هذه الدالة تجهز النموذج لإضافة عنوان شحن جديد.
  void prepareAddShipping() {
    ui.prepareAddShipping(
      updateAddress: (next) => shippingAddress.value = next,
    );
  }

  /// هذه الدالة تجهز النموذج لتعديل عنوان الشحن الحالي.
  void prepareEditShipping() {
    ui.prepareEditShipping(shippingAddress.value);
  }

  /// هذه الدالة تحفظ عنوان الشحن من بيانات النموذج.
  void saveShippingFromForm() {
    shippingAddress.value = ui.buildShippingFromForm(
      current: shippingAddress.value,
    );
  }

  // =========================
  // SHIPPING OPTION
  /// هذه الدالة تغيّر خيار الشحن المختار.
  void setShipping(String id) {
    ui.setShipping(id);
  }

  // =========================
  // PAYMENT
  /// هذه الدالة تغيّر طريقة الدفع الحالية.
  void setPaymentMethodId(String id) {
    ui.setPaymentMethodId(id);
  }

  /// هذه الدالة تغيّر اسم المستلم.
  void setReceiverName(String value) {
    ui.setReceiverName(value);
  }

  /// هذه الدالة تغيّر رقم المحفظة.
  void setWalletNumber(String value) {
    ui.setWalletNumber(value);
  }

  // =========================
  // ACTIONS
  /// هذه الدالة تحذف عنصرًا من السلة حسب المعرّف.
  /// وإذا أصبحت السلة فارغة أثناء الدفع، نعيد المستخدم إلى السلة.
  void removeFromCart(String id) {
    cartItems.removeWhere((e) => e.id == id);

    if (cartItems.isEmpty && isPayment) {
      backToCart();
    }
  }

  /// هذه الدالة تضيف عنصرًا إلى السلة.
  void addToCart(HomeProductItem item) {
    cartItems.add(item);
  }

  /// هذه الدالة تنفذ عملية الدفع الوهمية الحالية.
  /// وتتحقق من حقول المحفظة إذا كانت طريقة الدفع الحالية تعتمد عليها.
  void payNow() {
    if (isWalletPayment) {
      if (receiverName.value.trim().isEmpty ||
          walletNumber.value.trim().isEmpty) {
        Get.snackbar('Error', 'Please enter receiver name and wallet number');
        return;
      }
    }

    Get.snackbar('Success', 'Payment done (mock)');
    backToCart();
  }

  @override
  /// هذه الدالة تُستدعى عند إنشاء الكنترولر لأول مرة.
  /// نستخدمها لتهيئة الـ UI controller وتحميل البيانات التجريبية.
  void onInit() {
    super.onInit();

    ui = Get.find<CartUiController>();
    contactInfo = _service.contactInfo.obs;

    seedMockData();
  }

  /// هذه الدالة تحمل البيانات التجريبية الحالية الخاصة بالسلة.
  void seedMockData() {
    cartItems.assignAll(_service.seedCartItems());
    wishlistItems.assignAll(_service.seedWishlistItems());
    shippingAddress.value = _service.seedShippingAddress();

    fillShippingFormFromState();
  }
}