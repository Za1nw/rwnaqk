import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_validators.dart';

import 'package:rwnaqk_frontend/modules/auth/controllers/login_controller.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/widgets/app_button.dart';
import 'package:rwnaqk_frontend/core/widgets/app_input_field.dart';
import 'package:rwnaqk_frontend/core/widgets/app_password_field.dart';
import 'package:rwnaqk_frontend/modules/auth/widgets/auth_form_page_layout.dart';
import 'package:rwnaqk_frontend/modules/auth/widgets/auth_blob_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    if (Get.isRegistered<LoginController>()) {
      Get.find<LoginController>().formKey = _formKey;
    }
  }

  LoginController get controller => Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    final cardShadows = isDark
        ? <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppColors.burgundy.withValues(alpha: 0.12),
              blurRadius: 32,
              offset: const Offset(0, 4),
            ),
          ]
        : <BoxShadow>[
            BoxShadow(
              color: context.shadow.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ];

    return Scaffold(
      backgroundColor: context.background,
      body: AuthBlobBackground(
        child: SafeArea(
          child: AuthFormPageLayout(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 38),
                Text(
                  Tk.loginTitle.tr,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: AppTextTheme.fontFamily,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: context.foreground,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  Tk.loginSubtitle.tr,
                  style: TextStyle(
                    fontFamily: AppTextTheme.fontFamily,
                    fontSize: 14,
                    color: context.mutedForeground,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 22,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark.withValues(alpha: 0.94)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark.withValues(alpha: 0.6)
                          : AppColors.borderLight,
                      width: 1,
                    ),
                    boxShadow: cardShadows,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppInputField(
                          controller: controller.emailController,
                          label: Tk.loginEmailLabel.tr,
                          hint: Tk.loginEmailHint.tr,
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: AppValidators.email,
                        ),
                        const SizedBox(height: 14),
                        AppPasswordField(
                          controller: controller.passwordController,
                          label: Tk.loginPasswordLabel.tr,
                          hint: Tk.loginPasswordHint.tr,
                          prefixIcon: Icons.lock_outline_rounded,
                          textInputAction: TextInputAction.done,
                          validator: AppValidators.password,
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton(
                            onPressed: controller.goToForgotPassword,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                                vertical: 6,
                              ),
                              splashFactory: NoSplash.splashFactory,
                            ),
                            child: Text(
                              Tk.loginForgot.tr,
                              style: TextStyle(
                                fontFamily: AppTextTheme.fontFamily,
                                color: context.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(() {
                          return AppButton(
                            text: controller.isLoading.value
                                ? '...'
                                : Tk.loginSignIn.tr,
                            icon: Icons.login_rounded,
                            isLoading: controller.isLoading.value,
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.login,
                            height: 52,
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Google',
                        icon: Icons.g_mobiledata,
                        onPressed: controller.loginWithGoogle,
                        outlined: true,
                        height: 48,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        text: 'Apple',
                        icon: Icons.apple,
                        onPressed: controller.loginWithApple,
                        outlined: true,
                        height: 48,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AppButton(
                  text: 'Facebook',
                  icon: Icons.facebook,
                  onPressed: controller.loginWithFacebook,
                  outlined: true,
                  height: 48,
                ),
                const SizedBox(height: 14),

                // زر تجاوز تسجيل الدخول للدخول في وضع التصميم كزائر
                OutlinedButton.icon(
                  onPressed: controller.continueAsGuest,
                  icon: Icon(
                    Icons.explore_outlined,
                    size: 19,
                    color: context.primary,
                  ),
                  label: Text(
                    'تخطي والدخول كزائر (وضع التصميم)',
                    style: TextStyle(
                      fontFamily: AppTextTheme.fontFamily,
                      color: context.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: BorderSide(
                      color: context.primary.withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Tk.loginNoAccount.tr,
                      style: TextStyle(
                        fontFamily: AppTextTheme.fontFamily,
                        color: context.mutedForeground,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: controller.goToRegister,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: Text(
                          Tk.loginCreateAccount.tr,
                          style: TextStyle(
                            fontFamily: AppTextTheme.fontFamily,
                            color: context.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
