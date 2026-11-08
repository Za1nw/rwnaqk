import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/two_factor_settings_controller.dart';

/// بطاقة الأمان والمصادقة الثنائية (2FA) المصممة وفق هوية رونق الفاخرة
class ProfileTwoFactorCard extends GetView<TwoFactorSettingsController> {
  const ProfileTwoFactorCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final enabled = controller.isEnabled.value;
      final busy = controller.isLoading.value || controller.isSubmitting.value;
      final canShowSetup = controller.hasSetupData.value && !enabled;
      final setupKey = controller.manualSetupKey.value;
      final recoveryCodes = controller.recoveryCodes;

      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E0D1B) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? (enabled
                      ? const Color(0xFF10B981).withValues(alpha: 0.3)
                      : BrandColors.gold.withValues(alpha: 0.2))
                : (enabled
                      ? const Color(0xFF10B981).withValues(alpha: 0.25)
                      : BrandColors.burgundy.withValues(alpha: 0.1)),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان الرئيسي وحالة التفعيل
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: enabled
                        ? const Color(0xFF10B981).withValues(alpha: 0.12)
                        : (isDark
                              ? BrandColors.gold.withValues(alpha: 0.12)
                              : BrandColors.burgundy.withValues(alpha: 0.08)),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: enabled
                          ? const Color(0xFF10B981).withValues(alpha: 0.35)
                          : (isDark
                                ? BrandColors.gold.withValues(alpha: 0.3)
                                : BrandColors.burgundy.withValues(alpha: 0.15)),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    enabled
                        ? Icons.verified_user_rounded
                        : Icons.security_rounded,
                    color: enabled
                        ? const Color(0xFF10B981)
                        : (isDark ? BrandColors.gold : BrandColors.burgundy),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Tk.profileTwoFactorTitle.tr,
                        style: AppTextTheme.cairo(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        enabled
                            ? 'حسابك محمي برمز تحقق إضافي'
                            : 'حماية إضافية لحسابك من الوصول غير المصرح به',
                        style: AppTextTheme.cairo(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                // شارة الحالة
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: enabled
                        ? const Color(0xFF10B981).withValues(alpha: 0.14)
                        : const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: enabled
                          ? const Color(0xFF10B981).withValues(alpha: 0.4)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        enabled
                            ? Icons.check_circle_rounded
                            : Icons.info_outline_rounded,
                        size: 12,
                        color: enabled
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        enabled
                            ? Tk.profileTwoFactorEnabled.tr
                            : Tk.profileTwoFactorDisabled.tr,
                        style: AppTextTheme.cairo(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: enabled
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // خطوات إعداد المصادقة إن كانت قيد التهيئة
            if (canShowSetup) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : const Color(0xFFF8F5F7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Tk.profileTwoFactorSetupPending.tr,
                      style: AppTextTheme.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        height: 1.4,
                      ),
                    ),
                    if (setupKey.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Tk.profileTwoFactorManualKey.tr,
                                  style: AppTextTheme.cairo(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? BrandColors.gold
                                        : BrandColors.burgundy,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                SelectableText(
                                  setupKey,
                                  style: AppTextTheme.cairo(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: busy
                                ? null
                                : controller.copyManualSetupKey,
                            icon: Icon(
                              Icons.copy_rounded,
                              size: 18,
                              color: isDark
                                  ? BrandColors.gold
                                  : BrandColors.burgundy,
                            ),
                            tooltip: Tk.commonCopy.tr,
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                    TextField(
                      enabled: !busy,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      onChanged: controller.onCodeChanged,
                      textAlign: TextAlign.center,
                      style: AppTextTheme.cairo(
                        letterSpacing: 4,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        labelText: Tk.profileTwoFactorCodeLabel.tr,
                        hintText: Tk.profileTwoFactorCodeHint.tr,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isDark ? Colors.white24 : Colors.black12,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isDark
                                ? BrandColors.gold
                                : BrandColors.burgundy,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: busy || !controller.canConfirmCode
                            ? null
                            : controller.confirmSetup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? BrandColors.gold
                              : BrandColors.burgundy,
                          foregroundColor: isDark
                              ? const Color(0xFF1E0A17)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          Tk.profileTwoFactorConfirm.tr,
                          style: AppTextTheme.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // أكواد الاسترداد الاحتياطية إن كانت مفعلة
            if (enabled && recoveryCodes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: busy ? null : controller.copyAllRecoveryCodes,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : const Color(0xFFF9F6F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.vpn_key_outlined,
                          size: 16,
                          color: isDark
                              ? BrandColors.gold
                              : BrandColors.burgundy,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'نسخ رموز الاسترداد الاحتياطية (${recoveryCodes.length} رموز)',
                            style: AppTextTheme.cairo(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white70
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.copy_rounded,
                          size: 16,
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

            const SizedBox(height: 14),

            // زر التفعيل أو التعطيل الرئيسي
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton.icon(
                onPressed: busy
                    ? null
                    : enabled
                    ? controller.disable
                    : controller.enable,
                icon: Icon(
                  enabled ? Icons.shield_outlined : Icons.shield_rounded,
                  size: 17,
                  color: enabled
                      ? const Color(0xFFEF4444)
                      : (isDark ? BrandColors.gold : BrandColors.burgundy),
                ),
                label: Text(
                  enabled
                      ? Tk.profileTwoFactorDisable.tr
                      : Tk.profileTwoFactorEnable.tr,
                  style: AppTextTheme.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: enabled
                        ? const Color(0xFFEF4444)
                        : (isDark ? BrandColors.gold : BrandColors.burgundy),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: enabled
                        ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                        : (isDark
                              ? BrandColors.gold.withValues(alpha: 0.6)
                              : BrandColors.burgundy.withValues(alpha: 0.5)),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
