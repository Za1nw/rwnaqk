import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/home/home_controller.dart';
import 'package:rwnaqk/widgets/common/app_section_header.dart';
import 'package:rwnaqk/widgets/home/home_layout.dart';
import 'package:rwnaqk/widgets/card/product_grid_section.dart';

class HomeJustForYouSection extends GetView<HomeController> {
  final int crossAxisCount;

  const HomeJustForYouSection({
    super.key,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'home.just_for_you'.tr,
          actionText: 'home.see_all'.tr,
          onActionTap: controller.onSeeAllJustForYou,
        ),
        const SizedBox(height: HomeLayout.innerGap),
        Obx(() {
          final items = controller.justForYou.toList(growable: false);
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