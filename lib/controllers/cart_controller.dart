import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/home_product_item.dart';
import '../models/shipping_option_model.dart';
import '../models/shipping_address_model.dart';
import '../models/contact_info_model.dart';

enum CartStep { cart, payment }

class CartController extends GetxController {
  // =========================
  // CART DATA
  final cartItems = <HomeProductItem>[].obs;
  final wishlistItems = <HomeProductItem>[].obs;

  double get total => cartItems.fold(0.0, (sum, e) => sum + e.price);
  bool get isEmpty => cartItems.isEmpty;

  // =========================
  // FLOW
  final step = CartStep.cart.obs;
  bool get isPayment => step.value == CartStep.payment;

  void openPayment() {
    if (cartItems.isEmpty) return;
    Get.toNamed('/payment');
  }

  void backToCart() => step.value = CartStep.cart;

  // =========================
  // SHIPPING ADDRESS FORM CONTROLLERS
  late final TextEditingController shippingAddressCtrl;
  late final TextEditingController shippingCityCtrl;
  late final TextEditingController shippingPostcodeCtrl;

  final shippingCountries = const ['Yemen', 'Saudi Arabia', 'UAE', 'India'];

  final shippingAddress = ShippingAddressModel.empty().obs;

  bool get hasShippingAddress => !shippingAddress.value.isEmpty;
  String get shippingAddressText => shippingAddress.value.formatted;

  void setShippingCountry(String value) {
    shippingAddress.value = shippingAddress.value.copyWith(country: value);
  }

  void fillShippingFormFromState() {
    shippingAddressCtrl.text = shippingAddress.value.addressLine;
    shippingCityCtrl.text = shippingAddress.value.city;
    shippingPostcodeCtrl.text = shippingAddress.value.postcode;
  }

  void clearShippingForm() {
    shippingAddressCtrl.clear();
    shippingCityCtrl.clear();
    shippingPostcodeCtrl.clear();
    shippingAddress.value = shippingAddress.value.copyWith(
      country: shippingAddress.value.country.isEmpty
          ? 'Yemen'
          : shippingAddress.value.country,
    );
  }

  void prepareAddShipping() {
    shippingAddress.value = ShippingAddressModel.empty();
    clearShippingForm();
  }

  void prepareEditShipping() {
    fillShippingFormFromState();
  }

  void saveShippingFromForm() {
    shippingAddress.value = ShippingAddressModel(
      country: shippingAddress.value.country,
      addressLine: shippingAddressCtrl.text.trim(),
      city: shippingCityCtrl.text.trim(),
      postcode: shippingPostcodeCtrl.text.trim(),
    );
  }

  // =========================
  // SHIPPING OPTION
  final selectedShippingId = 'standard'.obs;

  final shippingOptions = <ShippingOptionModel>[
    const ShippingOptionModel(
      id: 'standard',
      title: 'Standard',
      eta: '5-7 days',
      priceText: 'FREE',
    ),
    const ShippingOptionModel(
      id: 'express',
      title: 'Express',
      eta: '1-2 days',
      priceText: '\$12.00',
      note: 'Fast delivery (extra fees may apply)',
    ),
  ].obs;

  void setShipping(String id) {
    selectedShippingId.value = id;
  }

  // =========================
  // CONTACT
  final contactInfo = const ContactInfoModel(
    phone: '+91987654321',
    email: 'gmail@example.com',
  ).obs;

  List<String> get contactLines => contactInfo.value.lines;

  // =========================
  // PAYMENT
  final paymentMethodId = 'cod'.obs;

  final receiverName = 'Zain'.obs;
  final walletNumber = '777123456'.obs;

  bool get isWalletPayment => paymentMethodId.value == 'wallet';

  void setPaymentMethodId(String id) {
    paymentMethodId.value = id;
  }

  void setReceiverName(String value) {
    receiverName.value = value;
  }

  void setWalletNumber(String value) {
    walletNumber.value = value;
  }

  // =========================
  // ACTIONS
  void removeFromCart(String id) {
    cartItems.removeWhere((e) => e.id == id);
    if (cartItems.isEmpty && isPayment) {
      backToCart();
    }
  }

  void addToCart(HomeProductItem item) {
    cartItems.add(item);
  }

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

  // =========================
  // INIT / DISPOSE
  @override
  void onInit() {
    super.onInit();

    shippingAddressCtrl = TextEditingController();
    shippingCityCtrl = TextEditingController();
    shippingPostcodeCtrl = TextEditingController();

    seedMockData();
  }

  @override
  void onClose() {
    shippingAddressCtrl.dispose();
    shippingCityCtrl.dispose();
    shippingPostcodeCtrl.dispose();
    super.onClose();
  }

  // =========================
  // MOCK DATA
  void seedMockData() {
    cartItems.assignAll([
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

    wishlistItems.assignAll([
      HomeProductItem(
        id: '3',
        title: 'Wishlist Item',
        imageUrl: 'https://picsum.photos/202',
        price: 17,
      ),
    ]);

    shippingAddress.value = const ShippingAddressModel(
      country: 'India',
      addressLine: 'Magadi Main Rd, next to Prasanna Theatre',
      city: 'Bengaluru',
      postcode: '560023',
    );

    fillShippingFormFromState();
  }
}
