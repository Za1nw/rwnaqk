import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';

/// كرت رفع صورة سند الحوالة أو إشعار التحويل البنكي الفاخر
class PaymentReceiptUploadCard extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onPickImage;
  final VoidCallback? onRemoveImage;

  const PaymentReceiptUploadCard({
    super.key,
    required this.imageFile,
    required this.onPickImage,
    this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF24111F) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? BrandColors.gold.withValues(alpha: 0.18)
              : const Color(0xFFEDE3EA),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
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
                  Icons.receipt_long_rounded,
                  size: 20,
                  color: isDark ? BrandColors.gold : BrandColors.burgundy,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إرفاق صورة سند التحويل',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E0A17),
                        fontWeight: FontWeight.w900,
                        fontSize: 14.5,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'صورة واضحة لإشعار الإيداع أو الحوالة لتأكيد طلبك',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF7E6674),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Upload Area or Image Preview
          if (imageFile == null)
            InkWell(
              onTap: onPickImage,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1B0B17)
                      : const Color(0xFFFAF5F8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? BrandColors.gold.withValues(alpha: 0.3)
                        : BrandColors.burgundy.withValues(alpha: 0.25),
                    style: BorderStyle.solid,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color:
                            (isDark ? BrandColors.gold : BrandColors.burgundy)
                                .withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 26,
                        color: isDark ? BrandColors.gold : BrandColors.burgundy,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'اضغط هنا لاختيار صورة السند',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E0A17),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'يدعم JPG, PNG بوضوح كافٍ',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white38
                            : const Color(0xFFA5909E),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Image Preview Card
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  Image.file(
                    imageFile!,
                    width: double.infinity,
                    height: 190,
                    fit: BoxFit.cover,
                  ),
                  // Success Badge Overlay
                  PositionedDirectional(
                    top: 10,
                    start: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'تم إرفاق السند بنجاح',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Actions row: Change or Remove
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPickImage,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('تغيير الصورة'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark
                          ? BrandColors.gold
                          : BrandColors.burgundy,
                      side: BorderSide(
                        color: isDark ? BrandColors.gold : BrandColors.burgundy,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Cairo',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                if (onRemoveImage != null) ...[
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: onRemoveImage,
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('حذف'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Cairo',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
