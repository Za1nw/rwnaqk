import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

enum FilterSegment { clothes, shoes }

enum FilterSort {
  popular,
  newest,
  priceHighToLow,
  priceLowToHigh,
}

class AppFilterResult {
  final Set<int> selectedCategories;
  final int selectedSizeIndex;
  final FilterSegment segment;
  final int selectedColorIndex;
  final RangeValues priceRange;
  final FilterSort sort;

  const AppFilterResult({
    required this.selectedCategories,
    required this.selectedSizeIndex,
    required this.segment,
    required this.selectedColorIndex,
    required this.priceRange,
    required this.sort,
  });

  AppFilterResult copyWith({
    Set<int>? selectedCategories,
    int? selectedSizeIndex,
    FilterSegment? segment,
    int? selectedColorIndex,
    RangeValues? priceRange,
    FilterSort? sort,
  }) {
    return AppFilterResult(
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedSizeIndex: selectedSizeIndex ?? this.selectedSizeIndex,
      segment: segment ?? this.segment,
      selectedColorIndex: selectedColorIndex ?? this.selectedColorIndex,
      priceRange: priceRange ?? this.priceRange,
      sort: sort ?? this.sort,
    );
  }
}

class AppFilterSheet extends StatefulWidget {
  const AppFilterSheet({super.key, this.initial});

  final AppFilterResult? initial;

  @override
  State<AppFilterSheet> createState() => _AppFilterSheetState();
}

class _AppFilterSheetState extends State<AppFilterSheet> {
  // ===== Demo data (replace later) =====
  final categories = const [
    'Dresses','Pants','Skirts','Shorts','Jackets',
    'Hoodies','Shirts','Polo','T-shirts','Tunics',
  ];

  final sizes = const ['XS', 'S', 'M', 'L', 'XL', '2XL'];

  final colors = const [
    0xFF2563EB, // blue
    0xFF111827, // black
    0xFF6B7280, // gray
    0xFF0EA5E9, // sky
    0xFFDC2626, // red
    0xFF06B6D4, // cyan
    0xFFF59E0B, // orange
    0xFF8B5CF6, // purple
  ];

  // ===== State =====
  late AppFilterResult state;

  @override
  void initState() {
    super.initState();

    state = widget.initial ??
        AppFilterResult(
          selectedCategories: <int>{0, 1, 8},
          selectedSizeIndex: 2,
          segment: FilterSegment.clothes,
          selectedColorIndex: 0,
          priceRange: const RangeValues(10, 150),
          sort: FilterSort.popular,
        );
  }

  void _reset() {
    setState(() {
      state = AppFilterResult(
        selectedCategories: <int>{},
        selectedSizeIndex: 2,
        segment: FilterSegment.clothes,
        selectedColorIndex: 0,
        priceRange: const RangeValues(10, 150),
        sort: FilterSort.popular,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * 0.88;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: maxH,
        decoration: BoxDecoration(
          color: context.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 22,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          children: [
            // ===== Handle + Header =====
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: context.border.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 10, 10, 10),
              child: Row(
                children: [
                  Text(
                    'Filter',
                    style: TextStyle(
                      color: context.foreground,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Get.back(),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.close_rounded, color: context.foreground),
                    ),
                  ),
                ],
              ),
            ),

            // ===== Body =====
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== Categories =====
                    _CategoriesGridResponsive(
                      categories: categories,
                      selected: state.selectedCategories,
                      onToggle: (i) {
                        setState(() {
                          final s = {...state.selectedCategories};
                          s.contains(i) ? s.remove(i) : s.add(i);
                          state = state.copyWith(selectedCategories: s);
                        });
                      },
                    ),

                    const SizedBox(height: 18),

                    // ===== Size + Segment =====
                    Row(
                      children: [
                        const _SectionTitle('Size'),
                        const Spacer(),
                        _SegmentedControl(
                          left: 'Clothes',
                          right: 'Shoes',
                          index: state.segment == FilterSegment.clothes ? 0 : 1,
                          onChanged: (v) {
                            setState(() {
                              state = state.copyWith(
                                segment: v == 0 ? FilterSegment.clothes : FilterSegment.shoes,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    _ChoiceWrap(
                      items: sizes,
                      selectedIndex: state.selectedSizeIndex,
                      onTap: (i) => setState(() => state = state.copyWith(selectedSizeIndex: i)),
                      minItemWidth: 44,
                    ),

                    const SizedBox(height: 18),

                    // ===== Color =====
                    const _SectionTitle('Color'),
                    const SizedBox(height: 10),
                    _ColorWrap(
                      colors: colors.map((e) => Color(e)).toList(),
                      selectedIndex: state.selectedColorIndex,
                      onTap: (i) => setState(() => state = state.copyWith(selectedColorIndex: i)),
                    ),

                    const SizedBox(height: 18),

                    // ===== Price =====
                    Row(
                      children: [
                        const _SectionTitle('Price'),
                        const Spacer(),
                        Text(
                          '\$${state.priceRange.start.toInt()} — \$${state.priceRange.end.toInt()}',
                          style: TextStyle(
                            color: context.mutedForeground,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    RangeSlider(
                      values: state.priceRange,
                      min: 10,
                      max: 150,
                      divisions: 28,
                      activeColor: context.primary,
                      inactiveColor: context.border.withOpacity(0.35),
                      labels: RangeLabels(
                        '\$${state.priceRange.start.toInt()}',
                        '\$${state.priceRange.end.toInt()}',
                      ),
                      onChanged: (v) => setState(() => state = state.copyWith(priceRange: v)),
                    ),

                    const SizedBox(height: 10),

                    // ===== Sort =====
                    Row(
                      children: [
                        Expanded(
                          child: _SortPill(
                            text: 'Popular',
                            on: state.sort == FilterSort.popular,
                            onTap: () => setState(() => state = state.copyWith(sort: FilterSort.popular)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SortPill(
                            text: 'Newest',
                            on: state.sort == FilterSort.newest,
                            onTap: () => setState(() => state = state.copyWith(sort: FilterSort.newest)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _SortPill(
                            text: 'Price High to Low',
                            on: state.sort == FilterSort.priceHighToLow,
                            onTap: () => setState(() => state = state.copyWith(sort: FilterSort.priceHighToLow)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SortPill(
                            text: 'Price Low to High',
                            on: state.sort == FilterSort.priceLowToHigh,
                            onTap: () => setState(() => state = state.copyWith(sort: FilterSort.priceLowToHigh)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // ===== Bottom actions (fixed like the screenshot) =====
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 10, 18, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: context.primary, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: context.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: state),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primary,
                        foregroundColor: context.primaryForeground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
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

// ===================== UI Parts =====================

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: context.foreground,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

/// Responsive grid: adjusts column count based on available width.
class _CategoriesGridResponsive extends StatelessWidget {
  final List<String> categories;
  final Set<int> selected;
  final ValueChanged<int> onToggle;

  const _CategoriesGridResponsive({
    required this.categories,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final w = c.maxWidth;

        // Target item width ~ 68..78 for nice spacing like the screenshot.
        final crossAxisCount = math.max(3, math.min(5, (w / 72).floor()));
        final itemW = (w - (crossAxisCount - 1) * 10) / crossAxisCount;
        final avatar = math.min(56.0, itemW);

        return GridView.builder(
          itemCount: categories.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 10,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (_, i) {
            final on = selected.contains(i);
            return GestureDetector(
              onTap: () => onToggle(i),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: avatar,
                        height: avatar,
                        decoration: BoxDecoration(
                          color: context.input.withOpacity(context.isDark ? 0.6 : 1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: on ? context.primary : context.border.withOpacity(0.35),
                            width: on ? 2 : 1,
                          ),
                        ),
                        child: Icon(Icons.image_outlined, color: context.mutedForeground),
                      ),
                      if (on)
                        PositionedDirectional(
                          start: -2,
                          top: -2,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: context.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: context.background, width: 2),
                            ),
                            child: Icon(Icons.check, size: 12, color: context.primaryForeground),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    categories[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.mutedForeground,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SegmentedControl extends StatelessWidget {
  final String left;
  final String right;
  final int index; // 0 / 1
  final ValueChanged<int> onChanged;

  const _SegmentedControl({
    required this.left,
    required this.right,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget pill(String text, int i) {
      final on = index == i;
      return GestureDetector(
        onTap: () => onChanged(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: on ? context.primary.withOpacity(0.14) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: on ? context.primary : context.mutedForeground,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.input.withOpacity(context.isDark ? 0.6 : 1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          pill(left, 0),
          pill(right, 1),
        ],
      ),
    );
  }
}

class _ChoiceWrap extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final double minItemWidth;

  const _ChoiceWrap({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    required this.minItemWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final w = c.maxWidth;
        // Keep wrap tidy and responsive
        final maxPerRow = math.max(3, math.min(items.length, (w / (minItemWidth + 14)).floor()));
        final itemWidth = (w - (maxPerRow - 1) * 10) / maxPerRow;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(items.length, (i) {
            final on = i == selectedIndex;
            return GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                width: itemWidth,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: on
                      ? context.primary.withOpacity(0.14)
                      : context.input.withOpacity(context.isDark ? 0.6 : 1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: on ? context.primary : context.border.withOpacity(0.35),
                  ),
                ),
                child: Text(
                  items[i],
                  style: TextStyle(
                    color: on ? context.primary : context.mutedForeground,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ColorWrap extends StatelessWidget {
  final List<Color> colors;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _ColorWrap({
    required this.colors,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(colors.length, (i) {
        final on = i == selectedIndex;
        return GestureDetector(
          onTap: () => onTap(i),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colors[i],
              shape: BoxShape.circle,
              border: Border.all(
                color: on ? context.primary : context.border.withOpacity(0.35),
                width: on ? 2.2 : 1,
              ),
            ),
            child: on ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
          ),
        );
      }),
    );
  }
}

class _SortPill extends StatelessWidget {
  final String text;
  final bool on;
  final VoidCallback onTap; 

  const _SortPill({
    required this.text,
    required this.on,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: on
              ? context.primary.withOpacity(0.14)
              : context.input.withOpacity(context.isDark ? 0.6 : 1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: on ? context.primary : context.border.withOpacity(0.35),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: on ? context.primary : context.mutedForeground,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (on) Icon(Icons.check, size: 16, color: context.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}