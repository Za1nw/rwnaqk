import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/services/auth/biometric_auth_service.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/utils/app_notifier.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/passkey_model.dart';
import 'package:rwnaqk_frontend/modules/customer/providers/sessions_and_passkeys_providers.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/profile/profile_two_factor_card.dart';

/// شاشة المصادقة الثنائية ومفاتيح المرور (التحقق بخطوتين والبصمة البيومترية)
///
/// تجربة بوتيك فاخرة تتوافق مع نظام التصميم Cairo والهوية الملكية لرَوْنَقُك
class TwoFactorAndPasskeysScreen extends ConsumerStatefulWidget {
  const TwoFactorAndPasskeysScreen({super.key});

  @override
  ConsumerState<TwoFactorAndPasskeysScreen> createState() =>
      _TwoFactorAndPasskeysScreenState();
}

class _TwoFactorAndPasskeysScreenState
    extends ConsumerState<TwoFactorAndPasskeysScreen> {
  bool _isRegisteringPasskey = false;
  int? _deletingPasskeyId;

  String _defaultDeviceName() {
    if (kIsWeb) return 'متصفح الويب (مفتاح مرور)';
    try {
      if (Platform.isAndroid) return 'بصمة هاتف أندرويد';
      if (Platform.isIOS) return 'بصمة Face ID / Touch ID';
      if (Platform.isWindows) return 'جهاز Windows Hello';
      if (Platform.isMacOS) return 'جهاز Mac Touch ID';
    } catch (_) {}
    return 'مفتاح مرور الجهاز الحالي';
  }

  Future<void> _registerPasskeyWithBiometrics() async {
    if (_isRegisteringPasskey) return;

    final bioService = ref.read(biometricAuthServiceProvider);

    // 1. فحص دعم المصادقة الحيوية أو قفل الهاتف
    final isAvailable = await bioService.isBiometricsAvailable();
    if (!isAvailable) {
      AppNotifier.warning(
        'خاصية المصادقة بالبصمة أو قفل الهاتف غير مدعومة على هذا الجهاز.',
      );
      return;
    }

    // 2. طلب تأكيد البصمة أو رمز قفل الهاتف فوراً من نظام التشغيل
    final authenticated = await bioService.authenticate(
      reason:
          'يرجى تأكيد بصمة الإصبع أو رمز قفل الهاتف لتسجيل هذا الجهاز في رَوْنَقُك',
    );

    if (!authenticated) {
      return;
    }

    setState(() => _isRegisteringPasskey = true);

    try {
      final credentialId = 'passkey_${DateTime.now().millisecondsSinceEpoch}';
      final secret = 'sec_${DateTime.now().microsecondsSinceEpoch}';
      final customer = ref.read(currentCustomerProvider);
      final email = customer?.email ?? '';

      // 3. إرسال تسجيل مفتاح المرور للباك إند بدون كلمة مرور الحساب
      await ref.read(passkeysProvider.notifier).storePasskey(
            name: _defaultDeviceName(),
            credentialId: credentialId,
            credential: <String, dynamic>{
              'secret': secret,
              'email': email,
              'type': 'public-key',
            },
          );

      // 4. حفظ بيانات الاعتماد محلياً لتمكين تسجيل الدخول السريع
      final currentToken = await ref.read(authTokenStorageProvider).readToken();
      await bioService.saveBiometricRegistration(
        credentialId: credentialId,
        secret: secret,
        email: email,
        token: currentToken,
      );

      HapticFeedback.mediumImpact();
      AppNotifier.success(
        'تم تسجيل البصمة وتفعيل مفتاح المرور بنجاح لهذا الجهاز',
        isKey: false,
      );
    } catch (e) {
      AppNotifier.errorFrom(e);
    } finally {
      if (mounted) {
        setState(() => _isRegisteringPasskey = false);
      }
    }
  }

  Future<void> _confirmDeletePasskey(PasskeyModel passkey) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'حذف مفتاح المرور',
          style: AppTextTheme.cairo(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: context.foreground,
          ),
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في إزالة مفتاح المرور "${passkey.name}"؟ لن تتمكن من الدخول بالبصمة بهذا الجهاز حتى تعيد تسجيله.',
          style: AppTextTheme.cairo(
            fontSize: 13.5,
            height: 1.5,
            color: context.mutedForeground,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'إلغاء',
              style: AppTextTheme.cairo(
                color: context.mutedForeground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.destructive,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'حذف',
              style: AppTextTheme.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _deletingPasskeyId = passkey.id);
    try {
      await ref.read(passkeysProvider.notifier).deletePasskey(passkey.id);
      HapticFeedback.lightImpact();
      AppNotifier.success('تم حذف مفتاح المرور بنجاح', isKey: false);
    } catch (e) {
      AppNotifier.errorFrom(e);
    } finally {
      if (mounted) {
        setState(() => _deletingPasskeyId = null);
      }
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'غير محدد';
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final passkeysAsync = ref.watch(passkeysProvider);

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'المصادقة الثنائية ومفاتيح المرور',
          style: AppTextTheme.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: context.foreground,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.foreground,
            size: 20,
          ),
          onPressed: () => AppNav.back(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==========================================
            // هيدر الأمان البوتيكي العصري
            // ==========================================
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: context.border,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isDark
                          ? const LinearGradient(
                              colors: [Color(0xFF380C23), Color(0xFF1B0713)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [Colors.white, AppColors.burgundy50],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      border: Border.all(
                        color: context.primary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.primary.withValues(
                            alpha: isDark ? 0.25 : 0.12,
                          ),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.fingerprint_rounded,
                        color: context.primary,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حماية الحساب المتقدمة',
                          style: AppTextTheme.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: context.foreground,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'طبقات حماية متقدمة لحسابك عبر بصمة الإصبع وتطبيقات المصادقة',
                          style: AppTextTheme.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.mutedForeground,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // 1. بطاقة مفاتيح المرور والبصمة البيومترية
            // ==========================================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: context.border,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: context.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: context.primary.withValues(alpha: 0.18),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.fingerprint_rounded,
                          color: context.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تسجيل الدخول بالبصمة وقفل الجهاز',
                              style: AppTextTheme.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: context.foreground,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'مفاتيح المرور البيومترية لتسجيل الدخول السريع',
                              style: AppTextTheme.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: context.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // كبسولة توضيحية فاخرة
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : context.primary.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.border,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          color: context.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'تتيح لك مفاتيح المرور تسجيل الدخول الآمن والسريع بدون كتابة كلمة المرور عبر بصمة الإصبع، معرف الوجه أو قفل شاشة الهاتف.',
                            style: AppTextTheme.cairo(
                              fontSize: 12,
                              height: 1.5,
                              color: context.mutedForeground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // زر تفعيل مفتاح مرور لهذا الجهاز
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primary,
                        foregroundColor: context.primaryForeground,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _isRegisteringPasskey
                          ? null
                          : _registerPasskeyWithBiometrics,
                      icon: _isRegisteringPasskey
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: context.primaryForeground,
                              ),
                            )
                          : const Icon(Icons.add_moderator_rounded, size: 20),
                      label: Text(
                        'تفعيل مفتاح مرور لهذا الجهاز',
                        style: AppTextTheme.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // قائمة مفاتيح المرور الحالية
                  passkeysAsync.when(
                    loading: () => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          color: context.primary,
                        ),
                      ),
                    ),
                    error: (err, _) => Center(
                      child: Text(
                        'تعذر تحميل مفاتيح المرور',
                        style: AppTextTheme.cairo(
                          color: context.destructive,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    data: (passkeys) {
                      if (passkeys.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.fingerprint_rounded,
                                  size: 34,
                                  color: context.mutedForeground.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'لا توجد مفاتيح مرور مسجلة بعد',
                                  style: AppTextTheme.cairo(
                                    color: context.mutedForeground,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: passkeys.length,
                        separatorBuilder: (_, i) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final passkey = passkeys[index];
                          final isDeleting =
                              _deletingPasskeyId == passkey.id;

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.03)
                                  : context.primary.withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: context.border,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color:
                                        context.primary.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: context.primary
                                          .withValues(alpha: 0.18),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.fingerprint_rounded,
                                    color: context.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        passkey.name,
                                        style: AppTextTheme.cairo(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                          color: context.foreground,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'تم التفعيل: ${_formatDate(passkey.createdAt)}',
                                        style: AppTextTheme.cairo(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: context.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'حذف مفتاح المرور',
                                  icon: isDeleting
                                      ? SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: context.destructive,
                                          ),
                                        )
                                      : Icon(
                                          Icons.delete_outline_rounded,
                                          color: context.destructive,
                                          size: 22,
                                        ),
                                  onPressed: isDeleting
                                      ? null
                                      : () => _confirmDeletePasskey(passkey),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ==========================================
            // 2. بطاقة المصادقة الثنائية (تطبيق المصادقة)
            // ==========================================
            const ProfileTwoFactorCard(),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
