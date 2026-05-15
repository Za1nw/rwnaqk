import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/widgets/common/app_sectioned_page.dart';

class LegalDocumentsScreen extends StatelessWidget {
  const LegalDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSectionedPage(
      title: Tk.legalTitle.tr,
      onBack: Get.back,
      trailingIcon: Icons.verified_user_outlined,
      children: const [
        _LegalHeroCard(),
        SizedBox(height: 18),
        _LegalSectionCard(
          icon: Icons.gavel_rounded,
          titleKey: Tk.legalTermsTitle,
          introKey: Tk.legalTermsIntro,
          bulletKeys: [
            Tk.legalTermsBullet1,
            Tk.legalTermsBullet2,
            Tk.legalTermsBullet3,
          ],
        ),
        SizedBox(height: 14),
        _LegalSectionCard(
          icon: Icons.privacy_tip_outlined,
          titleKey: Tk.legalConsentTitle,
          introKey: Tk.legalConsentIntro,
          bulletKeys: [
            Tk.legalConsentBullet1,
            Tk.legalConsentBullet2,
            Tk.legalConsentBullet3,
          ],
        ),
        SizedBox(height: 14),
        _LegalNoticeCard(),
      ],
    );
  }
}

class _LegalHeroCard extends StatelessWidget {
  const _LegalHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.primary.withValues(alpha: context.isDark ? 0.14 : 0.10),
            context.card,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              context.primary.withValues(alpha: context.isDark ? 0.20 : 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color:
                context.shadow.withValues(alpha: context.isDark ? 0.12 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: context.primary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.policy_rounded,
              color: context.primaryForeground,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Tk.legalTitle.tr,
                  style: TextStyle(
                    color: context.foreground,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  Tk.legalSubtitle.tr,
                  style: TextStyle(
                    color: context.mutedForeground,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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

class _LegalSectionCard extends StatelessWidget {
  final IconData icon;
  final String titleKey;
  final String introKey;
  final List<String> bulletKeys;

  const _LegalSectionCard({
    required this.icon,
    required this.titleKey,
    required this.introKey,
    required this.bulletKeys,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: context.border.withValues(alpha: context.isDark ? 0.38 : 0.52),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: context.primary.withValues(alpha: 0.16),
                  ),
                ),
                child: Icon(icon, color: context.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titleKey.tr,
                  style: TextStyle(
                    color: context.foreground,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            introKey.tr,
            style: TextStyle(
              color: context.mutedForeground,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 14),
          ...bulletKeys.map(_LegalBullet.new),
        ],
      ),
    );
  }
}

class _LegalBullet extends StatelessWidget {
  final String textKey;

  const _LegalBullet(this.textKey);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: context.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              textKey.tr,
              style: TextStyle(
                color: context.foreground,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalNoticeCard extends StatelessWidget {
  const _LegalNoticeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: context.isDark ? 0.10 : 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              context.primary.withValues(alpha: context.isDark ? 0.18 : 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: context.primary,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Tk.legalNoticeTitle.tr,
                  style: TextStyle(
                    color: context.foreground,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  Tk.legalNoticeBody.tr,
                  style: TextStyle(
                    color: context.mutedForeground,
                    fontSize: 12.8,
                    fontWeight: FontWeight.w600,
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
