import 'package:flutter/material.dart';

class CustomColors {
  CustomColors._();
  static const Color blue = Color(0xFF2196F3);
  static const Color white = Color(0xFFFFFFFF);
  static Color blueWithOpacity(double opacity) {
    assert(opacity >= 0 && opacity <= 1); // Ensure opacity is in valid range
    int alpha = (255 * opacity).round(); // Convert opacity to alpha (0-255)
    return blue.withAlpha(alpha);
  }

  static Color whiteWithOpacity(double opacity) {
    assert(opacity >= 0 && opacity <= 1); // Ensure opacity is in valid range
    int alpha = (255 * opacity).round(); // Convert opacity to alpha (0-255)
    return white.withAlpha(alpha);
  }
}
