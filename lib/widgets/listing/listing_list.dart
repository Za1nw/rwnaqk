import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/models/home_product_item.dart';
import 'package:rwnaqk/widgets/home/product_card.dart';

class ListingListSliver extends StatelessWidget {
  final List<HomeProductItem> items;

  const ListingListSliver({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];

          return SizedBox(
            height: 150,
            child: ProductCard(
              item: item,
              showAddToCart: true,
              onTap: (_) => Get.toNamed(
                AppRoutes.product,
                arguments: {'item': item},
              ),
            ),
          );
        },
      ),
    );
  }
}