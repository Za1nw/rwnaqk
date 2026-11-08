import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_service.dart';

/// شريط المؤشرات التفاعلي للملف الشخصي (الطلبات، العناوين، المفضلة)
class ProfileStatsStrip extends StatelessWidget {
  final List<ProfileStatsItem> items;

  const ProfileStatsStrip({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: items
          .map((item) {
            final isLast = item == items.last;
            return Expanded(
              child: Container(
                margin: EdgeInsetsDirectional.only(end: isLast ? 0 : 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E0D1B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? BrandColors.gold.withValues(alpha: 0.18)
                        : BrandColors.burgundy.withValues(alpha: 0.08),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.20 : 0.03,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: item.onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 8,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? BrandColors.gold.withValues(alpha: 0.12)
                                  : BrandColors.burgundy.withValues(
                                      alpha: 0.07,
                                    ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.icon,
                              size: 16,
                              color: isDark
                                  ? BrandColors.gold
                                  : BrandColors.burgundy,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.value,
                            style: AppTextTheme.cairo(
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimaryLight,
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.labelKey.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: AppTextTheme.cairo(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}
