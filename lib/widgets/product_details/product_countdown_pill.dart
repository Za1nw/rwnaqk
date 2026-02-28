import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class ProductCountdownPill extends StatefulWidget {
  final DateTime endsAt;
  final VoidCallback? onFinished;

  const ProductCountdownPill({
    super.key,
    required this.endsAt,
    this.onFinished,
  });

  @override
  State<ProductCountdownPill> createState() => _ProductCountdownPillState();
}

class _ProductCountdownPillState extends State<ProductCountdownPill> {
  Timer? _t;
  Duration _left = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _t = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final d = widget.endsAt.difference(DateTime.now());
    final next = d.isNegative ? Duration.zero : d;

    if (!mounted) return;
    setState(() => _left = next);

    if (next == Duration.zero) {
      _t?.cancel();
      widget.onFinished?.call();
    }
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = _left.inHours;
    final m = _left.inMinutes.remainder(60);
    final s = _left.inSeconds.remainder(60);

    String two(int v) => v.toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.border.withOpacity(0.55)),
        boxShadow: [
          BoxShadow(
            color: context.shadow.withOpacity(context.isDark ? 0.16 : 0.07),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_rounded, size: 16, color: context.primary),
          const SizedBox(width: 8),
          _TimeChip(text: two(h)),
          const SizedBox(width: 6),
          _TimeChip(text: two(m)),
          const SizedBox(width: 6),
          _TimeChip(text: two(s)),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String text;
  const _TimeChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: context.background.withOpacity(context.isDark ? 0.20 : 0.75),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: context.border.withOpacity(0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: context.foreground,
          fontWeight: FontWeight.w900,
          fontSize: 11.5,
          height: 1.0,
        ),
      ),
    );
  }
}