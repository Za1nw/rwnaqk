import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/widgets/help/support_frequent_questions.dart';

class SupportChatComposer extends StatelessWidget {
  final TextEditingController controller;
  final List<String> frequentQuestions;
  final ValueChanged<String> onQuestionTap;
  final VoidCallback onSend;

  const SupportChatComposer({
    super.key,
    required this.controller,
    required this.frequentQuestions,
    required this.onQuestionTap,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 18),
      decoration: BoxDecoration(
        color: context.card,
        border: Border(top: BorderSide(color: context.border.withOpacity(.3))),
      ),
      child: Column(
        children: [
          SupportFrequentQuestions(
            title: Tk.supportChatQuickActions.tr,
            questions: frequentQuestions,
            onQuestionTap: onQuestionTap,
          ),
          if (frequentQuestions.isNotEmpty) const SizedBox(height: 12),
          Container(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 8, 8),
            decoration: BoxDecoration(
              color: context.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.border.withOpacity(.35)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    style: TextStyle(
                      color: context.foreground,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: Tk.supportChatHint.tr,
                      hintStyle: TextStyle(
                        color: context.mutedForeground,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: onSend,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: context.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      color: context.primaryForeground,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
