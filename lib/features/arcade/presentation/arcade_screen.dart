import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_themes.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../game/logic/game_session_provider.dart';
import '../../game/ui/game_screen.dart';

class ArcadeScreen extends ConsumerWidget {
  const ArcadeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.arcade),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/carbon-fibre.png',
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                _buildSectionHeader(l10n.gameModes, theme),
                const SizedBox(height: 16),
                _buildArcadeListItem(
                  context,
                  l10n.scoreAttack,
                  l10n.scoreAttackDesc,
                  () => _showOperationDialog(context, ref, GameMode.scoreAttack),
                  theme.colorScheme.primary,
                ),
                _buildArcadeListItem(
                  context,
                  l10n.endless,
                  l10n.endlessDesc,
                  () => _showOperationDialog(context, ref, GameMode.endless),
                  theme.colorScheme.secondary,
                ),
                _buildArcadeListItem(
                  context,
                  l10n.duel,
                  l10n.duelDesc,
                  () => _showOperationDialog(context, ref, GameMode.duel),
                  AppDesignTokens.neonYellow,
                ),
                _buildArcadeListItem(
                  context,
                  l10n.flash,
                  l10n.flashDesc,
                  () => _showOperationDialog(context, ref, GameMode.flash),
                  AppDesignTokens.neonPink,
                ),
                const SizedBox(height: 32),
                _buildSectionHeader(l10n.activeChallenges, theme),
                const SizedBox(height: 16),
                _buildArcadeListItem(
                  context,
                  l10n.speedDemon,
                  l10n.speedDemonDesc,
                  () => _showOperationDialog(context, ref, GameMode.speedDemon),
                  theme.colorScheme.primary,
                ),
                _buildArcadeListItem(
                  context,
                  l10n.mathMaster,
                  l10n.mathMasterDesc,
                  () => _showOperationDialog(context, ref, GameMode.mathMaster),
                  theme.colorScheme.secondary,
                ),
                _buildArcadeListItem(
                  context,
                  l10n.marathon,
                  l10n.marathonDesc,
                  () => _showOperationDialog(context, ref, GameMode.marathon),
                  AppDesignTokens.neonPink,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.labelSmall?.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 4,
        color: theme.colorScheme.primary.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildArcadeListItem(
    BuildContext context,
    String title,
    String subtitle,
    VoidCallback onTap,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PremiumCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        borderRadius: AppDesignTokens.radiusSmall,
        borderColor: color.withValues(alpha: 0.3),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: color.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showOperationDialog(
    BuildContext context,
    WidgetRef ref,
    GameMode mode,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const BeveledRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                l10n.selectOperation,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
            _buildOperationItem(
              context,
              ref,
              l10n.addition,
              '+',
              l10n.additionProcedure,
              mode,
            ),
            _buildOperationItem(
              context,
              ref,
              l10n.subtraction,
              '-',
              l10n.subtractionProcedure,
              mode,
            ),
            _buildOperationItem(
              context,
              ref,
              l10n.multiplication,
              '×',
              l10n.multiplicationProcedure,
              mode,
            ),
            _buildOperationItem(
              context,
              ref,
              l10n.division,
              '÷',
              l10n.divisionProcedure,
              mode,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationItem(
    BuildContext context,
    WidgetRef ref,
    String operation,
    String symbol,
    String label,
    GameMode mode,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _startGame(context, ref, operation, mode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1), width: 0.5)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                symbol,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w100,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _startGame(
    BuildContext context,
    WidgetRef ref,
    String operation,
    GameMode mode,
  ) {
    // For modes that need level selection, show level dialog
    if ([GameMode.scoreAttack, GameMode.duel, GameMode.speedDemon, GameMode.mathMaster].contains(mode)) {
      _showLevelDialog(context, ref, operation, mode);
    } else {
      _launchGame(context, ref, operation, mode, 1);
    }
  }

  void _showLevelDialog(BuildContext context, WidgetRef ref, String operation, GameMode mode) {
    final theme = Theme.of(context);
    int selectedLevel = 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SELECT DIFFICULTY LEVEL',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(30, (index) {
                        final level = index + 1;
                        final difficulty = level <= 10 ? 'Easy' : level <= 20 ? 'Medium' : 'Hard';
                        final color = level <= 10 ? Colors.green : level <= 20 ? Colors.orange : Colors.red;
                        return ChoiceChip(
                          label: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('L$level', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              Text(difficulty, style: TextStyle(fontSize: 8, color: color)),
                            ],
                          ),
                          selected: selectedLevel == level,
                          onSelected: (selected) {
                            if (selected) setState(() => selectedLevel = level);
                          },
                          backgroundColor: theme.colorScheme.surface,
                          selectedColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          checkmarkColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _launchGame(context, ref, operation, mode, selectedLevel);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('START GAME'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _launchGame(BuildContext context, WidgetRef ref, String operation, GameMode mode, int level) {
    int totalQuestions = 60; // Increased base questions for more challenge

    if (mode == GameMode.scoreAttack) {
      totalQuestions = 200; // Increased - survive longer under time pressure
    } else if (mode == GameMode.endless) {
      totalQuestions = 300; // Increased - more endurance required
    } else if (mode == GameMode.duel) {
      totalQuestions = 50; // Increased - longer duels
    } else if (mode == GameMode.flash) {
      totalQuestions = 45; // Increased - more memory challenges
    } else if (mode == GameMode.speedDemon) {
      totalQuestions = 35; // Increased - faster paced speed round
    } else if (mode == GameMode.mathMaster) {
      totalQuestions = 80; // Increased - test all operations more thoroughly
    } else if (mode == GameMode.marathon) {
      totalQuestions = 300; // Increased - ultimate endurance test
    }

    // Scale difficulty based on level for arcade modes
    if (level > 1) {
      totalQuestions = (totalQuestions * (1 + level * 0.1)).round(); // 10% increase per level
    }

    // Set appropriate time limits based on mode and level
    int? timeLimit;
    if (mode == GameMode.scoreAttack) {
      timeLimit = 90 + (level * 5); // 90-240 seconds based on level
    } else if (mode == GameMode.speedDemon) {
      timeLimit = 45 + (level * 2); // 45-90 seconds for speed rounds
    } else if (mode == GameMode.flash) {
      timeLimit = 60 + (level * 3); // Memory challenges get more time
    }

    ref
        .read(gameSessionProvider.notifier)
        .startGame(
          mode: mode,
          operation: operation,
          level: level,
          totalQuestions: totalQuestions,
          timeLimit: timeLimit,
        );
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const GameScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
