import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/game_adaptability/adaptive_game_system.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../game/logic/game_session_provider.dart';
import '../../game/ui/game_screen.dart';

class EnhancedPracticeScreen extends ConsumerStatefulWidget {
  const EnhancedPracticeScreen({super.key});

  @override
  ConsumerState<EnhancedPracticeScreen> createState() =>
      _EnhancedPracticeScreenState();
}

class _EnhancedPracticeScreenState extends ConsumerState<EnhancedPracticeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedOperation = 'addition';
  String _difficulty = 'easy';
  int _questionCount = 10;
  bool _showFeedback = true;
  bool _unlimitedTime = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final playerProfile = ref.watch(playerProfileProvider);
    final adaptiveState = ref.watch(adaptiveGameStateProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.brightness == Brightness.light
                ? [
                    const Color(0xFFF8FAFC), // Very light gray
                    const Color(0xFFE0F2FE), // Light sky blue
                    const Color(0xFFF0FDFA), // Light mint
                  ]
                : [
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                    theme.colorScheme.secondary.withValues(alpha: 0.05),
                    theme.scaffoldBackgroundColor,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(theme, playerProfile),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (playerProfile != null)
                        _buildPlayerStatsCard(playerProfile, theme),
                      const SizedBox(height: 16),
                      _buildOperationSelector(theme),
                      const SizedBox(height: 16),
                      _buildDifficultySelector(theme, l10n),
                      const SizedBox(height: 16),
                      _buildSettings(theme),
                      const SizedBox(height: 24),
                      _buildStartButton(theme, adaptiveState),
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

  Widget _buildHeader(ThemeData theme, PlayerProfile? profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Practice Mode',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Learn at your own pace',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.school, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Adaptive',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerStatsCard(PlayerProfile profile, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Your Progress',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildSkillBadge(profile.skillLevel),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                'Games',
                '${profile.totalGamesPlayed}',
                Icons.sports_esports,
                theme,
              ),
              _buildStatItem(
                'Accuracy',
                '${(profile.averageAccuracy * 100).toStringAsFixed(0)}%',
                Icons.gps_fixed,
                theme,
              ),
              _buildStatItem(
                'Avg Speed',
                '${(profile.averageResponseTimeMs / 1000).toStringAsFixed(1)}s',
                Icons.speed,
                theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillBadge(PlayerSkillLevel level) {
    Color color;
    String label;
    switch (level) {
      case PlayerSkillLevel.master:
        color = Colors.purple;
        label = 'Master';
        break;
      case PlayerSkillLevel.advanced:
        color = Colors.red;
        label = 'Advanced';
        break;
      case PlayerSkillLevel.intermediate:
        color = Colors.blue;
        label = 'Intermediate';
        break;
      case PlayerSkillLevel.beginner:
        color = Colors.green;
        label = 'Beginner';
        break;
      case PlayerSkillLevel.novice:
        color = Colors.grey;
        label = 'Novice';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildOperationSelector(ThemeData theme) {
    final operations = [
      {'op': 'addition', 'label': 'Add (+)', 'color': Colors.green},
      {'op': 'subtraction', 'label': 'Sub (-)', 'color': Colors.blue},
      {'op': 'multiplication', 'label': 'Mul (×)', 'color': Colors.orange},
      {'op': 'division', 'label': 'Div (÷)', 'color': Colors.purple},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Operation',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: operations.map((op) {
            final isSelected = _selectedOperation == op['op'];
            return ChoiceChip(
              label: Text(op['label'] as String),
              selected: isSelected,
              onSelected: (s) {
                setState(() => _selectedOperation = op['op'] as String);
              },
              selectedColor: (op['color'] as Color).withValues(alpha: 0.3),
              labelStyle: TextStyle(
                color: isSelected
                    ? op['color'] as Color
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDifficultySelector(ThemeData theme, AppLocalizations l10n) {
    final difficulties = [
      {
        'diff': 'easy',
        'label': l10n.easy,
        'color': Colors.green,
        'time': l10n.noLimit,
      },
      {
        'diff': 'medium',
        'label': l10n.medium,
        'color': Colors.blue,
        'time': '90${l10n.seconds}',
      },
      {
        'diff': 'hard',
        'label': l10n.hard,
        'color': Colors.orange,
        'time': '60${l10n.seconds}',
      },
      {
        'diff': 'expert',
        'label': 'Expert',
        'color': Colors.red,
        'time': '45${l10n.seconds}',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Difficulty',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: difficulties.map((d) {
            final isSelected = _difficulty == d['diff'];
            return ChoiceChip(
              label: Text('${d['label']} (${d['time']})'),
              selected: isSelected,
              onSelected: (s) {
                setState(() => _difficulty = d['diff'] as String);
              },
              selectedColor: (d['color'] as Color).withValues(alpha: 0.3),
              labelStyle: TextStyle(
                color: isSelected
                    ? d['color'] as Color
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSettings(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSliderSetting(
                'Questions',
                _questionCount,
                5,
                30,
                '$_questionCount',
                (v) => setState(() => _questionCount = v),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Unlimited Time'),
                subtitle: const Text('Practice without pressure'),
                value: _unlimitedTime,
                onChanged: (v) => setState(() => _unlimitedTime = v),
              ),
              SwitchListTile(
                title: const Text('Show Feedback'),
                subtitle: const Text('See correct answers immediately'),
                value: _showFeedback,
                onChanged: (v) => setState(() => _showFeedback = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliderSetting(
    String label,
    int value,
    int min,
    int max,
    String format,
    Function(int) onChanged,
  ) {
    return Row(
      children: [
        Text(label),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            label: format.replaceAll('\$value', '$value'),
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(width: 40, child: Text('$value', textAlign: TextAlign.center)),
      ],
    );
  }

  Widget _buildStartButton(ThemeData theme, AdaptiveGameState adaptiveState) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _startPractice,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow),
            const SizedBox(width: 8),
            Text(
              'Start Practice',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startPractice() {
    final level = _difficultyToLevel(_difficulty);
    final timeLimit = _unlimitedTime ? 0 : _difficultyToTime(_difficulty);

    ref
        .read(gameSessionProvider.notifier)
        .startGame(
          mode: GameMode.practice,
          operation: _selectedOperation,
          level: level,
          totalQuestions: _questionCount,
        );

    if (timeLimit > 0) {
      ref.read(adaptiveConfigProvider.notifier).applySpeedBonus(timeLimit);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  int _difficultyToLevel(String diff) {
    switch (diff) {
      case 'easy':
        return 1;
      case 'medium':
        return 5;
      case 'hard':
        return 10;
      case 'expert':
        return 15;
      default:
        return 1;
    }
  }

  int _difficultyToTime(String diff) {
    switch (diff) {
      case 'easy':
        return 0;
      case 'medium':
        return 90;
      case 'hard':
        return 60;
      case 'expert':
        return 45;
      default:
        return 0;
    }
  }
}
