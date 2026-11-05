import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/checkout/widgets/product_card.dart';

class ProductGridSection extends StatelessWidget {
  final List<HomeProductItem> items;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final ValueChanged<HomeProductItem> onTap;

  const ProductGridSection({
    super.key,
    required this.items,
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.onTap,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = crossAxisCount < 1 ? 1 : crossAxisCount;
        final totalSpacing = crossAxisSpacing * (cols - 1);
        final tileW = (c.maxWidth - totalSpacing) / cols;

        double tileH;

        if (tileW <= 150) {
          tileH = tileW * 1.88;
        } else if (tileW <= 180) {
          tileH = tileW * 1.64;
        } else {
          tileH = tileW * 1.56;
        }

        return GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            mainAxisExtent: tileH,
          ),
          itemBuilder: (_, i) => ProductCard(item: items[i], onTap: onTap),
        );
      },
    );
  }
}
