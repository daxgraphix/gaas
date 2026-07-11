import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/themes/app_themes.dart';
import '../../../../data/models/level_progress.dart';
import '../../../../l10n/generated/app_localizations.dart';

class SyncMap extends StatefulWidget {
  final String operation;
  final List<LevelProgress> progressList;
  final Function(int level) onLevelTap;

  const SyncMap({
    super.key,
    required this.operation,
    required this.progressList,
    required this.onLevelTap,
  });

  @override
  State<SyncMap> createState() => _SyncMapState();
}

class _SyncMapState extends State<SyncMap> with TickerProviderStateMixin {
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              _buildConnectionLines(context),
              _buildLevelNodes(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionLines(BuildContext context) {
    return CustomPaint(
      size: const Size(600, 100 * 120.0), // 100 levels * spacing
      painter: _MapPathPainter(levelCount: 100, theme: Theme.of(context)),
    );
  }

  Widget _buildLevelNodes(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final List<Widget> children = [];
    
    for (int index = 0; index < 100; index++) {
      final level = index + 1;
      
      // Add Chapter Header
      if (index % 10 == 0) {
        final chapterNum = (index ~/ 10) + 1;
        final startLevel = index + 1;
        final endLevel = index + 10;
        
        final chapterStars = widget.progressList
            .where((p) => p.level >= startLevel && p.level <= endLevel)
            .fold(0, (sum, p) => sum + p.stars);
        
        // Global star count for linear progression check
        final totalStars = widget.progressList.fold(0, (sum, p) => sum + p.stars);
        
        // Chapter 1 is always unlocked. 
        // Subsequent chapters depend on total stars.
        // Formula: (level - 1) * 2. So Chapter 2 (starts at L11) needs 10*2 = 20 stars.
        bool isUnlocked;
        final starsNeeded = (startLevel - 1) * 2;
        if (chapterNum == 1) {
          isUnlocked = true;
        } else {
          isUnlocked = totalStars >= starsNeeded;
        }

        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: isUnlocked 
                      ? theme.colorScheme.surface.withValues(alpha: 0.3)
                      : theme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isUnlocked 
                        ? theme.colorScheme.outline.withValues(alpha: 0.1) 
                        : theme.colorScheme.error.withValues(alpha: 0.3)
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${l10n.chapter} $chapterNum',
                      style: TextStyle(
                        color: isUnlocked ? theme.colorScheme.primary : theme.colorScheme.error,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isUnlocked 
                          ? l10n.chapterStarsProgress(chapterStars, 30) 
                          : l10n.lockedNeedStars(starsNeeded),
                      style: TextStyle(
                        color: isUnlocked ? theme.colorScheme.onSurface : theme.colorScheme.error.withValues(alpha: 0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      final progress = widget.progressList.firstWhere(
        (p) => p.level == level,
        orElse: () => LevelProgress(
          operationId: widget.operation,
          level: level,
          stars: 0,
          isUnlocked: level == 1,
          highScore: 0,
        ),
      );

      final isBoss = level % 10 == 0;
      final alignment = index % 2 == 0 ? Alignment.centerLeft : Alignment.centerRight;
      final horizontalPadding = index % 2 == 0 ? 60.0 : 60.0;

      children.add(
        Padding(
          padding: EdgeInsets.only(
            left: index % 2 == 0 ? horizontalPadding : 0,
            right: index % 2 != 0 ? horizontalPadding : 0,
            bottom: 40,
          ),
          child: Align(
            alignment: alignment,
            child: _SyncNode(
              level: level,
              isUnlocked: progress.isUnlocked,
              stars: progress.stars,
              isBoss: isBoss,
              onTap: () => widget.onLevelTap(level),
              particleAnimation: _particleController,
            ),
          ),
        ),
      );
    }

    return Column(children: children);
  }
}

class _SyncNode extends StatelessWidget {
  final int level;
  final bool isUnlocked;
  final int stars;
  final bool isBoss;
  final VoidCallback onTap;
  final Animation<double> particleAnimation;

  const _SyncNode({
    required this.level,
    required this.isUnlocked,
    required this.stars,
    required this.onTap,
    required this.particleAnimation,
    this.isBoss = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = isUnlocked ? theme.colorScheme.primary : AppDesignTokens.textMuted(context).withValues(alpha: 0.3);
    
    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (isBoss && isUnlocked)
                CustomPaint(
                  size: const Size(120, 120),
                  painter: _BossParticlePainter(
                    color: theme.colorScheme.error,
                    animation: particleAnimation,
                  ),
                ),
              Container(
                width: isBoss ? 85 : 70,
                height: isBoss ? 85 : 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked
                      ? (isBoss ? theme.colorScheme.errorContainer : theme.colorScheme.surface)
                      : theme.colorScheme.surface.withValues(alpha: 0.5),
                  border: Border.all(
                    color: isBoss && isUnlocked ? theme.colorScheme.error : accentColor,
                    width: isBoss ? 4 : 2,
                  ),
                  boxShadow: isUnlocked
                      ? [
                        BoxShadow(
                          color: (isBoss ? theme.colorScheme.error : accentColor)
                              .withValues(alpha: 0.3),
                          blurRadius: isBoss ? 20 : 12,
                          spreadRadius: isBoss ? 4 : 2,
                        ),
                      ]
                      : [],
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (!isUnlocked)
                        Icon(
                          Icons.lock,
                          color: AppDesignTokens.textMuted(context).withValues(alpha: 0.5),
                          size: 24,
                        ),
                      if (isUnlocked)
                        isBoss
                            ? Icon(
                              Icons.bolt,
                              color: theme.colorScheme.error,
                              size: 32,
                            )
                            : Text(
                              level.toString(),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppDesignTokens.textPrimary(context),
                              ),
                            ),
                    ],
                  ),
                ),
              ).animate(target: isUnlocked ? 1 : 0)
                .shimmer(duration: 2.seconds, color: (isBoss ? theme.colorScheme.error : accentColor).withValues(alpha: 0.1))
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 400.ms, curve: Curves.easeOutBack),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) => Icon(
              Icons.star,
              size: 14,
              color: i < stars ? AppDesignTokens.warning : AppDesignTokens.textMuted(context).withValues(alpha: 0.2),
            )),
          ),
        ],
      ),
    );
  }
}

class _BossParticlePainter extends CustomPainter {
  final Color color;
  final Animation<double> animation;
  final Random rand = Random(42);

  _BossParticlePainter({required this.color, required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final seed = i * 100;
      final radius = 40.0 + (sin(animation.value * pi * 2 + seed) * 10);
      final angle = (i * 30 * pi / 180) + (animation.value * pi * 0.5);
      
      final particlePos = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      canvas.drawCircle(particlePos, 2.0 + (sin(animation.value * pi + seed).abs() * 2), paint);
      
      // Draw faint connect lines to boss node
      final linePaint = Paint()
        ..color = color.withValues(alpha: 0.1)
        ..strokeWidth = 1;
      canvas.drawLine(center, particlePos, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _MapPathPainter extends CustomPainter {
  final int levelCount;
  final ThemeData theme;

  _MapPathPainter({required this.levelCount, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.colorScheme.onSurface.withValues(alpha: 0.1)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final stepY = 110.0; // Matches node height + padding
    final centerX = size.width / 2;
    final offsetX = 140.0;

    path.moveTo(centerX - offsetX, 35); // Start at first node position

    for (int i = 0; i < levelCount - 1; i++) {
      final currentLeft = i % 2 == 0;
      final startX = currentLeft ? (centerX - offsetX) : (centerX + offsetX);
      final startY = 35 + (i * stepY);
      
      final endX = !currentLeft ? (centerX - offsetX) : (centerX + offsetX);
      final endY = 35 + ((i + 1) * stepY);

      path.cubicTo(
        startX, startY + stepY / 2,
        endX, endY - stepY / 2,
        endX, endY
      );
    }

    canvas.drawPath(path, paint);

    // Draw secondary "glow" path
    final glowPaint = Paint()
      ..color = theme.colorScheme.primary.withValues(alpha: 0.05)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
