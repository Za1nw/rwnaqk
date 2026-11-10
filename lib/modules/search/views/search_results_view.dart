import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_breakpoints.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_empty_state.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_page_loading.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_query_chip.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_section_header.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/app_filter_button.dart';
import 'package:rwnaqk_frontend/modules/checkout/widgets/product_grid_section.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/shop_top_bar.dart';
import 'package:rwnaqk_frontend/modules/search/providers/search_providers.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  ConsumerState<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
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

    // Keep text field in sync if query changes externally
    if (_searchC.text != searchState.query && !searchState.isLoading) {
      _searchC.text = searchState.query;
    }

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final cols = AppBreakpoints.productGridColumns(w);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ShopTopBar(
                          title: Tk.homeTitle.tr,
                          searchHint: Tk.searchTitle.tr,
                          controller: _searchC,
                          onChanged: notifier.onQueryChanged,
                          onSubmitted: notifier.submitSearch,
                          onCamera: notifier.openCamera,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 10),
                      AppFilterButton(onTap: notifier.openFilters),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (searchState.query.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppQueryChip(
                        text: searchState.query.trim(),
                        onRemove: () {
                          _searchC.clear();
                          notifier.clearQuery();
                        },
                      ),
                    ),
                  if (searchState.isLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: AppPageLoading(
                        expanded: false,
                        title: Tk.searchLoadingTitle.tr,
                        subtitle: Tk.searchLoadingSubtitle.tr,
                      ),
                    )
                  else if (searchState.results.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: AppEmptyState(
                        title: Tk.searchNoResultsTitle.tr,
                        subtitle: Tk.searchNoResultsSubtitle.tr,
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSectionHeader(
                          title: Tk.searchResultsCount.trParams({
                            'count': '${searchState.results.length}',
                          }),
                          titleFontSize: 15,
                          titleFontWeight: FontWeight.w800,
                          titleColor: context.mutedForeground,
                        ),
                        const SizedBox(height: 12),
                        ProductGridSection(
                          items: searchState.results,
                          crossAxisCount: cols,
                          childAspectRatio: w >= AppBreakpoints.compact
                              ? 0.74
                              : 0.72,
                          onTap: notifier.openProduct,
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
