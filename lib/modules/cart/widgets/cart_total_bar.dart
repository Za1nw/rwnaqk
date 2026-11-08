import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/utils/app_money_utils.dart';
import 'package:rwnaqk_frontend/core/widgets/app_button.dart';

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
    this.buttonWidth = 175,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primaryColor = isDark ? BrandColors.gold : BrandColors.burgundy;
    final defaultBtnBg = buttonBg ?? primaryColor;
    final defaultBtnFg =
        buttonFg ?? (isDark ? const Color(0xFF1E0A17) : Colors.white);

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF24111F) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? BrandColors.gold.withValues(alpha: 0.20)
                : BrandColors.burgundy.withValues(alpha: 0.08),
            width: 1.2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Total Details
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
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white60 : const Color(0xFF7E6674),
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppMoneyUtils.riyal(total),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                    fontFamily: 'Cairo',
                    height: 1.1,
                  ),
                ),
                if (helperText != null && helperText!.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    helperText!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : const Color(0xFF8E7684),
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Primary Checkout Button
          Flexible(
            flex: 0,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: buttonWidth, minWidth: 140),
              child: Opacity(
                opacity: enabled ? 1.0 : 0.6,
                child: AppButton(
                  text: checkoutText,
                  icon: checkoutIcon,
                  height: 48,
                  outlined: outlinedButton,
                  backgroundColor: defaultBtnBg,
                  foregroundColor: defaultBtnFg,
                  onPressed: onCheckout,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
