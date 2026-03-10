import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/cart/payment_method_section.dart';
import 'package:rwnaqk/widgets/cart/wallet_companies_row.dart';

class ReceiverInfoBlock extends StatelessWidget {
  final String receiverNameLabel;
  final String walletNumberLabel;
  final String receiverNameValue;
  final String walletNumberValue;
  final List<WalletCompany> companies;

  const ReceiverInfoBlock({
    super.key,
    required this.receiverNameLabel,
    required this.walletNumberLabel,
    required this.receiverNameValue,
    required this.walletNumberValue,
    required this.companies,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border.withOpacity(.35)),
        boxShadow: [
          BoxShadow(
            color: context.shadow.withOpacity(context.isDark ? .08 : .05),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (companies.isNotEmpty) ...[
            WalletCompaniesRow(companies: companies),
            const SizedBox(height: 12),
            Divider(
              height: 1,
              thickness: 1,
              color: context.border.withOpacity(.25),
            ),
            const SizedBox(height: 12),
          ],
          _InfoRow(
            icon: Icons.person_outline,
            label: receiverNameLabel,
            value: receiverNameValue,
          ),
          Divider(
            height: 16,
            thickness: 1,
            color: context.border.withOpacity(.25),
          ),
          _InfoRow(
            icon: Icons.phone_outlined,
            label: walletNumberLabel,
            value: walletNumberValue,
          ),
          if (companies.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(
              height: 1,
              thickness: 1,
              color: context.border.withOpacity(.25),
            ),
            const SizedBox(height: 10),
            Text(
              'Available companies',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.mutedForeground,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.trim().isEmpty ? '—' : value.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.muted.withOpacity(context.isDark ? .22 : .45),
            border: Border.all(color: context.border.withOpacity(.35)),
          ),
          child: Icon(icon, size: 18, color: context.mutedForeground),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.mutedForeground,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                v,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.foreground,
                  fontWeight: FontWeight.w900,
                  fontSize: 13.5,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}