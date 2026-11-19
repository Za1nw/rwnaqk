import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/modules/home/widgets/home_skeletons.dart';

/// هيكل تحميل متكامل لشاشة تفاصيل المنتج يطابق بنسبة 100% تصميم الشاشة الحقيقي وتقسيماتها
class ProductDetailsSkeleton extends StatelessWidget {
  final int crossAxisCount;
  final bool hasVariations;
  final bool hasSizeGuide;

  const ProductDetailsSkeleton({
    super.key,
    this.crossAxisCount = 2,
    this.hasVariations = false,
    this.hasSizeGuide = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
        children: [
          // 1. كرت رأس المنتج الرئيسي (معرض الصور، البيانات الأساسية، والخصائص والكمية المباشرة)
          _HeaderCardSkeleton(
            hasVariations: hasVariations,
            hasSizeGuide: hasSizeGuide,
          ),

          const SizedBox(height: 18),

          // 2. كرت المواصفات والتفاصيل المطابق لـ ProductSpecificationsCard
          const _SpecificationsCardSkeleton(),

          const SizedBox(height: 18),

          // 3. قسم المراجعات والتقييمات المطابق لـ ProductReviewsSection
          const _ReviewsSectionSkeleton(),

          const SizedBox(height: 18),

          // 4. قسم المنتجات الموصى بها (لك خصيصاً)
          _RecommendedSectionSkeleton(crossAxisCount: crossAxisCount),

          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

/// هيكل شريط الإجراءات السفلي (المفضلة، أضف للسلة، اشتري الآن)
class ProductDetailsBottomBarSkeleton extends StatelessWidget {
  const ProductDetailsBottomBarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: context.card,
          border: Border(
            top: BorderSide(
              color: context.border.withValues(alpha: 0.55),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: const [
              // زر المفضلة المربع
              SkeletonBox(width: 48, height: 48, borderRadius: 14),
              SizedBox(width: 10),

              // زر إضافة إلى السلة
              Expanded(
                flex: 5,
                child: SkeletonBox(height: 48, borderRadius: 14),
              ),
              SizedBox(width: 10),

              // زر اشتري الآن
              Expanded(
                flex: 5,
                child: SkeletonBox(height: 48, borderRadius: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==============================================================================
// INTERNAL SECTION SKELETONS
// ==============================================================================

/// كرت رأس المنتج الكامل
class _HeaderCardSkeleton extends StatelessWidget {
  final bool hasVariations;
  final bool hasSizeGuide;

  const _HeaderCardSkeleton({
    this.hasVariations = false,
    this.hasSizeGuide = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: context.shadow.withValues(
              alpha: isDark ? 0.14 : 0.07,
            ),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. معرض الصور (Gallery) بنسبة 1.05 مثل ProductDetailsHeaderGallery
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 1.05,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SkeletonBox(
                      borderRadius: 0,
                      color: isDark
                          ? const Color(0xFF190C18)
                          : const Color(0xFFF7F1F5),
                    ),
                  ),
                  // شارة الخصم
                  const Positioned(
                    top: 12,
                    right: 12,
                    child: SkeletonBox.pill(width: 46, height: 22),
                  ),
                  // زر المفضلة
                  const Positioned(
                    top: 12,
                    left: 12,
                    child: SkeletonBox.circle(size: 38),
                  ),
                  // مؤشرات الصفحات بالأسفل (Dots)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SkeletonBox.pill(width: 18, height: 6),
                        SizedBox(width: 4),
                        SkeletonBox.circle(size: 6),
                        SizedBox(width: 4),
                        SkeletonBox.circle(size: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. بطاقة البيانات والمعلومات الأساسية
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // شارة الماركة (Brand Eyebrow)
                const SkeletonBox(width: 70, height: 20, borderRadius: 6),
                const SizedBox(height: 8),

                // عنوان المنتج (سطران)
                const SkeletonBox.pill(width: double.infinity, height: 18),
                const SizedBox(height: 6),
                const SkeletonBox.pill(width: 220, height: 18),
                const SizedBox(height: 10),

                // سطر التقييم والمراجعات وحالة التوفر
                Row(
                  children: const [
                    SkeletonBox.pill(width: 75, height: 14),
                    SizedBox(width: 8),
                    SkeletonBox.pill(width: 50, height: 12),
                    Spacer(),
                    SkeletonBox(width: 75, height: 20, borderRadius: 6),
                  ],
                ),
                const SizedBox(height: 14),

                // سطر السعر والخصم
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: const [
                    SkeletonBox.pill(width: 110, height: 26),
                    SizedBox(width: 10),
                    SkeletonBox.pill(width: 65, height: 14),
                    SizedBox(width: 8),
                    SkeletonBox(width: 45, height: 20, borderRadius: 6),
                  ],
                ),
                const SizedBox(height: 12),

                // صندوق الوصف المختصر ذو الخط الجانبي
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: context.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: BorderDirectional(
                      start: BorderSide(
                        color: context.primary.withValues(alpha: 0.35),
                        width: 3.5,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonBox.pill(width: double.infinity, height: 12),
                      SizedBox(height: 5),
                      SkeletonBox.pill(width: 180, height: 12),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 3. صندوق الخصائص والكمية المباشرة المدمج (_ProductSelectionAndQuantitySection)
                Container(
                  decoration: BoxDecoration(
                    color: context.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: context.border.withValues(alpha: 0.55),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      // إذا كان للمنتج خيارات/خصائص (hasVariations)
                      if (hasVariations) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                          child: Row(
                            children: [
                              const SkeletonBox(width: 32, height: 32, borderRadius: 9),
                              const SizedBox(width: 10),
                              const SkeletonBox.pill(width: 55, height: 14),
                              const Spacer(),
                              // يظهر زر دليل المقاسات فقط إذا كان للمنتج دليل مقاسات
                              if (hasSizeGuide) ...[
                                const SkeletonBox.pill(width: 90, height: 26),
                                const SizedBox(width: 6),
                              ],
                              const SkeletonBox.pill(width: 40, height: 16),
                            ],
                          ),
                        ),

                        // خيارات الخصائص (الألوان / المقاسات)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: Row(
                            children: List.generate(
                              4,
                              (i) => const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: SkeletonBox(
                                  width: 50,
                                  height: 32,
                                  borderRadius: 8,
                                ),
                              ),
                            ),
                          ),
                        ),

                        Divider(
                          height: 1,
                          thickness: 0.6,
                          color: context.border.withValues(alpha: 0.4),
                        ),
                      ] else if (hasSizeGuide) ...[
                        // إذا كان للمنتج دليل مقاسات فقط بدون خصائص
                        const Padding(
                          padding: EdgeInsets.fromLTRB(14, 10, 14, 8),
                          child: Row(
                            children: [
                              Spacer(),
                              SkeletonBox.pill(width: 90, height: 26),
                            ],
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 0.6,
                          color: context.border.withValues(alpha: 0.4),
                        ),
                      ],

                      // صف مغير الكمية والمجموع الإجمالي
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        child: Row(
                          children: const [
                            SkeletonBox(width: 110, height: 38, borderRadius: 10),
                            Spacer(),
                            SkeletonBox.pill(width: 90, height: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// كرت المواصفات والتفاصيل المطابق لـ ProductSpecificationsCard
class _SpecificationsCardSkeleton extends StatelessWidget {
  const _SpecificationsCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: context.shadow.withValues(
              alpha: isDark ? 0.12 : 0.04,
            ),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // شريط العنوان مع الأيقونة المربعة وسهم التوسيع
            Row(
              children: const [
                SkeletonBox(width: 34, height: 34, borderRadius: 10),
                SizedBox(width: 12),
                SkeletonBox.pill(width: 130, height: 16),
                Spacer(),
                SkeletonBox.circle(size: 20),
              ],
            ),
            const SizedBox(height: 14),
            // بنود المواصفات
            const SkeletonBox.pill(width: double.infinity, height: 12),
            const SizedBox(height: 8),
            const SkeletonBox.pill(width: double.infinity, height: 12),
            const SizedBox(height: 8),
            const SkeletonBox.pill(width: 200, height: 12),
          ],
        ),
      ),
    );
  }
}

/// قسم المراجعات والتقييمات المطابق لـ ProductReviewsSection
class _ReviewsSectionSkeleton extends StatelessWidget {
  const _ReviewsSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم مع عدد المراجعات وزر الإضافة
        Row(
          children: const [
            SkeletonBox.pill(width: 90, height: 16),
            SizedBox(width: 8),
            SkeletonBox.pill(width: 45, height: 14),
            Spacer(),
            SkeletonBox.pill(width: 85, height: 28),
          ],
        ),
        const SizedBox(height: 12),

        // بطاقة مراجعة
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.border.withValues(alpha: 0.45)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  SkeletonBox.circle(size: 36),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox.pill(width: 80, height: 13),
                      SizedBox(height: 4),
                      SkeletonBox.pill(width: 60, height: 10),
                    ],
                  ),
                  Spacer(),
                  SkeletonBox.pill(width: 55, height: 12),
                ],
              ),
              const SizedBox(height: 10),
              const SkeletonBox.pill(width: double.infinity, height: 12),
              const SizedBox(height: 4),
              const SkeletonBox.pill(width: 180, height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

/// قسم المنتجات الموصى بها (لك خصيصاً)
class _RecommendedSectionSkeleton extends StatelessWidget {
  final int crossAxisCount;

  const _RecommendedSectionSkeleton({required this.crossAxisCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: context.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            const SkeletonBox.pill(width: 90, height: 16),
          ],
        ),
        const SizedBox(height: 12),
        HomeProductGridSkeleton(crossAxisCount: crossAxisCount),
      ],
    );
  }
}
