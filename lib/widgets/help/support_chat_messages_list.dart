import 'package:flutter/material.dart';
import 'package:rwnaqk/models/support_chat_message.dart';
import 'package:rwnaqk/widgets/help/support_message_bubble.dart';

class SupportChatMessagesList extends StatelessWidget {
  final ScrollController? controller;
  final EdgeInsetsGeometry padding;
  final List<SupportChatMessage> messages;

  const SupportChatMessagesList({
    super.key,
    this.controller,
    required this.messages,
    this.padding = const EdgeInsetsDirectional.fromSTEB(18, 0, 18, 12),
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: padding,
      children: messages
          .map(
            (message) => SupportMessageBubble(
              text: message.text,
              time: message.time,
              isAgent: message.isAgent,
            ),
          )
          .toList(growable: false),
    );
  }
}
