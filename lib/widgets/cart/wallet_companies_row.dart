import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/cart/payment_method_section.dart';

class WalletCompaniesRow extends StatelessWidget {
  final List<WalletCompany> companies;

  const WalletCompaniesRow({
    super.key,
    required this.companies,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: companies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          return _CompanyAvatar(company: companies[i]);
        },
      ),
    );
  }
}

class _CompanyAvatar extends StatelessWidget {
  final WalletCompany company;

  const _CompanyAvatar({
    required this.company,
  });

  @override
  Widget build(BuildContext context) {
    final hasAsset =
        company.assetPath != null && company.assetPath!.trim().isNotEmpty;

    final border = context.border.withOpacity(.30);
    final bg = context.muted.withOpacity(context.isDark ? .16 : .24);

    return Tooltip(
      message: company.name,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bg,
          border: Border.all(color: border),
        ),
        child: Center(
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.card,
              border: Border.all(color: context.border.withOpacity(.35)),
            ),
            child: Center(
              child: hasAsset
                  ? ClipOval(
                      child: Image.asset(
                        company.assetPath!,
                        width: 22,
                        height: 22,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      company.icon ?? Icons.account_balance,
                      size: 18,
                      color: context.mutedForeground,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}