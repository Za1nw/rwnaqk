import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/modules/checkout/widgets/product_horizontal_list.dart';
import 'package:rwnaqk_frontend/modules/home/providers/home_providers.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/flash_sale_header.dart';

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
    final state = ref.watch(homeContentProvider);
    final notifier = ref.read(homeContentProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FlashSaleHeader(
          hh: state.hh,
          mm: state.mm,
          ss: state.ss,
          onSeeAll: notifier.openFlashSaleScreen,
        ),
        const SizedBox(height: 12),
        if (state.flashSale.isNotEmpty)
          ProductHorizontalList(
            items: state.flashSale,
            itemWidth: itemWidth,
            height: height,
            onTap: notifier.openProduct,
          ),
      ],
    );
  }
}
