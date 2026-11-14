import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/profile_avatar.dart';

/// شريط التنقل السفلي الفاخر مع مؤشر انسيابي متحرك وحركات نبض حركية
/// (Boutique Luxury Animated Floating Bottom Nav)
///
/// صمم وفق أعلى معايير المتاجر الفاخرة العالمية (Farfetch, Ounass, Apple Store)
/// ويتميز بـ:
/// 1. **مؤشر كبسولي منزلق ناعم (Sliding Indicator Capsule)**:
///    ينزلق أفقياً بمرونة فيزيائية (`Curves.easeOutBack`) تحت التبويب النشط، متوافق كلياً مع RTL وLTR.
/// 2. **ارتداد وأناقة الأيقونة (Micro-Bounce Pop)**:
///    تكبير مرن عند التحديد (`scale: 0.76 -> 1.0`) وارتفاع طفيف للأعلى (-1.5px) لإعطاء إحساس ثلاثي الأبعاد.
/// 3. **انتقال سلس بين الأيقونات مزدوجة الحالة (Icon Morph Crossfade)**:
///    تلاشي وتدرج بصري ناعم بين الأيقونة المفرغة والممتلئة عبر `AnimatedSwitcher`.
/// 4. **نبض الشارة التفاعلي (Badge Scale Pulse)**:
///    شارة السلة والمفضلة تتفاعل وتقفز بلطف عند تغير عدد المنتجات.
/// 5. **تأثير الزجاج المعتم الفاخر (Frosted Glass)**:
///    ضبابية `ImageFilter.blur(sigma: 20)` لعكس خلفية محتوى المتجر بنعومة.
/// 6. **استجابة لمسية واضحة (Haptic Feedback)**:
///    اهتزاز دقيق `HapticFeedback.selectionClick()` عند كل انتقال.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final String profileName;
  final String profileAvatarPath;
  final String profileAvatarUrl;
  final int cartBadgeCount;
  final int wishlistBadgeCount;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    this.profileName = '',
    this.profileAvatarPath = '',
    this.profileAvatarUrl = '',
    this.cartBadgeCount = 0,
    this.wishlistBadgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = <_NavItemSpec>[
      _NavItemSpec(
        inactiveIcon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: Tk.navHome.tr, // 'الرئيسية'
      ),
      _NavItemSpec(
        inactiveIcon: Icons.favorite_outline_rounded,
        activeIcon: Icons.favorite_rounded,
        label: Tk.navWishlist.tr, // 'المفضلة'
        badgeCount: wishlistBadgeCount,
      ),
      _NavItemSpec(
        inactiveIcon: Icons.inventory_2_outlined,
        activeIcon: Icons.inventory_2_rounded,
        label: Tk.navOrders.tr, // 'طلباتي'
      ),
      _NavItemSpec(
        inactiveIcon: Icons.shopping_bag_outlined,
        activeIcon: Icons.shopping_bag_rounded,
        label: Tk.cartTitle.tr, // 'السلة'
        badgeCount: cartBadgeCount,
      ),
      _NavItemSpec(
        inactiveIcon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: Tk.navAccount.tr, // 'حسابي'
        useAvatar: true,
      ),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 68,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E0A17).withValues(alpha: 0.92)
                      : Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: isDark
                        ? BrandColors.gold.withValues(alpha: 0.22)
                        : BrandColors.burgundy.withValues(alpha: 0.12),
                    width: 1.2,
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final totalWidth = constraints.maxWidth;
                    final tabCount = items.length;
                    final tabWidth = totalWidth / tabCount;
                    // عرض وارتفاع كبسولة المؤشر المنزلق
                    final pillWidth = (tabWidth * 0.88).clamp(46.0, 58.0);
                    const pillHeight = 52.0;
                    final pillTop = (constraints.maxHeight - pillHeight) / 2;
                    final pillStart =
                        currentIndex * tabWidth + (tabWidth - pillWidth) / 2;

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // 1. مؤشر التبويب الانسيابي المنزلق (Gliding Indicator Pill)
                        AnimatedPositionedDirectional(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutBack,
                          start: pillStart,
                          top: pillTop,
                          width: pillWidth,
                          height: pillHeight,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: isDark
                                    ? [
                                        BrandColors.gold.withValues(
                                          alpha: 0.22,
                                        ),
                                        BrandColors.gold.withValues(
                                          alpha: 0.08,
                                        ),
                                      ]
                                    : [
                                        BrandColors.burgundy.withValues(
                                          alpha: 0.12,
                                        ),
                                        BrandColors.burgundy.withValues(
                                          alpha: 0.04,
                                        ),
                                      ],
                              ),
                              border: Border.all(
                                color: isDark
                                    ? BrandColors.gold.withValues(alpha: 0.35)
                                    : BrandColors.burgundy.withValues(
                                        alpha: 0.18,
                                      ),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (isDark
                                              ? BrandColors.gold
                                              : BrandColors.burgundy)
                                          .withValues(
                                            alpha: isDark ? 0.20 : 0.08,
                                          ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 2. صف التبويبات التفاعلية
                        Row(
                          children: [
                            for (int i = 0; i < tabCount; i++)
                              Expanded(
                                child: _NavTabButton(
                                  spec: items[i],
                                  isSelected: i == currentIndex,
                                  profileName: profileName,
                                  profileAvatarPath: profileAvatarPath,
                                  profileAvatarUrl: profileAvatarUrl,
                                  onTap: () {
                                    if (i != currentIndex) {
                                      HapticFeedback.selectionClick();
                                      onChanged(i);
                                    }
                                  },
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemSpec {
  final IconData inactiveIcon;
  final IconData activeIcon;
  final String label;
  final int badgeCount;
  final bool useAvatar;

  const _NavItemSpec({
    required this.inactiveIcon,
    required this.activeIcon,
    required this.label,
    this.badgeCount = 0,
    this.useAvatar = false,
  });
}

class _NavTabButton extends StatelessWidget {
  final _NavItemSpec spec;
  final bool isSelected;
  final String profileName;
  final String profileAvatarPath;
  final String profileAvatarUrl;
  final VoidCallback onTap;

  const _NavTabButton({
    required this.spec,
    required this.isSelected,
    required this.profileName,
    required this.profileAvatarPath,
    required this.profileAvatarUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? BrandColors.gold : BrandColors.burgundy;
    final inactiveColor = isDark
        ? AppColors.textSecondaryDark.withValues(alpha: 0.70)
        : const Color(0xFF8C7584);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: primaryColor.withValues(alpha: 0.12),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. حاوية الأيقونة مع حركة النبض والارتفاع المرن
              TweenAnimationBuilder<double>(
                key: ValueKey<bool>(isSelected),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                tween: Tween<double>(begin: isSelected ? 0.76 : 1.0, end: 1.0),
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  offset: Offset(0, isSelected ? -0.07 : 0.0),
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // الصورة الشخصية لحسابي أو الأيقونة
                      if (spec.useAvatar)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          width: isSelected ? 26 : 24,
                          height: isSelected ? 26 : 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : (isDark ? Colors.white24 : Colors.black12),
                              width: isSelected ? 2.0 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: primaryColor.withValues(
                                        alpha: isDark ? 0.35 : 0.20,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: ProfileAvatar(
                            name: profileName.isEmpty
                                ? spec.label
                                : profileName,
                            imagePath: profileAvatarPath,
                            imageUrl: profileAvatarUrl,
                            size: isSelected ? 26 : 24,
                            fontSize: 10.5,
                            backgroundColor: isDark
                                ? const Color(0xFF2E091E)
                                : const Color(0xFFFFF7FA),
                            textColor: isDark
                                ? BrandColors.gold
                                : BrandColors.burgundy,
                            showBorder: false,
                          ),
                        )
                      else
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Icon(
                            isSelected ? spec.activeIcon : spec.inactiveIcon,
                            key: ValueKey<bool>(isSelected),
                            size: 22,
                            color: isSelected ? primaryColor : inactiveColor,
                          ),
                        ),

                      // شارة عدد العناصر التفاعلية ذات النبض
                      if (spec.badgeCount > 0)
                        PositionedDirectional(
                          top: -4,
                          end: -6,
                          child: AnimatedScale(
                            scale: spec.badgeCount > 0 ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutBack,
                            child: TweenAnimationBuilder<double>(
                              key: ValueKey<int>(spec.badgeCount),
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeOutBack,
                              tween: Tween<double>(begin: 0.6, end: 1.0),
                              builder: (context, badgeScale, child) {
                                return Transform.scale(
                                  scale: badgeScale,
                                  child: child,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.5,
                                  vertical: 1.5,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE11D48),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF1E0A17)
                                        : Colors.white,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFE11D48)
                                          .withValues(alpha: 0.45),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  spec.badgeCount > 99
                                      ? '99+'
                                      : '${spec.badgeCount}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    fontFamily: 'Cairo',
                                    height: 1.1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 2),

              // 2. اسم التبويب الواضح مع انتقال الخط واللون
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                style: AppTextTheme.cairo(
                  fontSize: isSelected ? 10.5 : 10.0,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  color: isSelected ? primaryColor : inactiveColor,
                  letterSpacing: isSelected ? -0.1 : -0.2,
                  height: 1.15,
                ),
                child: Text(
                  spec.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
