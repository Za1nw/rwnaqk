import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class AppPageHeader extends StatelessWidget {
  final String title;
  final int? count;
  final VoidCallback? onNotificationsTap;
  final IconData notificationsIcon;

  const AppPageHeader({
    super.key,
    required this.title,
    this.count,
    this.onNotificationsTap,
    this.notificationsIcon = Icons.notifications_none_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final compact = c.maxWidth < 360;
        final titleSize = compact ? 22.0 : 26.0;
        final badgeFont = compact ? 12.5 : 13.5;

        final showCount = (count ?? 0) > 0;

        return Row(
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w900,
                        color: context.foreground,
                        height: 1.05,
                      ),
                    ),
                  ),
                  if (showCount) ...[
                    const SizedBox(width: 10),
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
                        '${count ?? 0}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: badgeFont,
                          color: context.primary,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            _HeaderIconButton(
              icon: notificationsIcon,
              onTap: onNotificationsTap,
            ),
          ],
        );
      },
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Notifications',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: context.primary.withOpacity(.08),
          highlightColor: Colors.transparent,
          child: Ink(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: context.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: context.border.withOpacity(.35),
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: context.foreground,
            ),
          ),
        ),
      ),
    );
  }
}
