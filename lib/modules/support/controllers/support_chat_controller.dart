import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/modules/support/controllers/support_chat_service.dart';
import 'package:rwnaqk_frontend/modules/support/controllers/support_chat_ui_controller.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/support/data/models/support_chat_message.dart';
import 'package:rwnaqk_frontend/modules/support/views/support_chat_view.dart';
import 'package:rwnaqk_frontend/modules/support/widgets/support_quick_topics.dart';

class SupportChatController extends GetxController {
  SupportChatController(this._service);

  final SupportChatService _service;

  late final SupportChatUiController ui;

  final messages = <SupportChatMessage>[].obs;
  late final SupportChatArgs args;

  TextEditingController get messageCtrl => ui.messageCtrl;
  ScrollController get messagesScrollCtrl => ui.messagesScrollCtrl;

  List<SupportQuickTopic> get quickTopics => _service.quickTopics();
  List<String> get frequentQuestions => args.frequentQuestions;
  String get channelTitle => args.title.tr;

  @override
  void onInit() {
    super.onInit();
    ui = Get.find<SupportChatUiController>();
    args = _readArgs(Get.arguments);
    messages.assignAll(_service.seedMessages());
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

  void selectQuickTopic(SupportQuickTopic topic) {
    ui.setDraft(topic.label.tr);
  }

  void sendMessage([String? preset]) {
    final text = (preset ?? messageCtrl.text).trim();
    if (text.isEmpty) return;

    messages.add(
      SupportChatMessage(
        text: text,
        time: _service.timeLabel(DateTime.now()),
        isAgent: false,
      ),
    );

    ui.clearDraft();
    ui.scrollToBottom();
  }
}
