import 'package:flutter/material.dart';
import 'package:rwnaqk/models/home_product_item.dart';
import 'package:rwnaqk/widgets/card/product_card.dart';

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
          tileH = tileW * 1.82;
        } else if (tileW <= 180) {
          tileH = tileW * 1.58;
        } else {
          tileH = tileW * 1.52;
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
          itemBuilder: (_, i) => ProductCard(
            item: items[i],
            onTap: onTap,
          ),
        );
      },
    );
  }
}
