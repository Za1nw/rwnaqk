import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/profile/profile_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/widgets/common/app_section_header.dart';
import 'package:rwnaqk/widgets/common/app_sectioned_page.dart';
import 'package:rwnaqk/widgets/profile/profile_info_card.dart';
import 'package:rwnaqk/widgets/profile/profile_stats_strip.dart';
import 'package:rwnaqk/widgets/settings/settings_profile_card.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = controller.stats;
      final info = controller.infoItems;

      return AppSectionedPage(
        title: Tk.settingsProfile.tr,
        onBack: Get.back,
        trailingIcon: Icons.person_outline_rounded,
        children: [
          SettingsProfileCard(
            name: controller.name,
            phone: controller.phone,
            avatarPath: controller.avatarPath,
            avatarUrl: controller.avatarUrl,
            onEdit: controller.openEditProfile,
          ),
          const SizedBox(height: 14),
          ProfileStatsStrip(items: stats),
          const SizedBox(height: 18),
          AppSectionHeader(
            title: Tk.profileViewPersonalInfo.tr,
            titleFontSize: 12.5,
            titleColor: context.muted,
          ),
          const SizedBox(height: 10),
          ProfileInfoCard(
            title: info[0].titleKey.tr,
            value: info[0].value,
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 10),
          ProfileInfoCard(
            title: info[1].titleKey.tr,
            value: info[1].value,
            icon: Icons.phone_outlined,
          ),
          const SizedBox(height: 10),
          ProfileInfoCard(
            title: info[2].titleKey.tr,
            value: info[2].value,
            icon: Icons.location_on_outlined,
          ),
        ],
      );
    });
  }
}
