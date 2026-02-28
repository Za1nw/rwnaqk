import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/utils/app_breakpoints.dart';

import '../controllers/search_results_controller.dart';
import '../widgets/app_filter_button.dart';
import '../widgets/common/app_empty_state.dart';
import '../widgets/common/app_query_chip.dart';
import '../widgets/home/product_grid_section.dart';
import '../widgets/home/shop_top_bar.dart';

class SearchResultsScreen extends GetView<SearchResultsController> {
  const SearchResultsScreen({super.key});

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
                  Row(
                    children: [
                      Expanded(
                        child: ShopTopBar(
                          title: 'Shop',
                          searchHint: 'Search',
                          controller: controller.searchC,
                          onChanged: controller.onChanged,
                          onSubmitted: controller.onSubmitted,
                          onCamera: controller.openCamera,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 10),
                      AppFilterButton(onTap: controller.openFilters),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Obx(() {
                    final q = controller.query.value.trim();
                    if (q.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppQueryChip(
                        text: q,
                        onRemove: controller.clearQuery,
                      ),
                    );
                  }),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Center(
                          child:
                              CircularProgressIndicator(color: context.primary),
                        ),
                      );
                    }

                    final items = controller.results.toList();
                    if (items.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: AppEmptyState(
                          title: 'No results',
                          subtitle: 'Try another keyword or adjust filters.',
                        ),
                      );
                    }

                    return ProductGridSection(
                      items: items,
                      crossAxisCount: cols,
                      childAspectRatio:
                          w >= AppBreakpoints.compact ? 0.74 : 0.72,
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
