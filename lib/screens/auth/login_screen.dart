import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';

import '../../controllers/login/login_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/app_password_field.dart';
import '../../widgets/auth/auth_form_page_layout.dart';
import '../../widgets/auth_blob_background.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: AuthBlobBackground(
        child: SafeArea(
          child: AuthFormPageLayout(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 42),
                Text(
                  Tk.loginTitle.tr,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: context.foreground,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Tk.loginSubtitle.tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.mutedForeground,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color:
                        context.card.withOpacity(context.isDark ? 0.82 : 0.92),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white
                            .withOpacity(context.isDark ? 0.06 : 0.55),
                        offset: const Offset(-8, -8),
                        blurRadius: 20,
                      ),
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(context.isDark ? 0.35 : 0.14),
                        offset: const Offset(12, 12),
                        blurRadius: 26,
                      ),
                    ],
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white
                            .withOpacity(context.isDark ? 0.05 : 0.14),
                        width: 1,
                      ),
                    ),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        children: [
                          AppInputField(
                            controller: controller.emailController,
                            label: Tk.loginEmailLabel.tr,
                            hint: Tk.loginEmailHint.tr,
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              final value = (v ?? '').trim();
                              if (value.isEmpty)
                                return Tk.loginEmailRequired.tr;
                              if (!GetUtils.isEmail(value))
                                return Tk.loginEmailInvalid.tr;
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          AppPasswordField(
                            controller: controller.passwordController,
                            label: Tk.loginPasswordLabel.tr,
                            hint: Tk.loginPasswordHint.tr,
                            prefixIcon: Icons.lock_outline_rounded,
                            validator: (v) {
                              final value = (v ?? '');
                              if (value.isEmpty)
                                return Tk.loginPasswordRequired.tr;
                              if (value.length < 6)
                                return Tk.loginPasswordShort.tr;
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: TextButton(
                              onPressed: controller.goToForgotPassword,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                splashFactory: NoSplash.splashFactory,
                              ),
                              child: Text(
                                Tk.loginForgot.tr,
                                style: TextStyle(
                                  color: context.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          AppButton(
                            text: Tk.loginSignIn.tr,
                            icon: Icons.login_rounded,
                            onPressed: controller.login,
                            height: 54,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
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
                    const SizedBox(width: 10),
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Tk.loginNoAccount.tr,
                      style: TextStyle(color: context.mutedForeground),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: controller.goToRegister,
                      child: Text(
                        Tk.loginCreateAccount.tr,
                        style: TextStyle(
                          color: context.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}