import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/home/home_controller.dart';
import 'package:rwnaqk/widgets/home/banner_carousel.dart';

class HomeBannerSection extends GetView<HomeController> {
  const HomeBannerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.banners.toList();
      if (items.isEmpty) return const SizedBox.shrink();

      return BannerCarousel(
        items: items,
        index: controller.bannerIndex.value,
        onChanged: controller.onBannerChanged,
      );
    });
  }
}