import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/profile_avatar.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

/// بطاقة العضوية الملكية الفاخرة للعميل (Executive VIP Membership Card)
/// مصممة وفق أرقى معايير المتاجر الفاخرة العالمية (Farfetch, Harrods VIP, Noon VIP)
/// تتميز بتوزيع بصري رحب يمنع أي ازدحام، مع إبراز الاسم بدون أي قص
class SettingsUserHeader extends StatelessWidget {
  final String name;
  final String phone;
  final String? avatarPath;
  final String? avatarUrl;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;

  const SettingsUserHeader({
    super.key,
    required this.name,
    required this.phone,
    this.avatarPath,
    this.avatarUrl,
    this.onEdit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayName = name.trim().isEmpty
        ? 'عميل رَوْنَقُك الفاخر'
        : name.trim();
    final displayPhone = phone.trim().isEmpty
        ? 'لم يتم ربط رقم الهاتف'
        : phone.trim();

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF4A0A26),
                    const Color(0xFF300619),
                    const Color(0xFF1B030E),
                  ]
                : [
                    const Color(0xFF750135),
                    const Color(0xFF540126),
                    const Color(0xFF330016),
                  ],
          ),
          border: Border.all(
            color: BrandColors.gold.withValues(alpha: isDark ? 0.45 : 0.40),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6E0131)
                  .withValues(alpha: isDark ? 0.35 : 0.22),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap ?? () => AppNav.toNamed(AppRoutes.profile),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. الصف العلوي: الصورة الشخصية والاسم ورقم الهاتف وزر التعديل
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // الصورة الشخصية مع إطار ذهبي مصقول وخلفية لؤلؤية عالية التباين
                    ProfileAvatar(
                      name: displayName,
                      imagePath: avatarPath,
                      imageUrl: avatarUrl,
                      size: 54,
                      fontSize: 21,
                      backgroundColor: isDark
                          ? const Color(0xFF280719)
                          : const Color(0xFFFFF7FA),
                      textColor: isDark
                          ? BrandColors.gold
                          : BrandColors.burgundy,
                      showBorder: true,
                    ),
                    const SizedBox(width: 12),

                    // الاسم ورقم الهاتف في مساحة كاملة تمنع أي قص
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextTheme.cairo(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.phone_iphone_rounded,
                                size: 13,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  displayPhone,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextTheme.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ),
                              if (phone.trim().isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981)
                                        .withValues(alpha: 0.22),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_rounded,
                                        size: 10,
                                        color: Color(0xFF34D399),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'موثق',
                                        style: AppTextTheme.cairo(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF34D399),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // زر تعديل الملف الشخصي الأنيق والمريح للنقر
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap:
                            onEdit ?? () => AppNav.toNamed(AppRoutes.editProfile),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 0.9,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.edit_outlined,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                Tk.commonEdit.tr,
                                style: AppTextTheme.cairo(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 2. شريط فئة العضوية الملكية المنفصل والأنيق (Membership Tier Ribbon)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        BrandColors.gold.withValues(alpha: 0.22),
                        BrandColors.gold.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: BrandColors.gold.withValues(alpha: 0.40),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.workspace_premium_rounded,
                        size: 14,
                        color: BrandColors.gold,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'عضوية VIP الذهبية',
                        style: AppTextTheme.cairo(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: BrandColors.gold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'ROYAL MEMBER',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: BrandColors.gold.withValues(alpha: 0.85),
                          fontFamily: AppTextTheme.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 3. شريط المزايا الحصرية السفلية للعميل
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 13,
                        color: BrandColors.gold,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'توصيل مجاني لكافة طلباتك • خصم 15% فوري',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextTheme.cairo(
                            fontSize: 11.2,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_left_rounded,
                        size: 18,
                        color: BrandColors.gold.withValues(alpha: 0.9),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
