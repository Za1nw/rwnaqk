import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class HelpFaqCard extends StatefulWidget {
  final String question;
  final String answer;

  const HelpFaqCard({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<HelpFaqCard> createState() => _HelpFaqCardState();
}

class _HelpFaqCardState extends State<HelpFaqCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: (_expanded ? context.primary : context.border).withOpacity(.35),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: TextStyle(
                        color: context.foreground,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: context.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 10),
                Text(
                  widget.answer,
                  style: TextStyle(
                    color: context.mutedForeground,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.8,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
