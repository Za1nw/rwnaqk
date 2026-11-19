import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';

// ==============================================================================
// 1. LUXURY SHIMMER ENGINE (INHERITED SCOPE COORDINATOR)
// ==============================================================================

/// منسق ومحرك الوميض (Shimmer) الاحترافي
///
/// يعمل بنظام InheritedWidget لتنسيق موجة الوميض بدقة عبر كافة العناصر الهيكلية
/// دون تشويه أو طمس خلفيات الكروت والتقسيمات الأساسية للشاشات.
class AppShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const AppShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1400),
  });

  static double of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_AppShimmerScope>();
    return scope?.value ?? 0.5;
  }

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerScope extends InheritedWidget {
  final double value;

  const _AppShimmerScope({
    required this.value,
    required super.child,
  });

  @override
  bool updateShouldNotify(_AppShimmerScope oldWidget) =>
      value != oldWidget.value;
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return _AppShimmerScope(
          value: _controller.value,
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (2 * slidePercent - 1),
      0,
      0,
    );
  }
}

// ==============================================================================
// 2. ATOMIC SKELETON PRIMITIVES
// ==============================================================================

/// عنصر هيكلي أساسي (مستطيل، دائرة، أو شريط حبّة دواء Pill) مع وميض داخلي ناعم.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxShape shape;
  final Color? color;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
    this.color,
  });

  const SkeletonBox.circle({
    super.key,
    required double size,
    this.color,
  })  : width = size,
        height = size,
        borderRadius = 0,
        shape = BoxShape.circle;

  const SkeletonBox.pill({
    super.key,
    this.width,
    this.height = 12,
    this.color,
  })  : borderRadius = 999,
        shape = BoxShape.rectangle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = AppShimmer.of(context);

    // تدرجات ألوان الوميض الملكية المتناسقة مع رونقك
    final baseColor = color ??
        (isDark ? const Color(0xFF2C172A) : const Color(0xFFE8E0E6));
    final highlightColor = isDark
        ? const Color(0xFF452742)
        : const Color(0xFFFAF7F9);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: const Alignment(-1.0, -0.3),
          end: const Alignment(1.0, 0.3),
          colors: [
            baseColor,
            highlightColor,
            baseColor,
          ],
          stops: const [0.1, 0.5, 0.9],
          transform: _SlidingGradientTransform(slidePercent: t),
        ),
      ),
    );
  }
}

// ==============================================================================
// 3. HOME SECTION SKELETONS (100% MATCHING SCREEN GEOMETRY)
// ==============================================================================

/// هيكل تحميل البانر الإعلاني - متطابق مع شكل وتصميم BannerCarousel
class HomeBannerSkeleton extends StatelessWidget {
  const HomeBannerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = (w * 0.50).clamp(180.0, 225.0);

        return AppShimmer(
          child: Column(
            children: [
              Container(
                height: h,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: context.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.border.withValues(alpha: 0.55),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.shadow.withValues(
                        alpha: context.isDark ? 0.30 : 0.08,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SkeletonBox.pill(width: 85, height: 18),
                      SizedBox(height: 10),
                      SkeletonBox.pill(width: 190, height: 18),
                      SizedBox(height: 6),
                      SkeletonBox.pill(width: 130, height: 13),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SkeletonBox.pill(width: 22, height: 6),
                  SizedBox(width: 5),
                  SkeletonBox.circle(size: 6),
                  SizedBox(width: 5),
                  SkeletonBox.circle(size: 6),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// هيكل تحميل شريط الفئات - متطابق بنسبة 100% مع CategoryGrid
class HomeCategoriesSkeleton extends StatelessWidget {
  const HomeCategoriesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SizedBox(
        height: 98,
        child: ListView.separated(
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          separatorBuilder: (_, _) => const SizedBox(width: 14),
          itemBuilder: (_, i) {
            return SizedBox(
              width: 72,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.card,
                      border: Border.all(
                        color: context.border.withValues(alpha: 0.55),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.shadow.withValues(
                            alpha: context.isDark ? 0.20 : 0.05,
                          ),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: SkeletonBox.circle(size: 28),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const SkeletonBox.pill(width: 52, height: 10),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// كرت منتج هيكلي - متطابق 100% مع ProductCard في الأبعاد والحدود والظل والتقسيم
class HomeProductCardSkeleton extends StatelessWidget {
  final double radius;

  const HomeProductCardSkeleton({
    super.key,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: context.border.withValues(alpha: 0.55),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.shadow.withValues(
              alpha: isDark ? 0.25 : 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. مساحة صورة المنتج بنفس النسبة (aspectRatio: 1.12)
          AspectRatio(
            aspectRatio: 1.12,
            child: Container(
              color: isDark
                  ? const Color(0xFF190C18)
                  : const Color(0xFFF7F1F5),
              child: Stack(
                children: const [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: SkeletonBox.pill(width: 38, height: 16),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: SkeletonBox.circle(size: 28),
                  ),
                ],
              ),
            ),
          ),
          // 2. تفاصيل المنتج
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox.pill(width: 46, height: 9),
                  const SizedBox(height: 5),
                  const SkeletonBox.pill(width: double.infinity, height: 11),
                  const SizedBox(height: 4),
                  const SkeletonBox.pill(width: 75, height: 11),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SkeletonBox.pill(width: 58, height: 13),
                            SizedBox(height: 3),
                            SkeletonBox.pill(width: 36, height: 9),
                          ],
                        ),
                      ),
                      const SkeletonBox.circle(size: 32),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// هيكل تحميل القوائم الأفقية للمنتجات
class HomeProductHorizontalListSkeleton extends StatelessWidget {
  final double itemWidth;
  final double height;

  const HomeProductHorizontalListSkeleton({
    super.key,
    required this.itemWidth,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SizedBox(
        height: height,
        child: ListView.separated(
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, _) => SizedBox(
            width: itemWidth,
            child: const HomeProductCardSkeleton(),
          ),
        ),
      ),
    );
  }
}

/// هيكل تحميل المنتجات المتصدرة مع شارة الترتيب الذهبية
class HomeTopProductsSkeleton extends StatelessWidget {
  final double itemWidth;
  final double height;

  const HomeTopProductsSkeleton({
    super.key,
    required this.itemWidth,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SizedBox(
        height: height,
        child: ListView.separated(
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, _) => SizedBox(
            width: itemWidth,
            child: Stack(
              children: const [
                Positioned.fill(
                  child: HomeProductCardSkeleton(),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: SkeletonBox.circle(size: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// هيكل تحميل شبكة المنتجات (Just For You)
class HomeProductGridSkeleton extends StatelessWidget {
  final int crossAxisCount;

  const HomeProductGridSkeleton({
    super.key,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = crossAxisCount < 1 ? 1 : crossAxisCount;
        const crossAxisSpacing = 12.0;
        const mainAxisSpacing = 12.0;
        final totalSpacing = crossAxisSpacing * (cols - 1);
        final tileW = (c.maxWidth - totalSpacing) / cols;

        double tileH;
        if (tileW <= 150) {
          tileH = tileW * 1.90;
        } else if (tileW <= 180) {
          tileH = tileW * 1.70;
        } else {
          tileH = tileW * 1.60;
        }

        return AppShimmer(
          child: GridView.builder(
            itemCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
              mainAxisExtent: tileH,
            ),
            itemBuilder: (_, _) => const HomeProductCardSkeleton(),
          ),
        );
      },
    );
  }
}

// ==============================================================================
// 4. EMPTY / ERROR SECTION PLACEHOLDER
// ==============================================================================

/// رسالة قسم أنيقة عند تعذر جلب البيانات أو عدم توفر عناصر
class HomeSectionEmptyWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final double height;

  const HomeSectionEmptyWidget({
    super.key,
    required this.message,
    this.icon = Icons.inventory_2_outlined,
    this.onRetry,
    this.height = 110,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF231422).withValues(alpha: 0.6)
            : const Color(0xFFFAF7F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? BrandColors.gold.withValues(alpha: 0.12)
              : const Color(0xFFE8DEE4),
          width: 1,
        ),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isDark ? const Color(0xFF9E8B99) : const Color(0xFF8C7686),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? const Color(0xFFC7B8C3) : const Color(0xFF6B5866),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 4),
                InkWell(
                  onTap: onRetry,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: 13,
                          color: BrandColors.burgundy,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'إعادة المحاولة',
                          style: TextStyle(
                            color: isDark ? BrandColors.gold : BrandColors.burgundy,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
