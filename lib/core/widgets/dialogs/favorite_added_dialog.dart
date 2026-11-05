import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';

class FavoriteAddedDialog extends StatelessWidget {
  const FavoriteAddedDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'favorite_added',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) => const Center(
        child: _FavoriteAnimation(),
      ),
      transitionBuilder: (_, animation, _, child) {
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
  late final Animation<double> heartGlow;

  late final Animation<double> burstProgress;
  late final Animation<double> burstOpacity;
  late final Animation<double> ringScale;
  late final Animation<double> ringOpacity;

  @override
  void initState() {
    super.initState();

    // 2000ms duration: relaxed, clear, high-contrast, premium
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 1. HUD Card Scale & Opacity
    cardScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.72, end: 1.04).chain(
          CurveTween(curve: Curves.easeOutBack),
        ),
        weight: 16,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.04, end: 1.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 8,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 64,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.88).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 12,
      ),
    ]).animate(controller);

    cardOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 74,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 12,
      ),
    ]).animate(controller);

    // 2. Heart Scale: Spring Pop -> Double Heartbeat Pulse -> Rest
    heartScale = TweenSequence<double>([
      // Spring pop-in (0 - 600ms)
      TweenSequenceItem(
        tween: Tween(begin: 0.2, end: 1.35).chain(
          CurveTween(curve: Curves.elasticOut),
        ),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.35, end: 1.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 12,
      ),
      // Pause before beat
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 8,
      ),
      // Heartbeat 1 (approx 1000ms - 1200ms)
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.22).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 7,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.22, end: 0.98).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 7,
      ),
      // Heartbeat 2
      TweenSequenceItem(
        tween: Tween(begin: 0.98, end: 1.14).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 6,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.14, end: 1.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 6,
      ),
      // Serene rest
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 24,
      ),
    ]).animate(controller);

    // Glowing aura intensity behind heart during heartbeat
    heartGlow = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.4),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.4, end: 1.0),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.5),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.5),
        weight: 24,
      ),
    ]).animate(controller);

    // 3. Initial Sparkle Burst
    burstProgress = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.12, 0.45, curve: Curves.easeOutCubic),
    );

    burstOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 6,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 24,
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: 58,
      ),
    ]).animate(controller);

    ringScale = Tween<double>(
      begin: 0.35,
      end: 1.70,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.12, 0.48, curve: Curves.easeOutCubic),
      ),
    );

    ringOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.90),
        weight: 6,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.90, end: 0.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 26,
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: 56,
      ),
    ]).animate(controller);

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
    final isDark = context.isDark;
    const heartColor = Color(0xFFFF2D55); // Vivid glowing ruby
    final accentGold = BrandColors.gold;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        return Opacity(
          opacity: cardOpacity.value,
          child: Transform.scale(
            scale: cardScale.value,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 154,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF261422) : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark
                        ? accentGold.withValues(alpha: 0.55)
                        : BrandColors.burgundy.withValues(alpha: 0.16),
                    width: 1.6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.55 : 0.16),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: heartColor.withValues(alpha: isDark ? 0.38 : 0.14),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Stage: Beating Ruby Heart & Sparkle Aura
                    SizedBox(
                      width: 84,
                      height: 84,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 1. Concentric Shockwave Ring
                          Opacity(
                            opacity: ringOpacity.value,
                            child: Transform.scale(
                              scale: ringScale.value,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: heartColor.withValues(alpha: 0.75),
                                    width: 2.2,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 2. Starlight Burst
                          Opacity(
                            opacity: burstOpacity.value,
                            child: CustomPaint(
                              size: const Size(84, 84),
                              painter: _FavoriteBurstPainter(
                                color: heartColor,
                                progress: burstProgress.value,
                              ),
                            ),
                          ),

                          // 3. Heart Glow Halo (Pulses with heartbeat)
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: heartColor.withValues(
                                alpha: (isDark ? 0.22 : 0.12) * heartGlow.value,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: heartColor.withValues(
                                    alpha: (isDark ? 0.35 : 0.15) * heartGlow.value,
                                  ),
                                  blurRadius: 16,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),

                          // 4. Elastic & Pulsing Heart Icon
                          Transform.scale(
                            scale: heartScale.value,
                            child: const Icon(
                              Icons.favorite_rounded,
                              size: 44,
                              color: heartColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Clear Arabic Title
                    Text(
                      'تمت الإضافة للمفضلة',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF26141E),
                        fontFamily: 'Cairo',
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Subtitle
                    Text(
                      'أضيف إلى قائمة رغباتك',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? accentGold.withValues(alpha: 0.90)
                            : BrandColors.burgundy.withValues(alpha: 0.85),
                        fontFamily: 'Cairo',
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FavoriteBurstPainter extends CustomPainter {
  final Color color;
  final double progress;

  _FavoriteBurstPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);

    final linePaint = Paint()
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.95);

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: 0.9);

    const lines = 8;
    const startRadius = 18.0;
    const endRadius = 34.0;
    const lineLength = 7.0;

    for (int i = 0; i < lines; i++) {
      final angle = (i * (360 / lines)) * math.pi / 180;
      final currentRadius = startRadius + ((endRadius - startRadius) * progress);

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
        center.dx + (currentRadius + lineLength + 2.5) * math.cos(angle),
        center.dy + (currentRadius + lineLength + 2.5) * math.sin(angle),
      );

      canvas.drawCircle(dot, 1.8, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FavoriteBurstPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
