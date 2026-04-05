import 'package:flutter/material.dart';
import 'package:rwnaqk/models/home_product_item.dart';
import 'package:rwnaqk/widgets/card/product_card.dart';

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
    this.height = 245,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => SizedBox(
          width: itemWidth,
          child: ProductCard(
            item: items[i],
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}