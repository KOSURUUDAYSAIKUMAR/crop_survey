import 'package:flutter/material.dart';

class CustomColors {
  CustomColors._();
  static const Color blue = Colors.blue;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
  static const Color red = Colors.red;
  static const Color green = Color(0xFF4CAF50);
  // static const Color yellow = Color(0xFFFFEB3B);
  // static const Color dashboardNavTitle = Color(0xFF3E7CA2);
  // static const Color farmSectionColor1 = Color(0xFFF6FBFF);
  // static const Color farmTimelineSubTextColor = Color(0xFF666666);
  // static const Color selectFarmBottomBar = Color(0xFF3E7CA2);
  // static const Color selectMarketBottomBar = Color(0xFFB09610);
  // static const Color selectWelfareBottomBar = Color(0xFF8A3FA1);
  // static Color errorColorTheme(BuildContext context) {
  //   return Theme.of(context).colorScheme.error;
  // }

  static Color greyShade(int shade) {
    if (shade >= 100 && shade <= 900 && shade % 100 == 0) {
      return Colors.grey[shade]!;
    }
    return Colors.grey;
  }

  static Color greenShade(int shade) {
    if (shade >= 100 && shade <= 900 && shade % 100 == 0) {
      return Colors.green[shade]!;
    }
    return Colors.green;
  }

  static Color redShade(int shade) {
    if (shade >= 100 && shade <= 900 && shade % 100 == 0) {
      return Colors.red[shade]!;
    }
    return Colors.red;
  }

  // static Color primaryColor(BuildContext context) {
  //   return Theme.of(context).primaryColor;
  // }

  // static Color primaryColorScheme(BuildContext context) {
  //   return Theme.of(context).colorScheme.primary;
  // }

  // static Color primaryColorTheme(ThemeData theme) {
  //   return theme.colorScheme.primary;
  // }

  // static Color secondaryColorScheme(BuildContext context) {
  //   return Theme.of(context).colorScheme.secondary;
  // }

  // static Color blueWithOpacity(double opacity) {
  //   assert(opacity >= 0 && opacity <= 1);
  //   int alpha = (255 * opacity).round();
  //   return blue.withAlpha(alpha);
  // }

  static Color whiteWithOpacity(double opacity) {
    assert(opacity >= 0 && opacity <= 1);
    int alpha = (255 * opacity).round();
    return white.withAlpha(alpha);
  }

  // static Color primaryColorWithOpacity(BuildContext context, double opacity) {
  //   assert(opacity >= 0 && opacity <= 1);
  //   int alpha = (255 * opacity).round();
  //   return primaryColor(context).withAlpha(alpha);
  // }

  static Color blackWithOpacity(double opacity) {
    assert(opacity >= 0 && opacity <= 1);
    int alpha = (255 * opacity).round();
    return black.withAlpha(alpha);
  }

  // static Color primaryColorSchemeWithOpacity(
  //     BuildContext context, double opacity) {
  //   assert(opacity >= 0 && opacity <= 1);
  //   int alpha = (255 * opacity).round();
  //   return primaryColorScheme(context).withAlpha(alpha);
  // }

  // static Color inputColorWithOpacity(Color color, double opacity) {
  //   assert(opacity >= 0 && opacity <= 1);
  //   int alpha = (255 * opacity).round();
  //   return color.withAlpha(alpha);
  // }

  // static Color greyWithOpacity(double opacity) {
  //   assert(opacity >= 0 && opacity <= 1);
  //   int alpha = (255 * opacity).round();
  //   return grey.withAlpha(alpha);
  // }

  // static Color primaryColorThemeWithOpacity(ThemeData theme, double opacity) {
  //   assert(opacity >= 0 && opacity <= 1);
  //   int alpha = (255 * opacity).round();
  //   return theme.colorScheme.primary.withAlpha(alpha);
  // }
}
