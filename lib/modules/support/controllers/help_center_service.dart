import 'package:url_launcher/url_launcher.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/support/views/support_chat_view.dart';

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
  HelpCenterService({
    this.urlLauncher,
  });

  final Future<bool> Function(Uri uri, {LaunchMode mode})? urlLauncher;

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

  /// فتح محادثة WhatsApp مباشرة للتواصل السريع مع خدمة العملاء
  Future<bool> launchWhatsApp({
    String phone = '+967770000000',
    String message = 'مرحباً خدمة عملاء رونقك، لدي استفسار',
  }) async {
    final sanitizedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final encodedMessage = Uri.encodeComponent(message);
    final uri = Uri.parse('https://wa.me/$sanitizedPhone?text=$encodedMessage');

    if (urlLauncher != null) {
      return urlLauncher!(uri, mode: LaunchMode.externalApplication);
    }
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// فتح تطبيق البريد الإلكتروني لإرسال تذكرة دعم
  Future<bool> launchEmail({
    String email = 'support@rawnaqk.com',
    String subject = 'طلب مساعدة - تطبيق رونقك',
    String body = '',
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        if (body.isNotEmpty) 'body': body,
      },
    );

    if (urlLauncher != null) {
      return urlLauncher!(uri, mode: LaunchMode.platformDefault);
    }
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  /// فتح تطبيق الاتصال الهاتفي المباشر
  Future<bool> launchPhoneCall({String phone = '+967770000000'}) async {
    final uri = Uri(scheme: 'tel', path: phone);

    if (urlLauncher != null) {
      return urlLauncher!(uri, mode: LaunchMode.platformDefault);
    }
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }
}
