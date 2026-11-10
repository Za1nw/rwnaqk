import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/wishlist/providers/wishlist_providers.dart';
import 'package:rwnaqk_frontend/modules/wishlist/widgets/wishlist_tab_animated_body.dart';
import 'package:rwnaqk_frontend/modules/wishlist/widgets/wishlist_top_bar.dart';

/// شاشة المفضلة [WishlistScreen].
///
/// تمت هجرتها بنجاح إلى Riverpod 3 كـ ConsumerWidget مع إزالة أي Obx أو GetView.
class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wishlistProvider);
    final isWishlist = state.tabIndex == 0;

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 10, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WishlistTopBar(title: Tk.wishlistTitle.tr),
              const SizedBox(height: 14),
              Expanded(
                child: WishlistTabAnimatedBody(
                  isWishlist: isWishlist,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
