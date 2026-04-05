import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class SupportMessageBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isAgent;

  const SupportMessageBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isAgent,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isAgent
        ? context.card
        : context.primary.withOpacity(context.isDark ? .22 : .12);
    final textColor = isAgent ? context.foreground : context.primary;

    return Align(
      alignment:
          isAgent ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadiusDirectional.only(
              topStart: const Radius.circular(18),
              topEnd: const Radius.circular(18),
              bottomStart: Radius.circular(isAgent ? 6 : 18),
              bottomEnd: Radius.circular(isAgent ? 18 : 6),
            ),
            border: Border.all(
              color: (isAgent ? context.border : context.primary).withOpacity(.22),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                isAgent ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                time,
                style: TextStyle(
                  color: context.mutedForeground,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
