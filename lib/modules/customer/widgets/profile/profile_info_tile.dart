import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/widgets/feedback/app_toast.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_service.dart';

/// بطاقة عرض تفاصيل المستخدم الشخصية مع إمكانية النسخ وحالة التوثيق
class ProfileInfoTile extends StatelessWidget {
  final ProfileInfoItem item;

  const ProfileInfoTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E0D1B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? BrandColors.gold.withValues(alpha: 0.15)
              : BrandColors.burgundy.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة الحقل بتنسيق راقٍ
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark
                  ? BrandColors.gold.withValues(alpha: 0.12)
                  : BrandColors.burgundy.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? BrandColors.gold.withValues(alpha: 0.25)
                    : BrandColors.burgundy.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Icon(
              item.icon,
              size: 20,
              color: isDark ? BrandColors.gold : BrandColors.burgundy,
            ),
          ),
          const SizedBox(width: 12),

          // العنوان والقيمة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.titleKey.tr,
                      style: AppTextTheme.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    if (item.isVerified) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              size: 11,
                              color: Color(0xFF10B981),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'موثق',
                              style: AppTextTheme.cairo(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextTheme.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),

          // زر النسخ السريع إن كان الحقل قابلاً للنسخ
          if (item.isCopyable)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: item.value));
                  AppToast.copied(message: item.value, title: item.titleKey.tr);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.copy_rounded,
                    size: 17,
                    color: isDark
                        ? BrandColors.gold.withValues(alpha: 0.8)
                        : BrandColors.burgundy.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
