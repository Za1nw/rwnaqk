import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_breakpoints.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_section_header.dart';
import 'package:rwnaqk_frontend/modules/checkout/widgets/product_horizontal_list.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/shop_top_bar.dart';
import 'package:rwnaqk_frontend/modules/search/providers/search_providers.dart';
import 'package:rwnaqk_frontend/modules/search/widgets/search_chip_group.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _searchC;

  @override
  void initState() {
    super.initState();
    _searchC = TextEditingController(
      text: ref.read(productSearchProvider).query,
    );
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(productSearchProvider);
    final notifier = ref.read(productSearchProvider.notifier);

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShopTopBar(
                title: Tk.searchTitle.tr,
                searchHint: Tk.searchTitle.tr,
                controller: _searchC,
                onChanged: notifier.onQueryChanged,
                onSubmitted: (val) {
                  notifier.submitSearch(val);
                },
                onCamera: notifier.openCamera,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              AppSectionHeader(
                title: Tk.searchHistory.tr,
                actionIcon: Icons.delete_outline_rounded,
                onActionTap: notifier.clearHistory,
                titleFontSize: 15,
                titleFontWeight: FontWeight.w800,
                titleColor: context.mutedForeground,
              ),
              const SizedBox(height: 10),
              if (searchState.history.isEmpty)
                Text(
                  Tk.searchNoRecent.tr,
                  style: TextStyle(
                    color: context.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                SearchChipGroup(
                  items: searchState.history,
                  onTap: (chip) {
                    _searchC.text = chip;
                    notifier.submitSearch(chip);
                  },
                ),
              const SizedBox(height: 18),
              AppSectionHeader(
                title: Tk.searchRecommendations.tr,
                titleFontSize: 14,
                titleFontWeight: FontWeight.w800,
                titleColor: context.mutedForeground,
              ),
              const SizedBox(height: 10),
              if (searchState.recommendations.isNotEmpty)
                SearchChipGroup(
                  items: searchState.recommendations,
                  onTap: (chip) {
                    _searchC.text = chip;
                    notifier.submitSearch(chip);
                  },
                ),
              const SizedBox(height: 22),
              AppSectionHeader(title: Tk.searchDiscover.tr),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (_, c) {
                  final w = c.maxWidth;
                  final cardW = AppBreakpoints.isCompact(w) ? 155.0 : 170.0;
                  final listH = AppBreakpoints.isCompact(w) ? 280.0 : 290.0;

                  if (searchState.discover.isEmpty) return const SizedBox.shrink();

                  return ProductHorizontalList(
                    items: searchState.discover,
                    itemWidth: cardW,
                    height: listH,
                    onTap: notifier.openProduct,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
