import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/cart/payment_option_tile.dart';
import 'package:rwnaqk/widgets/cart/receiver_info_block.dart';
import 'package:rwnaqk/widgets/cart/wallet_info_message.dart';

class WalletCompany {
  final String id;
  final String name;
  final IconData? icon;
  final String? assetPath;

  const WalletCompany({
    required this.id,
    required this.name,
    this.icon,
    this.assetPath,
  });
}

class PaymentMethodSection extends StatelessWidget {
  final String titleText;
  final String cashTitle;
  final String cashSubtitle;
  final String walletTitle;
  final String walletSubtitle;
  final String receiverNameLabel;
  final String walletNumberLabel;
  final String receiverNameValue;
  final String walletNumberValue;
  final List<WalletCompany> walletCompanies;
  final String selectedWalletCompanyId;
  final String selectedId;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onWalletCompanyChanged;
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
    required this.receiverNameValue,
    required this.walletNumberValue,
    required this.walletCompanies,
    required this.selectedWalletCompanyId,
    required this.selectedId,
    required this.onChanged,
    this.onWalletCompanyChanged,
    this.infoMessage,
    this.infoIcon = Icons.info_outline_rounded,
  });

  bool get _isWallet => selectedId == 'wallet';
  bool get _showInfo => infoMessage != null && infoMessage!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
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
            side: BorderSide(color: context.border.withOpacity(.35)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                PaymentOptionTile(
                  selected: selectedId == 'cod',
                  title: cashTitle,
                  subtitle: cashSubtitle,
                  leadingIcon: Icons.payments_outlined,
                  onTap: () => onChanged('cod'),
                ),
                const SizedBox(height: 10),
                PaymentOptionTile(
                  selected: _isWallet,
                  title: walletTitle,
                  subtitle: walletSubtitle,
                  leadingIcon: Icons.account_balance_wallet_outlined,
                  onTap: () => onChanged('wallet'),
                ),
                if (_showInfo) ...[
                  const SizedBox(height: 10),
                  WalletInfoMessage(
                    icon: infoIcon,
                    text: infoMessage!,
                  ),
                ],
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 180),
                  crossFadeState: _isWallet
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                    child: ReceiverInfoBlock(
                      receiverNameLabel: receiverNameLabel,
                      walletNumberLabel: walletNumberLabel,
                      receiverNameValue: receiverNameValue,
                      walletNumberValue: walletNumberValue,
                      companies: walletCompanies,
                      selectedCompanyId: selectedWalletCompanyId,
                      onCompanyChanged: onWalletCompanyChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
