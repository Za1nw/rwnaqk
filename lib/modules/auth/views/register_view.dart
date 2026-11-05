import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/constants/app_env.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_validators.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:rwnaqk_frontend/modules/auth/controllers/register_controller.dart';
import 'package:rwnaqk_frontend/core/widgets/app_button.dart';
import 'package:rwnaqk_frontend/core/widgets/app_input_field.dart';
import 'package:rwnaqk_frontend/core/widgets/app_password_field.dart';
import 'package:rwnaqk_frontend/core/widgets/app_select_field.dart';
import 'package:rwnaqk_frontend/modules/auth/widgets/auth_form_page_layout.dart';
import 'package:rwnaqk_frontend/modules/auth/widgets/auth_blob_background.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

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
      Get.snackbar(Tk.commonError.tr, Tk.commonUnexpectedError.tr);
    }
  }

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

                // العنوان الرئيسي
                Text(
                  Tk.registerTitle.tr,
                  style: TextStyle(
                    fontFamily: AppTextTheme.fontFamily,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: context.foreground,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),

                // العنوان الفرعي
                Text(
                  Tk.registerSubtitle.tr,
                  style: TextStyle(
                    fontFamily: AppTextTheme.fontFamily,
                    fontSize: 14,
                    color: context.mutedForeground,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // بطاقة نموذج إنشاء الحساب
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
                    key: controller.formKey,
                    child: Column(
                      children: [
                        // الاسم واللقب في سطر واحد متناسق
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AppInputField(
                                controller: controller.firstNameController,
                                label: Tk.registerFirstNameLabel.tr,
                                hint: Tk.registerFirstNameHint.tr,
                                prefixIcon: Icons.person_outline_rounded,
                                validator: (v) => AppValidators.required(
                                  v,
                                  Tk.registerFirstNameRequired.tr,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppInputField(
                                controller: controller.lastNameController,
                                label: Tk.registerLastNameLabel.tr,
                                hint: Tk.registerLastNameHint.tr,
                                prefixIcon: Icons.badge_outlined,
                                validator: (v) => AppValidators.required(
                                  v,
                                  Tk.registerLastNameRequired.tr,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // حقل رقم الهاتف
                        AppInputField(
                          controller: controller.phoneController,
                          label: Tk.registerPhoneLabel.tr,
                          hint: Tk.registerPhoneHint.tr,
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: AppValidators.phone,
                        ),
                        const SizedBox(height: 14),

                        // حقل البريد الإلكتروني
                        AppInputField(
                          controller: controller.emailController,
                          label: Tk.registerEmailLabel.tr,
                          hint: Tk.registerEmailHint.tr,
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => AppValidators.email(
                            v,
                            requiredMsg: Tk.registerEmailRequired.tr,
                            invalidMsg: Tk.registerEmailInvalid.tr,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // حقل اختيار المحافظة
                        Obx(() {
                          final governorates = controller.governorates;
                          final governorateItems = governorates.toList(
                            growable: false,
                          );

                          return AppSelectField<String>(
                            label: Tk.registerGovernorateLabel.tr,
                            hint: Tk.registerGovernorateHint.tr,
                            items: governorateItems,
                            value: controller.governorate.value,
                            prefixIcon: Icons.location_on_outlined,
                            itemLabel: (e) => e,
                            onChanged: (v) => controller.governorate.value = v,
                            validator: (v) => AppValidators.requiredSelection(
                              v,
                              Tk.registerGovernorateRequired.tr,
                            ),
                          );
                        }),
                        const SizedBox(height: 14),

                        // حقل كلمة المرور
                        AppPasswordField(
                          controller: controller.passwordController,
                          label: Tk.registerPasswordLabel.tr,
                          hint: Tk.registerPasswordHint.tr,
                          prefixIcon: Icons.lock_outline_rounded,
                          textInputAction: TextInputAction.next,
                          validator: (v) => AppValidators.password(
                            v,
                            requiredMsg: Tk.registerPasswordRequired.tr,
                            shortMsg: Tk.registerPasswordShort.tr,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // حقل تأكيد كلمة المرور
                        AppPasswordField(
                          controller: controller.confirmPasswordController,
                          label: Tk.registerConfirmPasswordLabel.tr,
                          hint: Tk.registerConfirmPasswordHint.tr,
                          prefixIcon: Icons.lock_reset_rounded,
                          textInputAction: TextInputAction.done,
                          validator: (v) => AppValidators.confirmPassword(
                            v,
                            controller.passwordController.text,
                            requiredMsg: Tk.registerConfirmPasswordRequired.tr,
                            mismatchMsg: Tk.registerPasswordMismatch.tr,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // الموافقة على الشروط وسياسة الخصوصية
                        Obx(() {
                          final isAgreed = controller.agreed.value;

                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: controller.toggleAgreed,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 2,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    width: 22,
                                    height: 22,
                                    margin: const EdgeInsets.only(top: 2),
                                    decoration: BoxDecoration(
                                      color: isAgreed
                                          ? context.primary
                                          : (isDark
                                                ? const Color(0xFF190C18)
                                                : Colors.white),
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                        color: isAgreed
                                            ? context.primary
                                            : (isDark
                                                  ? AppColors.borderDark
                                                  : AppColors.borderLight),
                                        width: 1.5,
                                      ),
                                      boxShadow: isAgreed && isDark
                                          ? [
                                              BoxShadow(
                                                color: context.primary
                                                    .withValues(alpha: 0.35),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          Tk.registerTermsText.tr,
                                          style: TextStyle(
                                            fontFamily: AppTextTheme.fontFamily,
                                            color: context.mutedForeground,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 4,
                                          children: [
                                            GestureDetector(
                                              onTap: () => _openLegalPage(
                                                AppEnv.termsUrl,
                                              ),
                                              child: Text(
                                                Tk.registerTermsLink.tr,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppTextTheme.fontFamily,
                                                  color: context.primary,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12.5,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor:
                                                      context.primary,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => _openLegalPage(
                                                AppEnv.privacyPolicyUrl,
                                              ),
                                              child: Text(
                                                Tk.registerPrivacyLink.tr,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppTextTheme.fontFamily,
                                                  color: context.primary,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12.5,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor:
                                                      context.primary,
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
                          );
                        }),
                        const SizedBox(height: 20),

                        // زر إنشاء الحساب
                        Obx(() {
                          return AppButton(
                            text: controller.isLoading.value
                                ? '...'
                                : Tk.registerSubmit.tr,
                            icon: Icons.person_add_alt_1_rounded,
                            isLoading: controller.isLoading.value,
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.register,
                            height: 52,
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // رابط تسجيل الدخول
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Tk.registerHaveAccount.tr,
                      style: TextStyle(
                        fontFamily: AppTextTheme.fontFamily,
                        color: context.mutedForeground,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: controller.goToLogin,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: Text(
                          Tk.registerSignIn.tr,
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
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: controller.continueAsGuest,
                    icon: Icon(
                      Icons.explore_outlined,
                      size: 18,
                      color: context.primary,
                    ),
                    label: Text(
                      'تخطي والمتابعة كزائر (وضع التصميم)',
                      style: TextStyle(
                        fontFamily: AppTextTheme.fontFamily,
                        color: context.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
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
