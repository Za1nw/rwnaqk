import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/app_button.dart';

/// حالة فارغة موحّدة للاستخدام في الشاشات التي تعرض نتائج/قوائم.
class AppEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final EdgeInsetsGeometry padding;
  final String? lottieAsset;
  final double animationSize;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const AppEmptyState({
    super.key,
    required this.title,
    this.subtitle = '',
    this.icon = Icons.search_off_rounded,
    this.padding =  EdgeInsets. zero,
    this.lottieAsset,
    this.animationSize = 240,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedSubtitle = subtitle.tr.trim();
    final showButton =
        buttonText != null &&
        buttonText!.trim().isNotEmpty &&
        onButtonPressed != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (lottieAsset != null && lottieAsset!.trim().isNotEmpty)
              SizedBox(
                width: 240,
                height: 240,
                child: Lottie.asset(
                  lottieAsset!,
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              )
            else
              Icon(
                icon,
                size: 90,
                color: context.primary.withValues(alpha: .85),
              ),

            const SizedBox(height: 18),

            Text(
              title.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: context.foreground,
                letterSpacing: -.4,
              ),
            ),

            if (resolvedSubtitle.isNotEmpty) ...[
              const SizedBox(height: 10),

              Text(
                resolvedSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.7,
                  fontWeight: FontWeight.w500,
                  color: context.mutedForeground,
                ),
              ),
            ],

            if (showButton) ...[
              const SizedBox(height: 28),

              SizedBox(
                width: 210,
                child: AppButton(
                  text: buttonText!.tr,
                  onPressed: onButtonPressed,
                  height: 50,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
