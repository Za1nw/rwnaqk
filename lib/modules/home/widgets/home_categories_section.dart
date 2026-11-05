import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/modules/home/controllers/home_controller.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_section_header.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/category_grid.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_layout.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';

class HomeCategoriesSection extends GetView<HomeController> {
  const HomeCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: Tk.homeCategories.tr,
          actionText: Tk.homeSeeAll.tr,
          onActionTap: controller.onSeeAllCategories,
        ),
        const SizedBox(height: HomeLayout.innerGap),
        Obx(() {
          final items = controller.categories.toList();
          if (items.isEmpty) return const SizedBox.shrink();

          return CategoryGrid(items: items, onTap: controller.openCategory);
        }),
      ],
    );
  }
}
