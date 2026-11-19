import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/services/cache/app_image_cache_manager.dart';
import 'package:rwnaqk_frontend/core/services/cache/app_image_storage_service.dart';
import 'package:rwnaqk_frontend/core/services/cache/image_cache_config.dart';

/// مكون موحد ومركزي لعرض الصور الشبكية مع كاش محلي محدد الحجم (100 MB) وتحسين استهلاك الذاكرة
class AppNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Alignment alignment;
  final Color? color;
  final BlendMode? colorBlendMode;
  final FilterQuality filterQuality;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Color? backgroundColor;

  /// تخصيص أبعاد فك التشفير في الذاكرة العشوائية يدوياً إن رغب المطور
  final int? memCacheWidth;
  final int? memCacheHeight;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.alignment = Alignment.center,
    this.color,
    this.colorBlendMode,
    this.filterQuality = FilterQuality.medium,
    this.loadingWidget,
    this.errorWidget,
    this.backgroundColor,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  /// حساب العرض المناسب لفك التشفير في الرام لتفادي استهلاك الذاكرة OOM مع مراعاة كثافة الشاشة الحقيقية
  int? _resolveMemCacheWidth(BuildContext context) {
    if (memCacheWidth != null) return memCacheWidth;
    if (width != null && width! > 0) {
      final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
      final calculated = (width! * dpr).round();
      return calculated.clamp(100, ImageCacheConfig.defaultMaxMemCacheWidth);
    }
    return ImageCacheConfig.defaultMaxMemCacheWidth;
  }

  /// حساب الارتفاع المناسب لفك التشفير في الرام
  int? _resolveMemCacheHeight(BuildContext context) {
    if (memCacheHeight != null) return memCacheHeight;
    if (height != null && height! > 0) {
      final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
      final calculated = (height! * dpr).round();
      return calculated.clamp(100, ImageCacheConfig.defaultMaxMemCacheWidth);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? context.card;

    Widget buildPlaceholder() {
      return Container(
        width: width,
        height: height,
        color: bgColor,
        alignment: Alignment.center,
        child: loadingWidget ??
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(context.primary),
              ),
            ),
      );
    }

    Widget buildError() {
      return Container(
        width: width,
        height: height,
        color: bgColor,
        alignment: Alignment.center,
        child: errorWidget ??
            Icon(
              Icons.image_not_supported_outlined,
              size: 22,
              color: context.mutedForeground.withValues(alpha: 0.8),
            ),
      );
    }

    var resolvedUrl = url.trim();
    if (resolvedUrl.contains('format=svg')) {
      resolvedUrl = resolvedUrl.replaceAll('format=svg', 'format=png');
    }

    if (resolvedUrl.isEmpty || resolvedUrl.toLowerCase().endsWith('.svg')) {
      return buildError();
    }

    // صيانة كاش الصور في الخلفية مع كبح زمني وفحص سريع لسقف المساحة
    unawaited(AppImageStorageService.instance.runMaintenanceIfNeeded());
    unawaited(AppImageStorageService.instance.checkAndEvictIfOverLimit());

    final imageWidget = CachedNetworkImage(
      imageUrl: resolvedUrl,
      cacheManager: AppImageCacheManager.instance,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      color: color,
      colorBlendMode: colorBlendMode,
      filterQuality: filterQuality,
      memCacheWidth: _resolveMemCacheWidth(context),
      memCacheHeight: _resolveMemCacheHeight(context),
      maxWidthDiskCache: 1440,
      maxHeightDiskCache: 1440,
      placeholder: (_, _) => buildPlaceholder(),
      errorWidget: (_, _, _) => buildError(),
    );

    if (borderRadius == null) return imageWidget;

    return ClipRRect(
      borderRadius: borderRadius!,
      child: imageWidget,
    );
  }
}
