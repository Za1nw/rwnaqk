import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_section_header.dart';
import 'package:rwnaqk_frontend/modules/checkout/widgets/product_horizontal_list.dart';
import 'package:rwnaqk_frontend/modules/home/providers/home_providers.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_layout.dart';

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
    final state = ref.watch(homeContentProvider);
    final notifier = ref.read(homeContentProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: Tk.homeNewItems.tr,
          actionText: Tk.homeSeeAll.tr,
          onActionTap: notifier.onSeeAllNewItems,
        ),
        const SizedBox(height: HomeLayout.innerGap),
        if (state.newItems.isNotEmpty)
          ProductHorizontalList(
            items: state.newItems,
            itemWidth: itemWidth,
            height: height,
            onTap: notifier.openProduct,
          ),
      ],
    );
  }
}
