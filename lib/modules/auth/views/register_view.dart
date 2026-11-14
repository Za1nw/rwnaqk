import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/constants/app_env.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_notifier.dart';
import 'package:rwnaqk_frontend/core/utils/app_validators.dart';
import 'package:rwnaqk_frontend/core/widgets/app_button.dart';
import 'package:rwnaqk_frontend/core/widgets/app_input_field.dart';
import 'package:rwnaqk_frontend/core/widgets/app_password_field.dart';
import 'package:rwnaqk_frontend/core/widgets/app_select_field.dart';
import 'package:rwnaqk_frontend/modules/auth/providers/auth_flow_providers.dart';
import 'package:rwnaqk_frontend/modules/auth/widgets/auth_blob_background.dart';
import 'package:rwnaqk_frontend/modules/auth/widgets/auth_form_page_layout.dart';
import 'package:url_launcher/url_launcher.dart';

/// شاشة إنشاء حساب جديد بتصميم معياري فاخر (Modular Boutique Inset Pods)
/// توزيع انسيابي للمدخلات بدون بطاقات صندوقية مغلقة، مع فصل أنيق بين
/// بيانات الهوية والاتصال وبيانات الأمان وفق أرقى معايير UI/UX Pro.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  String _currentPassword = '';
  String _currentConfirm = '';

  static String get _resolvedApiBaseUrl => AppEnv.apiBaseUrl;

  static Uri _buildLegalUri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final baseUrl = _resolvedApiBaseUrl.endsWith('/')
        ? _resolvedApiBaseUrl.substring(0, _resolvedApiBaseUrl.length - 1)
        : _resolvedApiBaseUrl;
    return Uri.parse('$baseUrl$normalizedPath');
  }

  Future<void> _openLegalPage(String path) async {
    final uri = _buildLegalUri(path);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      AppNotifier.error(Tk.commonUnexpectedError.tr, title: Tk.commonError.tr);
    }
  }

  @override
  void initState() {
    super.initState();
    ref.read(registerFormProvider.notifier).formKey = _formKey;
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

  int _calculateStrength(String password) {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[a-zA-Z]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>_~`\-+=]').hasMatch(password)) score++;
    return score;
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
    final state = ref.watch(registerFormProvider);
    final notifier = ref.read(registerFormProvider.notifier);
    final isDark = context.isDark;

    final password = _currentPassword.isNotEmpty
        ? _currentPassword
        : notifier.passwordController.text;
    final confirm = _currentConfirm.isNotEmpty
        ? _currentConfirm
        : notifier.confirmPasswordController.text;
    final strength = _calculateStrength(password);
    final isMatching = confirm.isNotEmpty && confirm == password;

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

                    // 1. أيقونة الهوية الملكية العصرية لإنشاء الحساب
                    Center(
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: BrandGradients.royalBurgundy,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: BrandColors.gold.withValues(
                              alpha: isDark ? 0.4 : 0.3,
                            ),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: BrandColors.burgundy.withValues(
                                alpha: isDark ? 0.35 : 0.18,
                              ),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person_add_alt_1_rounded,
                            size: 28,
                            color: BrandColors.gold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. العنوان الرئيسي والوصف الإرشادي
                    Text(
                      Tk.registerTitle.tr,
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
                      'أهلاً بك في رَوْنَقُك، سجّل بياناتك لبدء تجربة تسوق راقية',
                      textAlign: TextAlign.center,
                      style: AppTextTheme.cairo(
                        fontSize: 13.5,
                        color: context.mutedForeground,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3. نموذج الإدخال المعياري
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ----------------------------------------------------
                          // البطاقة 1: البيانات الشخصية ومعلومات الاتصال
                          // ----------------------------------------------------
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: _podDecoration(context, isDark),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildPodHeader(
                                  context,
                                  icon: Icons.badge_outlined,
                                  title: 'البيانات الشخصية والاتصال',
                                  subtitle:
                                      'الاسم، البريد الإلكتروني، والهاتف والموقع',
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 16),

                                // الاسم الأول واسم العائلة
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: AppInputField(
                                        controller:
                                            notifier.firstNameController,
                                        label: Tk.registerFirstNameLabel.tr,
                                        hint: Tk.registerFirstNameHint.tr,
                                        prefixIcon:
                                            Icons.person_outline_rounded,
                                        textInputAction: TextInputAction.next,
                                        validator: (v) =>
                                            AppValidators.required(
                                          v,
                                          Tk.registerFirstNameRequired.tr,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: AppInputField(
                                        controller: notifier.lastNameController,
                                        label: Tk.registerLastNameLabel.tr,
                                        hint: Tk.registerLastNameHint.tr,
                                        prefixIcon: Icons.badge_outlined,
                                        textInputAction: TextInputAction.next,
                                        validator: (v) =>
                                            AppValidators.required(
                                          v,
                                          Tk.registerLastNameRequired.tr,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // البريد الإلكتروني (أولاً كمعرف الحساب الرئيسي)
                                AppInputField(
                                  controller: notifier.emailController,
                                  label: Tk.registerEmailLabel.tr,
                                  hint: Tk.registerEmailHint.tr,
                                  prefixIcon: Icons.alternate_email_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) => AppValidators.email(
                                    v,
                                    requiredMsg: Tk.registerEmailRequired.tr,
                                    invalidMsg: Tk.registerEmailInvalid.tr,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // رقم الهاتف
                                AppInputField(
                                  controller: notifier.phoneController,
                                  label: Tk.registerPhoneLabel.tr,
                                  hint: Tk.registerPhoneHint.tr,
                                  prefixIcon: Icons.phone_android_rounded,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  validator: AppValidators.phone,
                                ),
                                const SizedBox(height: 12),

                                // تحديد الجنس (ذكر أو أنثى حصراً)
                                _buildGenderSelector(
                                  context,
                                  state,
                                  notifier,
                                  isDark,
                                ),
                                const SizedBox(height: 12),

                                // المحافظة
                                AppSelectField<String>(
                                  label: Tk.registerGovernorateLabel.tr,
                                  hint: Tk.registerGovernorateHint.tr,
                                  items: state.governorates,
                                  value: state.selectedGovernorate,
                                  prefixIcon: Icons.location_on_outlined,
                                  itemLabel: (e) => e,
                                  onChanged: notifier.selectGovernorate,
                                  validator: (v) =>
                                      AppValidators.requiredSelection(
                                    v,
                                    Tk.registerGovernorateRequired.tr,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ----------------------------------------------------
                          // البطاقة 2: الأمان وكلمة المرور
                          // ----------------------------------------------------
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: _podDecoration(context, isDark),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildPodHeader(
                                  context,
                                  icon: Icons.shield_outlined,
                                  title: 'الأمان وكلمة المرور',
                                  subtitle:
                                      'أنشئ كلمة مرور قوية لحماية حسابك',
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 16),

                                // كلمة المرور
                                AppPasswordField(
                                  controller: notifier.passwordController,
                                  label: Tk.registerPasswordLabel.tr,
                                  hint: Tk.registerPasswordHint.tr,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (val) {
                                    setState(() {
                                      _currentPassword = val;
                                    });
                                  },
                                  validator: (v) => AppValidators.password(
                                    v,
                                    requiredMsg: Tk.registerPasswordRequired.tr,
                                    shortMsg: Tk.registerPasswordShort.tr,
                                  ),
                                ),

                                // مقياس قوة كلمة المرور الذكي
                                if (password.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  _buildStrengthMeter(
                                    context,
                                    strength,
                                    isDark,
                                  ),
                                ],
                                const SizedBox(height: 12),

                                // تأكيد كلمة المرور
                                AppPasswordField(
                                  controller:
                                      notifier.confirmPasswordController,
                                  label: Tk.registerConfirmPasswordLabel.tr,
                                  hint: Tk.registerConfirmPasswordHint.tr,
                                  prefixIcon: Icons.lock_reset_rounded,
                                  textInputAction: TextInputAction.done,
                                  onChanged: (val) {
                                    setState(() {
                                      _currentConfirm = val;
                                    });
                                  },
                                  validator: (v) =>
                                      AppValidators.confirmPassword(
                                    v,
                                    notifier.passwordController.text,
                                    requiredMsg:
                                        Tk.registerConfirmPasswordRequired.tr,
                                    mismatchMsg: Tk.registerPasswordMismatch.tr,
                                  ),
                                ),

                                // مؤشر تطابق كلمتي المرور
                                if (confirm.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  _buildMatchIndicator(
                                    context,
                                    isMatching,
                                    isDark,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ----------------------------------------------------
                          // الموافقة على الشروط وسياسة الخصوصية
                          // ----------------------------------------------------
                          _buildTermsAgreementTile(
                            context,
                            state,
                            notifier,
                            isDark,
                          ),
                          const SizedBox(height: 20),

                          // زر الإجراء الرئيسي: إنشاء الحساب
                          AppButton(
                            text: state.isLoading
                                ? '...'
                                : Tk.registerSubmit.tr,
                            icon: Icons.arrow_forward_rounded,
                            isLoading: state.isLoading,
                            height: 54,
                            borderRadius: 16,
                            onPressed: state.isLoading
                                ? null
                                : () => notifier.register(key: _formKey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4. رابط تسجيل الدخول للمستخدمين المسجلين
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Tk.registerHaveAccount.tr,
                          style: AppTextTheme.cairo(
                            fontSize: 14,
                            color: context.mutedForeground,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: notifier.goToLogin,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Text(
                              Tk.registerSignIn.tr,
                              style: AppTextTheme.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: context.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 5. زر المتابعة كزائر
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: notifier.continueAsGuest,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.mutedForeground,
                          side: BorderSide(
                            color: (isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight)
                                .withValues(alpha: 0.8),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        icon: Icon(
                          Icons.explore_outlined,
                          size: 18,
                          color: context.primary,
                        ),
                        label: Text(
                          'تصفح المتجر كزائر',
                          style: AppTextTheme.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: context.foreground,
                          ),
                        ),
                      ),
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

  /// محدد الجنس (ذكر / أنثى حصراً) وفق معايير رَوْنَقُك الفاخرة
  Widget _buildGenderSelector(
    BuildContext context,
    RegisterFormState state,
    RegisterFormNotifier notifier,
    bool isDark,
  ) {
    return FormField<String>(
      key: ValueKey('gender_field_${state.selectedGender}'),
      initialValue: state.selectedGender,
      validator: (_) {
        if (state.selectedGender == null ||
            state.selectedGender!.trim().isEmpty) {
          return 'يرجى تحديد الجنس (ذكر أو أنثى)';
        }
        return null;
      },
      builder: (field) {
        final hasError = field.hasError;
        final selected = state.selectedGender;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.wc_rounded,
                  size: 16,
                  color:
                      hasError ? context.destructive : context.mutedForeground,
                ),
                const SizedBox(width: 6),
                Text(
                  'الجنس',
                  style: AppTextTheme.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: hasError ? context.destructive : context.foreground,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: AppTextTheme.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.destructive,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // خيار ذكر
                Expanded(
                  child: _buildGenderOptionTile(
                    context,
                    label: 'ذكر',
                    subtitle: 'Male',
                    icon: Icons.male_rounded,
                    isSelected: selected == 'male' || selected == 'ذكر',
                    isDark: isDark,
                    hasError: hasError,
                    onTap: () {
                      notifier.selectGender('male');
                      field.didChange('male');
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // خيار أنثى
                Expanded(
                  child: _buildGenderOptionTile(
                    context,
                    label: 'أنثى',
                    subtitle: 'Female',
                    icon: Icons.female_rounded,
                    isSelected: selected == 'female' || selected == 'أنثى',
                    isDark: isDark,
                    hasError: hasError,
                    onTap: () {
                      notifier.selectGender('female');
                      field.didChange('female');
                    },
                  ),
                ),
              ],
            ),
            if (hasError) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 13,
                      color: context.destructive,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      field.errorText ?? 'يرجى تحديد الجنس (ذكر أو أنثى)',
                      style: AppTextTheme.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: context.destructive,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildGenderOptionTile(
    BuildContext context, {
    required String label,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required bool hasError,
    required VoidCallback onTap,
  }) {
    final activeColor = context.primary;
    final borderColor = isSelected
        ? activeColor
        : (hasError
            ? context.destructive.withValues(alpha: 0.7)
            : (isDark ? AppColors.borderDark : AppColors.borderLight));

    final bgColor = isSelected
        ? activeColor.withValues(alpha: isDark ? 0.22 : 0.08)
        : (isDark
            ? Colors.white.withValues(alpha: 0.03)
            : context.muted.withValues(alpha: 0.25));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.6 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: isDark ? 0.35 : 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withValues(alpha: isDark ? 0.3 : 0.15)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: isSelected
                      ? activeColor.withValues(alpha: 0.4)
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: 0.8,
                ),
              ),
              child: Icon(
                icon,
                size: 19,
                color: isSelected ? activeColor : context.mutedForeground,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTextTheme.cairo(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? activeColor : context.foreground,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextTheme.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? activeColor.withValues(alpha: 0.8)
                          : context.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 12,
                  color: context.primaryForeground,
                ),
              ),
          ],
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

  /// مؤشر تطابق كلمتي المرور اللحظي
  Widget _buildMatchIndicator(
    BuildContext context,
    bool isMatching,
    bool isDark,
  ) {
    final matchColor = isMatching
        ? (isDark ? AppColors.successDark : AppColors.success)
        : AppColors.error;
    final matchBg = matchColor.withValues(alpha: isDark ? 0.16 : 0.08);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: matchBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: matchColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isMatching
                ? Icons.check_circle_rounded
                : Icons.info_outline_rounded,
            size: 16,
            color: matchColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isMatching
                  ? 'كلمتا المرور متطابقتان تماماً'
                  : Tk.registerPasswordMismatch.tr,
              style: AppTextTheme.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: matchColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// بطاقة الموافقة على الشروط وسياسة الخصوصية
  Widget _buildTermsAgreementTile(
    BuildContext context,
    RegisterFormState state,
    RegisterFormNotifier notifier,
    bool isDark,
  ) {
    final isAgreed = state.isAgree;
    final activeColor = context.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => notifier.toggleAgreement(!isAgreed),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isAgreed
                ? activeColor.withValues(alpha: isDark ? 0.12 : 0.04)
                : (isDark ? const Color(0xFF1A0D18) : const Color(0xFFFAF7F9)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isAgreed
                  ? activeColor.withValues(alpha: isDark ? 0.5 : 0.4)
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: 1.2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: isAgreed
                      ? activeColor
                      : (isDark ? const Color(0xFF140A13) : Colors.white),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isAgreed
                        ? activeColor
                        : (isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight),
                    width: 1.6,
                  ),
                  boxShadow: isAgreed
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(
                              alpha: isDark ? 0.45 : 0.25,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: isAgreed
                    ? Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: context.primaryForeground,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Tk.registerTermsText.tr,
                      style: AppTextTheme.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: context.mutedForeground,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        InkWell(
                          onTap: () => _openLegalPage(AppEnv.termsUrl),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              Tk.registerTermsLink.tr,
                              style: AppTextTheme.cairo(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: activeColor,
                              ).copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: activeColor,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => _openLegalPage(AppEnv.privacyPolicyUrl),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              Tk.registerPrivacyLink.tr,
                              style: AppTextTheme.cairo(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: activeColor,
                              ).copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: activeColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
