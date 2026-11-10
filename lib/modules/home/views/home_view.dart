import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_breakpoints.dart';
import 'package:rwnaqk_frontend/modules/cart/providers/cart_providers.dart';
import 'package:rwnaqk_frontend/modules/home/providers/home_providers.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/curated_collections_grid.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_banner_section.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_categories_section.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_flash_sale_section.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_just_for_you_section.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_layout.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_most_popular_section.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_new_items_section.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_top_products_section.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/shop_top_bar.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/store_perks_strip.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/vip_club_banner.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(homeContentProvider.notifier);
    final cartCount = ref.watch(cartProvider).itemCount;

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;

            final productW = AppBreakpoints.isCompact(w) ? 156.0 : 172.0;
            final horizontalListH = AppBreakpoints.isCompact(w) ? 282.0 : 295.0;

            final justCols = AppBreakpoints.productGridColumns(w);

            return RefreshIndicator(
              color: context.primary,
              backgroundColor: context.card,
              onRefresh: () async {
                notifier.refreshHome();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                // 110 bottom padding ensures floating bottom nav bar never obscures content
                padding: const EdgeInsets.fromLTRB(
                  HomeLayout.pageHPadding,
                  10,
                  HomeLayout.pageHPadding,
                  110,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Prestigious Top Header (Brand, Location, Search, Actions)
                    ShopTopBar(
                      title: Tk.homeTitle.tr,
                      searchHint: 'ابحث عن منتجات، ماركات، عطور...',
                      controller: notifier.searchController,
                      onTapField: () => AppNav.toNamed(AppRoutes.search),
                      onCamera: notifier.openCamera,
                      showBrandHeader: true,
                      locationText: 'التوصيل إلى: صنعاء / عدن',
                      onLocationTap: () => AppNav.toNamed(AppRoutes.addresses),
                      onNotifications: () => AppNav.toNamed(AppRoutes.settings),
                      onCart: () => AppNav.toNamed(AppRoutes.cart),
                      cartCount: cartCount,
                    ),

                    const SizedBox(height: 14),

                    // 2. Promotional Banners Carousel (Hero Stage)
                    const HomeBannerSection(),

                    const SizedBox(height: 14),

                    // 3. Store Trust & Perks Strip (Fast delivery, Genuine, Easy returns, COD)
                    const StorePerksStrip(),

                    const SizedBox(height: 18),

                    // 4. Quick Category Story Pills
                    const HomeCategoriesSection(),

                    const SizedBox(height: 18),

                    // 5. Flash Sale (Placed prominently near top for immediate impulse/urgency deals)
                    HomeFlashSaleSection(
                      itemWidth: productW,
                      height: horizontalListH,
                    ),

                    const SizedBox(height: 22),

                    // 6. Curated Collections Showcase (Replaces clunky 2x2 grid with luxury department cards)
                    const CuratedCollectionsGrid(),

                    const SizedBox(height: 22),

                    // 7. Top Ranked Products Showcase (Ranked #1, #2, #3 Best Sellers)
                    HomeTopProductsSection(
                      itemWidth: productW,
                      height: horizontalListH,
                    ),

                    const SizedBox(height: 20),

                    // 8. Mid-Page VIP Club Privilege Promotion (RAWNAQ 15% discount)
                    const VipClubBanner(),

                    const SizedBox(height: 22),

                    // 9. New Arrivals
                    HomeNewItemsSection(
                      itemWidth: productW,
                      height: horizontalListH,
                    ),

                    const SizedBox(height: 22),

                    // 10. Most Popular Items
                    HomeMostPopularSection(
                      itemWidth: productW,
                      height: horizontalListH,
                    ),

                    const SizedBox(height: 22),

                    // 11. Personalized Recommendations Grid (2 Columns)
                    HomeJustForYouSection(crossAxisCount: justCols),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
