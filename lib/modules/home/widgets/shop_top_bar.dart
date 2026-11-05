import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';

class ShopTopBar extends StatelessWidget {
  final String title;
  final String searchHint;

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  final VoidCallback? onCamera;
  final VoidCallback? onTapField;
  final EdgeInsetsGeometry padding;

  /// Enable full store brand header (Logo + Location + Notifications/Cart)
  final bool showBrandHeader;
  final String? locationText;
  final VoidCallback? onLocationTap;
  final VoidCallback? onNotifications;
  final int unreadNotificationsCount;
  final VoidCallback? onCart;
  final int cartCount;

  const ShopTopBar({
    super.key,
    required this.title,
    required this.searchHint,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onCamera,
    this.onTapField,
    this.padding = EdgeInsets.zero,
    this.showBrandHeader = false,
    this.locationText,
    this.onLocationTap,
    this.onNotifications,
    this.unreadNotificationsCount = 0,
    this.onCart,
    this.cartCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (!showBrandHeader) {
      return Padding(
        padding: padding,
        child: SizedBox(
          height: 44,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: context.foreground,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Cairo',
                  height: 1.0,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SearchPill(
                  controller: controller,
                  hint: searchHint,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  onCamera: onCamera,
                  onTapField: onTapField,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Full Standard E-Commerce Store Top Header
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Brand & Actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Store Brand Identity & Location
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'رَوْنَقُك',
                        style: TextStyle(
                          color: context.primary,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Cairo',
                          height: 1.0,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: BrandColors.gold.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: BrandColors.gold.withValues(alpha: 0.45),
                            width: 0.8,
                          ),
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(
                            color: BrandColors.gold,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (locationText != null && locationText!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: onLocationTap,
                      borderRadius: BorderRadius.circular(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: context.mutedForeground,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            locationText!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: context.mutedForeground,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 14,
                            color: context.mutedForeground,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              const Spacer(),

              // Notifications Action
              if (onNotifications != null)
                _HeaderIconButton(
                  icon: Icons.notifications_none_rounded,
                  onTap: onNotifications!,
                  badgeCount: unreadNotificationsCount,
                ),

              if (onCart != null) ...[
                const SizedBox(width: 8),
                _HeaderIconButton(
                  icon: Icons.shopping_bag_outlined,
                  onTap: onCart!,
                  badgeCount: cartCount,
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // Row 2: Search Pill (Sleek full pill design)
          _SearchPill(
            controller: controller,
            hint: searchHint,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            onCamera: onCamera,
            onTapField: onTapField,
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.border.withValues(alpha: 0.40)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 20, color: context.foreground),
              if (badgeCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: BrandColors.burgundy,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  final VoidCallback? onCamera;
  final VoidCallback? onTapField;

  const _SearchPill({
    required this.controller,
    required this.hint,
    this.onChanged,
    this.onSubmitted,
    this.onCamera,
    this.onTapField,
  });

  @override
  Widget build(BuildContext context) {
    final fieldColor = context.isDark
        ? context.card.withValues(alpha: 0.6)
        : const Color(0xFFF6F7F9);

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: context.isDark
              ? context.border.withValues(alpha: 0.35)
              : context.border.withValues(alpha: 0.45),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsetsDirectional.only(start: 14, end: 8),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 20,
            color: context.primary.withValues(alpha: 0.85),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTapField,
              child: AbsorbPointer(
                absorbing: onTapField != null,
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  textAlign: TextAlign.start,
                  cursorColor: context.primary,
                  textInputAction: TextInputAction.search,
                  style: TextStyle(
                    color: context.foreground,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: context.mutedForeground.withValues(alpha: 0.65),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Cairo',
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
          ),
          if (onCamera != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onCamera,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.photo_camera_outlined,
                    size: 19,
                    color: context.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
