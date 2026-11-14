import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_back_header.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_section_header.dart';
import 'package:rwnaqk_frontend/modules/support/providers/support_providers.dart';
import 'package:rwnaqk_frontend/modules/support/widgets/support_chat_composer.dart';
import 'package:rwnaqk_frontend/modules/support/widgets/support_chat_header_card.dart';
import 'package:rwnaqk_frontend/modules/support/widgets/support_message_bubble.dart';
import 'package:rwnaqk_frontend/modules/support/widgets/support_quick_topics.dart';

class SupportChatArgs {
  final String title;
  final List<String> frequentQuestions;

  const SupportChatArgs({
    required this.title,
    this.frequentQuestions = const [],
  });
}

/// شاشة محادثة الدعم الفني المباشرة
///
/// تمت هجرتها بالكامل إلى Riverpod 3 مع إزالة أي Obx أو GetxController
class SupportChatScreen extends ConsumerStatefulWidget {
  final SupportChatArgs? initialArgs;

  const SupportChatScreen({
    super.key,
    this.initialArgs,
  });

  @override
  ConsumerState<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends ConsumerState<SupportChatScreen> {
  late final TextEditingController _messageCtrl;
  late final ScrollController _messagesScrollCtrl;

  @override
  void initState() {
    super.initState();
    _messageCtrl = TextEditingController();
    _messagesScrollCtrl = ScrollController();

    // تهيئة عنوان المحادثة والأسئلة الشائعة من وسائط التوجيه
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final navArgs = ModalRoute.of(context)?.settings.arguments;
      final args = widget.initialArgs ?? _readArgs(navArgs);
      ref.read(supportChatProvider.notifier).setArgs(args);
    });
  }

  SupportChatArgs _readArgs(dynamic raw) {
    if (raw is SupportChatArgs) {
      return raw;
    }
    if (raw is String && raw.trim().isNotEmpty) {
      return SupportChatArgs(title: raw);
    }
    return const SupportChatArgs(title: Tk.helpCenterContactSupport);
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _messagesScrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_messagesScrollCtrl.hasClients) return;
      _messagesScrollCtrl.animateTo(
        _messagesScrollCtrl.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendMessage([String? preset]) {
    final text = (preset ?? _messageCtrl.text).trim();
    if (text.isEmpty) return;

    final sent = ref.read(supportChatProvider.notifier).sendMessage(text);
    if (sent) {
      _messageCtrl.clear();
      _scrollToBottom();
    }
  }

  void _selectQuickTopic(SupportQuickTopic topic) {
    final label = topic.label.tr;
    _messageCtrl.text = label;
    _messageCtrl.selection = TextSelection.collapsed(offset: label.length);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(supportChatProvider);
    final quickTopics = ref.watch(supportChatServiceProvider).quickTopics();

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
                    onBack: AppNav.back,
                    trailingIcon: Icons.more_horiz_rounded,
                  ),
                  const SizedBox(height: 14),
                  SupportChatHeaderCard(channelTitle: chatState.title.tr),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: _messagesScrollCtrl,
                padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 18, 12),
                children: [
                  AppSectionHeader(
                    title: Tk.supportChatQuickActions.tr,
                    titleFontSize: 12.5,
                    titleColor: context.muted,
                  ),
                  const SizedBox(height: 10),
                  SupportQuickTopics(
                    topics: quickTopics,
                    onTap: _selectQuickTopic,
                  ),
                  const SizedBox(height: 18),
                  ...chatState.messages.map(
                    (message) => SupportMessageBubble(
                      text: message.text,
                      time: message.time,
                      isAgent: message.isAgent,
                    ),
                  ),
                ],
              ),
            ),
            SupportChatComposer(
              controller: _messageCtrl,
              frequentQuestions: chatState.frequentQuestions,
              onQuestionTap: _sendMessage,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
