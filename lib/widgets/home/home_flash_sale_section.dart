import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/home_controller.dart';
import 'package:rwnaqk/widgets/home/flash_sale_header.dart';
import 'package:rwnaqk/widgets/home/home_layout.dart';
import 'package:rwnaqk/widgets/home/product_grid_section.dart';

class HomeFlashSaleSection extends GetView<HomeController> {
  final int crossAxisCount;

  const HomeFlashSaleSection({
    super.key,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => FlashSaleHeader(
            hh: controller.hh.value,
            mm: controller.mm.value,
            ss: controller.ss.value,
            onSeeAll: controller.openFlashSaleScreen,
          ),
        ),
        const SizedBox(height: HomeLayout.innerGap),
        Obx(() {
          final items = controller.flashSale.toList();
          if (items.isEmpty) return const SizedBox.shrink();

          return ProductGridSection(
            items: items,
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: HomeLayout.gridSpacing,
            mainAxisSpacing: HomeLayout.gridSpacing,
            onTap: controller.openProduct,
            childAspectRatio: 1.0,
          );
        }),
      ],
    );
  }
}