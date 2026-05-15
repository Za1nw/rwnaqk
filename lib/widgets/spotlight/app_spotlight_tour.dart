import 'dart:math' as math;
import 'dart:ui' show clampDouble;

import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

enum AppSpotlightShape {
  roundedRect,
  oval,
}

@immutable
class AppSpotlightStep {
  final GlobalKey targetKey;
  final String title;
  final String description;
  final IconData icon;
  final String? badge;
  final EdgeInsets padding;
  final double borderRadius;
  final Color? accentColor;
  final VoidCallback? onTargetTap;
  final AppSpotlightShape shape;

  const AppSpotlightStep({
    required this.targetKey,
    required this.title,
    required this.description,
    required this.icon,
    this.badge,
    this.padding = const EdgeInsets.all(10),
    this.borderRadius = 24,
    this.accentColor,
    this.onTargetTap,
    this.shape = AppSpotlightShape.roundedRect,
  });
}

class AppSpotlightTour extends StatefulWidget {
  final List<AppSpotlightStep> steps;
  final int currentStep;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final String nextLabel;
  final String doneLabel;
  final String skipLabel;

  const AppSpotlightTour({
    super.key,
    required this.steps,
    required this.currentStep,
    required this.onNext,
    required this.onSkip,
    required this.nextLabel,
    required this.doneLabel,
    required this.skipLabel,
  });

  @override
  State<AppSpotlightTour> createState() => _AppSpotlightTourState();
}

class _AppSpotlightTourState extends State<AppSpotlightTour>
    with SingleTickerProviderStateMixin {
  final GlobalKey _overlayKey = GlobalKey();
  Rect? _targetRect;
  late final AnimationController _pulseController;

  bool get _hasSteps =>
      widget.steps.isNotEmpty &&
      widget.currentStep >= 0 &&
      widget.currentStep < widget.steps.length;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1850),
    )..repeat();
    _scheduleMeasure();
  }

  @override
  void didUpdateWidget(covariant AppSpotlightTour oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentStep != widget.currentStep ||
        oldWidget.steps != widget.steps) {
      _scheduleMeasure();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final rect = _resolveTargetRect();
      if (rect != _targetRect) {
        setState(() => _targetRect = rect);
      }
    });
  }

  Rect? _resolveTargetRect() {
    if (!_hasSteps) return null;

    final targetContext =
        widget.steps[widget.currentStep].targetKey.currentContext;
    final overlayContext = _overlayKey.currentContext;
    if (targetContext == null || overlayContext == null) return null;

    final targetBox = targetContext.findRenderObject() as RenderBox?;
    final overlayBox = overlayContext.findRenderObject() as RenderBox?;
    if (targetBox == null ||
        overlayBox == null ||
        !targetBox.hasSize ||
        !overlayBox.hasSize) {
      return null;
    }

    final topLeft = targetBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    return topLeft & targetBox.size;
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_hasSteps || _targetRect == null) return;

    final step = widget.steps[widget.currentStep];
    final spotlightRect = _expandRect(_targetRect!, step.padding);
    if (spotlightRect.contains(details.localPosition)) {
      step.onTargetTap?.call();
      _scheduleMeasure();
    }
  }

  Rect _expandRect(Rect rect, EdgeInsets padding) {
    return Rect.fromLTRB(
      rect.left - padding.left,
      rect.top - padding.top,
      rect.right + padding.right,
      rect.bottom + padding.bottom,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasSteps) {
      return const SizedBox.shrink();
    }

    final step = widget.steps[widget.currentStep];
    final accentColor = step.accentColor ?? context.primary;

    return Positioned.fill(
      child: RepaintBoundary(
        key: _overlayKey,
        child: _targetRect == null
            ? const SizedBox.expand()
            : LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest;
                  final spotlightRect = _expandRect(_targetRect!, step.padding);
                  final tooltipWidth = math.min(size.width - 24, 330.0);
                  final showBelow =
                      size.height - spotlightRect.bottom > spotlightRect.top;
                  final tooltipLeft = clampDouble(
                    spotlightRect.center.dx - (tooltipWidth / 2),
                    12,
                    size.width - tooltipWidth - 12,
                  );
                  final tooltipAnchorX = clampDouble(
                    spotlightRect.center.dx,
                    tooltipLeft + 30,
                    tooltipLeft + tooltipWidth - 30,
                  );
                  final tooltipTop =
                      showBelow ? spotlightRect.bottom + 30 : null;
                  final tooltipBottom =
                      showBelow ? null : size.height - spotlightRect.top + 30;

                  return TweenAnimationBuilder<double>(
                    key: ValueKey(widget.currentStep),
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    builder: (context, progress, _) {
                      final overlayColor = Color.lerp(
                        Colors.transparent,
                        context.isDark
                            ? const Color(0xCC07141D)
                            : const Color(0xA6243347),
                        progress,
                      )!;

                      final focusRect = Rect.fromCenter(
                        center: spotlightRect.center,
                        width: spotlightRect.width + (18 * (1 - progress)),
                        height: spotlightRect.height + (18 * (1 - progress)),
                      );

                      return AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, _) {
                          return Stack(
                            children: [
                              Positioned.fill(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapDown: _handleTapDown,
                                  child: CustomPaint(
                                    painter: _SpotlightScrimPainter(
                                      highlightRect: spotlightRect,
                                      borderRadius: step.borderRadius,
                                      overlayColor: overlayColor,
                                      shape: step.shape,
                                    ),
                                  ),
                                ),
                              ),
                              for (final phase in [0.0, 0.5])
                                Positioned.fromRect(
                                  rect: _pulseRect(
                                    spotlightRect,
                                    _pulseController.value,
                                    phase,
                                  ),
                                  child: IgnorePointer(
                                    child: Opacity(
                                      opacity: _pulseOpacity(
                                        _pulseController.value,
                                        phase,
                                      ),
                                      child: DecoratedBox(
                                        decoration: _focusDecoration(
                                          step: step,
                                          color: accentColor,
                                          glow: false,
                                          isPulse: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned.fromRect(
                                rect: focusRect,
                                child: IgnorePointer(
                                  child: DecoratedBox(
                                    decoration: _focusDecoration(
                                      step: step,
                                      color: accentColor,
                                      glow: true,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: CustomPaint(
                                    painter: _SpotlightPointerPainter(
                                      color:
                                          accentColor.withValues(alpha: 0.86),
                                      start: Offset(
                                        spotlightRect.center.dx,
                                        showBelow
                                            ? spotlightRect.bottom + 4
                                            : spotlightRect.top - 4,
                                      ),
                                      end: Offset(
                                        tooltipAnchorX,
                                        showBelow
                                            ? (tooltipTop ?? 0) + 2
                                            : size.height -
                                                (tooltipBottom ?? 0) -
                                                2,
                                      ),
                                      showBelow: showBelow,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: tooltipLeft,
                                top: tooltipTop,
                                bottom: tooltipBottom,
                                width: tooltipWidth,
                                child: Transform.scale(
                                  alignment: showBelow
                                      ? Alignment.topCenter
                                      : Alignment.bottomCenter,
                                  scale: 0.96 + (0.04 * progress),
                                  child: Opacity(
                                    opacity: progress,
                                    child: AppSpotlightTooltipCard(
                                      title: step.title,
                                      description: step.description,
                                      icon: step.icon,
                                      badge: step.badge,
                                      stepIndex: widget.currentStep,
                                      stepCount: widget.steps.length,
                                      accentColor: accentColor,
                                      isLast: widget.currentStep ==
                                          widget.steps.length - 1,
                                      nextLabel: widget.nextLabel,
                                      doneLabel: widget.doneLabel,
                                      skipLabel: widget.skipLabel,
                                      onNext: widget.onNext,
                                      onSkip: widget.onSkip,
                                      showBelow: showBelow,
                                      notchX: tooltipAnchorX - tooltipLeft,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  BoxDecoration _focusDecoration({
    required AppSpotlightStep step,
    required Color color,
    bool glow = false,
    bool isPulse = false,
  }) {
    return BoxDecoration(
      borderRadius: step.shape == AppSpotlightShape.oval
          ? BorderRadius.circular(999)
          : BorderRadius.circular(step.borderRadius + 8),
      border: Border.all(
        color: color.withValues(alpha: isPulse ? 0.46 : 0.5),
        width: isPulse ? 1.2 : 1.5,
      ),
      boxShadow: glow
          ? [
              BoxShadow(
                color: color.withValues(alpha: 0.28),
                blurRadius: 24,
                spreadRadius: 3,
              ),
            ]
          : [],
    );
  }

  Rect _pulseRect(Rect base, double value, double phase) {
    final normalized = (value + phase) % 1;
    final inflate = 10 + (normalized * 26);

    return Rect.fromCenter(
      center: base.center,
      width: base.width + inflate,
      height: base.height + inflate,
    );
  }

  double _pulseOpacity(double value, double phase) {
    final normalized = (value + phase) % 1;
    return (1 - normalized) * 0.36;
  }
}

class AppSpotlightTooltipCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? badge;
  final int stepIndex;
  final int stepCount;
  final Color accentColor;
  final bool isLast;
  final String nextLabel;
  final String doneLabel;
  final String skipLabel;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool showBelow;
  final double notchX;

  const AppSpotlightTooltipCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.stepIndex,
    required this.stepCount,
    required this.accentColor,
    required this.isLast,
    required this.nextLabel,
    required this.doneLabel,
    required this.skipLabel,
    required this.onNext,
    required this.onSkip,
    required this.showBelow,
    required this.notchX,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = context.card.withValues(
      alpha: context.isDark ? 0.98 : 0.97,
    );
    final safeNotchX = clampDouble(notchX, 30, 300);

    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: safeNotchX - 9,
            top: showBelow ? -8 : null,
            bottom: showBelow ? null : -8,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: bubbleColor,
                  border: Border.all(
                    color: accentColor.withValues(
                      alpha: context.isDark ? 0.3 : 0.18,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.08),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: accentColor.withValues(
                  alpha: context.isDark ? 0.3 : 0.18,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: context.isDark ? 0.34 : 0.1,
                  ),
                  offset: const Offset(0, 18),
                  blurRadius: 36,
                ),
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.14),
                  offset: const Offset(0, 6),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        color: accentColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (badge != null) ...[
                            Text(
                              badge!,
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 11.5,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 5),
                          ],
                          Text(
                            title,
                            style: TextStyle(
                              color: context.foreground,
                              fontWeight: FontWeight.w900,
                              fontSize: 16.2,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: context.background.withValues(
                          alpha: context.isDark ? 0.34 : 0.7,
                        ),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: context.border.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        '${stepIndex + 1}/$stepCount',
                        style: TextStyle(
                          color: context.mutedForeground,
                          fontWeight: FontWeight.w800,
                          fontSize: 11.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  description,
                  style: TextStyle(
                    color: context.mutedForeground,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.2,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    TextButton(
                      onPressed: onSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: context.mutedForeground,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.8,
                        ),
                      ),
                      child: Text(skipLabel),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: onNext,
                      style: FilledButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13.2,
                        ),
                      ),
                      child: Text(isLast ? doneLabel : nextLabel),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotlightPointerPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;
  final bool showBelow;

  const _SpotlightPointerPainter({
    required this.start,
    required this.end,
    required this.color,
    required this.showBelow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final controlPoint = Offset(
      start.dx + ((end.dx - start.dx) * 0.2),
      showBelow
          ? start.dy + ((end.dy - start.dy) * 0.58)
          : start.dy - ((start.dy - end.dy) * 0.58),
    );

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        end.dx,
        end.dy,
      );

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, strokePaint);

    canvas.drawCircle(
      start,
      4.5,
      Paint()..color = color.withValues(alpha: 0.96),
    );

    final arrowVector = Offset(
      end.dx - controlPoint.dx,
      end.dy - controlPoint.dy,
    );
    final arrowAngle = math.atan2(arrowVector.dy, arrowVector.dx);
    final arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - 11 * math.cos(arrowAngle - 0.34),
        end.dy - 11 * math.sin(arrowAngle - 0.34),
      )
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - 11 * math.cos(arrowAngle + 0.34),
        end.dy - 11 * math.sin(arrowAngle + 0.34),
      );

    canvas.drawPath(arrowPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPointerPainter oldDelegate) {
    return oldDelegate.start != start ||
        oldDelegate.end != end ||
        oldDelegate.color != color ||
        oldDelegate.showBelow != showBelow;
  }
}

class _SpotlightScrimPainter extends CustomPainter {
  final Rect highlightRect;
  final double borderRadius;
  final Color overlayColor;
  final AppSpotlightShape shape;

  const _SpotlightScrimPainter({
    required this.highlightRect,
    required this.borderRadius,
    required this.overlayColor,
    required this.shape,
  });

  Path _holePath() {
    if (shape == AppSpotlightShape.oval) {
      return Path()..addOval(highlightRect);
    }

    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          highlightRect,
          Radius.circular(borderRadius),
        ),
      );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPath = Path()..addRect(Offset.zero & size);
    final holePath = _holePath();

    overlayPath.fillType = PathFillType.evenOdd;
    overlayPath.addPath(holePath, Offset.zero);

    canvas.drawPath(
      overlayPath,
      Paint()
        ..color = overlayColor
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightScrimPainter oldDelegate) {
    return oldDelegate.highlightRect != highlightRect ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.overlayColor != overlayColor ||
        oldDelegate.shape != shape;
  }
}
