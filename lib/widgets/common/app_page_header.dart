import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/common/app_action_icon_button.dart';

class AppPageHeader extends StatelessWidget {
  static const double _height = 40;

  final String title;
  final String? info;
  final VoidCallback? onNotificationTap;
  final IconData notificationIcon;

  const AppPageHeader({
    super.key,
    required this.title,
    this.info,
    this.onNotificationTap,
    this.notificationIcon = Icons.notifications_none_rounded,
  });

  bool get _hasInfo => info != null && info!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final compact = constraints.maxWidth < 360;

        return SizedBox(
          height: _height,
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.foreground,
                            fontSize: compact ? 20 : 22,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                          ),
                        ),
                      ),
                      if (_hasInfo) ...[
                        SizedBox(width: compact ? 8 : 10),
                        Container(
                          padding: EdgeInsetsDirectional.symmetric(
                            horizontal: compact ? 8 : 10,
                            vertical: compact ? 3 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.primary.withOpacity(.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: context.primary.withOpacity(.22),
                            ),
                          ),
                          child: Text(
                            info!.trim(),
                            maxLines: 1,
                            style: TextStyle(
                              color: context.primary,
                              fontSize: compact ? 12.5 : 13.5,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              AppActionIconButton(
                icon: notificationIcon,
                onTap: onNotificationTap ?? () {},
                backgroundColor: context.card,
                iconColor: context.foreground,
                borderColor: context.border.withOpacity(.35),
                size: _height,
                radius: 14,
              ),
            ],
          ),
        );
      },
    );
  }
}
