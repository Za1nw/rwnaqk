import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_details_skeleton.dart';
import 'package:rwnaqk_frontend/modules/home/providers/home_providers.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_banner_section.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_categories_section.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_flash_sale_section.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_new_items_section.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_skeletons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Home Skeleton & Empty State Tests', () {
    test('HomeContentState initializes empty with isLoading = true', () {
      const state = HomeContentState(isLoading: true);
      expect(state.banners, isEmpty);
      expect(state.categories, isEmpty);
      expect(state.topProducts, isEmpty);
      expect(state.newItems, isEmpty);
      expect(state.flashSale, isEmpty);
      expect(state.isLoading, isTrue);
    });

    testWidgets('Displays skeleton while loading and banners/categories are empty',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeContentProvider.overrideWith(
              () => _StubHomeNotifier(
                const HomeContentState(isLoading: true),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  HomeBannerSection(),
                  HomeCategoriesSection(),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify Skeletons are visible
      expect(find.byType(HomeBannerSkeleton), findsOneWidget);
      expect(find.byType(HomeCategoriesSkeleton), findsOneWidget);
      expect(find.byType(HomeSectionEmptyWidget), findsNothing);
    });

    testWidgets('Displays section message when loading finishes and no items found',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeContentProvider.overrideWith(
              () => _StubHomeNotifier(
                const HomeContentState(
                  isLoading: false,
                  hasLoaded: true,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  HomeBannerSection(),
                  HomeCategoriesSection(),
                  HomeFlashSaleSection(),
                  HomeNewItemsSection(itemWidth: 160, height: 260),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify Skeletons are not visible
      expect(find.byType(HomeBannerSkeleton), findsNothing);
      expect(find.byType(HomeCategoriesSkeleton), findsNothing);

      // Verify Empty State widgets are displayed with appropriate messages
      expect(find.byType(HomeSectionEmptyWidget), findsNWidgets(4));
      expect(find.text('لا توجد عروض ترويجية متاحة حالياً'), findsOneWidget);
      expect(find.text('لا توجد تصنيفات متاحة حالياً'), findsOneWidget);
      expect(find.text('لا توجد عروض وتخفيضات فلاش متاحة حالياً'), findsOneWidget);
      expect(find.text('لا توجد منتجات جديدة حالياً'), findsOneWidget);
    });

    testWidgets(
        'Does NOT display skeleton when refreshing data (hasLoaded = true, isRefreshing = true)',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeContentProvider.overrideWith(
              () => _StubHomeNotifier(
                const HomeContentState(
                  isLoading: false,
                  isRefreshing: true,
                  hasLoaded: true,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  HomeBannerSection(),
                  HomeCategoriesSection(),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify Skeletons are NOT shown during refresh
      expect(find.byType(HomeBannerSkeleton), findsNothing);
      expect(find.byType(HomeCategoriesSkeleton), findsNothing);
    });

    testWidgets('ProductDetailsSkeleton renders distinct section layouts and bottom bar',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProductDetailsSkeleton(
              crossAxisCount: 2,
              hasVariations: true,
              hasSizeGuide: true,
            ),
            bottomNavigationBar: ProductDetailsBottomBarSkeleton(),
          ),
        ),
      );

      // Let animation initialize
      await tester.pump();

      // Verify ProductDetailsSkeleton & BottomBar are rendered
      expect(find.byType(ProductDetailsSkeleton), findsOneWidget);
      expect(find.byType(ProductDetailsBottomBarSkeleton), findsOneWidget);

      // Verify multiple distinct SkeletonBox elements render (not a single solid box)
      expect(find.byType(SkeletonBox), findsAtLeastNWidgets(10));
    });

    testWidgets('ProductDetailsSkeleton respects hasVariations = false and hasSizeGuide = false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProductDetailsSkeleton(
              crossAxisCount: 2,
              hasVariations: false,
              hasSizeGuide: false,
            ),
          ),
        ),
      );

      await tester.pump();

      // Should still render skeleton, but with fewer elements because variations and size guide are omitted
      expect(find.byType(ProductDetailsSkeleton), findsOneWidget);
      expect(find.byType(SkeletonBox), findsWidgets);
    });

    testWidgets('retrySection only shows skeleton for targeted section and keeps others unchanged',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeContentProvider.overrideWith(
              () => _StubHomeNotifier(
                const HomeContentState(
                  isLoading: false,
                  hasLoaded: true,
                  loadingSections: {HomeSection.categories},
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  HomeBannerSection(),
                  HomeCategoriesSection(),
                ],
              ),
            ),
          ),
        ),
      );

      // Categories is loading individually: should show Skeleton
      expect(find.byType(HomeCategoriesSkeleton), findsOneWidget);

      // Banners is not in loadingSections: should remain on Empty State
      expect(find.byType(HomeBannerSkeleton), findsNothing);
      expect(find.text('لا توجد عروض ترويجية متاحة حالياً'), findsOneWidget);
    });
  });
}

class _StubHomeNotifier extends HomeContentNotifier {
  final HomeContentState _initial;
  _StubHomeNotifier(this._initial);

  @override
  HomeContentState build() => _initial;
}
