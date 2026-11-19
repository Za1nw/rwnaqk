import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_section_header.dart';
import 'package:rwnaqk_frontend/modules/home/providers/home_providers.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/category_grid.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_layout.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_skeletons.dart';

class HomeCategoriesSection extends ConsumerWidget {
  const HomeCategoriesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(homeContentProvider.select((s) => s.categories));
    final isLoading = ref.watch(
      homeContentProvider.select((s) => s.isSectionLoading(HomeSection.categories)),
    );
    final notifier = ref.read(homeContentProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: Tk.homeCategories.tr,
          actionText: categories.isNotEmpty ? Tk.homeSeeAll.tr : null,
          onActionTap: categories.isNotEmpty ? notifier.onSeeAllCategories : null,
        ),
        const SizedBox(height: HomeLayout.innerGap),
        if (isLoading && categories.isEmpty)
          const HomeCategoriesSkeleton()
        else if (categories.isNotEmpty)
          CategoryGrid(items: categories, onTap: notifier.openCategory)
        else
          HomeSectionEmptyWidget(
            message: 'لا توجد تصنيفات متاحة حالياً',
            icon: Icons.category_outlined,
            height: 98,
            onRetry: () => notifier.retrySection(HomeSection.categories),
          ),
      ],
    );
  }
}
