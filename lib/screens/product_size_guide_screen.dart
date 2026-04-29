import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/product_details/product_details_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/models/home_product_item.dart';
import 'package:rwnaqk/widgets/card/product_grid_section.dart';
import 'package:rwnaqk/widgets/common/app_sectioned_page.dart';

const double _gridSpacing = 12;

class ProductSizeGuideScreen extends GetView<ProductDetailsController> {
  const ProductSizeGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSectionedPage(
      title: Tk.productDetailsSizeGuide.tr,
      onBack: Get.back,
      children: [
        Obx(
          () {
            final rows = controller.sizeGuide;
            final recentItems = controller.recommended.isNotEmpty
                ? controller.recommended.take(2).toList()
                : controller.mostPopular.take(2).toList();

            if (rows.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SizeGuideAudienceTabs(),
                const SizedBox(height: 14),
                _SizeGuideTable(
                  rows: rows,
                  selectedSize: controller.selectedSize.value,
                ),
                const SizedBox(height: 14),
                Center(
                  child: _SizeGuideChooseLink(
                    onTap: () => _openHowToChooseSheet(context),
                  ),
                ),
                if (recentItems.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  _SizeGuideSectionTitle(title: Tk.wishlistRecentlyViewed.tr),
                  const SizedBox(height: 10),
                  ProductGridSection(
                    items: recentItems,
                    crossAxisCount:
                        MediaQuery.of(context).size.width >= 700 ? 3 : 2,
                    crossAxisSpacing: _gridSpacing,
                    mainAxisSpacing: _gridSpacing,
                    childAspectRatio: 1.0,
                    onTap: (p) => Get.toNamed(
                      AppRoutes.product,
                      arguments: {
                        'item': p,
                        'mostPopular': controller.mostPopular.toList(),
                        'recommended': controller.recommended.toList(),
                        'reviews': controller.reviews.toList(),
                      },
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  void _openHowToChooseSheet(BuildContext context) {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          decoration: BoxDecoration(
            color: context.background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: const _HowToMeasureCard(),
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }
}

class _SizeGuideTable extends StatelessWidget {
  final List<ProductSizeGuideRow> rows;
  final String selectedSize;

  const _SizeGuideTable({
    required this.rows,
    required this.selectedSize,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedSelected = selectedSize.trim().toUpperCase();
    const labelWidth = 76.0;
    const minValueWidth = 58.0;
    final tableRows = <_SizeGuideMatrixRow>[
      _SizeGuideMatrixRow(
        label: Tk.productDetailsSizeColumn.tr,
        values: rows.map((row) => row.size.trim().toUpperCase()).toList(),
      ),
      _SizeGuideMatrixRow(
        label: Tk.productDetailsChestColumn.tr,
        values: rows.map((row) => row.chest).toList(),
      ),
      _SizeGuideMatrixRow(
        label: Tk.productDetailsWaistColumn.tr,
        values: rows.map((row) => row.waist).toList(),
      ),
      _SizeGuideMatrixRow(
        label: Tk.productDetailsHipsColumn.tr,
        values: rows.map((row) => row.hips).toList(),
      ),
      _SizeGuideMatrixRow(
        label: Tk.productDetailsLengthColumn.tr,
        values: rows.map((row) => row.length).toList(),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableValueWidth =
            (constraints.maxWidth - labelWidth) / rows.length;
        final valueWidth = availableValueWidth < minValueWidth
            ? minValueWidth
            : availableValueWidth;

        return Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.border.withValues(alpha: .35)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: tableRows.asMap().entries.map((entry) {
                final isLastRow = entry.key == tableRows.length - 1;
                final row = entry.value;

                return Row(
                  children: [
                    _SizeGuideMatrixCell(
                      text: row.label,
                      width: labelWidth,
                      isLabel: true,
                      showBottomBorder: !isLastRow,
                      showEndBorder: true,
                    ),
                    ...row.values.asMap().entries.map((valueEntry) {
                      final value = valueEntry.value;
                      final isLastColumn =
                          valueEntry.key == row.values.length - 1;
                      final isActive = normalizedSelected.isNotEmpty &&
                          rows[valueEntry.key].size.trim().toUpperCase() ==
                              normalizedSelected;

                      return _SizeGuideMatrixCell(
                        text: value,
                        width: valueWidth,
                        isActive: isActive,
                        showBottomBorder: !isLastRow,
                        showEndBorder: !isLastColumn,
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _SizeGuideMatrixRow {
  final String label;
  final List<String> values;

  const _SizeGuideMatrixRow({
    required this.label,
    required this.values,
  });
}

class _SizeGuideMatrixCell extends StatelessWidget {
  final String text;
  final double width;
  final bool isLabel;
  final bool isActive;
  final bool showBottomBorder;
  final bool showEndBorder;

  const _SizeGuideMatrixCell({
    required this.text,
    required this.width,
    this.isLabel = false,
    this.isActive = false,
    this.showBottomBorder = false,
    this.showEndBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = context.border.withValues(alpha: .28);

    return Container(
      width: width,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive
            ? context.primary.withValues(alpha: context.isDark ? .16 : .08)
            : context.card,
        border: BorderDirectional(
          end: showEndBorder ? BorderSide(color: borderColor) : BorderSide.none,
          bottom: showBottomBorder
              ? BorderSide(color: borderColor)
              : BorderSide.none,
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isActive ? context.primary : context.foreground,
          fontWeight: isLabel || isActive ? FontWeight.w900 : FontWeight.w700,
          fontSize: isLabel ? 11.2 : 12,
        ),
      ),
    );
  }
}

class _SizeGuideAudienceTabs extends StatefulWidget {
  const _SizeGuideAudienceTabs();

  @override
  State<_SizeGuideAudienceTabs> createState() => _SizeGuideAudienceTabsState();
}

class _SizeGuideAudienceTabsState extends State<_SizeGuideAudienceTabs> {
  int selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    final labels = [
      Tk.productDetailsSizeGuideWomen.tr,
      Tk.productDetailsSizeGuideMen.tr,
      Tk.productDetailsSizeGuideKids.tr,
    ];

    return Container(
      width: double.infinity,
      height: 46,
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: context.border.withValues(alpha: .35)),
      ),
      child: Row(
        children: labels.asMap().entries.map((entry) {
          final index = entry.key;
          final isSelected = selectedIndex == index;

          return Expanded(
            child: InkWell(
              onTap: () => setState(() => selectedIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? context.primary : Colors.transparent,
                  border: BorderDirectional(
                    end: index == labels.length - 1
                        ? BorderSide.none
                        : BorderSide(
                            color: context.border.withValues(alpha: .30),
                          ),
                  ),
                ),
                child: Text(
                  entry.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? context.primaryForeground
                        : context.foreground,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SizeGuideChooseLink extends StatelessWidget {
  final VoidCallback onTap;

  const _SizeGuideChooseLink({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          Tk.productDetailsSizeGuideHowToChoose.tr,
          style: TextStyle(
            color: context.foreground,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            decoration: TextDecoration.underline,
            decorationColor: context.foreground,
          ),
        ),
      ),
    );
  }
}

class _SizeGuideSectionTitle extends StatelessWidget {
  final String title;

  const _SizeGuideSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: context.foreground,
        fontWeight: FontWeight.w900,
        fontSize: 16,
      ),
    );
  }
}

class _HowToMeasureCard extends StatelessWidget {
  const _HowToMeasureCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.border.withValues(alpha: .34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.accessibility_new_rounded,
                  color: context.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                Tk.productDetailsSizeGuideHowToMeasure.tr,
                style: TextStyle(
                  color: context.foreground,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _MeasureHintRow(
            icon: Icons.straighten_rounded,
            title: Tk.productDetailsChestColumn.tr,
            description: Tk.productDetailsSizeGuideChestHelp.tr,
          ),
          const SizedBox(height: 10),
          _MeasureHintRow(
            icon: Icons.straighten_rounded,
            title: Tk.productDetailsWaistColumn.tr,
            description: Tk.productDetailsSizeGuideWaistHelp.tr,
          ),
          const SizedBox(height: 10),
          _MeasureHintRow(
            icon: Icons.straighten_rounded,
            title: Tk.productDetailsHipsColumn.tr,
            description: Tk.productDetailsSizeGuideHipsHelp.tr,
          ),
          const SizedBox(height: 10),
          _MeasureHintRow(
            icon: Icons.height_rounded,
            title: Tk.productDetailsLengthColumn.tr,
            description: Tk.productDetailsSizeGuideLengthHelp.tr,
          ),
        ],
      ),
    );
  }
}

class _MeasureHintRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _MeasureHintRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.input.withValues(alpha: context.isDark ? .28 : .58),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.border.withValues(alpha: .22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: context.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.foreground,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: context.mutedForeground,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.4,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
