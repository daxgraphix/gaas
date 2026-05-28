import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/content_library/achievement_system.dart';
import '../../core/themes/app_themes.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final achievementState = ref.watch(achievementStateProvider);
    final allAchievements = ref.watch(achievementDatabaseProvider);
    final reward = ref.watch(achievementRewardProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Animated background
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: AchievementParticlesPainter(theme),
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, ref, reward, theme),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final achievement = allAchievements[index];
                    final isUnlocked = achievementState.unlockedAchievements.any(
                      (a) => a.achievementId == achievement.id,
                    );
                    return _buildAchievementEntry(achievement, isUnlocked, index, theme);
                  }, childCount: allAchievements.length),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref, AchievementReward reward, ThemeData theme) {
    final unlockedAchievements = ref.read(achievementStateProvider).unlockedAchievements;
    final totalAchievements = ref.read(achievementDatabaseProvider).length;
    final progressPercent = unlockedAchievements.length / totalAchievements;

    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 16,
            color: theme.colorScheme.onSurface,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.2,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.15),
                theme.colorScheme.secondary.withValues(alpha: 0.08),
                theme.scaffoldBackgroundColor,
              ],
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.9),
                            theme.colorScheme.secondary.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.6),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium,
                            color: theme.colorScheme.onPrimary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'ACHIEVER • LEVEL ${reward.level}',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20),
                      constraints: const BoxConstraints(maxWidth: 320),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'TOTAL SCORE',
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 2,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${reward.totalPoints}',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              shadows: [
                                Shadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ).animate().scale(delay: 400.ms, duration: 500.ms, curve: Curves.easeOut),
                          const SizedBox(height: 16),
                          if (reward.pointsToNextLevel > 0) ...[
                            Stack(
                              children: [
                                Container(
                                  width: 280,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOut,
                                  width: 280 * (1 - progressPercent.clamp(0.0, 1.0)),
                                  height: 10,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppDesignTokens.neonGreen,
                                        theme.colorScheme.primary,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${reward.pointsToNextLevel} XP to NEXT LEVEL',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementEntry(
    Achievement achievement,
    bool isUnlocked,
    int index,
    ThemeData theme,
  ) {
    final color = _getRarityColor(achievement.rarity, theme);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isUnlocked
            ? LinearGradient(
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.05),
                ],
              )
            : LinearGradient(
                colors: [
                  theme.colorScheme.surface.withValues(alpha: 0.3),
                  theme.colorScheme.surface.withValues(alpha: 0.1),
                ],
              ),
        border: Border.all(
          color: isUnlocked
              ? color.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Achievement icon with glow effect
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isUnlocked
                          ? [color, color.withValues(alpha: 0.7)]
                          : [theme.colorScheme.surface, theme.colorScheme.surface.withValues(alpha: 0.5)],
                    ),
                    border: Border.all(
                      color: isUnlocked ? color : theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: isUnlocked
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _getIconData(achievement.iconName),
                    color: isUnlocked ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Rarity indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isUnlocked ? color.withValues(alpha: 0.2) : theme.colorScheme.surface.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              achievement.rarity.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isUnlocked ? color : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // XP reward
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '+${achievement.points} XP',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        achievement.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isUnlocked
                              ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                              : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          height: 1.4,
                        ),
                      ),
                      if (!isUnlocked) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'LOCKED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'star':
        return Icons.star_border;
      case 'local_fire_department':
        return Icons.bolt;
      case 'whatshot':
        return Icons.whatshot;
      case 'military_tech':
        return Icons.military_tech;
      case 'looks_one':
        return Icons.filter_1;
      case 'all_inclusive':
        return Icons.all_inclusive;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'verified':
        return Icons.verified;
      case 'bolt':
        return Icons.electric_bolt;
      case 'date_range':
        return Icons.calendar_today;
      case 'calendar_month':
        return Icons.calendar_month;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'calculate':
        return Icons.calculate;
      case 'sports_mma':
        return Icons.sports_mma;
      case 'score':
        return Icons.score;
      case 'leaderboard':
        return Icons.leaderboard;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'nightlight':
        return Icons.nightlight;
      case 'weekend':
        return Icons.weekend;
      case 'sports_esports':
        return Icons.sports_esports;
      default:
        return Icons.code;
    }
  }

  Color _getRarityColor(AchievementRarity rarity, ThemeData theme) {
    switch (rarity) {
      case AchievementRarity.common:
        return theme.colorScheme.onSurface.withValues(alpha: 0.6);
      case AchievementRarity.uncommon:
        return theme.colorScheme.secondary;
      case AchievementRarity.rare:
        return theme.colorScheme.primary;
      case AchievementRarity.epic:
        return theme.colorScheme.tertiary;
      case AchievementRarity.legendary:
        return AppDesignTokens.neonYellow;
    }
  }
}

class AchievementParticlesPainter extends CustomPainter {
  final ThemeData theme;
  AchievementParticlesPainter(this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.colorScheme.primary.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final x = (i * 37.0) % size.width;
      final y = (i * 73.0) % size.height;
      final radius = 2 + (i % 3) * 1.5;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}