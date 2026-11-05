import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';

class CartAddedDialog extends StatelessWidget {
  const CartAddedDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'cart_added',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) => const Center(
        child: _CartAnimation(),
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

class _CartAnimation extends StatefulWidget {
  const _CartAnimation();

  @override
  State<_CartAnimation> createState() => _CartAnimationState();
}

class _CartAnimationState extends State<_CartAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  bool _closed = false;

  // HUD Dialog Card
  late final Animation<double> cardScale;
  late final Animation<double> cardOpacity;

  // Dropping Product Item
  late final Animation<double> itemOpacity;
  late final Animation<double> itemOffsetY;
  late final Animation<double> itemScale;
  late final Animation<double> itemRotation;

  // Cart Reaction (Squash & Stretch upon impact)
  late final Animation<double> cartScaleX;
  late final Animation<double> cartScaleY;

  // Particle Burst & Shockwave Ring
  late final Animation<double> burstProgress;
  late final Animation<double> burstOpacity;
  late final Animation<double> ringScale;
  late final Animation<double> ringOpacity;

  // Emerald Checkmark Badge
  late final Animation<double> checkScale;

  @override
  void initState() {
    super.initState();

    // 2100ms total duration: long, cinematic, delightful experience
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    );

    // 1. HUD Card appearance (0 - 300ms) & gentle exit (1850 - 2100ms)
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

    // 2. Dropping Product Item
    // Fades in above cart (300ms - 450ms) and sinks into the basket (400ms - 880ms)
    itemOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 8,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 16,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 5,
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: 57,
      ),
    ]).animate(controller);

    // Moves down from -54 to +8 into the cart basket
    itemOffsetY = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(-54.0),
        weight: 16,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -54.0, end: 8.0).chain(
          CurveTween(curve: Curves.easeInCubic),
        ),
        weight: 26,
      ),
      TweenSequenceItem(
        tween: ConstantTween(8.0),
        weight: 58,
      ),
    ]).animate(controller);

    // Item scales down slightly as it drops into depth
    itemScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(1.2),
        weight: 16,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 0.55).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 26,
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.55),
        weight: 58,
      ),
    ]).animate(controller);

    // Item rotates slightly (-18 deg -> 0)
    itemRotation = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(-0.30),
        weight: 16,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -0.30, end: 0.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 26,
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: 58,
      ),
    ]).animate(controller);

    // 3. Cart Squash & Stretch Impact Reaction upon landing (at weight ~42)
    cartScaleX = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.24).chain(
          CurveTween(curve: Curves.easeOutQuad),
        ),
        weight: 6,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.24, end: 0.94).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 7,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.94, end: 1.0).chain(
          CurveTween(curve: Curves.easeOutBack),
        ),
        weight: 8,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 39,
      ),
    ]).animate(controller);

    cartScaleY = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.78).chain(
          CurveTween(curve: Curves.easeOutQuad),
        ),
        weight: 6,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.78, end: 1.10).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 7,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.10, end: 1.0).chain(
          CurveTween(curve: Curves.easeOutBack),
        ),
        weight: 8,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 39,
      ),
    ]).animate(controller);

    // 4. Sparkle & Ring Burst on Impact
    burstProgress = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.40, 0.65, curve: Curves.easeOutCubic),
    );

    burstOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 5,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: 35,
      ),
    ]).animate(controller);

    ringScale = Tween<double>(
      begin: 0.35,
      end: 1.75,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.40, 0.68, curve: Curves.easeOutCubic),
      ),
    );

    ringOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.85),
        weight: 5,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.85, end: 0.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 22,
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: 33,
      ),
    ]).animate(controller);

    // 5. Checkmark Badge Pop-in
    checkScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: 46,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.35).chain(
          CurveTween(curve: Curves.easeOutBack),
        ),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.35, end: 1.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 7,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 35,
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
    final cartPrimary = isDark ? BrandColors.gold : BrandColors.burgundy;
    final sparkColor = isDark ? const Color(0xFFFFD54F) : BrandColors.gold;

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
                        ? BrandColors.gold.withValues(alpha: 0.55)
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
                      color: cartPrimary.withValues(alpha: isDark ? 0.28 : 0.12),
                      blurRadius: 22,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Stage: Product falling into Shopping Cart
                    SizedBox(
                      width: 84,
                      height: 84,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // 1. Expanding Shockwave Ring on impact
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
                                    color: sparkColor.withValues(alpha: 0.75),
                                    width: 2.2,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 2. Sparkling Particle Explosion
                          Opacity(
                            opacity: burstOpacity.value,
                            child: CustomPaint(
                              size: const Size(84, 84),
                              painter: _CartBurstPainter(
                                color: sparkColor,
                                progress: burstProgress.value,
                              ),
                            ),
                          ),

                          // 3. Shopping Cart Base (with squash & bounce)
                          Positioned(
                            bottom: 8,
                            child: Transform.scale(
                              scaleX: cartScaleX.value,
                              scaleY: cartScaleY.value,
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: cartPrimary.withValues(alpha: isDark ? 0.20 : 0.12),
                                  border: Border.all(
                                    color: cartPrimary.withValues(alpha: isDark ? 0.35 : 0.22),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.shopping_cart_rounded,
                                  size: 30,
                                  color: cartPrimary,
                                ),
                              ),
                            ),
                          ),

                          // 4. Product Item Falling from top into the cart
                          Positioned(
                            bottom: 24,
                            child: Opacity(
                              opacity: itemOpacity.value,
                              child: Transform.translate(
                                offset: Offset(0, itemOffsetY.value),
                                child: Transform.rotate(
                                  angle: itemRotation.value,
                                  child: Transform.scale(
                                    scale: itemScale.value,
                                    child: _ProductDropParcel(isDark: isDark),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 5. Emerald Checkmark Badge (+1)
                          Positioned(
                            top: 14,
                            right: 4,
                            child: Transform.scale(
                              scale: checkScale.value,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF10B981), // Emerald green
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.45),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Title
                    Text(
                      'تمت الإضافة للسلة',
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

                    // Subtitle / Confirmation Hint
                    Text(
                      'أضيف إلى مشترياتك بنجاح',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? BrandColors.gold.withValues(alpha: 0.90)
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

/// Mini luxury product package/parcel that drops into the cart
class _ProductDropParcel extends StatelessWidget {
  final bool isDark;

  const _ProductDropParcel({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final gradientColors = isDark
        ? [const Color(0xFFFAAD01), const Color(0xFFFFD54F)]
        : [const Color(0xFF8E0542), const Color(0xFF6E0131)];

    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFFFAAD01) : const Color(0xFF6E0131))
                .withValues(alpha: 0.45),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        Icons.inventory_2_rounded,
        size: 15,
        color: isDark ? const Color(0xFF1E0A17) : Colors.white,
      ),
    );
  }
}

class _CartBurstPainter extends CustomPainter {
  final Color color;
  final double progress;

  _CartBurstPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2 + 10);

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
  bool shouldRepaint(covariant _CartBurstPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
