import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';
import 'package:rwnaqk_frontend/core/utils/app_breakpoints.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/checkout/widgets/product_card.dart';

class ListingGridSliver extends StatelessWidget {
  final List<HomeProductItem> items;
  final ValueChanged<HomeProductItem>? onAddToCart;

const ListingGridSliver({
  super.key,
  required this.items,
  this.onAddToCart,
});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = AppBreakpoints.productGridColumns(
            constraints.crossAxisExtent,
          );

          const crossAxisSpacing = 12.0;
          const mainAxisSpacing = 12.0;

          final totalSpacing = crossAxisSpacing * (crossAxisCount - 1);
          final tileWidth =
              (constraints.crossAxisExtent - totalSpacing) / crossAxisCount;

          double tileHeight;
          if (tileWidth <= 150) {
            tileHeight = tileWidth * 1.90;
          } else if (tileWidth <= 180) {
            tileHeight = tileWidth * 1.70;
          } else {
            tileHeight = tileWidth * 1.60;
          }

          return SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = items[index];

                return ProductCard(
                  item: item,
                  onTap: (_) => AppNav.toNamed(
                    AppRoutes.product,
                    arguments: {'item': item},
                  ),
                );
              },
              childCount: items.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
              mainAxisExtent: tileHeight,
            ),
          );
        },
      ),
    );
  }
}