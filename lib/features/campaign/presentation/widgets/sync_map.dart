import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/themes/app_themes.dart';
import '../../../../data/models/level_progress.dart';

class SyncMap extends StatelessWidget {
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
              _buildConnectionLines(),
              _buildLevelNodes(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionLines() {
    return CustomPaint(
      size: const Size(600, 30 * 120.0), // 30 levels * spacing
      painter: _MapPathPainter(levelCount: 30),
    );
  }

  Widget _buildLevelNodes() {
    return Column(
      children: List.generate(30, (index) {
        final level = index + 1;
        final progress = progressList.firstWhere(
          (p) => p.level == level,
          orElse: () => LevelProgress(
            operationId: operation,
            level: level,
            stars: 0,
            isUnlocked: level == 1,
            highScore: 0,
          ),
        );

        // Zig-zag alignment
        final alignment = index % 2 == 0 ? Alignment.centerLeft : Alignment.centerRight;
        final horizontalPadding = index % 2 == 0 ? 60.0 : 60.0;

        return Padding(
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
              onTap: () => onLevelTap(level),
            ),
          ),
        );
      }),
    );
  }
}

class _SyncNode extends StatelessWidget {
  final int level;
  final bool isUnlocked;
  final int stars;
  final VoidCallback onTap;

  const _SyncNode({
    required this.level,
    required this.isUnlocked,
    required this.stars,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = isUnlocked ? theme.colorScheme.primary : AppDesignTokens.textMuted.withValues(alpha: 0.3);
    
    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked ? theme.colorScheme.surface : theme.colorScheme.surface.withValues(alpha: 0.5),
              border: Border.all(
                color: accentColor,
                width: 2,
              ),
              boxShadow: isUnlocked ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ] : [],
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!isUnlocked)
                    Icon(Icons.lock, color: AppDesignTokens.textMuted.withValues(alpha: 0.5), size: 24),
                  if (isUnlocked)
                    Text(
                      level.toString(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                ],
              ),
            ),
          ).animate(target: isUnlocked ? 1 : 0)
            .shimmer(duration: 2.seconds, color: accentColor.withValues(alpha: 0.1))
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) => Icon(
              Icons.star,
              size: 14,
              color: i < stars ? AppDesignTokens.warning : AppDesignTokens.textMuted.withValues(alpha: 0.2),
            )),
          ),
        ],
      ),
    );
  }
}

class _MapPathPainter extends CustomPainter {
  final int levelCount;

  _MapPathPainter({required this.levelCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppDesignTokens.textMuted.withValues(alpha: 0.1)
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
      ..color = AppDesignTokens.primary.withValues(alpha: 0.05)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
