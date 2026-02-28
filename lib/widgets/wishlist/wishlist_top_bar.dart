import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/controllers/wishlist_controller.dart';

class WishlistTopBar extends StatelessWidget {
  final String title;
  const WishlistTopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<WishlistController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Get.back(),
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.foreground),
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                color: context.foreground,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1.0,
              ),
            ),
            const Spacer(),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: context.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.add, color: context.primaryForeground, size: 18),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Obx(() {
          final idx = c.tabIndex.value;
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
                  text: 'Wishlist',
                  selected: idx == 0,
                  onTap: () => c.setTab(0),
                ),
                _TabPill(
                  text: 'Recently viewed',
                  selected: idx == 1,
                  onTap: () => c.setTab(1),
                ),
              ],
            ),
          );
        }),
      ],
    );
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? context.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: selected ? context.primaryForeground : context.mutedForeground,
              fontWeight: FontWeight.w900,
              fontSize: 12.8,
            ),
          ),
        ),
      ),
    );
  }
}