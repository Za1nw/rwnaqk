import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class AppNoInternetState extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String buttonText;
  final VoidCallback? onRetry;
  final bool expanded;

  const AppNoInternetState({
    super.key,
    this.title,
    this.subtitle,
    this.buttonText = 'Try Again',
    this.onRetry,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.border.withOpacity(0.35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 42,
                color: context.destructive,
              ),
              const SizedBox(height: 14),
              Text(
                title ?? 'No Internet Connection',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.foreground,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle ?? 'Please check your connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.mutedForeground,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: context.primary,
                      foregroundColor: context.primaryForeground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (expanded) return SizedBox(height: 360, child: content);
    return content;
  }
}