import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class AuthBlobBackground extends StatelessWidget {
  final Widget child;

  const AuthBlobBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final primary = Theme.of(context).colorScheme.primary;
    final base = Theme.of(context).scaffoldBackgroundColor;

    return Stack(
      children: [
        // Base
        Positioned.fill(
          child: Container(color: base),
        ),

        // Top-left big blob (محسن: تأثير أعمق)
        Positioned(
          top: -size.width * 0.3,
          left: -size.width * 0.3,
          child: _Blob(
            width: size.width * 0.8,
            height: size.width * 0.8,
            color: primary,
            opacity: 1,
            shape: _BlobShape.topLeft,
          ),
        ),

        // Top-left soft shadow blob (محسن: توزيع أفضل)
        Positioned(
          top: size.width * 0.02,
          left: -size.width * 0.1,
          child: _Blob(
            width: size.width * 0.65,
            height: size.width * 0.6,
            color: primary,
            opacity: 0.22,
            shape: _BlobShape.topLeftSoft,
          ),
        ),

        // Middle decorative blob (جديد: طبقة وسطى لإثراء الخلفية)
        Positioned(
          top: size.height * 0.4,
          right: size.width * 0.2,
          child: _Blob(
            width: size.width * 0.25,
            height: size.width * 0.25,
            color: primary,
            opacity: 0.15,
            shape: _BlobShape.middle,
          ),
        ),

        // Bottom-right small blob (محسن: حجم وتأثير أفضل)
        Positioned(
          bottom: size.width * 0.02,
          right: -size.width * 0.08,
          child: _Blob(
            width: size.width * 0.4,
            height: size.width * 0.4,
            color: primary,
            opacity: 1,
            shape: _BlobShape.bottomRight,
          ),
        ),

        // Bottom-left subtle blob (جديد: للتوازن البصري)
        Positioned(
          bottom: -size.width * 0.1,
          left: -size.width * 0.1,
          child: _Blob(
            width: size.width * 0.3,
            height: size.width * 0.3,
            color: primary,
            opacity: 0.12,
            shape: _BlobShape.bottomLeft,
          ),
        ),

        // Gradient overlay (جديد: تدرج خفيف للعمق)
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.transparent,
                    primary.withOpacity(0.03),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Child (screen)
        Positioned.fill(child: child),
      ],
    );
  }
}

enum _BlobShape { topLeft, topLeftSoft, bottomRight, middle, bottomLeft }

class _Blob extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double opacity;
  final _BlobShape shape;

  const _Blob({
    required this.width,
    required this.height,
    required this.color,
    required this.opacity,
    required this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _BlobPainter(
        color: color.withOpacity(opacity),
        shape: shape,
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  final Color color;
  final _BlobShape shape;

  _BlobPainter({required this.color, required this.shape});

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size, shape);

    // اتجاه الإضاءة (أعلى يسار) - محسن
    const lightOffset = Offset(-0.2, -0.2);
    const darkOffset = Offset(0.3, 0.3);

    // 1) Soft outer shadow (clay elevation) - محسن: طبقات أكثر
    canvas.drawShadow(
      path,
      Colors.black.withOpacity(0.2),
      18,
      true,
    );
    canvas.drawShadow(
      path,
      Colors.black.withOpacity(0.12),
      32,
      true,
    );
    canvas.drawShadow(
      path,
      Colors.black.withOpacity(0.06),
      48,
      true,
    );

    // 2) Clay fill (soft radial gradient) - محسن: تدرج أكثر سلاسة
    final rect = Offset.zero & size;

    final base = color;
    final light = _mix(base, Colors.white, 0.32).withOpacity(base.opacity);
    final midLight = _mix(base, Colors.white, 0.12).withOpacity(base.opacity);
    final dark = _mix(base, Colors.black, 0.18).withOpacity(base.opacity);
    final extraDark = _mix(base, Colors.black, 0.08).withOpacity(base.opacity);

    final fillPaint = Paint()
      ..shader = ui.Gradient.radial(
        rect.center + Offset(size.width * lightOffset.dx, size.height * lightOffset.dy),
        size.shortestSide * 0.8,
        [
          light,
          midLight,
          base,
          extraDark,
          dark,
        ],
        const [0.0, 0.3, 0.6, 0.85, 1.0],
      );

    canvas.drawPath(path, fillPaint);

    // 3) Subtle highlight rim (top-left edge) - محسن: أكثر نعومة
    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withOpacity(0.32)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawPath(path, highlightPaint);

    // 4) Soft inner glow (جديد)
    final innerGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.white.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawPath(path, innerGlowPaint);

    // 5) Soft blur effect - محسن
    if (shape == _BlobShape.topLeftSoft || shape == _BlobShape.middle || shape == _BlobShape.bottomLeft) {
      final softPaint = Paint()
        ..color = base.withOpacity(base.opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
      canvas.drawPath(path, softPaint);
    }

    // 6) Subtle inner depth - محسن
    final innerPaint = Paint()
      ..shader = ui.Gradient.radial(
        rect.center + Offset(size.width * darkOffset.dx, size.height * darkOffset.dy),
        size.shortestSide * 0.95,
        [
          Colors.transparent,
          Colors.black.withOpacity(0.12 * color.opacity),
        ],
        const [0.4, 1.0],
      );
    canvas.drawPath(path, innerPaint);

    // 7) Fine details (جديد: تفاصيل دقيقة للحواف)
    final edgeDetailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.white.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(path, edgeDetailPaint);
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

  Color _mix(Color a, Color b, double t) {
    return Color.fromARGB(
      (a.alpha + (b.alpha - a.alpha) * t).round(),
      (a.red + (b.red - a.red) * t).round(),
      (a.green + (b.green - a.green) * t).round(),
      (a.blue + (b.blue - a.blue) * t).round(),
    );
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.shape != shape;
  }
}