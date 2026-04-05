import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/products_listing/products_listing_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

import 'package:rwnaqk/widgets/listing/listing_top_bar.dart';
import 'package:rwnaqk/widgets/listing/listing_sort_sheet.dart';
import 'package:rwnaqk/widgets/listing/listing_states.dart';
import 'package:rwnaqk/widgets/listing/listing_grid.dart';
import 'package:rwnaqk/widgets/listing/listing_loading_more.dart';

class ProductsListingScreen extends GetView<ProductsListingController> {
  const ProductsListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final isLoading = controller.isLoading.value;
          final error = controller.errorMessage.value;
          final items = controller.items.toList(growable: false);

          final showGrid = !isLoading && error == null && items.isNotEmpty;

          return CustomScrollView(
            controller: controller.scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              ListingTopBar(
                title: controller.title.value,
                filterCount: controller.activeFilterCount.value,
                onBack: () => Get.back(),
                onSort: () => openListingSortSheet(context, controller),
                onFilter: () => controller.openFilters(),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 8),
              ),
              if (isLoading)
                const ListingSkeletonSliver()
              else if (error != null)
                ListingErrorSliver(
                  message: error,
                  onRetry: controller.refreshList,
                )
              else if (items.isEmpty)
                ListingEmptySliver(
                  onRefresh: controller.refreshList,
                )
              else
                ListingGridSliver(items: items),
              if (showGrid) ListingLoadingMoreSliver(controller: controller),
              if (showGrid)
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
            ],
          );
        }),
      ),
    );
  }
}