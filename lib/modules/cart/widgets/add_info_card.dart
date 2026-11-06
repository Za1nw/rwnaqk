import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_action_icon_button.dart';

/// كرت يظهر عندما لا توجد بيانات (مثل عدم وجود عنوان شحن)
/// يعرض زر (+) لإضافة البيانات.
class AddInfoCard extends StatelessWidget {
  /// عنوان القسم (مثال: Shipping Address)
  final String title;

  /// يتم استدعاؤه عند الضغط على زر الإضافة
  final VoidCallback? onAdd;

  /// نص مساعد اختياري
  final String? hint;

  const AddInfoCard({
    super.key,
    required this.title,
    required this.onAdd,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF24111F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? BrandColors.gold.withValues(alpha: 0.16)
              : const Color(0xFFEDE3EA),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? BrandColors.gold.withValues(alpha: 0.12)
                    : BrandColors.burgundy.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_location_alt_rounded,
                size: 20,
                color: isDark ? BrandColors.gold : BrandColors.burgundy,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1E0A17),
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  if (hint != null && hint!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      hint!,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF7E6674),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (onAdd != null)
              AppActionIconButton(
                icon: Icons.add_rounded,
                onTap: onAdd!,
                size: 34,
                iconSize: 20,
                radius: 10,
              ),
          ],
        ),
      ),
    );
  }
}
