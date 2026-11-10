import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:rwnaqk_frontend/modules/customer/providers/customer_profile_providers.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/settings/ecommerce_orders_hub.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/settings/ecommerce_wallet_hub.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/settings/language_selection_sheet.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/settings/settings_group_card.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/settings/settings_list_tile.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/settings/settings_user_header.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/settings/theme_mode_selection_sheet.dart';
import 'package:rwnaqk_frontend/modules/orders/providers/orders_providers.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

/// الشاشة الرئيسية لـ "حسابي والإعدادات" وفق أفضل معايير تجربة المستخدم للمتاجر العالمية
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppConfirmDialog.show(
      title: Tk.settingsLogout.tr,
      message: Tk.settingsLogoutSubtitle.tr,
      confirmLabel: Tk.settingsLogout.tr,
      isDestructive: true,
    );
    if (confirmed == true) {
      await ref.read(customerSettingsProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = ref.watch(currentCustomerProvider);
    final settings = ref.watch(customerSettingsProvider);
    final settingsNotifier = ref.read(customerSettingsProvider.notifier);
    final currentTheme = ref.watch(appThemeModeProvider);
    final currentLocale = ref.watch(appLocaleProvider);
    final ordersCount = ref.watch(ordersProvider).orders.length;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final fullName = customer?.fullName;
    final firstName = customer?.firstName;
    final String displayName = (fullName != null && fullName.isNotEmpty)
        ? fullName
        : ((firstName != null && firstName.isNotEmpty)
            ? firstName
            : 'عميل رَوْنَقُك');

    final phone = customer?.phone;
    final String displayPhone = (phone != null && phone.isNotEmpty)
        ? phone
        : '+967 777 000 000';

    String themeBadge;
    switch (currentTheme) {
      case ThemeMode.dark:
        themeBadge = 'داكن';
        break;
      case ThemeMode.light:
        themeBadge = 'فاتح';
        break;
      case ThemeMode.system:
        themeBadge = 'تلقائي';
        break;
    }

    final isArabic = currentLocale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          // حشوة سفلية كافية (120px) تضمن عدم تغطية شريط التنقل السفلي العائم لأي عنصر
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. ترويسة المتجر الراقية لصفحة الحساب
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Tk.navAccount.tr, // 'حسابي'
                          style: AppTextTheme.cairo(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: context.foreground,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'أهلاً بك في عالم رَوْنَقُك الفاخر',
                          style: AppTextTheme.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // زر محادثة الدعم الفوري
                    _TopActionButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      tooltip: 'محادثة الدعم المباشر',
                      onTap: () => AppNav.toNamed(AppRoutes.supportChat),
                    ),
                    const SizedBox(width: 8),

                    // زر مركز المساعدة
                    _TopActionButton(
                      icon: Icons.help_outline_rounded,
                      tooltip: Tk.settingsHelpCenter.tr,
                      onTap: () => AppNav.toNamed(AppRoutes.helpCenter),
                    ),
                  ],
                ),
              ),

              // 2. بطاقة العضوية الملكية الفاخرة للعميل (Executive VIP Membership Card)
              SettingsUserHeader(
                name: displayName,
                phone: displayPhone,
                avatarPath: '',
                avatarUrl: customer?.avatarUrl ?? '',
                onTap: () => AppNav.toNamed(AppRoutes.profile),
                onEdit: () => AppNav.toNamed(AppRoutes.editProfile),
              ),
              const SizedBox(height: 16),

              // 3. مركز متابعة الطلبات والشحنات
              EcommerceOrdersHub(
                totalOrders: ordersCount,
                onAllOrders: () => AppNav.toNamed(AppRoutes.orders),
              ),
              const SizedBox(height: 16),

              // 4. المحفظة والمكافآت
              EcommerceWalletHub(
                walletBalance: '0 ر.ي',
                activeCouponsCount: '3 كوبونات',
                loyaltyPoints: '2,450 نقطة',
                onWalletTap: () {},
                onCouponsTap: () {},
                onPointsTap: () {},
              ),
              const SizedBox(height: 16),

              // 5. إدارة الشحن والعناوين والمفضلة
              SettingsGroupCard(
                title: 'تفضيلات التسوق والشحن',
                icon: Icons.shopping_bag_outlined,
                children: [
                  SettingsListTile(
                    icon: Icons.location_on_outlined,
                    title: Tk.settingsAddresses.tr,
                    subtitle: 'إدارة وتعديل عناوين التوصيل والاستلام',
                    onTap: () => AppNav.toNamed(AppRoutes.addresses),
                  ),
                  SettingsListTile(
                    icon: Icons.favorite_border_rounded,
                    title: Tk.wishlistTitle.tr,
                    subtitle: 'استعراض قائمة المنتجات المفضلة',
                    onTap: () => AppNav.toNamed(AppRoutes.wishlist),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 6. تفضيلات التطبيق (الثيم، اللغة، الإشعارات)
              SettingsGroupCard(
                title: 'تفضيلات ومظهر التطبيق',
                icon: Icons.tune_rounded,
                children: [
                  // الإشعارات العامة
                  SettingsListTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'الإشعارات العامة',
                    subtitle: 'إشعارات العروض الخاصة وحالة الشحنات',
                    showChevron: false,
                    trailing: Switch.adaptive(
                      value: settings.notificationsEnabled,
                      activeTrackColor: isDark
                          ? BrandColors.gold
                          : BrandColors.burgundy,
                      onChanged: settingsNotifier.toggleNotifications,
                    ),
                  ),

                  // مظهر التطبيق (ثيم)
                  SettingsListTile(
                    icon: currentTheme == ThemeMode.dark
                        ? Icons.dark_mode_outlined
                        : (currentTheme == ThemeMode.light
                            ? Icons.light_mode_outlined
                            : Icons.brightness_auto_outlined),
                    title: Tk.settingsDarkMode.tr,
                    subtitle: currentTheme == ThemeMode.dark
                        ? 'الوضع الليلي (داكن)'
                        : (currentTheme == ThemeMode.light
                            ? 'الوضع النهاري (فاتح)'
                            : 'تلقائي (حسب الجهاز)'),
                    onTap: () => ThemeModeSelectionSheet.show(context),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (isDark ? BrandColors.gold : BrandColors.burgundy)
                            .withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: (isDark
                                  ? BrandColors.gold
                                  : BrandColors.burgundy)
                              .withValues(alpha: 0.30),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            themeBadge,
                            style: AppTextTheme.cairo(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? BrandColors.gold
                                  : BrandColors.burgundy,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_left_rounded,
                            size: 16,
                            color: isDark
                                ? BrandColors.gold
                                : BrandColors.burgundy,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // لغة التطبيق
                  SettingsListTile(
                    icon: Icons.language_rounded,
                    title: Tk.settingsLanguage.tr,
                    subtitle: isArabic
                        ? 'العربية (اليمن)'
                        : 'English (International)',
                    onTap: () => LanguageSelectionSheet.show(context),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (isDark ? BrandColors.gold : BrandColors.burgundy)
                            .withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: (isDark
                                  ? BrandColors.gold
                                  : BrandColors.burgundy)
                              .withValues(alpha: 0.30),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isArabic ? 'العربية' : 'English',
                            style: AppTextTheme.cairo(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? BrandColors.gold
                                  : BrandColors.burgundy,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_left_rounded,
                            size: 16,
                            color: isDark
                                ? BrandColors.gold
                                : BrandColors.burgundy,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 7. مجموعة الدعم والخدمات
              SettingsGroupCard(
                title: Tk.settingsSupport.tr,
                icon: Icons.support_agent_outlined,
                children: [
                  SettingsListTile(
                    icon: Icons.headset_mic_outlined,
                    title: 'تواصل معنا والمحادثة المباشرة',
                    subtitle: 'فريق رَوْنَقُك جاهز لمساعدتك دائماً',
                    onTap: () => AppNav.toNamed(AppRoutes.supportChat),
                  ),
                  SettingsListTile(
                    icon: Icons.help_outline_rounded,
                    title: Tk.settingsHelpCenter.tr,
                    subtitle: Tk.settingsHelpCenterSubtitle.tr,
                    onTap: () => AppNav.toNamed(AppRoutes.helpCenter),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 8. منطقة تسجيل الخروج
              SettingsGroupCard(
                title: 'إدارة الجلسة',
                icon: Icons.security_outlined,
                children: [
                  SettingsListTile(
                    icon: Icons.logout_rounded,
                    title: Tk.settingsLogout.tr,
                    subtitle: Tk.settingsLogoutSubtitle.tr,
                    isDestructive: true,
                    showChevron: false,
                    trailing: Icon(
                      Icons.logout_rounded,
                      color: isDark
                          ? const Color(0xFFFFB4AB)
                          : const Color(0xFFB42318),
                      size: 20,
                    ),
                    onTap: () => _confirmLogout(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 26),

              // 9. تذييل وهوية المتجر
              Center(
                child: Column(
                  children: [
                    Text(
                      'رَوْنَقُك • RAWNAQK',
                      style: AppTextTheme.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: (isDark ? AppColors.gold : AppColors.burgundy)
                            .withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'الإصدار 1.0.0 (Royal Boutique Edition)',
                      style: AppTextTheme.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textSecondaryDark.withValues(alpha: 0.6)
                            : AppColors.textSecondaryLight.withValues(
                                alpha: 0.7,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _TopActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.border.withValues(alpha: isDark ? 0.35 : 0.45),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: isDark ? AppColors.gold : AppColors.burgundy,
            ),
          ),
        ),
      ),
    );
  }
}
