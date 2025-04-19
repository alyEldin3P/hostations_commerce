import 'package:flutter/material.dart';

class AppPadding {
  static EdgeInsets horizontalPadding(double value) {
    return EdgeInsets.symmetric(horizontal: value);
  }

  static EdgeInsets verticalPadding(double value) {
    return EdgeInsets.symmetric(vertical: value);
  }

  static EdgeInsets symmetricPadding(double horizontal, double vertical) {
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  static EdgeInsets allPadding(double value) {
    return EdgeInsets.all(value);
  }

  // Common padding values
  static const EdgeInsets paddingS = EdgeInsets.all(8);
  static const EdgeInsets paddingM = EdgeInsets.all(16);
  static const EdgeInsets paddingL = EdgeInsets.all(24);
  static const EdgeInsets paddingXL = EdgeInsets.all(32);
}
