import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/sound_manager.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../reports/reports_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../campaign/presentation/campaign_screen.dart';
import '../../arcade/presentation/arcade_screen.dart';
import '../../practice/presentation/practice_screen.dart';
import '../../calculator/calculator_screen.dart';
import '../../custom_mix/presentation/custom_mix_screen.dart';
import '../../puzzle/math_riddle/math_riddle_level_selection_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late final AppLocalizations l10n;
  late AnimationController _fabAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _cardSlideAnimation;

  final int _currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));

    _cardSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.elasticOut,
    ));

    _cardAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    l10n = AppLocalizations.of(context)!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(userSessionProvider);
    final totalStars = ref.watch(totalStarsProvider);
    final completedLevels = ref.watch(completedLevelsProvider);
    final totalTime = ref.watch(totalTimePlayedProvider);
    final accuracy = ref.watch(overallAccuracyProvider);
    final sessionStats = ref.watch(sessionStatsProvider);

    final hour = DateTime.now().hour;
    final String greeting = hour < 12
        ? l10n.goodMorning
        : hour < 17
            ? l10n.goodAfternoon
            : hour < 21
                ? l10n.goodEvening
                : l10n.goodNight;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true,
      appBar: _buildAdvancedAppBar(theme, greeting),
      body: _buildAdvancedBody(
        theme, user, totalStars, completedLevels, totalTime, accuracy, sessionStats, l10n,
      ),
      floatingActionButton: _buildAnimatedFAB(theme),
      bottomNavigationBar: _buildModernBottomNav(theme, l10n),
    );
  }

  PreferredSizeWidget _buildAdvancedAppBar(ThemeData theme, String greeting) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.colorScheme.secondary.withValues(alpha: 0.05),
            ],
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.calculate,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.welcomeToGAAS,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '$greeting, ${l10n.player}!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        _buildStreakIndicator(theme),
        const SizedBox(width: 8),
        _buildLanguageToggle(theme),
        const SizedBox(width: 8),
        _buildProfileButton(theme),
      ],
    );
  }

  Widget _buildStreakIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department,
            color: theme.colorScheme.tertiary,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '$_currentStreak',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onTertiaryContainer,
            ),
          ),
        ],
      ),
    ).animate(target: _currentStreak > 0 ? 1 : 0)
        .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2))
        .then()
        .scale(begin: const Offset(1.2, 1.2), end: const Offset(1, 1));
  }

  Widget _buildLanguageToggle(ThemeData theme) {
    return Consumer(
      builder: (context, ref, child) {
        final currentLocale = ref.watch(localeProvider);
        return IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              currentLocale.flag,
              key: ValueKey(currentLocale.flag),
              style: const TextStyle(fontSize: 20),
            ),
          ),
          tooltip: l10n.switchLanguage,
          onPressed: () {
            HapticManager.selectionClick();
            ref.read(soundManagerProvider).playEffect('click');
            ref.read(localeProvider.notifier).toggleLanguage();
            final newLocale = ref.read(localeProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${l10n.switchedTo} ${newLocale.name}'),
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
    );
  }

  Widget _buildProfileButton(ThemeData theme) {
    return IconButton(
      icon: CircleAvatar(
        radius: 14,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        child: Icon(
          Icons.person_outline,
          size: 16,
          color: theme.colorScheme.primary,
        ),
      ),
      tooltip: l10n.profile,
      onPressed: () {
        HapticManager.selectionClick();
        ref.read(soundManagerProvider).playEffect('click');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      },
    );
  }

  Widget _buildAdvancedBody(
    ThemeData theme,
    dynamic user,
    AsyncValue<int> totalStars,
    AsyncValue<int> completedLevels,
    AsyncValue<int> totalTime,
    AsyncValue<double> accuracy,
    SessionStats sessionStats,
    AppLocalizations l10n,
  ) {
    return Stack(
      children: [
        // Subtle particle background
        Positioned.fill(
          child: _buildParticleBackground(theme),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.scaffoldBackgroundColor,
                theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                theme.colorScheme.surface.withValues(alpha: 0.3),
              ],
            ),
          ),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeSection(theme),
                      const SizedBox(height: 24),
                  _buildStatsOverview(
                    theme, totalStars, completedLevels, totalTime, accuracy, l10n,
                  ),
                  const SizedBox(height: 24),
                  _buildSessionStats(theme, sessionStats, l10n),
                      const SizedBox(height: 32),
                      _buildQuickActions(theme),
                      const SizedBox(height: 32),
                      _buildDailyChallenge(theme),
                      const SizedBox(height: 32),
                      _buildGameModesGrid(theme),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(ThemeData theme) {
    return AnimatedBuilder(
      animation: _cardSlideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _cardSlideAnimation.value),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
                  theme.colorScheme.secondaryContainer.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.welcomeBack,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.masterMathematicsDesc,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.rocket_launch,
                        color: theme.colorScheme.primary,
                        size: 32,
                      ),
                    ).animate()
                        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.1, 1.1))
                        .then()
                        .scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDailyProgressIndicator(theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyProgressIndicator(ThemeData theme) {
    // Mock daily progress - in real app this would come from user data
    const int dailyGoal = 10;
    const int completedToday = 3;

    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: theme.colorScheme.primary,
            size: 16,
          ).animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '$completedToday/$dailyGoal',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ).animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideX(begin: 0.2, end: 0),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            height: 4,
            child: LinearProgressIndicator(
              value: completedToday / dailyGoal,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ).animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .scale(begin: const Offset(0, 1), end: const Offset(1, 1), alignment: Alignment.centerLeft),
        ],
      ),
    ).animate()
        .fadeIn(duration: 500.ms, delay: 300.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatsOverview(
    ThemeData theme,
    AsyncValue<int> totalStars,
    AsyncValue<int> completedLevels,
    AsyncValue<int> totalTime,
    AsyncValue<double> accuracy,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.yourProgress,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                l10n.starsEarned,
                totalStars.when(
                  data: (v) => '$v ⭐',
                  loading: () => '...',
                  error: (_, _) => '0 ⭐',
                ),
                theme.colorScheme.primary,
                Icons.star,
                theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                l10n.levelsCompleted,
                completedLevels.when(
                  data: (v) => '$v 🎯',
                  loading: () => '...',
                  error: (_, _) => '0 🎯',
                ),
                theme.colorScheme.secondary,
                Icons.flag,
                theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                l10n.timePlayed,
                totalTime.when(
                  data: (v) => '${(v / 60).toStringAsFixed(1)}h ⏰',
                  loading: () => '...',
                  error: (_, _) => '0h ⏰',
                ),
                theme.colorScheme.tertiary,
                Icons.timer,
                theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                l10n.accuracy,
                accuracy.when(
                  data: (v) => '${(v * 100).toStringAsFixed(1)}% 🎯',
                  loading: () => '...',
                  error: (_, _) => '0% 🎯',
                ),
                theme.colorScheme.error,
                Icons.trending_up,
                theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon, ThemeData theme) {
    final isLoading = value == '...' || value == '0 ⭐' || value == '0 🎯' || value == '0h ⏰' || value == '0% 🎯';

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isLoading ? null : [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 24),
          ).animate(target: isLoading ? 1 : 0)
              .shimmer(duration: 1200.ms, color: color.withValues(alpha: 0.3)),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ).animate(target: isLoading ? 1 : 0)
              .shimmer(duration: 1200.ms, color: color.withValues(alpha: 0.3)),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
        .then(delay: 200.ms)
        .shake(curve: Curves.elasticOut);
  }

  Widget _buildSessionStats(ThemeData theme, SessionStats sessionStats, AppLocalizations l10n) {
    if (sessionStats.questionsAnswered == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Session',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSessionStatCard(
                '${sessionStats.questionsAnswered}',
                'Questions',
                theme.colorScheme.primary,
                theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSessionStatCard(
                '${sessionStats.accuracy.toStringAsFixed(1)}%',
                'Accuracy',
                theme.colorScheme.secondary,
                theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSessionStatCard(
                '${sessionStats.timeSpent ~/ 60}m',
                'Time',
                theme.colorScheme.tertiary,
                theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSessionStatCard(String value, String label, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child:               _buildActionButton(
                l10n.calculator,
                Icons.calculate,
                theme.colorScheme.primary,
                () => _navigateToScreen(const CalculatorScreen()),
                theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child:               _buildActionButton(
                l10n.reports,
                Icons.bar_chart,
                theme.colorScheme.secondary,
                () => _navigateToScreen(const ReportsScreen()),
                theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onPressed, ThemeData theme) {
    return InkWell(
      onTap: () {
        HapticManager.selectionClick();
        onPressed();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    ).animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildDailyChallenge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.tertiaryContainer.withValues(alpha: 0.8),
            theme.colorScheme.surface.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: theme.colorScheme.tertiary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.dailyChallenge,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.completeTodaysChallenge,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.challengeReward,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.play_arrow,
              color: theme.colorScheme.tertiary,
              size: 32,
            ),
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 700.ms)
        .slideX(begin: 0.2, end: 0);
  }

  Widget _buildGameModesGrid(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.gameModes,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: 5,
          itemBuilder: (context, index) {
            final gameModes = [
              {
                'title': l10n.campaign,
                'subtitle': l10n.completeLevelsProgressively,
                'icon': Icons.map,
                'color': theme.colorScheme.primary,
                'screen': const CampaignScreen(),
              },
              {
                'title': l10n.arcade,
                'subtitle': l10n.fastPacedChallenges,
                'icon': Icons.flash_on,
                'color': theme.colorScheme.secondary,
                'screen': const ArcadeScreen(),
              },
              {
                'title': l10n.practice,
                'subtitle': l10n.improveSpecificSkills,
                'icon': Icons.school,
                'color': theme.colorScheme.tertiary,
                'screen': const PracticeScreen(),
              },
              {
                'title': l10n.customMix,
                'subtitle': l10n.createYourOwnChallenges,
                'icon': Icons.shuffle,
                'color': theme.colorScheme.error,
                'screen': const CustomMixScreen(),
              },
              {
                'title': l10n.logicRiddles,
                'subtitle': l10n.solveLogicChallenges,
                'icon': Icons.extension,
                'color': theme.colorScheme.surfaceTint,
                'screen': const MathRiddleLevelSelectionScreen(),
              },
            ];

            final mode = gameModes[index];
            return _buildGameModeCard(
              mode['title'] as String,
              mode['icon'] as IconData,
              mode['color'] as Color,
              () => _navigateToScreen(mode['screen'] as Widget),
              theme,
            );
          },
        ),
      ],
    );
  }

  Widget _buildGameModeCard(String title, IconData icon, Color color, VoidCallback onPressed, ThemeData theme) {
    return InkWell(
      onTap: () {
        HapticManager.selectionClick();
        onPressed();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ).animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
        .then(delay: 100.ms);
  }

  Widget _buildAnimatedFAB(ThemeData theme) {
    return AnimatedBuilder(
      animation: _fabScaleAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Transform.scale(
            scale: _fabScaleAnimation.value,
            child: FloatingActionButton(
              onPressed: () {
                HapticManager.selectionClick();
                ref.read(soundManagerProvider).playEffect('click');
                _showQuickStartDialog(theme);
              },
              backgroundColor: Colors.transparent,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.play_arrow, size: 28),
            ),
          ),
        ).animate()
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.05, 1.05))
            .then()
            .scale(begin: const Offset(1.05, 1.05), end: const Offset(1, 1));
      },
    );
  }

  Widget _buildModernBottomNav(ThemeData theme, AppLocalizations l10n) {
    return SafeArea(
      bottom: true,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedItemColor: theme.colorScheme.primary,
            unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            currentIndex: 0,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined, size: 24),
                activeIcon: const Icon(Icons.home, size: 24),
                label: l10n.home,
                tooltip: l10n.home,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.games_outlined, size: 24),
                activeIcon: const Icon(Icons.games, size: 24),
                label: l10n.gameModes,
                tooltip: l10n.gameModes,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.bar_chart_outlined, size: 24),
                activeIcon: const Icon(Icons.bar_chart, size: 24),
                label: l10n.stats,
                tooltip: l10n.stats,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline, size: 24),
                activeIcon: const Icon(Icons.person, size: 24),
                label: l10n.profile,
                tooltip: l10n.profile,
              ),
            ],
            onTap: (index) {
              switch (index) {
                case 0:
                  // Already on home
                  break;
                case 1:
                  _navigateToScreen(const ArcadeScreen());
                  break;
                case 2:
                  _navigateToScreen(const ReportsScreen());
                  break;
                case 3:
                  _navigateToScreen(const ProfileScreen());
                  break;
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildParticleBackground(ThemeData theme) {
    return Stack(
      children: List.generate(15, (index) {
        return Positioned(
          left: (index * 53.0) % MediaQuery.of(context).size.width,
          top: (index * 97.0) % MediaQuery.of(context).size.height,
          child: Container(
            width: 2 + (index % 3).toDouble(),
            height: 2 + (index % 3).toDouble(),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05 + (index % 3) * 0.01),
              shape: BoxShape.circle,
            ),
          ).animate()
              .fadeIn(duration: 2000.ms)
              .moveY(begin: 0, end: -30, duration: 4000.ms + (index * 300).ms),
        );
      }),
    );
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showQuickStartDialog(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Icon(
              Icons.rocket_launch,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              l10n.quickStart,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuickStartOption(
              l10n.campaignMode,
              l10n.startYourMathematicalJourney,
              Icons.map,
              () {
                Navigator.pop(context);
                _navigateToScreen(const CampaignScreen());
              },
              theme,
            ),
            const SizedBox(height: 12),
            _buildQuickStartOption(
              l10n.practiceMode,
              l10n.focusOnSpecificOperations,
              Icons.school,
              () {
                Navigator.pop(context);
                _navigateToScreen(const PracticeScreen());
              },
              theme,
            ),
            const SizedBox(height: 12),
            _buildQuickStartOption(
              l10n.arcadeMode,
              l10n.fastPacedGamingExperience,
              Icons.flash_on,
              () {
                Navigator.pop(context);
                _navigateToScreen(const ArcadeScreen());
              },
              theme,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStartOption(String title, String subtitle, IconData icon, VoidCallback onPressed, ThemeData theme) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}