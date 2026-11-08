import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';

/// حالة عدم وجود عناوين مسجلة للعميل بتصميم فاخر وجذاب
class AddressEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const AddressEmptyState({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: isDark
                    ? BrandColors.gold.withValues(alpha: 0.10)
                    : BrandColors.burgundy.withValues(alpha: 0.06),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? BrandColors.gold.withValues(alpha: 0.25)
                      : BrandColors.burgundy.withValues(alpha: 0.12),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.location_off_outlined,
                size: 42,
                color: isDark ? BrandColors.gold : BrandColors.burgundy,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'لا توجد عناوين توصيل مسجلة',
              style: AppTextTheme.cairo(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'أضف عنوان استلام طلباتك للاستمتاع بتجربة توصيل سريعة ومباشرة إلى باب منزلك.',
              textAlign: TextAlign.center,
              style: AppTextTheme.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_location_alt_rounded, size: 18),
              label: Text(
                'إضافة عنوان توصيل جديد',
                style: AppTextTheme.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? BrandColors.gold
                    : BrandColors.burgundy,
                foregroundColor: isDark
                    ? const Color(0xFF1E0A17)
                    : Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
