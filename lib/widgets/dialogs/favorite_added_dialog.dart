import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class FavoriteAddedDialog extends StatelessWidget {
  const FavoriteAddedDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'favorite_added',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, __, ___) => const Center(
        child: _FavoriteAnimation(),
      ),
      transitionBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _FavoriteAnimation extends StatefulWidget {
  const _FavoriteAnimation();

  @override
  State<_FavoriteAnimation> createState() => _FavoriteAnimationState();
}

class _FavoriteAnimationState extends State<_FavoriteAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  bool _closed = false;

  late final Animation<double> cardScale;
  late final Animation<double> cardOpacity;
  late final Animation<double> heartScale;
  late final Animation<double> heartOpacity;
  late final Animation<double> burstProgress;
  late final Animation<double> burstOpacity;
  late final Animation<double> ringScale;
  late final Animation<double> ringOpacity;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    cardScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.82, end: 1.0).chain(
          CurveTween(curve: Curves.easeOutBack),
        ),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.94).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 25,
      ),
    ]).animate(controller);

    cardOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0),
        weight: 35,
      ),
    ]).animate(controller);

    heartScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.4, end: 1.2).chain(
          CurveTween(curve: Curves.easeOutBack),
        ),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 40,
      ),
    ]).animate(controller);

    heartOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0),
        weight: 35,
      ),
    ]).animate(controller);

    burstProgress = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.10, 0.50, curve: Curves.easeOutCubic),
    );

    burstOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.18, 0.55, curve: Curves.easeOut),
      ),
    );

    ringScale = Tween<double>(
      begin: 0.5,
      end: 1.5,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.08, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    ringOpacity = Tween<double>(
      begin: 0.6,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.12, 0.48, curve: Curves.easeOut),
      ),
    );

    controller.forward();

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _closeDialog();
      }
    });
  }

  void _closeDialog() {
    if (_closed || !mounted) return;
    _closed = true;

    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.primary;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Opacity(
          opacity: cardOpacity.value,
          child: Transform.scale(
            scale: cardScale.value,
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.card,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.14),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: context.border.withOpacity(.18),
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: ringOpacity.value,
                        child: Transform.scale(
                          scale: ringScale.value,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primary.withOpacity(.55),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: burstOpacity.value,
                        child: CustomPaint(
                          size: const Size(72, 72),
                          painter: _BurstPainter(
                            color: primary,
                            progress: burstProgress.value,
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: heartOpacity.value,
                        child: Transform.scale(
                          scale: heartScale.value,
                          child: Icon(
                            Icons.favorite_rounded,
                            size: 32,
                            color: primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BurstPainter extends CustomPainter {
  final Color color;
  final double progress;

  _BurstPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);

    final linePaint = Paint()
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = color.withOpacity(0.95);

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(0.9);

    const lines = 10;
    const startRadius = 18.0;
    const endRadius = 30.0;
    const lineLength = 8.0;

    for (int i = 0; i < lines; i++) {
      final angle = (i * (360 / lines)) * math.pi / 180;
      final currentRadius =
          startRadius + ((endRadius - startRadius) * progress);

      final p1 = Offset(
        center.dx + currentRadius * math.cos(angle),
        center.dy + currentRadius * math.sin(angle),
      );

      final p2 = Offset(
        center.dx + (currentRadius + lineLength) * math.cos(angle),
        center.dy + (currentRadius + lineLength) * math.sin(angle),
      );

      canvas.drawLine(p1, p2, linePaint);

      final dot = Offset(
        center.dx + (currentRadius + lineLength + 2) * math.cos(angle),
        center.dy + (currentRadius + lineLength + 2) * math.sin(angle),
      );

      canvas.drawCircle(dot, 1.7, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}