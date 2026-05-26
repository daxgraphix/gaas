import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/math_engine/math_engine.dart';
import '../../../core/providers.dart';
import '../../../core/sound_manager.dart';

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
  final Map<int, int?> userAnswers;
  final Map<int, bool> hintsUsed;
  final int comboMultiplier;
  final DateTime? lastAnswerTime;
  final bool isBossLevel;
  final VisualCountingData? currentVisualData;
  final List<Map<String, dynamic>> pendingStats;

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
    this.totalQuestions = 30,
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
    Map<int, int?>? userAnswers,
    Map<int, bool>? hintsUsed,
    int? comboMultiplier,
    DateTime? lastAnswerTime,
    bool? isBossLevel,
    VisualCountingData? currentVisualData,
    List<Map<String, dynamic>>? pendingStats,
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
  static const int campaignPassThreshold = 25;
  final Ref ref;
  Timer? _timer;
  Timer? _duelTimer;
  final Random _random = Random();
  bool _duelAnswered = false;

  GameSessionNotifier(this.ref) : super(null);

  void startGame({
    required GameMode mode,
    required String operation,
    int level = 1,
    int minNumber = 1,
    int maxNumber = 10,
    bool isVisualCounting = false,
    int totalQuestions = 30,
    int? timeLimit,
  }) {
    _timer?.cancel();
    _duelTimer?.cancel();

    bool isBossLevel = false;
    int timeRemaining = 60;
    int lives = 3;

    if (mode == GameMode.campaign && level % 10 == 0) {
      isBossLevel = true;
      timeRemaining = 60; // Boss levels have a strict 60 second timer
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

    final questions = <MathQuestion>[];
    final generatedQuestions = <String>{};
    final isArcade =
        mode == GameMode.scoreAttack ||
        mode == GameMode.endless ||
        mode == GameMode.duel ||
        mode == GameMode.flash ||
        mode == GameMode.speedDemon ||
        mode == GameMode.mathMaster ||
        mode == GameMode.marathon;

    for (int i = 0; i < totalQuestions; i++) {
      MathQuestion q;
      if (mode == GameMode.mathMaster) {
        // Randomly pick an operation for each question
        final ops = ['addition', 'subtraction', 'multiplication', 'division'];
        final randomOp = ops[_random.nextInt(ops.length)];
        q = MathEngine.generateQuestion(
          randomOp,
          level,
          isArcade: isArcade,
          excludeQuestions: generatedQuestions,
        );
      } else {
        q = MathEngine.generateQuestion(
          operation,
          level,
          isArcade: isArcade,
          excludeQuestions: generatedQuestions,
        );
      }
      generatedQuestions.add(q.displayString);
      questions.add(q);
    }

    // Shuffle questions for random order
    questions.shuffle();

    int? aiScore;
    int? aiCorrectAnswers;
    if (mode == GameMode.duel) {
      aiScore = 0;
      aiCorrectAnswers = 0;
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
    );

    if (mode == GameMode.scoreAttack ||
        mode == GameMode.speedDemon ||
        isBossLevel) {
      _startTimer();
    } else if (mode == GameMode.duel) {
      _startDuelMode();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state != null && state!.timeRemaining > 0) {
        state = state!.copyWith(timeRemaining: state!.timeRemaining - 1);
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

  void answerQuestion(int answer) {
    if (state == null || state!.currentQuestion == null) return;

    // If question already answered, do not count again (for next/prev feature)
    if (state!.userAnswers.containsKey(state!.currentQuestionIndex)) {
      _goToNextOrEnd();
      return;
    }

    final isCorrect = answer == state!.currentQuestion!.correctAnswer;
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
      HapticManager.successPattern();
      final baseScore = _getScoreForMode();
      newScore += (hintUsed ? (baseScore ~/ 2) : baseScore) * newCombo;
      newCorrect++;

      // Update Daily Challenges - increment question count for all modes
      final challengeNotifier = ref.read(dailyChallengeProvider.notifier);
      challengeNotifier.incrementProgress('questions', 1);
      // Check actual question operation for division tracking
      if (state!.currentQuestion?.operation == 'division') {
        challengeNotifier.incrementProgress('division', 1);
      }
      if (state!.mode == GameMode.speedDemon) {
        challengeNotifier.incrementProgress('speed', 1);
      }
      challengeNotifier.incrementProgress('streak', 1);
    } else {
      HapticManager.errorPattern();
      newCombo = 1; // Reset combo on wrong answer
      if (state!.mode == GameMode.endless) {
        newLives--;
      }
      if (state!.isBossLevel) {
        newLives--; // Boss levels penalize mistakes heavily
      }
      // Reset streak
      ref.read(dailyChallengeProvider.notifier).updateProgressMax('streak', 0);
    }

    final newUserAnswers = Map<int, int?>.from(state!.userAnswers);
    newUserAnswers[state!.currentQuestionIndex] = answer;

    final newPendingStats = List<Map<String, dynamic>>.from(state!.pendingStats);
    final timeSpent = state!.lastAnswerTime == null
        ? 0
        : now.difference(state!.lastAnswerTime!).inSeconds.clamp(1, 120);

    newPendingStats.add({
      'operationId': state!.operation,
      'isCorrect': isCorrect,
      'timeSpent': timeSpent,
    });

    state = state!.copyWith(
      score: newScore,
      correctAnswers: newCorrect,
      lives: newLives,
      userAnswers: newUserAnswers,
      comboMultiplier: newCombo,
      lastAnswerTime: now,
      pendingStats: newPendingStats,
    );

    if (state!.mode == GameMode.duel) {
      _duelAnswered = true;
      _duelTimer?.cancel();
    }

    _goToNextOrEnd();
  }

  void skipQuestion() {
    if (state == null || state!.currentQuestion == null) return;

    if (!state!.userAnswers.containsKey(state!.currentQuestionIndex)) {
      final newUserAnswers = Map<int, int?>.from(state!.userAnswers);
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
      HapticManager.successPattern();
      newScore += 15;
      newCorrect++;
    } else {
      HapticManager.errorPattern();
      if (state!.mode == GameMode.endless) {
        newLives--;
      }
    }

    final newPendingStats = List<Map<String, dynamic>>.from(state!.pendingStats);
    newPendingStats.add({
      'operationId': 'visual_counting',
      'isCorrect': isCorrect,
      'timeSpent': 0,
    });

    state = state!.copyWith(
      score: newScore,
      correctAnswers: newCorrect,
      lives: newLives,
      pendingStats: newPendingStats,
    );

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

  static const int questionsPerLevel = 15;
  static const int correctToPass = 10;

  void _endGame() {
    _timer?.cancel();
    _duelTimer?.cancel();
    if (state == null) return;

    // Batch update stats
    if (state!.pendingStats.isNotEmpty) {
      final statsRepo = ref.read(statisticsRepositoryProvider);
      for (final stat in state!.pendingStats) {
        statsRepo.updateStatistics(
          operationId: stat['operationId'] as String,
          score: stat['score'] as int,
          isCorrect: stat['isCorrect'] as bool,
          timeSpent: stat['timeSpent'] as int,
        );
      }
    }

    final isCampaign = state!.mode == GameMode.campaign;
    final passed = state!.correctAnswers >= correctToPass;

    if (isCampaign) {
      final stars = _calculateStarsForCampaign(
        state!.correctAnswers,
        state!.totalQuestions,
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
        ref.read(userSessionProvider.notifier).addPoints(state!.score);
      }
    } else {
      if (state!.score > 0) {
        final userNotifier = ref.read(userSessionProvider.notifier);
        userNotifier.addPoints(state!.score);
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
      final avgTime = state!.totalQuestions > 0 ? (600 - state!.timeRemaining) ~/ state!.totalQuestions : 0; // Rough estimate
      final hintsUsed = state!.hintsUsed.values.where((used) => used).length;

      ref.read(performanceTrendsProvider.notifier).addDataPoint(
        accuracy,
        avgTime,
        hintsUsed, // Using hints as streak proxy for now
      );

      // Also record session stats
      ref.read(sessionStatsProvider.notifier).recordAnswer(
        state!.operation,
        true, // Session completed
        avgTime,
        hintsUsed > 0,
      );
    }

    state = state!.copyWith(
      state: GameState.finished,
      playerWon: isCampaign ? passed : null,
    );
  }

  int _calculateStarsForCampaign(int correct, int total) {
    if (total == 0) return 0;
    final percentage = (correct / total) * 100;
    if (percentage >= 90) return 3;
    if (percentage >= 70) return 2;
    if (percentage >= 50) return 1;
    return 0;
  }

  void _unlockNextLevel(String operation, int currentLevel) {
    try {
      final notifier = ref.read(campaignUnlockedLevelsProvider.notifier);
      final currentUnlocked = ref.read(campaignUnlockedLevelsProvider);
      final nextLevelToUnlock = currentLevel + 1;

      if (nextLevelToUnlock <= 30) {
        final current = currentUnlocked[operation] ?? 2;
        if (nextLevelToUnlock > current) {
          notifier.update({...currentUnlocked, operation: nextLevelToUnlock});
        }
      }
    } catch (e) {
      // Provider might not be initialized yet
    }
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
