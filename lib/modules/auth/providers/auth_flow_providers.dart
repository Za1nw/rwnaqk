import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
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
    this.obscurePassword = true,
    this.errorMessage,
  });

  final String email;
  final String password;
  final bool isLoading;
  final bool obscurePassword;
  final String? errorMessage;

  LoginFormState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    bool? obscurePassword,
    String? errorMessage,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
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

      AppNotifier.success(Tk.loginSuccess);
      AppNav.offAllNamed(AppRoutes.main);
    } catch (error) {
      AppNotifier.errorFrom(error);
      state = state.copyWith(errorMessage: error.toString());
    } finally {
      state = state.copyWith(isLoading: false);
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
    this.isLoading = false,
    this.isAgree = false,
    this.obscurePassword = true,
    this.obscureConfirm = true,
    this.errorMessage,
  });

  final List<String> governorates;
  final String? selectedGovernorate;
  final bool isLoading;
  final bool isAgree;
  final bool obscurePassword;
  final bool obscureConfirm;
  final String? errorMessage;

  RegisterFormState copyWith({
    List<String>? governorates,
    String? selectedGovernorate,
    bool? isLoading,
    bool? isAgree,
    bool? obscurePassword,
    bool? obscureConfirm,
    String? errorMessage,
  }) {
    return RegisterFormState(
      governorates: governorates ?? this.governorates,
      selectedGovernorate: selectedGovernorate ?? this.selectedGovernorate,
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
  final formKey = GlobalKey<FormState>();
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

    // Load initial governorates
    _loadGovernorates();
    return const RegisterFormState();
  }

  Future<void> _loadGovernorates() async {
    try {
      final registerService = ref.read(registerServiceProvider);
      await registerService.loadGovernorates();
      final list = List<String>.from(registerService.governorates);
      final defaultGov = registerService.defaultGovernorate();
      state = state.copyWith(
        governorates: list,
        selectedGovernorate: defaultGov,
      );
    } catch (_) {}
  }

  void selectGovernorate(String? val) {
    state = state.copyWith(selectedGovernorate: val);
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

  Future<void> register() async {
    final isValid = formKey.currentState?.validate() ?? false;
    final canProceed = ref.read(registerServiceProvider).canRegister(
          isFormValid: isValid,
          governorate: state.selectedGovernorate,
          password: passwordController.text,
          passwordConfirmation: confirmPasswordController.text,
          agreed: state.isAgree,
        );

    if (!canProceed || state.isLoading) {
      if (!state.isAgree) {
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
        country: registerService.defaultCountryName(),
        governorate: state.selectedGovernorate ?? '',
        password: passwordController.text,
        passwordConfirmation: confirmPasswordController.text,
        termsAccepted: state.isAgree,
        privacyPolicyAccepted: state.isAgree,
      );

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
      state = state.copyWith(errorMessage: error.toString());
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
    state = state.copyWith(otp: code);
    if (!ref.read(forgotPasswordServiceProvider).isValidOtp(code)) {
      AppNotifier.warning(Tk.fpVerifyInvalid);
      return;
    }

    AppNav.toNamed(
      AppRoutes.reset,
      arguments: <String, dynamic>{
        AppRouteArgs.target: state.target,
        'code': code,
      },
    );
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
  });

  final bool isLoading;
  final bool showRecoveryInput;
  final String code;
  final String recoveryCode;

  bool get canSubmit =>
      showRecoveryInput ? recoveryCode.trim().isNotEmpty : code.trim().length == 6;

  TwoFactorChallengeState copyWith({
    bool? isLoading,
    bool? showRecoveryInput,
    String? code,
    String? recoveryCode,
  }) {
    return TwoFactorChallengeState(
      isLoading: isLoading ?? this.isLoading,
      showRecoveryInput: showRecoveryInput ?? this.showRecoveryInput,
      code: code ?? this.code,
      recoveryCode: recoveryCode ?? this.recoveryCode,
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
    );
  }

  void setCode(String val) {
    state = state.copyWith(code: val.trim());
  }

  void setRecoveryCode(String val) {
    state = state.copyWith(recoveryCode: val.trim());
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

    state = state.copyWith(isLoading: true);
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

      AppNotifier.success(Tk.loginSuccess);
      AppNav.offAllNamed(AppRoutes.main);
    } catch (error) {
      AppNotifier.errorFrom(error);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
