import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/models/wallet/wallet_transaction_model.dart';
import 'package:rwnaqk/widgets/wallet/wallet_status_chip.dart';

class WalletTransactionItem extends StatelessWidget {
  final WalletTransactionModel transaction;
  final String amountText;
  final String typeText;
  final String statusText;
  final String descriptionText;
  final String dateText;
  final VoidCallback onTap;

  const WalletTransactionItem({
    super.key,
    required this.transaction,
    required this.amountText,
    required this.typeText,
    required this.statusText,
    required this.descriptionText,
    required this.dateText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = _typeColor(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: context.border.withValues(alpha: .35)),
            boxShadow: [
              BoxShadow(
                color: context.shadow.withValues(alpha: .05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: .10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _typeIcon(),
                      color: accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          typeText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.foreground,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          descriptionText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.mutedForeground,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.2,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  WalletStatusChip(
                    status: transaction.status,
                    label: statusText,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: context.input.withValues(alpha: .55),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: context.border.withValues(alpha: .30),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 16,
                            color: context.mutedForeground,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              dateText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.mutedForeground,
                                fontWeight: FontWeight.w800,
                                fontSize: 11.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: accentColor.withValues(alpha: .20),
                      ),
                    ),
                    child: Text(
                      amountText,
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 12.8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: context.input,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.border.withValues(alpha: .35),
                      ),
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: context.mutedForeground,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _typeIcon() {
    switch (transaction.type) {
      case WalletTransactionType.deposit:
        return Icons.add_circle_outline_rounded;
      case WalletTransactionType.withdraw:
        return Icons.arrow_circle_up_outlined;
      case WalletTransactionType.refund:
        return Icons.assignment_return_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  Color _typeColor(BuildContext context) {
    switch (transaction.type) {
      case WalletTransactionType.deposit:
        return context.success;
      case WalletTransactionType.withdraw:
        return context.primary;
      case WalletTransactionType.refund:
        return context.info;
      default:
        return context.primary;
    }
  }
}
