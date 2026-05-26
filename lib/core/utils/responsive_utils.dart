import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import '../themes/app_themes.dart';

class ResponsiveUtils {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static bool isWindows() => Platform.isWindows;
  static bool isAndroid() => Platform.isAndroid;
  static bool isIOS() => Platform.isIOS;

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375.0; // Base width for scaling
    return baseSize * scaleFactor.clamp(0.8, 2.0);
  }

  static EdgeInsets getResponsivePadding(BuildContext context, {
    double mobileHorizontal = 16.0,
    double mobileVertical = 8.0,
    double tabletHorizontal = 24.0,
    double tabletVertical = 12.0,
    double desktopHorizontal = 32.0,
    double desktopVertical = 16.0,
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
    return baseSize * 1.4;
  }

  static int getResponsiveGridColumns(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 3;
    return 4;
  }

  static double getResponsiveCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = getResponsiveGridColumns(context);
    final totalPadding = 32.0; // Total horizontal padding
    final spacing = (columns - 1) * 16.0; // Spacing between cards

    return (screenWidth - totalPadding - spacing) / columns;
  }

  // Touch-friendly dimensions for mobile vs mouse-friendly for desktop
  static double getTouchTargetSize(BuildContext context) {
    return isMobile(context) ? 44.0 : 32.0;
  }

  // Adaptive spacing based on platform
  static double getPlatformSpacing(BuildContext context) {
    return isMobile(context) ? 8.0 : 12.0;
  }

  // Keyboard navigation support for desktop
  static bool supportsKeyboardNavigation() => isWindows() || Platform.isLinux || Platform.isMacOS;

  // Gesture detection settings
  static double getSwipeThreshold(BuildContext context) {
    return isMobile(context) ? 50.0 : 100.0;
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

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // Smooth theme transition animation
  static Widget buildThemeTransition({
    required BuildContext context,
    required Widget child,
    required AppThemeType fromTheme,
    required AppThemeType toTheme,
  }) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(
        begin: _getThemePrimaryColor(fromTheme),
        end: _getThemePrimaryColor(toTheme),
      ),
      duration: const Duration(milliseconds: 500),
      builder: (context, color, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: color,
            ),
          ),
          child: child!,
        );
      },
      child: child,
    );
  }

  static Color _getThemePrimaryColor(AppThemeType theme) {
    switch (theme) {
      case AppThemeType.midnight:
        return const Color(0xFF1F2937);
    }
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