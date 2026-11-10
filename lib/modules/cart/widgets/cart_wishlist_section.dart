import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_product_utils.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_section_header.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/wishlist/providers/wishlist_providers.dart';
import 'package:rwnaqk_frontend/modules/wishlist/widgets/wishlist_item_tile.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

class CartWishlistSection extends ConsumerWidget {
  final ValueChanged<HomeProductItem> onAdd;
  final ValueChanged<HomeProductItem>? onTap;

  const CartWishlistSection({super.key, required this.onAdd, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistState = ref.watch(wishlistProvider);
    final wishlistNotifier = ref.read(wishlistProvider.notifier);
    final items = wishlistState.items;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: Tk.cartFromWishlist.tr, titleFontSize: 16),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final item = items[i];

            return WishlistItemTile(
              item: item,
              variantText: AppProductUtils.variantText(item),
              onTap: () {
                if (onTap != null) {
                  onTap!(item);
                } else {
                  AppNav.toNamed(
                    AppRoutes.product,
                    arguments: {
                      'item': item,
                      'selectedColorId': item.availableColors.isNotEmpty
                          ? item.availableColors.first.id
                          : null,
                      'selectedSize': item.availableSizes.isNotEmpty
                          ? item.availableSizes.first
                          : null,
                    },
                  );
                }
              },
              onRemove: () => wishlistNotifier.removeFromWishlist(item.id),
              onAddToCart: () => onAdd(item),
            );
          },
        ),
      ],
    );
  }
}
