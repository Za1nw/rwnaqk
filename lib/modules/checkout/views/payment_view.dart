import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_checkout_utils.dart';
import 'package:rwnaqk_frontend/core/utils/app_money_utils.dart';
import 'package:rwnaqk_frontend/core/widgets/app_button.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_empty_state.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_controller.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/address_section.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/cart_checkout_stepper.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/cart_total_bar.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/mini_item_price_tile.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/payment_contact_section.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/payment_items_header.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/payment_method_section.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/payment_receipt_upload_card.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/shipping_address_sheet.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/shipping_method_selector.dart';
import 'package:rwnaqk_frontend/modules/checkout/controllers/payment_controller.dart';

class PaymentScreen extends GetView<CartController> {
  // حالة صورة سند التحويل
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

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF140A13)
          : const Color(0xFFFBF8FA),
      bottomNavigationBar: Obx(() {
        final payment = Get.find<PaymentController>();
        final isWallet = payment.isWalletPayment;
        final hasReceipt = _receiptImage.value != null;
        final canCheckout = controller.canCheckout && (!isWallet || hasReceipt);

        return CartTotalBar(
          total: controller.total,
          enabled: canCheckout,
          totalLabel: Tk.cartTotal.tr,
          helperText: isWallet && !hasReceipt
              ? 'يرجى إرفاق صورة السند للمتابعة'
              : AppCheckoutUtils.inlineSummary([
                  controller.selectedShippingTitle,
                  payment.paymentMethodLabel,
                ]),
          checkoutText: Tk.cartPaymentConfirmOrder.tr,
          checkoutIcon: Icons.check_circle_outline_rounded,
          buttonWidth: 190,
          onCheckout: () {
            if (isWallet && !hasReceipt) {
              Get.snackbar(
                'تنبيه الدفع',
                'يرجى إرفاق صورة سند أو إشعار التحويل البنكي لإتمام الطلب',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFFEF4444),
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
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

          return Column(
            children: [
              // Custom Top Header
              _buildTopBar(context),

              // Checkout Stepper (Step 2: Shipping & Payment)
              const CartCheckoutStepper(currentStep: 2),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Security Guarantee Banner
                      _buildSecurityBanner(context),

                      const SizedBox(height: 14),

                      // Delivery Address Section
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

                      // Contact Information Section
                      PaymentContactSection(
                        lines: controller.contactLines,
                        onEdit: () => _openContactSheet(context),
                      ),

                      const SizedBox(height: 16),

                      // Order Items Preview Section
                      PaymentItemsHeader(
                        title: Tk.cartPaymentItems.tr,
                        count: controller.itemsCount,
                      ),

                      const SizedBox(height: 10),

                      _buildItemsPreviewCard(context),

                      const SizedBox(height: 18),

                      // Shipping Delivery Options
                      ShippingMethodSelector(
                        headerTitle: Tk.cartPaymentShippingOptions.tr,
                        selectedId: controller.selectedShippingId.value,
                        onChanged: controller.setShipping,
                        options: controller.shippingOptions
                            .map(AppCheckoutUtils.cartShippingTileData)
                            .toList(growable: false),
                      ),

                      const SizedBox(height: 18),

                      // Payment Method Section (COD vs Wallets)
                      const _PaymentMethodBlock(),

                      // Upload Receipt Card (if wallet payment)
                      Obx(() {
                        if (!payment.isWalletPayment) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: PaymentReceiptUploadCard(
                            imageFile: _receiptImage.value,
                            onPickImage: _pickReceiptImage,
                            onRemoveImage: _removeReceiptImage,
                          ),
                        );
                      }),

                      const SizedBox(height: 18),

                      // Final Order Payment Summary Card
                      _PaymentSummaryCard(
                        subtotal: controller.itemsSubtotal,
                        shippingFeeText: controller.shippingFeeText,
                        total: controller.total,
                        shippingTitle: controller.selectedShippingTitle,
                        paymentMethod: payment.paymentMethodLabel,
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Top Bar with back button to Cart
  Widget _buildTopBar(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 16, 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E0D1A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? BrandColors.gold.withValues(alpha: 0.12)
                : const Color(0xFFEBE0E6),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          InkWell(
            onTap: controller.backToCart,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFF7F1F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: isDark ? Colors.white : const Color(0xFF1E0A17),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Text(
              Tk.cartPaymentTitle.tr,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E0A17),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFamily: 'Cairo',
              ),
            ),
          ),

          // Items count pill
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: isDark
                    ? BrandColors.gold.withValues(alpha: 0.15)
                    : BrandColors.burgundy.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${controller.itemsCount} عناصر',
                style: TextStyle(
                  color: isDark ? BrandColors.gold : BrandColors.burgundy,
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Security Trust Banner
  Widget _buildSecurityBanner(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF24111F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? BrandColors.gold.withValues(alpha: 0.16)
              : const Color(0xFFEDE3EA),
          width: 1.1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark
                  ? BrandColors.gold.withValues(alpha: 0.12)
                  : BrandColors.burgundy.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_user_rounded,
              color: isDark ? BrandColors.gold : BrandColors.burgundy,
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
                    color: isDark ? Colors.white : const Color(0xFF1E0A17),
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  Tk.cartPaymentReviewSubtitle.tr,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : const Color(0xFF7E6674),
                    fontWeight: FontWeight.w600,
                    fontSize: 11.5,
                    fontFamily: 'Cairo',
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Order Items Preview Card
  Widget _buildItemsPreviewCard(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF24111F) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? BrandColors.gold.withValues(alpha: 0.16)
              : const Color(0xFFEDE3EA),
          width: 1.1,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          for (var i = 0; i < controller.cartItems.length; i++) ...[
            MiniItemPriceTile(
              imageUrl: controller.cartItems[i].imageUrl,
              badgeCount: controller.quantityOf(controller.cartItems[i].id),
              title: controller.cartItems[i].title.tr,
              subtitle: AppCheckoutUtils.paymentItemSubtitle(
                controller.cartItems[i],
                quantity: controller.quantityOf(controller.cartItems[i].id),
              ),
              priceText: AppMoneyUtils.riyal(
                controller.lineTotalOf(controller.cartItems[i]),
              ),
            ),
            if (i != controller.cartItems.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFF3EAF0),
              ),
          ],
        ],
      ),
    );
  }
}

class _PaymentMethodBlock extends StatelessWidget {
  const _PaymentMethodBlock();

  @override
  Widget build(BuildContext context) {
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
    final isDark = context.isDark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF24111F) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? BrandColors.gold.withValues(alpha: 0.16)
              : const Color(0xFFEDE3EA),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 20,
                color: isDark ? BrandColors.gold : BrandColors.burgundy,
              ),
              const SizedBox(width: 8),
              Text(
                Tk.cartPaymentSummary.tr,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E0A17),
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _SummaryRow(
            label: Tk.cartSubtotal.tr,
            value: AppMoneyUtils.riyal(subtotal),
            isDark: isDark,
          ),

          const SizedBox(height: 8),

          _SummaryRow(
            label: Tk.cartPaymentShipping.tr,
            value: AppCheckoutUtils.inlineSummary([
              shippingTitle,
              shippingFeeText,
            ]),
            isDark: isDark,
          ),

          const SizedBox(height: 8),

          _SummaryRow(
            label: Tk.cartPaymentMethod.tr,
            value: paymentMethod,
            isDark: isDark,
          ),

          const SizedBox(height: 12),

          Divider(
            height: 1,
            thickness: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFF0E5EC),
          ),

          const SizedBox(height: 12),

          _SummaryRow(
            label: Tk.cartPaymentFinalTotal.tr,
            value: AppMoneyUtils.riyal(total),
            emphasize: true,
            isDark: isDark,
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
  final bool isDark;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = emphasize
        ? (isDark ? Colors.white : const Color(0xFF1E0A17))
        : (isDark ? Colors.white70 : const Color(0xFF6E5664));

    final valueColor = emphasize
        ? (isDark ? BrandColors.gold : BrandColors.burgundy)
        : (isDark ? Colors.white : const Color(0xFF1E0A17));

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
              fontSize: emphasize ? 14.5 : 12.5,
              fontFamily: 'Cairo',
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
              fontSize: emphasize ? 17 : 13,
              fontFamily: 'Cairo',
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
