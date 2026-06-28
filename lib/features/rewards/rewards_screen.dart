import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/sound_manager.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../data/models/statistics.dart';

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
                        return _buildAchievementRewards(context, theme, l10n, ref);
                      case 5:
                        return const SizedBox(height: 32);
                      case 6:
                        return _buildSpecialRewards(context, theme, l10n, ref);
                      case 7:
                        return const SizedBox(height: 32);
                      case 8:
                        return _buildShopSection(context, theme, l10n, ref);
                      default:
                        return const SizedBox.shrink();
                    }
                  },
                  childCount: 9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopSection(BuildContext context, ThemeData theme, AppLocalizations l10n, WidgetRef ref) {
    final user = ref.watch(userSessionProvider);
    final unlockedAvatars = user?.unlockedAvatars ?? ['circle', 'square', 'star'];
    
    final shopItems = [
      {'id': 'hexagon', 'name': 'Hexagon', 'cost': 500, 'icon': Icons.hexagon},
      {'id': 'pentagon', 'name': 'Pentagon', 'cost': 750, 'icon': Icons.pentagon},
      {'id': 'diamond', 'name': 'Diamond', 'cost': 1000, 'icon': Icons.diamond},
      {'id': 'favorite', 'name': 'Heart', 'cost': 1500, 'icon': Icons.favorite},
      {'id': 'star', 'name': 'Premium Star', 'cost': 2000, 'icon': Icons.stars},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AVATAR SHOP',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: shopItems.length,
          itemBuilder: (context, index) {
            final item = shopItems[index];
            final id = item['id'] as String;
            final isUnlocked = unlockedAvatars.contains(id);
            final cost = item['cost'] as int;
            final canAfford = (user?.totalPoints ?? 0) >= cost;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUnlocked 
                      ? theme.colorScheme.primary.withValues(alpha: 0.5)
                      : theme.colorScheme.outline.withValues(alpha: 0.1),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 48,
                    color: isUnlocked ? theme.colorScheme.primary : Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (isUnlocked)
                    Text(
                      'UNLOCKED',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: canAfford ? () async {
                        final success = await ref.read(userSessionProvider.notifier).unlockAvatar(id, cost);
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Unlocked ${item['name']}!'))
                          );
                        }
                      } : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(0, 36),
                      ),
                      child: Text('$cost pts'),
                    ),
                ],
              ),
            );
          },
        ),
      ],
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
              tooltip: l10n.switchLanguage,
              onPressed: () {
                HapticManager.instance.selectionClick();
                ref.read(localeProvider.notifier).toggleLanguage();
                final newLocale = ref.read(localeProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${l10n.languageChanged} ${newLocale.name}'),
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
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
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
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final rewards = [100, 150, 200, 250, 300, 350, 500];
                    return Container(
                      width: 50,
                      margin: const EdgeInsets.only(right: 8),
                      child: _buildDailyRewardItem(
                        day: day,
                        reward: '$rewards[index] XP',
                        isClaimed: day <= 3,
                        theme: theme,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticManager.instance.successPattern();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.dailyRewardClaimed),
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
                  child: Text(l10n.claimTodaysReward),
                ),
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
      mainAxisAlignment: MainAxisAlignment.center,
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
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildAchievementRewards(BuildContext context, ThemeData theme, AppLocalizations l10n, WidgetRef ref) {
    return FutureBuilder<Statistics>(
      future: ref.read(statisticsRepositoryProvider).getOverallStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? Statistics();
        final accuracy = stats.totalQuestionsAnswered > 0
            ? (stats.correctAnswers / stats.totalQuestionsAnswered) * 100
            : 0.0;
        
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
              title: 'Question Master',
              description: 'Answer ${stats.totalQuestionsAnswered} questions',
              reward: '+${(stats.totalQuestionsAnswered ~/ 10) * 10} XP',
              progress: (stats.totalQuestionsAnswered / 100).clamp(0.0, 1.0),
              icon: Icons.quiz,
              color: theme.colorScheme.primary,
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildRewardCard(
              title: 'Accuracy King',
              description: 'Achieve ${accuracy.toStringAsFixed(0)}% accuracy',
              reward: '+${accuracy.toInt()} XP',
              progress: (accuracy / 100).clamp(0.0, 1.0),
              icon: Icons.track_changes,
              color: theme.colorScheme.secondary,
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildRewardCard(
              title: 'Time Master',
              description: 'Play for ${stats.timeSpentSeconds ~/ 60} minutes',
              reward: '+${stats.timeSpentSeconds ~/ 60} XP',
              progress: (stats.timeSpentSeconds / 3600).clamp(0.0, 1.0),
              icon: Icons.timer,
              color: theme.colorScheme.tertiary,
              theme: theme,
            ),
          ],
        );
      },
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 8),
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
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialRewards(BuildContext context, ThemeData theme, AppLocalizations l10n, WidgetRef ref) {
    final user = ref.watch(userSessionProvider);
    final streak = user?.loginStreak ?? 0;
    
    return FutureBuilder<Statistics>(
      future: ref.read(statisticsRepositoryProvider).getOverallStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? Statistics();
        final totalQuestions = stats.totalQuestionsAnswered;
        
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
                    progress: (stats.correctAnswers / 100).clamp(0.0, 1.0),
                    isUnlocked: stats.correctAnswers >= 50,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSpecialRewardItem(
                    title: 'Streak Master',
                    description: '$streak day streak',
                    icon: Icons.local_fire_department,
                    color: theme.colorScheme.primary,
                    theme: theme,
                    progress: (streak / 7).clamp(0.0, 1.0),
                    isUnlocked: streak >= 7,
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
                    description: 'Solve $totalQuestions riddles',
                    icon: Icons.psychology,
                    color: theme.colorScheme.tertiary,
                    theme: theme,
                    progress: (totalQuestions / 100).clamp(0.0, 1.0),
                    isUnlocked: totalQuestions >= 100,
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
                    progress: (totalQuestions / 50).clamp(0.0, 1.0),
                    isUnlocked: totalQuestions >= 50,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpecialRewardItem({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required ThemeData theme,
    double progress = 1.0,
    bool isUnlocked = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: isUnlocked ? 0.2 : 0.1),
            color.withValues(alpha: isUnlocked ? 0.1 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: isUnlocked ? 0.3 : 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isUnlocked ? 0.15 : 0.08),
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