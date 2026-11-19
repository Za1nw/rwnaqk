import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/modules/checkout/widgets/product_horizontal_list.dart';
import 'package:rwnaqk_frontend/modules/home/providers/home_providers.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/flash_sale_header.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_skeletons.dart';

class HomeFlashSaleSection extends ConsumerWidget {
  final double itemWidth;
  final double height;

  const HomeFlashSaleSection({
    super.key,
    this.itemWidth = 165,
    this.height = 275,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashSale = ref.watch(homeContentProvider.select((s) => s.flashSale));
    final isLoading = ref.watch(
      homeContentProvider.select((s) => s.isSectionLoading(HomeSection.flashSale)),
    );
    final notifier = ref.read(homeContentProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _HomeFlashSaleHeaderConsumer(),
        const SizedBox(height: 12),
        if (isLoading && flashSale.isEmpty)
          HomeProductHorizontalListSkeleton(
            itemWidth: itemWidth,
            height: height,
          )
        else if (flashSale.isNotEmpty)
          ProductHorizontalList(
            items: flashSale,
            itemWidth: itemWidth,
            height: height,
            onTap: notifier.openProduct,
          )
        else
          HomeSectionEmptyWidget(
            message: 'لا توجد عروض وتخفيضات فلاش متاحة حالياً',
            icon: Icons.flash_off_rounded,
            height: 125,
            onRetry: () => notifier.retrySection(HomeSection.flashSale),
          ),
      ],
    );
  }
}

/// ودجت معزولة لاستهلاك العداد التنازلي دون إعادة بناء قائمة المنتجات الثقيلة كل ثانية
class _HomeFlashSaleHeaderConsumer extends ConsumerWidget {
  const _HomeFlashSaleHeaderConsumer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (hh, mm, ss) = ref.watch(
      homeContentProvider.select((s) => (s.hh, s.mm, s.ss)),
    );
    final hasItems = ref.watch(
      homeContentProvider.select((s) => s.flashSale.isNotEmpty),
    );
    final notifier = ref.read(homeContentProvider.notifier);

    return FlashSaleHeader(
      hh: hh,
      mm: mm,
      ss: ss,
      onSeeAll: hasItems ? notifier.openFlashSaleScreen : null,
    );
  }
}
