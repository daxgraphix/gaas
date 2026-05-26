import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum AppThemeType { midnight }

class AppDesignTokens {
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 20.0;
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

  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Enhanced Gaming Tech Color Palette
  static const Color neonCyan = Color(0xFF00F5FF);
  static const Color neonPink = Color(0xFFFF006E);
  static const Color neonYellow = Color(0xFFF7FF00);
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonPurple = Color(0xFF9D4EDD);
  static const Color neonOrange = Color(0xFFFF6B35);
  static const Color brightBlue = Color(0xFF4A90E2);
  static const Color brightRed = Color(0xFFE74C3C);
  static const Color electricBlue = Color(0xFF00BFFF);
  static const Color hotPink = Color(0xFFFF1493);
  static const Color limeGreen = Color(0xFF32CD32);
  static const Color gold = Color(0xFFFFD700);
  static const Color techBlack = Color(0xFF0A0A0B);
  static const Color techGrey = Color(0xFF1A1A1C);
  static const Color darkGrey = Color(0xFF2A2A2A);
  static const Color mediumGrey = Color(0xFF404040);
  static const Color lightGrey = Color(0xFF606060);
}

class Material3Tokens {
  static const double frostedBlur = 10.0;
  static const double frostedOpacity = 0.7;
  static const double springDamping = 0.6;
  static const double springStiffness = 500.0;
}

class AppThemes {
  static ThemeData getTheme(AppThemeType type) {
    switch (type) {
      case AppThemeType.midnight:
        return _midnightTheme;
    }
  }










   static final ThemeData _midnightTheme = ThemeData(
     useMaterial3: true,
     brightness: Brightness.dark,
     colorScheme: ColorScheme.fromSeed(
       seedColor: AppDesignTokens.neonCyan,
       brightness: Brightness.dark,
       primary: AppDesignTokens.neonCyan,
       onPrimary: const Color(0xFF121212),
       secondary: AppDesignTokens.neonPink,
       onSecondary: const Color(0xFF121212),
       surface: const Color(0xFF121212),
       onSurface: AppDesignTokens.neonCyan,
       outline: AppDesignTokens.neonCyan.withValues(alpha: 0.3),
       surfaceContainerHighest: const Color(0xFF1E1E1E),
     ),
     scaffoldBackgroundColor: const Color(0xFF121212),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppDesignTokens.techGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
        side: BorderSide(color: AppDesignTokens.neonCyan.withValues(alpha: 0.1)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: AppDesignTokens.neonCyan,
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        letterSpacing: 4,
        color: AppDesignTokens.neonCyan,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppDesignTokens.neonCyan,
        foregroundColor: AppDesignTokens.techBlack,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: const Size(0, 52),
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusSmall),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppDesignTokens.neonPink,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: const Size(0, 52),
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusSmall),
        ),
        side: const BorderSide(color: AppDesignTokens.neonPink, width: 1.5),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppDesignTokens.neonCyan,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppDesignTokens.neonCyan.withValues(alpha: 0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusSmall),
        borderSide: BorderSide(
          color: AppDesignTokens.neonCyan.withValues(alpha: 0.2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusSmall),
        borderSide: BorderSide(
          color: AppDesignTokens.neonCyan.withValues(alpha: 0.2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusSmall),
        borderSide: const BorderSide(color: AppDesignTokens.neonCyan, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusSmall),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      hintStyle: TextStyle(
        color: AppDesignTokens.neonCyan.withValues(alpha: 0.3),
        letterSpacing: 1,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: AppDesignTokens.techBlack,
      indicatorColor: AppDesignTokens.neonCyan.withValues(alpha: 0.1),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppDesignTokens.neonCyan,
            letterSpacing: 1,
          );
        }
        return TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppDesignTokens.neonCyan.withValues(alpha: 0.5),
          letterSpacing: 1,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppDesignTokens.neonCyan, size: 24);
        }
        return IconThemeData(
          color: AppDesignTokens.neonCyan.withValues(alpha: 0.5),
          size: 24,
        );
      }),
    ),
    textTheme: _buildTextTheme(
      AppDesignTokens.neonCyan,
      AppDesignTokens.neonCyan.withValues(alpha: 0.7),
    ),
    dividerTheme: DividerThemeData(
      color: AppDesignTokens.neonCyan.withValues(alpha: 0.1),
      thickness: 1,
      space: 1,
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

    if (useFrostedEffect) {
      return ClipRRect(
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

    return containerChild;
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
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
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
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
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

  const PremiumCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.borderColor,
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
      child:
          Container(
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
                child: widget.child,
              )
              .animate(target: _isPressed ? 1 : 0)
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(0.98, 0.98),
                duration: 100.ms,
                curve: Curves.easeOut,
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
