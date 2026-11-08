import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/widgets/feedback/app_toast.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/product_details_controller.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_size_guide.dart';

enum _GuideViewMode { table, card }

class ProductSizeGuideSheet extends StatefulWidget {
  final ProductSizeGuide? sizeGuide;
  final String currentSelectedSize;
  final ValueChanged<String>? onSizeSelected;

  const ProductSizeGuideSheet({
    super.key,
    this.sizeGuide,
    required this.currentSelectedSize,
    this.onSizeSelected,
  });

  static Future<void> show(
    BuildContext context, {
    ProductSizeGuide? sizeGuide,
    required String currentSelectedSize,
    ValueChanged<String>? onSizeSelected,
  }) {
    HapticFeedback.lightImpact();

    ProductSizeGuide? resolvedGuide = sizeGuide;
    if (resolvedGuide == null && Get.isRegistered<ProductDetailsController>()) {
      resolvedGuide = Get.find<ProductDetailsController>().sizeGuide;
    }
    resolvedGuide ??= ProductSizeGuide.defaultClothingGuide();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductSizeGuideSheet(
        sizeGuide: resolvedGuide,
        currentSelectedSize: currentSelectedSize,
        onSizeSelected: onSizeSelected,
      ),
    );
  }

  @override
  State<ProductSizeGuideSheet> createState() => _ProductSizeGuideSheetState();
}

class _ProductSizeGuideSheetState extends State<ProductSizeGuideSheet> {
  late ProductSizeGuide _guide;
  late String _activeSize;
  _GuideViewMode _viewMode = _GuideViewMode.table;

  final ScrollController _horizontalScrollController = ScrollController();

  static const double _headerHeight = 48.0;
  static const double _rowHeight = 48.0;
  static const double _stickySizeColWidth = 78.0;

  @override
  void initState() {
    super.initState();
    _guide = widget.sizeGuide ?? ProductSizeGuide.defaultClothingGuide();

    _activeSize = widget.currentSelectedSize.trim().toUpperCase();
    if (_activeSize.isEmpty && _guide.rows.isNotEmpty) {
      _activeSize = _guide.rows.first.size.toUpperCase();
    } else if (_activeSize.isEmpty) {
      _activeSize = 'M';
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  ProductSizeGuideRow? get _activeRow {
    for (final r in _guide.rows) {
      if (r.size.toUpperCase() == _activeSize) return r;
    }
    return _guide.rows.isNotEmpty ? _guide.rows.first : null;
  }

  void _confirmSelection(String size) {
    HapticFeedback.mediumImpact();
    setState(() => _activeSize = size);
    widget.onSizeSelected?.call(size);
    if (Get.isRegistered<ProductDetailsController>()) {
      Get.find<ProductDetailsController>().setSelectedSize(size);
    }
    AppToast.success(
      Tk.productDetailsSizeSelected.trParams({'size': size}),
      title: Tk.productDetailsSizeGuideTitle.tr,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final maxH = height * 0.90;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: context.mutedForeground.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: context.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Icon(
                    Icons.straighten_rounded,
                    color: context.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _guide.title.isNotEmpty
                            ? _guide.title
                            : Tk.productDetailsSizeGuideTitle.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.foreground,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 13,
                            color: context.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'جميع القياسات بالسنتيمتر (سم) مأخوذة للمنتج',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.mutedForeground,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: context.card,
                    shape: const CircleBorder(),
                  ),
                  icon: Icon(
                    Icons.close_rounded,
                    color: context.foreground,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.8),

          // Scrollable Body
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              children: [
                // View Mode Segmented Controls (Table View vs My Size Card)
                Row(
                  children: [
                    Expanded(
                      child: _ModeSegmentButton(
                        icon: Icons.table_chart_rounded,
                        label: 'جدول المقاسات الكامل',
                        isSelected: _viewMode == _GuideViewMode.table,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _viewMode = _GuideViewMode.table);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ModeSegmentButton(
                        icon: Icons.badge_rounded,
                        label: 'تفاصيل مقاسي ($_activeSize)',
                        isSelected: _viewMode == _GuideViewMode.card,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _viewMode = _GuideViewMode.card);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Main View Container
                if (_viewMode == _GuideViewMode.table)
                  _buildWideTableWithStickyColumn(context)
                else
                  _buildMySizeCardView(context),

                const SizedBox(height: 16),

                // Luxury Tip Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.primary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: context.primary.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: context.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          Tk.productDetailsMeasureTip.tr,
                          style: TextStyle(
                            color: context.foreground,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),

          // Bottom Selection CTA
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: BoxDecoration(
                color: context.background,
                border: Border(
                  top: BorderSide(
                    color: context.border.withValues(alpha: 0.35),
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _confirmSelection(_activeSize),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primary,
                    foregroundColor: context.primaryForeground,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${Tk.productDetailsSelectSizeCta.tr} ($_activeSize)',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SOLUTION FOR WIDE TABLES:
  // Pinned/Frozen First Column ("المقاس") + Smooth Horizontal Scroll for all measurements
  // =========================================================================
  Widget _buildWideTableWithStickyColumn(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border.withValues(alpha: 0.50)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Scroll Indicator Affordance
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: context.primary.withValues(alpha: 0.05),
            child: Row(
              children: [
                Icon(
                  Icons.swipe_left_rounded,
                  size: 15,
                  color: context.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'اسحبي الجدول أفقياً لرؤية باقي القياسات (سم) ⟵',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.primary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_guide.columns.length + 1} أعمدة',
                  style: TextStyle(
                    color: context.mutedForeground,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 0.7,
            color: context.border.withValues(alpha: 0.35),
          ),

          // Table Structure: Frozen Sticky Column (Right) + Horizontal Scrollable Columns (Left)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. FROZEN STICKY COLUMN: "المقاس" (XS, S, M, L, XL, etc.)
              Container(
                width: _stickySizeColWidth,
                decoration: BoxDecoration(
                  color: context.card,
                  border: Border(
                    left: BorderSide(
                      color: context.border.withValues(alpha: 0.55),
                      width: 1.5,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(-2, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Sticky Header Cell
                    Container(
                      height: _headerHeight,
                      alignment: Alignment.center,
                      color: context.primary.withValues(alpha: 0.09),
                      child: Text(
                        Tk.productDetailsSizeLabel.tr,
                        style: TextStyle(
                          color: context.foreground,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 0.8,
                      color: context.border.withValues(alpha: 0.4),
                    ),

                    // Sticky Size Rows
                    ..._guide.rows.map((row) {
                      final isSelected = row.size.toUpperCase() == _activeSize;

                      return InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _activeSize = row.size.toUpperCase());
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          height: _rowHeight,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? context.primary.withValues(alpha: 0.15)
                                : Colors.transparent,
                            border: Border(
                              bottom: BorderSide(
                                color: context.border.withValues(alpha: 0.25),
                                width: 0.8,
                              ),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected)
                                Padding(
                                  padding:
                                      const EdgeInsetsDirectional.only(end: 4),
                                  child: Icon(
                                    Icons.check_circle_rounded,
                                    size: 14,
                                    color: context.primary,
                                  ),
                                ),
                              Text(
                                row.size,
                                style: TextStyle(
                                  color: isSelected
                                      ? context.primary
                                      : context.foreground,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // 2. HORIZONTALLY SCROLLABLE MEASUREMENT COLUMNS (Chest, Waist, Hips, Length, Shoulder...)
              Expanded(
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: IntrinsicWidth(
                    child: Column(
                      children: [
                        // Measurement Columns Header Row
                        Container(
                          height: _headerHeight,
                          color: context.primary.withValues(alpha: 0.09),
                          child: Row(
                            children: _guide.columns.map((col) {
                              return Container(
                                width: col.width,
                                alignment: Alignment.center,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  '${col.label}\n(سم)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: context.foreground,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11.5,
                                    height: 1.15,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 0.8,
                          color: context.border.withValues(alpha: 0.4),
                        ),

                        // Measurement Data Rows
                        ..._guide.rows.map((row) {
                          final isSelected =
                              row.size.toUpperCase() == _activeSize;

                          return InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(
                                () => _activeSize = row.size.toUpperCase(),
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              height: _rowHeight,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? context.primary.withValues(alpha: 0.15)
                                    : Colors.transparent,
                                border: Border(
                                  bottom: BorderSide(
                                    color:
                                        context.border.withValues(alpha: 0.25),
                                    width: 0.8,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: _guide.columns.map((col) {
                                  final val = row.getVal(col.id);

                                  return Container(
                                    width: col.width,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Text(
                                      val,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isSelected
                                            ? context.primary
                                            : context.foreground,
                                        fontWeight: isSelected
                                            ? FontWeight.w900
                                            : FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // CARD BREAKDOWN VIEW: Zero-scroll luxury specs for the currently chosen size
  // =========================================================================
  Widget _buildMySizeCardView(BuildContext context) {
    final activeRow = _activeRow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal Size Switcher Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _guide.rows.map((r) {
              final isSel = r.size.toUpperCase() == _activeSize;
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  label: Text(r.size),
                  selected: isSel,
                  onSelected: (val) {
                    if (val) {
                      HapticFeedback.selectionClick();
                      setState(() => _activeSize = r.size.toUpperCase());
                    }
                  },
                  selectedColor: context.primary,
                  backgroundColor: context.card,
                  labelStyle: TextStyle(
                    color: isSel
                        ? context.primaryForeground
                        : context.foreground,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSel
                          ? context.primary
                          : context.border.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 14),

        // Measurements Grid Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: context.primary.withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: context.primary.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: context.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.checkroom_rounded,
                          color: context.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'قياسات مقاس ($_activeSize)',
                        style: TextStyle(
                          color: context.foreground,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: context.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'محدد',
                      style: TextStyle(
                        color: context.primaryForeground,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(
                height: 1,
                thickness: 0.6,
                color: context.border.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 14),

              // Grid of Measurements
              if (activeRow != null)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardW = (constraints.maxWidth - 12) / 2;

                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _guide.columns.map((col) {
                        final val = activeRow.getVal(col.id);

                        return Container(
                          width: cardW > 120 ? cardW : 120,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: context.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: context.border.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                col.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.mutedForeground,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    val,
                                    style: TextStyle(
                                      color: context.foreground,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'سم',
                                    style: TextStyle(
                                      color: context.primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModeSegmentButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeSegmentButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? context.primary : context.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? context.primary
                : context.border.withValues(alpha: 0.45),
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.primary.withValues(alpha: 0.20),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? context.primaryForeground
                  : context.mutedForeground,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? context.primaryForeground
                      : context.foreground,
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
