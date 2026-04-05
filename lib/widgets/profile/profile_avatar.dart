import 'dart:io';

import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String name;
  final String? imagePath;
  final String? imageUrl;
  final double size;
  final double fontSize;
  final bool showBorder;

  const ProfileAvatar({
    super.key,
    required this.name,
    this.imagePath,
    this.imageUrl,
    this.size = 56,
    this.fontSize = 22,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final safePath = (imagePath ?? '').trim();
    final safeUrl = (imageUrl ?? '').trim();
    final hasFileImage = safePath.isNotEmpty;
    final hasNetworkImage = safeUrl.isNotEmpty;
    final hasImage = hasFileImage || hasNetworkImage;
    final initial = _displayInitial(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasImage
            ? null
            : LinearGradient(
                colors: [
                  context.primary.withOpacity(.22),
                  context.primary.withOpacity(.10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: hasImage ? context.input : null,
        border: showBorder
            ? Border.all(color: context.border.withOpacity(.35))
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasFileImage
          ? Image.file(
              File(safePath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _AvatarFallback(
                initial: initial,
                fontSize: fontSize,
              ),
            )
          : hasNetworkImage
              ? Image.network(
                  safeUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _AvatarFallback(
                    initial: initial,
                    fontSize: fontSize,
                  ),
                )
              : _AvatarFallback(
                  initial: initial,
                  fontSize: fontSize,
                ),
    );
  }

  String _displayInitial(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }
}

class _AvatarFallback extends StatelessWidget {
  final String initial;
  final double fontSize;

  const _AvatarFallback({
    required this.initial,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: context.primary,
          fontWeight: FontWeight.w900,
          fontSize: fontSize,
          height: 1,
        ),
      ),
    );
  }
}
