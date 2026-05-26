import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DifficultyLevel { beginner, easy, medium, hard, expert, master }

class LearningPath {
  final String operation;
  final List<int> recommendedLevels;
  final List<String> prerequisiteSkills;
  final double masteryThreshold;
  final String nextFocusArea;

  LearningPath({
    required this.operation,
    required this.recommendedLevels,
    required this.prerequisiteSkills,
    this.masteryThreshold = 0.8,
    this.nextFocusArea = '',
  });
}

class KnowledgeGap {
  final String operation;
  final double currentAccuracy;
  final double targetAccuracy;
  final int recommendedPracticeQuestions;
  final String improvementStrategy;

  KnowledgeGap({
    required this.operation,
    required this.currentAccuracy,
    required this.targetAccuracy,
    required this.recommendedPracticeQuestions,
    required this.improvementStrategy,
  });
}

class PlayerPerformanceMetrics {
  final int totalQuestionsAnswered;
  final int correctAnswers;
  final double recentAccuracy;
  final int currentStreak;
  final int bestStreak;
  final double averageResponseTimeMs;
  final List<double> recentResponseTimes;
  final Map<String, double> accuracyByOperation;
  final Map<String, int> operationFrequency;
  final List<String> weakOperations;
  final Map<String, LearningPath> learningPaths;

  PlayerPerformanceMetrics({
    this.totalQuestionsAnswered = 0,
    this.correctAnswers = 0,
    this.recentAccuracy = 0.5,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.averageResponseTimeMs = 5000,
    this.recentResponseTimes = const [],
    this.accuracyByOperation = const {},
    this.operationFrequency = const {},
    this.weakOperations = const [],
    this.learningPaths = const {},
  });

  double get overallAccuracy => totalQuestionsAnswered > 0
      ? correctAnswers / totalQuestionsAnswered
      : 0.5;

  List<KnowledgeGap> get knowledgeGaps {
    final gaps = <KnowledgeGap>[];
    accuracyByOperation.forEach((operation, accuracy) {
      if (accuracy < 0.7) { // Below 70% accuracy
        final targetAccuracy = 0.85;
        final practiceQuestions = ((1 - accuracy) * 50).round(); // More practice for lower accuracy
        final strategy = _getImprovementStrategy(operation, accuracy);

        gaps.add(KnowledgeGap(
          operation: operation,
          currentAccuracy: accuracy,
          targetAccuracy: targetAccuracy,
          recommendedPracticeQuestions: practiceQuestions.clamp(10, 100),
          improvementStrategy: strategy,
        ));
      }
    });
    return gaps;
  }

  Map<String, LearningPath> get recommendedLearningPaths {
    final paths = <String, LearningPath>{};
    const operations = ['addition', 'subtraction', 'multiplication', 'division'];

    for (final op in operations) {
      final accuracy = accuracyByOperation[op] ?? 0.5;
      final levels = _calculateRecommendedLevels(op, accuracy);
      final prerequisites = _getPrerequisites(op);

      paths[op] = LearningPath(
        operation: op,
        recommendedLevels: levels,
        prerequisiteSkills: prerequisites,
        masteryThreshold: 0.8,
        nextFocusArea: accuracy < 0.6 ? 'Basic concepts' : 'Speed and accuracy',
      );
    }
    return paths;
  }

  List<int> _calculateRecommendedLevels(String operation, double accuracy) {
    if (accuracy > 0.9) return [15, 20, 25, 30]; // Advanced levels
    if (accuracy > 0.8) return [8, 12, 16, 20]; // Intermediate
    if (accuracy > 0.7) return [3, 6, 9, 12]; // Beginner advanced
    return [1, 2, 3, 4]; // Basic levels
  }

  List<String> _getPrerequisites(String operation) {
    switch (operation) {
      case 'addition': return ['Number recognition', 'Counting'];
      case 'subtraction': return ['Addition', 'Number comparison'];
      case 'multiplication': return ['Addition', 'Repeated addition'];
      case 'division': return ['Multiplication', 'Sharing concepts'];
      default: return [];
    }
  }

  String _getImprovementStrategy(String operation, double accuracy) {
    if (accuracy < 0.5) return 'Focus on basic concepts with visual aids';
    if (accuracy < 0.6) return 'Practice with smaller numbers and visual representations';
    if (accuracy < 0.7) return 'Increase speed while maintaining accuracy';
    return 'Challenge with larger numbers and time pressure';
  }

  PlayerPerformanceMetrics copyWith({
    int? totalQuestionsAnswered,
    int? correctAnswers,
    double? recentAccuracy,
    int? currentStreak,
    int? bestStreak,
    double? averageResponseTimeMs,
    List<double>? recentResponseTimes,
    Map<String, double>? accuracyByOperation,
    Map<String, int>? operationFrequency,
    List<String>? weakOperations,
    Map<String, LearningPath>? learningPaths,
  }) {
    return PlayerPerformanceMetrics(
      totalQuestionsAnswered:
          totalQuestionsAnswered ?? this.totalQuestionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      recentAccuracy: recentAccuracy ?? this.recentAccuracy,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      averageResponseTimeMs:
          averageResponseTimeMs ?? this.averageResponseTimeMs,
      recentResponseTimes: recentResponseTimes ?? this.recentResponseTimes,
      accuracyByOperation: accuracyByOperation ?? this.accuracyByOperation,
      operationFrequency: operationFrequency ?? this.operationFrequency,
      weakOperations: weakOperations ?? this.weakOperations,
      learningPaths: learningPaths ?? this.learningPaths,
    );
  }
}

class DynamicDifficultyConfig {
  final int currentLevel;
  final DifficultyLevel difficulty;
  final double adaptationRate;
  final int questionsPerAssessment;
  final int cooldownQuestions;
  final double performanceMultiplier;
  final int streakBonus;
  final bool adaptiveHints;
  final Map<String, double> operationWeights;

  DynamicDifficultyConfig({
    this.currentLevel = 1,
    this.difficulty = DifficultyLevel.beginner,
    this.adaptationRate = 0.25, // More responsive adaptation
    this.questionsPerAssessment = 12, // Optimized for better feedback
    this.cooldownQuestions = 6, // Reduced cooldown for faster adaptation
    this.performanceMultiplier = 1.0,
    this.streakBonus = 0,
    this.adaptiveHints = true,
    this.operationWeights = const {},
  });

  int get adjustedLevel => currentLevel.clamp(1, 50);

  DynamicDifficultyConfig copyWith({
    int? currentLevel,
    DifficultyLevel? difficulty,
    double? adaptationRate,
    int? questionsPerAssessment,
    int? cooldownQuestions,
  }) {
    return DynamicDifficultyConfig(
      currentLevel: currentLevel ?? this.currentLevel,
      difficulty: difficulty ?? this.difficulty,
      adaptationRate: adaptationRate ?? this.adaptationRate,
      questionsPerAssessment:
          questionsPerAssessment ?? this.questionsPerAssessment,
      cooldownQuestions: cooldownQuestions ?? this.cooldownQuestions,
    );
  }
}

final playerPerformanceProvider =
    StateNotifierProvider<PlayerPerformanceNotifier, PlayerPerformanceMetrics>(
      (ref) => PlayerPerformanceNotifier(),
    );

class PlayerPerformanceNotifier
    extends StateNotifier<PlayerPerformanceMetrics> {
  PlayerPerformanceNotifier() : super(PlayerPerformanceMetrics());

  void recordAnswer({
    required String operation,
    required bool isCorrect,
    required int responseTimeMs,
    required int hintsUsed,
  }) {
    final currentMetrics = state;

    // Update operation-specific accuracy
    final currentAccuracy = currentMetrics.accuracyByOperation[operation] ?? 0.5;
    final currentFrequency = currentMetrics.operationFrequency[operation] ?? 0;
    final newAccuracy = ((currentAccuracy * currentFrequency) + (isCorrect ? 1.0 : 0.0)) / (currentFrequency + 1);

    // Update recent response times (keep last 10)
    final recentTimes = List<double>.from(currentMetrics.recentResponseTimes);
    recentTimes.add(responseTimeMs.toDouble());
    if (recentTimes.length > 10) recentTimes.removeAt(0);

    // Calculate new average response time
    final newAverageTime = recentTimes.reduce((a, b) => a + b) / recentTimes.length;

    // Update recent accuracy (last 20 answers)
    final totalRecent = currentMetrics.correctAnswers + (isCorrect ? 1 : 0);
    final newRecentAccuracy = totalRecent / (currentMetrics.totalQuestionsAnswered + 1);

    state = currentMetrics.copyWith(
      totalQuestionsAnswered: currentMetrics.totalQuestionsAnswered + 1,
      correctAnswers: currentMetrics.correctAnswers + (isCorrect ? 1 : 0),
      recentAccuracy: newRecentAccuracy.clamp(0.0, 1.0),
      averageResponseTimeMs: newAverageTime,
      recentResponseTimes: recentTimes,
      accuracyByOperation: {
        ...currentMetrics.accuracyByOperation,
        operation: newAccuracy,
      },
      operationFrequency: {
        ...currentMetrics.operationFrequency,
        operation: currentFrequency + 1,
      },
    );

    // Update weak operations
    _updateWeakOperations();
  }

  void _updateWeakOperations() {
    final weakOps = <String>[];
    state.accuracyByOperation.forEach((operation, accuracy) {
      if (accuracy < 0.7) {
        weakOps.add(operation);
      }
    });
    state = state.copyWith(weakOperations: weakOps);
  }

  DifficultyLevel getRecommendedDifficulty(String operation) {
    final accuracy = state.accuracyByOperation[operation] ?? 0.5;
    final responseTime = state.averageResponseTimeMs;

    if (accuracy > 0.9 && responseTime < 2000) return DifficultyLevel.expert;
    if (accuracy > 0.8 && responseTime < 3000) return DifficultyLevel.hard;
    if (accuracy > 0.7 && responseTime < 4000) return DifficultyLevel.medium;
    if (accuracy > 0.6) return DifficultyLevel.easy;
    return DifficultyLevel.beginner;
  }

  List<String> getRecommendedFocusAreas() {
    final focusAreas = <String>[];

    if (state.recentAccuracy < 0.6) {
      focusAreas.add('Improve accuracy with slower, careful solving');
    }

    if (state.averageResponseTimeMs > 5000) {
      focusAreas.add('Work on speed with timed practice');
    }

    if (state.weakOperations.isNotEmpty) {
      focusAreas.add('Focus on weak operations: ${state.weakOperations.join(", ")}');
    }

    if (state.recentAccuracy > 0.8 && state.averageResponseTimeMs < 3000) {
      focusAreas.add('Ready for advanced difficulty levels');
    }

    return focusAreas;
  }



  void reset() {
    state = PlayerPerformanceMetrics();
  }
}

final dynamicDifficultyProvider =
    StateNotifierProvider<DynamicDifficultyNotifier, DynamicDifficultyConfig>(
      (ref) => DynamicDifficultyNotifier(ref),
    );

class DynamicDifficultyNotifier extends StateNotifier<DynamicDifficultyConfig> {
  final Ref ref;
  int _questionsSinceLastAdjustment = 0;
  int _correctInCurrentBlock = 0;

  DynamicDifficultyNotifier(this.ref) : super(DynamicDifficultyConfig());

  DifficultyLevel _calculateDifficultyFromMetrics(
    PlayerPerformanceMetrics metrics,
  ) {
    final accuracy = metrics.recentAccuracy;
    final avgTime = metrics.averageResponseTimeMs;
    final streak = metrics.currentStreak;

    // More nuanced difficulty calculation based on 35+ correct threshold
    if (accuracy >= 0.95 && avgTime < 2500 && streak >= 8) {
      return DifficultyLevel.master; // Can handle 42.75+ correct out of 45
    }
    if (accuracy >= 0.9 && avgTime < 3000 && streak >= 6) {
      return DifficultyLevel.expert; // Can handle 40.5+ correct out of 45
    }
    if (accuracy >= 0.8 && avgTime < 4000 && streak >= 5) {
      return DifficultyLevel.hard; // Can handle 36+ correct out of 45
    }
    if (accuracy >= 0.75 && avgTime < 5000 && streak >= 4) {
      return DifficultyLevel.medium; // Can handle 33.75+ correct out of 45
    }
    if (accuracy >= 0.7 && avgTime < 6000 && streak >= 3) {
      return DifficultyLevel.easy; // Can handle 31.5+ correct out of 45
    }
    return DifficultyLevel.beginner; // For those struggling to reach 35 correct
  }

  void recordAssessment({required bool isCorrect}) {
    _questionsSinceLastAdjustment++;
    if (isCorrect) {
      _correctInCurrentBlock++;
    }

    if (_questionsSinceLastAdjustment >= state.questionsPerAssessment) {
      _adjustDifficulty();
    }
  }

  void _adjustDifficulty() {
    final metrics = ref.read(playerPerformanceProvider);

    if (_questionsSinceLastAdjustment < state.cooldownQuestions) {
      return;
    }

    final blockAccuracy =
        _correctInCurrentBlock / _questionsSinceLastAdjustment;
    final currentLevel = state.currentLevel;

    int newLevel = currentLevel;

    // Enhanced adaptation for 45-question levels (35+ needed to pass)
    if (blockAccuracy >= 0.85 && currentLevel < 50) { // 38.25+ correct out of 45
      newLevel = (currentLevel + (3 * state.adaptationRate).round()).clamp(
        1,
        50,
      );
    } else if (blockAccuracy >= 0.78 && currentLevel < 50) { // 35.1+ correct out of 45 (just passes)
      newLevel = (currentLevel + (1.5 * state.adaptationRate).round()).clamp(1, 50);
    } else if (blockAccuracy >= 0.67 && currentLevel < 50) { // 30.15+ correct out of 45
      newLevel = (currentLevel + state.adaptationRate.round()).clamp(1, 50);
    } else if (blockAccuracy < 0.5 && currentLevel > 1) { // Below 22.5 correct out of 45
      newLevel = (currentLevel - (3 * state.adaptationRate).round()).clamp(
        1,
        50,
      );
    } else if (blockAccuracy < 0.6 && currentLevel > 1) { // Below 27 correct out of 45
      newLevel = (currentLevel - (1.5 * state.adaptationRate).round()).clamp(1, 50);
    }

    final newDifficulty = _calculateDifficultyFromMetrics(metrics);

    state = state.copyWith(currentLevel: newLevel, difficulty: newDifficulty);

    _questionsSinceLastAdjustment = 0;
    _correctInCurrentBlock = 0;
  }

  void setLevel(int level) {
    final difficulty = _determineDifficultyFromLevel(level);
    state = state.copyWith(
      currentLevel: level.clamp(1, 50),
      difficulty: difficulty,
    );
  }

  DifficultyLevel _determineDifficultyFromLevel(int level) {
    if (level >= 45) { // Very high levels for masters
      return DifficultyLevel.master;
    }
    if (level >= 35) { // Levels requiring 35+ correct consistently
      return DifficultyLevel.expert;
    }
    if (level >= 25) { // Challenging levels
      return DifficultyLevel.hard;
    }
    if (level >= 15) { // Moderate challenge
      return DifficultyLevel.medium;
    }
    if (level >= 8) { // Getting easier
      return DifficultyLevel.easy;
    }
    return DifficultyLevel.beginner; // Early levels for learning
  }

  void forceReset() {
    state = DynamicDifficultyConfig();
    _questionsSinceLastAdjustment = 0;
    _correctInCurrentBlock = 0;
  }
}

extension DifficultyExtension on DifficultyLevel {
  String get displayName {
    switch (this) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Medium';
      case DifficultyLevel.hard:
        return 'Hard';
      case DifficultyLevel.expert:
        return 'Expert';
      case DifficultyLevel.master:
        return 'Master';
    }
  }

  String get description {
    switch (this) {
      case DifficultyLevel.beginner:
        return 'Perfect for learning basics';
      case DifficultyLevel.easy:
        return 'Gentle challenges';
      case DifficultyLevel.medium:
        return 'Balanced difficulty';
      case DifficultyLevel.hard:
        return 'Pushing your skills';
      case DifficultyLevel.expert:
        return 'For experienced players';
      case DifficultyLevel.master:
        return 'Ultimate challenge';
    }
  }

  double get scoreMultiplier {
    switch (this) {
      case DifficultyLevel.beginner:
        return 1.0;
      case DifficultyLevel.easy:
        return 1.25;
      case DifficultyLevel.medium:
        return 1.5;
      case DifficultyLevel.hard:
        return 1.75;
      case DifficultyLevel.expert:
        return 2.0;
      case DifficultyLevel.master:
        return 2.5;
    }
  }
}
