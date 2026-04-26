import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/register/register_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/app_password_field.dart';
import '../../widgets/app_select_field.dart';
import '../../widgets/auth/auth_form_page_layout.dart';
import '../../widgets/auth_blob_background.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  static const _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.8.124:8000',
  );

  static String get _resolvedApiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _apiBaseUrlOverride;
    }

    if (kIsWeb) {
      return Uri.base.origin;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://192.168.8.124:8000';
      case TargetPlatform.iOS:
        return 'http://127.0.0.1:8000';
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
        return 'http://127.0.0.1:8000';
      case TargetPlatform.fuchsia:
        return 'http://127.0.0.1:8000';
    }
  }

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
    final cardShadows = context.isDark
        ? <BoxShadow>[
            BoxShadow(
              color: context.shadow.withOpacity(0.22),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ]
        : <BoxShadow>[
            BoxShadow(
              color: context.background.withOpacity(0.85),
              blurRadius: 14,
              offset: const Offset(-6, -6),
            ),
            BoxShadow(
              color: context.shadow.withOpacity(0.28),
              blurRadius: 18,
              offset: const Offset(10, 10),
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
                const SizedBox(height: 42),
                Text(
                  Tk.registerTitle.tr,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: context.foreground,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Tk.registerSubtitle.tr,
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
                    color: context.card.withOpacity(
                      context.isDark ? 0.92 : 0.96,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: context.border.withOpacity(
                        context.isDark ? 0.45 : 0.70,
                      ),
                      width: 1,
                    ),
                    boxShadow: cardShadows,
                  ),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AppInputField(
                                controller: controller.firstNameController,
                                label: Tk.registerFirstNameLabel.tr,
                                hint: Tk.registerFirstNameHint.tr,
                                prefixIcon: Icons.person_outline,
                                validator: (v) {
                                  final value = (v ?? '').trim();
                                  if (value.isEmpty)
                                    return Tk.registerFirstNameRequired.tr;
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppInputField(
                                controller: controller.lastNameController,
                                label: Tk.registerLastNameLabel.tr,
                                hint: Tk.registerLastNameHint.tr,
                                prefixIcon: Icons.badge_outlined,
                                validator: (v) {
                                  final value = (v ?? '').trim();
                                  if (value.isEmpty)
                                    return Tk.registerLastNameRequired.tr;
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        AppInputField(
                          controller: controller.phoneController,
                          label: Tk.registerPhoneLabel.tr,
                          hint: Tk.registerPhoneHint.tr,
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (value.isEmpty)
                              return Tk.registerPhoneRequired.tr;
                            if (value.length < 8)
                              return Tk.registerPhoneInvalid.tr;
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        AppInputField(
                          controller: controller.emailController,
                          label: Tk.registerEmailLabel.tr,
                          hint: Tk.registerEmailHint.tr,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (value.isEmpty)
                              return Tk.registerEmailRequired.tr;
                            if (!GetUtils.isEmail(value))
                              return Tk.registerEmailInvalid.tr;
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        Obx(() {
                          final governorates = controller.governorates;
                          final governorateItems = governorates.toList(
                            growable: false,
                          );
                          governorates.length;

                          return AppSelectField<String>(
                            label: Tk.registerGovernorateLabel.tr,
                            hint: Tk.registerGovernorateHint.tr,
                            items: governorateItems,
                            value: controller.governorate.value,
                            prefixIcon: Icons.location_on_outlined,
                            itemLabel: (e) => e,
                            onChanged: (v) => controller.governorate.value = v,
                            validator: (v) => v == null
                                ? Tk.registerGovernorateRequired.tr
                                : null,
                          );
                        }),
                        const SizedBox(height: 14),
                        AppPasswordField(
                          controller: controller.passwordController,
                          label: Tk.registerPasswordLabel.tr,
                          hint: Tk.registerPasswordHint.tr,
                          prefixIcon: Icons.lock_outline_rounded,
                          textInputAction: TextInputAction.done,
                          validator: (v) {
                            final value = (v ?? '');
                            if (value.isEmpty)
                              return Tk.registerPasswordRequired.tr;
                            if (value.length < 6)
                              return Tk.registerPasswordShort.tr;
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        AppPasswordField(
                          controller: controller.confirmPasswordController,
                          label: Tk.registerConfirmPasswordLabel.tr,
                          hint: Tk.registerConfirmPasswordHint.tr,
                          prefixIcon: Icons.lock_reset,
                          textInputAction: TextInputAction.done,
                          validator: (v) {
                            final value = (v ?? '');
                            if (value.isEmpty) {
                              return Tk.registerConfirmPasswordRequired.tr;
                            }
                            if (value != controller.passwordController.text) {
                              return Tk.registerPasswordMismatch.tr;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        // ملاحظة: Obx هنا مخصص فقط لحالة الموافقة لتقليل إعادة البناء.
                        Obx(() {
                          return InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: controller.toggleAgreed,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: context.input,
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                        color: context.border.withOpacity(
                                          context.isDark ? 0.55 : 0.75,
                                        ),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: context.shadow.withOpacity(
                                            context.isDark ? 0.25 : 0.12,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: controller.agreed.value
                                        ? Icon(
                                            Icons.check,
                                            size: 16,
                                            color: context.primary,
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          Tk.registerTermsText.tr,
                                          style: TextStyle(
                                            color: context.mutedForeground,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 10,
                                          children: [
                                            GestureDetector(
                                              onTap: () =>
                                                  _openLegalPage('/terms'),
                                              child: Text(
                                                Tk.registerTermsLink.tr,
                                                style: TextStyle(
                                                  color: context.primary,
                                                  fontWeight: FontWeight.w700,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => _openLegalPage(
                                                '/privacy-policy',
                                              ),
                                              child: Text(
                                                Tk.registerPrivacyLink.tr,
                                                style: TextStyle(
                                                  color: context.primary,
                                                  fontWeight: FontWeight.w700,
                                                  decoration:
                                                      TextDecoration.underline,
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
                        const SizedBox(height: 14),
                        Obx(() {
                          return AppButton(
                            text: controller.isLoading.value
                                ? '...'
                                : Tk.registerSubmit.tr,
                            icon: Icons.person_add_alt_1_rounded,
                            onPressed: controller.isLoading.value
                                ? () {}
                                : controller.register,
                            height: 54,
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Tk.registerHaveAccount.tr,
                      style: TextStyle(color: context.mutedForeground),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: controller.goToLogin,
                      child: Text(
                        Tk.registerSignIn.tr,
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
