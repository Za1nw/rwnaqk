import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class RatingStarsInput extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int count;
  final double size;
  final double spacing;

  const RatingStarsInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.count = 5,
    this.size = 32,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      alignment: WrapAlignment.center,
      children: List.generate(count, (i) {
        final star = i + 1;
        final active = star <= value;

        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => onChanged(star),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(
              active ? Icons.star_rounded : Icons.star_border_rounded,
              size: size,
              color: active ? const Color(0xFFFFB800) : context.muted,
            ),
          ),
        );
      }),
    );
  }
}