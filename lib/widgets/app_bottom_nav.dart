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
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.only(top: 4, bottom: 8),
        decoration: BoxDecoration(
          color: context.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  selected: currentIndex == 0,
                  label: Tk.navHome.tr,
                  onTap: () => onChanged(0),
                ),
                _NavItem(
                  icon: Icons.favorite_rounded,
                  selected: currentIndex == 1,
                  label: Tk.navWishlist.tr,
                  onTap: () => onChanged(1),
                ),
                _NavItem(
                  icon: Icons.receipt_rounded,
                  selected: currentIndex == 2,
                  label: Tk.navOrders.tr,
                  onTap: () => onChanged(2),
                ),
                _NavItem(
                  icon: Icons.shopping_bag_rounded,
                  selected: currentIndex == 3,
                  label: Tk.navShop.tr,
                  onTap: () => onChanged(3),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  selected: currentIndex == 4,
                  label: Tk.navAccount.tr,
                  onTap: () => onChanged(4),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              width: 120,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: context.primary.withOpacity(0.1),
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: selected
                      ? context.primary.withOpacity(0.1)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: selected
                      ? context.primary
                      : context.primary.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: selected ? 10 : 9,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected
                      ? context.primary
                      : context.primary.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
