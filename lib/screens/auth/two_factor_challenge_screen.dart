import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/login/two_factor_challenge_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/widgets/auth/auth_centered_container.dart';
import 'package:rwnaqk/widgets/auth_blob_background.dart';

class TwoFactorChallengeScreen extends GetView<TwoFactorChallengeController> {
  const TwoFactorChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: AuthBlobBackground(
        child: SafeArea(
          child: AuthCenteredContainer(
            child: Obx(() {
              final recoveryMode = controller.showRecoveryInput.value;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    recoveryMode
                        ? Tk.loginTwoFactorRecoveryTitle.tr
                        : Tk.loginTwoFactorTitle.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.foreground,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recoveryMode
                        ? Tk.loginTwoFactorRecoveryHint.tr
                        : Tk.fpAuthenticatorCodeHint.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.mutedForeground,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (recoveryMode)
                    TextField(
                      enabled: !controller.isLoading.value,
                      textInputAction: TextInputAction.done,
                      onChanged: controller.setRecoveryCode,
                      onSubmitted: (_) => controller.submit(),
                      decoration: InputDecoration(
                        hintText: Tk.loginTwoFactorRecoveryPlaceholder.tr,
                        filled: true,
                        fillColor: context.input,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: context.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: context.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: context.primary),
                        ),
                      ),
                    )
                  else
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: _OtpCodeGrid(
                        onChanged: controller.setCode,
                        enabled: !controller.isLoading.value,
                      ),
                    ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed:
                          controller.isLoading.value || !controller.canSubmit
                          ? null
                          : controller.submit,
                      child: controller.isLoading.value
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.primaryForeground,
                              ),
                            )
                          : Text(Tk.loginTwoFactorContinue.tr),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.toggleMode,
                    child: Text(
                      recoveryMode
                          ? Tk.loginTwoFactorUseAuthCode.tr
                          : Tk.loginTwoFactorUseRecoveryCode.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.primary,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _OtpCodeGrid extends StatefulWidget {
  const _OtpCodeGrid({required this.onChanged, required this.enabled});

  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  State<_OtpCodeGrid> createState() => _OtpCodeGridState();
}

class _OtpCodeGridState extends State<_OtpCodeGrid> {
  static const String _arabicIndicDigits = '٠١٢٣٤٥٦٧٨٩';
  static const String _easternArabicDigits = '۰۱۲۳۴۵۶۷۸۹';

  String _normalizeVerificationDigits(String value) {
    final buffer = StringBuffer();

    for (final rune in value.runes) {
      final character = String.fromCharCode(rune);
      final arabicIndex = _arabicIndicDigits.indexOf(character);
      if (arabicIndex != -1) {
        buffer.write(arabicIndex);
        continue;
      }

      final easternIndex = _easternArabicDigits.indexOf(character);
      if (easternIndex != -1) {
        buffer.write(easternIndex);
        continue;
      }

      if (RegExp(r'[0-9]').hasMatch(character)) {
        buffer.write(character);
      }
    }

    return buffer.toString();
  }

  final _controllers = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    for (final node in _nodes) {
      node.addListener(_handleFocusChanged);
    }
  }

  @override
  void dispose() {
    for (final n in _nodes) {
      n.removeListener(_handleFocusChanged);
    }
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _handleFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _emit() {
    widget.onChanged(_controllers.map((e) => e.text).join());
  }

  int _firstEmptyIndex() {
    for (var i = 0; i < _controllers.length; i++) {
      if (_controllers[i].text.isEmpty) {
        return i;
      }
    }

    return _controllers.length - 1;
  }

  void _applyCode(String code, {int startIndex = 0}) {
    final digits = _normalizeVerificationDigits(code);

    _syncing = true;
    for (var i = 0; i < _controllers.length; i++) {
      final nextValue = i < startIndex
          ? _controllers[i].text
          : i - startIndex < digits.length
          ? digits[i - startIndex]
          : '';
      _controllers[i].text = nextValue;
      _controllers[i].selection = TextSelection.collapsed(
        offset: nextValue.length,
      );
    }
    _syncing = false;

    _emit();

    final nextFocusIndex = (startIndex + digits.length).clamp(0, 5);
    if (digits.length < 6 && nextFocusIndex < _nodes.length) {
      _nodes[nextFocusIndex].requestFocus();
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  void _handleChanged(int index, String value) {
    if (_syncing) {
      return;
    }

    final digits = _normalizeVerificationDigits(value);

    if (digits.length > 1) {
      // Always distribute pasted codes from the first box (left-to-right).
      _applyCode(digits, startIndex: 0);
      return;
    }

    final singleDigit = digits;

    if (_controllers[index].text != singleDigit) {
      _syncing = true;
      _controllers[index].text = singleDigit;
      _controllers[index].selection = TextSelection.collapsed(
        offset: singleDigit.length,
      );
      _syncing = false;
    }

    if (singleDigit.isNotEmpty && index < _nodes.length - 1) {
      _nodes[index + 1].requestFocus();
    }

    if (singleDigit.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }

    _emit();
  }

  Widget _buildBox(int index, double boxSize) {
    final isFocused = _nodes[index].hasFocus;
    final hasValue = _controllers[index].text.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: isFocused
            ? context.primary.withValues(alpha: 0.07)
            : context.input,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused
              ? context.primary
              : hasValue
              ? context.primary.withValues(alpha: 0.45)
              : context.border,
          width: isFocused ? 1.7 : 1.05,
        ),
        boxShadow: [
          BoxShadow(
            color: isFocused
                ? context.primary.withValues(alpha: 0.18)
                : context.shadow.withValues(alpha: 0.08),
            blurRadius: isFocused ? 16 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _nodes[index],
        enabled: widget.enabled,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLength: 6,
        maxLines: 1,
        showCursor: false,
        style: TextStyle(
          color: context.foreground,
          fontWeight: FontWeight.w900,
          fontSize: boxSize * 0.46,
          height: 1,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹]')),
        ],
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) => _handleChanged(index, value),
        onTap: () {
          if (_controllers[index].text.isEmpty) {
            final targetIndex = _firstEmptyIndex();
            if (targetIndex != index) {
              _nodes[targetIndex].requestFocus();
            }

            _controllers[targetIndex].selection = TextSelection.collapsed(
              offset: _controllers[targetIndex].text.length,
            );
            return;
          }

          _controllers[index].selection = TextSelection.collapsed(
            offset: _controllers[index].text.length,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final boxSize = ((availableWidth - 5 * 6) / 6).clamp(34.0, 41.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              textDirection: TextDirection.ltr,
              children: [
                for (var i = 0; i < 6; i++) ...[
                  _buildBox(i, boxSize),
                  if (i < 5) const SizedBox(width: 6),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}
