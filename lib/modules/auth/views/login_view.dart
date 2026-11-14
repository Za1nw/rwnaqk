import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_validators.dart';
import 'package:rwnaqk_frontend/core/widgets/app_button.dart';
import 'package:rwnaqk_frontend/core/widgets/app_input_field.dart';
import 'package:rwnaqk_frontend/core/widgets/app_password_field.dart';
import 'package:rwnaqk_frontend/modules/auth/providers/auth_flow_providers.dart';
import 'package:rwnaqk_frontend/modules/auth/widgets/auth_blob_background.dart';
import 'package:rwnaqk_frontend/modules/auth/widgets/auth_form_page_layout.dart';

/// شاشة تسجيل الدخول بتصميم ملكي فاخر، هرمية واضحة، وانسيابية حركية تامة
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

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
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  BoxDecoration _podDecoration(BuildContext context, bool isDark) {
    return BoxDecoration(
      color: isDark
          ? AppColors.surfaceDark.withValues(alpha: 0.94)
          : Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: isDark
            ? AppColors.borderDark.withValues(alpha: 0.6)
            : AppColors.borderLight,
        width: 1.2,
      ),
      boxShadow: isDark
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ]
          : [
              BoxShadow(
                color: context.shadow.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginFormProvider);
    final notifier = ref.read(loginFormProvider.notifier);
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.background,
      body: AuthBlobBackground(
        child: SafeArea(
          child: AuthFormPageLayout(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 28),

                    // 1. أيقونة الهوية الملكية العصرية لتسجيل الدخول
                    Center(
                      child: Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          gradient: BrandGradients.royalBurgundy,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: BrandColors.gold.withValues(
                              alpha: isDark ? 0.45 : 0.35,
                            ),
                            width: 1.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: BrandColors.burgundy.withValues(
                                alpha: isDark ? 0.38 : 0.18,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lock_open_rounded,
                            size: 30,
                            color: BrandColors.gold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. كبسولة الأمان
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF330C20)
                              : AppColors.burgundy50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: context.primary.withValues(
                              alpha: isDark ? 0.30 : 0.14,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 13,
                              color: context.primary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'تسجيل الدخول الآمن',
                              style: AppTextTheme.cairo(
                                color: context.primary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 3. العنوان الرئيسي والوصف الإرشادي
                    Text(
                      Tk.loginTitle.tr,
                      textAlign: TextAlign.center,
                      style: AppTextTheme.cairo(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: context.foreground,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'سجّل دخولك للمتابعة والوصول إلى حقيبتك ومفضلاتك',
                      textAlign: TextAlign.center,
                      style: AppTextTheme.cairo(
                        fontSize: 13.5,
                        color: context.mutedForeground,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4. بطاقة بيانات تسجيل الدخول
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: _podDecoration(context, isDark),
                      child: Form(
                        key: notifier.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildPodHeader(
                              context,
                              icon: Icons.fingerprint_rounded,
                              title: 'بيانات الحساب',
                              subtitle:
                                  'أدخل بريدك الإلكتروني وكلمة المرور للمتابعة',
                              isDark: isDark,
                            ),
                            const SizedBox(height: 18),

                            // البريد الإلكتروني
                            AppInputField(
                              controller: notifier.emailController,
                              label: Tk.loginEmailLabel.tr,
                              hint: Tk.loginEmailHint.tr,
                              prefixIcon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: AppValidators.email,
                            ),
                            const SizedBox(height: 14),

                            // كلمة المرور
                            AppPasswordField(
                              controller: notifier.passwordController,
                              label: Tk.loginPasswordLabel.tr,
                              hint: Tk.loginPasswordHint.tr,
                              prefixIcon: Icons.lock_outline_rounded,
                              textInputAction: TextInputAction.done,
                              validator: AppValidators.password,
                            ),
                            const SizedBox(height: 6),

                            // رابط نسيت كلمة المرور
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: TextButton(
                                onPressed: notifier.goToForgotPassword,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 4,
                                  ),
                                  splashFactory: NoSplash.splashFactory,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.help_outline_rounded,
                                      size: 13,
                                      color: context.primary,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      Tk.loginForgot.tr,
                                      style: AppTextTheme.cairo(
                                        color: context.primary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // صف أزرار تسجيل الدخول: الزر الرئيسي وبجانبه زر البصمة / قفل الهاتف
                            Row(
                              children: [
                                // الزر الملكي لتسجيل الدخول
                                Expanded(
                                  child: AppButton(
                                    text: Tk.loginSignIn.tr,
                                    icon: Icons.arrow_forward_rounded,
                                    isLoading: state.isLoading,
                                    height: 52,
                                    borderRadius: 16,
                                    onPressed: (state.isLoading ||
                                            state.isBiometricLoading)
                                        ? null
                                        : notifier.login,
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // زر الدخول بالبصمة أو كلمة مرور الهاتف
                                _buildBiometricButton(
                                  context: context,
                                  isDark: isDark,
                                  isLoading: state.isBiometricLoading,
                                  isDisabled: state.isLoading,
                                  onPressed: notifier.loginWithBiometrics,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // 5. فاصل وسائل الدخول الاجتماعية
                    _buildDivider(context, isDark),
                    const SizedBox(height: 18),

                    // 6. زر الدخول السريع عبر Google فقط
                    _buildGoogleButton(
                      context: context,
                      onPressed: notifier.loginWithGoogle,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 18),

                    // 7. كرت الدخول كزائر (وضع الاستكشاف الراقي)
                    _buildGuestExploreCard(context, isDark, notifier),
                    const SizedBox(height: 22),

                    // 8. قسم إنشاء حساب جديد (الفوتر)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Tk.loginNoAccount.tr,
                          style: AppTextTheme.cairo(
                            color: context.mutedForeground,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: notifier.goToRegister,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            child: Text(
                              Tk.loginCreateAccount.tr,
                              style: AppTextTheme.cairo(
                                color: context.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 13.5,
                              ).copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: context.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// رأس البطاقة المعيارية (Pod Header)
  Widget _buildPodHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool isDark = false,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: context.primary.withValues(alpha: isDark ? 0.18 : 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: context.primary.withValues(alpha: isDark ? 0.3 : 0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: context.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextTheme.cairo(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: context.foreground,
                ),
              ),
              Text(
                subtitle,
                style: AppTextTheme.cairo(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: context.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// فاصل بصري أنيق بين الحقول وتسجيل الدخول الاجتماعي
  Widget _buildDivider(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: context.border.withValues(alpha: isDark ? 0.45 : 0.65),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'أو المتابعة عبر',
            style: AppTextTheme.cairo(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: context.mutedForeground,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: context.border.withValues(alpha: isDark ? 0.45 : 0.65),
          ),
        ),
      ],
    );
  }

  /// زر صغير فاخر للدخول بالبصمة أو كلمة مرور / قفل الهاتف
  Widget _buildBiometricButton({
    required BuildContext context,
    required bool isDark,
    required bool isLoading,
    required bool isDisabled,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: 'الدخول ببصمة الإصبع أو رمز قفل الهاتف',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (isLoading || isDisabled)
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  onPressed();
                },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF450622),
                        const Color(0xFF280314),
                      ]
                    : [
                        BrandColors.burgundy,
                        const Color(0xFF4E0123),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: BrandColors.gold.withValues(
                  alpha: isDark ? 0.65 : 0.50,
                ),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: BrandColors.burgundy.withValues(
                    alpha: isDark ? 0.40 : 0.22,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          BrandColors.gold,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.fingerprint_rounded,
                      size: 28,
                      color: BrandColors.gold,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  /// زر الدخول الموحد والراقي عبر Google
  Widget _buildGoogleButton({
    required BuildContext context,
    required VoidCallback onPressed,
    bool isDark = false,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark.withValues(alpha: 0.92)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppColors.borderDark.withValues(alpha: 0.75)
                : AppColors.borderLight,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: context.shadow.withValues(alpha: isDark ? 0.22 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    fontFamily: AppTextTheme.fontFamily,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF4285F4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'المتابعة باستخدام Google',
              style: AppTextTheme.cairo(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: context.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// كرت استكشاف المتجر كزائر (بدون تسجيل دخول)
  Widget _buildGuestExploreCard(
    BuildContext context,
    bool isDark,
    LoginFormNotifier notifier,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          notifier.continueAsGuest();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: context.primary.withValues(alpha: isDark ? 0.10 : 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.primary.withValues(alpha: isDark ? 0.32 : 0.18),
              width: 1.1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.primary.withValues(
                    alpha: isDark ? 0.22 : 0.10,
                  ),
                ),
                child: Icon(
                  Icons.explore_outlined,
                  size: 18,
                  color: context.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تصفح المتجر كزائر',
                      style: AppTextTheme.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: context.foreground,
                      ),
                    ),
                    Text(
                      'استكشف التشكيلات والمنتجات بدون تسجيل دخول',
                      style: AppTextTheme.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: context.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: context.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
