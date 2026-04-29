import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/app_settings/app_settings_controller.dart';
import 'package:rwnaqk/controllers/profile/profile_store_service.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/routes/wallet_routes.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/widgets/common/app_sectioned_page.dart';
import 'package:rwnaqk/widgets/settings/settings_profile_card.dart';
import 'package:rwnaqk/widgets/settings/settings_sections.dart';

import '../controllers/main/main_controller.dart';

class SettingsScreen extends GetView<AppSettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppSettingsController>();
    final profileStore = Get.find<ProfileStoreService>();
    final main =
        Get.isRegistered<MainController>() ? Get.find<MainController>() : null;

    return AppSectionedPage(
      title: Tk.settingsTitle.tr,
      onBack: () {
        if (main != null) {
          main.changeTab(0);
        } else {
          Get.back();
        }
      },
      children: [
        Obx(
          () => SettingsProfileCard(
            name: profileStore.name.value,
            phone: profileStore.phone.value,
            avatarPath: profileStore.avatarPath.value,
            avatarUrl: profileStore.avatarUrl.value,
            onTap: () => Get.toNamed(AppRoutes.profile),
            onEdit: () => Get.toNamed(AppRoutes.editProfile),
          ),
        ),
        const SizedBox(height: 16),
        SettingsSections(
          sections: [
            SettingsSectionSpec(
              title: Tk.settingsAccount.tr,
              tiles: [
                SettingsTileSpec(
                  icon: Icons.location_on_outlined,
                  title: Tk.settingsAddresses.tr,
                  subtitle: Tk.settingsAddressesSubtitle.tr,
                  onTap: () => Get.toNamed(AppRoutes.addresses),
                ),
                SettingsTileSpec(
                  icon: Icons.receipt_long_outlined,
                  title: Tk.settingsOrders.tr,
                  subtitle: Tk.settingsOrdersSubtitle.tr,
                  onTap: () => Get.toNamed(AppRoutes.orders),
                ),
              ],
            ),
            SettingsSectionSpec(
              title: Tk.walletTitle.tr,
              tiles: [
                SettingsTileSpec(
                  icon: Icons.account_balance_wallet_outlined,
                  title: Tk.settingsWallet.tr,
                  subtitle: Tk.settingsWalletSubtitle.tr,
                  onTap: () => Get.toNamed(WalletRoutes.wallet),
                ),
              ],
            ),
            SettingsSectionSpec(
              title: Tk.settingsPreferences.tr,
              tiles: [
                SettingsTileSpec(
                  icon: Icons.dark_mode_outlined,
                  title: Tk.settingsDarkMode.tr,
                  subtitle: Tk.settingsDarkModeSubtitle.tr,
                  trailingMaxWidth: 90,
                  trailing: Obx(() {
                    final isDark = app.themeMode.value == ThemeMode.dark;
                    return Switch(
                      value: isDark,
                      onChanged: (_) => app.toggleTheme(),
                    );
                  }),
                  tapWholeTile: false,
                  showChevron: false,
                ),
                SettingsTileSpec(
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
                        color: context.primary.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: context.primary.withValues(alpha: .18),
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
              ],
            ),
            SettingsSectionSpec(
              title: Tk.settingsSupport.tr,
              tiles: [
                SettingsTileSpec(
                  icon: Icons.help_outline_rounded,
                  title: Tk.settingsHelpCenter.tr,
                  subtitle: Tk.settingsHelpCenterSubtitle.tr,
                  onTap: () => Get.toNamed(AppRoutes.helpCenter),
                ),
              ],
            ),
            SettingsSectionSpec(
              title: Tk.settingsDangerZone.tr,
              tiles: [
                SettingsTileSpec(
                  icon: Icons.logout_rounded,
                  title: Tk.settingsLogout.tr,
                  subtitle: Tk.settingsLogoutSubtitle.tr,
                  trailing: Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent.withValues(alpha: .95),
                    size: 20,
                  ),
                  trailingMaxWidth: 60,
                  showChevron: false,
                  onTap: () => Get.snackbar(
                      Tk.settingsLogout.tr, Tk.commonMockAction.tr),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
