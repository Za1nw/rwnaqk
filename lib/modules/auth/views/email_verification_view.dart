import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/services/auth/providers/auth_session_providers.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/utils/app_notifier.dart';
import 'package:rwnaqk_frontend/core/widgets/app_button.dart';
import 'package:rwnaqk_frontend/modules/auth/providers/auth_providers.dart';
import 'package:rwnaqk_frontend/modules/auth/widgets/auth_blob_background.dart';
import 'package:rwnaqk_frontend/modules/auth/widgets/auth_centered_container.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

/// شاشة التحقق من البريد الإلكتروني بتصميم ملكي فاخر وخانات إدخال منقسمة (3+3 Split Pods)
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  final GlobalKey<_LuxurySplitVerificationGridState> _gridKey =
      GlobalKey<_LuxurySplitVerificationGridState>();

  Timer? _countdownTimer;
  Timer? _autoSubmitTimer;
  int _secondsRemaining = 60;
  bool _isSending = false;
  bool _isVerifying = false;
  String _verificationCode = '';

  bool get _canResend => _secondsRemaining <= 0 && !_isSending;
  bool get _canVerify => _verificationCode.length == 6 && !_isVerifying;

  @override
  void initState() {
    super.initState();
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

    _animController.forward();
    _startCountdown();
  }

  @override
  void dispose() {
    _autoSubmitTimer?.cancel();
    _countdownTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _startCountdown([int seconds = 60]) {
    _countdownTimer?.cancel();
    setState(() {
      _secondsRemaining = seconds;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _secondsRemaining = 0;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      }
    });
  }

  Future<void> _resendVerification() async {
    if (!_canResend) return;

    setState(() {
      _isSending = true;
    });

    HapticFeedback.lightImpact();
    _startCountdown(60);
    _gridKey.currentState?.clear();

    try {
      final message = await ref
          .read(loginServiceProvider)
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

  Future<void> _verifyCode([String? directCode]) async {
    final codeToVerify = directCode ?? _verificationCode;
    if (_isVerifying || codeToVerify.length != 6) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      final message = await ref
          .read(loginServiceProvider)
          .verifyEmailVerificationCode(code: codeToVerify);
      AppNotifier.success(message);
      AppNav.offAllNamed(AppRoutes.main);
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
    if (code == _verificationCode) return;
    setState(() {
      _verificationCode = code;
    });
  }

  void _handleAutoSubmit(String code) {
    if (!_isVerifying && code.length == 6) {
      _autoSubmitTimer?.cancel();
      _autoSubmitTimer = Timer(const Duration(milliseconds: 250), () {
        if (mounted) {
          _verifyCode(code);
        }
      });
    }
  }

  void _handleSwitchAccount() {
    ref.read(authSessionProvider.notifier).clearSession();
    AppNav.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final argEmail = arguments is Map
        ? (arguments['email']?.toString().trim() ?? '')
        : '';
    final sessionEmail = ref.watch(authSessionProvider).customer?.email ?? '';
    final email = argEmail.isNotEmpty ? argEmail : sessionEmail;
    final isDark = context.isDark;

    final emailDisplay = email.isNotEmpty ? email : 'name@example.com';

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
                    // 1. أيقونة التحقق الملكية المتوهجة (Mail + Security)
                    _buildHeroIcon(context, isDark),
                    const SizedBox(height: 18),

                    // 2. كبسولة الشارة الأمنية
                    _buildSecurityBadge(context, isDark),
                    const SizedBox(height: 12),

                    // 3. العنوان الرئيسي والوصف الإرشادي الواضح
                    Text(
                      'تأكيد البريد الإلكتروني',
                      textAlign: TextAlign.center,
                      style: AppTextTheme.cairo(
                        color: context.foreground,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أدخل رمز التحقق المكوّن من 6 أرقام لتأكيد حسابك والبدء بالتسوق',
                      textAlign: TextAlign.center,
                      style: AppTextTheme.cairo(
                        color: context.mutedForeground,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. كبسولة عرض البريد الإلكتروني مع إمكانية التبديل
                    _buildEmailCapsule(
                      context,
                      emailDisplay,
                      isDark,
                      onSwitch: _handleSwitchAccount,
                    ),
                    const SizedBox(height: 32),

                    // 5. خانات الإدخال العصرية بتقسيم 3+3 وانسيابية تامة
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: _LuxurySplitVerificationGrid(
                        key: _gridKey,
                        enabled: !_isVerifying,
                        onChanged: _handleCodeChanged,
                        onCompleted: _handleAutoSubmit,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 6. قسم إعادة الإرسال المدمج مع العداد التنازلي
                    _buildResendRow(context),
                    const SizedBox(height: 26),

                    // 7. الزر الملكي الأساسي للتأكيد والمتابعة
                    AppButton(
                      text: 'تأكيد الحساب ومتابعة',
                      icon: Icons.check_circle_outline_rounded,
                      isLoading: _isVerifying,
                      height: 52,
                      borderRadius: 16,
                      onPressed: _canVerify ? () => _verifyCode() : null,
                    ),
                    const SizedBox(height: 14),

                    // 8. زر تسجيل الدخول بحساب آخر (خروج آمن من شاشة التحقق)
                    TextButton(
                      onPressed: _handleSwitchAccount,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            size: 14,
                            color: context.mutedForeground,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'تسجيل الدخول بحساب آخر',
                            style: AppTextTheme.cairo(
                              color: context.mutedForeground,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
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

  /// أيقونة رأسية هادئة تعبر عن التحقق من البريد بلمسة ملكية ناعمة
  Widget _buildHeroIcon(BuildContext context, bool isDark) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF380C23),
                  const Color(0xFF1B0713),
                ]
              : [
                  Colors.white,
                  AppColors.burgundy50,
                ],
        ),
        border: Border.all(
          color: (isDark ? BrandColors.gold : BrandColors.burgundy)
              .withValues(alpha: 0.28),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? BrandColors.gold : BrandColors.burgundy)
                .withValues(alpha: isDark ? 0.22 : 0.10),
            blurRadius: 22,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.mark_email_read_outlined,
          size: 34,
          color: context.primary,
        ),
      ),
    );
  }

  /// شارة كبسولية ناعمة تعبر عن أمان الحساب
  Widget _buildSecurityBadge(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF330C20) : AppColors.burgundy50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.primary.withValues(alpha: isDark ? 0.30 : 0.14),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 13, color: context.primary),
          const SizedBox(width: 5),
          Text(
            'تأكيد الحساب',
            style: AppTextTheme.cairo(
              color: context.primary,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  /// كبسولة عرض البريد الإلكتروني الأنيقة المدمجة مع خيار التبديل
  Widget _buildEmailCapsule(
    BuildContext context,
    String email,
    bool isDark, {
    required VoidCallback onSwitch,
  }) {
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
          const SizedBox(width: 10),
          Container(
            width: 1,
            height: 12,
            color: context.mutedForeground.withValues(alpha: 0.35),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onSwitch,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'تبديل',
                    style: AppTextTheme.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: context.primary,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    Icons.swap_horiz_rounded,
                    size: 13,
                    color: context.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// قسم إعادة الإرسال المدمج مع العداد التنازلي
  Widget _buildResendRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'لم يصلك الرمز؟ ',
          style: AppTextTheme.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: context.mutedForeground,
          ),
        ),
        if (_secondsRemaining > 0)
          Text(
            'إعادة الإرسال بعد ${_secondsRemaining.toString().padLeft(2, '0')} ثانية',
            style: AppTextTheme.cairo(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: context.primary.withValues(alpha: 0.85),
            ),
          )
        else
          InkWell(
            onTap: _isSending ? null : _resendVerification,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: _isSending
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.primary,
                      ),
                    )
                  : Text(
                      'إعادة إرسال الرمز الآن',
                      style: AppTextTheme.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: context.primary,
                      ).copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: context.primary,
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}

/// شبكة مربعات التحقق المنقسمة (3 + 3) مع انميشن انسيابي ومؤشر تفاعلي
class _LuxurySplitVerificationGrid extends StatefulWidget {
  const _LuxurySplitVerificationGrid({
    super.key,
    required this.onChanged,
    this.onCompleted,
    this.enabled = true,
  });

  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;

  @override
  State<_LuxurySplitVerificationGrid> createState() =>
      _LuxurySplitVerificationGridState();
}

class _LuxurySplitVerificationGridState
    extends State<_LuxurySplitVerificationGrid>
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
        debugLabel: 'EmailOtpBox_$index',
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

    final Color borderColor = isFocused
        ? context.primary
        : (hasValue
            ? context.primary.withValues(alpha: 0.6)
            : (isDark
                ? const Color(0xFF3B1E32)
                : const Color(0xFFE5D5DE)));

    final Color bgColor = isFocused
        ? (isDark
            ? const Color(0xFF2E1225)
            : const Color(0xFFFFF7FB))
        : (hasValue
            ? (isDark ? AppColors.surfaceDark : Colors.white)
            : (isDark
                ? const Color(0xFF1B0B18)
                : const Color(0xFFFCF8FA)));

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
          width: isFocused ? 2.0 : 1.2,
        ),
        boxShadow: isFocused
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
                : null),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // نقطة دلالية ناعمة جداً في الخانات الفارغة غير المحددة
          if (!isFocused && !hasValue)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.mutedForeground.withValues(alpha: 0.35),
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
                  color: context.primary,
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
                    color: context.foreground,
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
        color: context.mutedForeground.withValues(alpha: 0.4),
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
