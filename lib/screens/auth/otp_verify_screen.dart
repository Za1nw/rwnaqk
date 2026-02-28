import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

import '../../controllers/forgot_password_controller.dart';
import '../../widgets/auth_blob_background.dart';
import '../../widgets/app_button.dart';
import '../../widgets/auth/auth_centered_container.dart';

class OtpVerifyScreen extends GetView<ForgotPasswordController> {
  const OtpVerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: AuthBlobBackground(
        child: SafeArea(
          child: AuthCenteredContainer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AuthTitleBlock(
                  title: 'fp.verify.title'.tr,
                  subtitle: '',
                ),
                Obx(() {
                  final isEmail =
                      controller.method.value == RecoveryMethod.email;

                  final subtitle = isEmail
                      ? 'fp.verify.subtitle_email'.tr
                      : 'fp.verify.subtitle_sms'.tr;

                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '$subtitle\n${controller.maskedTarget.value}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.mutedForeground,
                        height: 1.35,
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 18),
                _OtpBoxes(onChanged: controller.setOtp),
                const SizedBox(height: 20),
                AppButton(
                  text: 'fp.next'.tr,
                  icon: Icons.verified_rounded,
                  onPressed: controller.verifyOtp,
                  height: 54,
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final enabled = controller.canResend.value;
                  final seconds = controller.resendSeconds.value;

                  return TextButton(
                    onPressed: enabled ? controller.resendCode : null,
                    child: Text(
                      enabled
                          ? 'fp.verify.resend'.tr
                          : 'fp.verify.resend_in'.trParams({
                              's': '$seconds',
                            }),
                      style: TextStyle(
                        color:
                            enabled ? context.primary : context.mutedForeground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }),
                TextButton(
                  onPressed: controller.cancel,
                  child: Text(
                    'fp.cancel'.tr,
                    style: TextStyle(color: context.mutedForeground),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpBoxes extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const _OtpBoxes({required this.onChanged});

  @override
  State<_OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<_OtpBoxes> {
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _nodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(_controllers.map((e) => e.text).join());
  }

  @override
  Widget build(BuildContext context) {
    Widget box(int i) {
      return SizedBox(
        width: 54,
        height: 54,
        child: TextField(
          controller: _controllers[i],
          focusNode: _nodes[i],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: TextStyle(
            color: context.foreground,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: context.input,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: context.border.withOpacity(0.7)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: context.primary.withOpacity(0.9),
                width: 1.6,
              ),
            ),
          ),
          onChanged: (v) {
            if (v.isNotEmpty && i < 3) _nodes[i + 1].requestFocus();
            if (v.isEmpty && i > 0) _nodes[i - 1].requestFocus();
            _emit();
          },
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        box(0),
        const SizedBox(width: 10),
        box(1),
        const SizedBox(width: 10),
        box(2),
        const SizedBox(width: 10),
        box(3),
      ],
    );
  }
}
