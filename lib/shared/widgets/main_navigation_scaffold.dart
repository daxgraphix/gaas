import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/themes/app_themes.dart';
import '../../core/sound_manager.dart';
import '../../core/providers.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/arcade/presentation/arcade_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigationScaffold extends ConsumerWidget {
  const MainNavigationScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currentIndex = ref.watch(navigationIndexProvider);

    final List<Widget> screens = [
      const HomeScreen(),
      const ArcadeScreen(),
      const ReportsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true,
      body: Stack(
        children: [
          // Global Background Mesh
          Positioned.fill(
            child: _buildGlobalBackground(theme),
          ),
          // Screens with Tab Transition
          IndexedStack(
            index: currentIndex,
            children: screens.map((screen) {
              return screen.animate(
                key: ValueKey('tab_$currentIndex'),
              )
              .fadeIn(duration: 300.ms, curve: Curves.easeOut)
              .slideX(begin: 0.05, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
            }).toList(),
          ),
        ],
      ),
      bottomNavigationBar: _buildUnifiedBottomNav(context, ref, theme, l10n, currentIndex),
    );
  }

  Widget _buildGlobalBackground(ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    theme.colorScheme.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.secondary.withValues(alpha: 0.05),
                    theme.colorScheme.secondary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedBottomNav(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
    int currentIndex,
  ) {
    return SafeArea(
      bottom: true,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: PremiumGlassOverlay(
          padding: EdgeInsets.zero,
          borderRadius: 24,
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(ref, 0, Icons.home_rounded, Icons.home_outlined, l10n.home, currentIndex, theme),
                _buildNavItem(ref, 1, Icons.sports_esports_rounded, Icons.sports_esports_outlined, l10n.arcade, currentIndex, theme),
                _buildNavItem(ref, 2, Icons.bar_chart_rounded, Icons.bar_chart_outlined, l10n.stats, currentIndex, theme),
                _buildNavItem(ref, 3, Icons.person_rounded, Icons.person_outline_rounded, l10n.profile, currentIndex, theme),
              ],
            ),
          ),
        ),
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildNavItem(
    WidgetRef ref,
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
    int currentIndex,
    ThemeData theme,
  ) {
    final isSelected = currentIndex == index;
    final color = isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.5);

    return InkWell(
      onTap: () {
        if (!isSelected) {
          HapticManager.instance.selectionClick();
          ref.read(soundManagerProvider).playEffect('click');
          ref.read(navigationIndexProvider.notifier).state = index;
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: color,
              size: 26,
            ).animate(target: isSelected ? 1 : 0)
             .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1))
             .then()
             .shake(hz: 4, offset: const Offset(2, 0)),
            if (isSelected)
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn().slideY(begin: 0.5, end: 0),
          ],
        ),
      ),
    );
  }
}
