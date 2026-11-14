import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_page_loading.dart';

class ListingLoadingMoreSliver extends StatelessWidget {
  final bool isLoadingMore;

  const ListingLoadingMoreSliver({
    super.key,
    this.isLoadingMore = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoadingMore) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: AppPageLoading(
            expanded: false,
            customIndicator: AppPageLoading.productCardIndicator,
          ),
        ),
      ),
    );
  }
}
