import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/sound_manager.dart';
import '../../l10n/generated/app_localizations.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(userSessionProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context, theme, l10n),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.02),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    switch (index) {
                      case 0:
                        return _buildPointsHeader(theme, user, l10n);
                      case 1:
                        return const SizedBox(height: 32);
                      case 2:
                        return _buildDailyRewards(context, theme, l10n);
                      case 3:
                        return const SizedBox(height: 32);
                      case 4:
                        return _buildAchievementRewards(context, theme, l10n);
                      case 5:
                        return const SizedBox(height: 32);
                      case 6:
                        return _buildSpecialRewards(context, theme, l10n);
                      default:
                        return const SizedBox.shrink();
                    }
                  },
                  childCount: 7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
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
            Icons.close,
            size: 16,
            color: theme.colorScheme.onSurface,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'REWARDS CENTER',
        style: TextStyle(
          fontSize: 18,
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
          fontFamily: 'monospace',
        ),
      ),
      actions: [
        Consumer(
          builder: (context, ref, child) {
            final currentLocale = ref.watch(localeProvider);
            return IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  currentLocale.flag,
                  key: ValueKey(currentLocale.flag),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              tooltip: 'Switch Language',
              onPressed: () {
                HapticManager.selectionClick();
                ref.read(localeProvider.notifier).toggleLanguage();
                final newLocale = ref.read(localeProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${l10n.languageChanged} to ${newLocale.name}'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: theme.colorScheme.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildPointsHeader(ThemeData theme, dynamic user, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.8),
            theme.colorScheme.secondary.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.stars,
                color: theme.colorScheme.onPrimary,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'TOTAL POINTS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${user?.totalPoints ?? 0}',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimary,
              shadows: [
                Shadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Keep playing to earn more rewards!',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRewards(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    final dailyRewards = [
      {'day': 1, 'reward': '100 XP', 'claimed': true},
      {'day': 2, 'reward': '150 XP', 'claimed': true},
      {'day': 3, 'reward': '200 XP', 'claimed': true},
      {'day': 4, 'reward': '250 XP', 'claimed': false},
      {'day': 5, 'reward': '300 XP', 'claimed': false},
      {'day': 6, 'reward': '350 XP', 'claimed': false},
      {'day': 7, 'reward': '500 XP + Avatar', 'claimed': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DAILY REWARDS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: dailyRewards.map((reward) {
                  final isClaimed = reward['claimed'] as bool;
                  final day = reward['day'] as int;
                  final rewardText = reward['reward'] as String;

                  return _buildDailyRewardItem(
                    day: day,
                    reward: rewardText,
                    isClaimed: isClaimed,
                    theme: theme,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Claim today's reward
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Daily reward claimed!'),
                      backgroundColor: theme.colorScheme.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('CLAIM TODAY\'S REWARD'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyRewardItem({
    required int day,
    required String reward,
    required bool isClaimed,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isClaimed
                ? LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  )
                : LinearGradient(
                    colors: [
                      theme.colorScheme.surface,
                      theme.colorScheme.surface.withValues(alpha: 0.5),
                    ],
                  ),
            border: Border.all(
              color: isClaimed
                  ? theme.colorScheme.primary.withValues(alpha: 0.5)
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: isClaimed
                ? Icon(
                    Icons.check,
                    color: theme.colorScheme.onPrimary,
                    size: 20,
                  )
                : Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Day $day',
          style: TextStyle(
            fontSize: 10,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementRewards(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACHIEVEMENT REWARDS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 20),
        _buildRewardCard(
          title: 'First Steps',
          description: 'Complete your first math problem',
          reward: '+50 XP',
          progress: 1.0,
          icon: Icons.flag,
          color: theme.colorScheme.primary,
          theme: theme,
        ),
        const SizedBox(height: 16),
        _buildRewardCard(
          title: 'Speed Demon',
          description: 'Solve 10 problems in under 30 seconds',
          reward: '+100 XP + Speed Badge',
          progress: 0.7,
          icon: Icons.flash_on,
          color: theme.colorScheme.secondary,
          theme: theme,
        ),
        const SizedBox(height: 16),
        _buildRewardCard(
          title: 'Math Master',
          description: 'Achieve 95% accuracy on 50 problems',
          reward: '+500 XP + Master Avatar',
          progress: 0.3,
          icon: Icons.school,
          color: theme.colorScheme.tertiary,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildRewardCard({
    required String title,
    required String description,
    required String reward,
    required double progress,
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        reward,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}% Complete',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialRewards(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SPECIAL REWARDS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildSpecialRewardItem(
                title: 'Weekly Champion',
                description: 'Top scorer this week',
                icon: Icons.emoji_events,
                color: theme.colorScheme.secondary,
                theme: theme,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSpecialRewardItem(
                title: 'Streak Master',
                description: '7-day solving streak',
                icon: Icons.local_fire_department,
                color: theme.colorScheme.primary,
                theme: theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSpecialRewardItem(
                title: 'Puzzle Genius',
                description: 'Solve 100 riddles',
                icon: Icons.psychology,
                color: theme.colorScheme.tertiary,
                theme: theme,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSpecialRewardItem(
                title: 'Time Lord',
                description: 'Beat 50 speed challenges',
                icon: Icons.access_time,
                color: theme.colorScheme.primary,
                theme: theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecialRewardItem({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}