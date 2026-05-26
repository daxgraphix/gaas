import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/themes/app_themes.dart';
import '../crossword/crossword_screen.dart';
import '../math_riddle/math_riddle_screen.dart';
import '../../../data/models/math_riddle.dart';

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
            colors: theme.brightness == Brightness.light
                ? [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    theme.scaffoldBackgroundColor,
                  ]
                : [
                    Colors.red.withValues(alpha: 0.3),
                    theme.scaffoldBackgroundColor,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildChallengeTypeSelector(context),
                      const SizedBox(height: 24),
                      _buildDifficultySelector(context),
                      const SizedBox(height: 24),
                      _buildLeaderboard(context, challengeState),
                      const SizedBox(height: 24),
                      _buildStartButton(context),
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
          ),
          Expanded(
            child: Text(
              'Challenge Mode',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeTypeSelector(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Challenge Type',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTypeChip('daily', 'Daily', Icons.today),
              const SizedBox(width: 12),
              _buildTypeChip('speed', 'Speed', Icons.speed),
              const SizedBox(width: 12),
              _buildTypeChip('endless', 'Endless', Icons.all_inclusive),
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : null,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Difficulty',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
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
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : null,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.leaderboard, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'Leaderboard',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sortedLeaderboard.take(5).toList().asMap().entries.map<Widget>((
            entry,
          ) {
            final index = entry.key;
            final e = entry.value;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: index == 0
                          ? Colors.amber
                          : index == 1
                          ? Colors.grey
                          : index == 2
                          ? Colors.orange
                          : theme.colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: index < 3
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(e.key, style: theme.textTheme.bodyMedium),
                  ),
                  Text(
                    '${e.value}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: index == 0 ? Colors.amber : null,
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
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow),
            const SizedBox(width: 8),
            Text(
              'Start ${_getChallengeLabel()} Challenge',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    final isWarning = state.remainingSeconds <= 30;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isWarning
                  ? Colors.red.withValues(alpha: 0.3)
                  : Colors.orange.withValues(alpha: 0.3),
              Theme.of(context).scaffoldBackgroundColor,
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              _timer?.cancel();
              ref.read(challengeModeProvider.notifier).endChallenge();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
            color: Colors.white,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  _getChallengeLabel(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  'Score: ${state.score}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isWarning
                  ? Colors.red.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  color: isWarning ? Colors.red : Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(state.remainingSeconds),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isWarning ? Colors.red : Colors.white,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
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
              'Select Puzzle Type',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPuzzleTypeCard(
                  context,
                  'Crossword',
                  Icons.grid_on,
                  Colors.blue,
                  () => _launchPuzzle('crossword'),
                ),
                _buildPuzzleTypeCard(
                  context,
                  'Math',
                  Icons.calculate,
                  Colors.green,
                  () => _launchPuzzle('arithmetic'),
                ),
                _buildPuzzleTypeCard(
                  context,
                  'Sequence',
                  Icons.timeline,
                  Colors.purple,
                  () => _launchPuzzle('sequence'),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _launchPuzzle(String type) {
    if (type == 'crossword') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CrosswordScreen(isChallengeMode: true),
        ),
      ).then((_) {
        ref.read(challengeModeProvider.notifier).addScore(100);
      });
    } else {
      final riddleType = type == 'sequence'
          ? MathRiddleType.numberSequence
          : MathRiddleType.arithmetic;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MathRiddleScreen(riddleType: riddleType),
        ),
      ).then((_) {
        ref.read(challengeModeProvider.notifier).addScore(100);
      });
    }
  }

  void _showTimeUpDialog() {
    final challengeState = ref.read(challengeModeProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Time\'s Up!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_off, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Your score: ${challengeState.score}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isPlaying = false;
              });
              ref.read(challengeModeProvider.notifier).reset();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    if (seconds >= 9999) return '--:--';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
