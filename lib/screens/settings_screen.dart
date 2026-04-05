import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/app_settings/app_settings_controller.dart';
import 'package:rwnaqk/controllers/profile/profile_store_service.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
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
    final profileStore = Get.find<ProfileStoreService>();
    final main =
        Get.isRegistered<MainController>() ? Get.find<MainController>() : null;

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 18),
          children: [
            AppBackHeader(
              title: Tk.settingsTitle.tr,
              onBack: () {
                if (main != null) {
                  main.changeTab(0);
                } else {
                  Get.back();
                }
              },
            ),
            const SizedBox(height: 14),
            Obx(
              () => SettingsProfileCard(
                name: profileStore.name.value,
                phone: profileStore.phone.value,
                avatarPath: profileStore.avatarPath.value,
                avatarUrl: profileStore.avatarUrl.value,
                onEdit: () => Get.toNamed(AppRoutes.editProfile),
              ),
            ),
            const SizedBox(height: 16),
            AppSectionHeader(
              title: Tk.settingsAccount.tr,
              titleFontSize: 12.5,
              titleColor: context.muted,
            ),
            const SizedBox(height: 10),
            SettingsListTile(
              icon: Icons.person_outline_rounded,
              title: Tk.settingsProfile.tr,
              subtitle: Tk.settingsProfileSubtitle.tr,
              onTap: () => Get.toNamed(AppRoutes.profile),
            ),
            const SizedBox(height: 10),
            SettingsListTile(
              icon: Icons.location_on_outlined,
              title: Tk.settingsAddresses.tr,
              subtitle: Tk.settingsAddressesSubtitle.tr,
              onTap: () => Get.toNamed(AppRoutes.addresses),
            ),
            const SizedBox(height: 10),
            SettingsListTile(
              icon: Icons.receipt_long_outlined,
              title: Tk.settingsOrders.tr,
              subtitle: Tk.settingsOrdersSubtitle.tr,
              onTap: () => Get.toNamed(AppRoutes.orders),
            ),
            const SizedBox(height: 18),
            AppSectionHeader(
              title: Tk.settingsPreferences.tr,
              titleFontSize: 12.5,
              titleColor: context.muted,
            ),
            const SizedBox(height: 10),
            Obx(() {
              final isDark = app.themeMode.value == ThemeMode.dark;

              return SettingsListTile(
                icon: Icons.dark_mode_outlined,
                title: Tk.settingsDarkMode.tr,
                subtitle: Tk.settingsDarkModeSubtitle.tr,
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
              title: Tk.settingsLanguage.tr,
              subtitle: Tk.settingsLanguageSubtitle.tr,
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
              title: Tk.settingsSupport.tr,
              titleFontSize: 12.5,
              titleColor: context.muted,
            ),
            const SizedBox(height: 10),
            SettingsListTile(
              icon: Icons.help_outline_rounded,
              title: Tk.settingsHelpCenter.tr,
              subtitle: Tk.settingsHelpCenterSubtitle.tr,
              onTap: () => Get.toNamed(AppRoutes.helpCenter),
            ),
            const SizedBox(height: 18),
            AppSectionHeader(
              title: Tk.settingsDangerZone.tr,
              titleFontSize: 12.5,
              titleColor: context.muted,
            ),
            const SizedBox(height: 10),
            SettingsListTile(
              icon: Icons.logout_rounded,
              title: Tk.settingsLogout.tr,
              subtitle: Tk.settingsLogoutSubtitle.tr,
              trailingMaxWidth: 60,
              trailing: Icon(
                Icons.logout_rounded,
                color: Colors.redAccent.withOpacity(.95),
                size: 20,
              ),
              showChevron: false,
              onTap: () =>
                  Get.snackbar(Tk.settingsLogout.tr, Tk.commonMockAction.tr),
            ),
          ],
        ),
      ),
    );
  }
}
