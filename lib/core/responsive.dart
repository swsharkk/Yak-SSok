import 'package:flutter/material.dart';

import 'theme.dart';

class AppResponsive {
  AppResponsive._();

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static bool isCompact(BuildContext context) => screenWidth(context) < 390;

  static EdgeInsets pagePadding(
    BuildContext context, {
    double top = AppDimensions.paddingXl,
    double bottom = AppDimensions.paddingXxl,
  }) {
    final horizontal =
        isCompact(context) ? AppDimensions.paddingLg : AppDimensions.paddingXl;

    return EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom);
  }

  static double logoWidth(BuildContext context) {
    final width = screenWidth(context);
    final reservedForAction = isCompact(context) ? 132.0 : 148.0;
    final available = (width - reservedForAction).clamp(132.0, 220.0);

    return available.toDouble();
  }

  static double logoHeight(BuildContext context) =>
      (logoWidth(context) * 0.2).clamp(32.0, 44.0).toDouble();

  static double headerLogoOffset(BuildContext context) =>
      isCompact(context) ? -8 : -14;
}
