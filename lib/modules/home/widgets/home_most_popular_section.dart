import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_section_header.dart';
import 'package:rwnaqk_frontend/modules/checkout/widgets/product_horizontal_list.dart';
import 'package:rwnaqk_frontend/modules/home/providers/home_providers.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_layout.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_skeletons.dart';

class HomeMostPopularSection extends ConsumerWidget {
  final double itemWidth;
  final double height;

  const HomeMostPopularSection({
    super.key,
    required this.itemWidth,
    required this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mostPopular = ref.watch(homeContentProvider.select((s) => s.mostPopular));
    final isLoading = ref.watch(
      homeContentProvider.select((s) => s.isSectionLoading(HomeSection.mostPopular)),
    );
    final notifier = ref.read(homeContentProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: Tk.homeMostPopular.tr,
          actionText: mostPopular.isNotEmpty ? Tk.homeSeeAll.tr : null,
          onActionTap: mostPopular.isNotEmpty ? notifier.onSeeAllMostPopular : null,
        ),
        const SizedBox(height: HomeLayout.innerGap),
        if (isLoading && mostPopular.isEmpty)
          HomeProductHorizontalListSkeleton(
            itemWidth: itemWidth,
            height: height,
          )
        else if (mostPopular.isNotEmpty)
          ProductHorizontalList(
            items: mostPopular,
            itemWidth: itemWidth,
            height: height,
            onTap: notifier.openProduct,
          )
        else
          HomeSectionEmptyWidget(
            message: 'لا توجد منتجات في قائمة الأكثر طلباً حالياً',
            icon: Icons.trending_up_rounded,
            height: 125,
            onRetry: () => notifier.retrySection(HomeSection.mostPopular),
          ),
      ],
    );
  }
}
