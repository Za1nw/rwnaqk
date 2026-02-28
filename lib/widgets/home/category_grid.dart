import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import '../../models/home_category_item.dart';

/// ✅ CategoryGrid (Reusable + Responsive + Animated)
///
/// يعرض قائمة الفئات Categories على شكل Grid.
/// كل بطاقة Category تحتوي على:
/// - شبكة صور صغيرة 2x2 (Preview سريع للفئة)
/// - اسم الفئة
/// - عدّاد اختياري (Count)
///
/// ✅ مرن:
/// - عدد الأعمدة يتغير حسب عرض الشاشة (Responsive)
/// - خيارات لتعديل المسافات والـ aspect ratio
/// - لا يعتمد على Controller => قابل لإعادة الاستخدام في أي صفحة
class CategoryGrid extends StatelessWidget {
  /// قائمة الفئات
  final List<HomeCategoryItem> items;

  /// Callback عند الضغط على فئة
  final ValueChanged<HomeCategoryItem> onTap;

  /// إظهار/إخفاء عدّاد المنتجات
  final bool showCount;

  /// المسافة بين البطاقات
  final double spacing;

  /// نسبة الكرت (عرض/ارتفاع)
  final double itemAspectRatio;

  /// الحد الأعلى للأعمدة (للتابلت مثلاً)
  final int maxCrossAxisCount;

  const CategoryGrid({
    super.key,
    required this.items,
    required this.onTap,
    this.showCount = true,
    this.spacing = 12,
    this.itemAspectRatio = 1.15,
    this.maxCrossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    // حماية: لو القائمة فاضية لا نعرض شيء
    if (items.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, c) {
        /// ✅ Responsive Columns
        ///
        /// - شاشة صغيرة (موبايل): 2 أعمدة
        /// - شاشة متوسطة: 3 أعمدة
        /// - شاشة كبيرة/تابلت: 4 أعمدة
        ///
        /// ثم نطبّق clamp حتى لا نتجاوز maxCrossAxisCount
        final w = c.maxWidth;

        int crossAxisCount = 2;
        if (w >= 760) {
          crossAxisCount = 4;
        } else if (w >= 520) {
          crossAxisCount = 3;
        }
        crossAxisCount = crossAxisCount.clamp(2, maxCrossAxisCount);

        return GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,

          // لأن الصفحة الأساسية هي التي تسكرول (SingleChildScrollView مثلاً)
          physics: const NeverScrollableScrollPhysics(),

          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: itemAspectRatio,
          ),
          itemBuilder: (_, i) {
            final item = items[i];

            return _CategoryCard(
              item: item,
              onTap: () => onTap(item),
              showCount: showCount,

              // نمرر index لعمل دخول تدريجي (stagger)
              index: i,
            );
          },
        );
      },
    );
  }
}

/// ✅ _CategoryCard (Private Widget)
///
/// بطاقة واحدة للفئة.
/// فيها micro-interactions:
/// - Scale بسيط عند الضغط (Premium)
/// - ظل يتغير بسلاسة (بدون glow مزعج)
/// - Fade/Slide دخول خفيف (Stagger)
class _CategoryCard extends StatefulWidget {
  final HomeCategoryItem item;
  final VoidCallback onTap;
  final bool showCount;

  /// ترتيب العنصر داخل الـ grid (للتأخير البسيط في الأنيميشن)
  final int index;

  const _CategoryCard({
    required this.item,
    required this.onTap,
    required this.showCount,
    required this.index,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);

    /// ✅ دخول تدريجي (Fade + Slide)
    /// نخلي التأخير بسيط ومحدود عشان ما يصير مزعج أو ثقيل
    final delay = (widget.index.clamp(0, 8)) * 40;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        // Slide للأعلى بسيط جدًا + Fade
        final dy = (1 - t) * 10;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, dy),
            child: child,
          ),
        );
      },

      child: AnimatedScale(
        // Scale خفيف عند الضغط
        scale: _pressed ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,

        child: InkWell(
          borderRadius: radius,
          onTap: widget.onTap,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: context.card.withOpacity(context.isDark ? 0.92 : 0.98),
              borderRadius: radius,

              // Border يتغير بشكل بسيط عند الضغط
              border: Border.all(
                color: context.border.withOpacity(_pressed ? 0.85 : 0.65),
              ),

              // ✅ Shadow هادي + يتغير مع الضغط
              // - بالدارك: opacity أقل حتى لا يعمل Glow
              boxShadow: [
                BoxShadow(
                  color: context.shadow.withOpacity(
                    context.isDark
                        ? (_pressed ? 0.10 : 0.14)
                        : (_pressed ? 0.06 : 0.08),
                  ),
                  blurRadius: _pressed ? 10 : 12,
                  offset: Offset(0, _pressed ? 6 : 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),

            child: Column(
              children: [
                // ✅ شبكة الصور 2x2
                Expanded(
                  child: _MiniImageGrid(imageUrls: widget.item.imageUrls),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    // اسم الفئة
                    Expanded(
                      child: Text(
                        widget.item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.foreground,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    // عداد المنتجات (اختياري)
                    if (widget.showCount) _CountChip(count: widget.item.count),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ✅ _MiniImageGrid
///
/// يعرض 4 صور كـ 2x2 داخل بطاقة الفئة.
/// - بدون GridView داخلي (أفضل أداء + أقل مشاكل قياس)
/// - يدعم Loading + Error
/// - لو الصور أقل من 4: يملأ placeholders
class _MiniImageGrid extends StatelessWidget {
  final List<String> imageUrls;
  const _MiniImageGrid({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    final urls = imageUrls.take(4).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: LayoutBuilder(
        builder: (context, c) {
          final size = c.biggest;

          // spacing بين الصور داخل الشبكة
          const innerGap = 6.0;

          // أبعاد كل صورة داخل الشبكة (2x2)
          final halfW = (size.width - innerGap) / 2;
          final halfH = (size.height - innerGap) / 2;

          /// صندوق صورة واحد (مع placeholder)
          Widget box(String? url) {
            return Container(
              width: halfW,
              height: halfH,
              color: context.input,
              child: url == null
                  ? Icon(
                      Icons.image_outlined,
                      color: context.mutedForeground,
                      size: 18,
                    )
                  : Image.network(
                      url,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,

                      // Loading indicator خفيف
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(context.primary),
                            ),
                          ),
                        );
                      },

                      // Error fallback
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: context.mutedForeground,
                          size: 18,
                        ),
                      ),
                    ),
            );
          }

          // ✅ لو أقل من 4 صور: نملأ الباقي بـ placeholders
          final u1 = urls.isNotEmpty ? urls[0] : null;
          final u2 = urls.length > 1 ? urls[1] : null;
          final u3 = urls.length > 2 ? urls[2] : null;
          final u4 = urls.length > 3 ? urls[3] : null;

          // Wrap يصنع شكل Grid 2x2 بدون Scroll/قيود إضافية
          return Wrap(
            spacing: innerGap,
            runSpacing: innerGap,
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(5), child: box(u1)),
              ClipRRect(borderRadius: BorderRadius.circular(5), child: box(u2)),
              ClipRRect(borderRadius: BorderRadius.circular(5), child: box(u3)),
              ClipRRect(borderRadius: BorderRadius.circular(5), child: box(u4)),
            ],
          );
        },
      ),
    );
  }
}

/// ✅ _CountChip
///
/// كبسولة صغيرة لعرض عدد العناصر داخل الفئة.
/// تصميمها هادي ومتناسق مع ألوانك (accent/border).
class _CountChip extends StatelessWidget {
  final int count;
  const _CountChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.accent.withOpacity(context.isDark ? 0.30 : 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.border.withOpacity(0.55)),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: context.foreground,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}
