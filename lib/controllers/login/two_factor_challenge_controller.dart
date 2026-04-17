import 'package:get/get.dart';
import 'package:rwnaqk/controllers/login/login_service.dart';
import 'package:rwnaqk/core/routes/app_route_args.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/core/utils/app_notifier.dart';

class TwoFactorChallengeController extends GetxController {
  TwoFactorChallengeController(this._service);

  final LoginService _service;

  final isLoading = false.obs;
  final showRecoveryInput = false.obs;
  final code = ''.obs;
  final recoveryCode = ''.obs;

  String loginEmail = '';
  String loginPassword = '';

  bool get canSubmit {
    if (showRecoveryInput.value) {
      return recoveryCode.value.trim().isNotEmpty;
    }

    return code.value.trim().length == 6;
  }

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is Map) {
      loginEmail = (args[AppRouteArgs.loginEmail] ?? '').toString().trim();
      loginPassword = (args[AppRouteArgs.loginPassword] ?? '').toString();
    }
  }

  void toggleMode() {
    if (isLoading.value) {
      return;
    }

    showRecoveryInput.value = !showRecoveryInput.value;
    code.value = '';
    recoveryCode.value = '';
  }

  void setCode(String value) {
    code.value = value.trim();
  }

  void setRecoveryCode(String value) {
    recoveryCode.value = value.trim();
  }

  Future<void> submit() async {
    if (isLoading.value || !canSubmit) {
      return;
    }

    if (loginEmail.isEmpty || loginPassword.isEmpty) {
      AppNotifier.error(Tk.loginInvalidCredentials);
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    isLoading.value = true;

    try {
      final result = await _service.login(
        email: loginEmail,
        password: loginPassword,
        code: showRecoveryInput.value ? null : code.value,
        recoveryCode: showRecoveryInput.value ? recoveryCode.value : null,
      );

      if (result.requiresTwoFactor) {
        AppNotifier.error(Tk.loginTwoFactorRequired);
        return;
      }

      if (result.requiresEmailVerification) {
        AppNotifier.success(Tk.loginVerifyEmailHint);
        Get.offAllNamed(
          AppRoutes.emailVerify,
          arguments: <String, dynamic>{'email': loginEmail},
        );
        return;
      }

      AppNotifier.success(Tk.loginSuccess);
      Get.offAllNamed(AppRoutes.main);
    } catch (error) {
      AppNotifier.errorFrom(error);
    } finally {
      isLoading.value = false;
    }
  }
}
