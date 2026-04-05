import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

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
  });

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
              color: context.mutedForeground.withOpacity(0.8),
            ),
      );
    }

    final imageWidget = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      color: color,
      colorBlendMode: colorBlendMode,
      filterQuality: filterQuality,
      errorBuilder: (_, __, ___) => buildError(),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return buildPlaceholder();
      },
    );

    if (borderRadius == null) return imageWidget;

    return ClipRRect(
      borderRadius: borderRadius!,
      child: imageWidget,
    );
  }
}