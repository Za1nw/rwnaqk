import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/cart/shipping_address_sheet.dart';

import '../../controllers/cart_controller.dart';

import 'package:rwnaqk/widgets/cart/cart_header.dart';
import 'package:rwnaqk/widgets/cart/address_section.dart';

import 'package:rwnaqk/widgets/cart/payment_items_header.dart';
import 'package:rwnaqk/widgets/cart/miniItem_price_tile.dart';
import 'package:rwnaqk/widgets/cart/shipping_method_selector.dart';
import 'package:rwnaqk/widgets/cart/payment_method_section.dart';
import '../../widgets/app_button.dart';

class PaymentScreen extends GetView<CartController> {
  const PaymentScreen({super.key});
  void _openShippingSheet(BuildContext context) {
    ShippingAddressSheet.showShipping(
      context,
      addressController: TextEditingController(
        text: 'Magadi Main Rd, next to Prasanna Theatre',
      ),
      cityController: TextEditingController(text: 'Bengaluru'),
      postcodeController: TextEditingController(text: '560023'),
      country: 'India',
      countries: const ['India', 'Yemen', 'Saudi Arabia', 'UAE'],
      onCountryChanged: (v) {
        debugPrint('Selected country: $v');
      },
      onSave: () {
        debugPrint('Shipping saved');
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      bottomNavigationBar: Obx(() {
        final totalText = _formatMoney(controller.total);
        return _PaymentBottomBar(
          totalText: totalText,
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
              // =========================
              // TOP: Header + Shipping + Contact (كلها Edit)
              CartHeader(title: 'Payment', count: controller.cartItems.length),
              const SizedBox(height: 12),

              // Shipping (قد تكون فاضية مستقبلاً -> تسمح بـ Add)
              AddressSection(
                title: 'Shipping Address',
                address: 'Magadi Main Rd ...', // بيانات وهمية حالياً
                onEdit: () => _openShippingSheet(context),

                allowAddWhenEmpty: true,
                emptyHint: 'اضف عنوان الشحن',
              ),

              const SizedBox(height: 12),

              // Contact (لن تكون فاضية مستقبلاً -> Edit فقط)
              AddressSection(
                title: 'Contact Information',
                lines: const [
                  '+91987654321',
                  'gmail@example.com',
                ], // بيانات وهمية
                onEdit: () {
                  // افتح شيت/صفحة تعديل التواصل
                },
                allowAddWhenEmpty: false, // ✅ ما نعرض Add هنا
                emptyHint: 'اضف معلومات التواصل',
              ),

              const SizedBox(height: 18),

              // =========================
              // Items header + discount
              Obx(() {
                return PaymentItemsHeader(
                  title: 'Items',
                  count: controller.cartItems.length,
                  discountText: '5% Discount',
                  onRemoveDiscount: () {},
                );
              }),

              const SizedBox(height: 10),

              // =========================
              // Items list (من السلة)
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
                        priceText: _formatMoney(item.price),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              }),

              const SizedBox(height: 20),

              // =========================
              // Shipping Options
              Obx(() {
                return ShippingMethodSelector(
                  headerTitle: "Shipping Options",
                  selectedId: controller.selectedShippingId.value,
                  onChanged: controller.setShipping,
                  options: [
                    {
                      "id": "standard",
                      "title": "Standard",
                      "eta": "5-7 days",
                      "price": "FREE",
                      "note": "Delivered on or before Thursday, 23 April 2020",
                    },
                    {
                      "id": "express",
                      "title": "Express",
                      "eta": "1-2 days",
                      "price": "\$12.00",
                      "note": "Fast delivery (extra fees may apply)",
                    },
                  ],
                );
              }),

              const SizedBox(height: 20),

              // =========================
              // Payment Method
              const _PaymentMethodBlock(),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMoney(num v) => '\$${v.toStringAsFixed(2)}';
}

class _PaymentMethodBlock extends StatefulWidget {
  const _PaymentMethodBlock();

  @override
  State<_PaymentMethodBlock> createState() => _PaymentMethodBlockState();
}

class _PaymentMethodBlockState extends State<_PaymentMethodBlock> {
  late final TextEditingController receiverCtrl;
  late final TextEditingController walletCtrl;

  @override
  void initState() {
    super.initState();
    final c = Get.find<CartController>();

    receiverCtrl = TextEditingController(text: c.receiverName.value);
    walletCtrl = TextEditingController(text: c.walletNumber.value);
  }

  @override
  void dispose() {
    receiverCtrl.dispose();
    walletCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();

    return Obx(
      () => PaymentMethodSection(
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

        infoMessage: controller.paymentMethodId.value == 'wallet'
            ? 'Use any company below. Name & number are unified.'
            : 'You will pay cash upon delivery.',
      ),
    );
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
