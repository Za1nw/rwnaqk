import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/wallet/wallet_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/models/wallet/wallet_transaction_model.dart';
import 'package:rwnaqk/widgets/common/app_back_header.dart';
import 'package:rwnaqk/widgets/wallet/wallet_empty_state.dart';
import 'package:rwnaqk/widgets/wallet/wallet_status_chip.dart';

class WalletOperationDetailsScreen extends GetView<WalletController> {
  const WalletOperationDetailsScreen({super.key});

  WalletTransactionModel? _resolveTransaction() {
    final args = Get.arguments;

    if (args is WalletTransactionModel) {
      return controller.findTransactionById(args.id) ?? args;
    }

    if (args is String) {
      return controller.findTransactionById(args);
    }

    return controller.selectedTransaction.value;
  }

  @override
  Widget build(BuildContext context) {
    final transaction = _resolveTransaction();

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 24),
          children: [
            AppBackHeader(
              title: Tk.walletOperationDetails.tr,
              onBack: Get.back,
              showTrailing: false,
            ),
            const SizedBox(height: 16),
            if (transaction == null)
              WalletEmptyState(
                title: Tk.walletOperationMissingTitle.tr,
                subtitle: Tk.walletOperationMissingSubtitle.tr,
                icon: Icons.receipt_long_outlined,
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: context.card,
                  borderRadius: BorderRadius.circular(24),
                  border:
                      Border.all(color: context.border.withValues(alpha: .35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            controller.typeLabel(transaction.type),
                            style: TextStyle(
                              color: context.foreground,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        WalletStatusChip(
                          status: transaction.status,
                          label: controller.statusLabel(transaction.status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      controller.formatTransactionAmount(transaction),
                      style: TextStyle(
                        color: context.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _DetailRow(
                      label: Tk.walletOperationId.tr,
                      value: transaction.id,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: Tk.walletOperationType.tr,
                      value: controller.typeLabel(transaction.type),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: Tk.walletOperationStatus.tr,
                      value: controller.statusLabel(transaction.status),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: Tk.walletOperationDate.tr,
                      value: controller.formatDate(transaction.createdAt),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: Tk.walletOperationDescription.tr,
                      value: controller.resolveTransactionDescription(
                          transaction.description),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              color: context.mutedForeground,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: context.foreground,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
