import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/wallet/wallet_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/routes/wallet_routes.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/widgets/common/app_back_header.dart';
import 'package:rwnaqk/widgets/common/app_error_state.dart';
import 'package:rwnaqk/widgets/common/app_section_header.dart';
import 'package:rwnaqk/widgets/wallet/wallet_action_button.dart';
import 'package:rwnaqk/widgets/wallet/wallet_balance_card.dart';
import 'package:rwnaqk/widgets/wallet/wallet_empty_state.dart';
import 'package:rwnaqk/widgets/wallet/wallet_transaction_item.dart';

class WalletScreen extends GetView<WalletController> {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Obx(() {
          final showInitialLoader = controller.isWalletLoading.value &&
              controller.wallet.value == null &&
              controller.transactions.isEmpty;

          return RefreshIndicator(
            onRefresh: controller.refreshWallet,
            color: context.primary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 24),
              children: [
                AppBackHeader(
                  title: Tk.walletTitle.tr,
                  onBack: Get.back,
                  trailingIcon: Icons.receipt_long_outlined,
                  onTrailingTap: () => Get.toNamed(WalletRoutes.transactions),
                ),
                const SizedBox(height: 16),
                if (showInitialLoader)
                  SizedBox(
                    height: 420,
                    child: Center(
                      child: CircularProgressIndicator(color: context.primary),
                    ),
                  )
                else if (controller.wallet.value == null)
                  AppErrorState(
                    title: Tk.walletLoadFailed.tr,
                    subtitle: controller.walletError.value ??
                        Tk.commonPleaseTryAgain.tr,
                    buttonText: Tk.commonRetry.tr,
                    onRetry: controller.refreshWallet,
                    expanded: false,
                  )
                else ...[
                  WalletBalanceCard(
                    title: Tk.walletBalance.tr,
                    balanceText: controller.formatMoney(controller.balance),
                    subtitle: Tk.walletAvailableBalance.tr,
                    updatedAtText: controller.walletUpdatedAtLabel,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: WalletActionButton(
                          label: Tk.walletDeposit.tr,
                          icon: Icons.add_rounded,
                          onTap: () => Get.toNamed(WalletRoutes.deposit),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: WalletActionButton(
                          label: Tk.walletWithdraw.tr,
                          icon: Icons.arrow_upward_rounded,
                          onTap: () => Get.toNamed(WalletRoutes.withdraw),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: WalletActionButton(
                          label: Tk.walletRefundCheck.tr,
                          icon: Icons.rule_folder_outlined,
                          onTap: () => Get.toNamed(WalletRoutes.refundCheck),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppSectionHeader(
                    title: Tk.walletRecentTransactions.tr,
                    actionText: Tk.walletViewAll.tr,
                    onActionTap: () => Get.toNamed(WalletRoutes.transactions),
                  ),
                  const SizedBox(height: 12),
                  if (controller.isTransactionsLoading.value &&
                      controller.transactions.isEmpty)
                    SizedBox(
                      height: 180,
                      child: Center(
                        child:
                            CircularProgressIndicator(color: context.primary),
                      ),
                    )
                  else if (controller.transactionsError.value != null &&
                      controller.transactions.isEmpty)
                    AppErrorState(
                      title: Tk.walletLoadFailed.tr,
                      subtitle: controller.transactionsError.value ??
                          Tk.commonPleaseTryAgain.tr,
                      buttonText: Tk.commonRetry.tr,
                      onRetry: controller.fetchWalletTransactions,
                      expanded: false,
                    )
                  else if (controller.recentTransactionsPreview.isEmpty)
                    WalletEmptyState(
                      title: Tk.walletRecentEmptyTitle.tr,
                      subtitle: Tk.walletRecentEmptySubtitle.tr,
                    )
                  else
                    Column(
                      children:
                          controller.recentTransactionsPreview.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: WalletTransactionItem(
                            transaction: item,
                            amountText:
                                controller.formatTransactionAmount(item),
                            typeText: controller.typeLabel(item.type),
                            statusText: controller.statusLabel(item.status),
                            descriptionText:
                                controller.resolveTransactionDescription(
                                    item.description),
                            dateText: controller.formatDate(item.createdAt),
                            onTap: () => controller.openOperationDetails(item),
                          ),
                        );
                      }).toList(growable: false),
                    ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}
