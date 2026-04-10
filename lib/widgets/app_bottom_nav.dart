import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_NavSpec>[
      _NavSpec(icon: Icons.home_rounded, label: Tk.navHome.tr),
      _NavSpec(icon: Icons.favorite_rounded, label: Tk.navWishlist.tr),
      _NavSpec(icon: Icons.receipt_rounded, label: Tk.navOrders.tr),
      _NavSpec(icon: Icons.shopping_bag_rounded, label: Tk.navShop.tr),
      _NavSpec(icon: Icons.person_rounded, label: Tk.navAccount.tr),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: context.shadow.withOpacity(.10),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 68,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: context.card,
                border: Border.all(color: context.border.withOpacity(.28)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.card,
                    Color.lerp(context.card, context.background, .18)!,
                  ],
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final segmentWidth = constraints.maxWidth / items.length;
                  final showActiveLabel = segmentWidth >= 88;
                  final indicatorX = _indicatorAlignment(
                    context,
                    count: items.length,
                    index: currentIndex,
                  );

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Animated highlight under the active segment
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment(indicatorX, 0),
                          child: IgnorePointer(
                            child: Container(
                              width: segmentWidth - 4,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: context.primary.withOpacity(.14),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: context.primary.withOpacity(.16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.primary.withOpacity(.10),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (var i = 0; i < items.length; i++)
                            Expanded(
                              child: _NavSegment(
                                icon: items[i].icon,
                                label: items[i].label,
                                selected: currentIndex == i,
                                showLabel: showActiveLabel,
                                onTap: () => onChanged(i),
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
    );
  }

  double _indicatorAlignment(
    BuildContext context, {
    required int count,
    required int index,
  }) {
    if (count <= 1) return 0;

    final safeIndex = index.clamp(0, count - 1);

    final step = 2 / (count - 1);
    final textDirection = Directionality.of(context);

    if (textDirection == TextDirection.rtl) {
      return 1 - (safeIndex * step);
    }

    return -1 + (safeIndex * step);
  }
}

class _NavSpec {
  final IconData icon;
  final String label;

  const _NavSpec({
    required this.icon,
    required this.label,
  });
}

class _NavSegment extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool showLabel;
  final VoidCallback onTap;

  const _NavSegment({
    required this.icon,
    required this.label,
    required this.selected,
    required this.showLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeFg = context.primary;
    final inactiveFg = context.mutedForeground;
    const duration = Duration(milliseconds: 180);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        splashColor: context.primary.withOpacity(.08),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: selected ? 1 : 0),
              duration: duration,
              curve: Curves.easeOutCubic,
              builder: (context, t, child) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: selected ? 6 : 2,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.scale(
                        scale: .94 + (.06 * t),
                        child: Icon(
                          icon,
                          size: 20,
                          color: Color.lerp(inactiveFg, activeFg, t),
                        ),
                      ),
                      if (showLabel)
                        ClipRect(
                          child: Align(
                            widthFactor: t,
                            child: Opacity(
                              opacity: t,
                              child: Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(start: 6),
                                child: SizedBox(
                                  width: 44,
                                  child: Text(
                                    label,
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    style: TextStyle(
                                      color: activeFg,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -.1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}