import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class SettingsProfileCard extends StatelessWidget {
  final String name;
  final String phone;
  final VoidCallback onEdit;

  const SettingsProfileCard({
    super.key,
    required this.name,
    required this.phone,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: context.border.withOpacity(.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: context.input,
                shape: BoxShape.circle,
                border: Border.all(color: context.border.withOpacity(.35)),
              ),
              child: Icon(
                Icons.person_rounded,
                color: context.foreground,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.foreground,
                      fontWeight: FontWeight.w900,
                      fontSize: 15.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: Colors.transparent,
              child: Ink(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: context.input,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.border.withOpacity(.35)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: onEdit,
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: context.foreground,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Edit'.tr,
                        style: TextStyle(
                          color: context.foreground,
                          fontWeight: FontWeight.w900,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}