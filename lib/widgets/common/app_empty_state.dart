import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

/// حالة فارغة موحّدة للاستخدام في الشاشات التي تعرض نتائج/قوائم.
class AppEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final EdgeInsetsGeometry padding;

  const AppEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.search_off_rounded,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: context.card.withOpacity(context.isDark ? 0.7 : 1.0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border.withOpacity(0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: context.mutedForeground),
            const SizedBox(height: 10),
            Text(
              title.tr,
              style: TextStyle(
                color: context.foreground,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
