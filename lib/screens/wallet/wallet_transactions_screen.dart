import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/wallet/wallet_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/models/wallet/wallet_transaction_model.dart';
import 'package:rwnaqk/widgets/common/app_back_header.dart';
import 'package:rwnaqk/widgets/common/app_error_state.dart';
import 'package:rwnaqk/widgets/wallet/wallet_empty_state.dart';
import 'package:rwnaqk/widgets/wallet/wallet_transaction_item.dart';

class WalletTransactionsScreen extends GetView<WalletController> {
  const WalletTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 0),
          child: Column(
            children: [
              AppBackHeader(
                title: Tk.walletTransactions.tr,
                onBack: Get.back,
                showTrailing: false,
              ),
              const SizedBox(height: 14),
              Obx(() {
                return _WalletTransactionFilters(
                  value: controller.filter.value,
                  labelBuilder: controller.filterLabel,
                  onChanged: controller.filterTransactions,
                );
              }),
              const SizedBox(height: 14),
              Expanded(
                child: Obx(() {
                  if (controller.isTransactionsLoading.value &&
                      controller.transactions.isEmpty) {
                    return Center(
                      child: CircularProgressIndicator(color: context.primary),
                    );
                  }

                  if (controller.transactionsError.value != null &&
                      controller.transactions.isEmpty) {
                    return AppErrorState(
                      title: Tk.walletLoadFailed.tr,
                      subtitle: controller.transactionsError.value ??
                          Tk.commonPleaseTryAgain.tr,
                      buttonText: Tk.commonRetry.tr,
                      onRetry: controller.fetchWalletTransactions,
                      expanded: false,
                    );
                  }

                  if (controller.filteredTransactions.isEmpty) {
                    return WalletEmptyState(
                      title: Tk.walletNoTransactions.tr,
                      subtitle: Tk.walletNoTransactionsHint.tr,
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 18),
                    itemCount: controller.filteredTransactions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final item = controller.filteredTransactions[index];

                      return WalletTransactionItem(
                        transaction: item,
                        amountText: controller.formatTransactionAmount(item),
                        typeText: controller.typeLabel(item.type),
                        statusText: controller.statusLabel(item.status),
                        descriptionText: controller
                            .resolveTransactionDescription(item.description),
                        dateText: controller.formatDate(item.createdAt),
                        onTap: () => controller.openOperationDetails(item),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletTransactionFilters extends StatelessWidget {
  final WalletTransactionFilter value;
  final String Function(WalletTransactionFilter value) labelBuilder;
  final ValueChanged<WalletTransactionFilter> onChanged;

  const _WalletTransactionFilters({
    required this.value,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget chip(WalletTransactionFilter filter, IconData icon) {
      final active = value == filter;
      final foreground = active ? context.primary : context.foreground;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => onChanged(filter),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: active
                  ? context.primary.withValues(alpha: .12)
                  : context.card,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: active
                    ? context.primary.withValues(alpha: .28)
                    : context.border.withValues(alpha: .35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: foreground),
                const SizedBox(width: 8),
                Text(
                  labelBuilder(filter),
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w900,
                    fontSize: 12.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          chip(WalletTransactionFilter.all, Icons.grid_view_rounded),
          const SizedBox(width: 8),
          chip(WalletTransactionFilter.deposit,
              Icons.add_circle_outline_rounded),
          const SizedBox(width: 8),
          chip(
              WalletTransactionFilter.withdraw, Icons.arrow_circle_up_outlined),
          const SizedBox(width: 8),
          chip(
              WalletTransactionFilter.refund, Icons.assignment_return_outlined),
        ],
      ),
    );
  }
}
