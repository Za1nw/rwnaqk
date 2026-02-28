import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

import '../../controllers/register_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/app_password_field.dart';
import '../../widgets/app_select_field.dart';
import '../../widgets/auth/auth_form_page_layout.dart';
import '../../widgets/auth_blob_background.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

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
                  'register.title'.tr,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: context.foreground,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'register.subtitle'.tr,
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
                        context.card.withOpacity(context.isDark ? 0.92 : 0.96),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: context.border
                          .withOpacity(context.isDark ? 0.45 : 0.70),
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
                                label: 'register.first_name.label'.tr,
                                hint: 'register.first_name.hint'.tr,
                                prefixIcon: Icons.person_outline,
                                validator: (v) {
                                  final value = (v ?? '').trim();
                                  if (value.isEmpty)
                                    return 'register.first_name.required'.tr;
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppInputField(
                                controller: controller.lastNameController,
                                label: 'register.last_name.label'.tr,
                                hint: 'register.last_name.hint'.tr,
                                prefixIcon: Icons.badge_outlined,
                                validator: (v) {
                                  final value = (v ?? '').trim();
                                  if (value.isEmpty)
                                    return 'register.last_name.required'.tr;
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        AppInputField(
                          controller: controller.phoneController,
                          label: 'register.phone.label'.tr,
                          hint: 'register.phone.hint'.tr,
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (value.isEmpty)
                              return 'register.phone.required'.tr;
                            if (value.length < 8)
                              return 'register.phone.invalid'.tr;
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        AppInputField(
                          controller: controller.emailController,
                          label: 'register.email.label'.tr,
                          hint: 'register.email.hint'.tr,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (value.isEmpty)
                              return 'register.email.required'.tr;
                            if (!GetUtils.isEmail(value))
                              return 'register.email.invalid'.tr;
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        Obx(() {
                          return AppSelectField<String>(
                            label: 'register.governorate.label'.tr,
                            hint: 'register.governorate.hint'.tr,
                            items: controller.governorates,
                            value: controller.governorate.value,
                            prefixIcon: Icons.location_on_outlined,
                            itemLabel: (e) => e,
                            onChanged: (v) => controller.governorate.value = v,
                            validator: (v) => v == null
                                ? 'register.governorate.required'.tr
                                : null,
                          );
                        }),
                        const SizedBox(height: 14),
                        AppPasswordField(
                          controller: controller.passwordController,
                          label: 'register.password.label'.tr,
                          hint: 'register.password.hint'.tr,
                          prefixIcon: Icons.lock_outline_rounded,
                          textInputAction: TextInputAction.done,
                          validator: (v) {
                            final value = (v ?? '');
                            if (value.isEmpty)
                              return 'register.password.required'.tr;
                            if (value.length < 6)
                              return 'register.password.short'.tr;
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
                                            context.isDark ? 0.55 : 0.75),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: context.shadow.withOpacity(
                                              context.isDark ? 0.25 : 0.12),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: controller.agreed.value
                                        ? Icon(Icons.check,
                                            size: 16, color: context.primary)
                                        : const SizedBox.shrink(),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'register.terms.text'.tr,
                                      style: TextStyle(
                                        color: context.mutedForeground,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 14),
                        AppButton(
                          text: 'register.submit'.tr,
                          icon: Icons.person_add_alt_1_rounded,
                          onPressed: controller.register,
                          height: 54,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'register.have_account'.tr,
                      style: TextStyle(color: context.mutedForeground),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: controller.goToLogin,
                      child: Text(
                        'register.sign_in'.tr,
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
