import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';

class AuthBlobBackground extends StatelessWidget {
  final Widget child;

  const AuthBlobBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = Theme.of(context).scaffoldBackgroundColor;

    // في الوضع الليلي: الألوان الأساسية للخلفية هي العنابي الملكي المخملي مع لمسة ذهبية ناعمة
    // في الوضع النهاري: العنابي الخفيف اللطيف
    final dominantBlobColor = isDark ? AppColors.burgundy : AppColors.burgundy;

    final dominantOpacity = isDark ? 0.38 : 0.08;

    final accentGoldColor = AppColors.gold;
    final goldOpacity = isDark ? 0.09 : 0.04;

    return Stack(
      children: [
        // الخلفية الأساسية
        Positioned.fill(child: Container(color: base)),

        // تدرج عام ناعم للعمق
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          AppColors.burgundy950.withValues(alpha: 0.5),
                          base,
                          AppColors.burgundy900.withValues(alpha: 0.25),
                        ]
                      : [
                          AppColors.burgundy50.withValues(alpha: 0.4),
                          base,
                          Colors.transparent,
                        ],
                ),
              ),
            ),
          ),
        ),

        // هالة ذهبية دافئة ناعمة في الزاوية العلوية (تمنح الفخامة دون إزعاج بصري)
        Positioned(
          top: -size.width * 0.2,
          right: -size.width * 0.1,
          child: _AmbientGlow(
            size: size.width * 0.7,
            color: accentGoldColor,
            opacity: goldOpacity,
          ),
        ),

        // الشكل العنابي العلوي الكبير (بنعومة مخملية وتدرج متناسق)
        Positioned(
          top: -size.width * 0.25,
          left: -size.width * 0.25,
          child: _Blob(
            width: size.width * 0.85,
            height: size.width * 0.85,
            color: dominantBlobColor,
            opacity: dominantOpacity,
            shape: _BlobShape.topLeft,
            isDark: isDark,
          ),
        ),

        // شكل عنابي ناعم وسطي للتوازن
        Positioned(
          top: size.height * 0.38,
          right: -size.width * 0.15,
          child: _Blob(
            width: size.width * 0.45,
            height: size.width * 0.45,
            color: dominantBlobColor,
            opacity: isDark ? 0.22 : 0.05,
            shape: _BlobShape.middle,
            isDark: isDark,
          ),
        ),

        // الشكل السفلي (متناغم ولا يقطع نصوص التذييل)
        Positioned(
          bottom: -size.width * 0.15,
          right: -size.width * 0.12,
          child: _Blob(
            width: size.width * 0.55,
            height: size.width * 0.55,
            color: dominantBlobColor,
            opacity: isDark ? 0.30 : 0.06,
            shape: _BlobShape.bottomRight,
            isDark: isDark,
          ),
        ),

        // هالة ذهبية خافتة في الأسفل لإكمال المظهر الفاخر
        Positioned(
          bottom: -size.width * 0.1,
          left: -size.width * 0.1,
          child: _AmbientGlow(
            size: size.width * 0.5,
            color: accentGoldColor,
            opacity: goldOpacity * 0.8,
          ),
        ),

        // محتوى الشاشة
        Positioned.fill(child: child),
      ],
    );
  }
}

enum _BlobShape { topLeft, topLeftSoft, bottomRight, middle, bottomLeft }

class _AmbientGlow extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _AmbientGlow({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: opacity * 0.4),
              Colors.transparent,
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double opacity;
  final _BlobShape shape;
  final bool isDark;

  const _Blob({
    required this.width,
    required this.height,
    required this.color,
    required this.opacity,
    required this.shape,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size(width, height),
        painter: _BlobPainter(
          color: color.withValues(alpha: opacity),
          shape: shape,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  final Color color;
  final _BlobShape shape;
  final bool isDark;

  _BlobPainter({
    required this.color,
    required this.shape,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size, shape);
    final rect = Offset.zero & size;

    // تدرج لوني انسيابي ناعم يتلاشى برقة مع ألوان الخلفية
    final baseColor = color;
    final innerLightColor = isDark
        ? Color.alphaBlend(
            AppColors.burgundy500.withValues(alpha: 0.35),
            baseColor,
          )
        : Color.alphaBlend(Colors.white.withValues(alpha: 0.4), baseColor);

    final outerFadeColor = baseColor.withValues(alpha: baseColor.a * 0.2);

    final fillPaint = Paint()
      ..shader = ui.Gradient.radial(
        rect.center,
        size.shortestSide * 0.55,
        [innerLightColor, baseColor, outerFadeColor],
        const [0.0, 0.65, 1.0],
      )
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isDark ? 28 : 16);

    canvas.drawPath(path, fillPaint);
  }

  Path _buildPath(Size size, _BlobShape shape) {
    final path = Path();
    switch (shape) {
      case _BlobShape.topLeft:
        path.moveTo(size.width * 0.15, size.height * 0.15);
        path.cubicTo(
          size.width * 0.02,
          size.height * 0.45,
          size.width * 0.08,
          size.height * 0.88,
          size.width * 0.45,
          size.height * 0.96,
        );
        path.cubicTo(
          size.width * 0.82,
          size.height * 1.04,
          size.width * 1.08,
          size.height * 0.72,
          size.width * 0.94,
          size.height * 0.42,
        );
        path.cubicTo(
          size.width * 0.82,
          size.height * 0.08,
          size.width * 0.42,
          size.height * -0.02,
          size.width * 0.15,
          size.height * 0.15,
        );
        break;

      case _BlobShape.topLeftSoft:
        path.moveTo(size.width * 0.18, size.height * 0.08);
        path.cubicTo(
          size.width * 0.02,
          size.height * 0.28,
          size.width * 0.08,
          size.height * 0.72,
          size.width * 0.38,
          size.height * 0.82,
        );
        path.cubicTo(
          size.width * 0.72,
          size.height * 0.92,
          size.width * 0.98,
          size.height * 0.62,
          size.width * 0.88,
          size.height * 0.32,
        );
        path.cubicTo(
          size.width * 0.82,
          size.height * 0.06,
          size.width * 0.42,
          size.height * -0.06,
          size.width * 0.18,
          size.height * 0.08,
        );
        break;

      case _BlobShape.bottomRight:
        path.moveTo(size.width * 0.25, size.height * 0.15);
        path.cubicTo(
          size.width * 0.02,
          size.height * 0.32,
          size.width * 0.02,
          size.height * 0.78,
          size.width * 0.32,
          size.height * 0.92,
        );
        path.cubicTo(
          size.width * 0.68,
          size.height * 1.08,
          size.width * 0.98,
          size.height * 0.82,
          size.width * 0.92,
          size.height * 0.52,
        );
        path.cubicTo(
          size.width * 0.88,
          size.height * 0.20,
          size.width * 0.55,
          size.height * 0.02,
          size.width * 0.25,
          size.height * 0.15,
        );
        break;

      case _BlobShape.middle:
        path.moveTo(size.width * 0.3, size.height * 0.1);
        path.cubicTo(
          size.width * 0.1,
          size.height * 0.25,
          size.width * 0.15,
          size.height * 0.6,
          size.width * 0.4,
          size.height * 0.7,
        );
        path.cubicTo(
          size.width * 0.65,
          size.height * 0.8,
          size.width * 0.85,
          size.height * 0.55,
          size.width * 0.75,
          size.height * 0.3,
        );
        path.cubicTo(
          size.width * 0.65,
          size.height * 0.1,
          size.width * 0.45,
          size.height * 0.0,
          size.width * 0.3,
          size.height * 0.1,
        );
        break;

      case _BlobShape.bottomLeft:
        path.moveTo(size.width * 0.2, size.height * 0.25);
        path.cubicTo(
          size.width * -0.05,
          size.height * 0.4,
          size.width * 0.0,
          size.height * 0.8,
          size.width * 0.3,
          size.height * 0.85,
        );
        path.cubicTo(
          size.width * 0.6,
          size.height * 0.9,
          size.width * 0.8,
          size.height * 0.65,
          size.width * 0.7,
          size.height * 0.4,
        );
        path.cubicTo(
          size.width * 0.6,
          size.height * 0.15,
          size.width * 0.4,
          size.height * 0.1,
          size.width * 0.2,
          size.height * 0.25,
        );
        break;
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.shape != shape ||
        oldDelegate.isDark != isDark;
  }
}
