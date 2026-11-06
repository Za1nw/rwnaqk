import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';

class OrderTrackingActions extends StatelessWidget {
  final bool canCancel;
  final bool canReorder;
  final VoidCallback onCancel;
  final VoidCallback onHelpOrReorder;
  final VoidCallback? onReview;
  final bool showReview;

  const OrderTrackingActions({
    super.key,
    required this.canCancel,
    required this.canReorder,
    required this.onCancel,
    required this.onHelpOrReorder,
    required this.showReview,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            if (canCancel)
              Expanded(
                child: _ActionButton(
                  text: Tk.ordersActionCancel.tr,
                  outlined: true,
                  onTap: onCancel,
                ),
              ),
            if (canCancel) const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                text: canReorder
                    ? Tk.ordersActionReorder.tr
                    : Tk.ordersActionHelp.tr,
                onTap: onHelpOrReorder,
              ),
            ),
          ],
        ),
        if (showReview) ...[
          const SizedBox(height: 14),
          _ActionButton(
            text: Tk.ordersActionReview.tr,
            outlined: true,
            onTap: onReview ?? () {},
          ),
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool outlined;

  const _ActionButton({
    required this.text,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primaryColor = isDark ? BrandColors.gold : BrandColors.burgundy;
    final foregroundColor = outlined
        ? primaryColor
        : (isDark ? const Color(0xFF1E0A17) : Colors.white);

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: outlined ? Colors.transparent : primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: outlined
                ? BorderSide(
                    color: primaryColor.withValues(alpha: isDark ? 0.6 : 0.4),
                    width: 1.5,
                  )
                : BorderSide.none,
          ),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: foregroundColor,
            fontWeight: FontWeight.w900,
            fontSize: 13,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}
