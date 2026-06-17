import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

enum AppToastType { success, info, warning, error, neutral }

class AppToast {
  AppToast._();

  static OverlayEntry? _currentEntry;
  static Timer? _hideTimer;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    AppToastType type = AppToastType.neutral,
    Duration duration = const Duration(seconds: 3),
    bool dismissible = true,
    bool showIcon = true,
    VoidCallback? onTap,
  }) async {
    // إزالة أي toast موجود حالياً
    _hideTimer?.cancel();
    _currentEntry?.remove();

    final overlay = Overlay.of(context, rootOverlay: true);

    final entry = OverlayEntry(
      builder: (overlayContext) {
        return _ToastEntry(
          title: title,
          message: message,
          type: type,
          duration: duration,
          dismissible: dismissible,
          showIcon: showIcon,
          onTap: onTap,
          onDismissed: () {
            _currentEntry = null;
            _hideTimer?.cancel();
          },
        );
      },
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  static void dismiss() {
    _hideTimer?.cancel();
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _ToastEntry extends StatefulWidget {
  final String title;
  final String message;
  final AppToastType type;
  final Duration duration;
  final bool dismissible;
  final bool showIcon;
  final VoidCallback? onTap;
  final VoidCallback onDismissed;

  const _ToastEntry({
    Key? key,
    required this.title,
    required this.message,
    required this.type,
    required this.duration,
    required this.dismissible,
    required this.showIcon,
    this.onTap,
    required this.onDismissed,
  }) : super(key: key);

  @override
  State<_ToastEntry> createState() => _ToastEntryState();
}

class _ToastEntryState extends State<_ToastEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  Timer? _autoDismissTimer;
  double _dragOffset = 0;
  bool _isDismissing = false;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // أنيمشن السحب من الأسفل
    _slide = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    // أنيمشن الظهور التدريجي
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);

    // أنيمشن التكبير للخلفية
    _scale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
    _startAutoDismissTimer();
  }

  void _startAutoDismissTimer() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = Timer(widget.duration, _dismiss);
  }

  void _pauseAutoDismiss() {
    _autoDismissTimer?.cancel();
  }

  void _resumeAutoDismiss() {
    if (!_isDismissing) {
      _autoDismissTimer = Timer(widget.duration, _dismiss);
    }
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_isDismissing) return;
    _isDismissing = true;
    _autoDismissTimer?.cancel();
    _controller.reverse().then((_) {
      widget.onDismissed();
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!widget.dismissible) return;
    setState(() {
      _dragOffset += details.delta.dx;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!widget.dismissible) return;
    if (_dragOffset.abs() > 80 || (details.primaryVelocity?.abs() ?? 0) > 400) {
      _dismiss();
    } else {
      setState(() {
        _dragOffset = 0;
      });
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    final isDark = context.isDark;

    switch (widget.type) {
      case AppToastType.success:
        return isDark ? const Color(0xFF1A3A2A) : const Color(0xFFE8F5E9);
      case AppToastType.info:
        return isDark ? const Color(0xFF0A2A3A) : const Color(0xFFE3F2FD);
      case AppToastType.warning:
        return isDark ? const Color(0xFF3A2A0A) : const Color(0xFFFFF3E0);
      case AppToastType.error:
        return isDark ? const Color(0xFF3A1A1A) : const Color(0xFFFFEBEE);
      case AppToastType.neutral:
        return isDark ? context.card : context.card;
    }
  }

  Color _getAccentColor(BuildContext context) {
    switch (widget.type) {
      case AppToastType.success:
        return context.success;
      case AppToastType.info:
        return context.info;
      case AppToastType.warning:
        return context.warning;
      case AppToastType.error:
        return context.destructive;
      case AppToastType.neutral:
        return context.primary;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case AppToastType.success:
        return Icons.check_circle_rounded;
      case AppToastType.info:
        return Icons.info_rounded;
      case AppToastType.warning:
        return Icons.warning_amber_rounded;
      case AppToastType.error:
        return Icons.error_outline_rounded;
      case AppToastType.neutral:
        return Icons.notifications_rounded;
    }
  }

  Widget _buildAnimatedIcon(BuildContext context) {
    final accent = _getAccentColor(context);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withOpacity(0.15), accent.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.2), width: 1.5),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Icon(
          _getIcon(),
          key: ValueKey(widget.type),
          color: accent,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final accent = _getAccentColor(context);

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 1.0, end: 0.0),
      duration: widget.duration,
      builder: (context, value, child) {
        return LinearProgressIndicator(
          value: value,
          backgroundColor: accent.withOpacity(0.15),
          valueColor: AlwaysStoppedAnimation<Color>(accent),
          borderRadius: BorderRadius.circular(2),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final background = _getBackgroundColor(context);
    final accent = _getAccentColor(context);
    final textColor = context.isDark ? Colors.white : context.foreground;
    final borderColor = accent.withOpacity(context.isDark ? 0.25 : 0.15);

    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Transform.translate(
              offset: Offset(_dragOffset, 0),
              child: MouseRegion(
                onEnter: (_) {
                  if (widget.dismissible) {
                    setState(() => _isHovering = true);
                    _pauseAutoDismiss();
                  }
                },
                onExit: (_) {
                  if (widget.dismissible) {
                    setState(() => _isHovering = false);
                    _resumeAutoDismiss();
                  }
                },
                child: GestureDetector(
                  onTap: widget.onTap,
                  onPanUpdate: _handleDragUpdate,
                  onPanEnd: _handleDragEnd,
                  child: Material(
                    color: Colors.transparent,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      // في حالة toast الكامل، استخدم هذا التصحيح:
                      transform: _isHovering
                          ? Matrix4.translationValues(0.0, -2.0, 0.0)
                          : Matrix4.identity(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withOpacity(0.25),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                              spreadRadius: -2,
                            ),
                            BoxShadow(
                              color: context.shadow.withOpacity(0.1),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // شريط التقدم
                              _buildProgressBar(context),

                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // الأيقونة المتألقة
                                    if (widget.showIcon) ...[
                                      _buildAnimatedIcon(context),
                                      const SizedBox(width: 14),
                                    ],

                                    // النص
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  widget.title,
                                                  style: TextStyle(
                                                    color: accent,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w800,
                                                    height: 1.3,
                                                    letterSpacing: -0.3,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (widget.dismissible &&
                                                  !_isHovering) ...[
                                                const SizedBox(width: 8),
                                                TweenAnimationBuilder(
                                                  tween: Tween<double>(
                                                    begin: 0,
                                                    end: 1,
                                                  ),
                                                  duration: const Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  builder:
                                                      (context, value, child) {
                                                        return Transform.scale(
                                                          scale: value,
                                                          child: child,
                                                        );
                                                      },
                                                  child: InkWell(
                                                    onTap: _dismiss,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4,
                                                          ),
                                                      child: Icon(
                                                        Icons.close_rounded,
                                                        size: 16,
                                                        color: textColor
                                                            .withOpacity(0.5),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            widget.message,
                                            style: TextStyle(
                                              color: textColor.withOpacity(
                                                0.85,
                                              ),
                                              fontSize: 13,
                                              height: 1.4,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
            ),
          ),
        ),
      ),
    );
  }
}

// Extension للاستخدام السهل
extension AppToastExtension on BuildContext {
  void showSuccessToast({required String title, required String message}) {
    AppToast.show(
      this,
      title: title,
      message: message,
      type: AppToastType.success,
    );
  }

  void showErrorToast({required String title, required String message}) {
    AppToast.show(
      this,
      title: title,
      message: message,
      type: AppToastType.error,
    );
  }

  void showWarningToast({required String title, required String message}) {
    AppToast.show(
      this,
      title: title,
      message: message,
      type: AppToastType.warning,
    );
  }

  void showInfoToast({required String title, required String message}) {
    AppToast.show(
      this,
      title: title,
      message: message,
      type: AppToastType.info,
    );
  }

  void showNeutralToast({required String title, required String message}) {
    AppToast.show(
      this,
      title: title,
      message: message,
      type: AppToastType.neutral,
    );
  }
}
