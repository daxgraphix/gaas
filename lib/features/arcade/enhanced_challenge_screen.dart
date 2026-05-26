import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/game_adaptability/adaptive_game_system.dart';
import '../game/logic/game_session_provider.dart';
import '../game/ui/game_screen.dart';

class EnhancedChallengeScreen extends ConsumerStatefulWidget {
  const EnhancedChallengeScreen({super.key});

  @override
  ConsumerState<EnhancedChallengeScreen> createState() =>
      _EnhancedChallengeScreenState();
}

class _EnhancedChallengeScreenState
    extends ConsumerState<EnhancedChallengeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playerProfile = ref.watch(playerProfileProvider);
    final dailyChallenges = ref.watch(dailyChallengeProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.brightness == Brightness.light
                ? [
                    const Color(0xFFE0F2FE), // Light sky blue
                    const Color(0xFFF8FAFC), // Very light background
                  ]
                : [
                    Colors.orange.withValues(alpha: 0.15),
                    theme.scaffoldBackgroundColor,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(theme, playerProfile),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Daily'),
                    Tab(text: 'Weekly'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildChallengeList(dailyChallenges, theme),
                    _buildChallengeList(dailyChallenges, theme),
                  ],
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
                  'Challenges',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Complete for rewards',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (profile != null) _buildSkillBadge(profile.skillLevel),
        ],
      ),
    );
  }

  Widget _buildSkillBadge(PlayerSkillLevel level) {
    Color color;
    IconData icon;
    switch (level) {
      case PlayerSkillLevel.master:
        color = Colors.purple;
        icon = Icons.emoji_events;
        break;
      case PlayerSkillLevel.advanced:
        color = Colors.red;
        icon = Icons.star;
        break;
      case PlayerSkillLevel.intermediate:
        color = Colors.blue;
        icon = Icons.star_half;
        break;
      case PlayerSkillLevel.beginner:
        color = Colors.green;
        icon = Icons.star_border;
        break;
      case PlayerSkillLevel.novice:
        color = Colors.grey;
        icon = Icons.star_outline;
        break;
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildChallengeList(List<DailyChallenge> challenges, ThemeData theme) {
    final now = DateTime.now();
    final dailyChallenges = challenges
        .where((c) => c.expiresAt.difference(now).inHours > 0)
        .toList();

    if (dailyChallenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.celebration, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('All challenges complete!', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Come back tomorrow',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dailyChallenges.length,
      itemBuilder: (context, index) {
        final challenge = dailyChallenges[index];
        return _buildChallengeCard(challenge, theme);
      },
    );
  }

  Widget _buildChallengeCard(DailyChallenge challenge, ThemeData theme) {
    final progress = challenge.progress;
    final isComplete = challenge.isCompleted;
    final hoursLeft = challenge.expiresAt.difference(DateTime.now()).inHours;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isComplete ? Border.all(color: Colors.green, width: 2) : null,
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            challenge.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '+${challenge.rewardPoints}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${hoursLeft}h left',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: hoursLeft < 6 ? Colors.red : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: isComplete ? Colors.green : theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${challenge.currentValue}/${challenge.targetValue}',
                  style: theme.textTheme.bodySmall,
                ),
                if (isComplete)
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Complete!',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                else
                  ElevatedButton(
                    onPressed: () => _startChallengeGame(challenge.type),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Play'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startChallengeGame(String type) {
    final operation = _getOperationForType(type);
    final mode = _getGameModeForType(type);

    ref
        .read(gameSessionProvider.notifier)
        .startGame(
          mode: mode,
          operation: operation,
          level: 5,
          totalQuestions: 15,
        );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  String _getOperationForType(String type) {
    switch (type) {
      case 'division':
        return 'division';
      case 'multiplication':
        return 'multiplication';
      case 'subtraction':
        return 'subtraction';
      case 'addition':
        return 'addition';
      default:
        return 'addition';
    }
  }

  GameMode _getGameModeForType(String type) {
    switch (type) {
      case 'speed':
        return GameMode.speedDemon;
      case 'streak':
        return GameMode.endless;
      case 'score':
        return GameMode.scoreAttack;
      default:
        return GameMode.campaign;
    }
  }
}

class ChallengeEvent {
  final String id;
  final String title;
  final String description;
  final int targetValue;
  final int currentValue;
  final int rewardPoints;
  final DateTime expiresAt;
  final String requiredMode;
  final bool isCompleted;

  ChallengeEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    this.currentValue = 0,
    required this.rewardPoints,
    required this.expiresAt,
    this.requiredMode = 'any',
    this.isCompleted = false,
  });

  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

final challengeEventsProvider =
    StateNotifierProvider<ChallengeEventsNotifier, List<ChallengeEvent>>((ref) {
      return ChallengeEventsNotifier();
    });

class ChallengeEventsNotifier extends StateNotifier<List<ChallengeEvent>> {
  ChallengeEventsNotifier() : super(_generateEvents());

  static List<ChallengeEvent> _generateEvents() {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final endOfWeek = DateTime(now.year, now.month, now.day + 7, 23, 59, 59);

    return [
      ChallengeEvent(
        id: 'daily_speed',
        title: 'Speed Demon',
        description: 'Answer 20 questions in 60 seconds',
        targetValue: 20,
        rewardPoints: 100,
        expiresAt: endOfDay,
        requiredMode: 'speed',
      ),
      ChallengeEvent(
        id: 'daily_streak',
        title: 'On Fire',
        description: 'Get 10 correct in a row',
        targetValue: 10,
        rewardPoints: 150,
        expiresAt: endOfDay,
        requiredMode: 'streak',
      ),
      ChallengeEvent(
        id: 'daily_accuracy',
        title: 'Perfect Score',
        description: 'Get 100% accuracy',
        targetValue: 10,
        rewardPoints: 200,
        expiresAt: endOfDay,
        requiredMode: 'accuracy',
      ),
      ChallengeEvent(
        id: 'weekly_master',
        title: 'Weekend Master',
        description: 'Complete 50 questions this week',
        targetValue: 50,
        rewardPoints: 500,
        expiresAt: endOfWeek,
        requiredMode: 'any',
      ),
    ];
  }

  void updateProgress(String eventId, int amount) {
    state = state.map((event) {
      if (event.id == eventId && !event.isCompleted) {
        final newValue = (event.currentValue + amount).clamp(
          0,
          event.targetValue,
        );
        return ChallengeEvent(
          id: event.id,
          title: event.title,
          description: event.description,
          targetValue: event.targetValue,
          currentValue: newValue,
          rewardPoints: event.rewardPoints,
          expiresAt: event.expiresAt,
          requiredMode: event.requiredMode,
          isCompleted: newValue >= event.targetValue,
        );
      }
      return event;
    }).toList();
  }

  void resetExpired() {
    state = state.where((e) => !e.isExpired).toList();
    if (state.isEmpty) {
      state = _generateEvents();
    }
  }
}

class ChallengeReward {
  final int points;
  final List<String> unlocks;

  ChallengeReward({this.points = 0, this.unlocks = const []});
}
