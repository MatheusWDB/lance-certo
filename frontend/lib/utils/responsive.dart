import 'package:flutter/material.dart';

class Responsive {
  static const double sm = 576.0;
  static const double md = 768.0;
  static const double lg = 992.0;
  static const double xl = 1200.0;
  static const double xxl = 1400.0;

  static bool isExtraSmall(BuildContext context) =>
      MediaQuery.of(context).size.width < sm;

  static bool isSmall(BuildContext context) =>
      MediaQuery.of(context).size.width >= sm &&
      MediaQuery.of(context).size.width < md;

  static bool isMedium(BuildContext context) =>
      MediaQuery.of(context).size.width >= md &&
      MediaQuery.of(context).size.width < lg;

  static bool isLarge(BuildContext context) =>
      MediaQuery.of(context).size.width >= lg &&
      MediaQuery.of(context).size.width < xl;

  static bool isExtraLarge(BuildContext context) =>
      MediaQuery.of(context).size.width >= xl &&
      MediaQuery.of(context).size.width < xxl;

  static bool isExtraExtraLarge(BuildContext context) =>
      MediaQuery.of(context).size.width >= xxl;

  static T valueForBreakpoints<T>({
    required BuildContext context,
    required T xs,
    T? sm,
    T? md,
    T? lg,
    T? xl,
    T? xxl,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (xxl != null && width >= Responsive.xxl) {
      return xxl;
    }
    if (xl != null && width >= Responsive.xl) {
      return xl;
    }
    if (lg != null && width >= Responsive.lg) {
      return lg;
    }
    if (md != null && width >= Responsive.md) {
      return md;
    }
    if (sm != null && width >= Responsive.sm) {
      return sm;
    }

    return xs;
  }
}
