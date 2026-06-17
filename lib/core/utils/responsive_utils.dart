import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import '../themes/app_themes.dart';
import 'package:flutter/cupertino.dart';

class ResponsiveUtils {
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

  static bool isWindows() => Platform.isWindows;
  static bool isAndroid() => Platform.isAndroid;
  static bool isIOS() => Platform.isIOS;
  static bool isMobilePlatform() => Platform.isAndroid || Platform.isIOS;

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375.0;
    return baseSize * scaleFactor.clamp(0.7, 2.2);
  }

  static EdgeInsets getResponsivePadding(BuildContext context, {
    double mobileHorizontal = 16.0,
    double mobileVertical = 8.0,
    double tabletHorizontal = 24.0,
    double tabletVertical = 12.0,
    double desktopHorizontal = 48.0,
    double desktopVertical = 24.0,
  }) {
    if (isMobile(context)) {
      return EdgeInsets.symmetric(horizontal: mobileHorizontal, vertical: mobileVertical);
    } else if (isTablet(context)) {
      return EdgeInsets.symmetric(horizontal: tabletHorizontal, vertical: tabletVertical);
    } else {
      return EdgeInsets.symmetric(horizontal: desktopHorizontal, vertical: desktopVertical);
    }
  }

  static double getResponsiveButtonHeight(BuildContext context) {
    if (isMobile(context)) return 48.0;
    if (isTablet(context)) return 56.0;
    return 64.0;
  }

  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    if (isMobile(context)) return baseSize;
    if (isTablet(context)) return baseSize * 1.2;
    return baseSize * 1.5;
  }

  static int getResponsiveGridColumns(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 3;
    return 4;
  }

  static double getResponsiveCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = getResponsiveGridColumns(context);
    final totalPadding = 32.0;
    final spacing = (columns - 1) * 16.0;

    return (screenWidth - totalPadding - spacing) / columns;
  }

  static double getTouchTargetSize(BuildContext context) {
    return isMobile(context) ? 48.0 : 32.0;
  }

  static double getPlatformSpacing(BuildContext context) {
    return isMobile(context) ? 8.0 : 12.0;
  }

  static bool supportsKeyboardNavigation() => isWindows() || Platform.isLinux || Platform.isMacOS;

  static double getSwipeThreshold(BuildContext context) {
    return isMobile(context) ? 50.0 : 100.0;
  }

  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static double getScreenWidth(BuildContext context) => MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) => MediaQuery.of(context).size.height;

  static double getPixelRatio(BuildContext context) => MediaQuery.of(context).devicePixelRatio;

  static bool isHighDensity(BuildContext context) => getPixelRatio(context) > 1.5;

  static Future<void> preloadAssets(BuildContext context) async {
    // Force GPU rasterization
    final binding = WidgetsBinding.instance;
    binding.addPostFrameCallback((_) {});
  }
}

class AdaptiveTheme {
  static ThemeData getAdaptiveTheme(BuildContext context, AppThemeType themeType) {
    final baseTheme = AppThemes.getTheme(themeType);

    return baseTheme.copyWith(
      textTheme: baseTheme.textTheme.copyWith(
        headlineSmall: baseTheme.textTheme.headlineSmall?.copyWith(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
        ),
        titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
        ),
        bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
        ),
        bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(
            double.infinity,
            ResponsiveUtils.getResponsiveButtonHeight(context),
          ),
          padding: ResponsiveUtils.getResponsivePadding(context),
        ),
      ),

      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static Widget buildOptimizedListView({
    required List<Widget> children,
    Axis scrollDirection = Axis.vertical,
    bool addAutomaticKeepAlives = true,
  }) {
    return ListView(
      scrollDirection: scrollDirection,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      children: children,
    );
  }

  static Widget buildOptimizedGridView({
    required int crossAxisCount,
    required double childAspectRatio,
    required List<Widget> children,
    double crossAxisSpacing = 16.0,
    double mainAxisSpacing = 16.0,
  }) {
    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      physics: const BouncingScrollPhysics(),
      children: children,
    );
  }
}

class PerformanceOptimizer {
  static const int maxCacheSize = 100;
  static final Map<String, dynamic> _cache = {};
  static final List<String> _cacheOrder = [];

  static T getCached<T>(String key, T Function() generator) {
    if (_cache.containsKey(key)) {
      // Move to end (most recently used)
      _cacheOrder.remove(key);
      _cacheOrder.add(key);
      return _cache[key] as T;
    }

    final value = generator();

    // Add to cache
    _cache[key] = value;
    _cacheOrder.add(key);

    // Maintain cache size
    if (_cacheOrder.length > maxCacheSize) {
      final oldestKey = _cacheOrder.removeAt(0);
      _cache.remove(oldestKey);
    }

    return value;
  }

  static void clearCache() {
    _cache.clear();
    _cacheOrder.clear();
  }

  static void preloadAssets(BuildContext context) {
    // Preload commonly used images and assets
    // This would be platform-specific implementation
  }
}