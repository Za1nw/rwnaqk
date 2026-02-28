import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class AppShareButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;
  final bool filled; // لو تبغى نسخة ممتلئة بدل الشفافة

  const AppShareButton({
    super.key,
    required this.onTap,
    this.size = 44,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);

    return Material(
      color: filled
          ? context.primary
          : context.primary.withOpacity(.10),

      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: filled
            ? BorderSide.none
            : BorderSide(
                color: context.primary.withOpacity(.35),
              ),
      ),

      clipBehavior: Clip.antiAlias,

      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(
              Icons.ios_share_rounded, // أجمل أيقونة مشاركة
              size: size * .50,
              color: filled
                  ? context.accentForeground
                  : context.primary,
            ),
          ),
        ),
      ),
    );
  }
}