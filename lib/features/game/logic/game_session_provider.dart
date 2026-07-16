import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/game_flow_optimizer.dart';
import '../../../core/math_engine/math_engine.dart';
import '../../../core/providers.dart';
import '../../../core/notification_service.dart';
import '../../../core/game_adaptability/dynamic_difficulty_system.dart' as difficulty;
import '../../../data/content_library/achievement_system.dart';
import '../../analytics/analytics_provider.dart';
import 'session_stats_provider.dart';
import 'player_performance_provider.dart';

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
  customMix,
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
  final MathQuestion? currentQuestion;
  final int currentQuestionIndex;
  final int score;
  final int correctAnswers;
  final int currentStreak;
  final int bestStreak;
  final int lives;
  final int timeRemaining;
  final int totalQuestions;
  final bool isVisualCounting;
  final int? aiScore;
  final int? aiCorrectAnswers;
  final bool? playerWon;
  final Map<int, dynamic> userAnswers;
  final Map<int, bool> hintsUsed;
  final List<String> revealedHints;
  final int comboMultiplier;
  final DateTime? lastAnswerTime;
  final bool isBossLevel;
  final VisualCountingData? currentVisualData;
  final List<Map<String, dynamic>> pendingStats;
  final int? ghostScore;
  final double heatIndex;
  final bool feverActive;

  GameSession({
    required this.mode,
    this.state = GameState.playing,
    required this.operation,
    required this.level,
    this.minNumber = 1,
    this.maxNumber = 10,
    required this.questions,
    this.currentQuestion,
    this.currentQuestionIndex = 0,
    this.score = 0,
    this.correctAnswers = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lives = 3,
    this.timeRemaining = 60,
    this.totalQuestions = 45,
    this.isVisualCounting = false,
    this.aiScore,
    this.aiCorrectAnswers,
    this.playerWon,
    this.userAnswers = const {},
    this.hintsUsed = const {},
    this.revealedHints = const [],
    this.comboMultiplier = 1,
    this.lastAnswerTime,
    this.isBossLevel = false,
    this.currentVisualData,
    this.pendingStats = const [],
    this.ghostScore,
    this.heatIndex = 1.0,
    this.feverActive = false,
  });

  int get questionsRemaining => totalQuestions - currentQuestionIndex;

  double get accuracy => totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;
  
  int get stars {
    if (mode == GameMode.campaign) {
      double pct = accuracy;
      int s = 0;
      if (pct >= 95) {
        s = 3;
      } else if (pct >= 85) {
        s = 2;
      } else if (pct >= 75) {
        s = 1;
      }

      // Time Bonus: If the player is exceptionally fast (more than 20s remaining)
      // and they were close to the next star tier, give them a boost.
      if (timeRemaining > 20 && s > 0 && s < 3) {
        if (pct >= 90 && s == 2) s = 3;
        if (pct >= 80 && s == 1) s = 2;
      }
      return s;
    } else {
      // General star calculation for other modes if applicable
      double pct = accuracy;
      if (pct >= 95) return 3;
      if (pct >= 85) return 2;
      if (pct >= 75) return 1;
      return 0;
    }
  }

  bool get passed {
    if (mode == GameMode.campaign) {
      return correctAnswers >= (totalQuestions * 0.7).ceil(); // 70% threshold
    }
    return true; // Other modes usually "pass" if completed
  }

  GameSession copyWith({
    GameMode? mode,
    GameState? state,
    String? operation,
    int? level,
    List<MathQuestion>? questions,
    MathQuestion? currentQuestion,
    int? currentQuestionIndex,
    int? score,
    int? correctAnswers,
    int? currentStreak,
    int? bestStreak,
    int? lives,
    int? timeRemaining,
    int? totalQuestions,
    bool? isVisualCounting,
    int? aiScore,
    int? aiCorrectAnswers,
    bool? playerWon,
    Map<int, dynamic>? userAnswers,
    Map<int, bool>? hintsUsed,
    List<String>? revealedHints,
    int? comboMultiplier,
    DateTime? lastAnswerTime,
    bool? isBossLevel,
    VisualCountingData? currentVisualData,
    List<Map<String, dynamic>>? pendingStats,
    int? ghostScore,
    double? heatIndex,
    bool? feverActive,
  }) {
    return GameSession(
      mode: mode ?? this.mode,
      state: state ?? this.state,
      operation: operation ?? this.operation,
      level: level ?? this.level,
      questions: questions ?? this.questions,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lives: lives ?? this.lives,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      isVisualCounting: isVisualCounting ?? this.isVisualCounting,
      aiScore: aiScore ?? this.aiScore,
      aiCorrectAnswers: aiCorrectAnswers ?? this.aiCorrectAnswers,
      playerWon: playerWon ?? this.playerWon,
      userAnswers: userAnswers ?? this.userAnswers,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      revealedHints: revealedHints ?? this.revealedHints,
      comboMultiplier: comboMultiplier ?? this.comboMultiplier,
      lastAnswerTime: lastAnswerTime ?? this.lastAnswerTime,
      isBossLevel: isBossLevel ?? this.isBossLevel,
      currentVisualData: currentVisualData ?? this.currentVisualData,
      pendingStats: pendingStats ?? this.pendingStats,
      ghostScore: ghostScore ?? this.ghostScore,
      heatIndex: heatIndex ?? this.heatIndex,
      feverActive: feverActive ?? this.feverActive,
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
    int? totalQuestions,
    int? timeLimit,
    List<MathQuestion>? preloadedQuestions,
  }) async {
    _timer?.cancel();
    _duelTimer?.cancel();

    bool isBossLevel = false;
    int calculatedTotalQuestions = totalQuestions ?? 45;
    int timeRemaining = 60;
    int lives = 3;

    // Mode-specific configuration
    if (mode == GameMode.campaign) {
      timeRemaining = 0;
      calculatedTotalQuestions = level <= 50 ? 50 : 60;
      if (level % 10 == 0) {
        isBossLevel = true;
      }
    } else if (mode == GameMode.scoreAttack) {
      timeRemaining = (90 + (level - 1) * 1.5).round().clamp(90, 240);
      calculatedTotalQuestions = (200 * (1 + level * 0.05)).toInt();
    } else if (mode == GameMode.speedDemon) {
      timeRemaining = (45 + (level - 1) * 0.5).round().clamp(45, 90);
      calculatedTotalQuestions = (40 * (1 + level * 0.05)).toInt();
    } else if (mode == GameMode.endless) {
      timeRemaining = 0;
      calculatedTotalQuestions = 1000; // Effectively endless
      lives = 3;
    } else if (mode == GameMode.mathMaster) {
      timeRemaining = 0;
      calculatedTotalQuestions = (100 * (1 + level * 0.05)).toInt();
      lives = 999;
    } else if (mode == GameMode.marathon) {
      timeRemaining = 0;
      calculatedTotalQuestions = 500;
      lives = 999;
    } else if (mode == GameMode.duel) {
      timeRemaining = 0;
      calculatedTotalQuestions = 50;
    } else if (mode == GameMode.flash) {
      timeRemaining = (60 + (level - 1) * 0.6).round().clamp(60, 120);
      calculatedTotalQuestions = (50 * (1 + level * 0.05)).toInt();
    } else if (mode == GameMode.customMix) {
      timeRemaining = timeLimit ?? 60;
    }

    // Explicit overrides
    if (timeLimit != null) timeRemaining = timeLimit;
    if (totalQuestions != null) calculatedTotalQuestions = totalQuestions;

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
          mode == GameMode.marathon ||
          mode == GameMode.customMix;

      final batch = await MathEngine.generateQuestionsBatch(
        operation,
        level,
        calculatedTotalQuestions,
        isArcade: isArcade,
        skillRating: skillRating,
        heatIndex: 1.0, // Initial heat is 1.0
      );
      questions.addAll(batch);
      
      // Shuffle questions for random order unless it's a specific ordered mode
      if (mode != GameMode.campaign) {
        questions.shuffle();
      }
    }

    // Save session info to user profile for "Quick Resume"
    ref.read(userSessionProvider.notifier).updateUser(
          lastPlayedMode: mode.name,
          lastPlayedOperation: operation,
          lastPlayedLevel: level,
          lastPlayedAt: DateTime.now(),
          lastHeatIndex: user?.lastHeatIndex ?? 1.0,
        );

    state = GameSession(
      mode: mode,
      operation: operation,
      level: level,
      minNumber: minNumber,
      maxNumber: maxNumber,
      questions: questions,
      currentQuestion: questions.isNotEmpty ? questions[0] : null,
      totalQuestions: calculatedTotalQuestions,
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
        mode == GameMode.speedDemon ||
        (mode == GameMode.customMix && timeRemaining > 0)) {
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
          newHeat = (newHeat - 0.05).clamp(1.0, 4.0);
        }

        state = state!.copyWith(
          timeRemaining: state!.timeRemaining - 1,
          heatIndex: newHeat,
        );
        ref.read(soundManagerProvider).updateHeat(newHeat);
      } else if (state != null && (state!.mode == GameMode.scoreAttack || state!.mode == GameMode.speedDemon || (state!.mode == GameMode.customMix && state!.timeRemaining <= 0)) && state!.timeRemaining <= 0) {
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
    
    // Performance improvement: track stats early
    final now = DateTime.now();
    final timeSpent = state!.lastAnswerTime == null
        ? 2 // minimum 2s for first question
        : now.difference(state!.lastAnswerTime!).inSeconds.clamp(1, 120);

    int newScore = state!.score;
    int newCorrect = state!.correctAnswers;
    int newLives = state!.lives;
    int newStreak = isCorrect ? state!.currentStreak + 1 : 0;
    int newBestStreak = max(state!.bestStreak, newStreak);

    final hintUsed = state!.hintsUsed[state!.currentQuestionIndex] ?? false;
    final challengeNotifier = ref.read(dailyChallengeProvider.notifier);

    challengeNotifier.incrementProgress('questions', 1);
    challengeNotifier.updateProgressMax('streak', newStreak);

    int newCombo = state!.comboMultiplier;
    bool newFever = state!.feverActive;

    if (state!.lastAnswerTime != null &&
        now.difference(state!.lastAnswerTime!).inSeconds <= 4) {
      newCombo = (newCombo < 4) ? newCombo + 1 : 4;
      if (newCombo >= 4 && !newFever) {
        newFever = true;
        ref.read(soundManagerProvider).playEffect('fever_start');
      }
    } else {
      newCombo = 1;
      if (newFever) {
        newFever = false;
        ref.read(soundManagerProvider).playEffect('fever_end');
      }
    }

    int bonusSeconds = 0;
    int questionScore = 0;
    if (isCorrect) {
      ref.read(soundManagerProvider).playCorrect();
      challengeNotifier.incrementProgress('correct', 1);
      final baseScore = _getScoreForMode();
      int multiplier = newCombo;
      if (newFever) multiplier *= 2; // Double points during fever
      
      questionScore = (hintUsed ? (baseScore ~/ 2) : baseScore) * multiplier;
      newScore += questionScore;
      newCorrect++;

      // Time Bonus for Score Attack and Speed Demon
      if (state!.mode == GameMode.scoreAttack) {
        bonusSeconds = 2 + (multiplier ~/ 2);
      } else if (state!.mode == GameMode.speedDemon) {
        bonusSeconds = 1 + (newFever ? 1 : 0);
      }

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

      if (state!.currentQuestion?.operation == 'division') {
        challengeNotifier.incrementProgress('division', 1);
      }
      if (state!.mode == GameMode.speedDemon) {
        challengeNotifier.incrementProgress('speed', 1);
      }
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
    newPendingStats.add({
      'operationId': state!.operation,
      'isCorrect': isCorrect,
      'timeSpent': timeSpent,
      'score': questionScore,
      'mode': state!.mode.name,
      'levelKey': '${state!.operation}_${state!.level}',
    });

    // Calculate Heat Index: increases if answering quickly and correctly
    double newHeat = state!.heatIndex;
    if (isCorrect) {
      if (timeSpent <= 3) {
        newHeat += 0.15; // Increased heat gain
      } else if (timeSpent <= 5) {
        newHeat += 0.08;
      }
    } else {
      newHeat = (newHeat - 0.25).clamp(1.0, 4.0);
    }
    
    // Endless mode makes heat increase faster over time
    if (state!.mode == GameMode.endless) {
       newHeat += 0.02;
    }
    
    newHeat = newHeat.clamp(1.0, 4.0);

    // If heat increased significantly, inject a tougher question
    List<MathQuestion> updatedQuestions = List.from(state!.questions);
    if (newHeat > state!.heatIndex + 0.1 && state!.currentQuestionIndex + 1 < state!.totalQuestions) {
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



    state = state!.copyWith(
      score: newScore,
      correctAnswers: newCorrect,
      currentStreak: newStreak,
      bestStreak: max(state!.bestStreak, newBestStreak),
      lives: newLives,
      timeRemaining: state!.timeRemaining + bonusSeconds,
      userAnswers: newUserAnswers,
      comboMultiplier: newCombo,
      feverActive: newFever,
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
    ref.read(difficulty.dynamicDifficultyProvider.notifier).recordAssessment(isCorrect: isCorrect);

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

    final question = state!.currentQuestion!;
    final currentRevealed = state!.revealedHints.length;
    
    if (currentRevealed >= question.progressiveHints.length) return;

    // Deduct points
    ref.read(userSessionProvider.notifier).addPoints(-hintCostPoints);
    ref.read(soundManagerProvider).playEffect('hint');

    final newHintsUsed = Map<int, bool>.from(state!.hintsUsed);
    newHintsUsed[state!.currentQuestionIndex] = true;
    
    final newRevealed = List<String>.from(state!.revealedHints);
    newRevealed.add(question.progressiveHints[currentRevealed]);

    state = state!.copyWith(
      hintsUsed: newHintsUsed,
      revealedHints: newRevealed,
    );
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
        currentQuestion: state!.questions[newIndex],
        currentVisualData: nextVisualData,
        revealedHints: [], // Reset revealed hints for next question
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
        return 5; // Practice now gives a small reward
      case GameMode.scoreAttack:
        final level = state?.level ?? 1;
        return (10 + (level ~/ 5)).clamp(10, 50);
      case GameMode.endless:
        final streak = state?.correctAnswers ?? 0;
        return (10 + (streak ~/ 5) * 5).clamp(10, 100);
      case GameMode.duel:
        return 25;
      case GameMode.flash:
        return 20;
      case GameMode.speedDemon:
        return 30; // high points for speed
      case GameMode.mathMaster:
        return 25;
      case GameMode.marathon:
        return 20;
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
      newScore += state!.mode == GameMode.practice ? 5 : 15;
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
    ref.read(difficulty.dynamicDifficultyProvider.notifier).recordAssessment(isCorrect: isCorrect);

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
        accuracy: (sessionCorrect / state!.totalQuestions) * 100,
        averageTimeMs: avgTime.toInt(),
        streak: state!.comboMultiplier,
        avgHeatIndex: state!.heatIndex,
      );
      
      // Refresh real-time providers
      ref.invalidate(overallAccuracyProvider);
      ref.invalidate(totalTimePlayedProvider);
      ref.invalidate(bestStreakProvider);
    }

    final isCampaign = state!.mode == GameMode.campaign;
    final passed = state!.passed;

    if (isCampaign) {
      final stars = state!.stars;

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
        
        final achievements = ref.read(achievementDatabaseProvider);
        final achievementNotifier = ref.read(achievementStateProvider.notifier);
        final currentStars = achievementNotifier.getProgress('total_stars');
        achievementNotifier.checkAndUnlock('total_stars', currentStars + stars, achievements);
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
      challengeNotifier.incrementProgress('arcade_sessions', 1);
      
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
      
      // Calculate total session time from pending stats for more accuracy
      int sessionTotalTime = 0;
      for (final stat in state!.pendingStats) {
        sessionTotalTime += stat['timeSpent'] as int;
      }
      
      // Fallback for modes where timer might be used but no pending stats (unlikely)
      final durationSeconds = sessionTotalTime > 0 
          ? sessionTotalTime 
          : (state!.mode == GameMode.scoreAttack || state!.mode == GameMode.speedDemon 
              ? (state!.timeRemaining == 0 ? 60 : 60 - state!.timeRemaining) 
              : 0);
              
      final avgTime = state!.totalQuestions > 0 ? durationSeconds / state!.totalQuestions : 0.0;
      final hintsUsed = state!.hintsUsed.values.where((used) => used).length;

      ref.read(performanceTrendsProvider.notifier).addDataPoint(
        accuracy: accuracy,
        averageTimeMs: avgTime.toInt(),
        streak: state!.correctAnswers.toInt(), 
        avgHeatIndex: state!.heatIndex,
      );

      // Check Achievements
      final achievements = ref.read(achievementDatabaseProvider);
      final achievementNotifier = ref.read(achievementStateProvider.notifier);
      
      achievementNotifier.checkAndUnlock('accuracy', accuracy.toInt(), achievements);
      achievementNotifier.checkAndUnlock('speed_run', state!.correctAnswers.toInt(), achievements, timeValue: durationSeconds.toInt());
      achievementNotifier.checkAndUnlock('questions', state!.totalQuestions, achievements);
      achievementNotifier.checkAndUnlock('streak', state!.bestStreak, achievements);
      achievementNotifier.checkAndUnlock('score', state!.score, achievements);
      
      if (accuracy >= 100 && state!.totalQuestions >= 10) {
        achievementNotifier.checkAndUnlock('perfect', 1, achievements);
      }

      if (state!.heatIndex >= 2.5) {
        achievementNotifier.checkAndUnlock('heat', 250, achievements);
      }

      if (avgTime < 2.0 && state!.totalQuestions >= 50) {
        achievementNotifier.checkAndUnlock('avg_time', 50, achievements, timeValue: avgTime.toInt());
      }
      
      if (state!.mode == GameMode.campaign && state!.level == 50 && passed) {
         achievementNotifier.checkAndUnlock('campaign_levels_unlocked', 50, achievements);
      }

      if (state!.mode == GameMode.duel && (state!.playerWon ?? false)) {
        final currentWins = achievementNotifier.getProgress('duel_wins');
        achievementNotifier.checkAndUnlock('duel_wins', currentWins + 1, achievements);
      }

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
