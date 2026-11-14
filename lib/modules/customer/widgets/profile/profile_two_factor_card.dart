import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/services/auth/providers/auth_session_providers.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/utils/app_notifier.dart';
import 'package:rwnaqk_frontend/modules/customer/providers/customer_profile_providers.dart';

/// بطاقة إعداد وإدارة المصادقة الثنائية (تطبيق المصادقة)
///
/// تصميم بوتيك فاخر معتمد على هوية رَوْنَقُك الملكية ونظام الـ 3+3 Split OTP Pods
class ProfileTwoFactorCard extends ConsumerStatefulWidget {
  const ProfileTwoFactorCard({super.key});

  @override
  ConsumerState<ProfileTwoFactorCard> createState() =>
      _ProfileTwoFactorCardState();
}

class _ProfileTwoFactorCardState extends ConsumerState<ProfileTwoFactorCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<_TwoFactorSplitOtpGridState> _otpKey =
      GlobalKey<_TwoFactorSplitOtpGridState>();

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 12.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12.0, end: -9.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -9.0, end: 9.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 9.0, end: -5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0);
    HapticFeedback.heavyImpact();
  }

  Future<void> _confirmDisable(
      BuildContext context, VoidCallback onConfirm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'تعطيل المصادقة الثنائية',
          style: AppTextTheme.cairo(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: context.foreground,
          ),
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في تعطيل المصادقة الثنائية؟ سيؤدي ذلك لتقليل مستوى حماية حسابك.',
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
              'تعطيل الحماية',
              style: AppTextTheme.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<TwoFactorState>(twoFactorSettingsNotifierProvider,
        (previous, next) {
      if (next.hasError &&
          (previous == null || previous.errorTicks != next.errorTicks)) {
        _triggerShake();
      }
    });

    final state = ref.watch(twoFactorSettingsNotifierProvider);
    final notifier = ref.read(twoFactorSettingsNotifierProvider.notifier);

    final enabled = state.isEnabled;
    final busy = state.isLoading || state.isSubmitting;
    final canShowSetup = state.hasSetupData && !enabled;
    final setupKey = state.manualSetupKey;
    final recoveryCodes = state.recoveryCodes;
    final customer = ref.watch(currentCustomerProvider);
    final isDark = context.isDark;

    final qrData = state.qrCodeUrl.isNotEmpty
        ? state.qrCodeUrl
        : (setupKey.isNotEmpty
            ? 'otpauth://totp/Rawnaquk:${customer?.email ?? 'Customer'}?secret=$setupKey&issuer=Rawnaquk'
            : '');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: enabled
              ? context.success.withValues(alpha: 0.35)
              : (canShowSetup
                  ? context.accent.withValues(alpha: 0.35)
                  : context.border),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // رأس البطاقة
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: enabled
                      ? context.success.withValues(alpha: 0.12)
                      : (canShowSetup
                          ? context.accent.withValues(alpha: 0.14)
                          : context.primary.withValues(alpha: 0.10)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: enabled
                        ? context.success.withValues(alpha: 0.25)
                        : (canShowSetup
                            ? context.accent.withValues(alpha: 0.25)
                            : context.primary.withValues(alpha: 0.18)),
                    width: 1,
                  ),
                ),
                child: Icon(
                  enabled
                      ? Icons.verified_user_rounded
                      : (canShowSetup
                          ? Icons.hourglass_top_rounded
                          : Icons.security_rounded),
                  color: enabled
                      ? context.success
                      : (canShowSetup ? context.accent : context.primary),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المصادقة الثنائية (تطبيق المصادقة)',
                      style: AppTextTheme.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: context.foreground,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: enabled
                                ? context.success
                                : (canShowSetup
                                    ? context.accent
                                    : context.mutedForeground),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          enabled
                              ? 'المصادقة الثنائية مفعلة بحسابك 🛡️'
                              : (canShowSetup
                                  ? 'بانتظار ربط التطبيق وتأكيد الرمز ⏳'
                                  : 'غير مفعلة'),
                          style: AppTextTheme.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: enabled
                                ? context.success
                                : (canShowSetup
                                    ? context.accent
                                    : context.mutedForeground),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (busy)
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: context.primary,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // الوصف التوضيحي
          Text(
            enabled
                ? 'حسابك محمي بنجاح. سيُطلب منك إدخال رمز التحقق المؤقت من تطبيق المصادقة لديك عند كل تسجيل دخول.'
                : (canShowSetup
                    ? 'يرجى إكمال خطوتَي الربط والتأكيد التاليتين لتفعيل الحماية لحسابك:'
                    : 'أضف طبقة حماية إضافية لحسابك تتطلب إدخال رمز أمان مؤقت من تطبيق المصادقة (مثل Google Authenticator أو Microsoft Authenticator) عند تسجيل الدخول.'),
            style: AppTextTheme.cairo(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: context.mutedForeground,
              height: 1.5,
            ),
          ),

          // ==========================================
          // حالة الإعداد الجاري: خطوات الربط والتأكيد
          // ==========================================
          if (canShowSetup) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : context.primary.withValues(alpha: 0.025),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: context.border,
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // رأس الخطوة 1
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: context.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.primary.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '1',
                          style: AppTextTheme.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: context.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الخطوة الأولى: ربط تطبيق المصادقة (مسح الكود أو إدخال المفتاح)',
                              style: AppTextTheme.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: context.foreground,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'افتح تطبيق المصادقة (Google Authenticator أو Microsoft Authenticator)، وامسح رمز الاستجابة السريعة (QR) أو أدخل المفتاح يدوياً:',
                              style: AppTextTheme.cairo(
                                fontSize: 11.5,
                                color: context.mutedForeground,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // كرت رمز الـ QR فائق الفخامة والنقاء
                  if (qrData.isNotEmpty) ...[
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.35 : 0.07,
                              ),
                              blurRadius: 18,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: context.border,
                            width: 1.2,
                          ),
                        ),
                        child: QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 160.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: context.primary.withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 15,
                              color: context.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'امسح الرمز مباشرة بكاميرا تطبيق المصادقة',
                              style: AppTextTheme.cairo(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: context.foreground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: context.border,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'أو انسخ المفتاح السري يدوياً',
                            style: AppTextTheme.cairo(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: context.mutedForeground,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: context.border,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // كبسولة المفتاح السري مع زر النسخ
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B0A16) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.border,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: SelectableText(
                              setupKey.isNotEmpty
                                  ? setupKey
                                  : 'جاري توليد المفتاح...',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: context.foreground,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: setupKey.isEmpty
                              ? null
                              : () {
                                  Clipboard.setData(
                                    ClipboardData(text: setupKey),
                                  );
                                  HapticFeedback.lightImpact();
                                  AppNotifier.copied(
                                    title: 'تم نسخ مفتاح الإعداد السري',
                                  );
                                },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: context.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: context.primary.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'نسخ المفتاح',
                                  style: AppTextTheme.cairo(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: context.primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.copy_rounded,
                                  size: 14,
                                  color: context.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // رأس الخطوة 2
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: context.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.primary.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '2',
                          style: AppTextTheme.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: context.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الخطوة الثانية: أدخل رمز التحقق للتأكيد والتفعيل',
                              style: AppTextTheme.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: context.foreground,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'أدخل الرمز المكون من 6 أرقام الظاهر في تطبيق المصادقة لديك:',
                              style: AppTextTheme.cairo(
                                fontSize: 11.5,
                                color: context.mutedForeground,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // خانات الإدخال العصرية المنقسمة 3+3 مع الانميشن والتوهج الذكي
                  AnimatedBuilder(
                    animation: _shakeAnim,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_shakeAnim.value, 0),
                        child: child,
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: _TwoFactorSplitOtpGrid(
                            key: _otpKey,
                            enabled: !busy,
                            hasError: state.hasError,
                            onChanged: notifier.setSetupCode,
                            onCompleted: (code) {
                              notifier.setSetupCode(code);
                              if (!busy) {
                                notifier.confirmSetup();
                              }
                            },
                          ),
                        ),
                        if (state.hasError) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 15,
                                color: context.destructive,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'رمز التحقق غير صحيح، أدخل الرمز الظاهر بتطبيق المصادقة',
                                  textAlign: TextAlign.center,
                                  style: AppTextTheme.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: context.destructive,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // أزرار التأكيد أو الإلغاء
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: busy || !state.canConfirmCode
                          ? null
                          : notifier.confirmSetup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primary,
                        foregroundColor: context.primaryForeground,
                        disabledBackgroundColor:
                            context.primary.withValues(alpha: 0.35),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: busy
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: context.primaryForeground,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'تأكيد وربط تطبيق المصادقة',
                                  style: AppTextTheme.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: busy
                        ? null
                        : () {
                            _otpKey.currentState?.clear();
                            notifier.disable('');
                          },
                    child: Text(
                      'إلغاء الإعداد',
                      style: AppTextTheme.cairo(
                        fontSize: 13,
                        color: context.mutedForeground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ==========================================
          // حالة التفعيل: رموز الاسترداد وزر التعطيل
          // ==========================================
          if (enabled && recoveryCodes.isNotEmpty) ...[
            const SizedBox(height: 18),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: busy
                    ? null
                    : () {
                        Clipboard.setData(
                          ClipboardData(text: recoveryCodes.join('\n')),
                        );
                        HapticFeedback.lightImpact();
                        AppNotifier.copied(
                          title: 'تم نسخ كافة رموز الاسترداد الاحتياطية',
                        );
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : context.primary.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: context.border,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: context.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.primary.withValues(alpha: 0.20),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.vpn_key_outlined,
                          size: 20,
                          color: context.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'رموز الاسترداد الاحتياطية (${recoveryCodes.length} رموز)',
                              style: AppTextTheme.cairo(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: context.foreground,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'اضغط لنسخ جميع الرموز لحفظها في مكان آمن',
                              style: AppTextTheme.cairo(
                                fontSize: 11.5,
                                color: context.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.copy_rounded,
                        size: 18,
                        color: context.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // ==========================================
          // زر التفعيل الأولي أو التعطيل النهائي
          // ==========================================
          if (!canShowSetup) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: busy
                    ? null
                    : () {
                        if (enabled) {
                          _confirmDisable(context, () => notifier.disable(''));
                        } else {
                          notifier.enable();
                        }
                      },
                icon: Icon(
                  enabled ? Icons.shield_outlined : Icons.shield_rounded,
                  size: 20,
                  color: enabled ? context.destructive : context.primary,
                ),
                label: Text(
                  enabled
                      ? 'تعطيل المصادقة الثنائية'
                      : 'بدء إعداد وتفعيل المصادقة الثنائية',
                  style: AppTextTheme.cairo(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: enabled ? context.destructive : context.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: enabled
                        ? context.destructive.withValues(alpha: 0.45)
                        : context.primary.withValues(alpha: 0.45),
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// شبكة مربعات إدخال كود المصادقة الثنائية العصرية المنقسمة 3+3 مع الانميشن والحدود الحمراء
class _TwoFactorSplitOtpGrid extends StatefulWidget {
  const _TwoFactorSplitOtpGrid({
    super.key,
    required this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.hasError = false,
  });

  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;
  final bool hasError;

  @override
  State<_TwoFactorSplitOtpGrid> createState() => _TwoFactorSplitOtpGridState();
}

class _TwoFactorSplitOtpGridState extends State<_TwoFactorSplitOtpGrid>
    with SingleTickerProviderStateMixin {
  static const int _cellCount = 6;
  static const String _arabicIndicDigits = '٠١٢٣٤٥٦٧٨٩';
  static const String _easternArabicDigits = '۰۱۲۳۴۵۶۷۸۹';

  final List<TextEditingController> _controllers =
      List.generate(_cellCount, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = [];
  final List<int> _pulseTicks = List.filled(_cellCount, 0);

  late final AnimationController _cursorAnimController;
  late final Animation<double> _cursorFade;

  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();

    _cursorAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _cursorFade = CurvedAnimation(
      parent: _cursorAnimController,
      curve: Curves.easeInOut,
    );

    for (var i = 0; i < _cellCount; i++) {
      final index = i;
      final node = FocusNode(
        debugLabel: 'TwoFactorSplitOtpBox_$index',
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            if (_controllers[index].text.isEmpty && index > 0) {
              _isSyncing = true;
              _controllers[index - 1].text = '';
              _isSyncing = false;
              _focusNodes[index - 1].requestFocus();
              _emit();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
      );

      node.addListener(_handleFocusChanged);
      _focusNodes.add(node);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.enabled && _focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _cursorAnimController.dispose();
    for (final node in _focusNodes) {
      node.removeListener(_handleFocusChanged);
      node.dispose();
    }
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void clear() {
    _isSyncing = true;
    for (final c in _controllers) {
      c.clear();
    }
    _isSyncing = false;
    _emit();
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
  }

  String _normalizeDigits(String value) {
    final buffer = StringBuffer();
    for (final rune in value.runes) {
      final character = String.fromCharCode(rune);
      final arabicIndex = _arabicIndicDigits.indexOf(character);
      if (arabicIndex != -1) {
        buffer.write(arabicIndex);
        continue;
      }
      final easternIndex = _easternArabicDigits.indexOf(character);
      if (easternIndex != -1) {
        buffer.write(easternIndex);
        continue;
      }
      if (RegExp(r'[0-9]').hasMatch(character)) {
        buffer.write(character);
      }
    }
    return buffer.toString();
  }

  void _emit() {
    final code = _controllers.map((c) => c.text).join();
    widget.onChanged(code);
    if (code.length == _cellCount) {
      widget.onCompleted?.call(code);
    }
  }

  int _firstEmptyIndex() {
    for (var i = 0; i < _cellCount; i++) {
      if (_controllers[i].text.isEmpty) {
        return i;
      }
    }
    return _cellCount - 1;
  }

  void _pasteCode(String digits, {int startIndex = 0}) {
    if (digits.isEmpty) return;
    _isSyncing = true;
    for (var i = 0; i < _cellCount; i++) {
      if (i >= startIndex && (i - startIndex) < digits.length) {
        _controllers[i].text = digits[i - startIndex];
        _pulseTicks[i]++;
      }
    }
    _isSyncing = false;
    _emit();

    final nextIndex = (startIndex + digits.length).clamp(0, _cellCount - 1);
    if (digits.length >= _cellCount) {
      FocusScope.of(context).unfocus();
      HapticFeedback.mediumImpact();
    } else {
      _focusNodes[nextIndex].requestFocus();
      HapticFeedback.lightImpact();
    }
  }

  void _handleChanged(int index, String value) {
    if (_isSyncing) return;

    final normalized = _normalizeDigits(value);

    // حالة اللصق المباشر
    if (normalized.length > 1) {
      _pasteCode(normalized, startIndex: index);
      return;
    }

    if (normalized.isNotEmpty) {
      final singleChar = normalized[normalized.length - 1];
      _isSyncing = true;
      _controllers[index].text = singleChar;
      _controllers[index].selection = const TextSelection.collapsed(offset: 1);
      _isSyncing = false;

      setState(() {
        _pulseTicks[index]++;
      });
      HapticFeedback.lightImpact();

      // الانتقال الفوري التلقائي للخانة التالية
      if (index < _cellCount - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        HapticFeedback.mediumImpact();
      }
    } else {
      _isSyncing = true;
      _controllers[index].text = '';
      _isSyncing = false;
    }

    _emit();
  }

  Widget _buildBox(int index, double boxWidth, double boxHeight) {
    final isFocused = _focusNodes[index].hasFocus;
    final hasValue = _controllers[index].text.isNotEmpty;
    final isDark = context.isDark;
    final hasError = widget.hasError;

    final Color borderColor = hasError
        ? context.destructive
        : (isFocused
            ? context.primary
            : (hasValue
                ? context.primary.withValues(alpha: 0.6)
                : context.border));

    final Color bgColor = hasError
        ? (isDark ? const Color(0xFF2E0D12) : const Color(0xFFFFF0F2))
        : (isFocused
            ? (isDark ? const Color(0xFF2E1225) : const Color(0xFFFFF7FB))
            : (hasValue
                ? (isDark ? context.card : Colors.white)
                : (isDark ? const Color(0xFF1B0A16) : const Color(0xFFFCF8FA))));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: boxWidth,
      height: boxHeight,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: hasError ? 2.0 : (isFocused ? 2.0 : 1.2),
        ),
        boxShadow: hasError
            ? [
                BoxShadow(
                  color: context.destructive.withValues(alpha: 0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : (isFocused
                ? [
                    BoxShadow(
                      color: context.primary.withValues(alpha: 0.24),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : (hasValue
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.28 : 0.04,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // نقطة دلالية ناعمة جداً في الخانات الفارغة غير المحددة
          if (!isFocused && !hasValue)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasError
                    ? context.destructive.withValues(alpha: 0.45)
                    : context.mutedForeground.withValues(alpha: 0.35),
              ),
            ),

          // مؤشر الكتابة الوامض الأنيق عندما تكون الخانة محددة وفارغة
          if (isFocused && !hasValue)
            FadeTransition(
              opacity: _cursorFade,
              child: Container(
                width: 2.2,
                height: boxHeight * 0.44,
                decoration: BoxDecoration(
                  color: hasError ? context.destructive : context.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

          // انميشن الارتداد للرقم المكتوب
          TweenAnimationBuilder<double>(
            key: ValueKey(_pulseTicks[index]),
            tween: Tween<double>(begin: 0.72, end: 1.0),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: hasValue ? scale : 1.0,
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  enabled: widget.enabled,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  maxLength: 2,
                  maxLines: 1,
                  showCursor: false,
                  style: AppTextTheme.cairo(
                    color: hasError ? context.destructive : context.foreground,
                    fontWeight: FontWeight.w900,
                    fontSize: boxHeight * 0.44,
                    height: 1.1,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹]')),
                  ],
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) => _handleChanged(index, val),
                  onTap: () {
                    final target = _firstEmptyIndex();
                    if (target < index) {
                      _focusNodes[target].requestFocus();
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// الفاصل البصري الأنيق بين أول 3 أرقام وآخر 3 أرقام
  Widget _buildMiddleDivider(BuildContext context) {
    return Container(
      width: 10,
      height: 2.5,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: context.mutedForeground.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final gap = availableWidth < 340 ? 4.0 : 6.0;
        const middleExtra = 10.0;
        final totalGaps = (4 * gap) + middleExtra;
        final boxWidth =
            ((availableWidth - totalGaps) / _cellCount).clamp(38.0, 48.0);
        final boxHeight = (boxWidth * 1.25).clamp(48.0, 58.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: TextDirection.ltr,
          children: [
            // المجموعة الأولى (3 أرقام)
            _buildBox(0, boxWidth, boxHeight),
            SizedBox(width: gap),
            _buildBox(1, boxWidth, boxHeight),
            SizedBox(width: gap),
            _buildBox(2, boxWidth, boxHeight),

            // الفاصل الأوسط (Dash)
            _buildMiddleDivider(context),

            // المجموعة الثانية (3 أرقام)
            _buildBox(3, boxWidth, boxHeight),
            SizedBox(width: gap),
            _buildBox(4, boxWidth, boxHeight),
            SizedBox(width: gap),
            _buildBox(5, boxWidth, boxHeight),
          ],
        );
      },
    );
  }
}
