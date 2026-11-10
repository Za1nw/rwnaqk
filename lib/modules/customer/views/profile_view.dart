import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/customer/providers/customer_profile_providers.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/profile/profile_info_tile.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/profile/profile_membership_banner.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/profile/profile_stats_strip.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/profile/profile_two_factor_card.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/settings/settings_user_header.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

/// شاشة الملف الشخصي الفاخرة للعميل (Customer Profile Screen)
/// متوافقة مع أرقى معايير تجربة المستخدم في تطبيقات التجارة الإلكترونية الفاخرة
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(customerProfileDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. ترويسة الصفحة الراقية مع زر الرجوع وتعديل الملف
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  _TopCircleButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'الرجوع',
                    onTap: () => AppNav.back(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Tk.settingsProfile.tr, // 'الملف الشخصي'
                          style: AppTextTheme.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          'إدارة معلوماتك الشخصية وعضويتك الفاخرة',
                          style: AppTextTheme.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _TopCircleButton(
                    icon: Icons.edit_note_rounded,
                    tooltip: Tk.profileEditTitle.tr,
                    onTap: () => AppNav.toNamed(AppRoutes.editProfile),
                  ),
                ],
              ),
            ),

            // 2. المحتوى القابل للتمرير
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // بطاقة العضوية والاسم
                    SettingsUserHeader(
                      name: data.name,
                      phone: data.phone,
                      avatarPath: '',
                      avatarUrl: data.avatarUrl,
                      onTap: () {},
                      onEdit: () => AppNav.toNamed(AppRoutes.editProfile),
                    ),
                    const SizedBox(height: 14),

                    // بنر نادي رونق VIP
                    ProfileMembershipBanner(
                      tierName: data.membershipTier,
                      discountText: data.membershipPerk,
                    ),
                    const SizedBox(height: 14),

                    // شريط المؤشرات التفاعلي (الطلبات، العناوين، المفضلة)
                    ProfileStatsStrip(items: data.stats),
                    const SizedBox(height: 20),

                    // عنوان قسم البيانات الشخصية
                    Row(
                      children: [
                        Container(
                          width: 3.5,
                          height: 15,
                          decoration: BoxDecoration(
                            color: isDark
                                ? BrandColors.gold
                                : BrandColors.burgundy,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Tk.profileViewPersonalInfo.tr,
                          style: AppTextTheme.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // قائمة البيانات الشخصية بطريقة ديناميكية آمنة
                    ...data.infoItems.map((item) => ProfileInfoTile(item: item)),

                    const SizedBox(height: 16),

                    // عنوان قسم الأمان والحماية
                    Row(
                      children: [
                        Container(
                          width: 3.5,
                          height: 15,
                          decoration: BoxDecoration(
                            color: isDark
                                ? BrandColors.gold
                                : BrandColors.burgundy,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'الأمان والخصوصية',
                          style: AppTextTheme.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // بطاقة المصادقة الثنائية
                    const ProfileTwoFactorCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// زر دائري أنيق للترويسة العلوية
class _TopCircleButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _TopCircleButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? BrandColors.gold.withValues(alpha: 0.25)
                  : BrandColors.burgundy.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? BrandColors.gold : BrandColors.burgundy,
          ),
        ),
      ),
    );
  }
}
