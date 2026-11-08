import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';

/// ويدجت الصورة الشخصية القابلة للتعديل والرفع
class EditableAvatarBadge extends StatelessWidget {
  final String name;
  final String avatarPath;
  final String avatarUrl;
  final bool isUploading;
  final Function(ImageSource) onPickImage;

  const EditableAvatarBadge({
    super.key,
    required this.name,
    required this.avatarPath,
    required this.avatarUrl,
    required this.isUploading,
    required this.onPickImage,
  });

  void _showImageSourceSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E0D1B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? BrandColors.gold.withValues(alpha: 0.25)
                : BrandColors.burgundy.withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'تغيير الصورة الشخصية',
                  style: AppTextTheme.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'اختر صورة تعكس أناقتك ومكانتك في رونق',
                  style: AppTextTheme.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? BrandColors.gold.withValues(alpha: 0.12)
                          : BrandColors.burgundy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: isDark ? BrandColors.gold : BrandColors.burgundy,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'التقاط صورة بالكاميرا',
                    style: AppTextTheme.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    onPickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? BrandColors.gold.withValues(alpha: 0.12)
                          : BrandColors.burgundy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.photo_library_outlined,
                      color: isDark ? BrandColors.gold : BrandColors.burgundy,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'اختيار من معرض الصور',
                    style: AppTextTheme.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    onPickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasFile = avatarPath.trim().isNotEmpty;
    final hasUrl = avatarUrl.trim().isNotEmpty;
    final initial = name.trim().isEmpty ? 'ر' : name.trim().characters.first;

    return Center(
      child: GestureDetector(
        onTap: isUploading ? null : () => _showImageSourceSheet(context),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // هالة ذهبية خارجية راقية (Luxury Halo Ring)
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: BrandColors.gold, width: 2.2),
                boxShadow: [
                  BoxShadow(
                    color: BrandColors.gold.withValues(alpha: 0.25),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: ClipOval(
                  child: Container(
                    color: isDark
                        ? const Color(0xFF1E0A17)
                        : const Color(0xFFF2EAEF),
                    child: isUploading
                        ? const Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  BrandColors.gold,
                                ),
                              ),
                            ),
                          )
                        : hasFile
                        ? Image.file(
                            File(avatarPath),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                _InitialText(initial: initial),
                          )
                        : hasUrl
                        ? Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                _InitialText(initial: initial),
                          )
                        : _InitialText(initial: initial),
                  ),
                ),
              ),
            ),

            // زر الكاميرا الصغير أسفل الصورة
            Positioned(
              bottom: 0,
              left: 4,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [BrandColors.gold, Color(0xFFE59E00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF1A0815) : Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 16,
                  color: Color(0xFF1E0A17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InitialText extends StatelessWidget {
  final String initial;

  const _InitialText({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial,
        style: AppTextTheme.cairo(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          color: BrandColors.burgundy,
        ),
      ),
    );
  }
}
