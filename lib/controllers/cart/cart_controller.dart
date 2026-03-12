import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:rwnaqk/controllers/cart/cart_service.dart';
import 'package:rwnaqk/controllers/cart/cart_ui_controller.dart';
import 'package:rwnaqk/controllers/orders/orders_controller.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/utils/app_money_utils.dart';
import 'package:rwnaqk/models/contact_info_model.dart';
import 'package:rwnaqk/models/home_product_item.dart';
import 'package:rwnaqk/models/order_model.dart';
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

  /// كميات عناصر السلة الحالية، بدون تعديل الـ model.
  final itemQuantities = <String, int>{}.obs;

  /// عناصر المفضلة المقترحة عند فراغ السلة.
  final wishlistItems = <HomeProductItem>[].obs;

  /// عنوان الشحن الحالي.
  final shippingAddress = ShippingAddressModel.empty().obs;

  /// بيانات التواصل الحالية.
  late final Rx<ContactInfoModel> contactInfo;

  /// إجمالي العناصر فقط بدون الشحن.
  double get itemsSubtotal => _service.computeItemsTotal(
        cartItems,
        itemQuantities,
      );

  /// رسوم الشحن حسب الخيار المختار.
  double get shippingFee => _service.shippingFeeFor(
        options: shippingOptions,
        selectedId: selectedShippingId.value,
      );

  /// الإجمالي النهائي.
  double get total => itemsSubtotal + shippingFee;

  /// هل السلة فارغة؟
  bool get isEmpty => cartItems.isEmpty;

  /// هل يوجد عنوان شحن محفوظ؟
  bool get hasShippingAddress => !shippingAddress.value.isEmpty;

  /// النص المنسق لعنوان الشحن.
  String get shippingAddressText => shippingAddress.value.formatted;

  /// السطور الجاهزة لعرض بيانات التواصل.
  List<String> get contactLines => contactInfo.value.lines;

  /// عدد كل الوحدات الموجودة في السلة.
  int get itemsCount {
    return cartItems.fold<int>(0, (sum, item) => sum + quantityOf(item.id));
  }

  /// عدد الأسطر/المنتجات المختلفة داخل السلة.
  int get linesCount => cartItems.length;

  /// هل يوجد ما يكفي لبدء الـ checkout.
  bool get canCheckout => cartItems.isNotEmpty;

  /// هل يوجد خيار شحن مختار.
  ShippingOptionModel get selectedShippingOption {
    for (final option in shippingOptions) {
      if (option.id == selectedShippingId.value) return option;
    }

    return shippingOptions.first;
  }

  /// اسم خيار الشحن الحالي.
  String get selectedShippingTitle => selectedShippingOption.title;

  /// نص سعر الشحن الحالي.
  String get shippingFeeText {
    if (shippingFee <= 0) return 'FREE';
    return AppMoneyUtils.currency(shippingFee);
  }

  /// اسم طريقة الدفع الحالية.
  String get paymentMethodLabel {
    return isWalletPayment ? 'Wallet Transfer' : 'Cash on Delivery';
  }

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

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشات.
  TextEditingController get contactPhoneCtrl => ui.contactPhoneCtrl;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشات.
  TextEditingController get contactEmailCtrl => ui.contactEmailCtrl;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشات.
  TextEditingController get receiverNameCtrl => ui.receiverNameCtrl;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشات.
  TextEditingController get walletNumberCtrl => ui.walletNumberCtrl;

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
  // CONTACT FORM
  /// هذه الدالة تجهز نموذج التواصل من الحالة الحالية.
  void prepareEditContact() {
    ui.prepareEditContact(contactInfo.value);
  }

  /// هذه الدالة تحفظ معلومات التواصل من النموذج.
  void saveContactFromForm() {
    contactInfo.value = ui.buildContactFromForm(current: contactInfo.value);
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

  /// هذه الدالة تجهز نموذج بيانات المحفظة.
  void prepareEditWalletInfo() {
    ui.prepareEditWalletInfo();
  }

  /// هذه الدالة تحفظ بيانات المحفظة من الحقول الحالية.
  void saveWalletFromForm() {
    ui.saveWalletFromForm();
  }

  // =========================
  // QUANTITY HELPERS
  int quantityOf(String id) => itemQuantities[id] ?? 1;

  double lineTotalOf(HomeProductItem item) {
    final unit = item.hasDiscount ? item.salePrice : item.price;
    return unit * quantityOf(item.id);
  }

  String? variantTextOf(HomeProductItem item) {
    final parts = <String>[];

    if (item.availableColors.isNotEmpty) {
      final colorName = item.availableColors.first.name.trim();
      if (colorName.isNotEmpty) parts.add(colorName);
    }

    if (item.availableSizes.isNotEmpty) {
      final size = item.availableSizes.first.trim();
      if (size.isNotEmpty) parts.add(size);
    }

    if (parts.isEmpty) return null;
    return parts.join(' • ');
  }

  String paymentItemSubtitle(HomeProductItem item) {
    final parts = <String>[];
    final variant = variantTextOf(item);

    if (variant != null && variant.isNotEmpty) {
      parts.add(variant);
    }

    parts.add('Qty ${quantityOf(item.id)}');

    return parts.join(' • ');
  }

  // =========================
  // ACTIONS
  /// هذه الدالة تحذف عنصرًا من السلة حسب المعرّف.
  /// وإذا أصبحت السلة فارغة أثناء الدفع، نعيد المستخدم إلى السلة.
  void removeFromCart(String id) {
    cartItems.removeWhere((e) => e.id == id);
    itemQuantities.remove(id);

    if (cartItems.isEmpty && isPayment) {
      backToCart();
    }
  }

  /// هذه الدالة تزيد كمية عنصر موجود.
  void incrementQuantity(String id) {
    if (!cartItems.any((e) => e.id == id)) return;
    itemQuantities[id] = quantityOf(id) + 1;
  }

  /// هذه الدالة تقلل كمية عنصر موجود أو تحذفه إذا أصبحت 0.
  void decrementQuantity(String id) {
    final current = quantityOf(id);

    if (current <= 1) {
      removeFromCart(id);
      return;
    }

    itemQuantities[id] = current - 1;
  }

  /// هذه الدالة تضيف عنصرًا إلى السلة.
  /// إذا كان موجودًا مسبقًا، نزيد الكمية بدل تكرار السطر.
  void addToCart(HomeProductItem item) {
    final existingIndex = cartItems.indexWhere((e) => e.id == item.id);

    if (existingIndex == -1) {
      cartItems.add(item);
      itemQuantities[item.id] = 1;
      return;
    }

    incrementQuantity(item.id);
  }

  /// هذه الدالة تنفذ عملية الدفع الحالية وتحوّلها إلى Order جاهز.
  void payNow() {
    if (cartItems.isEmpty) {
      Get.snackbar('Cart', 'Your cart is empty');
      return;
    }

    if (!hasShippingAddress) {
      Get.snackbar('Shipping', 'Please add a shipping address first');
      return;
    }

    if (contactInfo.value.isEmpty) {
      Get.snackbar('Contact', 'Please add your contact information');
      return;
    }

    if (isWalletPayment) {
      saveWalletFromForm();

      if (receiverName.value.trim().isEmpty ||
          walletNumber.value.trim().isEmpty) {
        Get.snackbar('Wallet', 'Please enter receiver name and wallet number');
        return;
      }
    }

    final order = _service.buildCheckoutOrder(
      itemsCount: itemsCount,
      total: total,
      address: shippingAddress.value,
      contact: contactInfo.value,
      status: 'pending',
    );

    Get.find<OrdersController>().addOrder(order);

    cartItems.clear();
    itemQuantities.clear();
    ui.completeCheckout();

    Get.offNamed(AppRoutes.orderTracking, arguments: order);
    Get.snackbar('Success', 'Your order has been created successfully');
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
    contactInfo.value = _service.contactInfo;

    itemQuantities
      ..clear()
      ..addEntries(cartItems.map((item) => MapEntry(item.id, 1)));

    fillShippingFormFromState();
    ui.fillContactFormFromState(contactInfo.value);
    ui.fillWalletFormFromState();
  }
}
