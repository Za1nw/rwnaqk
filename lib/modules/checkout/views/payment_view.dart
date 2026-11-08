import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

/// شاشة إتمام الطلب والدفع (Checkout & Payment Screen)
/// مرتبطة منطقياً وتصميمياً بـ CartController و PaymentController
class PaymentScreen extends GetView<PaymentController> {
  const PaymentScreen({super.key});

  void _openShippingSheet(BuildContext context, {required bool isEdit}) {
    final cart = Get.find<CartController>();
    if (isEdit) {
      cart.prepareEditShipping();
    } else {
      cart.prepareAddShipping();
    }

    ShippingAddressSheet.showShipping(
      context,
      addressController: cart.shippingAddressCtrl,
      cityController: cart.shippingCityCtrl,
      postcodeController: cart.shippingPostcodeCtrl,
      country: cart.selectedShippingCountryLabel,
      countries: cart.shippingCountries,
      onCountryChanged: (v) {
        if (v != null) cart.setShippingCountry(v);
      },
      onSave: () {
        cart.saveShippingFromForm();
        Navigator.pop(context);
      },
    );
  }

  void _openContactSheet(BuildContext context) {
    final cart = Get.find<CartController>();
    cart.prepareEditContact();

    ShippingAddressSheet.showContact(
      context,
      phoneController: cart.contactPhoneCtrl,
      emailController: cart.contactEmailCtrl,
      onSave: () {
        cart.saveContactFromForm();
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cart = Get.find<CartController>();

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF140A13)
          : const Color(0xFFFBF8FA),
      bottomNavigationBar: Obx(() {
        final isWallet = controller.isWalletPayment;
        final hasReceipt = controller.hasReceipt;
        final canCheckout = controller.canConfirmOrder;
        final isSubmitting = controller.isSubmitting.value;

        String? helper;
        if (isWallet && !hasReceipt) {
          helper = 'يرجى إرفاق صورة السند للمتابعة';
        } else if (cart.hasCoupon) {
          helper =
              'شامل خصم ${cart.couponDiscountPercent.value}% (${cart.couponCode.value})';
        } else {
          helper = AppCheckoutUtils.inlineSummary([
            cart.selectedShippingTitle,
            controller.paymentMethodLabel,
          ]);
        }

        return CartTotalBar(
          total: cart.total,
          enabled: canCheckout && !isSubmitting,
          totalLabel: Tk.cartTotal.tr,
          helperText: helper,
          checkoutText: 'مراجعة وتأكيد الطلب',
          checkoutIcon: Icons.arrow_back_rounded,
          buttonWidth: 175,
          onCheckout: () {
            controller.proceedToConfirmation();
          },
        );
      }),
      body: SafeArea(
        child: Obx(() {
          if (cart.cartItems.isEmpty) {
            return _PaymentEmptyState(onBack: cart.backToCart);
          }

          return Column(
            children: [
              // Custom Top Header
              _buildTopBar(context, cart),

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
                        address: cart.shippingAddressText,
                        onEdit: () => _openShippingSheet(
                          context,
                          isEdit: cart.hasShippingAddress,
                        ),
                        allowAddWhenEmpty: true,
                        emptyHint: Tk.cartAddShippingDetails.tr,
                      ),

                      const SizedBox(height: 12),

                      // Contact Information Section
                      PaymentContactSection(
                        lines: cart.contactLines,
                        onEdit: () => _openContactSheet(context),
                      ),

                      const SizedBox(height: 16),

                      // Order Items Preview Section
                      PaymentItemsHeader(
                        title: Tk.cartPaymentItems.tr,
                        count: cart.itemsCount,
                      ),

                      const SizedBox(height: 10),

                      _buildItemsPreviewCard(context, cart),

                      const SizedBox(height: 18),

                      // Shipping Delivery Options (Standard vs Express)
                      ShippingMethodSelector(
                        headerTitle: Tk.cartPaymentShippingOptions.tr,
                        selectedId: cart.selectedShippingId.value,
                        onChanged: cart.setShipping,
                        options: cart.shippingOptions
                            .map(AppCheckoutUtils.cartShippingTileData)
                            .toList(growable: false),
                      ),

                      const SizedBox(height: 18),

                      // Payment Method Section (COD vs Wallets)
                      const _PaymentMethodBlock(),

                      // Upload Receipt Card (if wallet payment)
                      Obx(() {
                        if (!controller.isWalletPayment) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: PaymentReceiptUploadCard(
                            imageFile: controller.receiptImage.value,
                            onPickImage: controller.pickReceiptImage,
                            onRemoveImage: controller.removeReceiptImage,
                          ),
                        );
                      }),

                      const SizedBox(height: 18),

                      // Final Order Payment Summary Card
                      _PaymentSummaryCard(
                        subtotal: cart.itemsSubtotal,
                        hasCoupon: cart.hasCoupon,
                        couponCode: cart.couponCode.value,
                        couponDiscountAmount: cart.couponDiscountAmount,
                        shippingFeeText: cart.shippingFeeText,
                        shippingFee: cart.shippingFee,
                        total: cart.total,
                        shippingTitle: cart.selectedShippingTitle,
                        paymentMethod: controller.paymentMethodLabel,
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
  Widget _buildTopBar(BuildContext context, CartController cart) {
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
            onTap: cart.backToCart,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: isDark
                  ? BrandColors.gold.withValues(alpha: 0.15)
                  : BrandColors.burgundy.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${cart.itemsCount} عناصر',
              style: TextStyle(
                color: isDark ? BrandColors.gold : BrandColors.burgundy,
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
                fontFamily: 'Cairo',
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
  Widget _buildItemsPreviewCard(BuildContext context, CartController cart) {
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
          for (var i = 0; i < cart.cartItems.length; i++) ...[
            MiniItemPriceTile(
              imageUrl: cart.cartItems[i].imageUrl,
              badgeCount: cart.quantityOf(cart.cartItems[i].id),
              title: cart.cartItems[i].title.tr,
              subtitle: AppCheckoutUtils.paymentItemSubtitle(
                cart.cartItems[i],
                quantity: cart.quantityOf(cart.cartItems[i].id),
              ),
              priceText: AppMoneyUtils.riyal(
                cart.lineTotalOf(cart.cartItems[i]),
              ),
            ),
            if (i != cart.cartItems.length - 1)
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
  final bool hasCoupon;
  final String couponCode;
  final double couponDiscountAmount;
  final String shippingFeeText;
  final double shippingFee;
  final double total;
  final String shippingTitle;
  final String paymentMethod;

  const _PaymentSummaryCard({
    required this.subtotal,
    required this.hasCoupon,
    required this.couponCode,
    required this.couponDiscountAmount,
    required this.shippingFeeText,
    required this.shippingFee,
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

          // Subtotal
          _SummaryRow(
            label: Tk.cartSubtotal.tr,
            value: AppMoneyUtils.riyal(subtotal),
            isDark: isDark,
          ),

          // Coupon Discount if active
          if (hasCoupon) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'خصم الكوبون ($couponCode)',
              value: '- ${AppMoneyUtils.riyal(couponDiscountAmount)}',
              isHighlight: true,
              isDark: isDark,
            ),
          ],

          const SizedBox(height: 8),

          // Shipping details
          _SummaryRow(
            label: Tk.cartPaymentShipping.tr,
            value: AppCheckoutUtils.inlineSummary([
              shippingTitle,
              shippingFee <= 0 ? 'مجاني' : AppMoneyUtils.riyal(shippingFee),
            ]),
            isHighlight: shippingFee <= 0,
            isDark: isDark,
          ),

          const SizedBox(height: 8),

          // Payment method
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

          // Final Total
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
  final bool isHighlight;
  final bool isDark;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.isHighlight = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    Color valueColor;

    if (emphasize) {
      color = isDark ? Colors.white : const Color(0xFF1E0A17);
      valueColor = isDark ? BrandColors.gold : BrandColors.burgundy;
    } else if (isHighlight) {
      color = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
      valueColor = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
    } else {
      color = isDark ? Colors.white70 : const Color(0xFF6E5664);
      valueColor = isDark ? Colors.white : const Color(0xFF1E0A17);
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: emphasize
                  ? FontWeight.w900
                  : (isHighlight ? FontWeight.w800 : FontWeight.w700),
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
