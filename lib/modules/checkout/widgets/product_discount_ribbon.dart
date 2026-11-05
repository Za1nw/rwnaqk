import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';

class ProductDiscountRibbon extends StatelessWidget {
  final String text;

  const ProductDiscountRibbon({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BrandColors.burgundy, Color(0xFF8E0542)],
        ),
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(10),
          bottomEnd: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: BrandColors.burgundy.withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          height: 1,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
