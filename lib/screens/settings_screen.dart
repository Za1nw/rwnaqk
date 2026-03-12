import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/app_settings/app_settings_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/widgets/common/app_back_header.dart';
import 'package:rwnaqk/widgets/common/app_section_header.dart';
import 'package:rwnaqk/widgets/settings/settings_profile_card.dart';

import '../controllers/main/main_controller.dart';
import '../../widgets/settings/settings_list_tile.dart';

class SettingsScreen extends GetView<AppSettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppSettingsController>();
    final main = Get.isRegistered<MainController>()
        ? Get.find<MainController>()
        : null;

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 18),
          children: [
            AppBackHeader(
              title: 'Settings'.tr,
              onBack: () {
                if (main != null) {
                  main.changeTab(0);
                } else {
                  Get.back();
                }
              },
            ),
            const SizedBox(height: 14),

            SettingsProfileCard(
              name: 'Eng Zain'.tr,
              phone: '+967 7xx xxx xxx'.tr,
              onEdit: () => Get.toNamed(AppRoutes.editProfile),
            ),

            const SizedBox(height: 16),

            AppSectionHeader(
              title: 'Account'.tr,
              titleFontSize: 12.5,
              titleColor: context.muted,
            ),
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
            const SizedBox(height: 10),

            SettingsListTile(
              icon: Icons.receipt_long_outlined,
              title: 'طلباتي'.tr,
              subtitle: 'تتبع وإدارة الطلبات'.tr,
              onTap: () => Get.toNamed(AppRoutes.orders),
            ),

            const SizedBox(height: 18),

            AppSectionHeader(
              title: 'Preferences'.tr,
              titleFontSize: 12.5,
              titleColor: context.muted,
            ),
            const SizedBox(height: 10),

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
                tapWholeTile: false,
                showChevron: false,
              );
            }),

            const SizedBox(height: 10),

            SettingsListTile(
              icon: Icons.language_outlined,
              title: 'Language'.tr,
              subtitle: 'Arabic / English'.tr,
              trailingMaxWidth: 95,
              trailing: Obx(() {
                final code = app.locale.value.languageCode.toUpperCase();
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.primary.withOpacity(.08),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: context.primary.withOpacity(.18),
                    ),
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

            AppSectionHeader(
              title: 'Support'.tr,
              titleFontSize: 12.5,
              titleColor: context.muted,
            ),
            const SizedBox(height: 10),

            SettingsListTile(
              icon: Icons.help_outline_rounded,
              title: 'Help Center'.tr,
              subtitle: 'FAQs & support'.tr,
              onTap: () {},
            ),

            const SizedBox(height: 18),

            AppSectionHeader(
              title: 'Danger zone'.tr,
              titleFontSize: 12.5,
              titleColor: context.muted,
            ),
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