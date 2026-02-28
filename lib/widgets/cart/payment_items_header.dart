import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class PaymentItemsHeader extends StatelessWidget {
  final String title; // "Items"
  final int count;

  /// حالة 1: Add Voucher
  final String? voucherText; // "Add Voucher"
  final VoidCallback? onAddVoucher;

  /// حالة 2: Discount Chip
  final String? discountText; // "5% Discount"
  final VoidCallback? onRemoveDiscount;

  const PaymentItemsHeader({
    super.key,
    required this.title,
    required this.count,

    // voucher state
    this.voucherText,
    this.onAddVoucher,

    // discount state
    this.discountText,
    this.onRemoveDiscount,
  });

  bool get _showDiscount => discountText != null && discountText!.trim().isNotEmpty;
  bool get _showVoucher => !_showDiscount && onAddVoucher != null;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: context.foreground,
            fontWeight: FontWeight.w900,
            fontSize: 26,
          ),
        ),
        const SizedBox(width: 10),

        // badge count
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: context.primary.withOpacity(.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: context.primary.withOpacity(.18)),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: context.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),

        const Spacer(),

        // RIGHT SIDE (Voucher OR Discount)
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: context.primary, width: 1.6),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: context.primary,
            fontWeight: FontWeight.w900,
            fontSize: 14,
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
      padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 12, 10),
      decoration: BoxDecoration(
        color: context.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              color: context.primaryForeground,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: onClose,
            borderRadius: BorderRadius.circular(999),
            child: Icon(
              Icons.close_rounded,
              size: 18,
              color: context.primaryForeground,
            ),
          ),
        ],
      ),
    );
  }
}