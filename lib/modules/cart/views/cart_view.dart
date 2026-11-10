import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_money_utils.dart';
import 'package:rwnaqk_frontend/core/widgets/feedback/app_toast.dart';
import 'package:rwnaqk_frontend/modules/cart/providers/cart_providers.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/address_section.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/cart_checkout_stepper.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/cart_items_list.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/cart_total_bar.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/cart_wishlist_section.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/free_shipping_meter.dart';
import 'package:rwnaqk_frontend/modules/customer/providers/addresses_providers.dart';
import 'package:rwnaqk_frontend/modules/wishlist/providers/wishlist_providers.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  void _confirmClearCart(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF24111F) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark
                ? BrandColors.gold.withValues(alpha: 0.20)
                : const Color(0xFFEBE0E6),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_sweep_rounded,
                color: Color(0xFFEF4444),
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'تفريغ السلة',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E0A17),
                fontSize: 17,
                fontWeight: FontWeight.w900,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في حذف جميع المنتجات من سلة التسوق؟',
          style: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF6E5664),
            fontSize: 13.5,
            fontFamily: 'Cairo',
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: isDark ? Colors.white60 : const Color(0xFF7E6674),
                fontWeight: FontWeight.w700,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(cartProvider.notifier).clearCart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'نعم، تفريغ',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final quoteState = ref.watch(cartQuoteProvider);
    final wishlistState = ref.watch(wishlistProvider);
    final selectedAddress = ref.watch(selectedAddressProvider) ??
        ref.watch(defaultAddressProvider);

    final isDark = context.isDark;
    final isEmpty = cartState.isEmpty;
    final hasWishlist = wishlistState.items.isNotEmpty;

    final cartItems =
        cartState.items.map((line) => line.originalProduct).toList();
    final quantities = {
      for (final line in cartState.items) line.originalProduct.id: line.quantity
    };
    final variantTexts = {
      for (final line in cartState.items)
        if (line.variantText != null) line.originalProduct.id: line.variantText!
    };
    final ratings = {
      for (final line in cartState.items)
        if (line.rating != null) line.originalProduct.id: line.rating!
    };
    final reviewsCounts = {
      for (final line in cartState.items)
        if (line.reviewsCount != null)
          line.originalProduct.id: line.reviewsCount!
    };

    final subtotal = cartState.subtotal;
    final hasCoupon = quoteState.couponCode != null &&
        quoteState.couponCode!.isNotEmpty &&
        quoteState.discountAmount > 0;
    final couponDiscount = quoteState.discountAmount;
    final shippingFee = quoteState.shippingFee;
    final finalTotal = quoteState.isValid
        ? quoteState.grandTotal
        : (subtotal - couponDiscount + shippingFee);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF140A13)
          : const Color(0xFFFBF8FA),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopAppBar(context, ref, cartState.totalQuantity, isEmpty),

            // Stepper Indicator (Step 1: Cart)
            const CartCheckoutStepper(currentStep: 1),

            // Main Body Content
            Expanded(
              child: isEmpty
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        16,
                        16,
                        16,
                        100,
                      ),
                      child: Column(
                        children: [
                          _buildEmptyState(context),
                          if (hasWishlist) ...[
                            const SizedBox(height: 24),
                            CartWishlistSection(onAdd: cartNotifier.addToCart),
                          ],
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Free Shipping Progress Meter
                          FreeShippingMeter(currentSubtotal: subtotal),

                          const SizedBox(height: 14),

                          // Shipping Address Card
                          AddressSection(
                            title: Tk.cartShippingAddress.tr,
                            address: selectedAddress?.formatted ?? '',
                            onEdit: () =>
                                AppNav.toNamed(AppRoutes.addresses),
                            allowAddWhenEmpty: true,
                            emptyHint: Tk.cartAddShippingDetails.tr,
                          ),

                          const SizedBox(height: 14),

                          // Reassurance Trust Badges Strip
                          _buildTrustBadgesStrip(context),

                          const SizedBox(height: 16),

                          // Cart Items Header Row
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'عناصر السلة (${cartState.totalQuantity})',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1E0A17),
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              Text(
                                'توصيل سريع متاح',
                                style: TextStyle(
                                  color: isDark
                                      ? BrandColors.gold
                                      : BrandColors.burgundy,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Cart Items List
                          CartItemsList(
                            items: cartItems,
                            quantities: quantities,
                            variantTexts: variantTexts,
                            ratings: ratings,
                            reviewsCounts: reviewsCounts,
                            onRemove: cartNotifier.removeFromCart,
                            onIncrement: cartNotifier.incrementQuantity,
                            onDecrement: cartNotifier.decrementQuantity,
                          ),

                          const SizedBox(height: 18),

                          // Promo Code Card
                          _buildPromoCodeCard(
                            context,
                            ref,
                            quoteState,
                            selectedAddress?.id,
                          ),

                          const SizedBox(height: 18),

                          // Bill / Financial Summary Card
                          _buildBillSummaryCard(
                            context,
                            subtotal: subtotal,
                            hasCoupon: hasCoupon,
                            couponCode: quoteState.couponCode ?? '',
                            couponDiscount: couponDiscount,
                            shippingFee: shippingFee,
                            finalTotal: finalTotal,
                          ),

                          if (hasWishlist) ...[
                            const SizedBox(height: 24),
                            CartWishlistSection(onAdd: cartNotifier.addToCart),
                          ],

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
            ),

            // Fixed Bottom Checkout Bar
            CartTotalBar(
              total: finalTotal,
              enabled: !isEmpty,
              totalLabel: Tk.cartTotal.tr,
              helperText: isEmpty
                  ? Tk.cartStartCheckout.tr
                  : Tk.cartCheckoutReady.trParams({
                      'count': '${cartState.totalQuantity}',
                    }),
              checkoutText: Tk.cartCheckout.tr,
              checkoutIcon: Icons.arrow_forward_rounded,
              onCheckout: () {
                AppNav.toNamed(AppRoutes.payment);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Top App Bar with Branding and Clear Cart action
  Widget _buildTopAppBar(
    BuildContext context,
    WidgetRef ref,
    int itemsCount,
    bool isEmpty,
  ) {
    final isDark = context.isDark;

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 10),
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
          // Shopping bag icon with luxury badge
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: isDark
                  ? BrandColors.gold.withValues(alpha: 0.12)
                  : BrandColors.burgundy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 22,
              color: isDark ? BrandColors.gold : BrandColors.burgundy,
            ),
          ),

          const SizedBox(width: 12),

          // Title & Count
          Expanded(
            child: Row(
              children: [
                Text(
                  Tk.cartTitle.tr,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E0A17),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? BrandColors.gold.withValues(alpha: 0.15)
                        : BrandColors.burgundy.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$itemsCount',
                    style: TextStyle(
                      color: isDark ? BrandColors.gold : BrandColors.burgundy,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Clear Cart action button
          if (!isEmpty)
            InkWell(
              onTap: () => _confirmClearCart(context, ref),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: 17,
                      color: isDark
                          ? const Color(0xFFFFA4A4)
                          : const Color(0xFFD32F2F),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'تفريغ',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFFFA4A4)
                            : const Color(0xFFD32F2F),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Reassurance trust strip (Local express delivery, authentic, secure payment)
  Widget _buildTrustBadgesStrip(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF24111F).withValues(alpha: 0.7)
            : const Color(0xFFFAF3F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? BrandColors.gold.withValues(alpha: 0.12)
              : const Color(0xFFEBE0E6),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _trustItem(
            icon: Icons.local_shipping_outlined,
            label: 'شحن سريع',
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 18,
            color: isDark ? Colors.white12 : const Color(0xFFDDD2D9),
          ),
          _trustItem(
            icon: Icons.verified_outlined,
            label: 'أصلي 100%',
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 18,
            color: isDark ? Colors.white12 : const Color(0xFFDDD2D9),
          ),
          _trustItem(
            icon: Icons.security_rounded,
            label: 'دفع آمن',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _trustItem({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? BrandColors.gold : BrandColors.burgundy,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF4A3443),
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  /// Promo Code / Coupon Card
  Widget _buildPromoCodeCard(
    BuildContext context,
    WidgetRef ref,
    CartQuoteState quoteState,
    String? addressIdStr,
  ) {
    final isDark = context.isDark;
    final hasCoupon = quoteState.couponCode != null &&
        quoteState.couponCode!.isNotEmpty &&
        quoteState.discountAmount > 0;
    final addressId = int.tryParse(addressIdStr ?? '1') ?? 1;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF24111F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasCoupon
              ? const Color(0xFF10B981).withValues(alpha: 0.4)
              : (isDark
                  ? BrandColors.gold.withValues(alpha: 0.15)
                  : const Color(0xFFEDE3EA)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.confirmation_number_outlined,
                size: 18,
                color: hasCoupon
                    ? const Color(0xFF10B981)
                    : (isDark ? BrandColors.gold : BrandColors.burgundy),
              ),
              const SizedBox(width: 8),
              Text(
                hasCoupon ? 'كوبون الخصم مفعّل' : 'كوبون الخصم',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E0A17),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Cairo',
                ),
              ),
              const Spacer(),
              if (hasCoupon)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'خصم ${AppMoneyUtils.riyal(quoteState.discountAmount)}',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Cairo',
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? BrandColors.gold.withValues(alpha: 0.15)
                        : BrandColors.burgundy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'كود: RAWNAQ',
                    style: TextStyle(
                      color: isDark ? BrandColors.gold : BrandColors.burgundy,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (hasCoupon) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'كود (${quoteState.couponCode}) مفعّل بنجاح!',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF34D399)
                            : const Color(0xFF065F46),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      await ref
                          .read(cartQuoteProvider.notifier)
                          .removeCoupon(addressId: addressId);
                      AppToast.info(
                        'تم إلغاء تفعيل كوبون الخصم',
                        title: 'كوبون الخصم',
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFFFCA5A5)
                              : const Color(0xFFDC2626),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1B0B17)
                          : const Color(0xFFF9F5F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? Colors.white12
                            : const Color(0xFFE2D6DF),
                      ),
                    ),
                    alignment: Alignment.centerRight,
                    child: Text(
                      'RAWNAQ',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF1E0A17),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo',
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () async {
                    final success = await ref
                        .read(cartQuoteProvider.notifier)
                        .applyCoupon(
                          code: 'RAWNAQ',
                          addressId: addressId,
                        );
                    if (success) {
                      AppToast.success(
                        'تم تطبيق كود الخصم (RAWNAQ) بنجاح!',
                        title: 'كوبون الخصم',
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                const Color(0xFFFAAD01),
                                const Color(0xFFE59C00),
                              ]
                            : [
                                const Color(0xFF8E0542),
                                const Color(0xFF6E0131),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'تطبيق',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF1E0A17)
                            : Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Bill / Cost Breakdown Card
  Widget _buildBillSummaryCard(
    BuildContext context, {
    required double subtotal,
    required bool hasCoupon,
    required String couponCode,
    required double couponDiscount,
    required double shippingFee,
    required double finalTotal,
  }) {
    final isDark = context.isDark;

    return Container(
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
                'ملخص الفاتورة',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E0A17),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Subtotal
          _summaryRow(
            title: Tk.cartSubtotal.tr,
            value: AppMoneyUtils.riyal(subtotal),
            isDark: isDark,
          ),

          // Coupon discount if applied
          if (hasCoupon) ...[
            const SizedBox(height: 8),
            _summaryRow(
              title: 'خصم الكوبون ($couponCode)',
              value: '- ${AppMoneyUtils.riyal(couponDiscount)}',
              isHighlight: true,
              isDark: isDark,
            ),
          ],

          const SizedBox(height: 8),

          // Shipping Fee
          _summaryRow(
            title: 'رسوم التوصيل',
            value: shippingFee <= 0
                ? 'مجاني'
                : AppMoneyUtils.riyal(shippingFee),
            isHighlight: shippingFee <= 0,
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

          // Total Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي النهائي',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E0A17),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Cairo',
                ),
              ),
              Text(
                AppMoneyUtils.riyal(finalTotal),
                style: TextStyle(
                  color: isDark ? BrandColors.gold : BrandColors.burgundy,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({
    required String title,
    required String value,
    required bool isDark,
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF6E5664),
            fontSize: 13,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlight
                ? const Color(0xFF10B981)
                : (isDark ? Colors.white : const Color(0xFF1E0A17)),
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  /// Luxury Empty State
  Widget _buildEmptyState(BuildContext context) {
    final isDark = context.isDark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing shopping bag icon
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          BrandColors.gold.withValues(alpha: 0.20),
                          const Color(0xFF24111F),
                        ]
                      : [
                          BrandColors.burgundy.withValues(alpha: 0.12),
                          const Color(0xFFF5EBF1),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: isDark
                      ? BrandColors.gold.withValues(alpha: 0.3)
                      : BrandColors.burgundy.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? BrandColors.gold : BrandColors.burgundy)
                        .withValues(alpha: 0.18),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 42,
                  color: isDark ? BrandColors.gold : BrandColors.burgundy,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              Tk.cartEmptyTitle.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E0A17),
                fontWeight: FontWeight.w900,
                fontSize: 19,
                fontFamily: 'Cairo',
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              Tk.cartEmptySubtitle.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white60 : const Color(0xFF6E5664),
                fontWeight: FontWeight.w600,
                fontSize: 13,
                fontFamily: 'Cairo',
                height: 1.45,
              ),
            ),

            const SizedBox(height: 24),

            // Start Shopping CTA
            InkWell(
              onTap: () => AppNav.toNamed(AppRoutes.main),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFFFAAD01), const Color(0xFFE59C00)]
                        : [const Color(0xFF8E0542), const Color(0xFF6E0131)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isDark
                                  ? const Color(0xFFFAAD01)
                                  : const Color(0xFF6E0131))
                              .withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.storefront_outlined,
                      size: 18,
                      color: isDark ? const Color(0xFF1E0A17) : Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ابدأ التسوق الآن',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF1E0A17) : Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
