import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_section_header.dart';
import 'package:rwnaqk_frontend/modules/home/controllers/home_controller.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_category_item.dart';

class CuratedCollectionsGrid extends GetView<HomeController> {
  const CuratedCollectionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'المجموعات والأقسام المميزة',
          actionText: 'عرض الكل',
          onActionTap: controller.onSeeAllCategories,
        ),
        const SizedBox(height: 12),
        Obx(() {
          final items = controller.categories.toList();
          if (items.isEmpty) return const SizedBox.shrink();

          return LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final crossAxisCount = w >= 600 ? 4 : 2;
              final aspectRatio = crossAxisCount == 2 ? 1.35 : 1.25;

              // Take up to 4 featured collections
              final displayItems = items.take(4).toList();

              return GridView.builder(
                itemCount: displayItems.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: aspectRatio,
                ),
                itemBuilder: (context, i) {
                  return _CollectionCard(
                    item: displayItems[i],
                    index: i,
                    onTap: () => controller.openCategory(displayItems[i]),
                  );
                },
              );
            },
          );
        }),
      ],
    );
  }
}

class _CollectionCard extends StatefulWidget {
  final HomeCategoryItem item;
  final int index;
  final VoidCallback onTap;

  const _CollectionCard({
    required this.item,
    required this.index,
    required this.onTap,
  });

  @override
  State<_CollectionCard> createState() => _CollectionCardState();
}

class _CollectionCardState extends State<_CollectionCard> {
  bool _pressed = false;

  IconData _iconForCategory(String nameKey) {
    final lower = nameKey.toLowerCase();
    if (lower.contains('cloth') || lower.contains('ملابس')) {
      return Icons.checkroom_rounded;
    }
    if (lower.contains('shoe') || lower.contains('أحذية')) {
      return Icons.hiking_rounded;
    }
    if (lower.contains('bag') || lower.contains('حقائب')) {
      return Icons.shopping_bag_rounded;
    }
    if (lower.contains('lingerie') || lower.contains('داخلية')) {
      return Icons.auto_awesome_rounded;
    }
    if (lower.contains('perfume') || lower.contains('عطور')) {
      return Icons.local_florist_rounded;
    }
    return Icons.diamond_rounded;
  }

  String _badgeForIndex(int index) {
    switch (index) {
      case 0:
        return 'الأكثر رواجاً';
      case 1:
        return 'تشكيلة جديدة';
      case 2:
        return 'بريميوم';
      default:
        return 'مميز';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final icon = _iconForCategory(widget.item.name);
    final badge = _badgeForIndex(widget.index);

    // Dynamic luxury gradients by index
    final List<Color> cardGradient;
    final Color accentColor;

    switch (widget.index % 4) {
      case 0:
        cardGradient = isDark
            ? [const Color(0xFF450320), const Color(0xFF280112)]
            : [const Color(0xFFFFF0F5), const Color(0xFFFDE1EB)];
        accentColor = BrandColors.burgundy;
        break;
      case 1:
        cardGradient = isDark
            ? [const Color(0xFF33230A), const Color(0xFF1E1405)]
            : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)];
        accentColor = BrandColors.gold;
        break;
      case 2:
        cardGradient = isDark
            ? [const Color(0xFF22112C), const Color(0xFF140A1A)]
            : [const Color(0xFFFBF4FF), const Color(0xFFF3E4FC)];
        accentColor = const Color(0xFF9333EA);
        break;
      default:
        cardGradient = isDark
            ? [const Color(0xFF11222C), const Color(0xFF09141A)]
            : [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)];
        accentColor = const Color(0xFF16A34A);
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 140),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: cardGradient,
            ),
            border: Border.all(
              color: accentColor.withValues(alpha: isDark ? 0.35 : 0.45),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: isDark ? 0.16 : 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Decorative luxury circle
                PositionedDirectional(
                  end: -18,
                  bottom: -18,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withValues(
                        alpha: isDark ? 0.10 : 0.12,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Icon + Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accentColor.withValues(
                                alpha: isDark ? 0.22 : 0.14,
                              ),
                              border: Border.all(
                                color: accentColor.withValues(
                                  alpha: isDark ? 0.40 : 0.30,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Icon(icon, size: 19, color: accentColor),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(
                                alpha: isDark ? 0.25 : 0.15,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                color: isDark ? Colors.white : accentColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Cairo',
                                height: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Bottom: Title + Count + Action
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.name.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? Colors.white : context.foreground,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              fontFamily: 'Cairo',
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                '${widget.item.count} منتج',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.70)
                                      : context.mutedForeground,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Cairo',
                                  height: 1.0,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Directionality.of(context) == TextDirection.rtl
                                    ? Icons.arrow_back_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 13,
                                color: accentColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
