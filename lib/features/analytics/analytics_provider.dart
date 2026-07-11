import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/statistics.dart';

class AnalyticsState {
  final Statistics overallStats;
  final List<Map<String, dynamic>> recentSessions;
  final Map<String, List<double>> heatHistory; // operation -> history

  AnalyticsState({
    required this.overallStats,
    this.recentSessions = const [],
    this.heatHistory = const {},
  });

  double get overallAccuracy => overallStats.totalQuestionsAnswered > 0
      ? overallStats.correctAnswers / overallStats.totalQuestionsAnswered
      : 0.0;

  int get totalTimeSpent => overallStats.timeSpentSeconds;

  Map<String, int> get operationUsage {
    final usage = <String, int>{};
    for (var session in recentSessions) {
      final op = session['operation'] as String?;
      if (op != null) {
        usage[op] = (usage[op] ?? 0) + 1;
      }
    }
    return usage;
  }

  AnalyticsState copyWith({
    Statistics? overallStats,
    List<Map<String, dynamic>>? recentSessions,
    Map<String, List<double>>? heatHistory,
  }) {
    return AnalyticsState(
      overallStats: overallStats ?? this.overallStats,
      recentSessions: recentSessions ?? this.recentSessions,
      heatHistory: heatHistory ?? this.heatHistory,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier() : super(AnalyticsState(overallStats: Statistics()));

  void recordSession(
    String operation,
    int durationSeconds,
    int totalQuestions,
    int correctAnswers,
    int hintsUsed, {
    String? mode,
    double? avgHeatIndex,
  }) {
    final newStats = Statistics(
      totalQuestionsAnswered: state.overallStats.totalQuestionsAnswered + totalQuestions,
      correctAnswers: state.overallStats.correctAnswers + correctAnswers,
      timeSpentSeconds: state.overallStats.timeSpentSeconds + durationSeconds,
      totalHintsUsed: state.overallStats.totalHintsUsed + hintsUsed,
      // ... other fields could be updated here
    );

    final sessionData = {
      'operation': operation,
      'duration': durationSeconds,
      'total': totalQuestions,
      'correct': correctAnswers,
      'hints': hintsUsed,
      'mode': mode,
      'heat': avgHeatIndex,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final newRecent = [sessionData, ...state.recentSessions].take(50).toList();
    
    Map<String, List<double>> newHeatHistory = Map.from(state.heatHistory);
    if (avgHeatIndex != null) {
      final history = newHeatHistory[operation] ?? [];
      newHeatHistory[operation] = [...history, avgHeatIndex].take(20).toList();
    }

    state = state.copyWith(
      overallStats: newStats,
      recentSessions: newRecent,
      heatHistory: newHeatHistory,
    );
  }
}

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier();
});
