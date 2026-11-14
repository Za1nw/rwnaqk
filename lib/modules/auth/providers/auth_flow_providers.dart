import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_env.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/services/auth/biometric_auth_service.dart';
import 'package:rwnaqk_frontend/core/services/geo/geo_lookup_api_service.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/api_error_utils.dart';
import 'package:rwnaqk_frontend/core/utils/app_notifier.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/forgot_password_service.dart';
import 'package:rwnaqk_frontend/modules/auth/providers/auth_providers.dart';
import 'package:rwnaqk_frontend/routes/app_route_args.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

// ==========================================
// 1. LOGIN FLOW
// ==========================================

class LoginFormState {
  const LoginFormState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.isBiometricLoading = false,
    this.obscurePassword = true,
    this.errorMessage,
  });

  final String email;
  final String password;
  final bool isLoading;
  final bool isBiometricLoading;
  final bool obscurePassword;
  final String? errorMessage;

  LoginFormState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    bool? isBiometricLoading,
    bool? obscurePassword,
    String? errorMessage,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      isBiometricLoading: isBiometricLoading ?? this.isBiometricLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      errorMessage: errorMessage,
    );
  }
}

final loginFormProvider =
    NotifierProvider<LoginFormNotifier, LoginFormState>(LoginFormNotifier.new);

class LoginFormNotifier extends Notifier<LoginFormState> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  LoginFormState build() {
    ref.onDispose(() {
      emailController.dispose();
      passwordController.dispose();
    });
    return const LoginFormState();
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void goToForgotPassword() {
    AppNav.toNamed(
      AppRoutes.forgot,
      arguments: <String, dynamic>{
        AppRouteArgs.target: emailController.text.trim(),
      },
    );
  }

  Future<void> login() async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid || state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final email = emailController.text.trim();
      final password = passwordController.text;

      final loginService = ref.read(loginServiceProvider);
      final result = await loginService.login(email: email, password: password);

      if (result.isBanned || result.customer?.isBanned == true) {
        return;
      }

      if (result.requiresTwoFactor) {
        AppNav.toNamed(
          AppRoutes.twoFactorChallenge,
          arguments: <String, dynamic>{
            AppRouteArgs.loginEmail: email,
            AppRouteArgs.loginPassword: password,
            AppRouteArgs.target: email,
          },
        );
        return;
      }

      if (result.requiresEmailVerification) {
        AppNotifier.success(Tk.loginVerifyEmailHint);
        AppNav.offAllNamed(
          AppRoutes.emailVerify,
          arguments: <String, dynamic>{'email': email},
        );
        return;
      }

      if (result.token != null && result.token!.isNotEmpty) {
        final bioService = ref.read(biometricAuthServiceProvider);
        await bioService.saveBiometricSession(
          token: result.token!,
          email: email,
        );
      }

      AppNotifier.success(Tk.loginSuccess);
      AppNav.offAllNamed(AppRoutes.main);
    } catch (error) {
      AppNotifier.errorFrom(error);
      state = state.copyWith(errorMessage: ApiErrorUtils.toMessage(error));
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// تسجيل الدخول الآمن بالبصمة أو كلمة مرور / قفل الهاتف
  Future<void> loginWithBiometrics() async {
    if (state.isLoading || state.isBiometricLoading) return;

    state = state.copyWith(isBiometricLoading: true, errorMessage: null);

    try {
      final bioService = ref.read(biometricAuthServiceProvider);

      // 1. فحص دعم الجهاز للمصادقة الحيوية
      final isAvailable = await bioService.isBiometricsAvailable();
      if (!isAvailable) {
        if (AppEnv.enableMockData) {
          ref.read(authSessionProvider.notifier).enterGuestMode();
          AppNotifier.success('تم تسجيل الدخول السريع (الوضع التجريبي)');
          AppNav.offAllNamed(AppRoutes.main);
          return;
        }
        AppNotifier.warning(
          'خاصية المصادقة بالبصمة أو قفل الهاتف غير مدعومة على هذا الجهاز.',
        );
        return;
      }

      // 2. فحص وجود تسجيل بيومتري مسبق
      final hasRegistration = await bioService.hasSavedBiometricRegistration();
      final credentialId = await bioService.getSavedCredentialId();
      final secret = await bioService.getSavedCredentialSecret();
      final savedEmail = await bioService.getSavedBiometricEmail();

      final inputEmail = emailController.text.trim();
      final inputPassword = passwordController.text;

      // إذا لم يكن هناك تسجيل مسبق ولم يدخل المستخدم بياناته
      if (!hasRegistration && (inputEmail.isEmpty || inputPassword.isEmpty)) {
        if (AppEnv.enableMockData) {
          final authenticated = await bioService.authenticate(
            reason:
                'يرجى تأكيد بصمة الإصبع أو قفل الهاتف لتسجيل الدخول السريع إلى رَوْنَقُك',
          );
          if (!authenticated) return;
          ref.read(authSessionProvider.notifier).enterGuestMode();
          AppNotifier.success('تم تسجيل الدخول بالبصمة بنجاح');
          AppNav.offAllNamed(AppRoutes.main);
          return;
        }

        AppNotifier.info(
          'لم يتم تفعيل تسجيل الدخول بالبصمة على هذا الجهاز بعد. يرجى تسجيل الدخول بحسابك أولاً لتفعيل البصمة من الإعدادات.',
        );
        return;
      }

      // 3. طلب تأكيد البصمة أو رمز قفل الهاتف من نظام التشغيل
      final authenticated = await bioService.authenticate(
        reason:
            'يرجى تأكيد بصمة الإصبع أو قفل الهاتف لتسجيل الدخول السريع إلى رَوْنَقُك',
      );

      if (!authenticated) {
        return;
      }

      // 4. تسجيل الدخول عبر مفتاح المرور والاعتماد البيومتري في الباك إند
      if (credentialId != null && credentialId.isNotEmpty) {
        final authRepo = ref.read(authRepositoryProvider);
        try {
          final result = await authRepo.passkeyLogin(
            credentialId: credentialId,
            secret: secret,
            email: savedEmail ?? (inputEmail.isNotEmpty ? inputEmail : null),
          );

          if (result.token != null && result.token!.isNotEmpty) {
            await bioService.saveBiometricSession(
              token: result.token!,
              email: result.customer?.email ?? savedEmail ?? inputEmail,
            );

            ref.read(authSessionProvider.notifier).startSession(
                  accessToken: result.token!,
                  customerPayload: result.customer,
                );

            AppNotifier.success('أهلاً بك مجدداً، تم تسجيل الدخول بنجاح');
            AppNav.offAllNamed(AppRoutes.main);
            return;
          }
        } catch (e) {
          debugPrint(
              '[LoginFormNotifier] passkeyLogin error, trying fallback token: $e');
        }
      }

      // 5. محاولة احتياطية عبر التوكن المحفوظ مسبقاً
      final savedToken = await bioService.getSavedBiometricToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        final storage = ref.read(authTokenStorageProvider);
        await storage.writeToken(savedToken);
        final authRepo = ref.read(authRepositoryProvider);

        try {
          final customer = await authRepo.me();
          if (customer.isBanned == true) {
            ref
                .read(authSessionProvider.notifier)
                .markAsBanned(customerPayload: customer);
            return;
          }

          ref.read(authSessionProvider.notifier).startSession(
                accessToken: savedToken,
                customerPayload: customer,
              );
          AppNotifier.success('أهلاً بك مجدداً، تم تسجيل الدخول بنجاح');
          AppNav.offAllNamed(AppRoutes.main);
          return;
        } catch (_) {}
      }

      // 6. إذا قام المستخدم بكتابة بيانات الحساب
      if (inputEmail.isNotEmpty && inputPassword.isNotEmpty) {
        await login();
        return;
      }

      AppNotifier.info(
        'لم يتم تفعيل تسجيل الدخول بالبصمة على هذا الجهاز بعد. يرجى تسجيل الدخول بحسابك أولاً لتفعيل البصمة من الإعدادات.',
      );
    } catch (e) {
      debugPrint('[LoginFormNotifier] loginWithBiometrics error: $e');
      AppNotifier.errorFrom(e);
    } finally {
      state = state.copyWith(isBiometricLoading: false);
    }
  }

  void continueAsGuest() {
    ref.read(authSessionProvider.notifier).enterGuestMode();
    AppNav.offAllNamed(AppRoutes.main);
  }

  void goToRegister() {
    AppNav.toNamed(AppRoutes.register);
  }

  void loginWithGoogle() {
    AppNotifier.info(Tk.loginWithGoogle.tr, isKey: false, title: Tk.commonSocial.tr);
  }

  void loginWithApple() {
    AppNotifier.info(Tk.loginWithApple.tr, isKey: false, title: Tk.commonSocial.tr);
  }

  void loginWithFacebook() {
    AppNotifier.info(Tk.loginWithFacebook.tr, isKey: false, title: Tk.commonSocial.tr);
  }
}

// ==========================================
// 2. REGISTER FLOW
// ==========================================

class RegisterFormState {
  const RegisterFormState({
    this.governorates = const [],
    this.selectedGovernorate,
    this.selectedGender,
    this.isLoading = false,
    this.isAgree = false,
    this.obscurePassword = true,
    this.obscureConfirm = true,
    this.errorMessage,
  });

  final List<String> governorates;
  final String? selectedGovernorate;
  final String? selectedGender;
  final bool isLoading;
  final bool isAgree;
  final bool obscurePassword;
  final bool obscureConfirm;
  final String? errorMessage;

  RegisterFormState copyWith({
    List<String>? governorates,
    String? selectedGovernorate,
    String? selectedGender,
    bool? isLoading,
    bool? isAgree,
    bool? obscurePassword,
    bool? obscureConfirm,
    String? errorMessage,
  }) {
    return RegisterFormState(
      governorates: governorates ?? this.governorates,
      selectedGovernorate: selectedGovernorate ?? this.selectedGovernorate,
      selectedGender: selectedGender ?? this.selectedGender,
      isLoading: isLoading ?? this.isLoading,
      isAgree: isAgree ?? this.isAgree,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirm: obscureConfirm ?? this.obscureConfirm,
      errorMessage: errorMessage,
    );
  }
}

final registerFormProvider =
    NotifierProvider<RegisterFormNotifier, RegisterFormState>(
  RegisterFormNotifier.new,
);

class RegisterFormNotifier extends Notifier<RegisterFormState> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  RegisterFormState build() {
    ref.onDispose(() {
      firstNameController.dispose();
      lastNameController.dispose();
      phoneController.dispose();
      emailController.dispose();
      passwordController.dispose();
      confirmPasswordController.dispose();
    });

    final registerService = ref.read(registerServiceProvider);
    final initialGovs = registerService.governorates.isNotEmpty
        ? List<String>.from(registerService.governorates)
        : GeoLookupApiService.cachedGovernorateNamesOrFallback;
    final initialGov = initialGovs.contains('صنعاء')
        ? 'صنعاء'
        : (initialGovs.isNotEmpty ? initialGovs.first : null);

    // مزامنة المحافظات في الخلفية مع الكاش المحلي أو الخادم
    _loadGovernorates();

    return RegisterFormState(
      governorates: initialGovs,
      selectedGovernorate: initialGov,
    );
  }

  Future<void> _loadGovernorates() async {
    try {
      final registerService = ref.read(registerServiceProvider);
      await registerService.loadGovernorates();
      final list = List<String>.from(registerService.governorates);
      if (list.isNotEmpty) {
        state = state.copyWith(
          governorates: list,
          selectedGovernorate:
              state.selectedGovernorate ?? registerService.defaultGovernorate(),
        );
      }
    } catch (_) {}
  }

  void selectGovernorate(String? val) {
    state = state.copyWith(selectedGovernorate: val);
  }

  void selectGender(String? val) {
    state = state.copyWith(selectedGender: val);
  }

  void toggleAgreement(bool? val) {
    state = state.copyWith(isAgree: val ?? false);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void toggleConfirmVisibility() {
    state = state.copyWith(obscureConfirm: !state.obscureConfirm);
  }

  void goToLogin() {
    AppNav.toNamed(AppRoutes.login);
  }

  void continueAsGuest() {
    ref.read(authSessionProvider.notifier).enterGuestMode();
    AppNav.offAllNamed(AppRoutes.main);
  }

  Future<void> register({GlobalKey<FormState>? key}) async {
    final activeKey = key ?? formKey;
    final isValid = activeKey.currentState?.validate() ?? false;
    final canProceed = ref.read(registerServiceProvider).canRegister(
          isFormValid: isValid,
          gender: state.selectedGender,
          governorate: state.selectedGovernorate,
          password: passwordController.text,
          passwordConfirmation: confirmPasswordController.text,
          agreed: state.isAgree,
        );

    if (!canProceed || state.isLoading) {
      if (state.selectedGender == null || state.selectedGender!.isEmpty) {
        AppNotifier.warning('يرجى تحديد الجنس (ذكر أو أنثى) للمتابعة');
      } else if (!state.isAgree) {
        AppNotifier.warning(Tk.registerTermsRequired);
      }
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final registerService = ref.read(registerServiceProvider);
      final result = await registerService.register(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        gender: state.selectedGender,
        country: registerService.defaultCountryName(),
        governorate: state.selectedGovernorate ?? '',
        password: passwordController.text,
        passwordConfirmation: confirmPasswordController.text,
        termsAccepted: state.isAgree,
        privacyPolicyAccepted: state.isAgree,
      );

      if (result.isBanned) {
        return;
      }

      if (result.requiresEmailVerification) {
        AppNotifier.success(Tk.registerVerifyEmailHint);
        AppNav.offAllNamed(
          AppRoutes.emailVerify,
          arguments: <String, dynamic>{'email': emailController.text.trim()},
        );
        return;
      }

      AppNotifier.success(Tk.registerSuccess);
      AppNav.offAllNamed(AppRoutes.main);
    } catch (error) {
      AppNotifier.errorFrom(error);
      state = state.copyWith(errorMessage: ApiErrorUtils.toMessage(error));
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

// ==========================================
// 3. FORGOT PASSWORD FLOW
// ==========================================

class ForgotPasswordFlowState {
  const ForgotPasswordFlowState({
    this.method = RecoveryMethod.email,
    this.target = '',
    this.otp = '',
    this.isLoading = false,
    this.obscurePassword = true,
    this.obscureConfirm = true,
    this.errorMessage,
  });

  final RecoveryMethod method;
  final String target;
  final String otp;
  final bool isLoading;
  final bool obscurePassword;
  final bool obscureConfirm;
  final String? errorMessage;

  ForgotPasswordFlowState copyWith({
    RecoveryMethod? method,
    String? target,
    String? otp,
    bool? isLoading,
    bool? obscurePassword,
    bool? obscureConfirm,
    String? errorMessage,
  }) {
    return ForgotPasswordFlowState(
      method: method ?? this.method,
      target: target ?? this.target,
      otp: otp ?? this.otp,
      isLoading: isLoading ?? this.isLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirm: obscureConfirm ?? this.obscureConfirm,
      errorMessage: errorMessage,
    );
  }
}

final forgotPasswordFlowProvider =
    NotifierProvider<ForgotPasswordFlowNotifier, ForgotPasswordFlowState>(
  ForgotPasswordFlowNotifier.new,
);

class ForgotPasswordFlowNotifier extends Notifier<ForgotPasswordFlowState> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final resetFormKey = GlobalKey<FormState>();

  @override
  ForgotPasswordFlowState build() {
    ref.onDispose(() {
      emailController.dispose();
      passwordController.dispose();
      confirmPasswordController.dispose();
    });
    return const ForgotPasswordFlowState();
  }

  void setMethod(RecoveryMethod method) {
    state = state.copyWith(method: method);
  }

  void setTarget(String target) {
    state = state.copyWith(target: target);
    emailController.text = target;
  }

  void setOtp(String code) {
    state = state.copyWith(otp: code);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void toggleConfirmVisibility() {
    state = state.copyWith(obscureConfirm: !state.obscureConfirm);
  }

  Future<void> sendCode() async {
    final target = emailController.text.trim();
    if (target.isEmpty) {
      AppNotifier.warning(Tk.loginEmailRequired);
      return;
    }

    state = state.copyWith(isLoading: true, target: target);
    try {
      final service = ref.read(forgotPasswordServiceProvider);
      await service.sendPasswordResetLink(email: target);
      AppNotifier.success(Tk.fpVerifySent);
      AppNav.toNamed(
        AppRoutes.otp,
        arguments: <String, dynamic>{
          AppRouteArgs.target: target,
          'method': state.method.name,
        },
      );
    } catch (error) {
      AppNotifier.errorFrom(error);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> verifyOtp(String code) async {
    if (state.isLoading) return;

    if (!ref.read(forgotPasswordServiceProvider).isValidOtp(code)) {
      AppNotifier.warning(Tk.fpVerifyInvalid);
      return;
    }

    state = state.copyWith(isLoading: true, otp: code);
    try {
      final service = ref.read(forgotPasswordServiceProvider);
      await service.verifyPasswordResetCode(
        email: state.target,
        code: code,
      );

      AppNav.toNamed(
        AppRoutes.reset,
        arguments: <String, dynamic>{
          AppRouteArgs.target: state.target,
          'code': code,
        },
      );
    } catch (error) {
      AppNotifier.errorFrom(error);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> resetPassword({required String code}) async {
    final isValid = resetFormKey.currentState?.validate() ?? false;
    final pwd = passwordController.text;
    final confirm = confirmPasswordController.text;

    final canProceed = ref.read(forgotPasswordServiceProvider).canSaveNewPassword(
          isFormValid: isValid,
          password: pwd,
          confirmPassword: confirm,
        );

    if (!canProceed || state.isLoading) return;

    state = state.copyWith(isLoading: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.resetPassword(
        email: state.target,
        token: code,
        password: pwd,
      );
      AppNotifier.success(Tk.fpDone);
      AppNav.offAllNamed(AppRoutes.login);
    } catch (error) {
      AppNotifier.errorFrom(error);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

// ==========================================
// 4. TWO-FACTOR CHALLENGE FLOW
// ==========================================

class TwoFactorChallengeState {
  const TwoFactorChallengeState({
    this.isLoading = false,
    this.showRecoveryInput = false,
    this.code = '',
    this.recoveryCode = '',
    this.hasError = false,
    this.errorTicks = 0,
  });

  final bool isLoading;
  final bool showRecoveryInput;
  final String code;
  final String recoveryCode;
  final bool hasError;
  final int errorTicks;

  bool get canSubmit =>
      showRecoveryInput ? recoveryCode.trim().isNotEmpty : code.trim().length == 6;

  TwoFactorChallengeState copyWith({
    bool? isLoading,
    bool? showRecoveryInput,
    String? code,
    String? recoveryCode,
    bool? hasError,
    int? errorTicks,
  }) {
    return TwoFactorChallengeState(
      isLoading: isLoading ?? this.isLoading,
      showRecoveryInput: showRecoveryInput ?? this.showRecoveryInput,
      code: code ?? this.code,
      recoveryCode: recoveryCode ?? this.recoveryCode,
      hasError: hasError ?? this.hasError,
      errorTicks: errorTicks ?? this.errorTicks,
    );
  }
}

final twoFactorChallengeFlowProvider =
    NotifierProvider<TwoFactorChallengeFlowNotifier, TwoFactorChallengeState>(
  TwoFactorChallengeFlowNotifier.new,
);

class TwoFactorChallengeFlowNotifier
    extends Notifier<TwoFactorChallengeState> {
  @override
  TwoFactorChallengeState build() => const TwoFactorChallengeState();

  void toggleMode() {
    if (state.isLoading) return;
    state = state.copyWith(
      showRecoveryInput: !state.showRecoveryInput,
      code: '',
      recoveryCode: '',
      hasError: false,
    );
  }

  void clearError() {
    if (state.hasError) {
      state = state.copyWith(hasError: false);
    }
  }

  void setCode(String val) {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var normalized = val.trim().replaceAll(' ', '').replaceAll('-', '');
    for (int i = 0; i < arabic.length; i++) {
      normalized = normalized.replaceAll(arabic[i], '$i');
    }
    state = state.copyWith(code: normalized, hasError: false);
  }

  void setRecoveryCode(String val) {
    state = state.copyWith(recoveryCode: val.trim(), hasError: false);
  }

  Future<void> submit({
    required String loginEmail,
    required String loginPassword,
  }) async {
    if (state.isLoading || !state.canSubmit) return;

    if (loginEmail.isEmpty || loginPassword.isEmpty) {
      AppNotifier.error(Tk.loginInvalidCredentials);
      AppNav.offAllNamed(AppRoutes.login);
      return;
    }

    state = state.copyWith(isLoading: true, hasError: false);
    try {
      final loginService = ref.read(loginServiceProvider);
      final result = await loginService.login(
        email: loginEmail,
        password: loginPassword,
        code: state.showRecoveryInput ? null : state.code,
        recoveryCode: state.showRecoveryInput ? state.recoveryCode : null,
      );

      if (result.requiresTwoFactor) {
        AppNotifier.error(Tk.loginTwoFactorRequired);
        state = state.copyWith(
          hasError: true,
          errorTicks: state.errorTicks + 1,
        );
        return;
      }

      if (result.requiresEmailVerification) {
        AppNotifier.success(Tk.loginVerifyEmailHint);
        AppNav.offAllNamed(
          AppRoutes.emailVerify,
          arguments: <String, dynamic>{'email': loginEmail},
        );
        return;
      }

      if (result.token != null && result.token!.isNotEmpty) {
        try {
          final bioService = ref.read(biometricAuthServiceProvider);
          await bioService.saveBiometricSession(
            token: result.token!,
            email: loginEmail,
          );
        } catch (_) {}
      }

      AppNotifier.success(Tk.loginSuccess);
      AppNav.offAllNamed(AppRoutes.main);
    } catch (error) {
      AppNotifier.errorFrom(error);
      state = state.copyWith(
        hasError: true,
        errorTicks: state.errorTicks + 1,
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
