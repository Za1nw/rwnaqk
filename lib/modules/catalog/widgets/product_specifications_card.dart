import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_size_guide_sheet.dart';

class ProductSpecificationsCard extends StatefulWidget {
  final String sku;
  final String selectedSize;
  final ValueChanged<String>? onSelectSize;

  const ProductSpecificationsCard({
    super.key,
    required this.sku,
    required this.selectedSize,
    this.onSelectSize,
  });

  @override
  State<ProductSpecificationsCard> createState() =>
      _ProductSpecificationsCardState();
}

class _ProductSpecificationsCardState extends State<ProductSpecificationsCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: context.shadow.withValues(alpha: context.isDark ? 0.12 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: context.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.format_list_bulleted_rounded,
                      color: context.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      Tk.productDetailsSpecifications.tr,
                      style: TextStyle(
                        color: context.foreground,
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: context.mutedForeground,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded) ...[
            Divider(
              height: 1,
              thickness: 0.7,
              color: context.border.withValues(alpha: 0.35),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _SpecItemRow(
                    label: Tk.productDetailsMaterial.tr,
                    valueWidget: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: const [
                        _BadgeTag(text: 'Cotton 95%'),
                        _BadgeTag(text: 'Elastane 5%'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SpecItemRow(
                    label: Tk.productDetailsOrigin.tr,
                    valueWidget: const _BadgeTag(text: 'Italy (EU)'),
                  ),
                  const SizedBox(height: 12),
                  _SpecItemRow(
                    label: 'SKU',
                    valueWidget: Text(
                      widget.sku,
                      style: TextStyle(
                        color: context.mutedForeground,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Divider(
                    height: 1,
                    thickness: 0.7,
                    color: context.border.withValues(alpha: 0.30),
                  ),
                  const SizedBox(height: 14),

                  // Care instructions row
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.dry_cleaning_outlined,
                            size: 16,
                            color: context.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            Tk.productDetailsCareInstructions.tr,
                            style: TextStyle(
                              color: context.foreground,
                              fontWeight: FontWeight.w800,
                              fontSize: 12.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _CareChip(
                            icon: Icons.water_drop_outlined,
                            text: Tk.productDetailsCareDryClean.tr,
                          ),
                          _CareChip(
                            icon: Icons.iron_outlined,
                            text: Tk.productDetailsCareIron.tr,
                          ),
                          _CareChip(
                            icon: Icons.do_not_disturb_on_outlined,
                            text: Tk.productDetailsCareNoBleach.tr,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Size Guide quick access banner
                  InkWell(
                    onTap: () => ProductSizeGuideSheet.show(
                      context,
                      currentSelectedSize: widget.selectedSize,
                      onSizeSelected: widget.onSelectSize,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: context.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.primary.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.straighten_rounded,
                            color: context.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              Tk.productDetailsSizeGuide.tr,
                              style: TextStyle(
                                color: context.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: context.primary,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SpecItemRow extends StatelessWidget {
  final String label;
  final Widget valueWidget;

  const _SpecItemRow({
    required this.label,
    required this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              color: context.mutedForeground,
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: valueWidget),
      ],
    );
  }
}

class _BadgeTag extends StatelessWidget {
  final String text;

  const _BadgeTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.border.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: context.foreground,
          fontWeight: FontWeight.w700,
          fontSize: 11.5,
        ),
      ),
    );
  }
}

class _CareChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _CareChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.border.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: context.mutedForeground,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

