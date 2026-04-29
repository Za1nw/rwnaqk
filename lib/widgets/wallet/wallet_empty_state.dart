import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class WalletEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const WalletEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.account_balance_wallet_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.border.withValues(alpha: .35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.input,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: context.mutedForeground,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.foreground,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.mutedForeground,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
