import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';

class ProductTrustBadges extends StatelessWidget {
  const ProductTrustBadges({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: context.shadow.withValues(alpha: context.isDark ? 0.12 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _TrustItem(
                  icon: Icons.verified_outlined,
                  title: Tk.productDetailsTrustAuthentic.tr,
                  subtitle: Tk.productDetailsTrustAuthenticDesc.tr,
                ),
              ),
              Container(
                height: 48,
                width: 1,
                color: context.border.withValues(alpha: 0.35),
                margin: const EdgeInsets.symmetric(horizontal: 10),
              ),
              Expanded(
                child: _TrustItem(
                  icon: Icons.local_shipping_outlined,
                  title: Tk.productDetailsTrustShipping.tr,
                  subtitle: Tk.productDetailsTrustShippingDesc.tr,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              height: 1,
              thickness: 0.7,
              color: context.border.withValues(alpha: 0.30),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _TrustItem(
                  icon: Icons.published_with_changes_rounded,
                  title: Tk.productDetailsTrustReturns.tr,
                  subtitle: Tk.productDetailsTrustReturnsDesc.tr,
                ),
              ),
              Container(
                height: 48,
                width: 1,
                color: context.border.withValues(alpha: 0.35),
                margin: const EdgeInsets.symmetric(horizontal: 10),
              ),
              Expanded(
                child: _TrustItem(
                  icon: Icons.shield_outlined,
                  title: Tk.productDetailsTrustSecure.tr,
                  subtitle: Tk.productDetailsTrustSecureDesc.tr,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TrustItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: context.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: context.primary, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.foreground,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.mutedForeground,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

