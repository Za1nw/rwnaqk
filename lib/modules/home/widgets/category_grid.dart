import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_category_item.dart';

class CategoryGrid extends StatelessWidget {
  final List<HomeCategoryItem> items;
  final ValueChanged<HomeCategoryItem> onTap;
  final bool showCount;
  final double spacing;
  final double itemAspectRatio;
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

  IconData _categoryIcon(String nameKey) {
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
    if (lower.contains('lingerie')) {
      return Icons.favorite_rounded;
    }
    if (lower.contains('perfume') || lower.contains('عطور')) {
      return Icons.local_florist_rounded;
    }
    if (lower.contains('jewel') ||
        lower.contains('access') ||
        lower.contains('إكسسوار')) {
      return Icons.diamond_rounded;
    }
    return Icons.category_rounded;
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 98,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final item = items[i];
          final icon = _categoryIcon(item.name);

          return _CategoryPill(
            item: item,
            icon: icon,
            onTap: () => onTap(item),
            index: i,
          );
        },
      ),
    );
  }
}

class _CategoryPill extends StatefulWidget {
  final HomeCategoryItem item;
  final IconData icon;
  final VoidCallback onTap;
  final int index;

  const _CategoryPill({
    required this.item,
    required this.icon,
    required this.onTap,
    required this.index,
  });

  @override
  State<_CategoryPill> createState() => _CategoryPillState();
}

class _CategoryPillState extends State<_CategoryPill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isFirst = widget.index == 0;
    final primaryColor = context.primary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 140),
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular / Squircle Icon Card
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isFirst
                      ? BrandGradients.royalBurgundy
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            context.card,
                            context.card.withValues(alpha: 0.8),
                          ],
                        ),
                  border: Border.all(
                    color: isFirst
                        ? BrandColors.gold.withValues(alpha: 0.5)
                        : context.border.withValues(alpha: 0.45),
                    width: isFirst ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isFirst
                          ? BrandColors.burgundy.withValues(alpha: 0.25)
                          : context.shadow.withValues(
                              alpha: context.isDark ? 0.12 : 0.05,
                            ),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    size: 26,
                    color: isFirst ? Colors.white : primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Category Label
              Text(
                widget.item.name.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isFirst ? context.foreground : context.mutedForeground,
                  fontWeight: isFirst ? FontWeight.w900 : FontWeight.w700,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
