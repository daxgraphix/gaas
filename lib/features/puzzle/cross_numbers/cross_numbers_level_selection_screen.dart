import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/level_progress.dart';
import '../../../core/providers.dart';
import '../../../core/themes/app_themes.dart';
import '../../../core/sound_manager.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'cross_numbers_screen.dart';

class CrossNumbersLevelSelectionScreen extends ConsumerWidget {
  const CrossNumbersLevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final progressMap = ref.watch(levelProgressProvider);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.crossNumbers.toUpperCase(),
          style: const TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 120),
            _buildHeader(theme, l10n),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: 40, // Increased to 40 levels
                itemBuilder: (context, index) {
                  final level = index + 1;
                  final progress = progressMap['cross_numbers']?.firstWhere(
                    (p) => p.level == level,
                    orElse: () => LevelProgress(
                      operationId: 'cross_numbers',
                      level: level,
                      stars: 0,
                      isUnlocked: level == 1,
                      highScore: 0,
                    ),
                  );
                  final isUnlocked = progress?.isUnlocked ?? (level == 1);
                  final stars = progress?.stars ?? 0;

                  return _buildLevelButton(context, ref, theme, level, isUnlocked, stars);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.grid_4x4_rounded,
              color: Colors.deepOrange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MATHEMATICAL GRIDS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'Solve equations in every direction',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
    );
  }

  Widget _buildLevelButton(
    BuildContext context, 
    WidgetRef ref, 
    ThemeData theme, 
    int level, 
    bool isUnlocked, 
    int stars
  ) {
    return InkWell(
      onTap: isUnlocked ? () {
        HapticManager.instance.selectionClick();
        ref.read(soundManagerProvider).playEffect('click');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CrossNumbersScreen(difficulty: level),
          ),
        );
      } : null,
      borderRadius: BorderRadius.circular(16),
      child: PremiumCard(
        padding: EdgeInsets.zero,
        borderColor: isUnlocked 
            ? theme.colorScheme.primary.withValues(alpha: 0.3) 
            : Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isUnlocked 
                ? null 
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (!isUnlocked)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$level',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Icon(
                      Icons.lock_outline_rounded, 
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2), 
                      size: 14
                    ),
                  ],
                ),
              if (isUnlocked)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$level',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (stars > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (i) => Icon(
                          Icons.star_rounded,
                          size: 10,
                          color: i < stars ? Colors.amber : theme.colorScheme.outline.withValues(alpha: 0.3),
                        )),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    ).animate().scale(
      delay: (level % 10 * 50).ms,
      duration: 400.ms,
      curve: Curves.easeOutBack,
    );
  }
}
