import '../models/statistics.dart';
import 'database_service.dart';

class StatisticsRepository {
  DatabaseService? _db;

  Future<DatabaseService> get db async {
    _db ??= await DatabaseService.instance;
    return _db!;
  }

  StatisticsRepository();

  Future<Statistics?> getStatistics(String? operationId) async {
    final database = await db;
    return await database.getStatistics(operationId);
  }

  Future<List<Statistics>> getAllStatistics() async {
    final database = await db;
    return await database.getAllStatistics();
  }

  Future<void> saveStatistics(Statistics stats) async {
    final database = await db;
    await database.saveStatistics(stats);
  }

  Future<void> updateStatistics({
    required String? operationId,
    required int score,
    required bool isCorrect,
    required int timeSpent,
    String? mode,
    String? levelKey,
  }) async {
    var stats = await getStatistics(null) ?? Statistics();

    stats.totalQuestionsAnswered += 1;
    stats.timeSpentSeconds += timeSpent;
    stats.lastUpdated = DateTime.now();

    if (isCorrect) {
      stats.correctAnswers += 1;
      stats.currentStreak += 1;
      if (stats.currentStreak > stats.bestStreak) {
        stats.bestStreak = stats.currentStreak;
      }
      if (score > stats.highScore) {
        stats.highScore = score;
      }
    } else {
      stats.currentStreak = 0;
    }
    
    if (stats.totalQuestionsAnswered > 0) {
      stats.dailyAccuracy = (stats.correctAnswers / stats.totalQuestionsAnswered) * 100;
    }

    // Track time per question
    stats.timePerQuestion.add({
      'operationId': operationId,
      'timeSpent': timeSpent,
      'isCorrect': isCorrect,
      'mode': mode,
      'levelKey': levelKey,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Update accuracy by operation
    if (operationId != null) {
      final totalOp = stats.timePerQuestion.where((q) => q['operationId'] == operationId).length;
      final correctOp = stats.timePerQuestion.where((q) => q['operationId'] == operationId && q['isCorrect'] == true).length;
      stats.accuracyByOperation[operationId] = totalOp > 0 ? (correctOp / totalOp * 100) : 0.0;
    }

    // Update mode usage
    if (mode != null) {
      stats.modeUsage[mode] = (stats.modeUsage[mode] ?? 0) + 1;
      
      // Update per-mode high scores
      if (score > (stats.highScoresByMode[mode] ?? 0)) {
        stats.highScoresByMode[mode] = score;
      }
    }

    // Update level completion if it's a "win"
    if (levelKey != null && isCorrect) {
      // In a real game, level completion might be tracked separately from per-question stats
      // but here we can at least increment attempts/wins if levelKey is provided
      stats.levelCompletion[levelKey] = (stats.levelCompletion[levelKey] ?? 0) + 1;
    }

    // Keep only last 100 entries for history
    if (stats.timePerQuestion.length > 100) {
      stats.timePerQuestion.removeAt(0);
    }

    final database = await db;
    await database.saveStatistics(stats);
  }

  Future<double> getOverallAccuracy() async {
    final stats = await getStatistics(null);
    if (stats != null && stats.totalQuestionsAnswered > 0) {
      return (stats.correctAnswers / stats.totalQuestionsAnswered) * 100;
    }
    return 0.0;
  }

  Future<int> getTotalQuestionsAnswered() async {
    final stats = await getStatistics(null);
    return stats?.totalQuestionsAnswered ?? 0;
  }

  Future<int> getTotalTimePlayed() async {
    final stats = await getStatistics(null);
    return stats?.timeSpentSeconds ?? 0;
  }

  Future<Statistics> getOverallStats() async {
    final stats = await getStatistics(null);
    return stats ?? Statistics();
  }
}