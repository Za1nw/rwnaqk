import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class AppDialogShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final EdgeInsetsGeometry? contentPadding;
  final bool showCloseButton;
  final double maxWidth;

  const AppDialogShell({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.contentPadding,
    this.showCloseButton = true,
    this.maxWidth = 420,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.border.withOpacity(.22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.18),
                offset: const Offset(0, 16),
                blurRadius: 32,
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding:
                contentPadding ?? const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.tr,
                            style: TextStyle(
                              color: context.foreground,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                          if ((subtitle ?? '').trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle!.tr,
                              style: TextStyle(
                                color: context.muted,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (showCloseButton)
                      InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: Get.back,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.close_rounded,
                            color: context.muted,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}