import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/support/data/models/support_chat_message.dart';

/// نموذج الحالة غير القابل للتعديل لشاشة المحادثة والدعم [SupportChatScreen].
class SupportChatState {
  final List<SupportChatMessage> messages;
  final String title;
  final List<String> frequentQuestions;
  final bool isSubmitting;
  final String? errorMessage;

  const SupportChatState({
    required this.messages,
    this.title = Tk.helpCenterContactSupport,
    this.frequentQuestions = const [],
    this.isSubmitting = false,
    this.errorMessage,
  });

  SupportChatState copyWith({
    List<SupportChatMessage>? messages,
    String? title,
    List<String>? frequentQuestions,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return SupportChatState(
      messages: messages ?? this.messages,
      title: title ?? this.title,
      frequentQuestions: frequentQuestions ?? this.frequentQuestions,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

