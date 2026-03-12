import 'package:flutter/material.dart';
import 'package:rwnaqk/controllers/wishlist/wishlist_controller.dart';
import 'package:rwnaqk/core/utils/app_breakpoints.dart';
import 'package:rwnaqk/widgets/common/app_empty_state.dart';
import 'package:rwnaqk/widgets/card/product_grid_section.dart';
import 'package:rwnaqk/widgets/wishlist/recent_filter_row.dart';
import 'package:rwnaqk/widgets/wishlist/wishlist_item_tile.dart';

class WishlistTabAnimatedBody extends StatelessWidget {
  final WishlistController controller;
  final bool isWishlist;

  const WishlistTabAnimatedBody({
    super.key,
    required this.controller,
    required this.isWishlist,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );

        final slide = Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        );

        final scale = Tween<double>(
          begin: 0.985,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
        );

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: ScaleTransition(
              scale: scale,
              child: child,
            ),
          ),
        );
      },
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: isWishlist
          ? _WishlistTabContent(
              key: const ValueKey('wishlist_tab_content'),
              controller: controller,
            )
          : _RecentTabContent(
              key: const ValueKey('recent_tab_content'),
              controller: controller,
            ),
    );
  }
}

class _WishlistTabContent extends StatelessWidget {
  final WishlistController controller;

  const _WishlistTabContent({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.wishlist.isEmpty) {
      return const AppEmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'No wishlist items',
        subtitle: 'Items you save will appear here.',
      );
    }

    return ListView.separated(
      key: const ValueKey('wishlist_list'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 18),
      itemCount: controller.wishlist.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) {
        final item = controller.wishlist[i];

        return WishlistItemTile(
          item: item,
          onTap: () => controller.openProduct(item),
          onRemove: () => controller.removeFromWishlist(item.id),
          onAddToCart: () => controller.addToCart(item),
        );
      },
    );
  }
}

class _RecentTabContent extends StatelessWidget {
  final WishlistController controller;

  const _RecentTabContent({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.recentlyViewed.isEmpty) {
      return Column(
        key: const ValueKey('recent_empty_column'),
        children: const [
          RecentFilterRow(),
          SizedBox(height: 14),
          Expanded(
            child: AppEmptyState(
              icon: Icons.history_rounded,
              title: 'No recently viewed items',
              subtitle: 'Products you open will appear here.',
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      key: const ValueKey('recent_scroll'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RecentFilterRow(),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (_, c) {
              final w = c.maxWidth;
              final cols = AppBreakpoints.productGridColumns(w);
              final ratio = w >= AppBreakpoints.compact ? 0.78 : 0.72;

              return ProductGridSection(
                items: controller.recentlyViewed,
                crossAxisCount: cols,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: ratio,
                onTap: controller.openProduct,
              );
            },
          ),
        ],
      ),
    );
  }
}