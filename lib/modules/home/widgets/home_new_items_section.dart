import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_section_header.dart';
import 'package:rwnaqk_frontend/modules/checkout/widgets/product_horizontal_list.dart';
import 'package:rwnaqk_frontend/modules/home/providers/home_providers.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_layout.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_skeletons.dart';

class HomeNewItemsSection extends ConsumerWidget {
  final double itemWidth;
  final double height;

  const HomeNewItemsSection({
    super.key,
    required this.itemWidth,
    required this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newItems = ref.watch(homeContentProvider.select((s) => s.newItems));
    final isLoading = ref.watch(
      homeContentProvider.select((s) => s.isSectionLoading(HomeSection.newItems)),
    );
    final notifier = ref.read(homeContentProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: Tk.homeNewItems.tr,
          actionText: newItems.isNotEmpty ? Tk.homeSeeAll.tr : null,
          onActionTap: newItems.isNotEmpty ? notifier.onSeeAllNewItems : null,
        ),
        const SizedBox(height: HomeLayout.innerGap),
        if (isLoading && newItems.isEmpty)
          HomeProductHorizontalListSkeleton(
            itemWidth: itemWidth,
            height: height,
          )
        else if (newItems.isNotEmpty)
          ProductHorizontalList(
            items: newItems,
            itemWidth: itemWidth,
            height: height,
            onTap: notifier.openProduct,
          )
        else
          HomeSectionEmptyWidget(
            message: 'لا توجد منتجات جديدة حالياً',
            icon: Icons.new_releases_outlined,
            height: 125,
            onRetry: () => notifier.retrySection(HomeSection.newItems),
          ),
      ],
    );
  }
}
