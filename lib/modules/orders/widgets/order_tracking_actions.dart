import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/widgets/feedback/app_toast.dart';

class OrderTrackingActions extends StatelessWidget {
  final bool canCancel;
  final bool canReorder;
  final VoidCallback onCancel;
  final VoidCallback onHelpOrReorder;
  final VoidCallback? onReview;
  final VoidCallback? onViewDetails;
  final String orderId;
  final bool showReview;

  const OrderTrackingActions({
    super.key,
    required this.canCancel,
    required this.canReorder,
    required this.onCancel,
    required this.onHelpOrReorder,
    required this.showReview,
    this.onReview,
    this.onViewDetails,
    this.orderId = '',
  });

  void _shareTrackingLink() {
    Clipboard.setData(ClipboardData(text: 'https://rawnaqk.ye/track/$orderId'));
    AppToast.copied(
      message: 'تم نسخ رابط تتبع الشحنة للحافظة بنجاح، يمكنك مشاركته الآن.',
      title: 'مشاركة التتبع',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary Actions Row
        Row(
          children: [
            if (canCancel) ...[
              Expanded(
                child: _ActionButton(
                  text: Tk.ordersActionCancel.tr,
                  outlined: true,
                  onTap: onCancel,
                  icon: Icons.close_rounded,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: _ActionButton(
                text: canReorder
                    ? Tk.ordersActionReorder.tr
                    : Tk.ordersActionHelp.tr,
                onTap: onHelpOrReorder,
                icon: canReorder
                    ? Icons.replay_rounded
                    : Icons.help_outline_rounded,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Secondary Utilities Row (Share & Invoice)
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                text: 'مشاركة التتبع 🔗',
                outlined: true,
                onTap: _shareTrackingLink,
              ),
            ),
            if (onViewDetails != null) ...[
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  text: 'تفاصيل الفاتورة 📄',
                  outlined: true,
                  onTap: onViewDetails!,
                ),
              ),
            ],
          ],
        ),

        if (showReview) ...[
          const SizedBox(height: 12),
          _ActionButton(
            text: Tk.ordersActionReview.tr,
            outlined: false,
            onTap: onReview ?? () {},
            icon: Icons.star_rounded,
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
  final IconData? icon;

  const _ActionButton({
    required this.text,
    required this.onTap,
    this.outlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primaryColor = isDark ? BrandColors.gold : BrandColors.burgundy;
    final foregroundColor = outlined
        ? (isDark ? BrandColors.gold : BrandColors.burgundy)
        : (isDark ? const Color(0xFF1E0A17) : Colors.white);

    return SizedBox(
      height: 46,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: outlined ? Colors.transparent : primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: outlined
                ? BorderSide(
                    color: primaryColor.withValues(alpha: isDark ? 0.6 : 0.4),
                    width: 1.2,
                  )
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: foregroundColor),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
