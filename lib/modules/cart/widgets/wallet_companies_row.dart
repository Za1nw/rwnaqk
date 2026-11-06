import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/modules/checkout/data/models/wallet_company.dart';

class WalletCompaniesRow extends StatelessWidget {
  final List<WalletCompany> companies;
  final int? selectedIndex;
  final ValueChanged<int>? onChanged;

  const WalletCompaniesRow({
    super.key,
    required this.companies,
    this.selectedIndex,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: companies.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          return _CompanyAvatar(
            company: companies[i],
            selected: selectedIndex != null && selectedIndex == i,
            onTap: onChanged == null ? null : () => onChanged!(i),
          );
        },
      ),
    );
  }
}

class _CompanyAvatar extends StatelessWidget {
  final WalletCompany company;
  final bool selected;
  final VoidCallback? onTap;

  const _CompanyAvatar({
    required this.company,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasAsset =
        company.assetPath != null && company.assetPath!.trim().isNotEmpty;

    final border = selected
        ? context.primary.withValues(alpha: .95)
        : context.border.withValues(alpha: .30);
    final bg = selected
        ? context.primary.withValues(alpha: .16)
        : context.muted.withValues(alpha: context.isDark ? .16 : .24);
    final shadow = selected
        ? context.primary.withValues(alpha: .14)
        : context.shadow.withValues(alpha: context.isDark ? .18 : .06);

    return Tooltip(
      message: company.name,
      child: GestureDetector(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bg,
            border: Border.all(color: border, width: selected ? 2.0 : 1.0),
            boxShadow: [
              BoxShadow(
                color: shadow,
                blurRadius: selected ? 14 : 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: AnimatedScale(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              scale: selected ? 1.06 : 1.0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.card,
                  border: Border.all(
                    color: selected
                        ? context.primary.withValues(alpha: .22)
                        : context.border.withValues(alpha: .35),
                  ),
                ),
                child: Center(
                  child: hasAsset
                      ? ClipOval(
                          child: Image.asset(
                            company.assetPath!,
                            width: 18,
                            height: 18,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          company.icon ?? Icons.account_balance,
                          size: 17,
                          color: selected
                              ? context.primary
                              : context.mutedForeground,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
