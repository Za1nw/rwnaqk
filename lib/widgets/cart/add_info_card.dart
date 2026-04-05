import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/common/app_action_icon_button.dart';

/// كرت يظهر عندما لا توجد بيانات (مثل عدم وجود عنوان شحن)
/// يعرض زر (+) لإضافة البيانات.
class AddInfoCard extends StatelessWidget {

  /// عنوان القسم (مثال: Shipping Address)
  final String title;

  /// يتم استدعاؤه عند الضغط على زر الإضافة
  final VoidCallback? onAdd;

  /// نص مساعد اختياري
  final String? hint;

  const AddInfoCard({
    super.key,
    required this.title,
    required this.onAdd,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.card,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: context.border.withOpacity(.35),
          ),
        ),
        child: Row(
          children: [

            /// النص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: TextStyle(
                      color: context.foreground,
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                    ),
                  ),

                  if (hint != null && hint!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      hint!,
                      style: TextStyle(
                        color: context.mutedForeground,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            /// زر الإضافة
            if (onAdd != null)
              AppActionIconButton(
                icon: Icons.add_rounded,
                onTap: onAdd!,
              ),
          ],
        ),
      ),
    );
  }
}