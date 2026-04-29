import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class WalletActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const WalletActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          height: 104,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.border.withValues(alpha: .35)),
            boxShadow: [
              BoxShadow(
                color: context.shadow.withValues(alpha: .05),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: .10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: context.primary,
                  size: 20,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.foreground,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.5,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}