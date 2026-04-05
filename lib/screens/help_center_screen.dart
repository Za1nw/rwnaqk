import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/support/help_center_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/widgets/app_button.dart';
import 'package:rwnaqk/widgets/common/app_back_header.dart';
import 'package:rwnaqk/widgets/common/app_section_header.dart';
import 'package:rwnaqk/widgets/help/help_contact_tile.dart';
import 'package:rwnaqk/widgets/help/help_faq_card.dart';
import 'package:rwnaqk/widgets/settings/settings_list_tile.dart';

class HelpCenterScreen extends GetView<HelpCenterController> {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supportEntries = controller.supportEntries;
    final contactEntries = controller.contactEntries;
    final faqQuestions = controller.faqQuestions;

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 18),
          children: [
            AppBackHeader(
              title: Tk.helpCenterTitle.tr,
              onBack: Get.back,
              trailingIcon: Icons.support_agent_rounded,
            ),
            const SizedBox(height: 14),
            _HeroCard(
              title: Tk.helpCenterTitle.tr,
              subtitle: Tk.helpCenterSubtitle.tr,
            ),
            const SizedBox(height: 18),
            AppSectionHeader(
              title: Tk.helpCenterQuickActions.tr,
              titleFontSize: 12.5,
              titleColor: context.muted,
            ),
            const SizedBox(height: 10),
            SettingsListTile(
              icon: Icons.receipt_long_outlined,
              title: supportEntries[0].title.tr,
              subtitle: supportEntries[0].subtitle.tr,
              onTap: () => controller.openSupport(supportEntries[0].routeTitle),
            ),
            const SizedBox(height: 10),
            SettingsListTile(
              icon: Icons.account_balance_wallet_outlined,
              title: supportEntries[1].title.tr,
              subtitle: supportEntries[1].subtitle.tr,
              onTap: () => controller.openSupport(supportEntries[1].routeTitle),
            ),
            const SizedBox(height: 10),
            SettingsListTile(
              icon: Icons.manage_accounts_outlined,
              title: supportEntries[2].title.tr,
              subtitle: supportEntries[2].subtitle.tr,
              onTap: () => controller.openSupport(supportEntries[2].routeTitle),
            ),
            const SizedBox(height: 18),
            AppSectionHeader(
              title: Tk.helpCenterFaq.tr,
              titleFontSize: 12.5,
              titleColor: context.muted,
            ),
            const SizedBox(height: 10),
            HelpFaqCard(
              question: faqQuestions[0].tr,
              answer: Tk.helpCenterFaqOrderAnswer.tr,
            ),
            const SizedBox(height: 10),
            HelpFaqCard(
              question: faqQuestions[1].tr,
              answer: Tk.helpCenterFaqPaymentAnswer.tr,
            ),
            const SizedBox(height: 10),
            HelpFaqCard(
              question: faqQuestions[2].tr,
              answer: Tk.helpCenterFaqAddressAnswer.tr,
            ),
            const SizedBox(height: 10),
            HelpFaqCard(
              question: faqQuestions[3].tr,
              answer: Tk.helpCenterFaqRefundAnswer.tr,
            ),
            const SizedBox(height: 18),
            AppSectionHeader(
              title: Tk.helpCenterStillNeedHelp.tr,
              titleFontSize: 12.5,
              titleColor: context.muted,
            ),
            const SizedBox(height: 10),
            HelpContactTile(
              icon: Icons.chat_bubble_outline_rounded,
              title: contactEntries[0].title.tr,
              subtitle: contactEntries[0].subtitle.tr,
              onTap: () => controller.openSupport(contactEntries[0].title),
            ),
            const SizedBox(height: 10),
            HelpContactTile(
              icon: Icons.mail_outline_rounded,
              title: contactEntries[1].title.tr,
              subtitle: contactEntries[1].subtitle.tr,
              onTap: () => controller.openSupport(contactEntries[1].title),
            ),
            const SizedBox(height: 10),
            HelpContactTile(
              icon: Icons.phone_outlined,
              title: contactEntries[2].title.tr,
              subtitle: contactEntries[2].subtitle.tr,
              onTap: () => controller.openSupport(contactEntries[2].title),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.border.withOpacity(.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Tk.helpCenterResponseTime.tr,
                    style: TextStyle(
                      color: context.mutedForeground,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: Tk.helpCenterContactSupport.tr,
                    icon: Icons.support_agent_rounded,
                    onPressed: controller.openDefaultSupport,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeroCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.primary.withOpacity(.12),
            context.card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.primary.withOpacity(.16)),
        boxShadow: [
          BoxShadow(
            color: context.shadow.withOpacity(.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.support_agent_rounded,
              color: context.primaryForeground,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.foreground,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.mutedForeground,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
