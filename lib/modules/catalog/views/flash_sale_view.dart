import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_breakpoints.dart';
import 'package:rwnaqk_frontend/core/utils/app_date_utils.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_empty_state.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_section_header.dart';
import 'package:rwnaqk_frontend/modules/catalog/providers/catalog_providers.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/app_categories_filter_sheet.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/app_filter_button.dart';
import 'package:rwnaqk_frontend/modules/checkout/widgets/product_grid_section.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_layout.dart';

class FlashSaleScreen extends ConsumerWidget {
  const FlashSaleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(flashSaleProvider);
    final notifier = ref.read(flashSaleProvider.notifier);

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final cols = AppBreakpoints.productGridColumns(w);

            final d = state.selectedDiscount;
            final title = d == 0
                ? Tk.flashSaleAllDiscount.tr
                : Tk.flashSaleDiscountValue.trParams({'value': '$d'});

            final items = state.products;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FlashSaleHeroHeader(
                    hh: state.hh,
                    mm: state.mm,
                    ss: state.ss,
                  ),
                  const SizedBox(height: 12),

                  _FlashSaleDiscountTabs(
                    discounts: state.discounts,
                    selected: state.selectedDiscount,
                    onChanged: notifier.selectDiscount,
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: AppSectionHeader(
                          title: title,
                          titleFontSize: 18,
                          titleFontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 10),
                      AppFilterButton(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            builder: (_) => const AppCategoriesFilterSheet(),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: AppEmptyState(
                        title: Tk.flashSaleNoOffersTitle.tr,
                        subtitle: Tk.flashSaleNoOffersSubtitle.tr,
                        icon: Icons.local_offer_outlined,
                      ),
                    )
                  else
                    ProductGridSection(
                      items: items,
                      crossAxisCount: cols,
                      crossAxisSpacing: HomeLayout.gridSpacing,
                      mainAxisSpacing: HomeLayout.gridSpacing,
                      childAspectRatio: 1.0,
                      onTap: notifier.openProduct,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FlashSaleHeroHeader extends StatelessWidget {
  final int hh;
  final int mm;
  final int ss;

  const _FlashSaleHeroHeader({
    required this.hh,
    required this.mm,
    required this.ss,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.primary;
    final accent = context.accent;
    final headerBg = context.isDark
        ? context.card.withValues(alpha: 0.96)
        : context.background;
    final softCircle = context.isDark
        ? accent.withValues(alpha: 0.18)
        : accent.withValues(alpha: 0.90);
    final deepCircle =
        context.isDark ? primary.withValues(alpha: 0.85) : primary;

    final hhStr = AppDateUtils.pad2(hh);
    final mmStr = AppDateUtils.pad2(mm);
    final ssStr = AppDateUtils.pad2(ss);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 140,
        color: headerBg,
        child: Stack(
          children: [
            PositionedDirectional(
              start: 40,
              top: -120,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: softCircle,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            PositionedDirectional(
              end: -90,
              top: -140,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  color: deepCircle,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 18, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Tk.flashSaleTitle.tr,
                          style: TextStyle(
                            color: context.foreground,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          Tk.flashSaleSubtitle.tr,
                          style: TextStyle(
                            color: context.mutedForeground.withValues(
                              alpha: context.isDark ? 0.9 : 0.85,
                            ),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.alarm, color: context.primary, size: 18),
                      const SizedBox(width: 8),
                      _FlashSaleCountdownBox(text: hhStr),
                      const SizedBox(width: 6),
                      _FlashSaleCountdownBox(text: mmStr),
                      const SizedBox(width: 6),
                      _FlashSaleCountdownBox(text: ssStr),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlashSaleCountdownBox extends StatelessWidget {
  final String text;

  const _FlashSaleCountdownBox({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final bg = context.isDark
        ? context.background.withValues(alpha: 0.35)
        : context.background;
    final border =
        context.border.withValues(alpha: context.isDark ? 0.55 : 0.35);

    return Container(
      width: 32,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color:
                context.shadow.withValues(alpha: context.isDark ? 0.20 : 0.12),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: context.foreground,
          fontWeight: FontWeight.w900,
          fontSize: 12,
          height: 1.0,
        ),
      ),
    );
  }
}

class _FlashSaleDiscountTabs extends StatelessWidget {
  final List<int> discounts;
  final int selected;
  final ValueChanged<int> onChanged;

  const _FlashSaleDiscountTabs({
    required this.discounts,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final railBg = context.isDark
        ? context.muted.withValues(alpha: 0.55)
        : context.muted.withValues(alpha: 0.35);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: railBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.spaceBetween,
        children: discounts.map((d) {
          final isOn = d == selected;
          final label = d == 0 ? Tk.commonAll.tr : '$d%';

          if (!isOn) {
            return GestureDetector(
              onTap: () => onChanged(d),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Text(
                  label,
                  style: TextStyle(
                    color: context.foreground.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onChanged(d),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: context.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.primary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: context.primary.withValues(
                      alpha: context.isDark ? 0.22 : 0.20,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: context.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
