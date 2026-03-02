import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

/// شركة تحويل: استخدم IconData الآن، أو assetPath لو عندك شعار من assets
class WalletCompany {
  final String name;
  final IconData? icon;
  final String? assetPath;

  const WalletCompany({required this.name, this.icon, this.assetPath});
}

class PaymentMethodSection extends StatelessWidget {
  /// نصوص مترجمة من الخارج (استخدم .tr عند الاستدعاء)
  final String titleText;

  final String cashTitle;
  final String cashSubtitle;

  final String walletTitle;
  final String walletSubtitle;

  final String receiverNameLabel;
  final String walletNumberLabel;

  /// ✅ قيم ثابتة (عرض فقط)
  final String receiverNameValue;
  final String walletNumberValue;

  /// ✅ شركات التحويل تحت معلومات الحساب (أيقونات فقط)
  final List<WalletCompany> walletCompanies;

  /// ✅ بدون enum
  /// القيم المقترحة: "cod" أو "wallet"
  final String selectedId;
  final ValueChanged<String> onChanged;

  /// ✅ رسالة تظهر تحت الخيارين بمجرد اختيار أي خيار
  /// لو null أو فاضية ما تنعرض.
  final String? infoMessage;

  /// أيقونة الرسالة (اختياري)
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
    required this.selectedId,
    required this.onChanged,
    this.infoMessage,
    this.infoIcon = Icons.info_outline_rounded,
  });

  bool get _isWallet => selectedId == 'wallet';
  bool get _showInfo => (infoMessage != null && infoMessage!.trim().isNotEmpty);

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

        /// الخيار 1
        _MethodCard(
          selected: selectedId == 'cod',
          title: cashTitle,
          subtitle: cashSubtitle,
          leadingIcon: Icons.payments_outlined,
          onTap: () => onChanged('cod'),
        ),

        const SizedBox(height: 10),

        /// الخيار 2
        _MethodCard(
          selected: _isWallet,
          title: walletTitle,
          subtitle: walletSubtitle,
          leadingIcon: Icons.account_balance_wallet_outlined,
          onTap: () => onChanged('wallet'),
        ),

        /// ✅ رسالة منظمة تحت الخيارين
        if (_showInfo) ...[
          const SizedBox(height: 10),
          _InfoBanner(icon: infoIcon, text: infoMessage!),
        ],

        /// ✅ معلومات المحفظة + شركات التحويل (تظهر فقط عند اختيار wallet)
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 180),
          crossFadeState: _isWallet
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
            child: _WalletInfoCard(
              receiverNameLabel: receiverNameLabel,
              walletNumberLabel: walletNumberLabel,
              receiverNameValue: receiverNameValue,
              walletNumberValue: walletNumberValue,
              companies: walletCompanies,
            ),
          ),
        ),
      ],
    );
  }
}

/// =========================
/// معلومات المحفظة كعرض ثابت (بدون انبوت) + صف أيقونات الشركات
class _WalletInfoCard extends StatelessWidget {
  final String receiverNameLabel;
  final String walletNumberLabel;

  final String receiverNameValue;
  final String walletNumberValue;

  final List<WalletCompany> companies;

  const _WalletInfoCard({
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
          /// ✅ الشركات أولاً
          if (companies.isNotEmpty) ...[
            _CompaniesRowScroll(companies: companies),
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

          /// ✅ صف الأيقونات فقط مع سكرول أفقي
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

/// =========================
/// صف أفقي مع تمرير (أيقونات فقط)
class _CompaniesRowScroll extends StatelessWidget {
  final List<WalletCompany> companies;

  const _CompaniesRowScroll({required this.companies});

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

  const _CompanyAvatar({required this.company});

  @override
  Widget build(BuildContext context) {
    final hasAsset =
        (company.assetPath != null && company.assetPath!.trim().isNotEmpty);

    final border = context.border.withOpacity(.30);
    final bg = context.muted.withOpacity(context.isDark ? .16 : .24);

    return Tooltip(
      message: company.name, // الاسم ما يظهر في الواجهة، فقط Tooltip
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

/// =========================
/// رسالة منظمة وأنيقة
class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoBanner({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: context.muted.withOpacity(context.isDark ? .18 : .28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.border.withOpacity(.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.card,
              border: Border.all(color: context.border.withOpacity(.35)),
            ),
            child: Icon(icon, size: 16, color: context.mutedForeground),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: context.mutedForeground,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final VoidCallback onTap;

  const _MethodCard({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final compact = c.maxWidth < 360;

        final bg = selected
            ? context.primary.withOpacity(context.isDark ? .18 : .12)
            : context.card;

        final borderColor = selected
            ? context.primary.withOpacity(.35)
            : context.border.withOpacity(.35);

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsetsDirectional.fromSTEB(
              compact ? 12 : 14,
              compact ? 10 : 12,
              compact ? 12 : 14,
              compact ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: context.shadow.withOpacity(context.isDark ? .08 : .05),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                _RadioLike(selected: selected, size: compact ? 20 : 22),
                const SizedBox(width: 10),
                Container(
                  width: compact ? 32 : 34,
                  height: compact ? 32 : 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.muted.withOpacity(
                      context.isDark ? .22 : .45,
                    ),
                    border: Border.all(color: context.border.withOpacity(.35)),
                  ),
                  child: Icon(
                    leadingIcon,
                    size: compact ? 18 : 19,
                    color: context.mutedForeground,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.foreground,
                          fontWeight: FontWeight.w900,
                          fontSize: compact ? 13.5 : 14.5,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.mutedForeground,
                          fontWeight: FontWeight.w600,
                          fontSize: compact ? 11.5 : 12.5,
                          height: 1.05,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RadioLike extends StatelessWidget {
  final bool selected;
  final double size;

  const _RadioLike({required this.selected, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? context.primary : context.border.withOpacity(.55),
          width: 2,
        ),
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: selected ? size * .52 : 0,
          height: selected ? size * .52 : 0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.primary,
          ),
        ),
      ),
    );
  }
}
