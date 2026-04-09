import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/wishlist/wishlist_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';

class WishlistTabs extends GetView<WishlistController> {
  const WishlistTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final idx = controller.tabIndex.value;

      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: context.border.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            _TabPill(
              text: Tk.wishlistTitle.tr,
              selected: idx == 0,
              onTap: () => controller.setTab(0),
            ),
            _TabPill(
              text: Tk.wishlistRecentlyViewed.tr,
              selected: idx == 1,
              onTap: () => controller.setTab(1),
            ),
          ],
        ),
      );
    });
  }
}

class _TabPill extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _TabPill({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedPhysicalModel(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(999),
        elevation: selected ? 4 : 0,
        color: selected ? context.primary : Colors.transparent,
        shadowColor: context.primary.withOpacity(0.3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          splashColor: context.primaryForeground.withOpacity(0.3),
          highlightColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                color: selected
                    ? context.primaryForeground
                    : context.mutedForeground,
                fontWeight: FontWeight.w900,
                fontSize: 12.8,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
