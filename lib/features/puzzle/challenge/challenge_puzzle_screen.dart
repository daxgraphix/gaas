import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/themes/app_themes.dart';
import '../../../core/sound_manager.dart';
import '../../../core/utils/game_flow_optimizer.dart';
import '../math_riddle/math_riddle_screen.dart';
import '../../../data/models/math_riddle.dart';
import '../../../l10n/generated/app_localizations.dart';

class ChallengePuzzleScreen extends ConsumerStatefulWidget {
  const ChallengePuzzleScreen({super.key});

  @override
  ConsumerState<ChallengePuzzleScreen> createState() =>
      _ChallengePuzzleScreenState();
}

class _ChallengePuzzleScreenState extends ConsumerState<ChallengePuzzleScreen> {
  Timer? _timer;
  String _selectedChallenge = 'daily';
  int _selectedDifficulty = 1;
  bool _isPlaying = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        ref.read(challengeModeProvider.notifier).decrementTime();
        final remaining = ref.read(challengeModeProvider).remainingSeconds;
        if (remaining <= 0) {
          _timer?.cancel();
          _showTimeUpDialog();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final challengeState = ref.watch(challengeModeProvider);
    final theme = Theme.of(context);

    if (_isPlaying) {
      return _buildChallengeView(context, challengeState);
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.15),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildChallengeTypeSelector(context),
                      const SizedBox(height: 24),
                      _buildDifficultySelector(context),
                      const SizedBox(height: 24),
                      _buildLeaderboard(context, challengeState),
                      const SizedBox(height: 32),
                      _buildStartButton(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new),
            color: theme.colorScheme.onSurface,
            iconSize: 20,
          ),
          Expanded(
            child: Text(
              'Challenge Mode',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppDesignTokens.textPrimary(context),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Spacer for balance
        ],
      ),
    );
  }

  Widget _buildChallengeTypeSelector(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusLarge),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHALLENGE TYPE',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildTypeChip('daily', 'Daily', Icons.today_rounded),
              const SizedBox(width: 12),
              _buildTypeChip('speed', 'Speed', Icons.speed_rounded),
              const SizedBox(width: 12),
              _buildTypeChip('endless', 'Endless', Icons.all_inclusive_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type, String label, IconData icon) {
    final isSelected = _selectedChallenge == type;
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedChallenge = type;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : AppDesignTokens.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultySelector(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusLarge),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DIFFICULTY',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildDifficultyChip(1),
              const SizedBox(width: 8),
              _buildDifficultyChip(2),
              const SizedBox(width: 8),
              _buildDifficultyChip(3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(int difficulty) {
    final isSelected = _selectedDifficulty == difficulty;
    final theme = Theme.of(context);

    String label;
    switch (difficulty) {
      case 1:
        label = 'Easy';
        break;
      case 2:
        label = 'Medium';
        break;
      case 3:
        label = 'Hard';
        break;
      default:
        label = 'Unknown';
    }

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedDifficulty = difficulty;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : AppDesignTokens.textSecondary(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboard(BuildContext context, ChallengeModeState state) {
    final theme = Theme.of(context);
    final sortedLeaderboard = state.leaderboard.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusLarge),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.leaderboard_rounded, color: Colors.amber.shade700, size: 24),
              const SizedBox(width: 12),
              Text(
                'LEADERBOARD',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppDesignTokens.textPrimary(context),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...sortedLeaderboard.take(5).toList().asMap().entries.map<Widget>((
            entry,
          ) {
            final index = entry.key;
            final e = entry.value;
            final isTopThree = index < 3;
            
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.05),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: index == 0
                          ? Colors.amber.withValues(alpha: 0.2)
                          : index == 1
                          ? Colors.blueGrey.withValues(alpha: 0.1)
                          : index == 2
                          ? Colors.orange.withValues(alpha: 0.1)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: index == 0
                              ? Colors.amber.shade800
                              : index == 1
                              ? Colors.blueGrey
                              : index == 2
                              ? Colors.orange.shade800
                              : AppDesignTokens.textSecondary(context),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      e.key, 
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isTopThree ? FontWeight.w600 : FontWeight.normal,
                        color: AppDesignTokens.textPrimary(context),
                      ),
                    ),
                  ),
                  Text(
                    '${e.value}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: index == 0 ? Colors.amber.shade800 : theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    final theme = Theme.of(context);
    int timeLimit;
    switch (_selectedChallenge) {
      case 'speed':
        timeLimit = 60;
        break;
      case 'endless':
        timeLimit = 9999;
        break;
      default:
        timeLimit = 300;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _startChallenge(timeLimit),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: 4,
          shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, size: 28),
            const SizedBox(width: 12),
            Text(
              'START ${_getChallengeLabel().toUpperCase()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
          ],
        ),
      ),
    );
  }

  String _getChallengeLabel() {
    switch (_selectedChallenge) {
      case 'speed':
        return 'Speed';
      case 'endless':
        return 'Endless';
      default:
        return 'Daily';
    }
  }

  void _startChallenge(int timeLimit) {
    ref
        .read(challengeModeProvider.notifier)
        .startChallenge(type: _selectedChallenge, timeLimit: timeLimit);
    setState(() {
      _isPlaying = true;
    });
    _startTimer();
  }

  Widget _buildChallengeView(BuildContext context, ChallengeModeState state) {
    final theme = Theme.of(context);
    final isWarning = state.remainingSeconds <= 30;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isWarning
                  ? theme.colorScheme.error.withValues(alpha: 0.2)
                  : theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildChallengeHeader(context, state),
              Expanded(child: _buildPuzzleSelector(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeHeader(BuildContext context, ChallengeModeState state) {
    final theme = Theme.of(context);
    final isWarning = state.remainingSeconds <= 30;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              _timer?.cancel();
              ref.read(challengeModeProvider.notifier).endChallenge();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close_rounded),
            color: AppDesignTokens.textPrimary(context),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  _getChallengeLabel().toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppDesignTokens.textSecondary(context),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'SCORE: ${state.score}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppDesignTokens.textPrimary(context),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isWarning
                  ? theme.colorScheme.error.withValues(alpha: 0.15)
                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isWarning ? theme.colorScheme.error : theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: isWarning ? theme.colorScheme.error : theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(state.remainingSeconds),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isWarning ? theme.colorScheme.error : theme.colorScheme.primary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildPuzzleSelector(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SELECT PUZZLE TYPE',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppDesignTokens.textSecondary(context),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPuzzleTypeCard(
                  context,
                  'Math',
                  Icons.calculate_rounded,
                  theme.colorScheme.secondary,
                  () => _launchPuzzle('arithmetic'),
                ),
                _buildPuzzleTypeCard(
                  context,
                  'Logic',
                  Icons.extension_rounded,
                  theme.colorScheme.tertiary,
                  () => _launchPuzzle('logic'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPuzzleTypeCard(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
            ),
            child: Center(
              child: Icon(icon, color: color, size: 40),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _launchPuzzle(String type) {
    final riddleType = type == 'logic'
        ? MathRiddleType.logicChallenge
        : MathRiddleType.arithmetic;
    
    final operation = type == 'logic' ? 'logic' : 'arithmetic';
    GameFlowOptimizer.preloadRiddles(
      operations: [operation],
      level: _selectedDifficulty,
      count: 20,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MathRiddleScreen(
          riddleType: riddleType,
          difficulty: _selectedDifficulty,
        ),
      ),
    ).then((_) {
      ref.read(challengeModeProvider.notifier).addScore(100);
    });
  }

  void _showTimeUpDialog() {
    final challengeState = ref.read(challengeModeProvider);

    // Play time up/wrong audio and haptic feedback
    ref.read(soundManagerProvider).playWrongAnswer();
    HapticManager.instance.wrongAnswerPattern();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n?.timesUp ?? "Time's Up!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer_off, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('${l10n?.yourScore ?? 'Your score'}: ${challengeState.score}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(l10n?.exit ?? 'Exit'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isPlaying = false;
                });
                ref.read(challengeModeProvider.notifier).reset();
              },
              child: Text(l10n?.tryAgain ?? 'Try Again'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) {
    if (seconds >= 9999) return '--:--';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
