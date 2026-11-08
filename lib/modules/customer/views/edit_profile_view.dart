import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/widgets/app_button.dart';
import 'package:rwnaqk_frontend/core/widgets/app_input_field.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/edit_profile_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/edit_profile/editable_avatar_badge.dart';

/// شاشة تعديل الملف الشخصي الفاخرة للعميل (Edit Profile Screen)
class EditProfileScreen extends GetView<EditProfileController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.background,
      bottomNavigationBar: Obx(
        () => SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 14),
            child: AppButton(
              text: controller.isSaving
                  ? 'جاري الحفظ...'
                  : Tk.profileEditSaveChanges.tr,
              icon: Icons.check_circle_outline_rounded,
              isLoading: controller.isSaving,
              onPressed: controller.isBusy ? null : controller.save,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ترويسة الصفحة مع زر الرجوع
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  _TopCircleButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'الرجوع',
                    onTap: Get.back,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Tk.profileEditTitle.tr, // 'تعديل الملف الشخصي'
                          style: AppTextTheme.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          Tk.profileEditSubtitle.tr,
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
                ],
              ),
            ),

            // محتوى الحقول القابل للتمرير
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الصورة الشخصية القابلة للتعديل
                    const SizedBox(height: 10),
                    Obx(
                      () => EditableAvatarBadge(
                        name: controller.nameCtrl.text,
                        avatarPath: controller.avatarPath,
                        avatarUrl: controller.avatarUrl,
                        isUploading: controller.isUploadingAvatar,
                        onPickImage: controller.pickAvatar,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // بطاقة المعلومات الأساسية
                    _FormCard(
                      title: 'البيانات الشخصية',
                      icon: Icons.person_outline_rounded,
                      children: [
                        AppInputField(
                          controller: controller.nameCtrl,
                          label: Tk.profileEditName.tr,
                          hint: Tk.profileEditNameHint.tr,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        AppInputField(
                          controller: controller.emailCtrl,
                          label: Tk.profileEditEmail.tr,
                          hint: Tk.profileEditEmailHint.tr,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        AppInputField(
                          controller: controller.mobileCtrl,
                          label: Tk.profileEditMobile.tr,
                          hint: Tk.registerPhoneHint.tr,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // بطاقة الأمان وكلمة المرور
                    _FormCard(
                      title: 'الأمان وكلمة المرور',
                      icon: Icons.lock_outline_rounded,
                      children: [
                        Text(
                          'لحماية حسابك، نوصي باستخدام كلمة مرور قوية تحتوي على أرقام ورموز خاصة.',
                          style: AppTextTheme.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: controller.goToForgotPassword,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? BrandColors.gold.withValues(alpha: 0.1)
                                    : BrandColors.burgundy.withValues(
                                        alpha: 0.05,
                                      ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? BrandColors.gold.withValues(alpha: 0.25)
                                      : BrandColors.burgundy.withValues(
                                          alpha: 0.12,
                                        ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.key_rounded,
                                    size: 18,
                                    color: isDark
                                        ? BrandColors.gold
                                        : BrandColors.burgundy,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      Tk.profileEditChangePassword.tr,
                                      style: AppTextTheme.cairo(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? Colors.white
                                            : BrandColors.burgundy,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_left_rounded,
                                    size: 20,
                                    color: isDark
                                        ? BrandColors.gold
                                        : BrandColors.burgundy,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة احتواء وتجميع حقول الإدخال
class _FormCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _FormCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E0D1B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? BrandColors.gold.withValues(alpha: 0.18)
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isDark ? BrandColors.gold : BrandColors.burgundy,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextTheme.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _TopCircleButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _TopCircleButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? BrandColors.gold.withValues(alpha: 0.25)
                  : BrandColors.burgundy.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? BrandColors.gold : BrandColors.burgundy,
          ),
        ),
      ),
    );
  }
}
