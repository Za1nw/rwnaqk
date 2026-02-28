import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/app_button.dart';

class CartTotalBar extends StatelessWidget {
  final double total;
  final VoidCallback onCheckout;
  final bool enabled;

  // ✅ Reusable customization
  final String totalLabel;
  final String checkoutText;
  final IconData? checkoutIcon;
  final Color? buttonBg;
  final Color? buttonFg;
  final bool outlinedButton;

  const CartTotalBar({
    super.key,
    required this.total,
    required this.onCheckout,
    required this.enabled,

    // defaults (so it stays reusable)
    this.totalLabel = 'Total',
    this.checkoutText = 'Checkout',
    this.checkoutIcon,
    this.buttonBg,
    this.buttonFg,
    this.outlinedButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: context.card,
        boxShadow: [
          BoxShadow(
            color: context.shadow.withOpacity(.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          // TOTAL
          Expanded(
            child: Text(
              '$totalLabel \$${total.toStringAsFixed(2)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: context.foreground,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ✅ AppButton with proper disabled behavior
          SizedBox(
            width: 160, // adjustable
            child: IgnorePointer(
              ignoring: !enabled,
              child: Opacity(
                opacity: enabled ? 1.0 : 0.45,
                child: AppButton(
                  text: checkoutText,
                  icon: checkoutIcon,
                  height: 44,
                  outlined: outlinedButton,
                  backgroundColor: buttonBg,
                  foregroundColor: buttonFg,
                  onPressed: enabled ? onCheckout : () {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}