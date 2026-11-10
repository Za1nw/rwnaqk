import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_notifier.dart';
import 'package:rwnaqk_frontend/modules/customer/providers/customer_profile_providers.dart';

/// بطاقة الأمان والمصادقة الثنائية (2FA) المصممة وفق هوية رونق الفاخرة
class ProfileTwoFactorCard extends ConsumerWidget {
  const ProfileTwoFactorCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(twoFactorSettingsNotifierProvider);
    final notifier = ref.read(twoFactorSettingsNotifierProvider.notifier);

    final enabled = state.isEnabled;
    final busy = state.isLoading || state.isSubmitting;
    final canShowSetup = state.hasSetupData && !enabled;
    final setupKey = state.manualSetupKey;
    final recoveryCodes = state.recoveryCodes;

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
                  borderRadius: BorderRadius.circular(14),
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
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      enabled
                          ? Tk.profileTwoFactorEnabled.tr
                          : Tk.profileTwoFactorDisabled.tr,
                      style: AppTextTheme.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: enabled
                            ? const Color(0xFF10B981)
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                      ),
                    ),
                  ],
                ),
              ),
              if (busy)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // وصف الأمان
          Text(
            Tk.profileTwoFactorSubtitle.tr,
            style: AppTextTheme.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              height: 1.45,
            ),
          ),

          // إعداد المصادقة الثنائية (مفتاح الإعداد اليدوي وحقل الإدخال)
          if (canShowSetup) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFFBF8FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? BrandColors.gold.withValues(alpha: 0.15)
                      : BrandColors.burgundy.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مفتاح الربط اليدوي لتطبيق المصادقة:',
                    style: AppTextTheme.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          setupKey,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        tooltip: 'نسخ المفتاح',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: setupKey));
                          AppNotifier.copied(title: 'تم نسخ مفتاح الإعداد');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    enabled: !busy,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    onChanged: notifier.setSetupCode,
                    style: const TextStyle(
                      fontFamily: 'monospace',
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
                      onPressed: busy || !state.canConfirmCode
                          ? null
                          : notifier.confirmSetup,
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
                onTap: busy
                    ? null
                    : () {
                        Clipboard.setData(
                          ClipboardData(text: recoveryCodes.join('\n')),
                        );
                        AppNotifier.copied(
                          title: 'تم نسخ كافة رموز الاسترداد',
                        );
                      },
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
                  : () {
                      if (enabled) {
                        notifier.disable('');
                      } else {
                        notifier.enable();
                      }
                    },
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
  }
}
