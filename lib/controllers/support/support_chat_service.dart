import 'package:flutter/material.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/models/support_chat_message.dart';
import 'package:rwnaqk/widgets/help/support_quick_topics.dart';

class SupportChatService {
  List<SupportQuickTopic> quickTopics() {
    return const [
      SupportQuickTopic(
        label: Tk.supportChatOrders,
        icon: Icons.receipt_long_outlined,
      ),
      SupportQuickTopic(
        label: Tk.supportChatPayment,
        icon: Icons.account_balance_wallet_outlined,
      ),
      SupportQuickTopic(
        label: Tk.supportChatAddress,
        icon: Icons.location_on_outlined,
      ),
      SupportQuickTopic(
        label: Tk.supportChatGeneral,
        icon: Icons.chat_bubble_outline_rounded,
      ),
    ];
  }

  List<SupportChatMessage> seedMessages() {
    return const [
      SupportChatMessage(
        text: Tk.supportChatGreeting,
        time: '09:41',
        isAgent: true,
      ),
      SupportChatMessage(
        text: Tk.supportChatOrderPrompt,
        time: '09:42',
        isAgent: true,
      ),
      SupportChatMessage(
        text: '#ORD-483920',
        time: '09:43',
        isAgent: false,
      ),
      SupportChatMessage(
        text: Tk.ordersTrackingStatus,
        time: '09:44',
        isAgent: true,
      ),
    ];
  }

  String timeLabel(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
