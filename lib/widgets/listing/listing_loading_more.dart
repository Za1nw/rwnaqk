import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/products_listing/products_listing_controller.dart';
import 'package:rwnaqk/widgets/common/app_page_loading.dart';

class ListingLoadingMoreSliver extends StatelessWidget {
  final ProductsListingController controller;

  const ListingLoadingMoreSliver({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (!controller.hasMore.value || !controller.isLoadingMore.value) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: AppPageLoading(
              expanded: false,
              customIndicator: AppPageLoading.productCardIndicator,
            ),
          ),
        );
      }),
    );
  }
}