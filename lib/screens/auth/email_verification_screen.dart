import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/controllers/login/login_service.dart';
import 'package:rwnaqk/core/utils/app_notifier.dart';
import 'package:rwnaqk/widgets/auth_blob_background.dart';
import 'package:rwnaqk/widgets/auth/auth_centered_container.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
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

  bool _isSending = false;
  bool _isVerifying = false;
  String _verificationCode = '';

  bool get _canVerify => _verificationCode.length == 6;

  Future<void> _resendVerification() async {
    if (_isSending) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final message = await Get.find<LoginService>()
          .sendEmailVerificationCode();
      AppNotifier.success(message);
    } catch (error) {
      AppNotifier.errorFrom(error);
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _verifyCode() async {
    if (_isVerifying || !_canVerify) {
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final message = await Get.find<LoginService>()
          .verifyEmailVerificationCode(code: _verificationCode);
      AppNotifier.success(message);
      Get.offAllNamed(AppRoutes.login);
    } catch (error) {
      AppNotifier.errorFrom(error);
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  void _handleCodeChanged(String code) {
    final digits = _normalizeVerificationDigits(code);
    if (digits == _verificationCode) {
      return;
    }

    setState(() {
      _verificationCode = digits.length > 6 ? digits.substring(0, 6) : digits;
    });
  }

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments;
    final email = arguments is Map
        ? (arguments['email']?.toString().trim() ?? '')
        : '';

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
                    'تحقق آمن',
                    style: TextStyle(
                      color: context.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'تحقق من بريدك الإلكتروني',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.foreground,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email.isEmpty
                      ? Tk.registerVerifyEmailHint.tr
                      : '${Tk.registerVerifyEmailHint.tr}\n$email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.mutedForeground,
                    height: 1.3,
                    fontSize: 12,
                  ),
                ),
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
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: _VerificationCodeGrid(
                          onChanged: _handleCodeChanged,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: _isVerifying || !_canVerify ? null : _verifyCode,
                    child: _isVerifying
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.primaryForeground,
                            ),
                          )
                        : const Text('تحقق'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _isSending ? null : _resendVerification,
                    child: _isSending
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.primary,
                            ),
                          )
                        : Text(Tk.fpVerifyResend.tr),
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.login),
                  child: Text(Tk.loginSignIn.tr),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VerificationCodeGrid extends StatefulWidget {
  const _VerificationCodeGrid({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<_VerificationCodeGrid> createState() => _VerificationCodeGridState();
}

class _VerificationCodeGridState extends State<_VerificationCodeGrid> {
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

  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    for (final node in _focusNodes) {
      node.addListener(_handleFocusChanged);
    }
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.removeListener(_handleFocusChanged);
      node.dispose();
    }
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String get _currentCode =>
      _controllers.map((controller) => controller.text).join();

  void _notifyChanged() {
    widget.onChanged(_currentCode);
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

    _notifyChanged();

    final nextFocusIndex = (startIndex + digits.length).clamp(0, 5);
    if (digits.length < 6 && nextFocusIndex < _focusNodes.length) {
      _focusNodes[nextFocusIndex].requestFocus();
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
      _applyCode(digits, startIndex: index);
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

    if (singleDigit.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    if (singleDigit.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    _notifyChanged();
  }

  Widget _buildBox(int index, double boxSize) {
    final isFocused = _focusNodes[index].hasFocus;
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
        focusNode: _focusNodes[index],
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
              _focusNodes[targetIndex].requestFocus();
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
