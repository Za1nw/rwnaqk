import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_section_header.dart';
import 'package:rwnaqk_frontend/modules/home/providers/home_providers.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/category_grid.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_layout.dart';

class HomeCategoriesSection extends ConsumerWidget {
  const HomeCategoriesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeContentProvider);
    final notifier = ref.read(homeContentProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: Tk.homeCategories.tr,
          actionText: Tk.homeSeeAll.tr,
          onActionTap: notifier.onSeeAllCategories,
        ),
        const SizedBox(height: HomeLayout.innerGap),
        if (state.categories.isNotEmpty)
          CategoryGrid(
            items: state.categories,
            onTap: notifier.openCategory,
          ),
      ],
    );
  }
}
