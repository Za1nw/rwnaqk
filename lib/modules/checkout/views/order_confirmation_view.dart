import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_checkout_utils.dart';
import 'package:rwnaqk_frontend/core/utils/app_money_utils.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_controller.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/cart_checkout_stepper.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/cart_total_bar.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/mini_item_price_tile.dart';
import 'package:rwnaqk_frontend/modules/checkout/controllers/payment_controller.dart';

/// شاشة مرحلة التأكيد النهائية للطلب (Step 3: Confirmation)
///
/// تتيح للمشتري مراجعة كافة بيانات الطلب والشحن والدفع قبل الخصم أو التأكيد النهائي
class OrderConfirmationScreen extends GetView<PaymentController> {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return Scaffold(
      backgroundColor: context.background,
      bottomNavigationBar: Obx(() {
        final isSubmitting = controller.isSubmitting.value;

        return CartTotalBar(
          total: cart.total,
          enabled: !isSubmitting && cart.cartItems.isNotEmpty,
          totalLabel: Tk.cartTotal.tr,
          helperText: 'المبلغ الإجمالي المستحق شامل الضريبة والشحن',
          checkoutText: isSubmitting
              ? 'جاري تأكيد الطلب...'
              : 'تأكيد الطلب نهائياً',
          checkoutIcon: Icons.check_circle_rounded,
          buttonWidth: 175,
          onCheckout: () {
            controller.confirmAndSubmitOrder();
          },
        );
      }),
      body: SafeArea(
        child: Column(
          children: [
            // Header Top Bar
            _buildTopBar(context, cart),

            // Stepper: Step 3 (التأكيد)
            const CartCheckoutStepper(currentStep: 3),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Security & Quality Guarantee Banner
                    _buildSecurityBanner(context),

                    const SizedBox(height: 14),

                    // 1. Delivery & Contact Review Card
                    _buildDeliveryReviewCard(context, cart),

                    const SizedBox(height: 12),

                    // 2. Shipping Method Review Card
                    _buildShippingMethodReviewCard(context, cart),

                    const SizedBox(height: 12),

                    // 3. Payment Method & Receipt Review Card
                    _buildPaymentReviewCard(context),

                    const SizedBox(height: 14),

                    // 4. Ordered Items Preview Card
                    _buildItemsReviewCard(context, cart),

                    const SizedBox(height: 14),

                    // 5. Order Notes (Optional)
                    _buildOrderNotesCard(context),

                    const SizedBox(height: 14),

                    // 6. Final Financial Invoice Breakdown
                    _buildInvoiceSummaryCard(context, cart),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          InkWell(
            onTap: () => Get.back(),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'مراجعة وتأكيد الطلب',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E0A17),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Cairo',
                    height: 1.1,
                  ),
                ),
                Text(
                  'يرجى التأكد من صحة بياناتك قبل التأكيد النهائي',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : const Color(0xFF7E6674),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: isDark
                  ? BrandColors.gold.withValues(alpha: 0.15)
                  : BrandColors.burgundy.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'خطوة 3 من 3',
              style: TextStyle(
                color: isDark ? BrandColors.gold : BrandColors.burgundy,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityBanner(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, size: 20, color: Color(0xFF10B981)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'طلبك محمي ومضمون 100% وفق أعلى معايير الجودة والأمان الملكية',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF065F46),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryReviewCard(BuildContext context, CartController cart) {
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border.withValues(alpha: 0.35)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: context.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'بيانات التوصيل والتواصل',
                style: TextStyle(
                  color: context.foreground,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                  fontFamily: 'Cairo',
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        size: 14,
                        color: context.primary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'تعديل',
                        style: TextStyle(
                          color: context.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: context.border.withValues(alpha: 0.25)),
          const SizedBox(height: 10),
          _InfoLine(
            icon: Icons.home_outlined,
            label: 'العنوان المعتمد:',
            value: cart.shippingAddressText,
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          _InfoLine(
            icon: Icons.phone_android_rounded,
            label: 'رقم هاتف المستلم:',
            value: cart.contactInfo.value.phone.isEmpty
                ? 'غير محدد'
                : cart.contactInfo.value.phone,
            isDark: isDark,
          ),
          if (cart.contactInfo.value.email.isNotEmpty) ...[
            const SizedBox(height: 6),
            _InfoLine(
              icon: Icons.email_outlined,
              label: 'البريد الإلكتروني:',
              value: cart.contactInfo.value.email,
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShippingMethodReviewCard(
    BuildContext context,
    CartController cart,
  ) {
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border.withValues(alpha: 0.35)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: BrandColors.gold.withValues(alpha: isDark ? 0.18 : 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              size: 22,
              color: BrandColors.gold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cart.selectedShippingTitle,
                  style: TextStyle(
                    color: context.foreground,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'التوصيل المتوقع خلال 24 إلى 48 ساعة لكافة المدن',
                  style: TextStyle(
                    color: context.mutedForeground,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              cart.shippingFeeText,
              style: TextStyle(
                color: context.primary,
                fontWeight: FontWeight.w900,
                fontSize: 11.5,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentReviewCard(BuildContext context) {
    final isDark = context.isDark;
    final isWallet = controller.isWalletPayment;
    final acc = controller.selectedWalletAccount;
    final receipt = controller.receiptImage.value;

    return Container(
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border.withValues(alpha: 0.35)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isWallet
                      ? BrandColors.gold.withValues(alpha: 0.15)
                      : const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isWallet
                      ? Icons.account_balance_wallet_rounded
                      : Icons.payments_rounded,
                  size: 18,
                  color: isWallet ? BrandColors.gold : const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'طريقة الدفع المختارة',
                style: TextStyle(
                  color: context.foreground,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                  fontFamily: 'Cairo',
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isWallet ? BrandColors.gold : const Color(0xFF10B981))
                      .withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  controller.paymentMethodLabel,
                  style: TextStyle(
                    color: isWallet
                        ? (isDark ? BrandColors.gold : const Color(0xFFB45309))
                        : const Color(0xFF059669),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),

          if (isWallet && acc != null) ...[
            const SizedBox(height: 10),
            Divider(height: 1, color: context.border.withValues(alpha: 0.25)),
            const SizedBox(height: 10),
            _InfoLine(
              icon: Icons.person_outline_rounded,
              label: 'اسم المستلم:',
              value: acc.receiverName,
              isDark: isDark,
            ),
            const SizedBox(height: 6),
            _InfoLine(
              icon: Icons.tag_rounded,
              label: 'رقم الحساب/المحفظة:',
              value: acc.walletNumber,
              isDark: isDark,
            ),
            if (receipt != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E0A17)
                      : const Color(0xFFF9F5F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.40),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        receipt,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: Color(0xFF10B981),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'تم إرفاق سند التحويل بنجاح',
                                style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11.5,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'سيتم تدقيق الحوالة فور استلام الطلب',
                            style: TextStyle(
                              color: context.mutedForeground,
                              fontSize: 10.5,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildItemsReviewCard(BuildContext context, CartController cart) {
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border.withValues(alpha: 0.35)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المنتجات المطلوبة',
                  style: TextStyle(
                    color: context.foreground,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  '${cart.itemsCount} قطع',
                  style: TextStyle(
                    color: context.mutedForeground,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: context.border.withValues(alpha: 0.25)),
          const SizedBox(height: 6),
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

  Widget _buildOrderNotesCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border.withValues(alpha: 0.35)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes_rounded, size: 18, color: context.primary),
              const SizedBox(width: 8),
              Text(
                'ملاحظات إضافية للمندوب (اختياري)',
                style: TextStyle(
                  color: context.foreground,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            onChanged: (val) => controller.orderNotes.value = val,
            maxLines: 2,
            style: TextStyle(
              color: context.foreground,
              fontSize: 12.5,
              fontFamily: 'Cairo',
            ),
            decoration: InputDecoration(
              hintText: 'مثال: يرجى الاتصال قبل الوصول، العمارة رقم 5...',
              hintStyle: TextStyle(
                color: context.mutedForeground.withValues(alpha: 0.7),
                fontSize: 11.5,
                fontFamily: 'Cairo',
              ),
              filled: true,
              fillColor: context.isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFFBF8FA),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: context.border.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: context.border.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: context.primary, width: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceSummaryCard(BuildContext context, CartController cart) {
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: BrandColors.gold.withValues(alpha: isDark ? 0.35 : 0.50),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: BrandColors.burgundy.withValues(alpha: isDark ? 0.20 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: BrandGradients.luxuryGold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 16,
                  color: Color(0xFF26141E),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'الفاتورة والملخص المالي النهائي',
                style: TextStyle(
                  color: context.foreground,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: context.border.withValues(alpha: 0.3)),
          const SizedBox(height: 12),

          _InvoiceRow(
            label: 'المجموع الفرعي للمنتجات:',
            value: AppMoneyUtils.riyal(cart.itemsSubtotal),
            isDark: isDark,
          ),

          const SizedBox(height: 8),

          _InvoiceRow(
            label: 'رسوم الشحن والتوصيل:',
            value: cart.shippingFeeText,
            isDark: isDark,
          ),

          if (cart.hasCoupon) ...[
            const SizedBox(height: 8),
            _InvoiceRow(
              label: 'خصم الكوبون (${cart.couponCode.value}):',
              value: '- ${AppMoneyUtils.riyal(cart.couponDiscountAmount)}',
              isDiscount: true,
              isDark: isDark,
            ),
          ],

          const SizedBox(height: 14),
          Divider(height: 1, color: context.border.withValues(alpha: 0.45)),
          const SizedBox(height: 14),

          _InvoiceRow(
            label: 'المبلغ الإجمالي النهائي:',
            value: AppMoneyUtils.riyal(cart.total),
            isTotal: true,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 15,
          color: isDark ? BrandColors.gold : BrandColors.burgundy,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: context.mutedForeground,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: context.foreground,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ],
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDiscount;
  final bool isTotal;
  final bool isDark;

  const _InvoiceRow({
    required this.label,
    required this.value,
    this.isDiscount = false,
    this.isTotal = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    Color labelColor;
    Color valueColor;

    if (isTotal) {
      labelColor = isDark ? Colors.white : const Color(0xFF1E0A17);
      valueColor = isDark ? BrandColors.gold : BrandColors.burgundy;
    } else if (isDiscount) {
      labelColor = const Color(0xFF10B981);
      valueColor = const Color(0xFF10B981);
    } else {
      labelColor = context.mutedForeground;
      valueColor = context.foreground;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontWeight: isTotal
                ? FontWeight.w900
                : (isDiscount ? FontWeight.w800 : FontWeight.w700),
            fontSize: isTotal ? 14.5 : 12.5,
            fontFamily: 'Cairo',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w800,
            fontSize: isTotal ? 17.5 : 13,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}
