import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:rwnaqk/controllers/cart/cart_service.dart';
import 'package:rwnaqk/controllers/cart/cart_ui_controller.dart';
import 'package:rwnaqk/controllers/orders/orders_controller.dart';
import 'package:rwnaqk/controllers/payment/payment_controller.dart';
import 'package:rwnaqk/controllers/profile/profile_store_service.dart';
import 'package:rwnaqk/controllers/wishlist/wishlist_controller.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/core/utils/app_checkout_utils.dart';
import 'package:rwnaqk/core/utils/app_money_utils.dart';
import 'package:rwnaqk/models/contact_info_model.dart';
import 'package:rwnaqk/models/home_product_item.dart';
import 'package:rwnaqk/models/shipping_address.dart';
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
  /// مؤشر المحفظة المختارة (من ui)
  /// تحويل حسابات المحافظ الإدارية إلى WalletCompany لعرضها في الواجهة
  CartController(this._service);

  final CartService _service;
  final _profileStore = Get.find<ProfileStoreService>();

  late final CartUiController ui;

  // =========================
  // CART DATA
  /// عناصر السلة الحالية.
  final cartItems = <HomeProductItem>[].obs;

  /// كميات عناصر السلة الحالية، بدون تعديل الـ model.
  final itemQuantities = <String, int>{}.obs;

  /// ميتاداتا لكل عنصر في السلة (الاختيارات/التقييم) بدون تعديل الـ model.
  final itemVariantTexts = <String, String>{}.obs;
  final itemRatings = <String, double>{}.obs;
  final itemReviewsCounts = <String, int>{}.obs;

  /// عناصر المفضلة المقترحة عند فراغ السلة.
  final wishlistItems = <HomeProductItem>[].obs;

  /// عنوان الشحن الحالي.
  final shippingAddress = ShippingAddress.empty().obs;

  /// بيانات التواصل الحالية.
  late final Rx<ContactInfoModel> contactInfo;

  /// إجمالي العناصر فقط بدون الشحن.
  double get itemsSubtotal =>
      _service.computeItemsTotal(cartItems, itemQuantities);

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

  String get selectedShippingCountryLabel =>
      _service.localizedCountryLabel(shippingAddress.value.country);

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
  String get selectedShippingTitle =>
      AppCheckoutUtils.cartShippingTitle(selectedShippingOption.id);

  /// نص سعر الشحن الحالي.
  String get shippingFeeText {
    if (shippingFee <= 0) return Tk.cartFree.tr;
    return AppMoneyUtils.currency(shippingFee);
  }

  /// اسم طريقة الدفع الحالية.
  // =========================
  // UI BRIDGES
  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشات.
  Rx<CartStep> get step => ui.step;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشات.
  bool get isPayment => ui.isPayment;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشات.
  RxString get selectedShippingId => ui.selectedShippingId;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشات.

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشات.

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشات.

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشات.

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

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشات.

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
    _syncCheckoutDefaultsFromProfile();
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
    _profileStore.saveDefaultShippingAddress(shippingAddress.value);
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
  /// هذه الدالة تغيّر طريقة الدفع الحالية.

  /// هذه الدالة تغيّر اسم المستلم.

  /// هذه الدالة تغيّر رقم المحفظة.

  /// هذه الدالة تجهز نموذج بيانات المحفظة.

  /// هذه الدالة تحفظ بيانات المحفظة من الحقول الحالية.

  // =========================
  // QUANTITY HELPERS
  int quantityOf(String id) => itemQuantities[id] ?? 1;

  double lineTotalOf(HomeProductItem item) {
    final unit = item.hasDiscount ? item.salePrice : item.price;
    return unit * quantityOf(item.id);
  }

  // =========================
  // ACTIONS
  /// هذه الدالة تحذف عنصرًا من السلة حسب المعرّف.
  /// وإذا أصبحت السلة فارغة أثناء الدفع، نعيد المستخدم إلى السلة.
  void removeFromCart(String id) {
    cartItems.removeWhere((e) => e.id == id);
    itemQuantities.remove(id);
    itemVariantTexts.remove(id);
    itemRatings.remove(id);
    itemReviewsCounts.remove(id);

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
  void addToCart(
    HomeProductItem item, {
    String? variantText,
    double? rating,
    int? reviewsCount,
  }) {
    final existingIndex = cartItems.indexWhere((e) => e.id == item.id);

    if (existingIndex == -1) {
      cartItems.add(item);
      itemQuantities[item.id] = 1;
    } else {
      incrementQuantity(item.id);
    }

    final v = (variantText ?? '').trim();
    if (v.isNotEmpty) {
      itemVariantTexts[item.id] = v;
    }

    if (rating != null && rating > 0) {
      itemRatings[item.id] = rating;
    }

    if (reviewsCount != null && reviewsCount > 0) {
      itemReviewsCounts[item.id] = reviewsCount;
    }

    if (Get.isRegistered<WishlistController>()) {
      Get.find<WishlistController>().removeFromWishlist(item.id);
    }
  }

  /// هذه الدالة تنفذ عملية الدفع الحالية وتحوّلها إلى Order جاهز.
  void payNow() {
    if (cartItems.isEmpty) {
      Get.snackbar(
        Tk.cartValidationCartTitle.tr,
        Tk.cartValidationCartEmpty.tr,
      );
      return;
    }

    if (!hasShippingAddress) {
      Get.snackbar(
        Tk.cartValidationShippingTitle.tr,
        Tk.cartValidationShippingMissing.tr,
      );
      return;
    }

    if (contactInfo.value.isEmpty) {
      Get.snackbar(
        Tk.cartValidationContactTitle.tr,
        Tk.cartValidationContactMissing.tr,
      );
      return;
    }

    final payment = Get.find<PaymentController>();

    if (payment.isWalletPayment) {
      final acc = payment.selectedWalletAccount;
      if (acc == null ||
          acc.receiverName.trim().isEmpty ||
          acc.walletNumber.trim().isEmpty) {
        Get.snackbar(
          Tk.cartValidationWalletTitle.tr,
          Tk.cartValidationWalletMissing.tr,
        );
        return;
      }
    }

    final order = _service.buildCheckoutOrder(
      items: cartItems.toList(growable: false),
      quantities: Map<String, int>.from(itemQuantities),
      itemsCount: itemsCount,
      shippingFee: shippingFee,
      total: total,
      address: shippingAddress.value,
      contact: contactInfo.value,
      shippingMethodKey: selectedShippingTitle,
      paymentMethodKey: payment.paymentMethodLabel,
      status: 'pending',
    );

    Get.find<OrdersController>().addOrder(order);

    cartItems.clear();
    itemQuantities.clear();
    ui.completeCheckout();

    Get.offNamed(AppRoutes.orderTracking, arguments: order);
    Get.snackbar(Tk.cartOrderCreatedTitle.tr, Tk.cartOrderCreatedMessage.tr);
  }

  @override
  /// هذه الدالة تُستدعى عند إنشاء الكنترولر لأول مرة.
  /// نستخدمها لتهيئة الـ UI controller وتحميل البيانات التجريبية.
  void onInit() {
    super.onInit();

    ui = Get.find<CartUiController>();
    contactInfo = _service.contactInfo.obs;
    ever<List<dynamic>>(_profileStore.addresses, (_) {
      shippingAddress.value = _service.seedShippingAddress();
      fillShippingFormFromState();
    });

    seedMockData();
  }

  /// هذه الدالة تحمل البيانات التجريبية الحالية الخاصة بالسلة.
  void seedMockData() {
    cartItems.assignAll(_service.seedCartItems());
    wishlistItems.assignAll(_service.seedWishlistItems());
    shippingAddress.value = _service.seedShippingAddress();
    contactInfo.value = _service.contactInfo;
    _syncCheckoutDefaultsFromProfile(forceContact: true);

    itemQuantities
      ..clear()
      ..addEntries(cartItems.map((item) => MapEntry(item.id, 1)));

    itemVariantTexts.clear();
    itemRatings.clear();
    itemReviewsCounts.clear();

    fillShippingFormFromState();
    ui.fillContactFormFromState(contactInfo.value);
  }

  void _syncCheckoutDefaultsFromProfile({bool forceContact = false}) {
    final profilePhone = _profileStore.phone.trim();
    final profileEmail = _profileStore.email.trim();

    if (forceContact || contactInfo.value.isEmpty) {
      contactInfo.value = contactInfo.value.copyWith(
        phone: profilePhone,
        email: profileEmail,
      );
      ui.fillContactFormFromState(contactInfo.value);
    }
  }
}
