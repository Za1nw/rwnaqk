import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/products_listing_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

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
        if (!controller.hasMore.value) {
          return const SizedBox(height: 20);
        }

        if (!controller.isLoadingMore.value) {
          return const SizedBox(height: 20);
        }

        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation<Color>(context.primary),
              ),
            ),
          ),
        );
      }),
    );
  }
}