import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/game_flow_optimizer.dart';
import '../../../core/math_engine/math_engine.dart';
import '../../../core/providers.dart';
import '../../../core/notification_service.dart';
import '../../../core/game_adaptability/dynamic_difficulty_system.dart';
import '../../../data/content_library/achievement_system.dart';

enum GameMode {
  campaign,
  practice,
  scoreAttack,
  endless,
  duel,
  flash,
  speedDemon,
  mathMaster,
  marathon,
}

enum GameState { ready, playing, paused, finished }

class GameSession {
  final GameMode mode;
  final GameState state;
  final String operation;
  final int level;
  final int minNumber;
  final int maxNumber;
  final List<MathQuestion> questions;
  final int currentQuestionIndex;
  final int score;
  final int correctAnswers;
  final int lives;
  final int timeRemaining;
  final int totalQuestions;
  final bool isVisualCounting;
  final int? aiScore;
  final int? aiCorrectAnswers;
  final bool? playerWon;
  final Map<int, dynamic> userAnswers;
  final Map<int, bool> hintsUsed;
  final int comboMultiplier;
  final DateTime? lastAnswerTime;
  final bool isBossLevel;
  final VisualCountingData? currentVisualData;
  final List<Map<String, dynamic>> pendingStats;
  final int? ghostScore;
  final double heatIndex;

  GameSession({
    required this.mode,
    this.state = GameState.playing,
    required this.operation,
    required this.level,
    this.minNumber = 1,
    this.maxNumber = 10,
    required this.questions,
    this.currentQuestionIndex = 0,
    this.score = 0,
    this.correctAnswers = 0,
    this.lives = 3,
    this.timeRemaining = 60,
    this.totalQuestions = 45,
    this.isVisualCounting = false,
    this.aiScore,
    this.aiCorrectAnswers,
    this.playerWon,
    this.userAnswers = const {},
    this.hintsUsed = const {},
    this.comboMultiplier = 1,
    this.lastAnswerTime,
    this.isBossLevel = false,
    this.currentVisualData,
    this.pendingStats = const [],
    this.ghostScore,
    this.heatIndex = 1.0,
  });

  MathQuestion? get currentQuestion {
    if (currentQuestionIndex < questions.length) {
      return questions[currentQuestionIndex];
    }
    return null;
  }

  int get questionsRemaining => totalQuestions - currentQuestionIndex;

  GameSession copyWith({
    GameMode? mode,
    GameState? state,
    String? operation,
    int? level,
    List<MathQuestion>? questions,
    int? currentQuestionIndex,
    int? score,
    int? correctAnswers,
    int? lives,
    int? timeRemaining,
    int? totalQuestions,
    bool? isVisualCounting,
    int? aiScore,
    int? aiCorrectAnswers,
    bool? playerWon,
    Map<int, dynamic>? userAnswers,
    Map<int, bool>? hintsUsed,
    int? comboMultiplier,
    DateTime? lastAnswerTime,
    bool? isBossLevel,
    VisualCountingData? currentVisualData,
    List<Map<String, dynamic>>? pendingStats,
    int? ghostScore,
    double? heatIndex,
  }) {
    return GameSession(
      mode: mode ?? this.mode,
      state: state ?? this.state,
      operation: operation ?? this.operation,
      level: level ?? this.level,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      lives: lives ?? this.lives,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      isVisualCounting: isVisualCounting ?? this.isVisualCounting,
      aiScore: aiScore ?? this.aiScore,
      aiCorrectAnswers: aiCorrectAnswers ?? this.aiCorrectAnswers,
      playerWon: playerWon ?? this.playerWon,
      userAnswers: userAnswers ?? this.userAnswers,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      comboMultiplier: comboMultiplier ?? this.comboMultiplier,
      lastAnswerTime: lastAnswerTime ?? this.lastAnswerTime,
      isBossLevel: isBossLevel ?? this.isBossLevel,
      currentVisualData: currentVisualData ?? this.currentVisualData,
      pendingStats: pendingStats ?? this.pendingStats,
      ghostScore: ghostScore ?? this.ghostScore,
      heatIndex: heatIndex ?? this.heatIndex,
    );
  }
}

class VisualCountingData {
  final int targetCount;
  final List<ShapeData> shapes;

  VisualCountingData({required this.targetCount, required this.shapes});
}

class ShapeData {
  final String type;
  final double x;
  final double y;
  final double size;
  final int color;

  ShapeData({
    required this.type,
    required this.x,
    required this.y,
    required this.size,
    required this.color,
  });
}

final gameSessionProvider =
    StateNotifierProvider<GameSessionNotifier, GameSession?>((ref) {
      return GameSessionNotifier(ref);
    });

class GameSessionNotifier extends StateNotifier<GameSession?> {
  static int getCampaignPassThreshold(int totalQuestions) {
    // Require 70% to pass
    return (totalQuestions * 0.7).ceil();
  }
  final Ref ref;
  Timer? _timer;
  Timer? _duelTimer;
  final Random _random = Random();
  bool _duelAnswered = false;

  GameSessionNotifier(this.ref) : super(null);

  Future<void> startGame({
    required GameMode mode,
    required String operation,
    int level = 1,
    int minNumber = 1,
    int maxNumber = 10,
    bool isVisualCounting = false,
    int totalQuestions = 45,
    int? timeLimit,
    List<MathQuestion>? preloadedQuestions,
  }) async {
    _timer?.cancel();
    _duelTimer?.cancel();

    bool isBossLevel = false;
    int timeRemaining = 60;
    int lives = 3;

    if (mode == GameMode.campaign) {
      timeRemaining = 0;
      totalQuestions = level <= 50 ? 50 : 60;
      if (level % 10 == 0) {
        isBossLevel = true;
      }
    } else if (mode == GameMode.scoreAttack) {
      timeRemaining = 60;
    } else if (mode == GameMode.speedDemon) {
      timeRemaining = 30; // Speed demon: 30 seconds
    } else if (mode == GameMode.endless) {
      timeRemaining = 0;
    } else if (mode == GameMode.mathMaster) {
      timeRemaining = 0;
    } else if (mode == GameMode.marathon) {
      timeRemaining = 0;
    }

    // Set lives for modes that don't use lives
    if (mode == GameMode.mathMaster || mode == GameMode.marathon) {
      lives = 999; // effectively infinite
    }

    int? aiScore;
    int? aiCorrectAnswers;
    if (mode == GameMode.duel) {
      aiScore = 0;
      aiCorrectAnswers = 0;
    }

    int? ghostScore;
    if (mode == GameMode.scoreAttack) {
      final levelProgressRepo = ref.read(levelProgressRepositoryProvider);
      ghostScore = await levelProgressRepo.getHighScore(operation, level);
    }

    final user = ref.read(userSessionProvider);
    final skillRating = user?.skillRating ?? 1000;

    final questions = preloadedQuestions ?? <MathQuestion>[];
    
    if (questions.isEmpty) {
      final isArcade =
          mode == GameMode.scoreAttack ||
          mode == GameMode.endless ||
          mode == GameMode.duel ||
          mode == GameMode.flash ||
          mode == GameMode.speedDemon ||
          mode == GameMode.mathMaster ||
          mode == GameMode.marathon;

      if (mode == GameMode.mathMaster) {
        // We still generate sequentially if mathMaster needs specific mixed logic
        // but it's better to use batching for better performance if possible
        final generatedQuestions = <String>{};
        for (int i = 0; i < totalQuestions; i++) {
          final ops = ['addition', 'subtraction', 'multiplication', 'division'];
          final randomOp = ops[_random.nextInt(ops.length)];
          final q = MathEngine.generateQuestion(
            randomOp,
            level,
            isArcade: isArcade,
            excludeQuestions: generatedQuestions,
            skillRating: skillRating,
            heatIndex: 1.0, // Initial heat is 1.0
          );
          generatedQuestions.add(q.displayString);
          questions.add(q);
        }
      } else {
        final batch = await MathEngine.generateQuestionsBatch(
          operation,
          level,
          totalQuestions,
          isArcade: isArcade,
          skillRating: skillRating,
          heatIndex: 1.0, // Initial heat is 1.0
        );
        questions.addAll(batch);
      }
      
      // Shuffle questions for random order
      questions.shuffle();
    }

    state = GameSession(
      mode: mode,
      operation: operation,
      level: level,
      minNumber: minNumber,
      maxNumber: maxNumber,
      questions: questions,
      totalQuestions: totalQuestions,
      timeRemaining: timeRemaining,
      lives: lives,
      isVisualCounting: isVisualCounting,
      aiScore: aiScore,
      aiCorrectAnswers: aiCorrectAnswers,
      isBossLevel: isBossLevel,
      currentVisualData: isVisualCounting ? _generateVisualCountingData(level) : null,
      ghostScore: (ghostScore ?? 0) > 0 ? ghostScore : null,
      heatIndex: user?.lastHeatIndex ?? 1.0,
    );

    if (mode == GameMode.scoreAttack ||
        mode == GameMode.speedDemon) {
      _startTimer();
    } else if (mode == GameMode.duel) {
      _startDuelMode();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state != null && state!.timeRemaining > 0) {
        // Apply Heat Index Decay: slightly decrease heat every few seconds if no answer
        double newHeat = state!.heatIndex;
        if (state!.timeRemaining % 3 == 0) {
          newHeat = (newHeat - 0.05).clamp(1.0, 3.0);
        }

        state = state!.copyWith(
          timeRemaining: state!.timeRemaining - 1,
          heatIndex: newHeat,
        );
        ref.read(soundManagerProvider).updateHeat(newHeat);
      } else if (state != null && state!.timeRemaining <= 0) {
        _endGame();
      }
    });
  }

  void _startDuelMode() {
    _processDuelTurn();
  }

  void _processDuelTurn() {
    if (state == null || state!.mode != GameMode.duel) return;
    if (state!.currentQuestionIndex >= state!.totalQuestions) {
      _endGame();
      return;
    }

    _duelAnswered = false;
    final aiTime = MathEngine.getAIAnswerTime(state!.operation, state!.level);

    _duelTimer = Timer(Duration(milliseconds: aiTime), () {
      if (_duelAnswered || state == null) return;

      final aiCorrect = _random.nextDouble() < _getAIAccuracy();
      int newAiScore = state!.aiScore ?? 0;
      int newAiCorrect = state!.aiCorrectAnswers ?? 0;

      if (aiCorrect) {
        newAiScore += 10;
        newAiCorrect++;
      }

      state = state!.copyWith(
        aiScore: newAiScore,
        aiCorrectAnswers: newAiCorrect,
      );
    });
  }

  double _getAIAccuracy() {
    final level = state?.level ?? 1;
    final baseAccuracy = 0.7;
    final levelBonus = (level / 50).clamp(0.0, 0.2);
    return (baseAccuracy + levelBonus).clamp(0.5, 0.95);
  }

  void answerQuestion(dynamic answer) {
    if (state == null || state!.currentQuestion == null) return;

    // If question already answered, do not count again (for next/prev feature)
    if (state!.userAnswers.containsKey(state!.currentQuestionIndex)) {
      _goToNextOrEnd();
      return;
    }

    final isCorrect = answer.toString() == state!.currentQuestion!.correctAnswer.toString();
    int newScore = state!.score;
    int newCorrect = state!.correctAnswers;
    int newLives = state!.lives;

    final hintUsed = state!.hintsUsed[state!.currentQuestionIndex] ?? false;

    final now = DateTime.now();
    int newCombo = state!.comboMultiplier;

    if (state!.lastAnswerTime != null &&
        now.difference(state!.lastAnswerTime!).inSeconds <= 4) {
      newCombo = (newCombo < 4) ? newCombo + 1 : 4;
    } else {
      newCombo = 1;
    }

    if (isCorrect) {
      ref.read(soundManagerProvider).playCorrect();
      final baseScore = _getScoreForMode();
      newScore += (hintUsed ? (baseScore ~/ 2) : baseScore) * newCombo;
      newCorrect++;

      if (newCombo == 5) {
        ref.read(soundManagerProvider).playLevelUp();
        NotificationService().showStreakNotification(
          '5-Question Streak!',
          'Keep going! You\'ve answered 5 in a row.',
        );
      } else if (newCombo == 10) {
        ref.read(soundManagerProvider).playLevelUp();
        NotificationService().showAchievementNotification(
          '10-Question Streak!',
          'Incredible! Double-digit streak achieved.',
        );
      } else if (newCombo == 15) {
        ref.read(soundManagerProvider).playAchievement();
        NotificationService().showAchievementNotification(
          '15-Question Streak!',
          'Unstoppable! You\'re on fire!',
        );
      }

      final challengeNotifier = ref.read(dailyChallengeProvider.notifier);
      challengeNotifier.incrementProgress('questions', 1);
      if (state!.currentQuestion?.operation == 'division') {
        challengeNotifier.incrementProgress('division', 1);
      }
      if (state!.mode == GameMode.speedDemon) {
        challengeNotifier.incrementProgress('speed', 1);
      }
      challengeNotifier.incrementProgress('streak', 1);
    } else {
      ref.read(soundManagerProvider).playIncorrect();
      newCombo = 1;
      if (state!.mode == GameMode.endless) {
        newLives--;
      }
      if (state!.isBossLevel) {
        newLives--;
      }
      ref.read(dailyChallengeProvider.notifier).updateProgressMax('streak', 0);
    }

    final newUserAnswers = Map<int, dynamic>.from(state!.userAnswers);
    newUserAnswers[state!.currentQuestionIndex] = answer;

    final newPendingStats = List<Map<String, dynamic>>.from(state!.pendingStats);
    final timeSpent = state!.lastAnswerTime == null
        ? 0
        : now.difference(state!.lastAnswerTime!).inSeconds.clamp(1, 120);

    // Calculate Heat Index: increases if answering quickly and correctly
    double newHeat = state!.heatIndex;
    if (isCorrect) {
      if (timeSpent <= 3) {
        newHeat += 0.1;
      } else if (timeSpent <= 5) {
        newHeat += 0.05;
      }
    } else {
      newHeat = (newHeat - 0.2).clamp(1.0, 3.0);
    }
    newHeat = newHeat.clamp(1.0, 3.0);

    // If heat increased significantly, inject a tougher question
    List<MathQuestion> updatedQuestions = List.from(state!.questions);
    if (newHeat > state!.heatIndex + 0.15 && state!.currentQuestionIndex + 1 < state!.totalQuestions) {
       final user = ref.read(userSessionProvider);
       final skillRating = user?.skillRating ?? 1000;
       
       final toughQuestion = MathEngine.generateQuestion(
         state!.operation,
         state!.level,
         isArcade: state!.mode != GameMode.campaign,
         skillRating: skillRating,
         heatIndex: newHeat,
       );
       updatedQuestions[state!.currentQuestionIndex + 1] = toughQuestion;
    }

    final questionScore = isCorrect 
        ? (_getScoreForMode() * newCombo) 
        : 0;

    newPendingStats.add({
      'operationId': state!.operation,
      'score': hintUsed ? (questionScore ~/ 2) : questionScore,
      'isCorrect': isCorrect,
      'timeSpent': timeSpent,
      'mode': state!.mode.name,
      'levelKey': '${state!.operation}_${state!.level}',
    });

    state = state!.copyWith(
      score: newScore,
      correctAnswers: newCorrect,
      lives: newLives,
      userAnswers: newUserAnswers,
      comboMultiplier: newCombo,
      lastAnswerTime: now,
      pendingStats: newPendingStats,
      heatIndex: newHeat,
      questions: updatedQuestions,
    );
    ref.read(soundManagerProvider).updateHeat(newHeat);

    // Record per-answer session stats
    ref.read(sessionStatsProvider.notifier).recordAnswer(
      state!.operation,
      isCorrect,
      timeSpent,
      hintUsed,
    );

    // Record for dynamic difficulty
    ref.read(playerPerformanceProvider.notifier).recordAnswer(
      operation: state!.operation,
      isCorrect: isCorrect,
      responseTimeMs: timeSpent * 1000,
      hintsUsed: hintUsed ? 1 : 0,
    );
    ref.read(dynamicDifficultyProvider.notifier).recordAssessment(isCorrect: isCorrect);

    if (state!.mode == GameMode.duel) {
      _duelAnswered = true;
      _duelTimer?.cancel();
    }

    _goToNextOrEnd();
  }

  void skipQuestion() {
    if (state == null || state!.currentQuestion == null) return;

    if (!state!.userAnswers.containsKey(state!.currentQuestionIndex)) {
      final newUserAnswers = Map<int, dynamic>.from(state!.userAnswers);
      newUserAnswers[state!.currentQuestionIndex] = null; // null means skipped
      state = state!.copyWith(userAnswers: newUserAnswers);
      ref.read(dailyChallengeProvider.notifier).updateProgressMax('streak', 0);
    }

    _goToNextOrEnd();
  }

  void previousQuestion() {
    if (state != null && state!.currentQuestionIndex > 0) {
      state = state!.copyWith(
        currentQuestionIndex: state!.currentQuestionIndex - 1,
      );
    }
  }

  void useHint() {
    if (state == null || state!.currentQuestion == null) return;

    // Check if user has enough points
    final user = ref.read(userSessionProvider);
    if (user == null || user.totalPoints < hintCostPoints) return;

    // Deduct points
    ref.read(userSessionProvider.notifier).addPoints(-hintCostPoints);
    ref.read(soundManagerProvider).playEffect('hint');

    final newHintsUsed = Map<int, bool>.from(state!.hintsUsed);
    newHintsUsed[state!.currentQuestionIndex] = true;
    state = state!.copyWith(hintsUsed: newHintsUsed);
  }

  void _goToNextOrEnd() {
    if (state == null) return;

    final newIndex = state!.currentQuestionIndex + 1;
    VisualCountingData? nextVisualData;
    if (state!.isVisualCounting && newIndex < state!.totalQuestions) {
      nextVisualData = _generateVisualCountingData(state!.level);
    }

    if (newIndex >= state!.totalQuestions || state!.lives <= 0) {
      if (state!.mode == GameMode.duel) {
        final playerWon =
            state!.score > (state!.aiScore ?? 0) ||
            (state!.score == (state!.aiScore ?? 0) &&
                state!.correctAnswers > (state!.aiCorrectAnswers ?? 0));
        state = state!.copyWith(
          currentQuestionIndex: newIndex,
          playerWon: playerWon,
        );
      } else {
        state = state!.copyWith(currentQuestionIndex: newIndex);
      }
      _endGame();
    } else {
      state = state!.copyWith(
        currentQuestionIndex: newIndex,
        currentVisualData: nextVisualData,
      );

      if (state!.mode == GameMode.duel) {
        _processDuelTurn();
      }
    }
  }

  int _getScoreForMode() {
    switch (state?.mode) {
      case GameMode.campaign:
        return 10;
      case GameMode.practice:
        return 0;
      case GameMode.scoreAttack:
        final level = state?.level ?? 1;
        return (10 + (level ~/ 5)).clamp(10, 20);
      case GameMode.endless:
        final streak = state?.correctAnswers ?? 0;
        return (10 + (streak ~/ 5) * 2).clamp(10, 30);
      case GameMode.duel:
        return 15;
      case GameMode.flash:
        return 15;
      case GameMode.speedDemon:
        return 20; // high points for speed
      case GameMode.mathMaster:
        return 15;
      case GameMode.marathon:
        return 15;
      default:
        return 10;
    }
  }

  void answerVisualCounting(int answer) {
    if (state == null || state!.currentVisualData == null) return;

    final isCorrect = answer == state!.currentVisualData!.targetCount;
    int newScore = state!.score;
    int newCorrect = state!.correctAnswers;
    int newLives = state!.lives;

    if (isCorrect) {
      ref.read(soundManagerProvider).playCorrect();
      newScore += 15;
      newCorrect++;
    } else {
      ref.read(soundManagerProvider).playIncorrect();
      if (state!.mode == GameMode.endless) {
        newLives--;
      }
    }

    final newPendingStats = List<Map<String, dynamic>>.from(state!.pendingStats);
    newPendingStats.add({
      'operationId': 'visual_counting',
      'isCorrect': isCorrect,
      'timeSpent': 0, // Visual counting doesn't track time per item yet
    });

    state = state!.copyWith(
      score: newScore,
      correctAnswers: newCorrect,
      lives: newLives,
      pendingStats: newPendingStats,
    );

    // Record per-answer session stats
    ref.read(sessionStatsProvider.notifier).recordAnswer(
      'visual_counting',
      isCorrect,
      0,
      false,
    );

    // Record for dynamic difficulty
    ref.read(playerPerformanceProvider.notifier).recordAnswer(
      operation: 'visual_counting',
      isCorrect: isCorrect,
      responseTimeMs: 0,
      hintsUsed: 0,
    );
    ref.read(dynamicDifficultyProvider.notifier).recordAssessment(isCorrect: isCorrect);

    _goToNextOrEnd();
  }

  VisualCountingData _generateVisualCountingData(int level) {
    final count = MathEngine.generateVisualCount(level);
    final shapes = _generateNonOverlappingShapes(count);
    return VisualCountingData(targetCount: count, shapes: shapes);
  }

  List<ShapeData> _generateNonOverlappingShapes(int count) {
    final shapes = <ShapeData>[];
    final colors = [0xFF6366F1, 0xFF22D3EE, 0xFFF472B6, 0xFF22C55E, 0xFFFACC15];
    final types = ['circle', 'triangle', 'star'];
    const containerWidth = 300.0;
    const containerHeight = 300.0;
    const minSize = 30.0;
    const maxSize = 50.0;
    const padding = 10.0;
    const maxAttempts = 100;

    for (int i = 0; i < count; i++) {
      bool placed = false;
      int attempts = 0;

      while (!placed && attempts < maxAttempts) {
        final size = minSize + _random.nextDouble() * (maxSize - minSize);
        final x =
            padding +
            _random.nextDouble() * (containerWidth - size - padding * 2);
        final y =
            padding +
            _random.nextDouble() * (containerHeight - size - padding * 2);

        bool overlaps = false;
        for (final existing in shapes) {
          final dx = (existing.x + existing.size / 2) - (x + size / 2);
          final dy = (existing.y + existing.size / 2) - (y + size / 2);
          final distance = sqrt(dx * dx + dy * dy);
          final minDistance = (existing.size + size) / 2 + padding;

          if (distance < minDistance) {
            overlaps = true;
            break;
          }
        }

        if (!overlaps) {
          shapes.add(
            ShapeData(
              type: types[_random.nextInt(types.length)],
              x: x,
              y: y,
              size: size,
              color: colors[_random.nextInt(colors.length)],
            ),
          );
          placed = true;
        }
        attempts++;
      }

      if (!placed) {
        shapes.add(
          ShapeData(
            type: types[_random.nextInt(types.length)],
            x:
                padding +
                _random.nextDouble() * (containerWidth - maxSize - padding * 2),
            y:
                padding +
                _random.nextDouble() *
                    (containerHeight - maxSize - padding * 2),
            size: minSize,
            color: colors[_random.nextInt(colors.length)],
          ),
        );
      }
    }

    return shapes;
  }

  static const int questionsPerLevel = 45;
  static const int correctToPass = 35;

  void _endGame() {
    _timer?.cancel();
    _duelTimer?.cancel();
    
    // Clear preload cache when game ends
    GameFlowOptimizer.clearPreloadCache();

    if (state == null) return;

    // Batch update stats
    if (state!.pendingStats.isNotEmpty) {
      final statsRepo = ref.read(statisticsRepositoryProvider);
      
      int sessionTotalTime = 0;
      int sessionCorrect = 0;
      
      for (final stat in state!.pendingStats) {
        sessionTotalTime += stat['timeSpent'] as int;
        if (stat['isCorrect'] as bool) sessionCorrect++;
        
        statsRepo.updateStatistics(
          operationId: stat['operationId'] as String,
          score: stat['score'] as int,
          isCorrect: stat['isCorrect'] as bool,
          timeSpent: stat['timeSpent'] as int,
          mode: stat['mode'] as String?,
          levelKey: stat['levelKey'] as String?,
        );
      }

      // Update Skill Rating based on session performance
      _updateSkillRating(sessionCorrect, state!.totalQuestions, sessionTotalTime);
      
      // Update Performance Trends
      final avgTime = state!.totalQuestions > 0 ? sessionTotalTime / state!.totalQuestions : 0.0;
      ref.read(performanceTrendsProvider.notifier).addDataPoint(
        (sessionCorrect / state!.totalQuestions) * 100,
        avgTime.toInt(),
        state!.comboMultiplier,
        heat: state!.heatIndex,
      );
      
      // Refresh real-time providers
      ref.invalidate(overallAccuracyProvider);
      ref.invalidate(totalTimePlayedProvider);
      ref.invalidate(bestStreakProvider);
    }

    final isCampaign = state!.mode == GameMode.campaign;
    final passed = state!.correctAnswers >= getCampaignPassThreshold(state!.totalQuestions);

    if (isCampaign) {
      final stars = _calculateStarsForCampaign(
        state!.correctAnswers,
        state!.totalQuestions,
        state!.timeRemaining,
      );

      final levelProgressRepo = ref.read(levelProgressRepositoryProvider);
      levelProgressRepo.updateStars(
        state!.operation,
        state!.level,
        stars,
        state!.score,
      );

      ref.read(levelProgressProvider.notifier).refreshProgress();

      // Update Daily Challenge for stars
      if (stars > 0) {
        ref.read(dailyChallengeProvider.notifier).incrementProgress('stars', stars);
      }

      if (passed) {
        _unlockNextLevel(state!.operation, state!.level);
        
        int totalReward = state!.score;
        // Boss Level Bonus
        if (state!.isBossLevel) {
          totalReward += 1000; // Large bonus for boss levels
          NotificationService().showAchievementNotification(
            'Chapter Completed!',
            'You\'ve defeated the boss of Level ${state!.level}!',
          );
        }
        
        ref.read(userSessionProvider.notifier).updateUser(
          totalPoints: (ref.read(userSessionProvider)?.totalPoints ?? 0) + totalReward,
          lastPlayedMode: state!.mode.name,
          lastPlayedOperation: state!.operation,
          lastPlayedLevel: state!.level,
          lastHeatIndex: state!.heatIndex,
        );
      } else {
         ref.read(userSessionProvider.notifier).updateUser(
          lastPlayedMode: state!.mode.name,
          lastPlayedOperation: state!.operation,
          lastPlayedLevel: state!.level,
          lastHeatIndex: state!.heatIndex,
        );
      }
    } else {
      if (state!.score > 0) {
        final userNotifier = ref.read(userSessionProvider.notifier);
        userNotifier.updateUser(
          totalPoints: (ref.read(userSessionProvider)?.totalPoints ?? 0) + state!.score,
          lastPlayedMode: state!.mode.name,
          lastPlayedOperation: state!.operation,
          lastPlayedLevel: state!.level,
          lastHeatIndex: state!.heatIndex,
        );
      } else {
        ref.read(userSessionProvider.notifier).updateUser(
          lastPlayedMode: state!.mode.name,
          lastPlayedOperation: state!.operation,
          lastPlayedLevel: state!.level,
          lastHeatIndex: state!.heatIndex,
        );
      }

      // Update Daily Challenges for Arcade modes
      final challengeNotifier = ref.read(dailyChallengeProvider.notifier);
      
      if (state!.mode == GameMode.duel && (state!.playerWon ?? false)) {
        challengeNotifier.incrementProgress('wins', 1);
      }
      
      if (state!.mode == GameMode.endless) {
        challengeNotifier.updateProgressMax('score', state!.score);
      }

      if (state!.totalQuestions > 0) {
        final accuracy = state!.correctAnswers / state!.totalQuestions;
        if (accuracy >= 1.0 && state!.totalQuestions >= 10) {
          challengeNotifier.incrementProgress('accuracy', 1);
        }
      }
    }

    // Record performance trends for completed sessions
    if (state!.totalQuestions > 0) {
      final accuracy = (state!.correctAnswers / state!.totalQuestions) * 100;
      final durationSeconds = 600 - state!.timeRemaining;
      final avgTime = state!.totalQuestions > 0 ? durationSeconds / state!.totalQuestions : 0.0;
      
      final hintsUsed = state!.hintsUsed.values.where((used) => used).length;

      ref.read(performanceTrendsProvider.notifier).addDataPoint(
        accuracy,
        avgTime.toInt(),
        state!.correctAnswers.toInt(), 
      );

      // Check Achievements
      final achievements = ref.read(achievementDatabaseProvider);
      final achievementNotifier = ref.read(achievementStateProvider.notifier);
      
      achievementNotifier.checkAndUnlock('accuracy', accuracy.toInt(), achievements);
      achievementNotifier.checkAndUnlock('speed_run', state!.correctAnswers.toInt(), achievements, timeValue: durationSeconds.toInt());
      achievementNotifier.checkAndUnlock('questions', state!.totalQuestions, achievements);

      // Unify analytics recording
      ref.read(analyticsProvider.notifier).recordSession(
        state!.operation,
        durationSeconds.toInt(),
        state!.totalQuestions,
        state!.correctAnswers.toInt(),
        hintsUsed,
        mode: state!.mode.name,
      );
    }

    state = state!.copyWith(
      state: GameState.finished,
      playerWon: isCampaign ? passed : null,
    );
  }

  int _calculateStarsForCampaign(int correct, int total, int timeRemaining) {
    double percentage = (correct / total) * 100;
    int stars = 0;

    if (percentage >= 95) {
      stars = 3;
    } else if (percentage >= 85) {
      stars = 2;
    } else if (percentage >= 75) {
      stars = 1;
    }

    // Time Bonus: If the player is exceptionally fast (more than 20s remaining)
    // and they were close to the next star tier, give them a boost.
    if (timeRemaining > 20 && stars > 0 && stars < 3) {
      if (percentage >= 90 && stars == 2) {
        stars = 3;
      }
      if (percentage >= 80 && stars == 1) {
        stars = 2;
      }
    }

    return stars;
  }

  void _unlockNextLevel(String operation, int currentLevel) {
    try {
      final levelProgressRepo = ref.read(levelProgressRepositoryProvider);
      final nextLevel = currentLevel + 1;
      
      if (nextLevel <= 100) {
        levelProgressRepo.unlockLevel(operation, nextLevel);
      }
    } catch (e) {
      // Repository might not be initialized yet
    }
  }

  void _updateSkillRating(int correct, int total, int totalTime) {
    if (total == 0) return;
    
    final user = ref.read(userSessionProvider);
    if (user == null) return;

    final accuracy = correct / total;
    final avgTime = totalTime / total;
    
    // Skill rating logic:
    // Base gain/loss from accuracy
    double delta = (accuracy - 0.7) * 50; 
    
    // Time-based adjustment (bonus for speed)
    if (accuracy > 0.8) {
      if (avgTime < 3.0) {
        delta += 15;
      } else if (avgTime < 5.0) {
        delta += 10;
      } else if (avgTime > 10.0) {
        delta -= 5;
      }
    }

    // Heat Bonus: If the player sustained high heat, give a rating boost
    if (state != null && state!.heatIndex > 2.0) {
      delta += (state!.heatIndex - 2.0) * 20;
    }

    final newRating = (user.skillRating + delta).toInt().clamp(100, 3000);
    ref.read(userSessionProvider.notifier).updateUser(skillRating: newRating);
  }

  void pauseGame() {
    _timer?.cancel();
    _duelTimer?.cancel();
    if (state != null) {
      state = state!.copyWith(state: GameState.paused);
    }
  }

  void resumeGame() {
    if (state != null) {
      state = state!.copyWith(state: GameState.playing);
      if (state!.mode == GameMode.scoreAttack) {
        _startTimer();
      } else if (state!.mode == GameMode.duel) {
        _processDuelTurn();
      }
    }
  }

  void endGame() {
    _timer?.cancel();
    _duelTimer?.cancel();
    state = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _duelTimer?.cancel();
    super.dispose();
  }
}
