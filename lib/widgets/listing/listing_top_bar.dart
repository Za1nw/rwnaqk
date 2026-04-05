import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/app_filter_button.dart';

class ListingTopBar extends StatelessWidget {
  final String title;
  final int filterCount;

  final VoidCallback onBack;
  final VoidCallback onSort;
  final VoidCallback onFilter;

  const ListingTopBar({
    super.key,
    required this.title,
    required this.filterCount,
    required this.onBack,
    required this.onSort,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: context.background,
      surfaceTintColor: context.background,

      leading: IconButton(
        onPressed: onBack,
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: context.foreground,
        ),
      ),

      title: Text(
        title,
        style: TextStyle(
          color: context.foreground,
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      ),

      actions: [
        IconButton(
          onPressed: onSort,
          icon: Icon(Icons.swap_vert_rounded, color: context.foreground),
        ),

        AppFilterButton(
          onTap: onFilter,
        ),

        const SizedBox(width: 6),
      ],
    );
  }
}