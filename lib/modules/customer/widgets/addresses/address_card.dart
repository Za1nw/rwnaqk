import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/shipping_address.dart';

/// بطاقة عرض عنوان الشحن والتوصيل الفاخرة
class AddressCard extends StatelessWidget {
  final ShippingAddress address;
  final VoidCallback onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AddressCard({
    super.key,
    required this.address,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDefault = address.isDefault;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E0D1B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDefault
              ? (isDark ? BrandColors.gold : BrandColors.burgundy)
              : (isDark
                    ? BrandColors.gold.withValues(alpha: 0.15)
                    : BrandColors.burgundy.withValues(alpha: 0.08)),
          width: isDefault ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // شريط العنوان الافتراضي وحالة الاختيار
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                // أيقونة الموقع
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark
                        ? BrandColors.gold.withValues(alpha: 0.12)
                        : BrandColors.burgundy.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    size: 20,
                    color: isDark ? BrandColors.gold : BrandColors.burgundy,
                  ),
                ),
                const SizedBox(width: 10),

                // اسم المدينة والدولة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${address.city}، ${address.country}',
                        style: AppTextTheme.cairo(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      if (address.postcode.isNotEmpty)
                        Text(
                          'الرمز البريدي: ${address.postcode}',
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

                // شارة العنوان الافتراضي
                if (isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [BrandColors.gold, Color(0xFFD49200)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: Color(0xFF1E0A17),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'الافتراضي',
                          style: AppTextTheme.cairo(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1E0A17),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // تفاصيل العنوان المكتوب
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              address.address,
              style: AppTextTheme.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xFF4B3A44),
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 10),
          Divider(
            height: 1,
            thickness: 0.8,
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),

          // أزرار التحكم والإجراءات (تعيين كافتراضي، تعديل، حذف)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                if (!isDefault) ...[
                  TextButton.icon(
                    onPressed: onSetDefault,
                    icon: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 16,
                      color: isDark ? BrandColors.gold : BrandColors.burgundy,
                    ),
                    label: Text(
                      'تعيين كافتراضي',
                      style: AppTextTheme.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? BrandColors.gold : BrandColors.burgundy,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const Spacer(),
                ] else
                  const Spacer(),

                // زر التعديل
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: isDark ? Colors.white70 : const Color(0xFF5A4452),
                  ),
                  tooltip: Tk.commonEdit.tr,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
                const SizedBox(width: 4),

                // زر الحذف
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: Color(0xFFEF4444),
                  ),
                  tooltip: Tk.commonDelete.tr,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
