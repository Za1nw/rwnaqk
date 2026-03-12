import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/home/home_controller.dart';
import 'package:rwnaqk/widgets/common/app_section_header.dart';
import 'package:rwnaqk/widgets/card/product_avatar_row.dart';
import 'package:rwnaqk/widgets/home/home_layout.dart';

class HomeTopProductsSection extends GetView<HomeController> {
  const HomeTopProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'home.top_products'.tr,
        ),
        const SizedBox(height: HomeLayout.innerGap),
        Obx(() {
          final items = controller.topProducts.toList();
          if (items.isEmpty) return const SizedBox.shrink();

          return ProductAvatarRow(
            items: items,
            onTap: controller.openProduct,
          );
        }),
      ],
    );
  }
}