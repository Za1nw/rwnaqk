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
import 'package:url_launcher/url_launcher.dart';

/// شاشة الحظر الملكية الفاخرة [BannedScreen]
///
/// تُقفل التطبيق بالكامل وتمنع أي وصول لموارد المتجر للعملاء المحظورين
/// مع توفير قنوات تواصل واضحة مع الدعم وإمكانية التبديل لحساب آخر.
class BannedScreen extends ConsumerStatefulWidget {
  const BannedScreen({super.key});

  @override
  ConsumerState<BannedScreen> createState() => _BannedScreenState();
}

class _BannedScreenState extends ConsumerState<BannedScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  static const String _supportPhone = '967771508902';
  static const String _supportEmail = 'support@rawnaqk.com';

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
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _contactViaWhatsApp() async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(
      'https://wa.me/$_supportPhone?text=${Uri.encodeComponent('مرحباً، تم حظر حسابي في متجر رَوْنَقُك وأود الاستفسار لمراجعة الحساب.')}',
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await Clipboard.setData(const ClipboardData(text: _supportPhone));
        AppNotifier.info('تم نسخ رقم الدعم الفني: $_supportPhone');
      }
    } catch (_) {
      await Clipboard.setData(const ClipboardData(text: _supportPhone));
      AppNotifier.info('تم نسخ رقم الدعم الفني: $_supportPhone');
    }
  }

  Future<void> _contactViaEmail() async {
    HapticFeedback.lightImpact();
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: <String, String>{
        'subject': 'طلب مراجعة حساب محظور - تطبيق رَوْنَقُك',
      },
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await Clipboard.setData(const ClipboardData(text: _supportEmail));
        AppNotifier.info('تم نسخ بريد الدعم الفني: $_supportEmail');
      }
    } catch (_) {
      await Clipboard.setData(const ClipboardData(text: _supportEmail));
      AppNotifier.info('تم نسخ بريد الدعم الفني: $_supportEmail');
    }
  }

  void _switchAccount() {
    HapticFeedback.mediumImpact();
    ref.read(authSessionProvider.notifier).clearSession();
    AppNav.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider);
    final customer = session.customer;
    final reasonMessage = session.errorMessage?.trim();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor:
            isDark ? BrandColors.darkBackground : const Color(0xFFFBF8F9),
        body: AuthBlobBackground(
          child: SafeArea(
            child: Center(
              child: AuthCenteredContainer(
                maxWidth: 480,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),
                          // Ban Icon Hero Badge
                          _buildHeroBanBadge(isDark),
                          const SizedBox(height: 24),

                          // Main Title & Subtitle
                          Text(
                            'الحساب محظور',
                            textAlign: TextAlign.center,
                            style: AppTextTheme.cairo(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFD32F2F),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'تم إيقاف إمكانية الوصول إلى المتجر لهذا الحساب بناءً على سياسات الأمان أو لمخالفة شروط الاستخدام.',
                            textAlign: TextAlign.center,
                            style: AppTextTheme.cairo(
                              fontSize: 13.5,
                              color: isDark
                                  ? BrandColors.darkText.withValues(alpha: 0.72)
                                  : const Color(0xFF6B5863),
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Account Details Capsule
                          _buildAccountDetailsPod(
                            customerName: customer?.displayName ??
                                customer?.fullName ??
                                'عميل رَوْنَقُك',
                            emailOrPhone: customer?.email ??
                                customer?.mobile ??
                                'حساب مسجل',
                            reason: reasonMessage,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 24),

                          // Support Options Card
                          _buildSupportOptionsCard(isDark),
                          const SizedBox(height: 32),

                          // Switch Account Action Button
                          AppButton(
                            text: 'تسجيل الدخول بحساب آخر',
                            onPressed: _switchAccount,
                            outlined: true,
                            height: 52,
                          ),
                          const SizedBox(height: 16),

                          // Footer Note
                          Text(
                            'رَوْنَقُك • منصة الأناقة الفاخرة',
                            textAlign: TextAlign.center,
                            style: AppTextTheme.cairo(
                              fontSize: 11.5,
                              color: isDark
                                  ? Colors.white30
                                  : const Color(0xFFB5A6AD),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanBadge(bool isDark) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Soft Glow Ring
          Container(
            width: 114,
            height: 114,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD32F2F).withValues(alpha: 0.08),
            ),
          ),
          // Intermediate Warning Ring
          Container(
            width: 94,
            height: 94,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD32F2F).withValues(alpha: 0.14),
              border: Border.all(
                color: const Color(0xFFD32F2F).withValues(alpha: 0.28),
                width: 1.5,
              ),
            ),
          ),
          // Inner Solid Badge
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE53935),
                  Color(0xFFB71C1C),
                  Color(0xFF560026),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB71C1C).withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.block_flipped,
              size: 38,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetailsPod({
    required String customerName,
    required String emailOrPhone,
    String? reason,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF21111B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFF0DFE5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: BrandColors.burgundy.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BrandColors.burgundy.withValues(alpha: 0.08),
                  border: Border.all(
                    color: BrandColors.burgundy.withValues(alpha: 0.2),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: BrandColors.burgundy,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: AppTextTheme.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark ? BrandColors.darkText : BrandColors.lightText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      emailOrPhone,
                      style: AppTextTheme.cairo(
                        fontSize: 12.5,
                        color: isDark ? Colors.white60 : const Color(0xFF7A6A73),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFD32F2F).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'محظور',
                  style: AppTextTheme.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD32F2F),
                  ),
                ),
              ),
            ],
          ),
          if (reason != null && reason.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3F3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFCDD2),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFC62828),
                    size: 17,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reason,
                      style: AppTextTheme.cairo(
                        fontSize: 12,
                        color: const Color(0xFFB71C1C),
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSupportOptionsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E0E18) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFECE4E8),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.support_agent_rounded,
                color: BrandColors.gold,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'هل تعتقد أن هناك خطأ؟',
                style: AppTextTheme.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? BrandColors.darkText : BrandColors.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'فريق خدمة عملاء رَوْنَقُك متاح على مدار الساعة لمراجعة حالة الحساب وحل أي لبس:',
            style: AppTextTheme.cairo(
              fontSize: 12.5,
              color: isDark ? Colors.white60 : const Color(0xFF7A6A73),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // WhatsApp Support Button
              Expanded(
                child: _buildContactActionTile(
                  icon: Icons.chat_bubble_rounded,
                  label: 'واتساب',
                  color: const Color(0xFF25D366),
                  onTap: _contactViaWhatsApp,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              // Email Support Button
              Expanded(
                child: _buildContactActionTile(
                  icon: Icons.email_rounded,
                  label: 'البريد',
                  color: BrandColors.burgundy,
                  onTap: _contactViaEmail,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextTheme.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
