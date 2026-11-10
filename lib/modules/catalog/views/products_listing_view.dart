import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/modules/catalog/providers/catalog_providers.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/app_filter_sheet.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/listing_grid.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/listing_loading_more.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/listing_sort_sheet.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/listing_states.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/listing_top_bar.dart';

class ProductsListingScreen extends ConsumerStatefulWidget {
  const ProductsListingScreen({super.key});

  @override
  ConsumerState<ProductsListingScreen> createState() =>
      _ProductsListingScreenState();
}

class _ProductsListingScreenState extends ConsumerState<ProductsListingScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(productsListingProvider.notifier).initFromArgs(args);
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 240) {
      ref.read(productsListingProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openFilters(BuildContext context) async {
    final state = ref.read(productsListingProvider);
    final result = await showModalBottomSheet<AppFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AppFilterSheet(initial: state.filterResult),
    );

    if (result != null) {
      ref.read(productsListingProvider.notifier).setFilter(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productsListingProvider);
    final notifier = ref.read(productsListingProvider.notifier);

    final isLoading = state.isLoading;
    final error = state.errorMessage;
    final items = state.items;

    final showGrid = !isLoading && error == null && items.isNotEmpty;

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            ListingTopBar(
              title: state.title,
              filterCount: state.activeFilterCount,
              onBack: () => Navigator.of(context).pop(),
              onSort: () => openListingSortSheet(
                context: context,
                currentSort: state.sort,
                onSelectSort: notifier.setSort,
              ),
              onFilter: () => _openFilters(context),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 8),
            ),
            if (isLoading)
              const ListingSkeletonSliver()
            else if (error != null)
              ListingErrorSliver(
                message: error,
                onRetry: notifier.refreshList,
              )
            else if (items.isEmpty)
              ListingEmptySliver(
                onRefresh: notifier.refreshList,
              )
            else
              ListingGridSliver(items: items),
            if (showGrid)
              ListingLoadingMoreSliver(isLoadingMore: state.isLoadingMore),
            if (showGrid)
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
          ],
        ),
      ),
    );
  }
}
