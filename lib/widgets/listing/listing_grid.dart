import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/models/home_product_item.dart';
import 'package:rwnaqk/widgets/home/product_card.dart';

class ListingGridSliver extends StatelessWidget {
  final List<HomeProductItem> items;

  const ListingGridSliver({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = items[index];
          return ProductCard(
            item: item,
            showAddToCart: true,
            onTap: (_) =>
                Get.toNamed(AppRoutes.product, arguments: {'item': item}),
          );
        }, childCount: items.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 230,
        ),
      ),
    );
  }
}
