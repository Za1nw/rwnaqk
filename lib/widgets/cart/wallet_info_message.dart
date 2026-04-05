import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class WalletInfoMessage extends StatelessWidget {
  final IconData icon;
  final String text;

  const WalletInfoMessage({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: context.muted.withOpacity(context.isDark ? .18 : .28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.border.withOpacity(.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.card,
              border: Border.all(color: context.border.withOpacity(.35)),
            ),
            child: Icon(icon, size: 16, color: context.mutedForeground),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: context.mutedForeground,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}