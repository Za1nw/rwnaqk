import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/screens/payment_screen.dart';
import 'package:rwnaqk/widgets/cart/shipping_address_sheet.dart';

import '../models/home_product_item.dart';

enum CartStep { cart, payment }

class CartController extends GetxController {
  // =========================
  // DATA
  final cartItems = <HomeProductItem>[].obs;
  final wishlistItems = <HomeProductItem>[].obs;

  double get total => cartItems.fold(0.0, (sum, e) => sum + e.price);
  bool get isEmpty => cartItems.isEmpty;

  // =========================
  // FLOW STEP (Cart -> Payment)
  final Rx<CartStep> step = CartStep.cart.obs;
  bool get isPayment => step.value == CartStep.payment;

  void openPayment() => step.value = CartStep.payment;
  void backToCart() => step.value = CartStep.cart;
  final selectedShippingId = 'standard'.obs;

  void setShipping(String id) {
    selectedShippingId.value = id;
  }

  // (لو تبغى نفس اسم الدالة القديمة بدون ما تعدل الشاشة)
  void goCheckout() {
    Get.to(() => const PaymentScreen());
  }

  // =========================
  // SHIPPING (Address Form)
  late final TextEditingController shippingAddressCtrl;
  late final TextEditingController shippingCityCtrl;
  late final TextEditingController shippingPostcodeCtrl;

  final RxString shippingCountry = 'Yemen'.obs;
  final List<String> shippingCountries = const [
    'Yemen',
    'Saudi Arabia',
    'UAE',
    'India',
  ];

  /// النص المعروض في الواجهة (Cart/Payment)
  /// - إذا كان فاضي => AddressSection يعرض AddInfoCard
  final RxString shippingAddressText = ''.obs;

  /// ✅ فورم إضافة: يفتح الشيت والحقول فاضية
  void openAddShippingSheet(BuildContext context) {
    shippingAddressCtrl.clear();
    shippingCityCtrl.clear();
    shippingPostcodeCtrl.clear();
    _showShippingSheet(context);
  }

  /// ✅ فورم تعديل: يفتح الشيت بالقيم الحالية الموجودة في controllers
  void openEditShippingSheet(BuildContext context) {
    _showShippingSheet(context);
  }

  void _showShippingSheet(BuildContext context) {
    ShippingAddressSheet.showShipping(
      context,
      addressController: shippingAddressCtrl,
      cityController: shippingCityCtrl,
      postcodeController: shippingPostcodeCtrl,
      country: shippingCountry.value,
      countries: shippingCountries,
      onCountryChanged: (v) {
        if (v != null) shippingCountry.value = v;
      },
      onSave: () {
        _commitShippingAddress();
        Navigator.pop(context);
      },
    );
  }

  void _commitShippingAddress() {
    final a = shippingAddressCtrl.text.trim();
    final c = shippingCityCtrl.text.trim();
    final p = shippingPostcodeCtrl.text.trim();

    final line2 = [if (c.isNotEmpty) c, if (p.isNotEmpty) p].join(', ').trim();

    shippingAddressText.value = [
      if (a.isNotEmpty) a,
      if (line2.isNotEmpty) line2,
      if (shippingCountry.value.trim().isNotEmpty) shippingCountry.value,
    ].join('\n');
  }

  bool get hasShippingAddress => shippingAddressText.value.trim().isNotEmpty;

  // =========================
  // SHIPPING OPTIONS (بدون موديل)
  final shippingId = 'standard'.obs;

  final shippingOptions = <Map<String, dynamic>>[
    {
      "id": "standard",
      "title": "Standard",
      "eta": "5-7 days",
      "price": "FREE",
      "icon": null,
    },
    {
      "id": "express",
      "title": "Express",
      "eta": "1-2 days",
      "price": "\$12,00",
      "note": "Delivered on or before Thursday, 23 April 2020",
      "icon": null,
    },
  ].obs;


  // =========================
  // PAYMENT METHOD
  final paymentMethodId = 'cod'.obs;
  void setPaymentMethodId(String id) => paymentMethodId.value = id;
  bool get isWalletPayment => paymentMethodId.value == 'wallet';

  // Wallet fields
  final receiverName = ''.obs;
  final walletNumber = ''.obs;


  // =========================
  // CART ACTIONS
  void removeFromCart(String id) {
    cartItems.removeWhere((e) => e.id == id);
    if (cartItems.isEmpty && isPayment) backToCart();
  }

  void addToCart(HomeProductItem item) {
    cartItems.add(item);
  }

  // =========================
  // CONFIRM PAY (mock)
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
  void onInit() {
    super.onInit();

    // ✅ init shipping controllers once
    shippingAddressCtrl = TextEditingController();
    shippingCityCtrl = TextEditingController();
    shippingPostcodeCtrl = TextEditingController();

    _mock();
  }

  @override
  void onClose() {
    shippingAddressCtrl.dispose();
    shippingCityCtrl.dispose();
    shippingPostcodeCtrl.dispose();
    super.onClose();
  }

  void _mock() {
    cartItems.addAll([
      HomeProductItem(
        id: '1',
        title: 'Pink Dress',
        imageUrl: 'https://picsum.photos/200',
        price: 17,
      ),
      HomeProductItem(
        id: '2',
        title: 'Summer Shirt',
        imageUrl: 'https://picsum.photos/201',
        price: 17,
      ),
    ]);

    wishlistItems.addAll([
      HomeProductItem(
        id: '3',
        title: 'Wishlist Item',
        imageUrl: 'https://picsum.photos/202',
        price: 17,
      ),
    ]);

    // قيم افتراضية للاختبار (Payment)
    receiverName.value = 'Zain';
    walletNumber.value = '777123456';
    paymentMethodId.value = 'cod';

    // =========================
    // اختبار العنوان:
    // ✅ لو تبغى يظهر زر الإضافة (+) خلّيه فاضي:
    // shippingAddressText.value = '';

    // ✅ لو تبغى اختبار "التعديل" حط قيم:
    shippingCountry.value = 'India';
    shippingAddressCtrl.text = 'Magadi Main Rd, next to Prasanna Theatre';
    shippingCityCtrl.text = 'Bengaluru';
    shippingPostcodeCtrl.text = '560023';
    _commitShippingAddress();
  }
}
