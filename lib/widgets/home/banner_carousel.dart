import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import '../../models/home_banner_item.dart';

class BannerCarousel extends StatefulWidget {
  final List<HomeBannerItem> items;

  /// Controlled index من الـ Controller
  final int index;

  /// يرجّع index عند السحب
  final ValueChanged<int> onChanged;

  /// اختياري: لو تبغى تتحكم بالـ controller من خارج الودجت
  final PageController? controller;

  const BannerCarousel({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
    this.controller,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _pageController;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();

    // لو المستخدم مرّر Controller جاهز نستخدمه، غير كذا ننشئ واحد داخلي
    if (widget.controller != null) {
      _pageController = widget.controller!;
    } else {
      _ownsController = true;
      _pageController = PageController(initialPage: widget.index);
    }
  }

  @override
  void didUpdateWidget(covariant BannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 1) لو تغيرت العناصر وبطل الـ index صالح، لا نكسر UI
    final maxIndex = widget.items.isEmpty ? 0 : widget.items.length - 1;
    final safeIndex = widget.index.clamp(0, maxIndex);

    // 2) لو تغيّر index من الخارج (مثلاً controller) لازم نزامن PageView
    if (safeIndex != oldWidget.index &&
        _pageController.hasClients &&
        (_pageController.page?.round() ?? _pageController.initialPage) != safeIndex) {
      _pageController.animateToPage(
        safeIndex,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _pageController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, c) {
        // ✅ Responsive height:
        // - موبايل صغير: ~120-140
        // - موبايل كبير: ~150
        // - تابلت: ~170-190
        final w = c.maxWidth;
        final h = (w * 0.34).clamp(170.0, 230.0);

        return Column(
          children: [
            SizedBox(
              height: h,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.items.length,
                onPageChanged: widget.onChanged,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (_, i) => _BannerCard(item: widget.items[i]),
              ),
            ),

            const SizedBox(height: 18),

            _Dots(
              count: widget.items.length,
              activeIndex: widget.index.clamp(0, widget.items.length - 1),
            ),
          ],
        );
      },
    );
  }
}

class _BannerCard extends StatelessWidget {
  final HomeBannerItem item;
  const _BannerCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);

    // ✅ شادو محترم (خفيف بالدارك عشان ما يعمل glow مزعج)
    final shadow = BoxShadow(
      color: context.shadow.withOpacity(context.isDark ? 0.18 : 0.10),
      blurRadius: 18,
      offset: const Offset(0, 10),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ClipRRect(
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [shadow],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ✅ صورة مع Loading + Error
              Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: context.card,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(context.primary),
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  color: context.card,
                  alignment: Alignment.center,
                  child: Icon(Icons.image_not_supported_outlined, color: context.mutedForeground),
                ),
              ),

              // ✅ Overlay gradient محسّن للقراءة
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(context.isDark ? 0.58 : 0.50),
                      Colors.black.withOpacity(0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // ✅ محتوى البنر
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.titleKey.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.subtitleKey.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.92),
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        height: 1.25,
                      ),
                    ),
                    const Spacer(),
                    _Badge(text: item.badgeKey.tr),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.primary,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: context.shadow.withOpacity(context.isDark ? 0.18 : 0.10),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: context.primaryForeground,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int activeIndex;
  const _Dots({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    // ✅ Accessibility label واضح
    return Semantics(
      label: 'carousel_dots',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final active = i == activeIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 210),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: active ? context.primary : context.border.withOpacity(0.9),
              borderRadius: BorderRadius.circular(999),
            ),
          );
        }),
      ),
    );
  }
}
