import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/forgot_password/forgot_password_service.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';

import '../../controllers/forgot_password/forgot_password_controller.dart';
import '../../widgets/auth_blob_background.dart';
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: context.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: context.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Text(
                    controller.isTwoFactorFlow ? 'تحقق آمن' : 'استعادة آمنة',
                    style: TextStyle(
                      color: context.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Obx(() {
                  return Text(
                    controller.isTwoFactorFlow
                        ? Tk.fpTwoFactorTitle.tr
                        : Tk.fpVerifyTitle.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.foreground,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
                  );
                }),
                const SizedBox(height: 5),
                Obx(() {
                  final isEmail =
                      controller.method.value == RecoveryMethod.email;

                  final subtitle = controller.isTwoFactorFlow
                      ? Tk.fpAuthenticatorCodeHint.tr
                      : (isEmail
                            ? Tk.fpVerifySubtitleEmail.tr
                            : Tk.fpVerifySubtitleSms.tr);

                  return Text(
                    '$subtitle\n${controller.maskedTarget.value}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.mutedForeground,
                      height: 1.3,
                      fontSize: 12,
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        context.card.withValues(alpha: 0.98),
                        context.card.withValues(alpha: 0.96),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: context.border.withValues(alpha: 0.58),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.shadow.withValues(alpha: 0.10),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: context.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.lock_outline_rounded,
                              size: 15,
                              color: context.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'رمز التحقق',
                            style: TextStyle(
                              color: context.foreground,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _OtpBoxes(onChanged: controller.setOtp),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.verifyOtp,
                      child: controller.isLoading.value
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.primaryForeground,
                              ),
                            )
                          : Text(Tk.fpNext.tr),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Obx(() {
                  final enabled = controller.canResend.value;
                  final seconds = controller.resendSeconds.value;

                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: enabled ? controller.resendCode : null,
                      child: Text(
                        enabled
                            ? Tk.fpVerifyResend.tr
                            : Tk.fpVerifyResendIn.trParams({'s': '$seconds'}),
                        style: TextStyle(
                          color: enabled
                              ? context.primary
                              : context.mutedForeground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: controller.cancel,
                  child: Text(
                    Tk.fpCancel.tr,
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
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _emit() {
    widget.onChanged(_controllers.map((e) => e.text).join());
  }

  @override
  Widget build(BuildContext context) {
    Widget box(int i) {
      return SizedBox(
        width: 40,
        height: 40,
        child: TextField(
          controller: _controllers[i],
          focusNode: _nodes[i],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: TextStyle(
            color: context.foreground,
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: context.input,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: context.border.withValues(alpha: 0.7),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: context.primary.withValues(alpha: 0.9),
                width: 1.6,
              ),
            ),
          ),
          onChanged: (v) {
            if (v.isNotEmpty && i < _nodes.length - 1) {
              _nodes[i + 1].requestFocus();
            }
            if (v.isEmpty && i > 0) {
              _nodes[i - 1].requestFocus();
            }
            _emit();
          },
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < 6; i++) ...[
          box(i),
          if (i < 5) const SizedBox(width: 6),
        ],
      ],
    );
  }
}
