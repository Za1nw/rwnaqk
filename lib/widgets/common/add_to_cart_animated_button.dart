import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class AddToCartAnimatedButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;

  const AddToCartAnimatedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.height = 58,
  });

  @override
  State<AddToCartAnimatedButton> createState() =>
      _AddToCartAnimatedButtonState();
}

class _AddToCartAnimatedButtonState extends State<AddToCartAnimatedButton>
    with SingleTickerProviderStateMixin {
  static const _kRestRadius = 14.0;
  static const _kActiveRadius = 18.0;

  late final AnimationController _controller;
  late Animation<double> _buttonCompress;
  late Animation<double> _labelOpacity;
  late Animation<double> _labelScale;
  late Animation<double> _labelLift;
  late Animation<double> _iconSlide;
  late Animation<double> _iconScale;
  late Animation<double> _iconGlow;
  late Animation<double> _cartIconOpacity;
  late Animation<double> _checkIconOpacity;
  late Animation<double> _checkIconScale;
  late Animation<double> _waveShift;
  late Animation<double> _waveOpacity;
  late Animation<double> _surfaceCharge;

  bool _isAnimating = false;

  bool get _isUnavailable => widget.onPressed == null || widget.isLoading;
  bool get _isDisabled => _isUnavailable || _isAnimating;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1180),
    );
    _configureAnimations();
  }

  @override
  void reassemble() {
    super.reassemble();
    _configureAnimations();
  }

  void _configureAnimations() {
    _buttonCompress = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1).chain(
          CurveTween(curve: Curves.easeInOutCubic),
        ),
        weight: 34,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 66),
    ]).animate(_controller);

    _labelOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0).chain(
          CurveTween(curve: Curves.easeInOutCubic),
        ),
        weight: 24,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 76),
    ]).animate(_controller);

    _labelScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: .9).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 24,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(.9), weight: 76),
    ]).animate(_controller);

    _labelLift = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -4).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 24,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(-4), weight: 76),
    ]).animate(_controller);

    _iconSlide = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1).chain(
          CurveTween(curve: Curves.easeInOutCubicEmphasized),
        ),
        weight: 38,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 62),
    ]).animate(_controller);

    _iconScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: .94).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: .94, end: 1.08).chain(
          CurveTween(curve: Curves.easeOutBack),
        ),
        weight: 22,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.02).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 18,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1.02), weight: 50),
    ]).animate(_controller);

    _iconGlow = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: .16, end: .34).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: .34, end: .7).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 22,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: .7, end: .46).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 58,
      ),
    ]).animate(_controller);

    _cartIconOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 62),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0).chain(
          CurveTween(curve: Curves.easeInOutCubic),
        ),
        weight: 12,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 26),
    ]).animate(_controller);

    _checkIconOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 62),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 12,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 26),
    ]).animate(_controller);

    _checkIconScale = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(.72), weight: 62),
      TweenSequenceItem(
        tween: Tween<double>(begin: .72, end: 1.14).chain(
          CurveTween(curve: Curves.easeOutBack),
        ),
        weight: 16,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.14, end: 1).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 22,
      ),
    ]).animate(_controller);

    _waveShift = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(-1.25), weight: 30),
      TweenSequenceItem(
        tween: Tween<double>(begin: -1.25, end: 1.2).chain(
          CurveTween(curve: Curves.easeInOutCubic),
        ),
        weight: 44,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1.2), weight: 26),
    ]).animate(_controller);

    _waveOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 28),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: .92).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: .92, end: 0).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 24,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 38),
    ]).animate(_controller);

    _surfaceCharge = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1).chain(
          CurveTween(curve: Curves.easeInOutCubic),
        ),
        weight: 38,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: .7).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 62,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handlePressed() async {
    final onPressed = widget.onPressed;
    if (_isDisabled || onPressed == null) return;

    setState(() => _isAnimating = true);
    try {
      await _controller.animateTo(.58, curve: Curves.easeInOutCubic);
      onPressed();
      await _controller.forward();
      await _controller.reverse();
    } finally {
      if (mounted) {
        setState(() => _isAnimating = false);
      } else {
        _isAnimating = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final buttonBaseColor = _isUnavailable
        ? Color.lerp(context.primary, context.muted, .45)!
        : context.primary;
    final buttonActiveColor = _shiftColor(
      buttonBaseColor,
      lightnessDelta: context.isDark ? .05 : -.04,
      saturationDelta: .01,
    );
    final onPrimaryColor = context.primaryForeground;
    final shadowColor = context.shadow;
    final transparentSurface = context.background.withValues(alpha: 0);
    final transparentOnPrimary = onPrimaryColor.withValues(alpha: 0);
    final labelColor =
        onPrimaryColor.withValues(alpha: _isUnavailable ? .74 : .96);

    return Semantics(
      button: true,
      enabled: !_isDisabled,
      child: SizedBox(
        width: double.infinity,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final heightScale = lerpDouble(1, .96, _buttonCompress.value)!;
                final radius = lerpDouble(
                  _kRestRadius,
                  _kActiveRadius,
                  Curves.easeOut.transform(_buttonCompress.value),
                )!;
                final iconAlignmentX = isRtl
                    ? lerpDouble(.82, 0, _iconSlide.value)!
                    : lerpDouble(-.82, 0, _iconSlide.value)!;
                final charge = _surfaceCharge.value;
                final fillColor = Color.lerp(
                  buttonBaseColor,
                  buttonActiveColor,
                  .16 * charge,
                )!;
                final iconGlowScale = lerpDouble(1, 1.16, _iconGlow.value)!;
                final iconGlowOpacity = _isUnavailable
                    ? lerpDouble(.05, .10, _iconGlow.value)!
                    : lerpDouble(.08, .16, _iconGlow.value)!;
                final cartIconScale =
                    lerpDouble(.92, 1, _cartIconOpacity.value)!;
                final cartIconColor = Color.lerp(
                  labelColor.withValues(alpha: .86),
                  onPrimaryColor,
                  _iconSlide.value,
                )!;
                final checkIconColor = onPrimaryColor;

                return Transform.scale(
                  scaleY: heightScale,
                  child: SizedBox(
                    width: width,
                    height: widget.height,
                    child: RepaintBoundary(
                      child: Material(
                        color: transparentSurface,
                        child: InkWell(
                          onTap: _isDisabled ? null : _handlePressed,
                          borderRadius: BorderRadius.circular(radius),
                          splashColor: onPrimaryColor.withValues(alpha: .08),
                          highlightColor: transparentSurface,
                          child: Ink(
                            decoration: BoxDecoration(
                              color: fillColor,
                              borderRadius: BorderRadius.circular(radius),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(radius),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  IgnorePointer(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            onPrimaryColor.withValues(
                                              alpha: .08 + (.03 * charge),
                                            ),
                                            transparentOnPrimary,
                                            shadowColor.withValues(
                                              alpha: .05 + (.04 * charge),
                                            ),
                                          ],
                                          stops: const [0, .26, 1],
                                        ),
                                      ),
                                    ),
                                  ),
                                  IgnorePointer(
                                    child: Align(
                                      alignment: Alignment(_waveShift.value, 0),
                                      child: Transform.rotate(
                                        angle: -.22,
                                        child: Opacity(
                                          opacity: _waveOpacity.value,
                                          child: Container(
                                            width: width * .58,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                                colors: [
                                                  transparentOnPrimary,
                                                  onPrimaryColor.withValues(
                                                    alpha: .18,
                                                  ),
                                                  onPrimaryColor.withValues(
                                                    alpha: .42,
                                                  ),
                                                  onPrimaryColor.withValues(
                                                    alpha: .14,
                                                  ),
                                                  transparentOnPrimary,
                                                ],
                                                stops: const [
                                                  0,
                                                  .24,
                                                  .5,
                                                  .74,
                                                  1,
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (!widget.isLoading)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                      ),
                                      child: Align(
                                        alignment: Alignment(iconAlignmentX, 0),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Transform.scale(
                                              scale: iconGlowScale,
                                              child: Opacity(
                                                opacity: iconGlowOpacity,
                                                child: Container(
                                                  width: 34,
                                                  height: 34,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: onPrimaryColor
                                                        .withValues(
                                                      alpha: .10,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Transform.scale(
                                              scale: _iconScale.value,
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Transform.scale(
                                                    scale: cartIconScale,
                                                    child: Opacity(
                                                      opacity: _cartIconOpacity
                                                          .value,
                                                      child: Icon(
                                                        Icons
                                                            .shopping_cart_rounded,
                                                        size: 22,
                                                        color: cartIconColor,
                                                      ),
                                                    ),
                                                  ),
                                                  Transform.scale(
                                                    scale:
                                                        _checkIconScale.value,
                                                    child: Opacity(
                                                      opacity: _checkIconOpacity
                                                          .value,
                                                      child: Icon(
                                                        Icons.check_rounded,
                                                        size: 20,
                                                        color: checkIconColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    child: Center(
                                      child: widget.isLoading
                                          ? SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.4,
                                                color: onPrimaryColor,
                                                backgroundColor: onPrimaryColor
                                                    .withValues(alpha: .18),
                                              ),
                                            )
                                          : Transform.translate(
                                              offset:
                                                  Offset(0, _labelLift.value),
                                              child: Transform.scale(
                                                scale: _labelScale.value,
                                                child: Opacity(
                                                  opacity: _labelOpacity.value,
                                                  child: Text(
                                                    widget.label,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 14.5,
                                                      letterSpacing: .25,
                                                      color: labelColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

Color _shiftColor(
  Color color, {
  double lightnessDelta = 0,
  double saturationDelta = 0,
}) {
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withLightness((hsl.lightness + lightnessDelta).clamp(0.0, 1.0))
      .withSaturation((hsl.saturation + saturationDelta).clamp(0.0, 1.0))
      .toColor();
}
