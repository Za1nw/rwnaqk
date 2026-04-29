import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/models/wallet_transfer_account.dart';
import 'package:rwnaqk/widgets/cart/payment_option_tile.dart';
import 'package:rwnaqk/widgets/cart/wallet_companies_row.dart';
import 'package:rwnaqk/widgets/cart/wallet_info_message.dart';
import 'package:rwnaqk/models/wallet_company.dart';

class PaymentMethodSection extends StatelessWidget {
  final String titleText;

  final String cashTitle;
  final String cashSubtitle;
  final String walletTitle;
  final String walletSubtitle;

  final String receiverNameLabel;
  final String walletNumberLabel;

  final List<WalletTransferAccount> walletAccounts;

  final String selectedId;
  final ValueChanged<String> onChanged;

  final int selectedWalletAccountIndex;
  final ValueChanged<int> onWalletAccountChanged;
  final bool showCashOption;

  final String? infoMessage;
  final IconData infoIcon;

  const PaymentMethodSection({
    super.key,
    required this.titleText,
    required this.cashTitle,
    required this.cashSubtitle,
    required this.walletTitle,
    required this.walletSubtitle,
    required this.receiverNameLabel,
    required this.walletNumberLabel,
    required this.walletAccounts,
    required this.selectedId,
    required this.onChanged,
    required this.selectedWalletAccountIndex,
    required this.onWalletAccountChanged,
    this.showCashOption = true,
    this.infoMessage,
    this.infoIcon = Icons.info_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final isWallet = selectedId == 'wallet';
    final showInfo = infoMessage != null && infoMessage!.trim().isNotEmpty;

    final hasAccounts = walletAccounts.isNotEmpty;
    final safeIndex = !hasAccounts
        ? 0
        : (selectedWalletAccountIndex < 0
            ? 0
            : (selectedWalletAccountIndex >= walletAccounts.length
                ? walletAccounts.length - 1
                : selectedWalletAccountIndex));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleText,
          style: TextStyle(
            color: context.foreground,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Material(
          color: context.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: context.border.withValues(alpha: .35)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                if (showCashOption) ...[
                  PaymentOptionTile(
                    selected: selectedId == 'cod',
                    title: cashTitle,
                    subtitle: cashSubtitle,
                    leadingIcon: Icons.payments_outlined,
                    onTap: () => onChanged('cod'),
                  ),
                  const SizedBox(height: 10),
                ],
                PaymentOptionTile(
                  selected: isWallet,
                  title: walletTitle,
                  subtitle: walletSubtitle,
                  leadingIcon: Icons.account_balance_wallet_outlined,
                  onTap: () => onChanged('wallet'),
                ),
                if (showInfo) ...[
                  const SizedBox(height: 10),
                  WalletInfoMessage(
                    icon: infoIcon,
                    text: infoMessage!,
                  ),
                ],
                if (isWallet && hasAccounts) ...[
                  const SizedBox(height: 16),
                  WalletCompaniesRow(
                    companies: walletAccounts
                        .map((acc) => WalletCompany.fromTransferAccount(acc))
                        .toList(growable: false),
                    selectedIndex: safeIndex,
                    onChanged: onWalletAccountChanged,
                  ),
                  const SizedBox(height: 18),
                  _WalletDetailsCard(
                    receiverNameLabel: receiverNameLabel,
                    walletNumberLabel: walletNumberLabel,
                    receiverNameValue: walletAccounts[safeIndex].receiverName,
                    walletNumberValue: walletAccounts[safeIndex].walletNumber,
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WalletDetailsCard extends StatelessWidget {
  final String receiverNameLabel;
  final String walletNumberLabel;
  final String receiverNameValue;
  final String walletNumberValue;

  const _WalletDetailsCard({
    required this.receiverNameLabel,
    required this.walletNumberLabel,
    required this.receiverNameValue,
    required this.walletNumberValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.input.withValues(alpha: context.isDark ? .35 : .55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(
            icon: Icons.person_outline,
            label: receiverNameLabel,
            value: receiverNameValue,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.phone_outlined,
            label: walletNumberLabel,
            value: walletNumberValue,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: context.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: context.mutedForeground,
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: context.foreground,
                  fontWeight: FontWeight.w900,
                  fontSize: 13.5,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
