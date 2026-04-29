import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/wallet/wallet_controller.dart';
import 'package:rwnaqk/controllers/wallet/wallet_ui_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/models/wallet_company.dart';
import 'package:rwnaqk/widgets/app_button.dart';
import 'package:rwnaqk/widgets/app_input_field.dart';
import 'package:rwnaqk/widgets/cart/payment_option_tile.dart';
import 'package:rwnaqk/widgets/cart/wallet_companies_row.dart';
import 'package:rwnaqk/widgets/cart/wallet_info_message.dart';
import 'package:rwnaqk/widgets/common/app_back_header.dart';
import 'package:rwnaqk/widgets/wallet/wallet_amount_input.dart';

class WithdrawScreen extends GetView<WalletController> {
  const WithdrawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Obx(() {
          return ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 24),
            children: [
              AppBackHeader(
                title: Tk.walletWithdraw.tr,
                onBack: Get.back,
                showTrailing: false,
              ),
              const SizedBox(height: 18),
              _WithdrawBalanceCard(
                title: Tk.walletAvailableToWithdraw.tr,
                value: controller.formatMoney(controller.balance),
              ),
              const SizedBox(height: 16),
              Form(
                key: controller.withdrawFormKey,
                child: Column(
                  children: [
                    _WithdrawMethodSection(controller: controller),
                    const SizedBox(height: 16),
                    WalletAmountInput(
                      controller: controller.withdrawAmountController,
                      label: Tk.walletEnterAmount.tr,
                      hint: Tk.walletEnterAmount.tr,
                      suggestedTitle: Tk.walletSuggestedAmounts.tr,
                      suggestedAmounts: controller.suggestedAmounts,
                      amountFormatter: controller.formatMoney,
                      onSuggestedAmountTap: controller.setWithdrawSuggestion,
                      validator: controller.validateWithdrawAmount,
                    ),
                    const SizedBox(height: 16),
                    if (controller.isWalletWithdrawMethod)
                      _WalletRecipientFields(controller: controller)
                    else
                      _HawalaRecipientFields(controller: controller),
                    const SizedBox(height: 16),
                    _WithdrawSummaryCard(controller: controller),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                text: Tk.walletConfirm.tr,
                icon: Icons.arrow_circle_up_outlined,
                isLoading: controller.isSubmitting.value,
                onPressed: () async {
                  final isValid =
                      controller.withdrawFormKey.currentState?.validate() ??
                          false;
                  if (!isValid) return;

                  final success = await controller.withdrawBalance();
                  if (success && (Get.key.currentState?.canPop() ?? false)) {
                    Get.back();
                  }
                },
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _WithdrawMethodSection extends StatelessWidget {
  final WalletController controller;

  const _WithdrawMethodSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final selectedMethod = controller.withdrawMethod.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Tk.walletWithdrawMethodTitle.tr,
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
                PaymentOptionTile(
                  selected: selectedMethod == WalletWithdrawMethod.wallet,
                  title: Tk.walletWithdrawWalletTitle.tr,
                  subtitle: Tk.walletWithdrawWalletSubtitle.tr,
                  leadingIcon: Icons.account_balance_wallet_outlined,
                  onTap: () =>
                      controller.setWithdrawMethod(WalletWithdrawMethod.wallet),
                ),
                const SizedBox(height: 10),
                PaymentOptionTile(
                  selected: selectedMethod == WalletWithdrawMethod.hawala,
                  title: Tk.walletWithdrawHawalaTitle.tr,
                  subtitle: Tk.walletWithdrawHawalaSubtitle.tr,
                  leadingIcon: Icons.local_shipping_outlined,
                  onTap: () =>
                      controller.setWithdrawMethod(WalletWithdrawMethod.hawala),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WalletRecipientFields extends StatelessWidget {
  final WalletController controller;

  const _WalletRecipientFields({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WalletInfoMessage(
          icon: Icons.info_outline_rounded,
          text: Tk.walletWithdrawWalletInfo.tr,
        ),
        const SizedBox(height: 14),
        WalletCompaniesRow(
          companies: controller.walletTransferAccounts
              .map((account) => WalletCompany.fromTransferAccount(account))
              .toList(growable: false),
          selectedIndex: controller.selectedWithdrawWalletAccountIndex.value,
          onChanged: controller.setSelectedWithdrawWalletAccountIndex,
        ),
        const SizedBox(height: 14),
        AppInputField(
          controller: controller.withdrawWalletNameController,
          label: Tk.walletWithdrawWalletName.tr,
          hint: Tk.walletWithdrawWalletName.tr,
          prefixIcon: Icons.person_outline_rounded,
          validator: controller.validateWithdrawWalletName,
        ),
        const SizedBox(height: 12),
        AppInputField(
          controller: controller.withdrawWalletNumberController,
          label: Tk.walletWithdrawWalletNumber.tr,
          hint: Tk.walletWithdrawWalletNumber.tr,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: controller.validateWithdrawWalletNumber,
        ),
      ],
    );
  }
}

class _HawalaRecipientFields extends StatelessWidget {
  final WalletController controller;

  const _HawalaRecipientFields({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WalletInfoMessage(
          icon: Icons.info_outline_rounded,
          text: Tk.walletWithdrawHawalaInfo.trParams({
            'fee': controller.formatMoney(controller.withdrawHawalaFee),
          }),
        ),
        const SizedBox(height: 14),
        AppInputField(
          controller: controller.withdrawHawalaFullNameController,
          label: Tk.walletWithdrawHawalaFullName.tr,
          hint: Tk.walletWithdrawHawalaFullName.tr,
          prefixIcon: Icons.badge_outlined,
          validator: controller.validateWithdrawHawalaFullName,
        ),
        const SizedBox(height: 12),
        AppInputField(
          controller: controller.withdrawHawalaPhoneController,
          label: Tk.walletWithdrawHawalaPhone.tr,
          hint: Tk.walletWithdrawHawalaPhone.tr,
          prefixIcon: Icons.phone_android_outlined,
          keyboardType: TextInputType.phone,
          validator: controller.validateWithdrawHawalaPhone,
        ),
      ],
    );
  }
}

class _WithdrawSummaryCard extends StatelessWidget {
  final WalletController controller;

  const _WithdrawSummaryCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller.withdrawAmountController,
      builder: (_, __, ___) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.border.withValues(alpha: .35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Tk.walletWithdrawSummaryTitle.tr,
                style: TextStyle(
                  color: context.foreground,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              _SummaryRow(
                label: Tk.walletWithdrawMethodTitle.tr,
                value: controller.withdrawMethodLabel(),
              ),
              const SizedBox(height: 10),
              _SummaryRow(
                label: Tk.walletOperationAmount.tr,
                value: controller.formatMoney(
                  controller.withdrawRequestedAmount ?? 0,
                ),
              ),
              const SizedBox(height: 10),
              _SummaryRow(
                label: Tk.walletWithdrawFeeLabel.tr,
                value: controller.formatMoney(controller.withdrawHawalaFee),
              ),
              Divider(
                height: 22,
                thickness: 1,
                color: context.border.withValues(alpha: .24),
              ),
              _SummaryRow(
                label: Tk.walletWithdrawNetAmount.tr,
                value: controller.formatMoney(controller.withdrawNetAmount),
                emphasize: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: emphasize ? context.foreground : context.mutedForeground,
              fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
              fontSize: emphasize ? 13.6 : 12.4,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            color: emphasize ? context.primary : context.foreground,
            fontWeight: FontWeight.w900,
            fontSize: emphasize ? 15 : 13,
          ),
        ),
      ],
    );
  }
}

class _WithdrawBalanceCard extends StatelessWidget {
  final String title;
  final String value;

  const _WithdrawBalanceCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.border.withValues(alpha: .35)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: context.info.withValues(alpha: .10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_circle_up_outlined,
              color: context.info,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.mutedForeground,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: context.foreground,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
