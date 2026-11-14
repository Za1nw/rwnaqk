import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/utils/app_notifier.dart';
import 'package:rwnaqk_frontend/core/widgets/app_password_field.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/user_session_model.dart';
import 'package:rwnaqk_frontend/modules/customer/providers/sessions_and_passkeys_providers.dart';

/// شاشة كلمة المرور والأمان
///
/// تجربة بوتيك فاخرة تتضمن:
/// 1. تحديث كلمة المرور مع مؤشر ذكي لقوة كلمة المرور وتطابقها
/// 2. إدارة الأجهزة والجلسات النشطة مع إبراز الجلسة الحالية وحمايتها
class PasswordAndSecurityScreen extends ConsumerStatefulWidget {
  const PasswordAndSecurityScreen({super.key});

  @override
  ConsumerState<PasswordAndSecurityScreen> createState() =>
      _PasswordAndSecurityScreenState();
}

class _PasswordAndSecurityScreenState
    extends ConsumerState<PasswordAndSecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isChangingPassword = false;
  bool _isRevokingAll = false;
  int? _revokingSessionId;

  String _newPassword = '';
  String _confirmPassword = '';

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(() {
      if (mounted) {
        setState(() => _newPassword = _newPasswordController.text);
      }
    });
    _confirmPasswordController.addListener(() {
      if (mounted) {
        setState(() => _confirmPassword = _confirmPasswordController.text);
      }
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // حساب مؤشر قوة كلمة المرور (0 إلى 3)
  int _calculateStrength(String pass) {
    if (pass.isEmpty) return 0;
    int score = 0;
    if (pass.length >= 8) score++;
    if (RegExp(r'[0-9]').hasMatch(pass) && RegExp(r'[a-zA-Z]').hasMatch(pass)) {
      score++;
    }
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(pass)) {
      score++;
    }
    return score;
  }

  Future<void> _submitChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final currentPass = _currentPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (newPass != confirmPass) {
      AppNotifier.error('كلمة المرور الجديدة غير متطابقة مع التأكيد',
          isKey: false);
      return;
    }

    setState(() => _isChangingPassword = true);

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.changePassword(
        currentPassword: currentPass,
        newPassword: newPass,
        newPasswordConfirmation: confirmPass,
      );

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      HapticFeedback.mediumImpact();
      AppNotifier.success('تم تغيير كلمة المرور بنجاح وحماية حسابك',
          isKey: false);
    } catch (e) {
      AppNotifier.errorFrom(e);
    } finally {
      if (mounted) {
        setState(() => _isChangingPassword = false);
      }
    }
  }

  Future<void> _confirmRevokeSession(UserSessionModel session) async {
    if (session.isCurrent) {
      AppNotifier.info(
        'هذه هي جلستك الحالية. لا يمكن تسجيل الخروج منها من هذه القائمة.',
        isKey: false,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'إنهاء الجلسة',
          style: AppTextTheme.cairo(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: context.foreground,
          ),
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في تسجيل الخروج من الجهاز "${session.deviceName}"؟',
          style: AppTextTheme.cairo(
            fontSize: 13.5,
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
              'إنهاء الجلسة',
              style: AppTextTheme.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _revokingSessionId = session.id);
    try {
      await ref.read(activeSessionsProvider.notifier).revokeSession(session.id);
      HapticFeedback.lightImpact();
      AppNotifier.success('تم إنهاء جلسة الجهاز بنجاح', isKey: false);
    } catch (e) {
      AppNotifier.errorFrom(e);
    } finally {
      if (mounted) {
        setState(() => _revokingSessionId = null);
      }
    }
  }

  Future<void> _confirmRevokeAllOthers(List<UserSessionModel> sessions) async {
    final otherCount = sessions.where((s) => !s.isCurrent).length;
    if (otherCount == 0) {
      AppNotifier.info('لا توجد جلسات أخرى نشطة حالياً', isKey: false);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'تسجيل الخروج من الجلسات الأخرى',
          style: AppTextTheme.cairo(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: context.foreground,
          ),
        ),
        content: Text(
          'سيتم إنهاء وتسجيل الخروج من جميع الأجهزة الأخرى ($otherCount جهاز) مع الإبقاء على هذا الجهاز متصلاً.',
          style: AppTextTheme.cairo(
            fontSize: 13.5,
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
              'تسجيل خروج الجميع',
              style: AppTextTheme.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isRevokingAll = true);
    try {
      await ref.read(activeSessionsProvider.notifier).revokeOtherSessions();
      HapticFeedback.mediumImpact();
      AppNotifier.success('تم إنهاء جميع الجلسات الأخرى بنجاح', isKey: false);
    } catch (e) {
      AppNotifier.errorFrom(e);
    } finally {
      if (mounted) {
        setState(() => _isRevokingAll = false);
      }
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'غير محدد';
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 2) return 'نشط الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
  }

  IconData _deviceIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('phone') ||
        lower.contains('iphone') ||
        lower.contains('android') ||
        lower.contains('mobile') ||
        lower.contains('samsung') ||
        lower.contains('pixel')) {
      return Icons.phone_iphone_rounded;
    }
    if (lower.contains('ipad') || lower.contains('tablet')) {
      return Icons.tablet_mac_rounded;
    }
    if (lower.contains('mac') ||
        lower.contains('windows') ||
        lower.contains('pc') ||
        lower.contains('linux') ||
        lower.contains('desktop') ||
        lower.contains('web')) {
      return Icons.laptop_mac_rounded;
    }
    return Icons.devices_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final sessionsAsync = ref.watch(activeSessionsProvider);

    final strength = _calculateStrength(_newPassword);
    final hasNewPass = _newPassword.isNotEmpty;
    final isMatching =
        _confirmPassword.isNotEmpty && _newPassword == _confirmPassword;

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'كلمة المرور والأمان',
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
            // هيدر أمان الحساب البوتيكي العصري
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
                        Icons.shield_rounded,
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
                          'أمان الحساب والجلسات',
                          style: AppTextTheme.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: context.foreground,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'تحكم بكلمة مرورك وتتبع الأجهزة المسجلة لحماية خصوصيتك',
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
            // 1. بطاقة تغيير كلمة المرور
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
              child: Form(
                key: _formKey,
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
                            Icons.lock_reset_rounded,
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
                                'تغيير كلمة المرور',
                                style: AppTextTheme.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: context.foreground,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'قم بتعيين كلمة مرور قوية لحماية حسابك',
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
                    const SizedBox(height: 22),

                    // كلمة المرور الحالية
                    AppPasswordField(
                      controller: _currentPasswordController,
                      label: 'كلمة المرور الحالية',
                      hint: 'أدخل كلمة المرور الحالية',
                      prefixIcon: Icons.lock_outline_rounded,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'يرجى إدخال كلمة المرور الحالية';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // كلمة المرور الجديدة
                    AppPasswordField(
                      controller: _newPasswordController,
                      label: 'كلمة المرور الجديدة',
                      hint: '8 أحرف على الأقل',
                      prefixIcon: Icons.lock_open_rounded,
                      validator: (val) {
                        if (val == null || val.trim().length < 8) {
                          return 'يجب أن لا تقل كلمة المرور عن 8 أحرف';
                        }
                        return null;
                      },
                    ),

                    // مؤشر قوة كلمة المرور الذكي
                    if (hasNewPass) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: strength / 3,
                                minHeight: 6,
                                backgroundColor: isDark
                                    ? Colors.white12
                                    : context.primary.withValues(alpha: 0.08),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  strength <= 1
                                      ? context.destructive
                                      : (strength == 2
                                          ? context.warning
                                          : context.success),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            strength <= 1
                                ? 'ضعيفة'
                                : strength == 2
                                    ? 'متوسطة'
                                    : 'قوية وممتازة 🛡️',
                            style: AppTextTheme.cairo(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: strength <= 1
                                  ? context.destructive
                                  : (strength == 2
                                      ? context.warning
                                      : context.success),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),

                    // تأكيد كلمة المرور الجديدة
                    AppPasswordField(
                      controller: _confirmPasswordController,
                      label: 'تأكيد كلمة المرور الجديدة',
                      hint: 'أعد كتابة كلمة المرور الجديدة',
                      prefixIcon: Icons.check_circle_outline_rounded,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'يرجى تأكيد كلمة المرور الجديدة';
                        }
                        if (val != _newPasswordController.text) {
                          return 'كلمة المرور غير متطابقة';
                        }
                        return null;
                      },
                    ),

                    // مؤشر تطابق كلمتي المرور
                    if (_confirmPassword.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            isMatching
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            size: 16,
                            color: isMatching
                                ? context.success
                                : context.destructive,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isMatching
                                ? 'كلمتا المرور متطابقتان'
                                : 'كلمتا المرور غير متطابقتين',
                            style: AppTextTheme.cairo(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isMatching
                                  ? context.success
                                  : context.destructive,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),

                    // زر حفظ كلمة المرور البوتيكي
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primary,
                          foregroundColor: context.primaryForeground,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed:
                            _isChangingPassword ? null : _submitChangePassword,
                        child: _isChangingPassword
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
                                  const Icon(Icons.check_rounded, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'حفظ كلمة المرور الجديدة',
                                    style: AppTextTheme.cairo(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ==========================================
            // 2. بطاقة الجلسات النشطة والأجهزة
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
                          Icons.devices_rounded,
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
                              'الجلسات والأجهزة النشطة',
                              style: AppTextTheme.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: context.foreground,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'الأجهزة المتصلة بحسابك حالياً',
                              style: AppTextTheme.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: context.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'تحديث الجلسات',
                        icon: Icon(
                          Icons.refresh_rounded,
                          size: 22,
                          color: context.primary,
                        ),
                        onPressed: () =>
                            ref.read(activeSessionsProvider.notifier).refresh(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // قائمة الجلسات
                  sessionsAsync.when(
                    loading: () => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: CircularProgressIndicator(
                          color: context.primary,
                        ),
                      ),
                    ),
                    error: (err, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: context.destructive,
                              size: 36,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'تعذر تحميل الجلسات النشطة',
                              style: AppTextTheme.cairo(
                                fontWeight: FontWeight.bold,
                                color: context.destructive,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => ref
                                  .read(activeSessionsProvider.notifier)
                                  .refresh(),
                              child: Text(
                                'إعادة المحاولة',
                                style: AppTextTheme.cairo(
                                  color: context.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    data: (sessions) {
                      if (sessions.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'لا توجد جلسات مسجلة',
                              style: AppTextTheme.cairo(
                                color: context.mutedForeground,
                              ),
                            ),
                          ),
                        );
                      }

                      final otherSessions =
                          sessions.where((s) => !s.isCurrent).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // زر إنهاء جميع الجلسات الأخرى
                          if (otherSessions.isNotEmpty) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: context.destructive.withValues(
                                      alpha: 0.6,
                                    ),
                                    width: 1.2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: _isRevokingAll
                                    ? null
                                    : () => _confirmRevokeAllOthers(sessions),
                                icon: _isRevokingAll
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: context.destructive,
                                        ),
                                      )
                                    : Icon(
                                        Icons.logout_rounded,
                                        color: context.destructive,
                                        size: 18,
                                      ),
                                label: Text(
                                  'تسجيل الخروج من جميع الجلسات الأخرى (${otherSessions.length})',
                                  style: AppTextTheme.cairo(
                                    color: context.destructive,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          // بطاقات الجلسات الفردية
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: sessions.length,
                            separatorBuilder: (_, i) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final session = sessions[index];
                              final isCurrent = session.isCurrent;
                              final isRevokingThis =
                                  _revokingSessionId == session.id;

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? context.success.withValues(
                                          alpha: isDark ? 0.12 : 0.06,
                                        )
                                      : (isDark
                                          ? Colors.white.withValues(alpha: 0.03)
                                          : context.primary
                                              .withValues(alpha: 0.02)),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isCurrent
                                        ? context.success.withValues(alpha: 0.45)
                                        : context.border,
                                    width: isCurrent ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: isCurrent
                                            ? context.success.withValues(
                                                alpha: 0.18,
                                              )
                                            : context.primary.withValues(
                                                alpha: 0.08,
                                              ),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isCurrent
                                              ? context.success.withValues(
                                                  alpha: 0.35,
                                                )
                                              : context.border,
                                          width: 1,
                                        ),
                                      ),
                                      child: Icon(
                                        _deviceIcon(session.deviceName),
                                        color: isCurrent
                                            ? context.success
                                            : context.primary,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  session.deviceName,
                                                  style: AppTextTheme.cairo(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w800,
                                                    color: context.foreground,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (isCurrent) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: context.success,
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                        Icons.shield_rounded,
                                                        color: Colors.white,
                                                        size: 11,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'الجلسة الحالية',
                                                        style:
                                                            AppTextTheme.cairo(
                                                          fontSize: 10.5,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'آخر نشاط: ${_formatDateTime(session.lastUsedAt ?? session.createdAt)}',
                                            style: AppTextTheme.cairo(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: context.mutedForeground,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // إجراء الجلسة
                                    if (isCurrent)
                                      Tooltip(
                                        message:
                                            'لا يمكن إنهاء الجلسة الحالية من هذه الشاشة',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: context.mutedForeground
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            'هذا الجهاز',
                                            style: AppTextTheme.cairo(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w800,
                                              color: context.mutedForeground,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      IconButton(
                                        tooltip: 'إنهاء هذه الجلسة',
                                        icon: isRevokingThis
                                            ? SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: context.destructive,
                                                ),
                                              )
                                            : Icon(
                                                Icons.delete_outline_rounded,
                                                color: context.destructive,
                                                size: 22,
                                              ),
                                        onPressed: isRevokingThis
                                            ? null
                                            : () =>
                                                _confirmRevokeSession(session),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
