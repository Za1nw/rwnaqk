import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/controllers/wishlist/wishlist_controller.dart';
import 'package:rwnaqk/widgets/wishlist/wishlist_top_bar.dart';
import 'package:rwnaqk/widgets/wishlist/wishlist_tab_animated_body.dart';

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