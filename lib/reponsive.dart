import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
  static bool isMediumScreen(BuildContext context) => MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;
  static bool isLargeScreen(BuildContext context) => MediaQuery.of(context).size.width >= 1200;

  static double getFontSize(BuildContext context, double baseSize) {
    if (isMobile(context)) {
      return baseSize * 0.8;
    }
    return baseSize;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, rains) {
        if (rains.maxWidth <= 600) {
          return mobile;
        } else {
          return desktop;
        }
      },
    );
  }
}
