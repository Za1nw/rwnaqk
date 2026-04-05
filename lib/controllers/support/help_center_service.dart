import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/screens/support_chat_screen.dart';

class HelpCenterEntry {
  final String title;
  final String subtitle;
  final String routeTitle;

  const HelpCenterEntry({
    required this.title,
    required this.subtitle,
    required this.routeTitle,
  });
}

class HelpCenterContactEntry {
  final String title;
  final String subtitle;

  const HelpCenterContactEntry({
    required this.title,
    required this.subtitle,
  });
}

class HelpCenterService {
  List<HelpCenterEntry> supportEntries() {
    return const [
      HelpCenterEntry(
        title: Tk.helpCenterOrderIssuesTitle,
        subtitle: Tk.helpCenterOrderIssuesSubtitle,
        routeTitle: Tk.helpCenterOrderIssuesTitle,
      ),
      HelpCenterEntry(
        title: Tk.helpCenterPaymentIssuesTitle,
        subtitle: Tk.helpCenterPaymentIssuesSubtitle,
        routeTitle: Tk.helpCenterPaymentIssuesTitle,
      ),
      HelpCenterEntry(
        title: Tk.helpCenterAccountIssuesTitle,
        subtitle: Tk.helpCenterAccountIssuesSubtitle,
        routeTitle: Tk.helpCenterAccountIssuesTitle,
      ),
    ];
  }

  List<HelpCenterContactEntry> contactEntries() {
    return const [
      HelpCenterContactEntry(
        title: Tk.helpCenterWhatsappTitle,
        subtitle: Tk.helpCenterWhatsappSubtitle,
      ),
      HelpCenterContactEntry(
        title: Tk.helpCenterEmailTitle,
        subtitle: Tk.helpCenterEmailSubtitle,
      ),
      HelpCenterContactEntry(
        title: Tk.helpCenterCallTitle,
        subtitle: Tk.helpCenterCallSubtitle,
      ),
    ];
  }

  List<String> faqQuestions() {
    return const [
      Tk.helpCenterFaqOrderQuestion,
      Tk.helpCenterFaqPaymentQuestion,
      Tk.helpCenterFaqAddressQuestion,
      Tk.helpCenterFaqRefundQuestion,
    ];
  }

  SupportChatArgs buildSupportArgs(String titleKey) {
    return SupportChatArgs(
      title: titleKey,
      frequentQuestions: faqQuestions(),
    );
  }
}
