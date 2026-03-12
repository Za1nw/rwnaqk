import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/home/home_controller.dart';
import 'package:rwnaqk/widgets/common/app_section_header.dart';
import 'package:rwnaqk/widgets/home/category_grid.dart';
import 'package:rwnaqk/widgets/home/home_layout.dart';

class HomeCategoriesSection extends GetView<HomeController> {
  const HomeCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'home.categories'.tr,
          actionText: 'home.see_all'.tr,
          onActionTap: controller.onSeeAllCategories,
        ),
        const SizedBox(height: HomeLayout.innerGap),
        Obx(() {
          final items = controller.categories.toList();
          if (items.isEmpty) return const SizedBox.shrink();

          return CategoryGrid(
            items: items,
            onTap: controller.openCategory,
          );
        }),
      ],
    );
  }
}