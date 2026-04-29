import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/models/wallet/wallet_transaction_model.dart';

class WalletStatusChip extends StatelessWidget {
  final String status;
  final String label;

  const WalletStatusChip({
    super.key,
    required this.status,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .24)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 11.5,
          height: 1,
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context, String value) {
    switch (value) {
      case WalletTransactionStatus.pending:
        return context.warning;
      case WalletTransactionStatus.approved:
        return context.info;
      case WalletTransactionStatus.rejected:
      case WalletTransactionStatus.failed:
        return context.destructive;
      case WalletTransactionStatus.refunded:
      case WalletTransactionStatus.completed:
        return context.success;
      default:
        return context.primary;
    }
  }
}
