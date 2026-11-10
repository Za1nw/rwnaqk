import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_section_header.dart';
import 'package:rwnaqk_frontend/modules/checkout/widgets/product_grid_section.dart';
import 'package:rwnaqk_frontend/modules/home/providers/home_providers.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_layout.dart';

class HomeJustForYouSection extends ConsumerWidget {
  final int crossAxisCount;

  const HomeJustForYouSection({super.key, required this.crossAxisCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeContentProvider);
    final notifier = ref.read(homeContentProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: Tk.homeJustForYou.tr,
          actionText: Tk.homeSeeAll.tr,
          onActionTap: notifier.onSeeAllJustForYou,
        ),
        const SizedBox(height: HomeLayout.innerGap),
        if (state.justForYou.isNotEmpty)
          ProductGridSection(
            items: state.justForYou,
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: HomeLayout.gridSpacing,
            mainAxisSpacing: HomeLayout.gridSpacing,
            onTap: notifier.openProduct,
            childAspectRatio: 1.0,
          ),
      ],
    );
  }
}
