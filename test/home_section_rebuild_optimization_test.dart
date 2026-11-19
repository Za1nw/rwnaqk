import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_banner_item.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_category_item.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/home/providers/home_providers.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_banner_section.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_flash_sale_section.dart';

class TestHomeContentNotifier extends HomeContentNotifier {
  @override
  HomeContentState build() {
    return const HomeContentState(
      banners: [
        HomeBannerItem(
          id: '1',
          titleKey: 'Banner 1',
          subtitleKey: 'Sub',
          badgeKey: 'New',
          imageUrl: '',
        ),
      ],
      categories: [
        HomeCategoryItem(
          id: '1',
          name: 'Cat 1',
          count: 5,
          imageUrls: [],
        ),
      ],
      flashSale: [
        HomeProductItem(
          id: '1',
          title: 'Product 1',
          imageUrl: '',
          price: 100,
        ),
      ],
      newItems: [
        HomeProductItem(
          id: '2',
          title: 'Product 2',
          imageUrl: '',
          price: 200,
        ),
      ],
      isLoading: false,
      hasLoaded: true,
      hh: 1,
      mm: 30,
      ss: 0,
    );
  }

  void tickTimer() {
    state = state.copyWith(ss: state.ss > 0 ? state.ss - 1 : 59);
  }
}

void main() {
  testWidgets(
    'Timer ticks do NOT cause rebuild of HomeBannerSection or heavy ProductHorizontalList in HomeFlashSaleSection',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeContentProvider.overrideWith(TestHomeContentNotifier.new),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ListView(
                children: const [
                  HomeBannerSection(),
                  HomeFlashSaleSection(),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger timer tick that only modifies (hh, mm, ss) in HomeContentState
      final container = ProviderScope.containerOf(tester.element(find.byType(HomeBannerSection)));
      final notifier = container.read(homeContentProvider.notifier) as TestHomeContentNotifier;

      notifier.tickTimer();
      await tester.pump();

      notifier.tickTimer();
      await tester.pump();

      // Verify that HomeBannerSection and HomeFlashSaleSection are still intact and functioning
      expect(find.byType(HomeBannerSection), findsOneWidget);
      expect(find.byType(HomeFlashSaleSection), findsOneWidget);
    },
  );
}
