import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/widgets/app_button.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_section_header.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_sectioned_page.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/settings_sections.dart';
import 'package:rwnaqk_frontend/modules/support/providers/support_providers.dart';
import 'package:rwnaqk_frontend/modules/support/widgets/help_contact_tile.dart';
import 'package:rwnaqk_frontend/modules/support/widgets/help_faq_card.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

/// شاشة مركز المساعدة والأسئلة الشائعة
///
/// تمت هجرتها بنجاح إلى Riverpod 3 مع الإبقاء على توافقية الملاحة والترجمة
class HelpCenterScreen extends ConsumerWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(helpCenterProvider);
    final supportEntries = state.supportEntries;
    final contactEntries = state.contactEntries;
    final faqQuestions = state.faqQuestions;

    void openSupport(String titleKey) {
      final service = ref.read(helpCenterServiceProvider);
      AppNav.toNamed(
        AppRoutes.supportChat,
        arguments: service.buildSupportArgs(titleKey),
      );
    }

    return AppSectionedPage(
      title: Tk.helpCenterTitle.tr,
      onBack: AppNav.back,
      trailingIcon: Icons.support_agent_rounded,
      children: [
        _HeroCard(
          title: Tk.helpCenterTitle.tr,
          subtitle: Tk.helpCenterSubtitle.tr,
        ),
        const SizedBox(height: 18),
        SettingsSections(
          sections: [
            SettingsSectionSpec(
              title: Tk.helpCenterQuickActions.tr,
              tiles: [
                SettingsTileSpec(
                  icon: Icons.receipt_long_outlined,
                  title: supportEntries[0].title.tr,
                  subtitle: supportEntries[0].subtitle.tr,
                  onTap: () => openSupport(supportEntries[0].routeTitle),
                ),
                SettingsTileSpec(
                  icon: Icons.account_balance_wallet_outlined,
                  title: supportEntries[1].title.tr,
                  subtitle: supportEntries[1].subtitle.tr,
                  onTap: () => openSupport(supportEntries[1].routeTitle),
                ),
                SettingsTileSpec(
                  icon: Icons.manage_accounts_outlined,
                  title: supportEntries[2].title.tr,
                  subtitle: supportEntries[2].subtitle.tr,
                  onTap: () => openSupport(supportEntries[2].routeTitle),
                ),
              ],
            ),
          ],
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
          onTap: () => openSupport(contactEntries[0].title),
        ),
        const SizedBox(height: 10),
        HelpContactTile(
          icon: Icons.mail_outline_rounded,
          title: contactEntries[1].title.tr,
          subtitle: contactEntries[1].subtitle.tr,
          onTap: () => openSupport(contactEntries[1].title),
        ),
        const SizedBox(height: 10),
        HelpContactTile(
          icon: Icons.phone_outlined,
          title: contactEntries[2].title.tr,
          subtitle: contactEntries[2].subtitle.tr,
          onTap: () => openSupport(contactEntries[2].title),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.border.withValues(alpha: .35)),
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
                onPressed: () => openSupport(Tk.helpCenterContactSupport),
              ),
            ],
          ),
        ),
      ],
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
            context.primary.withValues(alpha: .12),
            context.card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.primary.withValues(alpha: .16)),
        boxShadow: [
          BoxShadow(
            color: context.shadow.withValues(alpha: .05),
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
