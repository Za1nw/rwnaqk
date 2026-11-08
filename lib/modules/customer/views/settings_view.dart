import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_money_utils.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/settings/ecommerce_orders_hub.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/settings/ecommerce_wallet_hub.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/settings/language_selection_sheet.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/settings/settings_group_card.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/settings/settings_list_tile.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/settings/settings_user_header.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/settings/theme_mode_selection_sheet.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_controller.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

/// الشاشة الرئيسية لـ "حسابي والإعدادات" وفق أفضل معايير تجربة المستخدم للمتاجر العالمية
class SettingsScreen extends GetView<AppSettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppSettingsController>();
    final profileStore = Get.find<ProfileStoreService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              // 1. ترويسة المتجر الراقية لصفحة الحساب (بدون أزرار رجوع دائرية لأنها صفحة رئيسية)
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
                      onTap: () => Get.toNamed(AppRoutes.supportChat),
                    ),
                    const SizedBox(width: 8),

                    // زر مركز المساعدة
                    _TopActionButton(
                      icon: Icons.help_outline_rounded,
                      tooltip: Tk.settingsHelpCenter.tr,
                      onTap: () => Get.toNamed(AppRoutes.helpCenter),
                    ),
                  ],
                ),
              ),

              // 2. بطاقة العضوية الملكية الفاخرة للعميل (Executive VIP Membership Card)
              Obx(
                () => SettingsUserHeader(
                  name: profileStore.displayName,
                  phone: profileStore.phone,
                  avatarPath: profileStore.avatarPath.value,
                  avatarUrl: profileStore.avatarUrl,
                  onTap: () => Get.toNamed(AppRoutes.profile),
                  onEdit: () => Get.toNamed(AppRoutes.editProfile),
                ),
              ),
              const SizedBox(height: 16),

              // 3. مركز تتبع ومتابعة الطلبات والشحنات (Orders & Tracking Hub)
              Obx(() {
                final ordersCount = Get.isRegistered<OrdersController>()
                    ? Get.find<OrdersController>().orders.length
                    : 0;

                return EcommerceOrdersHub(
                  totalOrders: ordersCount,
                  onAllOrders: () => Get.toNamed(AppRoutes.orders),
                );
              }),
              const SizedBox(height: 14),

              // 4. بطاقة المحفظة والكوبونات ونقاط الولاء (Wallet & Rewards Hub)
              Obx(() {
                final wallet = AppMoneyUtils.riyal(profileStore.walletBalance);

                return EcommerceWalletHub(
                  walletBalance: wallet,
                  activeCouponsCount: '2 قسائم',
                  loyaltyPoints: '250 نقطة',
                  onWalletTap: () => Get.toNamed(AppRoutes.profile),
                  onCouponsTap: () => Get.toNamed(AppRoutes.cart),
                  onPointsTap: () => Get.toNamed(AppRoutes.profile),
                );
              }),
              const SizedBox(height: 20),

              // 5. مجموعة الحساب وعناوين التوصيل
              SettingsGroupCard(
                title: 'إدارة الحساب والتوصيل',
                icon: Icons.person_outline_rounded,
                children: [
                  SettingsListTile(
                    icon: Icons.badge_outlined,
                    title: 'الملف الشخصي التفصيلي',
                    subtitle: 'عرض وتعديل معلومات حسابك ورقم هاتفك',
                    onTap: () => Get.toNamed(AppRoutes.profile),
                  ),
                  SettingsListTile(
                    icon: Icons.location_on_outlined,
                    title: Tk.settingsAddresses.tr,
                    subtitle: Tk.settingsAddressesSubtitle.tr,
                    onTap: () => Get.toNamed(AppRoutes.addresses),
                  ),
                  SettingsListTile(
                    icon: Icons.favorite_outline_rounded,
                    title: Tk.navWishlist.tr,
                    subtitle: 'المنتجات التي قمت بحفظها للإعجاب',
                    onTap: () => Get.toNamed(AppRoutes.wishlist),
                  ),
                  SettingsListTile(
                    icon: Icons.shield_outlined,
                    title: 'الأمان والمصادقة الثنائية (2FA)',
                    subtitle: 'حماية حسابك برمز تحقق إضافي',
                    onTap: () => Get.toNamed(AppRoutes.profile),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 6. مجموعة التفضيلات والمظهر (Boutique Preferences)
              SettingsGroupCard(
                title: Tk.settingsPreferences.tr,
                icon: Icons.tune_rounded,
                children: [
                  // المظهر ووضع العرض (نهاري، ليلي، أو حسب الجهاز)
                  Obx(() {
                    final mode = app.themeMode.value;
                    final modeBadge = mode == ThemeMode.dark
                        ? 'ليلي'
                        : (mode == ThemeMode.light ? 'نهاري' : 'تلقائي');

                    return SettingsListTile(
                      icon: app.themeModeIcon,
                      title: 'المظهر ووضع العرض',
                      subtitle: app.themeModeLabel,
                      onTap: () => ThemeModeSelectionSheet.show(context),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (isDark ? BrandColors.gold : BrandColors.burgundy)
                                  .withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                (isDark
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
                              modeBadge,
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
                    );
                  }),

                  // لغة التطبيق مع ورقة الاختيار الملكية
                  Obx(() {
                    final isArabic = app.locale.value.languageCode == 'ar';
                    return SettingsListTile(
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
                          color:
                              (isDark ? BrandColors.gold : BrandColors.burgundy)
                                  .withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                (isDark
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
                    );
                  }),
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
                    onTap: () => Get.toNamed(AppRoutes.supportChat),
                  ),
                  SettingsListTile(
                    icon: Icons.help_outline_rounded,
                    title: Tk.settingsHelpCenter.tr,
                    subtitle: Tk.settingsHelpCenterSubtitle.tr,
                    onTap: () => Get.toNamed(AppRoutes.helpCenter),
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
                    onTap: controller.confirmLogout,
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
