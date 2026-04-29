import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/wallet/wallet_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/widgets/app_button.dart';
import 'package:rwnaqk/widgets/app_input_field.dart';
import 'package:rwnaqk/widgets/common/app_back_header.dart';
import 'package:rwnaqk/widgets/wallet/wallet_status_chip.dart';

class RefundCheckScreen extends GetView<WalletController> {
  const RefundCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Obx(() {
          final result = controller.refundStatus.value;

          return ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 24),
            children: [
              AppBackHeader(
                title: Tk.walletRefundCheck.tr,
                onBack: Get.back,
                showTrailing: false,
              ),
              const SizedBox(height: 18),
              Form(
                key: controller.refundFormKey,
                child: AppInputField(
                  controller: controller.refundLookupController,
                  label: Tk.walletRefundCheck.tr,
                  hint: Tk.walletRefundLookupHint.tr,
                  prefixIcon: Icons.rule_folder_outlined,
                  textInputAction: TextInputAction.done,
                  validator: controller.validateRefundLookup,
                ),
              ),
              const SizedBox(height: 18),
              AppButton(
                text: Tk.walletCheckNow.tr,
                icon: Icons.search_rounded,
                isLoading: controller.isRefundLoading.value,
                onPressed: () async {
                  final isValid =
                      controller.refundFormKey.currentState?.validate() ??
                          false;
                  if (!isValid) return;
                  await controller.checkRefundStatus();
                },
              ),
              if (result != null) ...[
                const SizedBox(height: 20),
                _RefundResultCard(
                  title: Tk.walletRefundResultTitle.tr,
                  status: controller.statusLabel(result.status),
                  rawStatus: result.status,
                  amount: controller.formatMoney(result.amount),
                  refundId: result.refundId,
                  orderId: result.orderId,
                  message: result.message.tr,
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _RefundResultCard extends StatelessWidget {
  final String title;
  final String status;
  final String rawStatus;
  final String amount;
  final String refundId;
  final String orderId;
  final String message;

  const _RefundResultCard({
    required this.title,
    required this.status,
    required this.rawStatus,
    required this.amount,
    required this.refundId,
    required this.orderId,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.border.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: context.foreground,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              WalletStatusChip(
                status: rawStatus,
                label: status,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _RefundInfoRow(
            label: Tk.walletOperationAmount.tr,
            value: amount,
          ),
          const SizedBox(height: 10),
          _RefundInfoRow(
            label: Tk.walletRefundId.tr,
            value: refundId,
          ),
          const SizedBox(height: 10),
          _RefundInfoRow(
            label: Tk.walletOrderId.tr,
            value: orderId,
          ),
          const SizedBox(height: 10),
          _RefundInfoRow(
            label: Tk.walletMessage.tr,
            value: message,
          ),
        ],
      ),
    );
  }
}

class _RefundInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _RefundInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
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
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
