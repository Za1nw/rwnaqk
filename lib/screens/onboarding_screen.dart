import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/app_button.dart';
import '../widgets/app_link_button.dart';
import '../widgets/app_toggles.dart';
import '../widgets/auth_blob_background.dart'; // إذا عندك AuthBlobBackground بنفس الملف السابق

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: AuthBlobBackground(
          // ✅ clay blobs خلفية
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  width: 375,
                  height: 812,
                  child: Container(
                    // ✅ Clay card wrapper للشاشة
                    decoration: BoxDecoration(
                      color: context.background.withOpacity(0.30),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Spacer(flex: 2),

                          // ✅ Clay Logo Container
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.card,
                              boxShadow: [
                                // light shadow (top-left)
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.55),
                                  offset: const Offset(-6, -6),
                                  blurRadius: 18,
                                ),
                                // dark shadow (bottom-right)
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.14),
                                  offset: const Offset(10, 10),
                                  blurRadius: 22,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                // subtle inner highlight ring (اختياري clay polish)
                                width: 108,
                                height: 108,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.12),
                                    width: 1.2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.shopping_bag_rounded,
                                  color: context.primary,
                                  size: 56,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          Text(
                            'onboarding.title'.tr,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: context.foreground,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'onboarding.subtitle'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: context.mutedForeground,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const Spacer(flex: 3),

                          AppButton(
                            text: 'onboarding.get_started'.tr,
                            onPressed: controller.onGetStarted,
                          ),

                          const SizedBox(height: 16),

                          AppLinkButton(
                            text: 'onboarding.have_account'.tr,
                            onPressed: controller.onHaveAccount,
                          ),

                          const Spacer(flex: 1),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(top: 16, right: 16, child: AppToggles()),
            ],
          ),
        ),
      ),
    );
  }
}
