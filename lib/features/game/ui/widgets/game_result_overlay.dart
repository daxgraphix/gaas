import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/themes/app_themes.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../logic/game_session_provider.dart';

class GameResultOverlay extends ConsumerWidget {
  final GameSession session;
  final VoidCallback onAction;
  final VoidCallback onAbort;

  const GameResultOverlay({
    super.key,
    required this.session,
    required this.onAction,
    required this.onAbort,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gameTheme = theme.extension<GameThemeExtension>()!;
    final l10n = AppLocalizations.of(context)!;
    final percentage = session.accuracy;
    final isCampaign = session.mode == GameMode.campaign;
    final passed = session.passed;
    final stars = session.stars;
    final isDuel = session.mode == GameMode.duel;
    final playerWon = session.playerWon;

    return Center(
      child: PremiumGlassOverlay(
        padding: const EdgeInsets.all(32),
        borderRadius: 32,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isDuel
                  ? (playerWon == true ? l10n.victory : l10n.defeat)
                  : (passed ? l10n.levelStabilized : l10n.integrityFailed),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: passed ? gameTheme.timerColor : theme.colorScheme.error,
                letterSpacing: 4,
                fontWeight: FontWeight.w900,
              ),
            ).animate().fadeIn().scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            if (!isDuel && isCampaign)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      index < stars ? Icons.star : Icons.star_border,
                      color: index < stars ? Colors.amber : gameTheme.timerColor.withValues(alpha: 0.2),
                      size: 48,
                    ),
                  );
                }),
              ).animate(delay: 200.ms).fadeIn().scale(),
            const SizedBox(height: 40),
            _buildStatGrid(context, session, percentage, theme, gameTheme, l10n),
            const SizedBox(height: 40),
            PremiumPrimaryButton(
              text: isCampaign ? (passed ? l10n.nextLevel.toUpperCase() : l10n.tryAgain.toUpperCase()) : l10n.playAgain,
              onPressed: onAction,
            ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onAbort,
              child: Text(
                l10n.backToMenu.toUpperCase(),
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ).animate(delay: 800.ms).fadeIn(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid(BuildContext context, GameSession session, double percentage, ThemeData theme, GameThemeExtension gameTheme, AppLocalizations l10n) {
    return Column(
      children: [
        _buildMinimalResultRow(l10n.coreScore, '${session.score}', theme, gameTheme.timerColor),
        _buildMinimalResultRow(
          l10n.accuracy.toUpperCase(),
          '${percentage.toStringAsFixed(0)}%',
          theme,
          gameTheme.timerColor,
        ),
        _buildMinimalResultRow(
          l10n.completed.toUpperCase(),
          '${session.correctAnswers} / ${session.totalQuestions}',
          theme,
          gameTheme.timerColor,
        ),
        if (session.bestStreak > 0)
          _buildMinimalResultRow(l10n.bestStreak.toUpperCase(), '${session.bestStreak}', theme, gameTheme.streakColor),
      ],
    );
  }

  Widget _buildMinimalResultRow(String label, String value, ThemeData theme, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: accentColor,
              letterSpacing: 2,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

}
