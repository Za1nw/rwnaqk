import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/app_settings_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/widgets/common/app_action_icon_button.dart';

import '../../controllers/main_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../widgets/settings/settings_list_tile.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppSettingsController>();
    final main =
        Get.isRegistered<MainController>() ? Get.find<MainController>() : null;

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 18),
          children: [
            _TopBar(
              title: 'Settings'.tr,
              onBack: () {
                if (main != null) {
                  main.changeTab(0); // رجّعه Home
                } else {
                  Get.back();
                }
              },
            ),
            const SizedBox(height: 14),

            _ProfileHeaderCard(
              name: 'Eng Zain'.tr,
              phone: '+967 7xx xxx xxx'.tr,
              onEdit: () => Get.toNamed(AppRoutes.editProfile),
            ),

            const SizedBox(height: 16),

            _SectionTitle(title: 'Account'.tr),
            const SizedBox(height: 10),

            SettingsListTile(
              icon: Icons.person_outline_rounded,
              title: 'Profile'.tr,
              subtitle: 'Edit your info'.tr,
              onTap: () {
                // Get.toNamed(AppRoutes.profile);
              },
            ),
            const SizedBox(height: 10),

            SettingsListTile(
              icon: Icons.location_on_outlined,
              title: 'Addresses'.tr,
              subtitle: 'Manage shipping addresses'.tr,
              onTap: () => Get.toNamed(AppRoutes.addresses),
            ),

            const SizedBox(height: 18),

            _SectionTitle(title: 'Preferences'.tr),
            const SizedBox(height: 10),

            // ===== Theme (Switch فقط)
            Obx(() {
              final isDark = app.themeMode.value == ThemeMode.dark;

              return SettingsListTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark mode'.tr,
                subtitle: 'Switch theme'.tr,
                trailingMaxWidth: 90,
                trailing: Switch(
                  value: isDark,
                  onChanged: (_) => app.toggleTheme(),
                ),
                tapWholeTile: false, // ✅ مهم عشان السويتش ما يعلق
                showChevron: false,
              );
            }),

            const SizedBox(height: 10),

            // ===== Language (الصف كامل tappable + badge ثابت)
            SettingsListTile(
              icon: Icons.language_outlined,
              title: 'Language'.tr,
              subtitle: 'Arabic / English'.tr,
              trailingMaxWidth: 95,
              trailing: Obx(() {
                final code = app.locale.value.languageCode.toUpperCase();
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.primary.withOpacity(.08),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: context.primary.withOpacity(.18)),
                  ),
                  child: Text(
                    code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                );
              }),
              onTap: app.toggleLanguage,
              tapWholeTile: true,
              showChevron: true,
            ),

            const SizedBox(height: 18),

            _SectionTitle(title: 'Support'.tr),
            const SizedBox(height: 10),

            SettingsListTile(
              icon: Icons.help_outline_rounded,
              title: 'Help Center'.tr,
              subtitle: 'FAQs & support'.tr,
              onTap: () {},
            ),

            const SizedBox(height: 18),

            _SectionTitle(title: 'Danger zone'.tr),
            const SizedBox(height: 10),

            SettingsListTile(
              icon: Icons.logout_rounded,
              title: 'Logout'.tr,
              subtitle: 'Sign out of your account'.tr,
              trailingMaxWidth: 60,
              trailing: Icon(
                Icons.logout_rounded,
                color: Colors.redAccent.withOpacity(.95),
                size: 20,
              ),
              showChevron: false,
              onTap: () => Get.snackbar('Logout'.tr, 'Mock action'.tr),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================= UI Pieces =========================

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _TopBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppActionIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: onBack,
          backgroundColor: context.card,
          iconColor: context.foreground,
          borderColor: context.border.withOpacity(.35),
          size: 40,
          radius: 14,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: context.foreground,
            ),
          ),
        ),
        AppActionIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: () {},
          backgroundColor: context.card,
          iconColor: context.foreground,
          borderColor: context.border.withOpacity(.35),
          size: 40,
          radius: 14,
        ),
      ],
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String phone;
  final VoidCallback onEdit;

  const _ProfileHeaderCard({
    required this.name,
    required this.phone,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: context.border.withOpacity(.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: context.input,
                shape: BoxShape.circle,
                border: Border.all(color: context.border.withOpacity(.35)),
              ),
              child: Icon(Icons.person_rounded, color: context.foreground),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.foreground,
                      fontWeight: FontWeight.w900,
                      fontSize: 15.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: Colors.transparent,
              child: Ink(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: context.input,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.border.withOpacity(.35)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: onEdit,
                  child: Row(
                    children: [
                      Icon(Icons.edit_rounded,
                          size: 18, color: context.foreground),
                      const SizedBox(width: 6),
                      Text(
                        'Edit'.tr,
                        style: TextStyle(
                          color: context.foreground,
                          fontWeight: FontWeight.w900,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: context.muted,
        fontWeight: FontWeight.w900,
        fontSize: 12.5,
        letterSpacing: .2,
      ),
    );
  }
}