import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerProfile {
  final String id;
  final String name;
  final int totalGamesPlayed;
  final int totalWins;
  final int totalLosses;
  final double averageAccuracy;
  final double averageResponseTimeMs;
  final int highestStreak;
  final int currentStreak;
  final DateTime lastPlayedAt;
  final List<PlayerSessionHistory> recentSessions;

  PlayerProfile({
    required this.id,
    required this.name,
    this.totalGamesPlayed = 0,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.averageAccuracy = 0.5,
    this.averageResponseTimeMs = 5000,
    this.highestStreak = 0,
    this.currentStreak = 0,
    DateTime? lastPlayedAt,
    this.recentSessions = const [],
  }) : lastPlayedAt = lastPlayedAt ?? DateTime.now();

  double get winRate =>
      totalGamesPlayed > 0 ? totalWins / totalGamesPlayed : 0.5;
  double get performanceScore => _calculatePerformanceScore();
  PlayerSkillLevel get skillLevel => _determineSkillLevel();

  double _calculatePerformanceScore() {
    final accuracyWeight = averageAccuracy * 40;
    final speedWeight =
        ((10000 - averageResponseTimeMs.clamp(0, 10000)) / 10000) * 30;
    final streakWeight = (currentStreak / 50).clamp(0.0, 1.0) * 20;
    final winWeight = winRate * 10;
    return (accuracyWeight + speedWeight + streakWeight + winWeight).clamp(
      0,
      100,
    );
  }

  PlayerSkillLevel _determineSkillLevel() {
    final score = performanceScore;
    if (score >= 80) return PlayerSkillLevel.master;
    if (score >= 65) return PlayerSkillLevel.advanced;
    if (score >= 50) return PlayerSkillLevel.intermediate;
    if (score >= 35) return PlayerSkillLevel.beginner;
    return PlayerSkillLevel.novice;
  }

  PlayerProfile copyWith({
    String? id,
    String? name,
    int? totalGamesPlayed,
    int? totalWins,
    int? totalLosses,
    double? averageAccuracy,
    double? averageResponseTimeMs,
    int? highestStreak,
    int? currentStreak,
    DateTime? lastPlayedAt,
    List<PlayerSessionHistory>? recentSessions,
  }) {
    return PlayerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalWins: totalWins ?? this.totalWins,
      totalLosses: totalLosses ?? this.totalLosses,
      averageAccuracy: averageAccuracy ?? this.averageAccuracy,
      averageResponseTimeMs:
          averageResponseTimeMs ?? this.averageResponseTimeMs,
      highestStreak: highestStreak ?? this.highestStreak,
      currentStreak: currentStreak ?? this.currentStreak,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      recentSessions: recentSessions ?? this.recentSessions,
    );
  }
}

enum PlayerSkillLevel { novice, beginner, intermediate, advanced, master }

class PlayerSessionHistory {
  final DateTime timestamp;
  final String gameMode;
  final String operation;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final double responseTimeMs;
  final bool isWin;
  final int streak;

  PlayerSessionHistory({
    required this.timestamp,
    required this.gameMode,
    required this.operation,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.responseTimeMs,
    required this.isWin,
    required this.streak,
  });

  double get accuracy =>
      totalQuestions > 0 ? correctAnswers / totalQuestions : 0;
}

final playerProfileProvider =
    StateNotifierProvider<PlayerProfileNotifier, PlayerProfile?>((ref) {
      return PlayerProfileNotifier();
    });

class PlayerProfileNotifier extends StateNotifier<PlayerProfile?> {
  PlayerProfileNotifier() : super(null);

  void initializeProfile(String name) {
    state = PlayerProfile(id: 'player_1', name: name);
  }

  void recordGameResult({
    required String gameMode,
    required String operation,
    required int score,
    required int correctAnswers,
    required int totalQuestions,
    required double responseTimeMs,
    required bool isWin,
    required int streak,
  }) {
    if (state == null) return;

    final history = PlayerSessionHistory(
      timestamp: DateTime.now(),
      gameMode: gameMode,
      operation: operation,
      score: score,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      responseTimeMs: responseTimeMs,
      isWin: isWin,
      streak: streak,
    );

    final recentSessions = [...state!.recentSessions, history];
    if (recentSessions.length > 20) {
      recentSessions.removeAt(0);
    }

    final totalPlayed = state!.totalGamesPlayed + 1;
    final totalWins = state!.totalWins + (isWin ? 1 : 0);
    final totalLosses = state!.totalLosses + (isWin ? 0 : 1);

    final avgAccuracy = state!.recentSessions.isEmpty
        ? (correctAnswers / totalQuestions)
        : (state!.averageAccuracy * 0.8 +
              (correctAnswers / totalQuestions) * 0.2);

    final avgResponse = state!.recentSessions.isEmpty
        ? responseTimeMs
        : (state!.averageResponseTimeMs * 0.8 + responseTimeMs * 0.2);

    state = state!.copyWith(
      totalGamesPlayed: totalPlayed,
      totalWins: totalWins,
      totalLosses: totalLosses,
      averageAccuracy: avgAccuracy,
      averageResponseTimeMs: avgResponse,
      highestStreak: streak > state!.highestStreak
          ? streak
          : state!.highestStreak,
      currentStreak: streak,
      lastPlayedAt: DateTime.now(),
      recentSessions: recentSessions,
    );
  }

  void recordLoss() {
    if (state == null) return;
    state = state!.copyWith(
      totalGamesPlayed: state!.totalGamesPlayed + 1,
      totalLosses: state!.totalLosses + 1,
      currentStreak: 0,
    );
  }
}

class AdaptiveGameConfig {
  final int baseTimeLimit;
  final int timeBonusPerCorrect;
  final int timePenaltyPerWrong;
  final double speedMultiplier;
  final int questionCount;
  final bool adaptiveDifficulty;
  final int difficultyRange;
  final bool showHints;
  final int hintCost;

  const AdaptiveGameConfig({
    this.baseTimeLimit = 60,
    this.timeBonusPerCorrect = 2,
    this.timePenaltyPerWrong = 3,
    this.speedMultiplier = 1.0,
    this.questionCount = 20,
    this.adaptiveDifficulty = true,
    this.difficultyRange = 5,
    this.showHints = true,
    this.hintCost = 50,
  });

  AdaptiveGameConfig copyWith({
    int? baseTimeLimit,
    int? timeBonusPerCorrect,
    int? timePenaltyPerWrong,
    double? speedMultiplier,
    int? questionCount,
    bool? adaptiveDifficulty,
    int? difficultyRange,
    bool? showHints,
    int? hintCost,
  }) {
    return AdaptiveGameConfig(
      baseTimeLimit: baseTimeLimit ?? this.baseTimeLimit,
      timeBonusPerCorrect: timeBonusPerCorrect ?? this.timeBonusPerCorrect,
      timePenaltyPerWrong: timePenaltyPerWrong ?? this.timePenaltyPerWrong,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      questionCount: questionCount ?? this.questionCount,
      adaptiveDifficulty: adaptiveDifficulty ?? this.adaptiveDifficulty,
      difficultyRange: difficultyRange ?? this.difficultyRange,
      showHints: showHints ?? this.showHints,
      hintCost: hintCost ?? this.hintCost,
    );
  }
}

class AdaptiveGameState {
  final int currentTimeBonus;
  final bool isOnStreak;
  final int streakMultiplier;
  final int consecutiveCorrect;
  final int consecutiveWrong;
  final int speedScore;
  final String currentDifficulty;
  final bool shouldIncreaseDifficulty;
  final bool shouldDecreaseDifficulty;
  final List<String> gameEvents;

  const AdaptiveGameState({
    this.currentTimeBonus = 0,
    this.isOnStreak = false,
    this.streakMultiplier = 1,
    this.consecutiveCorrect = 0,
    this.consecutiveWrong = 0,
    this.speedScore = 0,
    this.currentDifficulty = 'medium',
    this.shouldIncreaseDifficulty = false,
    this.shouldDecreaseDifficulty = false,
    this.gameEvents = const [],
  });

  AdaptiveGameState copyWith({
    int? currentTimeBonus,
    bool? isOnStreak,
    int? streakMultiplier,
    int? consecutiveCorrect,
    int? consecutiveWrong,
    int? speedScore,
    String? currentDifficulty,
    bool? shouldIncreaseDifficulty,
    bool? shouldDecreaseDifficulty,
    List<String>? gameEvents,
  }) {
    return AdaptiveGameState(
      currentTimeBonus: currentTimeBonus ?? this.currentTimeBonus,
      isOnStreak: isOnStreak ?? this.isOnStreak,
      streakMultiplier: streakMultiplier ?? this.streakMultiplier,
      consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
      consecutiveWrong: consecutiveWrong ?? this.consecutiveWrong,
      speedScore: speedScore ?? this.speedScore,
      currentDifficulty: currentDifficulty ?? this.currentDifficulty,
      shouldIncreaseDifficulty:
          shouldIncreaseDifficulty ?? this.shouldIncreaseDifficulty,
      shouldDecreaseDifficulty:
          shouldDecreaseDifficulty ?? this.shouldDecreaseDifficulty,
      gameEvents: gameEvents ?? this.gameEvents,
    );
  }
}

final adaptiveGameStateProvider =
    StateNotifierProvider<AdaptiveGameStateNotifier, AdaptiveGameState>((ref) {
      return AdaptiveGameStateNotifier();
    });

class AdaptiveGameStateNotifier extends StateNotifier<AdaptiveGameState> {
  AdaptiveGameStateNotifier() : super(const AdaptiveGameState());

  void recordCorrectAnswer(double responseTimeMs, AdaptiveGameConfig config) {
    final newStreak = state.consecutiveCorrect + 1;
    final isStreak = newStreak >= 3;
    final multiplier = (newStreak ~/ 3).clamp(1, 4);

    int timeBonus = 0;
    double speedScore = 0;

    if (responseTimeMs < 2000) {
      timeBonus = config.timeBonusPerCorrect * 2;
      speedScore = 100;
    } else if (responseTimeMs < 4000) {
      timeBonus = config.timeBonusPerCorrect;
      speedScore = 50;
    } else if (responseTimeMs < 6000) {
      timeBonus = 0;
      speedScore = 25;
    } else {
      timeBonus = -config.timePenaltyPerWrong;
      speedScore = 0;
    }

    final shouldIncrease = newStreak >= 5 && speedScore > 50;
    final shouldDecrease = state.consecutiveWrong >= 3;

    state = state.copyWith(
      currentTimeBonus: state.currentTimeBonus + timeBonus,
      isOnStreak: isStreak,
      streakMultiplier: multiplier,
      consecutiveCorrect: newStreak,
      consecutiveWrong: 0,
      speedScore: (state.speedScore + speedScore) ~/ 2,
      shouldIncreaseDifficulty: shouldIncrease,
      shouldDecreaseDifficulty: shouldDecrease,
    );
  }

  void recordWrongAnswer() {
    final newWrong = state.consecutiveWrong + 1;
    final shouldDecrease = newWrong >= 3;

    state = state.copyWith(
      isOnStreak: false,
      streakMultiplier: 1,
      consecutiveCorrect: 0,
      consecutiveWrong: newWrong,
      shouldDecreaseDifficulty: shouldDecrease,
    );
  }

  void updateDifficulty(String difficulty) {
    state = state.copyWith(currentDifficulty: difficulty);
  }

  void addGameEvent(String event) {
    final events = [...state.gameEvents, event];
    if (events.length > 10) {
      events.removeAt(0);
    }
    state = state.copyWith(gameEvents: events);
  }

  void reset() {
    state = const AdaptiveGameState();
  }
}

class AdaptiveDifficultyCalculator {
  static AdaptiveGameConfig calculateConfig(
    PlayerProfile profile,
    AdaptiveGameConfig currentConfig,
  ) {
    final skillLevel = profile.skillLevel;
    final recentSessions = profile.recentSessions;

    double responseFactor = 1.0;
    if (recentSessions.isNotEmpty) {
      final avgResponse = recentSessions.last.responseTimeMs;
      if (avgResponse < 2000) {
        responseFactor = 0.8;
      } else if (avgResponse < 4000) {
        responseFactor = 0.9;
      } else if (avgResponse > 8000) {
        responseFactor = 1.2;
      }
    }

    int newTimeLimit = (currentConfig.baseTimeLimit * responseFactor).round();
    int newQuestionCount = currentConfig.questionCount;
    double speedMult = currentConfig.speedMultiplier;
    bool adaptive = currentConfig.adaptiveDifficulty;

    switch (skillLevel) {
      case PlayerSkillLevel.master:
        newTimeLimit = (newTimeLimit * 0.7).round();
        newQuestionCount = (newQuestionCount * 1.3).round();
        speedMult = 1.5;
        break;
      case PlayerSkillLevel.advanced:
        newTimeLimit = (newTimeLimit * 0.85).round();
        newQuestionCount = (newQuestionCount * 1.15).round();
        speedMult = 1.25;
        break;
      case PlayerSkillLevel.intermediate:
        speedMult = 1.0;
        break;
      case PlayerSkillLevel.beginner:
        newTimeLimit = (newTimeLimit * 1.15).round();
        newQuestionCount = (newQuestionCount * 0.9).round();
        speedMult = 0.85;
        break;
      case PlayerSkillLevel.novice:
        newTimeLimit = (newTimeLimit * 1.3).round();
        newQuestionCount = (newQuestionCount * 0.8).round();
        speedMult = 0.7;
        adaptive = false;
        break;
    }

    return currentConfig.copyWith(
      baseTimeLimit: newTimeLimit.clamp(15, 180),
      questionCount: newQuestionCount.clamp(10, 50),
      speedMultiplier: speedMult.clamp(0.5, 2.0),
      adaptiveDifficulty: adaptive,
    );
  }
}

class GameRewardCalculator {
  static int calculateScore({
    required bool isCorrect,
    required double responseTimeMs,
    required int streakMultiplier,
    required String difficulty,
    required bool isBossLevel,
  }) {
    if (!isCorrect) return 0;

    int baseScore = 10;

    if (isBossLevel) {
      baseScore = 20;
    }

    double speedBonus = 1.0;
    if (responseTimeMs < 2000) {
      speedBonus = 2.0;
    } else if (responseTimeMs < 4000) {
      speedBonus = 1.5;
    } else if (responseTimeMs > 8000) {
      speedBonus = 0.8;
    }

    double difficultyBonus = 1.0;
    switch (difficulty) {
      case 'easy':
        difficultyBonus = 0.8;
        break;
      case 'medium':
        difficultyBonus = 1.0;
        break;
      case 'hard':
        difficultyBonus = 1.3;
        break;
      case 'expert':
        difficultyBonus = 1.6;
        break;
      case 'master':
        difficultyBonus = 2.0;
        break;
    }

    return (baseScore * speedBonus * difficultyBonus * streakMultiplier)
        .round();
  }

  static int checkLevelUp({
    required int totalScore,
    required int currentLevel,
  }) {
    final thresholds = [
      0,
      100,
      300,
      600,
      1000,
      1500,
      2100,
      2800,
      3600,
      4500,
      5500,
      6600,
      7800,
      9100,
      10500,
      12100,
      13800,
      15600,
      17500,
      19500,
    ];

    for (int i = thresholds.length - 1; i >= 0; i--) {
      if (totalScore >= thresholds[i]) {
        return i + 1;
      }
    }
    return currentLevel;
  }
}

final adaptiveConfigProvider =
    StateNotifierProvider<AdaptiveConfigNotifier, AdaptiveGameConfig>((ref) {
      return AdaptiveConfigNotifier();
    });

class AdaptiveConfigNotifier extends StateNotifier<AdaptiveGameConfig> {
  AdaptiveConfigNotifier() : super(const AdaptiveGameConfig());

  void updateFromProfile(PlayerProfile profile) {
    state = AdaptiveDifficultyCalculator.calculateConfig(profile, state);
  }

  void applySpeedBonus(int bonus) {
    state = state.copyWith(
      baseTimeLimit: (state.baseTimeLimit + bonus).clamp(15, 180),
    );
  }

  void enableAdaptiveMode(bool enabled) {
    state = state.copyWith(adaptiveDifficulty: enabled);
  }

  void reset() {
    state = const AdaptiveGameConfig();
  }
}

class PerformanceAnalytics {
  static Map<String, dynamic> analyzePerformance(
    List<PlayerSessionHistory> sessions,
  ) {
    if (sessions.isEmpty) {
      return {
        'averageAccuracy': 0.0,
        'averageResponseTime': 0.0,
        'bestStreak': 0,
        'totalGames': 0,
        'winRate': 0.0,
        'improvement': 0.0,
        'trend': 'stable',
      };
    }

    final accuracy =
        sessions.map((s) => s.accuracy).reduce((a, b) => a + b) /
        sessions.length;
    final responseTime =
        sessions.map((s) => s.responseTimeMs).reduce((a, b) => a + b) /
        sessions.length;
    final wins = sessions.where((s) => s.isWin).length;
    final bestStreak = sessions
        .map((s) => s.streak)
        .reduce((a, b) => a > b ? a : b);

    double improvement = 0;
    if (sessions.length >= 10) {
      final firstHalf =
          sessions.take(5).map((s) => s.accuracy).reduce((a, b) => a + b) / 5;
      final secondHalf =
          sessions.skip(5).map((s) => s.accuracy).reduce((a, b) => a + b) / 5;
      improvement = (secondHalf - firstHalf) * 100;
    }

    String trend = 'stable';
    if (improvement > 5) {
      trend = 'improving';
    }
    if (improvement < -5) {
      trend = 'declining';
    }

    return {
      'averageAccuracy': accuracy,
      'averageResponseTime': responseTime,
      'bestStreak': bestStreak,
      'totalGames': sessions.length,
      'winRate': wins / sessions.length,
      'improvement': improvement,
      'trend': trend,
    };
  }
}
