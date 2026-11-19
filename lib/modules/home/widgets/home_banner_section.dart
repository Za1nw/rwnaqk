import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/modules/home/providers/home_providers.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/banner_carousel.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_skeletons.dart';

class HomeBannerSection extends ConsumerWidget {
  const HomeBannerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banners = ref.watch(homeContentProvider.select((s) => s.banners));
    final bannerIndex = ref.watch(homeContentProvider.select((s) => s.bannerIndex));
    final isLoading = ref.watch(
      homeContentProvider.select((s) => s.isSectionLoading(HomeSection.banners)),
    );
    final notifier = ref.read(homeContentProvider.notifier);

    // 1. حالة التحميل الأولي أو إعادة محاولة هذا القسم: عرض هيكل تحميل البانر (Skeleton)
    if (isLoading && banners.isEmpty) {
      return const HomeBannerSkeleton();
    }

    // 2. حالة نجاح الجلب وتوفر البيانات
    if (banners.isNotEmpty) {
      return BannerCarousel(
        items: banners,
        index: bannerIndex,
        onChanged: notifier.onBannerChanged,
      );
    }

    // 3. حالة عدم توفر البيانات أو فشل الجلب: عرض رسالة تنبيه مخصصة للقسم
    return HomeSectionEmptyWidget(
      message: 'لا توجد عروض ترويجية متاحة حالياً',
      icon: Icons.local_offer_outlined,
      height: 130,
      onRetry: () => notifier.retrySection(HomeSection.banners),
    );
  }
}
