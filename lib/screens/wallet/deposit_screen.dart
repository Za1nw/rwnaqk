import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/wallet/wallet_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/widgets/app_button.dart';
import 'package:rwnaqk/widgets/cart/payment_method_section.dart';
import 'package:rwnaqk/widgets/cart/payment_receipt_upload_card.dart';
import 'package:rwnaqk/widgets/common/app_back_header.dart';
import 'package:rwnaqk/widgets/wallet/wallet_amount_input.dart';

class DepositScreen extends GetView<WalletController> {
  const DepositScreen({super.key});

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
                title: Tk.walletDeposit.tr,
                onBack: Get.back,
                showTrailing: false,
              ),
              const SizedBox(height: 18),
              _WalletInfoCard(
                title: Tk.walletAvailableBalance.tr,
                value: controller.formatMoney(controller.balance),
              ),
              const SizedBox(height: 16),
              PaymentMethodSection(
                titleText: Tk.walletTransferMethodTitle.tr,
                cashTitle: '',
                cashSubtitle: '',
                walletTitle: Tk.cartPaymentWalletTitle.tr,
                walletSubtitle: Tk.walletTransferMethodSubtitle.tr,
                receiverNameLabel: Tk.cartPaymentReceiverName.tr,
                walletNumberLabel: Tk.cartPaymentWalletNumber.tr,
                walletAccounts: controller.walletTransferAccounts,
                selectedId: 'wallet',
                onChanged: (_) {},
                selectedWalletAccountIndex:
                    controller.selectedDepositWalletAccountIndex.value,
                onWalletAccountChanged:
                    controller.setSelectedDepositWalletAccountIndex,
                showCashOption: false,
                infoMessage: Tk.walletDepositTransferInfo.tr,
              ),
              const SizedBox(height: 16),
              Form(
                key: controller.depositFormKey,
                child: WalletAmountInput(
                  controller: controller.depositAmountController,
                  label: Tk.walletEnterAmount.tr,
                  hint: Tk.walletEnterAmount.tr,
                  suggestedTitle: Tk.walletSuggestedAmounts.tr,
                  suggestedAmounts: controller.suggestedAmounts,
                  amountFormatter: controller.formatMoney,
                  onSuggestedAmountTap: controller.setDepositSuggestion,
                  validator: controller.validateDepositAmount,
                ),
              ),
              const SizedBox(height: 18),
              PaymentReceiptUploadCard(
                imageFile: controller.depositReceiptImage,
                onPickImage: controller.pickDepositReceiptImage,
                onRemoveImage: controller.removeDepositReceiptImage,
                titleText: Tk.commonUploadReceiptImage.tr,
                pickImageText: Tk.commonChooseImage.tr,
              ),
              const SizedBox(height: 24),
              AppButton(
                text: Tk.walletConfirm.tr,
                icon: Icons.check_circle_outline_rounded,
                isLoading: controller.isSubmitting.value,
                onPressed: () async {
                  final isValid =
                      controller.depositFormKey.currentState?.validate() ??
                          false;
                  if (!isValid) return;

                  final success = await controller.depositBalance();
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

class _WalletInfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _WalletInfoCard({
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
              color: context.primary.withValues(alpha: .10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.savings_outlined,
              color: context.primary,
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
