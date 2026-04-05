import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class AppPageLoading extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final bool expanded;
  final double? height; // إضافة خاصية التحكم بالارتفاع
  final Widget? customIndicator; // إمكانية استخدام مؤشر تحميل مخصص

  const AppPageLoading({
    super.key,
    this.title,
    this.subtitle,
    this.expanded = true,
    this.height,
    this.customIndicator,
  });

  /// مؤشر تحميل افتراضي للمتجر
  static Widget get defaultIndicator => SizedBox(
        width: 34,
        height: 34,
        child: CircularProgressIndicator(
          strokeWidth: 2.8,
          valueColor: AlwaysStoppedAnimation<Color>(Get.context!.primary),
        ),
      );

  /// مؤشر تحميل للبطاقات (Product Cards)
  static Widget get productCardIndicator => SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Get.context!.primary),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final indicator = customIndicator ?? defaultIndicator;

    final content = Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            indicator,
            if (title != null) ...[
              const SizedBox(height: 16),
              Text(
                title!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.foreground,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.mutedForeground,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (expanded) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: height ?? 320, // استخدام الارتفاع المخصص أو الافتراضي
          child: content,
        ),
      );
    }
    
    return content;
  }
}

// إضافة Extension Methods للاستخدام السهل
extension AppPageLoadingExtension on Widget {
  /// تحويل أي Widget إلى حالة تحميل
  Widget withLoading({
    required bool isLoading,
    String? loadingTitle,
    String? loadingSubtitle,
    Widget? loadingIndicator,
  }) {
    if (!isLoading) return this;
    
    return Stack(
      children: [
        // تعتيم المحتوى الأصلي
        Opacity(
          opacity: 0.3,
          child: AbsorbPointer(
            child: this,
          ),
        ),
        // مؤشر التحميل
        Center(
          child: AppPageLoading(
            title: loadingTitle,
            subtitle: loadingSubtitle,
            expanded: false,
            customIndicator: loadingIndicator,
          ),
        ),
      ],
    );
  }
}