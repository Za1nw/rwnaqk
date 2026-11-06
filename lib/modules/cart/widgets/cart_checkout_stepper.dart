import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';

/// شريط خطوات الشراء الفاخر (Checkout Stepper)
/// يعرض مراحل عملية الشراء (1. السلة -> 2. الدفع والشحن -> 3. التأكيد)
/// بتصميم عصري فائق الجمال يتناسب مع الهوية الملكية في الوضعين الليلي والنهاري.
class CartCheckoutStepper extends StatelessWidget {
  /// الخطوة الحالية: 1 = السلة، 2 = الدفع والشحن، 3 = التأكيد
  final int currentStep;

  const CartCheckoutStepper({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF24111F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? BrandColors.gold.withValues(alpha: 0.16)
              : const Color(0xFFEDE3EA),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Step 1: Cart
          _buildStepItem(
            stepNumber: 1,
            title: 'السلة',
            icon: Icons.shopping_bag_outlined,
            isCompleted: currentStep > 1,
            isActive: currentStep == 1,
            isDark: isDark,
          ),

          // Connector 1-2
          Expanded(
            child: _buildConnector(isPassed: currentStep > 1, isDark: isDark),
          ),

          // Step 2: Payment & Shipping
          _buildStepItem(
            stepNumber: 2,
            title: 'الشحن والدفع',
            icon: Icons.payment_rounded,
            isCompleted: currentStep > 2,
            isActive: currentStep == 2,
            isDark: isDark,
          ),

          // Connector 2-3
          Expanded(
            child: _buildConnector(isPassed: currentStep > 2, isDark: isDark),
          ),

          // Step 3: Confirmation
          _buildStepItem(
            stepNumber: 3,
            title: 'التأكيد',
            icon: Icons.check_circle_outline_rounded,
            isCompleted: currentStep > 3,
            isActive: currentStep == 3,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required int stepNumber,
    required String title,
    required IconData icon,
    required bool isCompleted,
    required bool isActive,
    required bool isDark,
  }) {
    Color circleBg;
    Color iconColor;
    Color textColor;
    FontWeight fontWeight;

    if (isCompleted) {
      circleBg = const Color(0xFF10B981);
      iconColor = Colors.white;
      textColor = isDark ? Colors.white70 : const Color(0xFF4A3443);
      fontWeight = FontWeight.w700;
    } else if (isActive) {
      circleBg = isDark ? BrandColors.gold : BrandColors.burgundy;
      iconColor = isDark ? const Color(0xFF1E0A17) : Colors.white;
      textColor = isDark ? BrandColors.gold : BrandColors.burgundy;
      fontWeight = FontWeight.w900;
    } else {
      circleBg = isDark
          ? Colors.white.withValues(alpha: 0.08)
          : const Color(0xFFF1E9EE);
      iconColor = isDark ? Colors.white38 : const Color(0xFFA5909E);
      textColor = isDark ? Colors.white38 : const Color(0xFFA5909E);
      fontWeight = FontWeight.w600;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: circleBg,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: (isDark ? BrandColors.gold : BrandColors.burgundy)
                          .withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : Icon(icon, color: iconColor, size: 16),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: fontWeight,
            fontFamily: 'Cairo',
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector({required bool isPassed, required bool isDark}) {
    return Container(
      height: 2.5,
      margin: const EdgeInsets.only(bottom: 16, left: 6, right: 6),
      decoration: BoxDecoration(
        color: isPassed
            ? const Color(0xFF10B981)
            : (isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : const Color(0xFFE5D8E0)),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}
