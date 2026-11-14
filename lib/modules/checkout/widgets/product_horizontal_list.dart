import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/checkout/widgets/product_card.dart';

class ProductHorizontalList extends StatelessWidget {
  final List<HomeProductItem> items;
  final double itemWidth;
  final double height;
  final ValueChanged<HomeProductItem> onTap;

  const ProductHorizontalList({
    super.key,
    required this.items,
    required this.onTap,
    this.itemWidth = 165,
    this.height = 285,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => SizedBox(
          width: itemWidth,
          child: ProductCard(item: items[i], onTap: onTap),
        ),
      ),
    );
  }
}
