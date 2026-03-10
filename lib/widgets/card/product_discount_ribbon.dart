import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class ProductDiscountRibbon extends StatelessWidget {
  final String text;

  const ProductDiscountRibbon({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.28,
      child: ClipPath(
        clipper: _DiscountRibbonClipper(),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 6, 12, 6),
          decoration: BoxDecoration(
            color: context.destructive,
            boxShadow: [
              BoxShadow(
                color: context.shadow.withOpacity(.18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              color: context.primaryForeground,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: .2,
            ),
          ),
        ),
      ),
    );
  }
}

class _DiscountRibbonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, size.height * 0.5);
    path.lineTo(8, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(8, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}