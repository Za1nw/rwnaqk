import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/home/home_controller.dart';
import 'package:rwnaqk/widgets/common/app_section_header.dart';
import 'package:rwnaqk/widgets/home/home_layout.dart';
import 'package:rwnaqk/widgets/card/product_horizontal_list.dart';

class HomeNewItemsSection extends GetView<HomeController> {
  final double itemWidth;
  final double height;

  const HomeNewItemsSection({
    super.key,
    required this.itemWidth,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'home.new_items'.tr,
          actionText: 'home.see_all'.tr,
          onActionTap: controller.onSeeAllNewItems,
        ),
        const SizedBox(height: HomeLayout.innerGap),
        Obx(_buildContent),
      ],
    );
  }

  Widget _buildContent() {
    final items = controller.newItems;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return ProductHorizontalList(
      items: items.toList(growable: false),
      itemWidth: itemWidth,
      height: height,
      onTap: controller.openProduct,
    );
  }
}