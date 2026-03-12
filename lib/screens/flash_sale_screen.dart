import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/flash_sale/flash_sale_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/utils/app_date_utils.dart';
import 'package:rwnaqk/core/utils/app_breakpoints.dart';
import 'package:rwnaqk/widgets/app_categories_filter_sheet.dart';
import 'package:rwnaqk/widgets/app_filter_button.dart';
import 'package:rwnaqk/widgets/card/product_grid_section.dart';
import 'package:rwnaqk/widgets/common/app_empty_state.dart';
import 'package:rwnaqk/widgets/common/app_section_header.dart';
import 'package:rwnaqk/widgets/home/home_layout.dart';

class FlashSaleScreen extends GetView<FlashSaleController> {
  const FlashSaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final cols = AppBreakpoints.productGridColumns(w);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FlashSaleHeroHeader(controller: controller),
                  const SizedBox(height: 12),

                  Obx(() {
                    return _FlashSaleDiscountTabs(
                      discounts: controller.discounts,
                      selected: controller.selectedDiscount.value,
                      onChanged: controller.selectDiscount,
                    );
                  }),

                  const SizedBox(height: 14),

                  Obx(() {
                    final d = controller.selectedDiscount.value;
                    final title = d == 0
                        ? 'All Discount'.tr
                        : '$d% Discount'.tr;

                    return Row(
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
                            Get.bottomSheet(
                              const AppCategoriesFilterSheet(),
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                            );
                          },
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 12),

                  Obx(() {
                    final items = controller.flashSaleProducts.toList();

                    if (items.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: AppEmptyState(
                          title: 'No offers found',
                          subtitle: 'Try another discount or adjust filters.',
                          icon: Icons.local_offer_outlined,
                        ),
                      );
                    }

                    return ProductGridSection(
                      items: items,
                      crossAxisCount: cols,
                      crossAxisSpacing: HomeLayout.gridSpacing,
                      mainAxisSpacing: HomeLayout.gridSpacing,
                      childAspectRatio: 1.0,
                      onTap: controller.openProduct,
                    );
                  }),
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
  final FlashSaleController controller;

  const _FlashSaleHeroHeader({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.primary;
    final accent = context.accent;
    final headerBg = context.isDark
        ? context.card.withOpacity(0.96)
        : context.background;
    final softCircle = context.isDark
        ? accent.withOpacity(0.18)
        : accent.withOpacity(0.90);
    final deepCircle = context.isDark ? primary.withOpacity(0.85) : primary;

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
                          'Flash Sale'.tr,
                          style: TextStyle(
                            color: context.foreground,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Choose Your Discount'.tr,
                          style: TextStyle(
                            color: context.mutedForeground.withOpacity(
                              context.isDark ? 0.9 : 0.85,
                            ),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(() {
                    final hh = AppDateUtils.pad2(controller.hh.value);
                    final mm = AppDateUtils.pad2(controller.mm.value);
                    final ss = AppDateUtils.pad2(controller.ss.value);

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.alarm, color: context.primary, size: 18),
                        const SizedBox(width: 8),
                        _FlashSaleCountdownBox(text: hh),
                        const SizedBox(width: 6),
                        _FlashSaleCountdownBox(text: mm),
                        const SizedBox(width: 6),
                        _FlashSaleCountdownBox(text: ss),
                      ],
                    );
                  }),
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
        ? context.background.withOpacity(0.35)
        : context.background;
    final border = context.border.withOpacity(context.isDark ? 0.55 : 0.35);

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
            color: context.shadow.withOpacity(context.isDark ? 0.20 : 0.12),
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
        ? context.muted.withOpacity(0.55)
        : context.muted.withOpacity(0.35);

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
          final label = d == 0 ? 'All'.tr : '$d%';

          if (!isOn) {
            return GestureDetector(
              onTap: () => onChanged(d),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Text(
                  label,
                  style: TextStyle(
                    color: context.foreground.withOpacity(0.85),
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
                    color: context.primary.withOpacity(
                      context.isDark ? 0.22 : 0.20,
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