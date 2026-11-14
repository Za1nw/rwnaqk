import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_validators.dart';
import 'package:rwnaqk_frontend/core/widgets/app_button.dart';
import 'package:rwnaqk_frontend/core/widgets/app_password_field.dart';
import 'package:rwnaqk_frontend/modules/auth/providers/auth_flow_providers.dart';
import 'package:rwnaqk_frontend/modules/auth/widgets/auth_blob_background.dart';
import 'package:rwnaqk_frontend/modules/auth/widgets/auth_centered_container.dart';
import 'package:rwnaqk_frontend/routes/app_route_args.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

/// شاشة تعيين كلمة المرور الجديدة بتصميم ملكي فاخر ومؤشرات أمان حية
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  String _currentPassword = '';
  String _currentConfirm = '';
  String _routeCode = '';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final target = (args[AppRouteArgs.target] ?? args['target'] ?? '')
          .toString()
          .trim();
      final code = (args['code'] ?? '').toString().trim();
      if (code.isNotEmpty) {
        _routeCode = code;
      }
      if (target.isNotEmpty) {
        final currentTarget = ref.read(forgotPasswordFlowProvider).target;
        if (currentTarget.isEmpty) {
          Future.microtask(() {
            if (mounted) {
              ref.read(forgotPasswordFlowProvider.notifier).setTarget(target);
            }
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  int _calculateStrength(String password) {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[a-zA-Z]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>_~`\-+=]').hasMatch(password)) score++;
    return score;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordFlowProvider);
    final notifier = ref.read(forgotPasswordFlowProvider.notifier);
    final isDark = context.isDark;

    final targetDisplay = state.target.isNotEmpty
        ? state.target
        : notifier.emailController.text.trim();

    final strength = _calculateStrength(_currentPassword);
    final hasMinLength = _currentPassword.length >= 6;
    final hasStrongLength = _currentPassword.length >= 8;
    final hasNumberOrSpecial =
        RegExp(r'[0-9!@#$%^&*(),.?":{}|<>_~`\-+=]').hasMatch(_currentPassword);
    final isMatching = _currentConfirm.isNotEmpty &&
        _currentConfirm == _currentPassword;

    final activeCode = state.otp.isNotEmpty ? state.otp : _routeCode;

    return Scaffold(
      backgroundColor: context.background,
      body: AuthBlobBackground(
        child: SafeArea(
          child: AuthCenteredContainer(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Form(
                  key: notifier.resetFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. أيقونة الهوية الملكية لإعادة التعيين
                      _buildHeroIcon(context, isDark),
                      const SizedBox(height: 18),

                      // 2. العنوان الرئيسي والوصف الإرشادي
                      Text(
                        Tk.fpNewTitle.tr,
                        textAlign: TextAlign.center,
                        style: AppTextTheme.cairo(
                          color: context.foreground,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        Tk.fpNewSubtitle.tr,
                        textAlign: TextAlign.center,
                        style: AppTextTheme.cairo(
                          color: context.mutedForeground,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 3. كبسولة الحساب المؤكد
                      if (targetDisplay.isNotEmpty) ...[
                        _buildVerifiedAccountBadge(context, targetDisplay, isDark),
                        const SizedBox(height: 22),
                      ],

                      // 4. حقل كلمة المرور الجديدة
                      AppPasswordField(
                        controller: notifier.passwordController,
                        label: Tk.fpNewPassword.tr,
                        hint: 'أدخل كلمة مرور قوية',
                        prefixIcon: Icons.lock_outline_rounded,
                        textInputAction: TextInputAction.next,
                        onChanged: (val) {
                          setState(() {
                            _currentPassword = val;
                          });
                        },
                        validator: (v) => AppValidators.password(
                          v,
                          requiredMsg: Tk.loginPasswordRequired.tr,
                          shortMsg: Tk.fpNewShort.tr,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 5. شريط قياس قوة كلمة المرور (Strength Meter)
                      if (_currentPassword.isNotEmpty) ...[
                        _buildStrengthMeter(context, strength, isDark),
                        const SizedBox(height: 14),
                      ],

                      // 6. حقل تأكيد كلمة المرور
                      AppPasswordField(
                        controller: notifier.confirmPasswordController,
                        label: Tk.fpNewConfirm.tr,
                        hint: 'أعد إدخال كلمة المرور',
                        prefixIcon: isMatching
                            ? Icons.check_circle_rounded
                            : Icons.lock_reset_rounded,
                        textInputAction: TextInputAction.done,
                        onChanged: (val) {
                          setState(() {
                            _currentConfirm = val;
                          });
                        },
                        validator: (v) => AppValidators.confirmPassword(
                          v,
                          notifier.passwordController.text,
                          requiredMsg: Tk.fpNewShort.tr,
                          mismatchMsg: Tk.fpNewMismatch.tr,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 7. قائمة التحقق الأمني الذكية (Security Checklist)
                      _buildSecurityChecklist(
                        context,
                        hasMinLength: hasMinLength,
                        hasStrongLength: hasStrongLength,
                        hasNumberOrSpecial: hasNumberOrSpecial,
                        isMatching: isMatching,
                      ),
                      const SizedBox(height: 24),

                      // 8. زر الحفظ وتعيين كلمة المرور
                      AppButton(
                        text: Tk.fpNewSave.tr,
                        icon: Icons.check_rounded,
                        isLoading: state.isLoading,
                        height: 52,
                        borderRadius: 16,
                        onPressed: state.isLoading
                            ? null
                            : () => notifier.resetPassword(code: activeCode),
                      ),
                      const SizedBox(height: 12),

                      // 9. زر إلغاء والعودة لتسجيل الدخول
                      TextButton(
                        onPressed: () => AppNav.offAllNamed(AppRoutes.login),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          Tk.fpCancel.tr,
                          style: AppTextTheme.cairo(
                            color: context.mutedForeground,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// رأس الشاشة: أيقونة الأمان الملكية
  Widget _buildHeroIcon(BuildContext context, bool isDark) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF380C23),
                  const Color(0xFF1B0713),
                ]
              : [
                  Colors.white,
                  AppColors.burgundy50,
                ],
        ),
        border: Border.all(
          color: (isDark ? BrandColors.gold : BrandColors.burgundy)
              .withValues(alpha: 0.28),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? BrandColors.gold : BrandColors.burgundy)
                .withValues(alpha: isDark ? 0.22 : 0.10),
            blurRadius: 22,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.key_rounded,
          size: 36,
          color: context.primary,
        ),
      ),
    );
  }

  /// كبسولة عرض الحساب المؤكد باللون الأخضر الآمن
  Widget _buildVerifiedAccountBadge(
    BuildContext context,
    String target,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_user_rounded,
            size: 15,
            color: isDark ? AppColors.successDark : AppColors.success,
          ),
          const SizedBox(width: 8),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              target,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextTheme.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: context.foreground,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
            decoration: BoxDecoration(
              color: isDark ? AppColors.successDark : AppColors.success,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'مؤكد',
              style: AppTextTheme.cairo(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// شريط قياس قوة كلمة المرور المتدرج
  Widget _buildStrengthMeter(BuildContext context, int score, bool isDark) {
    Color barColor;
    String label;

    switch (score) {
      case 1:
        barColor = AppColors.error;
        label = 'كلمة مرور ضعيفة';
        break;
      case 2:
        barColor = const Color(0xFFE59C00);
        label = 'كلمة مرور متوسطة';
        break;
      case 3:
        barColor = context.primary;
        label = 'كلمة مرور جيدة';
        break;
      case 4:
        barColor = isDark ? AppColors.successDark : AppColors.success;
        label = 'كلمة مرور قوية وممتازة';
        break;
      default:
        barColor = Colors.grey;
        label = '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'قوة كلمة المرور',
              style: AppTextTheme.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.mutedForeground,
              ),
            ),
            Text(
              label,
              style: AppTextTheme.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (var i = 1; i <= 4; i++) ...[
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= score
                        ? barColor
                        : context.border.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (i < 4) const SizedBox(width: 4),
            ],
          ],
        ),
      ],
    );
  }

  /// قائمة فحص معايير الأمان الحية
  Widget _buildSecurityChecklist(
    BuildContext context, {
    required bool hasMinLength,
    required bool hasStrongLength,
    required bool hasNumberOrSpecial,
    required bool isMatching,
  }) {
    final isDark = context.isDark;

    Widget checkItem(String text, bool isPassed) {
      final successColor =
          isDark ? AppColors.successDark : AppColors.success;
      final inactiveColor = context.mutedForeground.withValues(alpha: 0.6);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isPassed
              ? successColor.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isPassed
                ? successColor.withValues(alpha: 0.3)
                : context.border.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPassed
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 13,
              color: isPassed ? successColor : inactiveColor,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: AppTextTheme.cairo(
                fontSize: 11,
                fontWeight: isPassed ? FontWeight.w800 : FontWeight.w600,
                color: isPassed ? context.foreground : inactiveColor,
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        checkItem('8 أحرف على الأقل', hasStrongLength),
        checkItem('أرقام أو رموز خاصة', hasNumberOrSpecial),
        checkItem('تطابق كلمتي المرور', isMatching),
      ],
    );
  }
}
