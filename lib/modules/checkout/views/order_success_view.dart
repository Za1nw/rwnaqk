import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/utils/app_money_utils.dart';
import 'package:rwnaqk_frontend/core/widgets/feedback/app_toast.dart';
import 'package:rwnaqk_frontend/modules/home/providers/home_providers.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

/// شاشة نجاح الطلب الفاخرة (Order Success Screen)
///
/// تجربة استلام احتفالية راقية تعرض رقم الطلب وملخص الفاتورة
/// وتوفر وصولاً سهلاً لتتبع مسار الطلب أو العودة لمتابعة التسوق.
class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  OrderModel? _order;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is OrderModel) {
        setState(() => _order = args);
      }
    });

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _copyOrderId(String orderId) {
    Clipboard.setData(ClipboardData(text: orderId));
    AppToast.copied(
      message: 'تم نسخ رقم الطلب $orderId إلى الحافظة بنجاح',
      title: 'تم النسخ',
    );
  }

  void _goToHome() {
    try {
      globalProviderContainer.read(mainNavigationProvider.notifier).changeTab(0);
    } catch (_) {}
    AppNav.offAllNamed(AppRoutes.main);
  }

  void _goToTracking() {
    if (_order != null) {
      AppNav.toNamed(AppRoutes.orderTracking, arguments: _order);
    } else {
      AppNav.offAllNamed(AppRoutes.orders);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final order = _order;
    final orderId = order?.id ?? '#ORD-994201';
    final total = order?.total ?? 0.0;
    final paymentMethod =
        order?.details?.paymentMethod ?? 'الدفع نقداً عند الاستلام';
    final address = order?.addressLine ?? 'صنعاء، اليمن';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _goToHome();
        }
      },
      child: Scaffold(
        backgroundColor: context.background,
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E0D1A) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? BrandColors.gold.withValues(alpha: 0.12)
                      : const Color(0xFFEBE0E6),
                  width: 1.0,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Primary Action: Track Order
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _goToTracking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: context.primary.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.local_shipping_outlined, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'تتبع مسار الشحنة 📦',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Secondary Action: Continue Shopping
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _goToHome,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.foreground,
                      side: BorderSide(
                        color: context.border.withValues(alpha: 0.45),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.storefront_outlined,
                          size: 19,
                          color: context.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'متابعة التسوق والعودة للرئيسية 🛍️',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: context.foreground,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                // Animated Success Checkmark
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981)
                              .withValues(alpha: 0.35),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 54,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Main Heading
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'تم استلام طلبك بنجاح! 🎉',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.foreground,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          fontFamily: 'Cairo',
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'شكراً لاختيارك رَوْنَقُك، تم تأكيد طلبك وجاري تحضيره وتغليفه الفاخر فوراً.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.mutedForeground,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Cairo',
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Order Number Pill with Copy Action
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF24111F)
                        : const Color(0xFFF9F3F6),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: BrandColors.gold.withValues(alpha: 0.45),
                      width: 1.1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'رقم الطلب:',
                        style: TextStyle(
                          color: context.mutedForeground,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        orderId,
                        style: TextStyle(
                          color: isDark
                              ? BrandColors.gold
                              : BrandColors.burgundy,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _copyOrderId(orderId),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.copy_rounded,
                            size: 15,
                            color: isDark
                                ? BrandColors.gold
                                : BrandColors.burgundy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Executive Receipt Card
                Container(
                  decoration: BoxDecoration(
                    color: context.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: context.border.withValues(alpha: 0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.shadow.withValues(
                          alpha: isDark ? 0.16 : 0.05,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.receipt_rounded,
                            size: 18,
                            color: context.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'تفاصيل الفاتورة السريعة',
                            style: TextStyle(
                              color: context.foreground,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'قيد التجهيز',
                              style: TextStyle(
                                color: Color(0xFF059669),
                                fontWeight: FontWeight.w800,
                                fontSize: 10.5,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),
                      Divider(
                        height: 1,
                        color: context.border.withValues(alpha: 0.25),
                      ),
                      const SizedBox(height: 14),

                      _ReceiptRow(
                        label: 'المبلغ الإجمالي:',
                        value: AppMoneyUtils.riyal(total),
                        isEmphasized: true,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 10),

                      _ReceiptRow(
                        label: 'طريقة الدفع:',
                        value: paymentMethod,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 10),

                      _ReceiptRow(
                        label: 'وجهة التوصيل:',
                        value: address,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 10),

                      _ReceiptRow(
                        label: 'المدة المقدرة للتوصيل:',
                        value: 'خلال 24 إلى 48 ساعة',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Next Steps Visual Roadmap
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF24111F)
                        : const Color(0xFFFCF9FB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? BrandColors.gold.withValues(alpha: 0.16)
                          : const Color(0xFFEDE3EA),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ماذا يحدث بعد ذلك؟',
                        style: TextStyle(
                          color: context.foreground,
                          fontWeight: FontWeight.w900,
                          fontSize: 13.5,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _StepProgressTile(
                        number: '1',
                        title: 'تم استلام وتأكيد الطلب بنجاح',
                        subtitle: 'تم التحقق من بياناتك وتسجيلها في النظام',
                        isCompleted: true,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _StepProgressTile(
                        number: '2',
                        title: 'جاري التجهيز والتغليف الملكي الفاخر',
                        subtitle: 'يتم الآن تحضير وفحص المنتجات بعناية فائقة',
                        isActive: true,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _StepProgressTile(
                        number: '3',
                        title: 'خروج الشحنة مع مندوب التوصيل',
                        subtitle:
                            'سيتواصل معك المندوب هاتفياً لتنسيق موعد الاستلام',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isEmphasized;
  final bool isDark;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.isEmphasized = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.mutedForeground,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Cairo',
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: isEmphasized
                  ? (isDark ? BrandColors.gold : BrandColors.burgundy)
                  : context.foreground,
              fontSize: isEmphasized ? 15 : 12.5,
              fontWeight: isEmphasized ? FontWeight.w900 : FontWeight.w800,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ],
    );
  }
}

class _StepProgressTile extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;
  final bool isDark;

  const _StepProgressTile({
    required this.number,
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    this.isActive = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final circleColor = isCompleted
        ? const Color(0xFF10B981)
        : (isActive
              ? (isDark ? BrandColors.gold : BrandColors.burgundy)
              : context.border.withValues(alpha: 0.5));

    final circleText = isCompleted ? '✓' : number;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
          child: Center(
            child: Text(
              circleText,
              style: TextStyle(
                color: (isActive && isDark)
                    ? const Color(0xFF1E0A17)
                    : Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                fontFamily: 'Cairo',
                height: 1.0,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isCompleted || isActive
                      ? context.foreground
                      : context.mutedForeground,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: context.mutedForeground,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Cairo',
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
