import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class PaymentItemsHeader extends StatelessWidget {
  final String title; // "Items"
  final int count;

  /// State 1: Add Voucher
  final String? voucherText; // "Add Voucher"
  final VoidCallback? onAddVoucher;

  /// State 2: Discount Chip
  final String? discountText; // "5% Discount"
  final VoidCallback? onRemoveDiscount;

  const PaymentItemsHeader({
    super.key,
    required this.title,
    required this.count,
    this.voucherText,
    this.onAddVoucher,
    this.discountText,
    this.onRemoveDiscount,
  });

  bool get _showDiscount =>
      discountText != null && discountText!.trim().isNotEmpty;

  bool get _showVoucher =>
      !_showDiscount && onAddVoucher != null; // نفس منطقك

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final compact = c.maxWidth < 360;

        final titleSize = compact ? 18.0 : 20.0; // ✅ مثل الصورة
        final badgeFont = compact ? 12.0 : 12.5;

        return Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: context.foreground,
                fontWeight: FontWeight.w900,
                fontSize: titleSize,
                height: 1.0,
              ),
            ),
            const SizedBox(width: 10),

            // ✅ badge count (رمادي فاتح + حجم صغير مثل الصورة)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: context.muted.withOpacity(context.isDark ? .25 : .55),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: context.foreground,
                  fontWeight: FontWeight.w800,
                  fontSize: badgeFont,
                  height: 1.0,
                ),
              ),
            ),

            const Spacer(),

            if (_showDiscount)
              _DiscountChip(
                text: discountText!,
                onClose: onRemoveDiscount,
              )
            else if (_showVoucher)
              _VoucherButton(
                text: voucherText ?? "Add Voucher",
                onTap: onAddVoucher!,
              ),
          ],
        );
      },
    );
  }
}

class _VoucherButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _VoucherButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        // ✅ أقصر وأنحف مثل الصورة
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: context.primary, width: 1.4),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: context.primary,
            fontWeight: FontWeight.w800,
            fontSize: 12.5,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

class _DiscountChip extends StatelessWidget {
  final String text;
  final VoidCallback? onClose;

  const _DiscountChip({required this.text, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      // ✅ أقصر مثل الصورة
      padding: const EdgeInsetsDirectional.fromSTEB(12, 6, 8, 6),
      decoration: BoxDecoration(
        color: context.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: context.primaryForeground,
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
              height: 1.0,
            ),
          ),
          const SizedBox(width: 8),

          // ✅ شكل X أقرب للصورة (مربع/دائرة صغيرة داخل الشيب)
          InkWell(
            onTap: onClose,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: context.primaryForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}