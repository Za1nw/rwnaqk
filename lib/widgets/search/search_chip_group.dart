import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class SearchChipGroup extends StatelessWidget {
  final List<String> items;
  final ValueChanged<String> onTap;

  const SearchChipGroup({
    super.key,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((t) {
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onTap(t),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: context.input.withOpacity(context.isDark ? 0.65 : 1.0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.border.withOpacity(0.35),
              ),
            ),
            child: Text(
              t,
              style: TextStyle(
                color: context.foreground,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}