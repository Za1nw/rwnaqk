import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/modules/home/controllers/main_controller.dart';

import 'package:rwnaqk_frontend/modules/cart/controllers/cart_service.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_controller.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/providers/fake_orders_repository.dart';
import 'package:rwnaqk_frontend/modules/orders/data/repositories/orders_repository.dart';
import 'package:rwnaqk_frontend/modules/checkout/controllers/payment_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';
import 'package:rwnaqk_frontend/core/constants/app_env.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_checkout_utils.dart';
import 'package:rwnaqk_frontend/core/utils/app_money_utils.dart';
import 'package:rwnaqk_frontend/core/widgets/feedback/app_toast.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/contact_info_model.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/shipping_address.dart';
import 'package:rwnaqk_frontend/modules/checkout/data/models/shipping_option_model.dart';
import 'package:rwnaqk_frontend/modules/checkout/data/models/wallet_transfer_account.dart';
import 'package:rwnaqk_frontend/modules/cart/data/models/cart_quote_model.dart';

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

  /// مرجع العامل لمراقبة عناوين الملف الشخصي
  Worker? _addressesWorker;
  Worker? _shippingAddressWorker;

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

  /// آخر عرض سعر محسوب وموثق من سيرفر Laravel
  final Rxn<CartQuoteModel> serverQuote = Rxn<CartQuoteModel>();
  final RxBool isQuoteLoading = false.obs;
  final RxString quoteError = ''.obs;

  /// إجمالي العناصر فقط بدون الشحن (من السيرفر أو محلياً)
  double get itemsSubtotal =>
      serverQuote.value?.subtotal ??
      _service.computeItemsTotal(cartItems, itemQuantities);

  /// رسوم الشحن حسب الخيار المختار والتسعير الجغرافي
  double get shippingFee {
    final quote = serverQuote.value;
    if (quote != null) {
      return quote.shippingFee;
    }
    return _service.shippingFeeFor(
      options: shippingOptions,
      selectedId: selectedShippingId.value,
    );
  }

  // =========================
  // COUPON / PROMO CODE
  /// كود الخصم المطبق حالياً.
  final couponCode = ''.obs;

  /// نسبة الخصم المطبقة (مثلاً: 15%).
  final couponDiscountPercent = 0.obs;

  /// هل يوجد كود خصم نشط حالياً؟
  bool get hasCoupon =>
      couponCode.value.isNotEmpty &&
      ((serverQuote.value != null && serverQuote.value!.couponDiscountTotal > 0) ||
          couponDiscountPercent.value > 0);

  /// قيمة الخصم المالي الفعلي بالريال.
  double get couponDiscountAmount {
    final quote = serverQuote.value;
    if (quote != null) {
      return quote.couponDiscountTotal;
    }
    return (itemsSubtotal * couponDiscountPercent.value / 100);
  }

  /// تطبيق كود الخصم بالتحقق الشبكي
  Future<bool> applyCouponOnline(String code) async {
    final clean = code.trim().toUpperCase();
    if (clean.isEmpty) return false;

    if (AppEnv.enableMockData) {
      return applyCoupon(clean);
    }

    try {
      isQuoteLoading.value = true;
      final result = await _service.validateCouponOnline(
        couponCode: clean,
        subtotal: itemsSubtotal,
      );

      final data = result['data'];
      if (data is Map<String, dynamic> && data['valid'] == true) {
        couponCode.value = clean;
        couponDiscountPercent.value =
            int.tryParse(data['discount_percent']?.toString() ?? '15') ?? 15;
        await refreshServerQuote();
        final msg = result['message']?.toString();
        if (msg != null && msg.isNotEmpty) {
          AppToast.success(msg);
        }
        return true;
      } else {
        final msg = result['message']?.toString() ?? 'كود الخصم غير صالح';
        AppToast.error(msg);
        return false;
      }
    } catch (e) {
      AppToast.error(e.toString());
      return false;
    } finally {
      isQuoteLoading.value = false;
    }
  }

  /// تطبيق كود الخصم
  bool applyCoupon(String code) {
    final clean = code.trim().toUpperCase();
    if (clean == 'RAWNAQ' ||
        clean == 'RWNAQK' ||
        clean == 'RWNAQK15' ||
        clean == 'WELCOME') {
      couponCode.value = clean;
      couponDiscountPercent.value = clean == 'WELCOME' ? 20 : 15;
      if (isPayment) {
        refreshServerQuote();
      }
      return true;
    }
    return false;
  }

  /// إزالة كود الخصم
  void removeCoupon() {
    couponCode.value = '';
    couponDiscountPercent.value = 0;
    if (isPayment) {
      refreshServerQuote();
    }
  }

  /// الإجمالي النهائي مع احتساب الخصم والشحن.
  double get total {
    final quote = serverQuote.value;
    if (quote != null) {
      return quote.grandTotal;
    }
    return (itemsSubtotal - couponDiscountAmount + shippingFee)
        .clamp(0.0, double.infinity);
  }

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

  /// خيارات الشحن المتاحة في صفحة الدفع (من السيرفر أو الافتراضية).
  List<ShippingOptionModel> get shippingOptions {
    final quote = serverQuote.value;
    if (quote != null && quote.shippingOptions.isNotEmpty) {
      return quote.shippingOptions.map((opt) {
        return ShippingOptionModel(
          id: opt.id,
          priceText: opt.formattedFee,
        );
      }).toList(growable: false);
    }
    return _service.shippingOptions;
  }

  /// تحديث وإعادة احتساب عرض السعر من خادم Laravel
  Future<void> refreshServerQuote() async {
    if (AppEnv.enableMockData) return;

    final addressId = int.tryParse(shippingAddress.value.id);
    if (addressId == null || addressId <= 0 || cartItems.isEmpty) {
      serverQuote.value = null;
      return;
    }

    try {
      isQuoteLoading.value = true;
      quoteError.value = '';

      final quoteItems = cartItems.map((item) {
        final qty = quantityOf(item.id);
        final prodId = int.tryParse(item.productId);
        final varId = int.tryParse(item.id);
        return <String, dynamic>{
          if (varId != null && varId > 0) 'product_variation_id': varId,
          if (prodId != null && prodId > 0) 'product_id': prodId,
          'qty': qty,
        };
      }).toList();

      final quote = await _service.requestCartQuote(
        addressId: addressId,
        items: quoteItems,
        couponCode: couponCode.value.isNotEmpty ? couponCode.value : null,
        shippingOptionId: selectedShippingId.value.isNotEmpty
            ? selectedShippingId.value
            : null,
      );

      if (quote != null) {
        serverQuote.value = quote;
        if (!quote.isServiceable && quote.message != null) {
          AppToast.warning(quote.message!);
        }
      }
    } catch (e) {
      quoteError.value = e.toString();
      debugPrint('[CartController.refreshServerQuote] error: $e');
    } finally {
      isQuoteLoading.value = false;
    }
  }

  // =========================
  // FLOW
  /// هذه الدالة تفتح صفحة الدفع إذا كانت السلة غير فارغة.
  void openPayment() {
    if (cartItems.isEmpty) return;
    _syncCheckoutDefaultsFromProfile();
    ui.openPayment();
    refreshServerQuote();
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
    if (isPayment) {
      refreshServerQuote();
    }
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
    } else if (isPayment) {
      refreshServerQuote();
    }
  }

  /// هذه الدالة تفرغ السلة بالكامل
  void clearCart() {
    cartItems.clear();
    itemQuantities.clear();
    itemVariantTexts.clear();
    itemRatings.clear();
    itemReviewsCounts.clear();
    removeCoupon();
    serverQuote.value = null;

    if (isPayment) {
      backToCart();
    }
  }

  /// الانتقال إلى الصفحة الرئيسية للتسوق
  void goToHome() {
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().changeTab(0);
    } else {
      Get.offAllNamed(AppRoutes.main);
    }
  }

  /// هذه الدالة تزيد كمية عنصر موجود.
  void incrementQuantity(String id) {
    if (!cartItems.any((e) => e.id == id)) return;
    itemQuantities[id] = quantityOf(id) + 1;
    if (isPayment) {
      refreshServerQuote();
    }
  }

  /// هذه الدالة تقلل كمية عنصر موجود أو تحذفه إذا أصبحت 0.
  void decrementQuantity(String id) {
    final current = quantityOf(id);

    if (current <= 1) {
      removeFromCart(id);
      return;
    }

    itemQuantities[id] = current - 1;
    if (isPayment) {
      refreshServerQuote();
    }
  }

  /// هذه الدالة تضيف عنصرًا إلى السلة.
  /// إذا كان موجودًا مسبقًا بنفس المتغير، نزيد الكمية، وإن كان بمتغير جديد ننشئ سطرًا مستقلاً مع الحفاظ على معرف المنتج الأصلي productId.
  void addToCart(
    HomeProductItem item, {
    int quantity = 1,
    String? variantText,
    double? rating,
    int? reviewsCount,
  }) {
    final qty = quantity > 0 ? quantity : 1;
    final v = (variantText ?? '').trim();
    final realProductId = item.productId;
    final lineId = v.isNotEmpty ? '${realProductId}_$v' : realProductId;
    final cartItem = item.copyWith(
      id: lineId,
      originalProductId: realProductId,
    );

    final existingIndex = cartItems.indexWhere((e) => e.id == lineId);

    if (existingIndex == -1) {
      cartItems.add(cartItem);
      itemQuantities[lineId] = qty;
    } else {
      itemQuantities[lineId] = (itemQuantities[lineId] ?? 0) + qty;
    }

    if (v.isNotEmpty) {
      itemVariantTexts[lineId] = v;
    }

    if (rating != null && rating > 0) {
      itemRatings[lineId] = rating;
    }

    if (reviewsCount != null && reviewsCount > 0) {
      itemReviewsCounts[lineId] = reviewsCount;
    }

    if (Get.isRegistered<WishlistController>()) {
      Get.find<WishlistController>().removeFromWishlist(realProductId);
    }
  }

  /// هذه الدالة تنفذ عملية الدفع الحالية وتحوّلها إلى Order جاهز وتعيده للواجهة.
  Future<OrderModel?> payNow({
    String? paymentMethodKey,
    WalletTransferAccount? walletAccount,
    String? receiptImageUrl,
    String? notes,
    String? idempotencyKey,
  }) async {
    if (cartItems.isEmpty) {
      AppToast.warning(
        Tk.cartValidationCartEmpty.tr,
        title: Tk.cartValidationCartTitle.tr,
      );
      return null;
    }

    if (!hasShippingAddress) {
      AppToast.warning(
        Tk.cartValidationShippingMissing.tr,
        title: Tk.cartValidationShippingTitle.tr,
      );
      return null;
    }

    if (contactInfo.value.isEmpty) {
      AppToast.warning(
        Tk.cartValidationContactMissing.tr,
        title: Tk.cartValidationContactTitle.tr,
      );
      return null;
    }

    final String resolvedPaymentMethodKey;
    final bool isWallet;
    if (paymentMethodKey != null && paymentMethodKey.trim().isNotEmpty) {
      resolvedPaymentMethodKey = paymentMethodKey;
      isWallet = paymentMethodKey == 'wallet' ||
          (Get.isRegistered<PaymentController>() &&
              Get.find<PaymentController>().isWalletPayment);
    } else if (Get.isRegistered<PaymentController>()) {
      final payment = Get.find<PaymentController>();
      isWallet = payment.isWalletPayment;
      if (isWallet) {
        final acc = walletAccount ?? payment.selectedWalletAccount;
        if (acc == null ||
            acc.receiverName.trim().isEmpty ||
            acc.walletNumber.trim().isEmpty) {
          AppToast.warning(
            Tk.cartValidationWalletMissing.tr,
            title: Tk.cartValidationWalletTitle.tr,
          );
          return null;
        }
      }
      resolvedPaymentMethodKey = payment.paymentMethodLabel;
    } else {
      isWallet = false;
      resolvedPaymentMethodKey = Tk.cartPaymentCodTitle.tr;
    }

    if (AppEnv.enableMockData) {
      final order = _service.buildCheckoutOrder(
        items: cartItems.toList(growable: false),
        quantities: Map<String, int>.from(itemQuantities),
        itemsCount: itemsCount,
        shippingFee: shippingFee,
        discountAmount: couponDiscountAmount,
        total: total,
        address: shippingAddress.value,
        contact: contactInfo.value,
        shippingMethodKey: selectedShippingTitle,
        paymentMethodKey: resolvedPaymentMethodKey,
        status: 'pending',
      );

      if (Get.isRegistered<OrdersController>()) {
        Get.find<OrdersController>().addOrder(order);
      }

      cartItems.clear();
      itemQuantities.clear();
      removeCoupon();
      serverQuote.value = null;
      ui.completeCheckout();

      return order;
    }

    // التكامل الحقيقي مع خادم Laravel API
    final addressId = int.tryParse(shippingAddress.value.id) ??
        serverQuote.value?.addressId;

    if (addressId == null || addressId <= 0) {
      AppToast.warning(
        'يرجى اختيار عنوان توصيل معتمد لإتمام الطلب.',
        title: Tk.cartValidationShippingTitle.tr,
      );
      return null;
    }

    final quoteItems = cartItems.map((item) {
      final qty = quantityOf(item.id);
      final prodId = int.tryParse(item.productId);
      final varId = int.tryParse(item.id);
      return <String, dynamic>{
        if (varId != null && varId > 0) 'product_variation_id': varId,
        if (prodId != null && prodId > 0) 'product_id': prodId,
        'qty': qty,
      };
    }).toList();

    final backendPaymentMethod = isWallet ? 'wallet' : 'cash_on_delivery';

    Map<String, dynamic>? backendWalletAccount;
    if (isWallet) {
      final acc = walletAccount ??
          (Get.isRegistered<PaymentController>()
              ? Get.find<PaymentController>().selectedWalletAccount
              : null);
      if (acc != null) {
        backendWalletAccount = {
          'company': acc.companyName,
          'number': acc.walletNumber,
          'name': acc.receiverName,
        };
      }
    }

    final IOrdersRepository ordersRepo = Get.isRegistered<IOrdersRepository>()
        ? Get.find<IOrdersRepository>()
        : (Get.isRegistered<OrdersController>()
            ? Get.find<OrdersController>().repository
            : FakeOrdersRepository());

    final order = await ordersRepo.submitCheckout(
      addressId: addressId,
      items: quoteItems,
      paymentMethod: backendPaymentMethod,
      couponCode: couponCode.value.isNotEmpty ? couponCode.value : null,
      shippingOptionId: selectedShippingId.value.isNotEmpty
          ? selectedShippingId.value
          : null,
      expectedGrandTotal: total,
      walletAccount: backendWalletAccount,
      receiptImageUrl: receiptImageUrl,
      notes: notes,
      idempotencyKey: idempotencyKey,
    );

    // تفريغ السلة فقط عند التأكد من نجاح إنشاء الطلب من السيرفر
    if (Get.isRegistered<OrdersController>()) {
      Get.find<OrdersController>().addOrder(order);
    }

    cartItems.clear();
    itemQuantities.clear();
    removeCoupon();
    serverQuote.value = null;
    ui.completeCheckout();

    return order;
  }

  @override
  /// هذه الدالة تُستدعى عند إنشاء الكنترولر لأول مرة.
  /// نستخدمها لتهيئة الـ UI controller وتحميل البيانات التجريبية.
  void onInit() {
    super.onInit();

    ui = Get.find<CartUiController>();
    contactInfo = _service.contactInfo.obs;
    _addressesWorker = ever<List<dynamic>>(_profileStore.addresses, (list) {
      if (list.isNotEmpty) {
        final def = _profileStore.defaultAddress;
        if (def != null) {
          shippingAddress.value = def;
          fillShippingFormFromState();
        }
      } else {
        shippingAddress.value = ShippingAddress.empty();
        clearShippingForm();
      }
    });

    _shippingAddressWorker = ever<ShippingAddress>(shippingAddress, (addr) {
      if (isPayment && !addr.isEmpty) {
        refreshServerQuote();
      }
    });

    seedMockData();
  }

  @override
  void onClose() {
    _addressesWorker?.dispose();
    _shippingAddressWorker?.dispose();
    super.onClose();
  }

  /// هذه الدالة تحمل البيانات التجريبية الحالية الخاصة بالسلة.
  void seedMockData() {
    if (!AppEnv.enableMockData) {
      cartItems.clear();
      wishlistItems.clear();
      itemQuantities.clear();
      itemVariantTexts.clear();
      itemRatings.clear();
      itemReviewsCounts.clear();
      _syncCheckoutDefaultsFromProfile(forceContact: true);
      return;
    }

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
