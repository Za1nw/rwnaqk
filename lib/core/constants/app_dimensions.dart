import 'package:flutter/material.dart';

/// Centralized UI dimensions, 8/16/24 spacing scale, and 390x844 viewport specifications.
class AppDimensions {
  AppDimensions._();

  // Design Viewport (Figma Standard: 390 x 844)
  static const double designScreenWidth = 390.0;
  static const double designScreenHeight = 844.0;

  // Spacing Scale: 8 / 16 / 24
  static const double space8 = 8.0;
  static const double space16 = 16.0;
  static const double space24 = 24.0;

  // Supplementary Spacings based on 8pt grid
  static const double space4 = 4.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;

  // Typography Size Scale: 10 - 44
  static const double font10 = 10.0;
  static const double font12 = 12.0;
  static const double font14 = 14.0;
  static const double font16 = 16.0;
  static const double font18 = 18.0;
  static const double font20 = 20.0;
  static const double font24 = 24.0;
  static const double font28 = 28.0;
  static const double font32 = 32.0;
  static const double font36 = 36.0;
  static const double font44 = 44.0;

  // Border Radii
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius24 = 24.0;
  static const double radiusFull = 999.0;

  // Sized Box Gap Shortcuts
  static const SizedBox gap8 = SizedBox(width: space8, height: space8);
  static const SizedBox gap16 = SizedBox(width: space16, height: space16);
  static const SizedBox gap24 = SizedBox(width: space24, height: space24);
  static const SizedBox gap32 = SizedBox(width: space32, height: space32);

  // Vertical Gaps
  static const SizedBox gapV8 = SizedBox(height: space8);
  static const SizedBox gapV16 = SizedBox(height: space16);
  static const SizedBox gapV24 = SizedBox(height: space24);
  static const SizedBox gapV32 = SizedBox(height: space32);

  // Horizontal Gaps
  static const SizedBox gapH8 = SizedBox(width: space8);
  static const SizedBox gapH16 = SizedBox(width: space16);
  static const SizedBox gapH24 = SizedBox(width: space24);

  // Padding Presets
  static const EdgeInsets padding8 = EdgeInsets.all(space8);
  static const EdgeInsets padding16 = EdgeInsets.all(space16);
  static const EdgeInsets padding24 = EdgeInsets.all(space24);

  static const EdgeInsets paddingH16 = EdgeInsets.symmetric(horizontal: space16);
  static const EdgeInsets paddingH24 = EdgeInsets.symmetric(horizontal: space24);

  static const EdgeInsets paddingV8 = EdgeInsets.symmetric(vertical: space8);
  static const EdgeInsets paddingV16 = EdgeInsets.symmetric(vertical: space16);
  static const EdgeInsets paddingV24 = EdgeInsets.symmetric(vertical: space24);
}

