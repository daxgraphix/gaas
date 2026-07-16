import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/themes/app_themes.dart';
import '../../../core/providers.dart';
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
      backgroundColor: session.feverActive ? Colors.orange.shade50 : theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: session.feverActive ? Colors.orange.shade100 : null,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitConfirmation(context, ref, l10n),
        ),
        title: Text(
          session.mode == GameMode.practice
              ? l10n.practiceMode
              : session.mode == GameMode.campaign
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
                _buildNumpad(context, ref, theme, session, l10n),
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'HEAT',
                    style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.whatshot,
                        size: 16,
                        color: session.heatIndex > 2.5 ? Colors.orange : theme.colorScheme.secondary,
                      ),
                      Text(
                        'x${session.heatIndex.toStringAsFixed(1)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: session.heatIndex > 2.5 ? Colors.orange : theme.colorScheme.secondary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          if (session.timeRemaining > 0 || session.mode == GameMode.scoreAttack)
            _buildTimer(session, theme, l10n),
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

  Widget _buildTimer(GameSession session, ThemeData theme, AppLocalizations l10n) {
    final color = session.timeRemaining < 10 ? theme.colorScheme.error : theme.colorScheme.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'TIME',
          style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${session.timeRemaining}s',
              style: theme.textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (session.mode == GameMode.scoreAttack || session.mode == GameMode.speedDemon)
              _buildTimeBonusIndicator(session, theme),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeBonusIndicator(GameSession session, ThemeData theme) {
    int bonus = 0;
    if (session.mode == GameMode.scoreAttack) {
      bonus = 2 + (session.comboMultiplier ~/ 2);
    } else if (session.mode == GameMode.speedDemon) {
      bonus = 1;
    }

    if (session.lastAnswerTime != null && 
        DateTime.now().difference(session.lastAnswerTime!).inMilliseconds < 1000) {
      return Container(
        margin: const EdgeInsets.only(left: 4),
        child: Text(
          '+$bonus',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ).animate().fadeOut(duration: 800.ms).moveY(begin: 0, end: -20);
    }
    return const SizedBox.shrink();
  }

  Widget _buildQuestionArea(GameSession session, ThemeData theme) {
    if (session.currentQuestion == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          if (session.feverActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'FEVER x2',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ).animate().scale().shake(),
          const SizedBox(height: 8),
          Text(
            session.currentQuestion!.displayString,
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: session.feverActive ? Colors.deepOrange : theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ).animate(key: ValueKey(session.currentQuestionIndex)).fadeIn().scale(),
          const SizedBox(height: 24),
          if (session.mode == GameMode.practice)
            Text(
              'Practice Session',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            Text(
              'Question ${session.currentQuestionIndex + 1} of ${session.totalQuestions}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
          if (session.revealedHints.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                session.revealedHints.last,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.blueGrey,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(),
            ),
        ],
      ),
    );
  }

  Widget _buildNumpad(BuildContext context, WidgetRef ref, ThemeData theme, GameSession session, AppLocalizations l10n) {
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
          if (session.mode == GameMode.practice || session.level > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextButton.icon(
                icon: const Icon(Icons.lightbulb_outline, size: 18),
                label: Text('${l10n.getHint} (10 PTS)'),
                onPressed: () => ref.read(gameSessionProvider.notifier).useHint(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNumpadButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    ThemeData theme, {
    Color? color,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: PremiumAnimatedButton(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: color?.withValues(alpha: 0.1) ?? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderColor: color ?? theme.colorScheme.outline.withValues(alpha: 0.2),
          onPressed: () {
            final currentInput = ref.read(_inputProvider);
            if (label == 'C') {
              ref.read(_inputProvider.notifier).state = '';
            } else if (label == 'OK') {
              if (currentInput.isNotEmpty) {
                ref.read(gameSessionProvider.notifier).answerQuestion(int.parse(currentInput));
                ref.read(_inputProvider.notifier).state = '';
              }
            } else {
              if (currentInput.length < 5) {
                ref.read(_inputProvider.notifier).state = currentInput + label;
              }
            }
          },
          child: Text(
            label,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
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

  Widget _buildResultsScreen(BuildContext context, WidgetRef ref, GameSession session, ThemeData theme, AppLocalizations l10n) {
    final user = ref.watch(userSessionProvider);
    final pointsEarned = session.score;
    final oldLevel = user != null ? ((user.totalPoints - pointsEarned) / 2500).floor() + 1 : 1;
    final newLevel = user?.level ?? 1;
    final didLevelUp = newLevel > oldLevel;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (didLevelUp)
                Text(
                  'LEVEL UP!',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: Colors.amber,
                    fontWeight: FontWeight.w900,
                  ),
                ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 2.seconds),
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
                    const Divider(),
                    _buildResultRow('MAX STREAK', '${session.bestStreak}', theme),
                    const Divider(),
                    _buildResultRow(l10n.averageHeat, 'x${session.heatIndex.toStringAsFixed(2)}', theme),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (user != null)
                Column(
                  children: [
                    Text(
                      'LEVEL $newLevel',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: user.levelProgress,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      color: theme.colorScheme.primary,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${user.pointsToNextLevel} pts to next level',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
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
              onPressed: () => _showExitConfirmation(context, ref, l10n),
              child: Text(l10n.exit),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
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
