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
  }) async {
    var stats = await getStatistics(operationId) ??
        Statistics(
          operationId: operationId,
        );

    stats.totalQuestionsAnswered += 1;
    stats.timeSpentSeconds += timeSpent;
    stats.lastUpdated = DateTime.now();

    if (isCorrect) {
      stats.correctAnswers += 1;
      if (score > stats.highScore) {
        stats.highScore = score;
      }
      if (stats.totalQuestionsAnswered > 0) {
        stats.dailyAccuracy = (stats.correctAnswers / stats.totalQuestionsAnswered) * 100;
      }
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