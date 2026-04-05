import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/utils/app_breakpoints.dart';
import 'package:rwnaqk/models/home_product_item.dart';
import 'package:rwnaqk/widgets/card/product_card.dart';

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
            tileHeight = tileWidth * 1.82;
          } else if (tileWidth <= 180) {
            tileHeight = tileWidth * 1.58;
          } else {
            tileHeight = tileWidth * 1.52;
          }

          return SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = items[index];

                return ProductCard(
                  item: item,
                  onTap: (_) => Get.toNamed(
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