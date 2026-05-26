import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/content_library/achievement_system.dart';

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
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.05),
                  theme.scaffoldBackgroundColor,
                  theme.colorScheme.secondary.withValues(alpha: 0.03),
                ],
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, reward, theme),
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

  Widget _buildSliverAppBar(BuildContext context, AchievementReward reward, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 280,
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
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.1),
                theme.colorScheme.secondary.withValues(alpha: 0.05),
                theme.scaffoldBackgroundColor,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Animated background particles
              ...List.generate(8, (index) {
                return Positioned(
                  left: (index * 45.0) % MediaQuery.of(context).size.width,
                  top: (index * 80.0) % 200,
                  child: Container(
                    width: 4 + (index % 3) * 2.0,
                    height: 4 + (index % 3) * 2.0,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                  ).animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  ).moveY(
                    begin: 0,
                    end: 20,
                    duration: Duration(seconds: 2 + index),
                    curve: Curves.easeInOut,
                  ),
                );
              }),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Player rank with enhanced styling
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.8),
                            theme.colorScheme.secondary.withValues(alpha: 0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium,
                            color: theme.colorScheme.onPrimary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'LEVEL ${reward.level}',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Total points with glow effect
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'TOTAL SCORE',
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 2,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${reward.totalPoints}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              shadows: [
                                Shadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (reward.pointsToNextLevel > 0)
                            _buildProgressBar(reward.totalPoints, theme),
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

  Widget _buildProgressBar(int points, ThemeData theme) {
    final double progress = (points % 100) / 100.0;
    final nextLevelPoints = ((points ~/ 100) + 1) * 100;

    return Column(
      children: [
        Container(
          width: 200,
          height: 8,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              Container(
                width: 200 * progress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${nextLevelPoints - points} XP to next level',
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
        return theme.colorScheme.secondary; // Legendary color
    }
  }
}