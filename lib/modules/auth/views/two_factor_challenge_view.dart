import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/widgets/app_button.dart';
import 'package:rwnaqk_frontend/modules/auth/providers/auth_flow_providers.dart';
import 'package:rwnaqk_frontend/modules/auth/widgets/auth_blob_background.dart';
import 'package:rwnaqk_frontend/modules/auth/widgets/auth_centered_container.dart';
import 'package:rwnaqk_frontend/routes/app_route_args.dart';

/// شاشة تأكيد المصادقة الثنائية (رمز المصادقة / رمز الاسترداد) عند تسجيل الدخول
///
/// تجربة بوتيك فاخرة متبنية نظام الـ 3+3 Split Pods، أنيميشن الهزة عند الخطأ (Shake Animation)، والتحول للأحمر
class TwoFactorChallengeScreen extends ConsumerStatefulWidget {
  const TwoFactorChallengeScreen({super.key});

  @override
  ConsumerState<TwoFactorChallengeScreen> createState() =>
      _TwoFactorChallengeScreenState();
}

class _TwoFactorChallengeScreenState
    extends ConsumerState<TwoFactorChallengeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnim;

  final GlobalKey<_LuxurySplitOtpGridState> _otpGridKey =
      GlobalKey<_LuxurySplitOtpGridState>();

  final TextEditingController _recoveryController = TextEditingController();
  Timer? _autoSubmitTimer;

  String _loginEmail = '';
  String _loginPassword = '';

  @override
  void initState() {
    super.initState();

    // 1. أنيميشن الظهور السلس الأولي
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    // 2. أنيميشن الهزة الفيزيائية عند إدخال رمز خطأ (Damped Harmonic Shake)
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 12.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12.0, end: -9.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -9.0, end: 9.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 9.0, end: -5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));

    _animController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _loginEmail = (args[AppRouteArgs.loginEmail] ??
              args[AppRouteArgs.target] ??
              args['email'] ??
              '')
          .toString()
          .trim();
      _loginPassword = (args[AppRouteArgs.loginPassword] ??
              args['password'] ??
              '')
          .toString();
    }
  }

  @override
  void dispose() {
    _autoSubmitTimer?.cancel();
    _animController.dispose();
    _shakeController.dispose();
    _recoveryController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0);
    HapticFeedback.heavyImpact();
  }

  void _handleAutoSubmit(String code) {
    final state = ref.read(twoFactorChallengeFlowProvider);
    if (!state.isLoading && code.length == 6) {
      _autoSubmitTimer?.cancel();
      _autoSubmitTimer = Timer(const Duration(milliseconds: 250), () {
        if (mounted) {
          ref.read(twoFactorChallengeFlowProvider.notifier).submit(
                loginEmail: _loginEmail,
                loginPassword: _loginPassword,
              );
        }
      });
    }
  }

  void _handleToggleMode() {
    _otpGridKey.currentState?.clear();
    _recoveryController.clear();
    ref.read(twoFactorChallengeFlowProvider.notifier).toggleMode();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    // الاستماع لأي خطأ في المصادقة لإطلاق الهزة والاهتزاز اللمسي تلقائياً
    ref.listen<TwoFactorChallengeState>(twoFactorChallengeFlowProvider,
        (previous, next) {
      if (next.hasError &&
          (previous == null || previous.errorTicks != next.errorTicks)) {
        _triggerShake();
      }
    });

    final state = ref.watch(twoFactorChallengeFlowProvider);
    final notifier = ref.read(twoFactorChallengeFlowProvider.notifier);
    final recoveryMode = state.showRecoveryInput;
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.background,
      body: AuthBlobBackground(
        child: SafeArea(
          child: AuthCenteredContainer(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. أيقونة الحماية الملكية المضيئة
                    _buildHeroIcon(context, isDark, recoveryMode, state.hasError),
                    const SizedBox(height: 20),

                    // 2. العنوان الرئيسي والوصف الإرشادي
                    Text(
                      recoveryMode
                          ? Tk.loginTwoFactorRecoveryTitle.tr
                          : Tk.loginTwoFactorTitle.tr,
                      textAlign: TextAlign.center,
                      style: AppTextTheme.cairo(
                        color: context.foreground,
                        fontSize: 26,
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
                      style: AppTextTheme.cairo(
                        color: context.mutedForeground,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 3. كبسولة البريد الإلكتروني الأنيقة
                    if (_loginEmail.isNotEmpty)
                      _buildRecipientCapsule(context, _loginEmail, isDark),
                    const SizedBox(height: 32),

                    // 4. منطقة الإدخال مع انميشن الهزة (Shake Animation)
                    AnimatedBuilder(
                      animation: _shakeAnim,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnim.value, 0),
                          child: child,
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (recoveryMode)
                            _buildRecoveryInput(
                              context,
                              state,
                              notifier,
                              isDark,
                            )
                          else
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: _LuxurySplitOtpGrid(
                                key: _otpGridKey,
                                enabled: !state.isLoading,
                                hasError: state.hasError,
                                onChanged: notifier.setCode,
                                onCompleted: _handleAutoSubmit,
                              ),
                            ),

                          // رسالة التنبيه الحمراء عند حدوث خطأ
                          if (state.hasError) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  size: 15,
                                  color: context.destructive,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    recoveryMode
                                        ? 'رمز الاسترداد غير صحيح، يرجى التأكد وإعادة المحاولة'
                                        : 'رمز المصادقة غير صحيح، أدخل الرمز الحالي بالتطبيق',
                                    textAlign: TextAlign.center,
                                    style: AppTextTheme.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: context.destructive,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 5. الزر الملكي الأساسي للمتابعة
                    AppButton(
                      text: Tk.loginTwoFactorContinue.tr,
                      icon: Icons.arrow_forward_rounded,
                      isLoading: state.isLoading,
                      height: 52,
                      borderRadius: 16,
                      onPressed: state.isLoading || !state.canSubmit
                          ? null
                          : () => notifier.submit(
                                loginEmail: _loginEmail,
                                loginPassword: _loginPassword,
                              ),
                    ),
                    const SizedBox(height: 16),

                    // 6. زر التبديل بين تطبيق المصادقة ورمز الاسترداد
                    TextButton.icon(
                      onPressed: state.isLoading ? null : _handleToggleMode,
                      icon: Icon(
                        recoveryMode
                            ? Icons.qr_code_2_rounded
                            : Icons.vpn_key_outlined,
                        size: 18,
                        color: context.primary,
                      ),
                      label: Text(
                        recoveryMode
                            ? Tk.loginTwoFactorUseAuthCode.tr
                            : Tk.loginTwoFactorUseRecoveryCode.tr,
                        style: AppTextTheme.cairo(
                          color: context.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // 7. زر الإلغاء والعودة
                    TextButton(
                      onPressed: state.isLoading ? null : () => AppNav.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                      ),
                      child: Text(
                        Tk.fpCancel.tr,
                        style: AppTextTheme.cairo(
                          color: context.mutedForeground,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// أيقونة رأسية هادئة تعبر عن الأمان بلمسة ملكية ناعمة (أو حمراء عند الخطأ)
  Widget _buildHeroIcon(
    BuildContext context,
    bool isDark,
    bool isRecovery,
    bool hasError,
  ) {
    final activeColor = hasError ? context.destructive : context.primary;

    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasError
              ? (isDark
                  ? [const Color(0xFF380C14), const Color(0xFF1B070A)]
                  : [Colors.white, const Color(0xFFFFF0F2)])
              : (isDark
                  ? [const Color(0xFF380C23), const Color(0xFF1B0713)]
                  : [Colors.white, AppColors.burgundy50]),
        ),
        border: Border.all(
          color: activeColor.withValues(alpha: hasError ? 0.45 : 0.28),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: activeColor.withValues(
              alpha: isDark ? (hasError ? 0.32 : 0.22) : (hasError ? 0.18 : 0.10),
            ),
            blurRadius: 22,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          hasError
              ? Icons.error_outline_rounded
              : (isRecovery ? Icons.vpn_key_outlined : Icons.shield_outlined),
          size: 34,
          color: activeColor,
        ),
      ),
    );
  }

  /// كبسولة عرض البريد الإلكتروني الأنيقة
  Widget _buildRecipientCapsule(
    BuildContext context,
    String email,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.85)
            : context.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: context.primary.withValues(alpha: isDark ? 0.24 : 0.12),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.alternate_email_rounded,
            size: 14,
            color: context.primary,
          ),
          const SizedBox(width: 8),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextTheme.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: context.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// حقل إدخال رمز الاسترداد العصري مع تحول الحدود للأحمر عند الخطأ
  Widget _buildRecoveryInput(
    BuildContext context,
    TwoFactorChallengeState state,
    TwoFactorChallengeFlowNotifier notifier,
    bool isDark,
  ) {
    final hasError = state.hasError;
    final borderColor = hasError ? context.destructive : context.border;
    final bgColor = hasError
        ? (isDark ? const Color(0xFF2E0D12) : const Color(0xFFFFF0F2))
        : (isDark ? AppColors.surfaceDark : Colors.white);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
          width: hasError ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: hasError
                ? context.destructive.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: hasError ? 14 : 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _recoveryController,
        enabled: !state.isLoading,
        textInputAction: TextInputAction.done,
        textAlign: TextAlign.center,
        onChanged: notifier.setRecoveryCode,
        onSubmitted: (_) {
          if (state.canSubmit) {
            notifier.submit(
              loginEmail: _loginEmail,
              loginPassword: _loginPassword,
            );
          }
        },
        style: TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          fontSize: 16,
          color: context.foreground,
        ),
        decoration: InputDecoration(
          hintText: Tk.loginTwoFactorRecoveryPlaceholder.tr,
          hintStyle: AppTextTheme.cairo(
            color: context.mutedForeground,
            fontSize: 13,
            letterSpacing: 0,
          ),
          filled: false,
          prefixIcon: Icon(
            Icons.vpn_key_outlined,
            color: hasError ? context.destructive : context.primary,
            size: 20,
          ),
          suffixIcon: _recoveryController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    _recoveryController.clear();
                    notifier.setRecoveryCode('');
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

/// شبكة مربعات إدخال كود المصادقة الثنائية العصرية المنقسمة (3 + 3) مع انميشن الارتداد والحدود الحمراء
class _LuxurySplitOtpGrid extends StatefulWidget {
  const _LuxurySplitOtpGrid({
    super.key,
    required this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.hasError = false,
  });

  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;
  final bool hasError;

  @override
  State<_LuxurySplitOtpGrid> createState() => _LuxurySplitOtpGridState();
}

class _LuxurySplitOtpGridState extends State<_LuxurySplitOtpGrid>
    with SingleTickerProviderStateMixin {
  static const int _cellCount = 6;
  static const String _arabicIndicDigits = '٠١٢٣٤٥٦٧٨٩';
  static const String _easternArabicDigits = '۰۱۲۳۴۵۶۷۸۹';

  final List<TextEditingController> _controllers =
      List.generate(_cellCount, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = [];
  final List<int> _pulseTicks = List.filled(_cellCount, 0);

  late final AnimationController _cursorAnimController;
  late final Animation<double> _cursorFade;

  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();

    _cursorAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _cursorFade = CurvedAnimation(
      parent: _cursorAnimController,
      curve: Curves.easeInOut,
    );

    for (var i = 0; i < _cellCount; i++) {
      final index = i;
      final node = FocusNode(
        debugLabel: 'ChallengeSplitOtpBox_$index',
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            if (_controllers[index].text.isEmpty && index > 0) {
              _isSyncing = true;
              _controllers[index - 1].text = '';
              _isSyncing = false;
              _focusNodes[index - 1].requestFocus();
              _emit();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
      );

      node.addListener(_handleFocusChanged);
      _focusNodes.add(node);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.enabled && _focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _cursorAnimController.dispose();
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

  void clear() {
    _isSyncing = true;
    for (final c in _controllers) {
      c.clear();
    }
    _isSyncing = false;
    _emit();
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
  }

  String _normalizeDigits(String value) {
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

  void _emit() {
    final code = _controllers.map((c) => c.text).join();
    widget.onChanged(code);
    if (code.length == _cellCount) {
      widget.onCompleted?.call(code);
    }
  }

  int _firstEmptyIndex() {
    for (var i = 0; i < _cellCount; i++) {
      if (_controllers[i].text.isEmpty) {
        return i;
      }
    }
    return _cellCount - 1;
  }

  void _pasteCode(String digits, {int startIndex = 0}) {
    if (digits.isEmpty) return;
    _isSyncing = true;
    for (var i = 0; i < _cellCount; i++) {
      if (i >= startIndex && (i - startIndex) < digits.length) {
        _controllers[i].text = digits[i - startIndex];
        _pulseTicks[i]++;
      }
    }
    _isSyncing = false;
    _emit();

    final nextIndex = (startIndex + digits.length).clamp(0, _cellCount - 1);
    if (digits.length >= _cellCount) {
      FocusScope.of(context).unfocus();
      HapticFeedback.mediumImpact();
    } else {
      _focusNodes[nextIndex].requestFocus();
      HapticFeedback.lightImpact();
    }
  }

  void _handleChanged(int index, String value) {
    if (_isSyncing) return;

    final normalized = _normalizeDigits(value);

    // حالة اللصق المباشر
    if (normalized.length > 1) {
      _pasteCode(normalized, startIndex: index);
      return;
    }

    if (normalized.isNotEmpty) {
      final singleChar = normalized[normalized.length - 1];
      _isSyncing = true;
      _controllers[index].text = singleChar;
      _controllers[index].selection = const TextSelection.collapsed(offset: 1);
      _isSyncing = false;

      setState(() {
        _pulseTicks[index]++;
      });
      HapticFeedback.lightImpact();

      // الانتقال الفوري التلقائي للخانة التالية
      if (index < _cellCount - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        HapticFeedback.mediumImpact();
      }
    } else {
      _isSyncing = true;
      _controllers[index].text = '';
      _isSyncing = false;
    }

    _emit();
  }

  Widget _buildBox(int index, double boxWidth, double boxHeight) {
    final isFocused = _focusNodes[index].hasFocus;
    final hasValue = _controllers[index].text.isNotEmpty;
    final isDark = context.isDark;
    final hasError = widget.hasError;

    // عند الخطأ يتحول لون الحدود للأحمر الصريح مع توهج أحمر
    final Color borderColor = hasError
        ? context.destructive
        : (isFocused
            ? context.primary
            : (hasValue
                ? context.primary.withValues(alpha: 0.6)
                : (isDark
                    ? const Color(0xFF3B1E32)
                    : const Color(0xFFE5D5DE))));

    final Color bgColor = hasError
        ? (isDark ? const Color(0xFF2E0D12) : const Color(0xFFFFF0F2))
        : (isFocused
            ? (isDark ? const Color(0xFF2E1225) : const Color(0xFFFFF7FB))
            : (hasValue
                ? (isDark ? AppColors.surfaceDark : Colors.white)
                : (isDark
                    ? const Color(0xFF1B0B18)
                    : const Color(0xFFFCF8FA))));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: boxWidth,
      height: boxHeight,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: hasError ? 2.0 : (isFocused ? 2.0 : 1.2),
        ),
        boxShadow: hasError
            ? [
                BoxShadow(
                  color: context.destructive.withValues(alpha: 0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : (isFocused
                ? [
                    BoxShadow(
                      color: context.primary.withValues(alpha: 0.24),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : (hasValue
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.28 : 0.05,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // نقطة دلالية ناعمة في الخانات الفارغة غير المحددة
          if (!isFocused && !hasValue)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasError
                    ? context.destructive.withValues(alpha: 0.45)
                    : context.mutedForeground.withValues(alpha: 0.35),
              ),
            ),

          // مؤشر الكتابة الوامض الأنيق عندما تكون الخانة محددة وفارغة
          if (isFocused && !hasValue)
            FadeTransition(
              opacity: _cursorFade,
              child: Container(
                width: 2.2,
                height: boxHeight * 0.44,
                decoration: BoxDecoration(
                  color: hasError ? context.destructive : context.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

          // انميشن الارتداد للرقم المكتوب
          TweenAnimationBuilder<double>(
            key: ValueKey(_pulseTicks[index]),
            tween: Tween<double>(begin: 0.72, end: 1.0),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: hasValue ? scale : 1.0,
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  enabled: widget.enabled,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  maxLength: 2,
                  maxLines: 1,
                  showCursor: false,
                  style: AppTextTheme.cairo(
                    color: hasError ? context.destructive : context.foreground,
                    fontWeight: FontWeight.w900,
                    fontSize: boxHeight * 0.44,
                    height: 1.1,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹]')),
                  ],
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) => _handleChanged(index, val),
                  onTap: () {
                    final target = _firstEmptyIndex();
                    if (target < index) {
                      _focusNodes[target].requestFocus();
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// الفاصل البصري الأنيق بين أول 3 أرقام وآخر 3 أرقام
  Widget _buildMiddleDivider(BuildContext context) {
    return Container(
      width: 10,
      height: 2.5,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: widget.hasError
            ? context.destructive.withValues(alpha: 0.5)
            : context.mutedForeground.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final gap = availableWidth < 350 ? 5.0 : 7.0;
        const middleExtra = 10.0;
        final totalGaps = (4 * gap) + middleExtra;
        final boxWidth =
            ((availableWidth - totalGaps) / _cellCount).clamp(38.0, 48.0);
        final boxHeight = (boxWidth * 1.25).clamp(48.0, 60.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: TextDirection.ltr,
          children: [
            // المجموعة الأولى (3 أرقام)
            _buildBox(0, boxWidth, boxHeight),
            SizedBox(width: gap),
            _buildBox(1, boxWidth, boxHeight),
            SizedBox(width: gap),
            _buildBox(2, boxWidth, boxHeight),

            // الفاصل الأوسط (Dash)
            _buildMiddleDivider(context),

            // المجموعة الثانية (3 أرقام)
            _buildBox(3, boxWidth, boxHeight),
            SizedBox(width: gap),
            _buildBox(4, boxWidth, boxHeight),
            SizedBox(width: gap),
            _buildBox(5, boxWidth, boxHeight),
          ],
        );
      },
    );
  }
}
