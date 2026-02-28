import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/controllers/wishlist_controller.dart';
import 'package:rwnaqk/models/home_product_item.dart';
import 'package:rwnaqk/widgets/cart/cart_wishlist_section.dart';

import 'package:rwnaqk/widgets/wishlist/wishlist_top_bar.dart';
import 'package:rwnaqk/widgets/wishlist/recent_filter_row.dart';

import 'package:rwnaqk/widgets/home/product_grid_section.dart';
import 'package:rwnaqk/widgets/common/app_empty_state.dart';

import 'package:rwnaqk/core/utils/app_breakpoints.dart';

// ✅ استخدم مكوّن السلة
import 'package:rwnaqk/widgets/cart/cart_item_tile.dart';

class WishlistScreen extends GetView<WishlistController> {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 10, 18, 0),
          child: Obx(() {
            final isWishlist = controller.tabIndex.value == 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const WishlistTopBar(title: 'Wishlist'),
                const SizedBox(height: 14),

                /// =========================
                /// WISHLIST TAB
                /// =========================
                if (isWishlist) ...[
                  Expanded(
                    child: controller.wishlist.isEmpty
                        ? const AppEmptyState(
                            icon: Icons.favorite_border_rounded,
                            title: "No wishlist items",
                            subtitle: "Items you save will appear here.",
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: controller.wishlist.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 14),
                            itemBuilder: (_, i) {
                              final p = controller.wishlist[i];

                              return GestureDetector(
                                onTap: () => controller.openProduct(p),
                                child: CartWishlistSection(
                                  items: [
                                    HomeProductItem(
                                      id: "1",
                                      title: "Apple AirPods Pro",
                                      imageUrl: "https://picsum.photos/301",
                                      price: 49.99,
                                    ),
                                    HomeProductItem(
                                      id: "2",
                                      title: "Gaming Headset RGB",
                                      imageUrl: "https://picsum.photos/302",
                                      price: 39.99,
                                    ),
                                  ],

                                  onAdd: (item) {
                                    debugPrint("Add to cart: ${item.title}");
                                  },

                                  onRemove: (item) {
                                    debugPrint("Remove: ${item.title}");
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ]
                /// =========================
                /// RECENT TAB
                /// =========================
                else ...[
                  const RecentFilterRow(),
                  const SizedBox(height: 14),
                  Expanded(
                    child: controller.recentlyViewed.isEmpty
                        ? const AppEmptyState(
                            icon: Icons.history_rounded,
                            title: "No recently viewed items",
                            subtitle: "Products you open will appear here.",
                          )
                        : LayoutBuilder(
                            builder: (_, c) {
                              final w = c.maxWidth;
                              final cols = AppBreakpoints.productGridColumns(w);
                              final ratio = w >= AppBreakpoints.compact
                                  ? 0.78
                                  : 0.72;

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
                  ),
                ],
              ],
            );
          }),
        ),
      ),
    );
  }
}
