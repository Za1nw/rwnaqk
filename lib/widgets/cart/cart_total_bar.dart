import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/utils/app_money_utils.dart';
import 'package:rwnaqk/widgets/app_button.dart';

class CartTotalBar extends StatelessWidget {
  final double total;
  final VoidCallback onCheckout;
  final bool enabled;

  // Reusable customization
  final String totalLabel;
  final String checkoutText;
  final IconData? checkoutIcon;
  final Color? buttonBg;
  final Color? buttonFg;
  final bool outlinedButton;
  final String? helperText;
  final double buttonWidth;

  const CartTotalBar({
    super.key,
    required this.total,
    required this.onCheckout,
    required this.enabled,
    this.totalLabel = 'Total',
    this.checkoutText = 'Checkout',
    this.checkoutIcon,
    this.buttonBg,
    this.buttonFg,
    this.outlinedButton = false,
    this.helperText,
    this.buttonWidth = 170,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: context.card,
        border: Border(top: BorderSide(color: context.border.withOpacity(.3))),
        boxShadow: [
          BoxShadow(
            color: context.shadow.withOpacity(.06),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  totalLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: context.mutedForeground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppMoneyUtils.currency(total),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: context.foreground,
                    height: 1.0,
                  ),
                ),
                if (helperText != null && helperText!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    helperText!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: context.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: buttonWidth,
            child: IgnorePointer(
              ignoring: !enabled,
              child: Opacity(
                opacity: enabled ? 1.0 : 0.45,
                child: AppButton(
                  text: checkoutText,
                  icon: checkoutIcon,
                  height: 48,
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
