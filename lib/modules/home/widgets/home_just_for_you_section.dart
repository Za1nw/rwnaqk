import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_section_header.dart';
import 'package:rwnaqk_frontend/modules/checkout/widgets/product_grid_section.dart';
import 'package:rwnaqk_frontend/modules/home/providers/home_providers.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_layout.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_skeletons.dart';

class HomeJustForYouSection extends ConsumerWidget {
  final int crossAxisCount;

  const HomeJustForYouSection({super.key, required this.crossAxisCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final justForYou = ref.watch(homeContentProvider.select((s) => s.justForYou));
    final isLoading = ref.watch(
      homeContentProvider.select((s) => s.isSectionLoading(HomeSection.justForYou)),
    );
    final notifier = ref.read(homeContentProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: Tk.homeJustForYou.tr,
          actionText: justForYou.isNotEmpty ? Tk.homeSeeAll.tr : null,
          onActionTap: justForYou.isNotEmpty ? notifier.onSeeAllJustForYou : null,
        ),
        const SizedBox(height: HomeLayout.innerGap),
        if (isLoading && justForYou.isEmpty)
          HomeProductGridSkeleton(crossAxisCount: crossAxisCount)
        else if (justForYou.isNotEmpty)
          ProductGridSection(
            items: justForYou,
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: HomeLayout.gridSpacing,
            mainAxisSpacing: HomeLayout.gridSpacing,
            onTap: notifier.openProduct,
            childAspectRatio: 1.0,
          )
        else
          HomeSectionEmptyWidget(
            message: 'لا توجد توصيات متوفرة حالياً',
            icon: Icons.recommend_outlined,
            height: 125,
            onRetry: () => notifier.retrySection(HomeSection.justForYou),
          ),
      ],
    );
  }
}
