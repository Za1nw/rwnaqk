import 'package:flutter/material.dart';

import '../app_toggles.dart';

/// هيكل موحّد لصفحات النماذج الطويلة (تسجيل الدخول / إنشاء حساب).
/// يحافظ على نفس السلوك الحالي: قابل للتمرير + ارتفاع أدنى للشاشة + أزرار التبديل أعلى اليمين.
class AuthFormPageLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry pagePadding;
  final double maxContentWidth;
  final bool showToggles;

  const AuthFormPageLayout({
    super.key,
    required this.child,
    this.pagePadding = const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
    this.maxContentWidth = 520,
    this.showToggles = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth > maxContentWidth
            ? maxContentWidth
            : constraints.maxWidth;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Stack(
              children: [
                if (showToggles)
                  const PositionedDirectional(
                    top: 14,
                    end: 14,
                    child: AppToggles(),
                  ),
                Center(
                  child: Padding(
                    padding: pagePadding,
                    child: SizedBox(
                      width: contentWidth,
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
