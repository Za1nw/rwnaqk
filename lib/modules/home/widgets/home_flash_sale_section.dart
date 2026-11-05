import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/modules/home/controllers/home_controller.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/flash_sale_header.dart';
import 'package:rwnaqk_frontend/modules/checkout/widgets/product_horizontal_list.dart';

class HomeFlashSaleSection extends GetView<HomeController> {
  final double itemWidth;
  final double height;

  const HomeFlashSaleSection({
    super.key,
    this.itemWidth = 165,
    this.height = 275,
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
        const SizedBox(height: 12),
        Obx(() {
          final items = controller.flashSale.toList();
          if (items.isEmpty) return const SizedBox.shrink();

          return ProductHorizontalList(
            items: items,
            itemWidth: itemWidth,
            height: height,
            onTap: controller.openProduct,
          );
        }),
      ],
    );
  }
}
