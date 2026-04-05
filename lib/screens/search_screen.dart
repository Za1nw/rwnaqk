import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/core/utils/app_breakpoints.dart';

import 'package:rwnaqk/controllers/search/app_search_controller.dart';
import '../widgets/common/app_section_header.dart';
import '../widgets/card/product_horizontal_list.dart';
import '../widgets/home/shop_top_bar.dart';
import '../widgets/search/search_chip_group.dart';

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
                title: Tk.searchTitle.tr,
                searchHint: Tk.searchTitle.tr,
                controller: controller.searchC,
                onChanged: controller.onChanged,
                onSubmitted: controller.onSubmitted,
                onCamera: controller.openCamera,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              AppSectionHeader(
                title: Tk.searchHistory.tr,
                actionIcon: Icons.delete_outline_rounded,
                onActionTap: controller.clearHistory,
                titleFontSize: 15,
                titleFontWeight: FontWeight.w800,
                titleColor: context.mutedForeground,
              ),
              const SizedBox(height: 10),
              Obx(() {
                final items = controller.history.toList(growable: false);

                if (items.isEmpty) {
                  return Text(
                    Tk.searchNoRecent.tr,
                    style: TextStyle(
                      color: context.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }

                return SearchChipGroup(
                  items: items,
                  onTap: controller.onTapChip,
                );
              }),
              const SizedBox(height: 18),
              AppSectionHeader(
                title: Tk.searchRecommendations.tr,
                titleFontSize: 14,
                titleFontWeight: FontWeight.w800,
                titleColor: context.mutedForeground,
              ),
              const SizedBox(height: 10),
              Obx(() {
                final items =
                    controller.recommendations.toList(growable: false);

                if (items.isEmpty) return const SizedBox.shrink();

                return SearchChipGroup(
                  items: items,
                  onTap: controller.onTapChip,
                );
              }),
              const SizedBox(height: 22),
              AppSectionHeader(title: Tk.searchDiscover.tr),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (_, c) {
                  final w = c.maxWidth;
                  final cardW = AppBreakpoints.isCompact(w) ? 155.0 : 170.0;
                  final listH = AppBreakpoints.isCompact(w) ? 240.0 : 245.0;

                  return Obx(() {
                    final items = controller.discover.toList(growable: false);

                    if (items.isEmpty) return const SizedBox.shrink();

                    return ProductHorizontalList(
                      items: items,
                      itemWidth: cardW,
                      height: listH,
                      onTap: controller.openProduct,
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
