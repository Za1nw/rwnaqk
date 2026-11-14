import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/support/controllers/help_center_service.dart';
import 'package:rwnaqk_frontend/modules/support/controllers/support_chat_service.dart';
import 'package:rwnaqk_frontend/modules/support/data/models/support_chat_message.dart';
import 'package:rwnaqk_frontend/modules/support/models/help_center_state.dart';
import 'package:rwnaqk_frontend/modules/support/models/support_chat_state.dart';
import 'package:rwnaqk_frontend/modules/support/views/support_chat_view.dart';

/// مزود خدمة مركز المساعدة والأسئلة الشائعة
final helpCenterServiceProvider = Provider<HelpCenterService>((ref) {
  return HelpCenterService();
});

/// مزود خدمة محادثات الدعم الفني
final supportChatServiceProvider = Provider<SupportChatService>((ref) {
  return SupportChatService();
});

/// موفر حالة مركز المساعدة [HelpCenterNotifier]
final helpCenterProvider =
    NotifierProvider<HelpCenterNotifier, HelpCenterState>(HelpCenterNotifier.new);

/// متحكم حالة مركز المساعدة المعتمد على Riverpod 3
class HelpCenterNotifier extends Notifier<HelpCenterState> {
  @override
  HelpCenterState build() {
    final service = ref.watch(helpCenterServiceProvider);
    return HelpCenterState(
      supportEntries: service.supportEntries(),
      contactEntries: service.contactEntries(),
      faqQuestions: service.faqQuestions(),
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  Future<bool> contactViaWhatsApp() async {
    final service = ref.read(helpCenterServiceProvider);
    return await service.launchWhatsApp();
  }

  Future<bool> contactViaEmail() async {
    final service = ref.read(helpCenterServiceProvider);
    return await service.launchEmail();
  }

  Future<bool> contactViaPhone() async {
    final service = ref.read(helpCenterServiceProvider);
    return await service.launchPhoneCall();
  }
}

/// موفر حالة محادثة الدعم [SupportChatNotifier]
final supportChatProvider =
    NotifierProvider<SupportChatNotifier, SupportChatState>(SupportChatNotifier.new);

/// متحكم حالة محادثة الدعم الفني المعتمد على Riverpod 3
class SupportChatNotifier extends Notifier<SupportChatState> {
  @override
  SupportChatState build() {
    final service = ref.watch(supportChatServiceProvider);
    return SupportChatState(
      messages: service.seedMessages(),
      title: Tk.helpCenterContactSupport,
      frequentQuestions: const [],
    );
  }

  void setArgs(SupportChatArgs args) {
    state = state.copyWith(
      title: args.title,
      frequentQuestions: args.frequentQuestions,
    );
  }

  bool sendMessage(String rawText) {
    final text = rawText.trim();
    if (text.isEmpty || state.isSubmitting) {
      return false;
    }

    final service = ref.read(supportChatServiceProvider);
    final newMessage = SupportChatMessage(
      text: text,
      time: service.timeLabel(DateTime.now()),
      isAgent: false,
    );

    state = state.copyWith(
      messages: [...state.messages, newMessage],
    );
    return true;
  }

  void clearMessages() {
    state = state.copyWith(messages: const []);
  }

  void resetToSeed() {
    final service = ref.read(supportChatServiceProvider);
    state = state.copyWith(messages: service.seedMessages());
  }
}

