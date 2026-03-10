import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/utils/app_breakpoints.dart';

import '../controllers/app_search_controller.dart';
import '../widgets/home/product_horizontal_list.dart';
import '../widgets/home/shop_top_bar.dart';
import '../widgets/common/app_section_header.dart';

class SearchScreen extends GetView<AppSearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShopTopBar(
                title: 'Search',
                searchHint: 'Search',
                controller: controller.searchC,
                onChanged: controller.onChanged,
                onSubmitted: controller.onSubmitted,
                onCamera: controller.openCamera,
              ),
              const SizedBox(height: 16),
              AppSectionHeader(
                title: 'Search history',
                actionIcon: Icons.delete_outline_rounded,
                onActionTap: controller.clearHistory,
                titleFontSize: 15,
                titleFontWeight: FontWeight.w800,
                titleColor: context.mutedForeground,
              ),
              const SizedBox(height: 10),
              Obx(() {
                final items = controller.history.toList();
                if (items.isEmpty) {
                  return Text(
                    'No recent searches',
                    style: TextStyle(
                      color: context.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }
                return _ChipsWrap(items: items, onTap: controller.onTapChip);
              }),
              const SizedBox(height: 18),
              AppSectionHeader(
                title: 'Recommendations',
                titleFontSize: 14,
                titleFontWeight: FontWeight.w800,
                titleColor: context.mutedForeground,
              ),
              const SizedBox(height: 10),
              Obx(() {
                final items = controller.recommendations.toList();
                if (items.isEmpty) return const SizedBox.shrink();
                return _ChipsWrap(items: items, onTap: controller.onTapChip);
              }),
              const SizedBox(height: 22),
              const AppSectionHeader(title: 'Discover'),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (_, c) {
                  final w = c.maxWidth;
                  final cardW = AppBreakpoints.isCompact(w) ? 155.0 : 170.0;
                  final listH = AppBreakpoints.isCompact(w) ? 225.0 : 240.0;
                  return Obx(() {
                    final items = controller.discover.toList();
                    if (items.isEmpty) return const SizedBox.shrink();
                    return ProductHorizontalList(
                      items: items,
                      itemWidth: cardW,
                      height: listH,
                      onTap: (_) {},
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipsWrap extends StatelessWidget {
  final List<String> items;
  final ValueChanged<String> onTap;

  const _ChipsWrap({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((t) {
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onTap(t),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: context.input.withOpacity(context.isDark ? 0.65 : 1.0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.border.withOpacity(0.35)),
            ),
            child: Text(
              t,
              style: TextStyle(
                color: context.foreground,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
