import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum AppThemeType { midnight }

class AppDesignTokens {
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 32.0;
  static const double radiusCircle = 100.0;

  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 400);
  static const Duration animationSlow = Duration(milliseconds: 600);

  // Modern Professional Dark Palette (Onyx & Slate)
  static const Color primary = Color(0xFF6366F1); // Indigo 500
  static const Color secondary = Color(0xFF38BDF8); // Sky 400
  static const Color accent = Color(0xFFF43F5E); // Rose 500
  static const Color background = Color(0xFF030712); // Gray 950 (Deep Obsidian)
  static const Color surface = Color(0xFF111827); // Gray 900
  static const Color surfaceLighter = Color(0xFF1F2937); // Gray 800
  
  static const Color textPrimary = Color(0xFFF8FAFC); // Gray 50
  static const Color textSecondary = Color(0xFF94A3B8); // Gray 400
  static const Color textMuted = Color(0xFF475569); // Gray 600

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Legacy compatibility for refactoring
  static const Color techBlack = Color(0xFF030712);
  static const Color neonYellow = Color(0xFFF59E0B);
  static const Color neonPink = Color(0xFFF43F5E);
  static const Color neonGreen = Color(0xFF10B981);
  static const Color brightBlue = Color(0xFF38BDF8);
  static const Color neonOrange = Color(0xFFF59E0B);
  static const Color neonPurple = Color(0xFF6366F1);
  static const Color neonCyan = Color(0xFF06B6D4);
  static const Color techGrey = Color(0xFF1E293B);

  static const Color surfaceVariant = Color(0xFF334155);
  static const Color outlineVariant = Color(0xFF475569);
  static const Color shadowColor = Color(0xFF000000);
  static const Color successLight = Color(0xFFBBF7D0);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color errorLight = Color(0xFFFECACA);
}

class Material3Tokens {
  static const double frostedBlur = 12.0;
  static const double frostedOpacity = 0.6;
  static const double springDamping = 0.7;
  static const double springStiffness = 400.0;
}

class AppThemes {
  static ThemeData getTheme(AppThemeType type) {
    switch (type) {
      case AppThemeType.midnight:
        return _darkOnyxTheme;
    }
  }

  static final ThemeData _darkOnyxTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppDesignTokens.primary,
      brightness: Brightness.dark,
      primary: AppDesignTokens.primary,
      onPrimary: Colors.white,
      secondary: AppDesignTokens.secondary,
      onSecondary: Colors.white,
      surface: AppDesignTokens.surface,
      onSurface: AppDesignTokens.textPrimary,
      surfaceContainerHighest: AppDesignTokens.surfaceLighter,
      error: AppDesignTokens.error,
      outline: AppDesignTokens.textMuted.withValues(alpha: 0.2),
    ),
    scaffoldBackgroundColor: AppDesignTokens.background,
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppDesignTokens.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: AppDesignTokens.textPrimary,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppDesignTokens.textPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppDesignTokens.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        minimumSize: const Size(0, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppDesignTokens.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        minimumSize: const Size(0, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
        ),
        side: BorderSide(color: AppDesignTokens.primary.withValues(alpha: 0.5), width: 1.5),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppDesignTokens.surfaceLighter.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
        borderSide: const BorderSide(color: AppDesignTokens.primary, width: 2),
      ),
      hintStyle: const TextStyle(color: AppDesignTokens.textMuted),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: AppDesignTokens.surface,
      indicatorColor: AppDesignTokens.primary.withValues(alpha: 0.15),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppDesignTokens.primary : AppDesignTokens.textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: isSelected ? AppDesignTokens.primary : AppDesignTokens.textSecondary,
          size: 24,
        );
      }),
    ),
    textTheme: _buildTextTheme(
      AppDesignTokens.textPrimary,
      AppDesignTokens.textSecondary,
    ),
  );




  static TextTheme _buildTextTheme(Color primaryColor, Color secondaryColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: primaryColor,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: primaryColor,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: primaryColor,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: primaryColor,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: primaryColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: secondaryColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: secondaryColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: secondaryColor,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: primaryColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: secondaryColor,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: secondaryColor,
      ),
    );
  }

  static String getThemeName(AppThemeType type) {
    switch (type) {
      case AppThemeType.midnight:
        return 'Midnight';
    }
  }

  static String getThemeDescription(AppThemeType type) {
    switch (type) {
      case AppThemeType.midnight:
        return 'Dark & Sleek';
    }
  }

  static IconData getThemeIcon(AppThemeType type) {
    switch (type) {
      case AppThemeType.midnight:
        return Icons.dark_mode;
    }
  }

  static Color getThemeColor(AppThemeType type) {
    switch (type) {
      case AppThemeType.midnight:
        return const Color(0xFF8B5CF6);
    }
  }
}

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final double opacity;
  final bool useFrostedEffect;
  final bool overflowProtected;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 24,
    this.backgroundColor,
    this.opacity = 0.1,
    this.useFrostedEffect = false,
    this.overflowProtected = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final containerChild = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color:
            backgroundColor ??
            (isDark
                ? Colors.white.withValues(alpha: opacity)
                : theme.colorScheme.surface.withValues(alpha: 0.9)),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.2)
              : theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
      ),
    );

    Widget result = overflowProtected
        ? SingleChildScrollView(
            clipBehavior: Clip.hardEdge,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedWidthBox(child: containerChild),
          )
        : containerChild;

    if (useFrostedEffect) {
      result = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: Material3Tokens.frostedBlur,
            sigmaY: Material3Tokens.frostedBlur,
          ),
          child: containerChild,
        ),
      );
    }

    return result;
  }
}

class PremiumGlassOverlay extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const PremiumGlassOverlay({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: Material3Tokens.frostedBlur,
          sigmaY: Material3Tokens.frostedBlur,
        ),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0.05),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.95),
                      Color(0xFFF0FDFA).withValues(alpha: 0.8), // Light mint
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Color(0xFFE0F2FE).withValues(alpha: 0.6), // Light blue
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final List<Color> colors;
  final double? width;
  final double height;
  final bool isLoading;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.colors = const [Color(0xFF0EA5E9), Color(0xFF10B981)], // Sky blue to fresh green
    this.width,
    this.height = 56,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusLarge),
          child: Center(
            child: isLoading
                ? const GlowRingProgress(
                    size: 24,
                    strokeWidth: 2,
                    color: Colors.white,
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class PremiumAnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const PremiumAnimatedButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.borderRadius = 16,
  });

  @override
  State<PremiumAnimatedButton> createState() => _PremiumAnimatedButtonState();
}

class _PremiumAnimatedButtonState extends State<PremiumAnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child:
          AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                padding: widget.padding,
                decoration: BoxDecoration(
                  color:
                      widget.backgroundColor ??
                      (isDark
                          ? theme.colorScheme.primary.withValues(alpha: 0.2)
                          : theme.colorScheme.primary.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: widget.borderColor ?? theme.colorScheme.primary,
                    width: widget.borderWidth,
                  ),
                  boxShadow: _isPressed
                      ? []
                      : [
                          BoxShadow(
                            color:
                                (widget.borderColor ??
                                        theme.colorScheme.primary)
                                    .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                transform: _isPressed
                    ? (Matrix4.identity()..setEntry(0, 0, 0.95))
                    : Matrix4.identity(),
                transformAlignment: Alignment.center,
                child: widget.child,
              )
              .animate(target: _isPressed ? 1 : 0)
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(0.95, 0.95),
                duration: 150.ms,
                curve: Curves.easeOutBack,
              )
              .animate(target: _isPressed ? 1 : 0)
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.elasticOut,
              ),
    );
  }
}

class PremiumPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const PremiumPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PremiumAnimatedButton(
      onPressed: isLoading ? () {} : onPressed,
      backgroundColor: theme.colorScheme.primary,
      borderColor: theme.colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      borderRadius: 16,
      child: Center(
        child: isLoading
            ? const GlowRingProgress(
                size: 24,
                strokeWidth: 2.5,
                color: Colors.white,
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: theme.colorScheme.onPrimary, size: 22),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class PremiumCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? borderColor;
  final bool overflowProtected;

  const PremiumCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.borderColor,
    this.overflowProtected = true,
  });

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap!();
            }
          : null,
      onTapCancel: widget.onTap != null
          ? () => setState(() => _isPressed = false)
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Container(
              margin: widget.margin,
              padding: widget.padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surface.withValues(alpha: 0.8)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color:
                      widget.borderColor ??
                      (isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : theme.colorScheme.outline.withValues(alpha: 0.3)),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDark ? 0.3 : 0.08,
                    ),
                    blurRadius: _isPressed ? 5 : 16,
                    offset: Offset(0, _isPressed ? 2 : 6),
                  ),
                ],
              ),
              child: widget.overflowProtected
                  ? SingleChildScrollView(
                      clipBehavior: Clip.hardEdge,
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedWidthBox(child: widget.child),
                    )
                  : widget.child,
            )
            .animate(target: _isPressed ? 1 : 0)
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(0.98, 0.98),
              duration: 100.ms,
              curve: Curves.easeOut,
            ),
      ),
    );
  }
}

class ConstrainedWidthBox extends StatelessWidget {
  final Widget child;
  const ConstrainedWidthBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
      ),
      child: child,
    );
  }
}

class GlowRingProgress extends StatelessWidget {
  final double? value;
  final Color? color;
  final double strokeWidth;
  final double size;

  const GlowRingProgress({
    super.key,
    this.value,
    this.color,
    this.strokeWidth = 3.0,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ringColor = color ?? theme.colorScheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: strokeWidth,
            color: ringColor.withValues(alpha: 0.1),
          ),
          // Glow effect
          if (value == null)
            CircularProgressIndicator(
              strokeWidth: strokeWidth + 2,
              color: ringColor.withValues(alpha: 0.2),
            ).animate(onPlay: (c) => c.repeat()).rotate(duration: 2.seconds)
          else
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value),
              duration: 500.ms,
              builder: (context, val, _) => CircularProgressIndicator(
                value: val,
                strokeWidth: strokeWidth + 1,
                color: ringColor.withValues(alpha: 0.3),
              ),
            ),
          // Primary ring
          CircularProgressIndicator(
            value: value,
            strokeWidth: strokeWidth,
            color: ringColor,
            strokeCap: StrokeCap.round,
          ),
        ],
      ),
    );
  }
}

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double borderRadius;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.padding,
    this.color,
    this.borderRadius = 16,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDesignTokens.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: widget.margin,
              decoration: BoxDecoration(
                color: widget.color ?? theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Padding(
                  padding: widget.padding ?? EdgeInsets.zero,
                  child: widget.child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PulsatingWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulsatingWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 0.95,
    this.maxScale = 1.0,
  });

  @override
  State<PulsatingWidget> createState() => _PulsatingWidgetState();
}

class _PulsatingWidgetState extends State<PulsatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat(reverse: true);

    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(scale: _animation.value, child: widget.child);
      },
    );
  }
}
