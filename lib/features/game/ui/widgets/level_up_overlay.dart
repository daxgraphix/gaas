import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/themes/app_themes.dart';
import '../../../../l10n/generated/app_localizations.dart';

class LevelUpOverlay extends ConsumerStatefulWidget {
  final int level;
  final int rewardPoints;
  final VoidCallback onDismiss;

  const LevelUpOverlay({
    super.key,
    required this.level,
    required this.rewardPoints,
    required this.onDismiss,
  });

  @override
  ConsumerState<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends ConsumerState<LevelUpOverlay> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(100.ms, () {
      if (mounted) setState(() => _isVisible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameTheme = theme.extension<GameThemeExtension>()!;
    final l10n = AppLocalizations.of(context)!;
    
    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: Stack(
        children: [
          // Background particles/glow
          Positioned.fill(
            child: CustomPaint(
              painter: _LevelUpGlowPainter(gameTheme.streakColor),
            ).animate(onPlay: (c) => c.repeat())
             .rotate(duration: 10.seconds, begin: 0, end: 1),
          ),

          Center(
            child: PremiumGlassOverlay(
              borderRadius: 32,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badge Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          gameTheme.streakColor,
                          gameTheme.timerColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: gameTheme.streakColor.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.keyboard_double_arrow_up_rounded,
                      color: Colors.white,
                      size: 64,
                    ),
                  ).animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut)
                    .shimmer(delay: 800.ms, duration: 1.seconds),

                  const SizedBox(height: 32),

                  Text(
                    l10n.levelUp,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      color: gameTheme.streakColor,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 8),

                  Text(
                    l10n.levelUppercase(widget.level),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.8, 0.8)),

                  const SizedBox(height: 40),

                  // Reward Info
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars_rounded, color: Colors.amber, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          '+${widget.rewardPoints} ${l10n.rewardPoints.toUpperCase()}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1, end: 0),

                  const SizedBox(height: 48),

                  PremiumPrimaryButton(
                    text: l10n.continueText,
                    onPressed: widget.onDismiss,
                    width: 200,
                  ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          ).animate(target: _isVisible ? 1 : 0)
           .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack, duration: 400.ms)
           .fadeIn(),
        ],
      ),
    );
  }
}

class _LevelUpGlowPainter extends CustomPainter {
  final Color color;
  _LevelUpGlowPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));

    canvas.drawCircle(center, size.width / 2, paint);

    // Draw some radial lines
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..strokeWidth = 2;

    for (int i = 0; i < 12; i++) {
      // Actual rotation handled by animation widget
      canvas.drawLine(center, Offset(center.dx + size.width, center.dy), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
