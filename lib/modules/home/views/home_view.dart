import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';
import 'package:rwnaqk_frontend/core/utils/app_breakpoints.dart';
import 'package:rwnaqk_frontend/modules/home/controllers/home_controller.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_banner_section.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_categories_section.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_flash_sale_section.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_just_for_you_section.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_layout.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_most_popular_section.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_new_items_section.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_top_products_section.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/shop_top_bar.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;

            final productW = AppBreakpoints.isCompact(w) ? 150.0 : 170.0;
            final horizontalListH = AppBreakpoints.isCompact(w) ? 240.0 : 250.0;

            final flashCols = AppBreakpoints.productGridColumns(w);
            final justCols = AppBreakpoints.productGridColumns(w);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: HomeLayout.pageHPadding,
                vertical: HomeLayout.pageVPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShopTopBar(
                    title: Tk.homeTitle.tr,
                    searchHint: Tk.homeSearchHint.tr,
                    controller: controller.searchC,
                    onTapField: () => Get.toNamed(AppRoutes.search),
                    onCamera: controller.openCamera,
                  ),

                  const SizedBox(height: HomeLayout.innerGap),

                  const HomeBannerSection(),

                  const SizedBox(height: HomeLayout.sectionGap),

                  const HomeCategoriesSection(),

                  const SizedBox(height: HomeLayout.sectionGap),

                  const HomeTopProductsSection(),

                  const SizedBox(height: HomeLayout.sectionGap),

                  HomeNewItemsSection(
                    itemWidth: productW,
                    height: horizontalListH,
                  ),

                  const SizedBox(height: HomeLayout.sectionGap),

                  HomeFlashSaleSection(
                    crossAxisCount: flashCols,
                  ),

                  const SizedBox(height: HomeLayout.sectionGap),

                  HomeMostPopularSection(
                    itemWidth: productW,
                    height: horizontalListH,
                  ),

                  const SizedBox(height: HomeLayout.sectionGap),

                  HomeJustForYouSection(
                    crossAxisCount: justCols,
                  ),

                  const SizedBox(height: HomeLayout.sectionGap),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}