import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers.dart';
import '../../../core/themes/app_themes.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../calculator/calculator_screen.dart';
import '../../profile_setup/profile_setup_screen.dart';
import 'avatar_shop_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(userSessionProvider);
    final theme = Theme.of(context);
    final totalStars = ref.watch(totalStarsProvider);
    final completedLevels = ref.watch(completedLevelsProvider);
    final totalTime = ref.watch(totalTimePlayedProvider);
    final accuracy = ref.watch(overallAccuracyProvider);
    final currentLocale = ref.watch(localeProvider);
    final settings = ref.watch(settingsProvider);
    final currentTheme = ref.watch(themeProvider);

    // Show loading if user is not initialized yet
    if (user == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Technical HUD Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/grid.png',
                repeat: ImageRepeat.repeat,
                errorBuilder: (context, error, stackTrace) => Container(),
              ),
            ),
          ),
          // Scanline Overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Image.asset(
                'assets/images/scanline.png',
                repeat: ImageRepeat.repeat,
                errorBuilder: (context, error, stackTrace) => Container(),
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(context, ref, user, theme, l10n),
                ),
                SliverToBoxAdapter(
                  child: _buildStats(
                    totalStars,
                    completedLevels,
                    totalTime,
                    accuracy,
                    theme,
                    l10n,
                  ),
                ),
                SliverToBoxAdapter(
                    child: _buildMenuSection(
                      context,
                      ref,
                      theme,
                      currentLocale,
                      currentTheme,
                      settings,
                      l10n,
                    ),
                ),
                SliverToBoxAdapter(
                  child: _buildAchievementsSection(
                    theme,
                    totalStars.value ?? 0,
                    accuracy.value ?? 0.0,
                    totalTime.value ?? 0,
                    l10n,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.userProfile,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      l10n.systemStatusActive,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileSetupScreen(),
                    ),
                  );
                },
                icon: GlassmorphicContainer(
                  padding: const EdgeInsets.all(8),
                  borderRadius: 12,
                  child: Icon(
                    Icons.edit,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .rotate(duration: const Duration(seconds: 10)),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _parseColor(context, user?.avatarColor ?? '#00F5FF').withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _parseColor(context, user?.avatarColor ?? '#00F5FF'),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _parseColor(context, user?.avatarColor ?? '#00F5FF').withValues(alpha: 0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _getAvatarIcon(user?.avatarShape ?? 'circle'),
                    color: _parseColor(context, user?.avatarColor ?? '#00F5FF'),
                    size: 50,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            user?.name?.toUpperCase() ?? l10n.player,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 8),
          GlassmorphicContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            borderRadius: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stars,
                  color: AppDesignTokens.neonYellow,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${user?.totalPoints ?? 0} PTS',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppDesignTokens.neonYellow,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(
    AsyncValue<int> totalStars,
    AsyncValue<int> completedLevels,
    AsyncValue<int> totalTime,
    AsyncValue<double> accuracy,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: PremiumCard(
        padding: const EdgeInsets.all(20),
        borderRadius: AppDesignTokens.radiusMedium,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
                l10n.stars,
              totalStars.when(
                data: (v) => '$v',
                loading: () => '...',
                error: (_, _) => '0',
              ),
              Icons.star,
              AppDesignTokens.neonYellow,
              theme,
            ),
            _buildStatItem(
                l10n.level,
              completedLevels.when(
                data: (v) => '$v',
                loading: () => '...',
                error: (_, _) => '0',
              ),
              Icons.check_circle,
              theme.colorScheme.primary,
              theme,
            ),
            _buildStatItem(
                l10n.time,
              totalTime.when(
                data: (v) => '${v}m',
                loading: () => '...',
                error: (_, _) => '0m',
              ),
              Icons.timer,
              theme.colorScheme.primary,
              theme,
            ),
            _buildStatItem(
                l10n.accuracy,
              accuracy.when(
                data: (v) => '${v.toStringAsFixed(0)}%',
                loading: () => '...',
                error: (_, _) => '0%',
              ),
              Icons.analytics,
              theme.colorScheme.secondary,
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Icon(icon, color: color.withValues(alpha: 0.6), size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            fontSize: 9,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocale currentLocale,
    AppThemeType currentTheme,
    SettingsState settings,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(l10n.storeAndCustomization, theme),
          const SizedBox(height: 12),
          _buildMenuCard(
            icon: Icons.storefront,
            title: 'Avatar Shop',
            subtitle: l10n.unlockNewAvatarsWithPoints,
            color: AppDesignTokens.neonYellow,
            theme: theme,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AvatarShopScreen()),
              );
            },
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(l10n.systemSettings, theme),
          const SizedBox(height: 12),
          _buildMenuCard(
            icon: Icons.calculate,
            title: 'Calculator',
            subtitle: l10n.builtInArithmeticTool,
            color: theme.colorScheme.primary,
            theme: theme,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalculatorScreen()),
              );
            },
          ),
          _buildMenuCard(
            icon: Icons.color_lens,
              title: l10n.visualTheme,
            subtitle: AppThemes.getThemeName(currentTheme).toUpperCase(),
            color: theme.colorScheme.secondary,
            theme: theme,
            onTap: () => _showThemeDialog(context, ref, currentTheme, theme),
          ),
          _buildMenuCard(
            icon: Icons.language,
              title: l10n.language,
            subtitle: '${currentLocale.flag} ${currentLocale.nativeName}'.toUpperCase(),
            color: theme.colorScheme.primary,
            theme: theme,
            onTap: () => _showLanguageDialog(context, ref, currentLocale),
            trailing: IconButton(
              icon: const Icon(Icons.swap_horiz, size: 20),
              onPressed: () {
                ref.read(localeProvider.notifier).toggleLanguage();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${l10n.switchedTo} ${ref.read(localeProvider).name}'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
              tooltip: l10n.quickLanguageToggle,
            ),
          ),
          _buildMenuCard(
            icon: Icons.notifications,
              title: l10n.notifications,
            subtitle: l10n.pushUpdates,
            color: theme.colorScheme.secondary,
            theme: theme,
            trailing: Switch(
              value: settings.notificationsEnabled,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).toggleNotifications(value);
              },
              activeThumbColor: theme.colorScheme.secondary,
            ),
          ),
          _buildMenuCard(
            icon: Icons.volume_up,
              title: l10n.audioOutput,
            subtitle: l10n.sfxAndMusic,
            color: theme.colorScheme.tertiary,
            theme: theme,
            trailing: Switch(
              value: settings.soundEnabled,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).toggleSound(value);
              },
              activeThumbColor: theme.colorScheme.tertiary,
            ),
          ),
           _buildMenuCard(
            icon: Icons.vibration,
              title: l10n.hapticFeedback,
            subtitle: l10n.tactileResponse,
            color: theme.colorScheme.error,
            theme: theme,
            trailing: Switch(
              value: settings.hapticsEnabled,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).toggleHaptics(value);
              },
              activeThumbColor: theme.colorScheme.error,
            ),
           ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required ThemeData theme,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: PremiumCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        borderRadius: AppDesignTokens.radiusSmall,
        child: ListTile(
          leading: Icon(icon, color: color, size: 20),
          title: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          trailing:
              trailing ?? Icon(Icons.chevron_right, color: color, size: 20),
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(
    ThemeData theme,
    int totalStars,
    double accuracy,
    int totalTime,
    AppLocalizations l10n,
  ) {
    final achievements = [
      {
        'icon': Icons.star,
        'title': l10n.stargazer,
        'progress': (totalStars / 50).clamp(0.0, 1.0),
        'color': theme.colorScheme.secondary,
      },
      {
        'icon': Icons.my_location,
        'title': l10n.sharpshooter,
        'progress': accuracy, // Needs 100% accuracy to fill
        'color': theme.colorScheme.primary,
      },
      {
        'icon': Icons.watch_later,
        'title': l10n.timeLord,
        'progress': (totalTime / 3600).clamp(0.0, 1.0), // 1 hour of playtime
        'color': theme.colorScheme.tertiary,
      },
      {
        'icon': Icons.school,
        'title': l10n.scholar,
        'progress': (totalStars / 120).clamp(0.0, 1.0), // All campaign stars
        'color': theme.colorScheme.primary,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.achievements,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (achievement['color'] as Color).withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        achievement['icon'] as IconData,
                        color: achievement['color'] as Color,
                        size: 28,
                      ),
                      const Spacer(),
                      Text(
                        achievement['title'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: achievement['progress'] as double,
                        backgroundColor: (achievement['color'] as Color)
                            .withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation(
                          achievement['color'] as Color,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocale currentLocale,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          l10n.language,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLocale.supportedLocales.map((locale) {
            return ListTile(
              leading: Text(locale.flag, style: const TextStyle(fontSize: 24)),
              title: Text(locale.name),
              subtitle: Text(locale.nativeName),
              selected: currentLocale == locale,
              selectedTileColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(locale);
                Navigator.pop(context);
                // Show success feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${l10n.languageChanged} ${locale.name}'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.continueGame),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    AppThemeType currentTheme,
    ThemeData theme,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppThemeType.values.map((themeType) {
              final isSelected = currentTheme == themeType;
              return ListTile(
                leading: Icon(
                  _getThemeIcon(themeType),
                  color: isSelected ? theme.colorScheme.primary : null,
                ),
                title: Text(AppThemes.getThemeName(themeType)),
                selected: isSelected,
                onTap: () {
                  ref.read(themeProvider.notifier).setTheme(themeType);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  IconData _getThemeIcon(AppThemeType type) {
    switch (type) {
      case AppThemeType.midnight:
        return Icons.dark_mode;
    }
  }

  IconData _getAvatarIcon(String shape) {
    switch (shape) {
      case 'circle':
        return Icons.circle;
      case 'square':
        return Icons.square;
      case 'triangle':
        return Icons.change_history;
      case 'star':
        return Icons.star;
      case 'diamond':
        return Icons.diamond;
      default:
        return Icons.circle;
    }
  }

  Color _parseColor(BuildContext context, String colorString) {
    final theme = Theme.of(context);
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
      } else {
        return Color(int.parse(colorString));
      }
    } catch (e) {
      return theme.colorScheme.primary; // Default theme primary color
    }
  }
}
