import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/controllers/wishlist/wishlist_controller.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/widgets/common/app_page_header.dart';
import 'package:rwnaqk/widgets/wishlist/wishlist_tab_animated_body.dart';
import 'package:rwnaqk/widgets/wishlist/wishlist_tabs.dart';

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
            final count = isWishlist
                ? controller.wishlist.length
                : controller.recentlyViewed.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppPageHeader(
                  title: Tk.wishlistTitle.tr,
                  info: '$count',
                ),
                const SizedBox(height: 14),
                const WishlistTabs(),
                const SizedBox(height: 14),
                Expanded(
                  child: WishlistTabAnimatedBody(
                    controller: controller,
                    isWishlist: isWishlist,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
