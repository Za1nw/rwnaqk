import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupportChatUiController extends GetxController {
  late final TextEditingController messageCtrl;
  late final ScrollController messagesScrollCtrl;

  @override
  void onInit() {
    super.onInit();
    messageCtrl = TextEditingController();
    messagesScrollCtrl = ScrollController();
  }

  void setDraft(String value) {
    messageCtrl.text = value;
    messageCtrl.selection = TextSelection.collapsed(offset: value.length);
  }

  void clearDraft() {
    messageCtrl.clear();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!messagesScrollCtrl.hasClients) return;
      messagesScrollCtrl.animateTo(
        messagesScrollCtrl.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void onClose() {
    messageCtrl.dispose();
    messagesScrollCtrl.dispose();
    super.onClose();
  }
}
