import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/services/auth/providers/auth_session_providers.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/utils/app_notifier.dart';
import 'package:rwnaqk_frontend/core/widgets/app_button.dart';
import 'package:rwnaqk_frontend/modules/auth/widgets/auth_blob_background.dart';
import 'package:rwnaqk_frontend/modules/auth/widgets/auth_centered_container.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

/// شاشة انقطاع الاتصال والخطأ بالخادم الملكية الفاخرة [NetworkErrorScreen]
///
/// تظهر عند وجود مشكلة في الإنترنت أو تعذر وصول المستخدم المسجل إلى السيرفر
/// وتمنع فتح الشاشة الرئيسية ببيانات وهمية مع إتاحة إعادة المحاولة أو تسجيل الخروج
class NetworkErrorScreen extends ConsumerStatefulWidget {
  const NetworkErrorScreen({super.key});

  @override
  ConsumerState<NetworkErrorScreen> createState() => _NetworkErrorScreenState();
}

class _NetworkErrorScreenState extends ConsumerState<NetworkErrorScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleRetry() async {
    if (_isRetrying) return;
    HapticFeedback.lightImpact();

    setState(() => _isRetrying = true);

    final success = await ref
        .read(authSessionProvider.notifier)
        .retryBootstrap();

    if (!mounted) return;

    setState(() => _isRetrying = false);

    if (success) {
      AppNotifier.success('تمت إعادة الاتصال بنجاح.');
    } else {
      AppNotifier.error(
        'تعذر الاتصال بالخادم، يرجى التأكد من اتصال الإنترنت والمحاولة مرة أخرى.',
      );
    }
  }

  Future<void> _handleLogout() async {
    HapticFeedback.lightImpact();
    await ref.read(authSessionProvider.notifier).logout();
    AppNav.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.background,
      body: AuthBlobBackground(
        child: SafeArea(
          child: AuthCenteredContainer(
            maxWidth: 480,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 1. أيقونة انقطاع الاتصال الملكية المتوهجة
                    _buildHeroIcon(context, isDark),

                    const SizedBox(height: 28),

                    // 2. العنوان الرئيسي
                    Text(
                      'تعذر الاتصال بالخادم',
                      textAlign: TextAlign.center,
                      style: AppTextTheme.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: context.foreground,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 3. الشرح والتفاصيل
                    Text(
                      'يبدو أن هناك مشكلة في الاتصال بالإنترنت أو أن خوادم رَوْنَقُك غير متاحة حالياً.\nيرجى التحقق من اتصالك والمحاولة مجدداً.',
                      textAlign: TextAlign.center,
                      style: AppTextTheme.cairo(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: context.mutedForeground,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // 4. زر إعادة المحاولة
                    AppButton(
                      text: 'إعادة المحاولة',
                      icon: Icons.refresh_rounded,
                      isLoading: _isRetrying,
                      onPressed: _handleRetry,
                    ),

                    const SizedBox(height: 16),

                    // 5. زر تسجيل الخروج / التبديل لحساب آخر
                    TextButton.icon(
                      onPressed: _isRetrying ? null : _handleLogout,
                      icon: const Icon(Icons.logout_rounded, size: 17),
                      label: Text(
                        'تسجيل الخروج أو استخدام حساب آخر',
                        style: AppTextTheme.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: context.mutedForeground,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
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

  Widget _buildHeroIcon(BuildContext context, bool isDark) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF4A1028), const Color(0xFF280614)]
              : [const Color(0xFF6B0B36), const Color(0xFF3F041F)],
        ),
        border: Border.all(
          color: BrandColors.gold.withValues(alpha: isDark ? 0.5 : 0.4),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B0B36)
                .withValues(alpha: isDark ? 0.40 : 0.25),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Icon(Icons.wifi_off_rounded, size: 46, color: BrandColors.gold),
      ),
    );
  }
}
