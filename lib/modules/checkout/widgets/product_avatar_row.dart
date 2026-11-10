import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

class ProductAvatarRow extends StatelessWidget {
  final List<HomeProductItem> items;
  final ValueChanged<HomeProductItem> onTap;
  final Map<int, Color> customRingByIndex;
  final double outerSize;
  final double ringThickness;
  final double spacing;

  const ProductAvatarRow({
    super.key,
    required this.items,
    required this.onTap,
    this.customRingByIndex = const {},
    this.outerSize = 62,
    this.ringThickness = 2.2,
    this.spacing = 14,
  });

  @override
  Widget build(BuildContext context) {
    final innerSize = outerSize - (ringThickness * 2);

    return SizedBox(
      height: outerSize + 30,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, _) => SizedBox(width: spacing),
        itemBuilder: (_, i) {
          final p = items[i];

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onTap(p),
            child: SizedBox(
              width: outerSize + 8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: outerSize,
                    height: outerSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: BrandGradients.royalBurgundy,
                      boxShadow: [
                        BoxShadow(
                          color: BrandColors.burgundy.withValues(
                            alpha: context.isDark ? 0.28 : 0.14,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(ringThickness),
                    child: Container(
                      width: innerSize,
                      height: innerSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.card,
                        border: Border.all(
                          color: context.background,
                          width: 1.5,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        p.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) {
                          return Center(
                            child: Icon(
                              Icons.star_rounded,
                              size: 20,
                              color: BrandColors.gold,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.title.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.foreground,
                      fontFamily: 'Cairo',
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
