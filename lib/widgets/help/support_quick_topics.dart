import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class SupportQuickTopic {
  final String label;
  final IconData icon;

  const SupportQuickTopic({
    required this.label,
    required this.icon,
  });
}

class SupportQuickTopics extends StatelessWidget {
  final List<SupportQuickTopic> topics;
  final ValueChanged<SupportQuickTopic> onTap;

  const SupportQuickTopics({
    super.key,
    required this.topics,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: topics
          .map(
            (topic) => InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => onTap(topic),
              child: Container(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: context.card,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: context.border.withOpacity(.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(topic.icon, color: context.primary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      topic.label,
                      style: TextStyle(
                        color: context.foreground,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
