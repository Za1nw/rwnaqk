import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class OrderDetailsSectionCard extends StatelessWidget {
  final Widget child;

  const OrderDetailsSectionCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: context.border.withOpacity(.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: child,
      ),
    );
  }
}
