import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/support/support_chat_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/widgets/common/app_back_header.dart';
import 'package:rwnaqk/widgets/common/app_section_header.dart';
import 'package:rwnaqk/widgets/help/support_chat_composer.dart';
import 'package:rwnaqk/widgets/help/support_chat_header_card.dart';
import 'package:rwnaqk/widgets/help/support_message_bubble.dart';
import 'package:rwnaqk/widgets/help/support_quick_topics.dart';

class SupportChatArgs {
  final String title;
  final List<String> frequentQuestions;

  const SupportChatArgs({
    required this.title,
    this.frequentQuestions = const [],
  });
}

class SupportChatScreen extends GetView<SupportChatController> {
  const SupportChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 12),
              child: Column(
                children: [
                  AppBackHeader(
                    title: Tk.supportChatTitle.tr,
                    onBack: Get.back,
                    trailingIcon: Icons.more_horiz_rounded,
                  ),
                  const SizedBox(height: 14),
                  SupportChatHeaderCard(channelTitle: controller.channelTitle),
                ],
              ),
            ),
            Expanded(
              child: Obx(
                () => ListView(
                  controller: controller.messagesScrollCtrl,
                  padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 18, 12),
                  children: [
                    AppSectionHeader(
                      title: Tk.supportChatQuickActions.tr,
                      titleFontSize: 12.5,
                      titleColor: context.muted,
                    ),
                    const SizedBox(height: 10),
                    SupportQuickTopics(
                      topics: controller.quickTopics,
                      onTap: controller.selectQuickTopic,
                    ),
                    const SizedBox(height: 18),
                    ...controller.messages.map(
                      (message) => SupportMessageBubble(
                        text: message.text,
                        time: message.time,
                        isAgent: message.isAgent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SupportChatComposer(
              controller: controller.messageCtrl,
              frequentQuestions: controller.frequentQuestions,
              onQuestionTap: controller.sendMessage,
              onSend: controller.sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
