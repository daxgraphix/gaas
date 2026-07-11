import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_themes.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../logic/game_session_provider.dart';

class GameScreen extends ConsumerWidget {
  GameScreen({super.key});

  final _inputProvider = StateProvider.autoDispose<String>((ref) => '');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(gameSessionProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (session == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (session.state == GameState.finished) {
      return _buildResultsScreen(context, ref, session, theme, l10n);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitConfirmation(context, ref),
        ),
        title: Text(
          session.mode == GameMode.campaign
              ? '${l10n.levelPrefix}${session.level}'
              : session.mode.name.toUpperCase(),
        ),
        actions: [
          IconButton(
            icon: Icon(session.state == GameState.paused ? Icons.play_arrow : Icons.pause),
            onPressed: () {
              if (session.state == GameState.paused) {
                ref.read(gameSessionProvider.notifier).resumeGame();
              } else {
                ref.read(gameSessionProvider.notifier).pauseGame();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(session, theme, l10n),
                const Spacer(),
                _buildQuestionArea(session, theme),
                const Spacer(),
                _buildNumpad(context, ref, theme),
              ],
            ),
          ),
          if (session.state == GameState.paused)
            _buildPauseOverlay(context, ref, theme, l10n),
        ],
      ),
    );
  }

  Widget _buildHeader(GameSession session, ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.score,
                style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${session.score}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          if (session.timeRemaining > 0 || session.mode == GameMode.scoreAttack)
            _buildTimer(session, theme),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'STREAK',
                style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'x${session.comboMultiplier}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimer(GameSession session, ThemeData theme) {
    final color = session.timeRemaining < 10 ? theme.colorScheme.error : theme.colorScheme.primary;
    return Column(
      children: [
        Text(
          'TIME',
          style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          '${session.timeRemaining}s',
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionArea(GameSession session, ThemeData theme) {
    if (session.currentQuestion == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            session.currentQuestion!.displayString,
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'Question ${session.currentQuestionIndex + 1} of ${session.totalQuestions}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumpad(BuildContext context, WidgetRef ref, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInputDisplay(theme, ref),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildNumpadButton(context, ref, '1', theme),
              _buildNumpadButton(context, ref, '2', theme),
              _buildNumpadButton(context, ref, '3', theme),
            ],
          ),
          Row(
            children: [
              _buildNumpadButton(context, ref, '4', theme),
              _buildNumpadButton(context, ref, '5', theme),
              _buildNumpadButton(context, ref, '6', theme),
            ],
          ),
          Row(
            children: [
              _buildNumpadButton(context, ref, '7', theme),
              _buildNumpadButton(context, ref, '8', theme),
              _buildNumpadButton(context, ref, '9', theme),
            ],
          ),
          Row(
            children: [
              _buildNumpadButton(context, ref, 'C', theme, color: theme.colorScheme.error),
              _buildNumpadButton(context, ref, '0', theme),
              _buildNumpadButton(context, ref, 'OK', theme, color: theme.colorScheme.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputDisplay(ThemeData theme, WidgetRef ref) {
    final input = ref.watch(_inputProvider);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        input.isEmpty ? '?' : input,
        textAlign: TextAlign.center,
        style: theme.textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: input.isEmpty
              ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
              : theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildNumpadButton(BuildContext context, WidgetRef ref, String label, ThemeData theme, {Color? color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PremiumAnimatedButton(
          onPressed: () {
            final currentInput = ref.read(_inputProvider);
            if (label == 'OK') {
              if (currentInput.isNotEmpty) {
                ref.read(gameSessionProvider.notifier).answerQuestion(currentInput);
                ref.read(_inputProvider.notifier).state = '';
              }
            } else if (label == 'C') {
              ref.read(_inputProvider.notifier).state = '';
            } else {
              if (currentInput.length < 5) {
                ref.read(_inputProvider.notifier).state = currentInput + label;
              }
            }
          },
          backgroundColor: color?.withValues(alpha: 0.1) ?? theme.colorScheme.surfaceContainerHighest,
          borderColor: color ?? theme.colorScheme.outline,
          borderWidth: 2,
          borderRadius: 12,
          child: Text(
            label,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsScreen(BuildContext context, WidgetRef ref, GameSession session, ThemeData theme, AppLocalizations l10n) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                session.passed ? l10n.levelComplete : l10n.gameOver,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: session.passed ? theme.colorScheme.primary : theme.colorScheme.error,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 32),
              PremiumCard(
                child: Column(
                  children: [
                    _buildResultRow(l10n.score, '${session.score}', theme),
                    const Divider(),
                    _buildResultRow(l10n.accuracy, '${session.accuracy.toStringAsFixed(1)}%', theme),
                    const Divider(),
                    _buildResultRow('CORRECT', '${session.correctAnswers}/${session.totalQuestions}', theme),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: PremiumPrimaryButton(
                  text: l10n.continueText,
                  onPressed: () {
                    ref.read(gameSessionProvider.notifier).endGame();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.titleMedium),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildPauseOverlay(BuildContext context, WidgetRef ref, ThemeData theme, AppLocalizations l10n) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.gamePaused.toUpperCase(),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 48),
            PremiumPrimaryButton(
              width: 200,
              text: l10n.resume,
              onPressed: () => ref.read(gameSessionProvider.notifier).resumeGame(),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                minimumSize: const Size(200, 56),
              ),
              onPressed: () => _showExitConfirmation(context, ref),
              child: Text(l10n.exit),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exitGame),
        content: Text(l10n.exitGameDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Dialog
              ref.read(gameSessionProvider.notifier).endGame();
              Navigator.pop(context); // Game Screen
            },
            child: Text(l10n.exit, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
