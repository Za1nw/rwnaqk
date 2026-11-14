import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/constants/app_env.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';

/// أفاتار الحساب الملكي الموحد مع احتواء متكامل وحرف أحادي ناصع
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
    var safeUrl = (imageUrl ?? '').trim();

    if (safeUrl.contains('format=svg')) {
      safeUrl = safeUrl.replaceAll('format=svg', 'format=png');
    }
    if (AppEnv.apiBaseUrl.contains('10.0.2.2')) {
      safeUrl = safeUrl
          .replaceFirst('http://localhost:8000', 'http://10.0.2.2:8000')
          .replaceFirst('http://127.0.0.1:8000', 'http://10.0.2.2:8000');
    }

    final isSvg = safeUrl.toLowerCase().endsWith('.svg');
    final hasFileImage = safePath.isNotEmpty;
    final isUiAvatar = safeUrl.contains('ui-avatars.com');

    // إذا كان الرابط هو ui-avatars أو غير موجود، نفضل الرندر المحلي الفوري عالي الدقة بحرف واحد فقط
    final hasRealNetworkImage = safeUrl.isNotEmpty && !isSvg && !isUiAvatar;
    final initial = _displayInitial(name);

    final avatarBg = backgroundColor ??
        (isDark ? const Color(0xFF450622) : BrandColors.burgundy);
    final avatarFg = textColor ?? (isDark ? BrandColors.gold : Colors.white);

    Widget content;
    if (hasFileImage) {
      content = Image.file(
        File(safePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => _AvatarFallback(
          initial: initial,
          fontSize: fontSize,
          color: avatarFg,
        ),
      );
    } else if (hasRealNetworkImage) {
      content = Image.network(
        safeUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => _AvatarFallback(
          initial: initial,
          fontSize: fontSize,
          color: avatarFg,
        ),
      );
    } else {
      content = _AvatarFallback(
        initial: initial,
        fontSize: fontSize,
        color: avatarFg,
      );
    }

    // احتواء هندسي كامل: حلقة ذهبية محيطية ناعمة مع فراغ داخلي متناسق
    final double borderThickness = showBorder ? 1.6 : 0.0;
    final double innerPadding = showBorder ? 2.0 : 0.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: BrandColors.gold.withValues(alpha: isDark ? 0.65 : 0.85),
                width: borderThickness,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: BrandColors.burgundy.withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(innerPadding),
        child: ClipOval(
          child: Container(
            color: avatarBg,
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }

  /// استخراج حرف واحد فقط بدقة متناهية من الاسم الأول
  String _displayInitial(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'ر';

    // نأخذ الكلمة الأولى فقط (الاسم الأول)
    final firstWord = trimmed.split(RegExp(r'\s+')).first;
    final runes = firstWord.runes;
    if (runes.isEmpty) return 'ر';

    // نأخذ الحرف الأول الفعلي فقط
    return String.fromCharCode(runes.first).toUpperCase();
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
        textAlign: TextAlign.center,
        style: AppTextTheme.cairo(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: color,
          height: 1.1,
        ),
      ),
    );
  }
}
