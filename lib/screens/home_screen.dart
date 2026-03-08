import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/utils/app_breakpoints.dart';

import '../controllers/home_controller.dart';
import '../widgets/home/banner_carousel.dart';
import '../widgets/home/category_grid.dart';
import '../widgets/home/flash_sale_header.dart';
import '../widgets/home/product_avatar_row.dart';
import '../widgets/home/product_grid_section.dart';
import '../widgets/home/product_horizontal_list.dart';
import '../widgets/home/section_header.dart';
import '../widgets/home/shop_top_bar.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  static const double _pageHPadding = 18;
  static const double _pageVPadding = 14;
  static const double _sectionGap = 18;
  static const double _innerGap = 10;
  static const double _gridSpacing = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;

            final productW = AppBreakpoints.isCompact(w) ? 150.0 : 170.0;
            final horizontalListH = AppBreakpoints.isCompact(w) ? 220.0 : 230.0;

            final flashCols = AppBreakpoints.productGridColumns(w);
            final justCols = AppBreakpoints.productGridColumns(w);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: _pageHPadding,
                vertical: _pageVPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShopTopBar(
                    title: 'home.title'.tr,
                    searchHint: 'home.search_hint'.tr,
                    controller: controller.searchC,
                    onTapField: () => Get.toNamed(AppRoutes.search),
                    onCamera: controller.openCamera,
                  ),

                  const SizedBox(height: _innerGap),

                  Obx(() {
                    final items = controller.banners.toList();
                    if (items.isEmpty) return const SizedBox.shrink();

                    return BannerCarousel(
                      items: items,
                      index: controller.bannerIndex.value,
                      onChanged: controller.onBannerChanged,
                      
                    );
                  }),

                  const SizedBox(height: _sectionGap),

                  SectionHeader(
                    title: 'home.categories'.tr,
                    actionText: 'home.see_all'.tr,
                    onAction: controller.onSeeAllCategories,
                  ),

                  const SizedBox(height: _innerGap),

                  Obx(() {
                    final items = controller.categories.toList();
                    if (items.isEmpty) return const SizedBox.shrink();

                    return CategoryGrid(
                      items: items,
                      onTap: controller.openCategory,
                    );
                  }),

                  const SizedBox(height: _sectionGap),

                  SectionHeader(
                    title: 'home.top_products'.tr,
                  ),

                  const SizedBox(height: _innerGap),

                  Obx(() {
                    final items = controller.topProducts.toList();
                    if (items.isEmpty) return const SizedBox.shrink();

                    return ProductAvatarRow(
                      items: items,
                      onTap: controller.openProduct,
                    );
                  }),

                  const SizedBox(height: _sectionGap),

                  SectionHeader(
                    title: 'home.new_items'.tr,
                    actionText: 'home.see_all'.tr,
                    onAction: controller.onSeeAllNewItems,
                  ),

                  const SizedBox(height: _innerGap),

                  Obx(() {
                    final items = controller.newItems.toList();
                    if (items.isEmpty) return const SizedBox.shrink();

                    return ProductHorizontalList(
                      items: items,
                      itemWidth: productW,
                      height: horizontalListH,
                      onTap: controller.openProduct,
                    );
                  }),

                  const SizedBox(height: _sectionGap),

                  Obx(
                     () => FlashSaleHeader(
                      hh: controller.hh.value,
                      mm: controller.mm.value,
                      ss: controller.ss.value,
                      onSeeAll: controller.openFlashSaleScreen,
                    ),
                  ),

                  const SizedBox(height: _innerGap),

                  Obx(() {
                    final items = controller.flashSale.toList();
                    if (items.isEmpty) return const SizedBox.shrink();

                    return ProductGridSection(
                      items: items,
                      crossAxisCount: flashCols,
                      crossAxisSpacing: _gridSpacing,
                      mainAxisSpacing: _gridSpacing,
                      onTap: controller.openProduct,
                      childAspectRatio: 1.0,
                    );
                  }),

                  const SizedBox(height: _sectionGap),

                  SectionHeader(
                    title: 'home.most_popular'.tr,
                    actionText: 'home.see_all'.tr,
                    onAction: controller.onSeeAllMostPopular,
                  ),

                  const SizedBox(height: _innerGap),

                  Obx(() {
                    final items = controller.mostPopular.toList();
                    if (items.isEmpty) return const SizedBox.shrink();

                    return ProductHorizontalList(
                      items: items,
                      itemWidth: productW,
                      height: horizontalListH,
                      onTap: controller.openProduct,
                    );
                  }),

                  const SizedBox(height: _sectionGap),

                  Text(
                    'home.just_for_you'.tr,
                    style: TextStyle(
                      color: context.foreground,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: _innerGap),

                  Obx(() {
                    final items = controller.justForYou.toList();
                    if (items.isEmpty) return const SizedBox.shrink();

                    return ProductGridSection(
                      items: items,
                      crossAxisCount: justCols,
                      crossAxisSpacing: _gridSpacing,
                      mainAxisSpacing: _gridSpacing,
                      onTap: controller.openProduct,
                      childAspectRatio: 1.0,
                    );
                  }),

                  const SizedBox(height: _sectionGap),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}