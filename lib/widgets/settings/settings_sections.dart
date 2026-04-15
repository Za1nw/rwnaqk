import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/common/app_section_header.dart';
import 'package:rwnaqk/widgets/settings/settings_list_tile.dart';

class SettingsTileSpec {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  final Widget? trailing;
  final double? trailingMaxWidth;
  final bool tapWholeTile;
  final bool showChevron;

  const SettingsTileSpec({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.trailingMaxWidth,
    this.tapWholeTile = true,
    this.showChevron = true,
  });
}

class SettingsSectionSpec {
  final String title;
  final List<SettingsTileSpec> tiles;

  const SettingsSectionSpec({
    required this.title,
    required this.tiles,
  });
}

class SettingsSections extends StatelessWidget {
  final List<SettingsSectionSpec> sections;
  final double sectionTitleSize;
  final double tileGap;
  final double sectionGap;

  const SettingsSections({
    super.key,
    required this.sections,
    this.sectionTitleSize = 12.5,
    this.tileGap = 10,
    this.sectionGap = 18,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    for (var i = 0; i < sections.length; i++) {
      final s = sections[i];
      children.add(
        AppSectionHeader(
          title: s.title,
          titleFontSize: sectionTitleSize,
          titleColor: context.muted,
        ),
      );
      children.add(SizedBox(height: tileGap));

      for (var j = 0; j < s.tiles.length; j++) {
        final t = s.tiles[j];
        children.add(
          SettingsListTile(
            icon: t.icon,
            title: t.title,
            subtitle: t.subtitle ?? '',
            onTap: t.onTap,
            trailing: t.trailing,
            trailingMaxWidth: t.trailingMaxWidth ?? 160,
            tapWholeTile: t.tapWholeTile,
            showChevron: t.showChevron,
          ),
        );
        if (j != s.tiles.length - 1) {
          children.add(SizedBox(height: tileGap));
        }
      }

      if (i != sections.length - 1) {
        children.add(SizedBox(height: sectionGap));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
