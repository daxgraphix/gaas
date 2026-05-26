import 'package:flutter/material.dart';

class ResponsiveDesign {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;
  static const double desktopBreakpoint = 1920;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  static double getMaxWidth(BuildContext context) {
    if (isLargeDesktop(context)) return 1600;
    if (isDesktop(context)) return 1200;
    if (isTablet(context)) return 800;
    return double.infinity;
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 32);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }

  static double getCardWidth(BuildContext context) {
    if (isDesktop(context)) return 400;
    if (isTablet(context)) return 350;
    return double.infinity;
  }

  static int getGridCrossAxisCount(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  static double getAppBarHeight(BuildContext context) {
    return isDesktop(context) ? 64 : 56;
  }

  static double getFontSize(BuildContext context, double mobileSize) {
    if (isDesktop(context)) return mobileSize * 1.2;
    if (isTablet(context)) return mobileSize * 1.1;
    return mobileSize;
  }

  static Size getButtonSize(BuildContext context) {
    if (isDesktop(context)) return const Size(200, 56);
    if (isTablet(context)) return const Size(180, 52);
    return const Size(160, 48);
  }

  static double getIconSize(BuildContext context, double mobileSize) {
    if (isDesktop(context)) return mobileSize * 1.3;
    if (isTablet(context)) return mobileSize * 1.2;
    return mobileSize;
  }
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget? tabletLayout;
  final Widget? desktopLayout;

  const ResponsiveLayout({
    super.key,
    required this.mobileLayout,
    this.tabletLayout,
    this.desktopLayout,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveDesign.isDesktop(context) && desktopLayout != null) {
      return desktopLayout!;
    }
    if (ResponsiveDesign.isTablet(context) && tabletLayout != null) {
      return tabletLayout!;
    }
    return mobileLayout;
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? ResponsiveDesign.getScreenPadding(context),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? ResponsiveDesign.getMaxWidth(context),
          ),
          child: child,
        ),
      ),
    );
  }
}