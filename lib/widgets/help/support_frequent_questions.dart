import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class SupportFrequentQuestions extends StatelessWidget {
  final String title;
  final List<String> questions;
  final ValueChanged<String> onQuestionTap;

  const SupportFrequentQuestions({
    super.key,
    required this.title,
    required this.questions,
    required this.onQuestionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            title,
            style: TextStyle(
              color: context.mutedForeground,
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: questions
                .map(
                  (question) => Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => onQuestionTap(question),
                      child: Container(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 10),
                        decoration: BoxDecoration(
                          color: context.primary.withOpacity(.08),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: context.primary.withOpacity(.18),
                          ),
                        ),
                        child: Text(
                          question,
                          style: TextStyle(
                            color: context.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }
}
