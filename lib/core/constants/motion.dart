import 'package:flutter/animation.dart';

/// Motion system constants for consistent animations across the app
/// Following Material Design motion guidelines
class AppMotion {
  AppMotion._(); // Private constructor to prevent instantiation

  // Duration constants
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 600);
  static const Duration longTransition = Duration(milliseconds: 800);

  // Easing curves
  static const Curve easing = Curves.easeInOutCubic;
  static const Curve easingDecelerate = Curves.easeOut;
  static const Curve easingAccelerate = Curves.easeIn;
  static const Curve easingStandard = Curves.easeInOut;

  // Specific animation durations
  static const Duration buttonPress = Duration(milliseconds: 100);
  static const Duration cardExpand = Duration(milliseconds: 300);
  static const Duration dialogFade = Duration(milliseconds: 250);
  static const Duration snackbarSlide = Duration(milliseconds: 350);
  static const Duration shimmer = Duration(milliseconds: 1500);
  static const Duration successAnimation = Duration(milliseconds: 500);
  static const Duration errorShake = Duration(milliseconds: 400);

  // Debounce durations
  static const Duration searchDebounce = Duration(milliseconds: 300);
  static const Duration scrollDebounce = Duration(milliseconds: 100);

  // Animation values
  static const double scalePressed = 0.95;
  static const double scaleNormal = 1.0;
  static const double fadeOut = 0.0;
  static const double fadeIn = 1.0;

  // Slide offsets
  static const Offset slideFromBottom = Offset(0, 0.1);
  static const Offset slideFromRight = Offset(0.1, 0);
  static const Offset slideFromLeft = Offset(-0.1, 0);
  static const Offset slideCenter = Offset.zero;
}
