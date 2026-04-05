import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class ProductRatingBadge extends StatelessWidget {
  final double fontSize;

  const ProductRatingBadge({
    super.key,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          size: 13,
          color: context.success,
        ),
        const SizedBox(width: 2),
        Text(
          '4.8',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: context.success,
            height: 1,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          '4.2k',
          style: TextStyle(
            fontSize: fontSize - 0.4,
            fontWeight: FontWeight.w700,
            color: context.success.withOpacity(.8),
            height: 1,
          ),
        ),
      ],
    );
  }
}