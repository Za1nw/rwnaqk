import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/modules/home/providers/home_providers.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/banner_carousel.dart';

class HomeBannerSection extends ConsumerWidget {
  const HomeBannerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeContentProvider);
    final notifier = ref.read(homeContentProvider.notifier);

    if (state.banners.isEmpty) return const SizedBox.shrink();

    return BannerCarousel(
      items: state.banners,
      index: state.bannerIndex,
      onChanged: notifier.onBannerChanged,
    );
  }
}
