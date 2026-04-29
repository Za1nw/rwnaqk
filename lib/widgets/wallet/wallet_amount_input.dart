import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class WalletAmountInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String suggestedTitle;
  final List<double> suggestedAmounts;
  final String Function(double amount) amountFormatter;
  final ValueChanged<double> onSuggestedAmountTap;
  final String? Function(String?)? validator;

  const WalletAmountInput({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.suggestedTitle,
    required this.suggestedAmounts,
    required this.amountFormatter,
    required this.onSuggestedAmountTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.foreground,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: context.input,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: context.shadow.withValues(alpha: .06),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: validator,
            style: TextStyle(
              color: context.foreground,
              fontWeight: FontWeight.w800,
            ),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(
                Icons.account_balance_wallet_outlined,
                color: context.mutedForeground,
              ),
              hintStyle: TextStyle(
                color: context.mutedForeground.withValues(alpha: .86),
                fontWeight: FontWeight.w600,
              ),
              filled: true,
              fillColor: context.input,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide:
                    BorderSide(color: context.border.withValues(alpha: .20)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: context.primary, width: 1.2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: context.destructive),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: context.destructive, width: 1.2),
              ),
            ),
          ),
        ),
        if (suggestedAmounts.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            suggestedTitle,
            style: TextStyle(
              color: context.mutedForeground,
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestedAmounts.map((amount) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => onSuggestedAmountTap(amount),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: context.card,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: context.border.withValues(alpha: .35),
                      ),
                    ),
                    child: Text(
                      amountFormatter(amount),
                      style: TextStyle(
                        color: context.foreground,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(growable: false),
          ),
        ],
      ],
    );
  }
}
