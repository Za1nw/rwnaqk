import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_checkout_utils.dart';
import 'package:rwnaqk_frontend/core/utils/app_money_utils.dart';
import 'package:rwnaqk_frontend/core/widgets/app_button.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_empty_state.dart';
import 'package:rwnaqk_frontend/core/widgets/feedback/app_toast.dart';
import 'package:rwnaqk_frontend/modules/cart/providers/cart_providers.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/address_section.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/cart_checkout_stepper.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/cart_total_bar.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/mini_item_price_tile.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/payment_contact_section.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/payment_items_header.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/payment_method_section.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/payment_receipt_upload_card.dart';
import 'package:rwnaqk_frontend/modules/checkout/providers/checkout_providers.dart';
import 'package:rwnaqk_frontend/modules/customer/providers/addresses_providers.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

/// شاشة إتمام الطلب والدفع (Checkout & Payment Screen)
/// معتمدة كلياً على Riverpod 3.5.0 وخالية تماماً من GetX
class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key});

  Future<void> _pickReceipt(WidgetRef ref) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) {
        ref
            .read(checkoutFlowProvider.notifier)
            .setReceiptImage(File(picked.path));
      }
    } catch (e) {
      AppToast.error('تعذر اختيار الصورة: $e', title: 'خطأ');
    }
  }

  bool _validatePrerequisites({
    required CartState cart,
    required dynamic address,
    required CheckoutState checkout,
  }) {
    if (cart.isEmpty) {
      AppToast.warning(
        Tk.cartValidationCartEmpty.tr,
        title: Tk.cartValidationCartTitle.tr,
      );
      return false;
    }

    if (address == null || address.isEmpty) {
      AppToast.warning(
        Tk.cartValidationShippingMissing.tr,
        title: Tk.cartValidationShippingTitle.tr,
      );
      return false;
    }

    if (!address.isServiceable) {
      AppToast.warning(
        'العنوان المختار خارج نطاق التوصيل المدعوم حالياً. يرجى اختيار أو إضافة عنوان آخر.',
        title: 'خارج نطاق التوصيل',
      );
      return false;
    }

    if (checkout.isWalletPayment && !checkout.hasReceipt) {
      AppToast.warning(
        'يرجى إرفاق صورة سند أو إشعار التحويل للانتقال لمرحلة التأكيد',
        title: 'سند التحويل مطلوب',
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;
    final cart = ref.watch(cartProvider);
    final quote = ref.watch(cartQuoteProvider);
    final checkout = ref.watch(checkoutFlowProvider);
    final checkoutNotifier = ref.read(checkoutFlowProvider.notifier);
    final address = ref.watch(selectedAddressProvider) ??
        ref.watch(defaultAddressProvider);
    final contact = ref.watch(customerContactInfoProvider);

    final finalTotal = quote.isValid
        ? quote.grandTotal
        : (cart.subtotal + quote.shippingFee - quote.discountAmount);

    final isWallet = checkout.isWalletPayment;
    final hasReceipt = checkout.hasReceipt;
    final canCheckout = cart.isNotEmpty &&
        address != null &&
        !address.isEmpty &&
        (!isWallet || hasReceipt);

    String? helper;
    if (isWallet && !hasReceipt) {
      helper = 'يرجى إرفاق صورة السند للمتابعة';
    } else if (quote.discountAmount > 0) {
      helper = 'شامل الخصم (${quote.couponCode ?? "كوبون"})';
    } else {
      helper = AppCheckoutUtils.inlineSummary([
        'توصيل قياسي',
        checkout.paymentMethodLabel,
      ]);
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF140A13)
          : const Color(0xFFFBF8FA),
      bottomNavigationBar: CartTotalBar(
        total: finalTotal,
        enabled: canCheckout && !checkout.isSubmitting,
        totalLabel: Tk.cartTotal.tr,
        helperText: helper,
        checkoutText: 'مراجعة وتأكيد الطلب',
        checkoutIcon: Icons.arrow_back_rounded,
        buttonWidth: 175,
        onCheckout: () {
          if (_validatePrerequisites(
            cart: cart,
            address: address,
            checkout: checkout,
          )) {
            AppNav.toNamed(AppRoutes.orderConfirmation);
          }
        },
      ),
      body: SafeArea(
        child: cart.isEmpty
            ? _PaymentEmptyState(onBack: () => Navigator.of(context).pop())
            : Column(
                children: [
                  // Custom Top Header
                  _buildTopBar(context, cart.totalQuantity),

                  // Checkout Stepper (Step 2: Shipping & Payment)
                  const CartCheckoutStepper(currentStep: 2),

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Security Guarantee Banner
                          _buildSecurityBanner(context),

                          const SizedBox(height: 14),

                          // Delivery Address Section
                          AddressSection(
                            title: Tk.cartShippingAddress.tr,
                            address: address?.formatted ?? '',
                            onEdit: () =>
                                AppNav.toNamed(AppRoutes.addresses),
                            allowAddWhenEmpty: true,
                            emptyHint: Tk.cartAddShippingDetails.tr,
                          ),

                          const SizedBox(height: 12),

                          // Contact Information Section
                          PaymentContactSection(
                            lines: contact.lines,
                            onEdit: () =>
                                AppNav.toNamed(AppRoutes.editProfile),
                          ),

                          const SizedBox(height: 16),

                          // Order Items Preview Section
                          PaymentItemsHeader(
                            title: Tk.cartPaymentItems.tr,
                            count: cart.totalQuantity,
                          ),

                          const SizedBox(height: 10),

                          _buildItemsPreviewCard(context, cart),

                          const SizedBox(height: 18),

                          // Payment Method Section (COD vs Wallets)
                          PaymentMethodSection(
                            titleText: Tk.cartPaymentMethod.tr,
                            cashTitle: Tk.cartPaymentCodTitle.tr,
                            cashSubtitle: Tk.cartPaymentCodSubtitle.tr,
                            walletTitle: Tk.cartPaymentWalletTitle.tr,
                            walletSubtitle: Tk.cartPaymentWalletSubtitle.tr,
                            receiverNameLabel: Tk.cartPaymentReceiverName.tr,
                            walletNumberLabel: Tk.cartPaymentWalletNumber.tr,
                            walletAccounts: checkout.walletAccounts,
                            selectedId: checkout.paymentMethodId,
                            onChanged: checkoutNotifier.setPaymentMethod,
                            selectedWalletAccountIndex:
                                checkout.selectedWalletAccountIndex,
                            onWalletAccountChanged:
                                checkoutNotifier.selectWalletAccount,
                            infoMessage: checkout.isWalletPayment
                                ? Tk.cartPaymentWalletInfoMessage.tr
                                : Tk.cartPaymentCodInfoMessage.tr,
                          ),

                          // Upload Receipt Card (if wallet payment)
                          if (checkout.isWalletPayment)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: PaymentReceiptUploadCard(
                                imageFile: checkout.receiptImage,
                                onPickImage: () => _pickReceipt(ref),
                                onRemoveImage: checkoutNotifier.clearReceipt,
                              ),
                            ),

                          const SizedBox(height: 18),

                          // Final Order Payment Summary Card
                          _PaymentSummaryCard(
                            subtotal: cart.subtotal,
                            hasCoupon: quote.discountAmount > 0,
                            couponCode: quote.couponCode ?? '',
                            couponDiscountAmount: quote.discountAmount,
                            shippingFeeText: quote.shippingFee <= 0
                                ? 'مجاني'
                                : AppMoneyUtils.riyal(quote.shippingFee),
                            shippingFee: quote.shippingFee,
                            total: finalTotal,
                            shippingTitle: 'توصيل قياسي',
                            paymentMethod: checkout.paymentMethodLabel,
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Top Bar with back button to Cart
  Widget _buildTopBar(BuildContext context, int count) {
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
            onTap: () => Navigator.of(context).pop(),
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
              '$count عناصر',
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
  Widget _buildItemsPreviewCard(BuildContext context, CartState cart) {
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
          for (var i = 0; i < cart.items.length; i++) ...[
            MiniItemPriceTile(
              imageUrl: cart.items[i].imageUrl,
              badgeCount: cart.items[i].quantity,
              title: cart.items[i].title.tr,
              subtitle: AppCheckoutUtils.paymentItemSubtitle(
                cart.items[i].originalProduct,
                quantity: cart.items[i].quantity,
              ),
              priceText: AppMoneyUtils.riyal(cart.items[i].lineTotal),
            ),
            if (i != cart.items.length - 1)
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
