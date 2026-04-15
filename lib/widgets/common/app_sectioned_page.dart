import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/common/app_back_header.dart';

class AppSectionedPage extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  /// If both [trailing] and [trailingIcon] are null, trailing is hidden.
  final Widget? trailing;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;

  final EdgeInsetsGeometry padding;
  final List<Widget> children;

  const AppSectionedPage({
    super.key,
    required this.title,
    required this.onBack,
    this.trailing,
    this.trailingIcon,
    this.onTrailingTap,
    this.padding = const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 18),
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: ListView(
          padding: padding,
          children: [
            AppBackHeader(
              title: title,
              onBack: onBack,
              trailingIcon: trailingIcon ?? Icons.notifications_none_rounded,
              onTrailingTap: onTrailingTap,
              showTrailing: trailing != null || trailingIcon != null,
              trailing: trailing,
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

