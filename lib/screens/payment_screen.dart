import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:rwnaqk/widgets/cart/payment_receipt_upload_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/cart/cart_controller.dart';
import 'package:rwnaqk/controllers/payment/payment_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/core/utils/app_checkout_utils.dart';
import 'package:rwnaqk/core/utils/app_money_utils.dart';
import 'package:rwnaqk/widgets/app_button.dart';
import 'package:rwnaqk/widgets/cart/address_section.dart';
import 'package:rwnaqk/widgets/cart/cart_header.dart';
import 'package:rwnaqk/widgets/cart/cart_total_bar.dart';
import 'package:rwnaqk/widgets/cart/miniItem_price_tile.dart';
import 'package:rwnaqk/widgets/cart/payment_contact_section.dart';
import 'package:rwnaqk/widgets/cart/payment_items_header.dart';
import 'package:rwnaqk/widgets/cart/payment_method_section.dart';
import 'package:rwnaqk/widgets/cart/shipping_address_sheet.dart';
import 'package:rwnaqk/widgets/cart/shipping_method_selector.dart';
import 'package:rwnaqk/widgets/common/app_empty_state.dart';

class PaymentScreen extends GetView<CartController> {
    // حالة صورة السند
    final Rx<File?> _receiptImage = Rx<File?>(null);

    Future<void> _pickReceiptImage() async {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        _receiptImage.value = File(picked.path);
      }
    }

    void _removeReceiptImage() {
      _receiptImage.value = null;
    }
  PaymentScreen({super.key});

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
      country: controller.selectedShippingCountryLabel,
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

  void _openContactSheet(BuildContext context) {
    controller.prepareEditContact();

    ShippingAddressSheet.showContact(
      context,
      phoneController: controller.contactPhoneCtrl,
      emailController: controller.contactEmailCtrl,
      onSave: () {
        controller.saveContactFromForm();
        Navigator.pop(context);
      },
    );
  }

  // Wallet info is admin-controlled. Edit sheet removed.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      bottomNavigationBar: Obx(() {
        final payment = Get.find<PaymentController>();
        final isWallet = payment.isWalletPayment;
        final hasReceipt = _receiptImage.value != null;
        final canCheckout = controller.canCheckout && (!isWallet || hasReceipt);
        return CartTotalBar(
          total: controller.total,
          enabled: canCheckout,
          totalLabel: Tk.cartTotal.tr,
          helperText: AppCheckoutUtils.inlineSummary([
            controller.selectedShippingTitle,
            payment.paymentMethodLabel,
          ]),
          checkoutText: Tk.cartPaymentConfirmOrder.tr,
          checkoutIcon: Icons.check_circle_outline_rounded,
          buttonWidth: 186,
          onCheckout: () {
            if (isWallet && !hasReceipt) {
              // إظهار رسالة تنبيه
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('يجب رفع صورة سند الحوالة أولاً')),
              );
              return;
            }
            controller.payNow();
          },
        );
      }),
      body: SafeArea(
        child: Obx(() {
          final payment = Get.find<PaymentController>();
          if (controller.cartItems.isEmpty) {
            return _PaymentEmptyState(onBack: controller.backToCart);
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 124),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CartHeader(
                  title: Tk.cartPaymentTitle.tr,
                  count: controller.itemsCount,
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: context.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: context.border.withOpacity(.35)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.primary.withOpacity(.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.verified_user_outlined,
                          color: context.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Tk.cartPaymentReviewTitle.tr,
                              style: TextStyle(
                                color: context.foreground,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Tk.cartPaymentReviewSubtitle.tr,
                              style: TextStyle(
                                color: context.mutedForeground,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                AddressSection(
                  title: Tk.cartShippingAddress.tr,
                  address: controller.shippingAddressText,
                  onEdit: () => _openShippingSheet(
                    context,
                    isEdit: controller.hasShippingAddress,
                  ),
                  allowAddWhenEmpty: true,
                  emptyHint: Tk.cartAddShippingDetails.tr,
                ),
                const SizedBox(height: 12),
                PaymentContactSection(
                  lines: controller.contactLines,
                  onEdit: () => _openContactSheet(context),
                ),
                const SizedBox(height: 18),
                PaymentItemsHeader(
                  title: Tk.cartPaymentItems.tr,
                  count: controller.itemsCount,
                ),
                const SizedBox(height: 10),
                Material(
                  color: context.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: context.border.withOpacity(.35)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        for (var i = 0;
                            i < controller.cartItems.length;
                            i++) ...[
                          MiniItemPriceTile(
                            imageUrl: controller.cartItems[i].imageUrl,
                            badgeCount: controller
                                .quantityOf(controller.cartItems[i].id),
                            title: controller.cartItems[i].title.tr,
                            subtitle: AppCheckoutUtils.paymentItemSubtitle(
                              controller.cartItems[i],
                              quantity: controller
                                  .quantityOf(controller.cartItems[i].id),
                            ),
                            priceText: AppMoneyUtils.currency(
                              controller.lineTotalOf(controller.cartItems[i]),
                            ),
                          ),
                          if (i != controller.cartItems.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: context.border.withOpacity(.18),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ShippingMethodSelector(
                  headerTitle: Tk.cartPaymentShippingOptions.tr,
                  selectedId: controller.selectedShippingId.value,
                  onChanged: controller.setShipping,
                  options: controller.shippingOptions
                      .map(AppCheckoutUtils.cartShippingTileData)
                      .toList(growable: false),
                ),
                const SizedBox(height: 20),
                _PaymentMethodBlock(),
                // واجهة رفع صورة السند
                Obx(() {
                  if (!payment.isWalletPayment) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 18.0, bottom: 0),
                    child: PaymentReceiptUploadCard(
                      imageFile: _receiptImage.value,
                      onPickImage: _pickReceiptImage,
                      onRemoveImage: _removeReceiptImage,
                    ),
                  );
                }),
                const SizedBox(height: 20),
                _PaymentSummaryCard(
                  subtotal: controller.itemsSubtotal,
                  shippingFeeText: controller.shippingFeeText,
                  total: controller.total,
                  shippingTitle: controller.selectedShippingTitle,
                  paymentMethod: payment.paymentMethodLabel,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}


class _PaymentMethodBlock extends StatelessWidget {
  const _PaymentMethodBlock();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();
    final payment = Get.find<PaymentController>();

    return Obx(() {
      return PaymentMethodSection(
        titleText: Tk.cartPaymentMethod.tr,
        cashTitle: Tk.cartPaymentCodTitle.tr,
        cashSubtitle: Tk.cartPaymentCodSubtitle.tr,
        walletTitle: Tk.cartPaymentWalletTitle.tr,
        walletSubtitle: Tk.cartPaymentWalletSubtitle.tr,
        receiverNameLabel: Tk.cartPaymentReceiverName.tr,
        walletNumberLabel: Tk.cartPaymentWalletNumber.tr,
        walletAccounts: payment.walletAccounts,
        selectedId: payment.paymentMethodId.value,
        onChanged: payment.setPaymentMethodId,
        selectedWalletAccountIndex: payment.selectedWalletAccountIndex.value,
        onWalletAccountChanged: payment.setSelectedWalletAccountIndex,
        infoMessage: payment.isWalletPayment
            ? Tk.cartPaymentWalletInfoMessage.tr
            : Tk.cartPaymentCodInfoMessage.tr,
      );
    });
  }
}

class _PaymentSummaryCard extends StatelessWidget {
  final double subtotal;
  final String shippingFeeText;
  final double total;
  final String shippingTitle;
  final String paymentMethod;

  const _PaymentSummaryCard({
    required this.subtotal,
    required this.shippingFeeText,
    required this.total,
    required this.shippingTitle,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.border.withOpacity(.35)),
        boxShadow: [
          BoxShadow(
            color: context.shadow.withOpacity(.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Tk.cartPaymentSummary.tr,
            style: TextStyle(
              color: context.foreground,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: Tk.cartSubtotal.tr,
            value: AppMoneyUtils.currency(subtotal),
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            label: Tk.cartPaymentShipping.tr,
            value: AppCheckoutUtils.inlineSummary([
              shippingTitle,
              shippingFeeText,
            ]),
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            label: Tk.cartPaymentMethod.tr,
            value: paymentMethod,
          ),
          Divider(
            height: 22,
            thickness: 1,
            color: context.border.withOpacity(.25),
          ),
          _SummaryRow(
            label: Tk.cartPaymentFinalTotal.tr,
            value: AppMoneyUtils.currency(total),
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = emphasize ? context.foreground : context.mutedForeground;
    final valueColor = emphasize ? context.primary : context.foreground;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
              fontSize: emphasize ? 13.5 : 12.5,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w900,
              fontSize: emphasize ? 15 : 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentEmptyState extends StatelessWidget {
  final VoidCallback onBack;

  const _PaymentEmptyState({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppEmptyState(
              icon: Icons.shopping_bag_outlined,
              title: Tk.cartPaymentNoItemsTitle.tr,
              subtitle: Tk.cartPaymentNoItemsSubtitle.tr,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 170,
              child: AppButton(
                text: Tk.cartPaymentBackToCart.tr,
                onPressed: onBack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
