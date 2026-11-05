import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/modules/home/controllers/home_controller.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_section_header.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_layout.dart';
import 'package:rwnaqk_frontend/modules/checkout/widgets/product_horizontal_list.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';

class HomeMostPopularSection extends GetView<HomeController> {
  final double itemWidth;
  final double height;

  const HomeMostPopularSection({
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
          title: Tk.homeMostPopular.tr,
          actionText: Tk.homeSeeAll.tr,
          onActionTap: controller.onSeeAllMostPopular,
        ),
        const SizedBox(height: HomeLayout.innerGap),
        Obx(() {
          final items = controller.mostPopular.toList();
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
