import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';

class MiniItemPriceTile extends StatelessWidget {
  final String imageUrl;
  final int badgeCount;
  final String title;
  final String subtitle;
  final String priceText;
  final VoidCallback? onTap;

  final double radius;
  final double imageSize;

  const MiniItemPriceTile({
    super.key,
    required this.imageUrl,
    required this.badgeCount,
    required this.title,
    required this.subtitle,
    required this.priceText,
    this.onTap,
    this.radius = 14,
    this.imageSize = 44,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final compact = c.maxWidth < 360;

        final img = compact ? imageSize - 4 : imageSize;
        final titleSize = compact ? 12.5 : 13.5;
        final subSize = compact ? 11.5 : 12.5;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 6, 6),
              child: Row(
                children: [
                  // الصورة + البادج
                  _AvatarWithBadge(
                    imageUrl: imageUrl,
                    badgeCount: badgeCount,
                    size: img,
                  ),

                  const SizedBox(width: 10),

                  // النصوص
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.foreground,
                            fontWeight: FontWeight.w800,
                            fontSize: titleSize,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.mutedForeground,
                            fontWeight: FontWeight.w600,
                            fontSize: subSize,
                            height: 1.05,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // السعر
                  Text(
                    priceText,
                    style: TextStyle(
                      color: context.foreground,
                      fontWeight: FontWeight.w900,
                      fontSize: compact ? 13 : 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AvatarWithBadge extends StatelessWidget {
  final String imageUrl;
  final int badgeCount;
  final double size;

  const _AvatarWithBadge({
    required this.imageUrl,
    required this.badgeCount,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final showBadge = badgeCount > 0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Avatar circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: context.border.withValues(alpha: .35),
                width: 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: context.muted.withValues(
                  alpha: context.isDark ? .25 : .5,
                ),
                child: Icon(
                  Icons.image_outlined,
                  color: context.mutedForeground,
                  size: size * .5,
                ),
              ),
            ),
          ),

          // Badge
          if (showBadge)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: context.card,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: context.border.withValues(alpha: .45),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.shadow.withValues(alpha: .08),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    color: context.foreground,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    height: 1.0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
