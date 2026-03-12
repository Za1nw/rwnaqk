import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/controllers/cart/cart_controller.dart';
import 'package:rwnaqk/core/utils/app_money_utils.dart';
import 'package:rwnaqk/widgets/app_button.dart';
import 'package:rwnaqk/widgets/cart/address_section.dart';
import 'package:rwnaqk/widgets/cart/cart_header.dart';
import 'package:rwnaqk/widgets/cart/miniItem_price_tile.dart';
import 'package:rwnaqk/widgets/cart/payment_contact_section.dart';
import 'package:rwnaqk/widgets/cart/payment_items_header.dart';
import 'package:rwnaqk/widgets/cart/payment_method_section.dart';
import 'package:rwnaqk/widgets/cart/shipping_address_sheet.dart';
import 'package:rwnaqk/widgets/cart/shipping_method_selector.dart';

class PaymentScreen extends GetView<CartController> {
  const PaymentScreen({super.key});

  void _openShippingSheet(BuildContext context, {required bool isEdit}) {
    if (isEdit) {
      controller.prepareEditShipping();
    } else {
      controller.prepareAddShipping();
    }

    ShippingAddressSheet.showShipping(
      context,
      addressController: controller.shippingAddressCtrl,
      cityController: controller.shippingCityCtrl,
      postcodeController: controller.shippingPostcodeCtrl,
      country: controller.shippingAddress.value.country,
      countries: controller.shippingCountries,
      onCountryChanged: (v) {
        if (v != null) controller.setShippingCountry(v);
      },
      onSave: () {
        controller.saveShippingFromForm();
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      bottomNavigationBar: Obx(() {
        return _PaymentBottomBar(
          totalText: AppMoneyUtils.currency(controller.total),
          onPay: controller.payNow,
        );
      }),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => CartHeader(
                  title: 'Payment',
                  count: controller.cartItems.length,
                ),
              ),
              const SizedBox(height: 12),

              Obx(
                () => AddressSection(
                  title: 'Shipping Address',
                  address: controller.shippingAddressText,
                  onEdit: () => _openShippingSheet(
                    context,
                    isEdit: controller.hasShippingAddress,
                  ),
                  allowAddWhenEmpty: true,
                  emptyHint: 'اضف عنوان الشحن',
                ),
              ),

              const SizedBox(height: 12),

              Obx(
                () => PaymentContactSection(
                  lines: controller.contactLines,
                  onEdit: () {
                    Get.snackbar('Info', 'Contact edit action');
                  },
                ),
              ),

              const SizedBox(height: 18),

              Obx(
                () => PaymentItemsHeader(
                  title: 'Items',
                  count: controller.cartItems.length,
                  discountText: '5% Discount',
                  onRemoveDiscount: () {},
                ),
              ),

              const SizedBox(height: 10),

              Obx(() {
                final items = controller.cartItems;
                return Column(
                  children: [
                    for (final item in items) ...[
                      MiniItemPriceTile(
                        imageUrl: item.imageUrl,
                        badgeCount: 1,
                        title: item.title,
                        subtitle: 'consectetur.',
                        priceText: AppMoneyUtils.currency(item.price),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              }),

              const SizedBox(height: 20),

              Obx(() {
                return ShippingMethodSelector(
                  headerTitle: 'Shipping Options',
                  selectedId: controller.selectedShippingId.value,
                  onChanged: controller.setShipping,
                  options: controller.shippingOptions
                      .map(
                        (e) => {
                          'id': e.id,
                          'title': e.title,
                          'eta': e.eta,
                          'price': e.priceText,
                          'note': e.note,
                          'icon': e.icon,
                        },
                      )
                      .toList(),
                );
              }),

              const SizedBox(height: 20),

              const _PaymentMethodBlock(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodBlock extends StatelessWidget {
  const _PaymentMethodBlock();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();

    return Obx(() {
      return PaymentMethodSection(
        titleText: 'Payment Method',
        cashTitle: 'Cash on Delivery',
        cashSubtitle: 'Pay when you receive',
        walletTitle: 'Wallet Transfer',
        walletSubtitle: 'Transfer via partners',
        receiverNameLabel: 'Receiver name',
        walletNumberLabel: 'Wallet number',
        receiverNameValue: controller.receiverName.value,
        walletNumberValue: controller.walletNumber.value,
        walletCompanies: const [
          WalletCompany(
            name: 'Jib',
            icon: Icons.account_balance_wallet_outlined,
          ),
          WalletCompany(name: 'OneCash', icon: Icons.payments_outlined),
          WalletCompany(name: 'Kuraimi', icon: Icons.account_balance),
          WalletCompany(name: 'M-Floos', icon: Icons.currency_exchange),
        ],
        selectedId: controller.paymentMethodId.value,
        onChanged: controller.setPaymentMethodId,
        infoMessage: controller.isWalletPayment
            ? 'Use any company below. Name & number are unified.'
            : 'You will pay cash upon delivery.',
      );
    });
  }
}

class _PaymentBottomBar extends StatelessWidget {
  final String totalText;
  final VoidCallback onPay;

  const _PaymentBottomBar({required this.totalText, required this.onPay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: context.card,
        border: Border(top: BorderSide(color: context.border.withOpacity(.3))),
      ),
      child: Row(
        children: [
          Text(
            'Total $totalText',
            style: TextStyle(
              color: context.foreground,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 170,
            child: AppButton(text: 'Pay', onPressed: onPay),
          ),
        ],
      ),
    );
  }
}
