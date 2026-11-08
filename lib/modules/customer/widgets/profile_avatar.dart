import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';

class ProfileAvatar extends StatelessWidget {
  final String name;
  final String? imagePath;
  final String? imageUrl;
  final double size;
  final double fontSize;
  final bool showBorder;
  final Color? backgroundColor;
  final Color? textColor;

  const ProfileAvatar({
    super.key,
    required this.name,
    this.imagePath,
    this.imageUrl,
    this.size = 56,
    this.fontSize = 22,
    this.showBorder = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safePath = (imagePath ?? '').trim();
    final safeUrl = (imageUrl ?? '').trim();
    final hasFileImage = safePath.isNotEmpty;
    final hasNetworkImage = safeUrl.isNotEmpty;
    final hasImage = hasFileImage || hasNetworkImage;
    final initial = _displayInitial(name);

    final defaultBg =
        backgroundColor ??
        (isDark ? const Color(0xFF2E091E) : const Color(0xFFFFF7FA));
    final defaultFg =
        textColor ?? (isDark ? BrandColors.gold : BrandColors.burgundy);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasImage ? context.input : defaultBg,
        border: showBorder
            ? Border.all(
                color: BrandColors.gold.withValues(alpha: isDark ? 0.45 : 0.65),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: hasFileImage
          ? Image.file(
              File(safePath),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _AvatarFallback(
                initial: initial,
                fontSize: fontSize,
                color: defaultFg,
              ),
            )
          : hasNetworkImage
          ? Image.network(
              safeUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _AvatarFallback(
                initial: initial,
                fontSize: fontSize,
                color: defaultFg,
              ),
            )
          : _AvatarFallback(
              initial: initial,
              fontSize: fontSize,
              color: defaultFg,
            ),
    );
  }

  String _displayInitial(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'ر';
    return trimmed.characters.first.toUpperCase();
  }
}

class _AvatarFallback extends StatelessWidget {
  final String initial;
  final double fontSize;
  final Color color;

  const _AvatarFallback({
    required this.initial,
    required this.fontSize,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial,
        style: AppTextTheme.cairo(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: fontSize,
          height: 1,
        ),
      ),
    );
  }
}
