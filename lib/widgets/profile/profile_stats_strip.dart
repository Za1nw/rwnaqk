import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/profile/profile_service.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class ProfileStatsStrip extends StatelessWidget {
  final List<ProfileStatsItem> items;

  const ProfileStatsStrip({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Container(
                margin: EdgeInsetsDirectional.only(
                  end: item == items.last ? 0 : 10,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: context.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: context.border.withOpacity(.35)),
                ),
                child: Column(
                  children: [
                    Text(
                      item.value,
                      style: TextStyle(
                        color: context.foreground,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.labelKey.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.mutedForeground,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
