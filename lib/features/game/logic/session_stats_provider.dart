import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionStats {
  final int questionsAnswered;
  final int correctAnswers;
  final int bestStreak;
  final int currentStreak;
  final int timeSpent;

  SessionStats({
    this.questionsAnswered = 0,
    this.correctAnswers = 0,
    this.bestStreak = 0,
    this.currentStreak = 0,
    this.timeSpent = 0,
  });

  double get accuracy => questionsAnswered > 0 
    ? (correctAnswers / questionsAnswered) * 100 
    : 0.0;

  SessionStats copyWith({
    int? questionsAnswered,
    int? correctAnswers,
    int? bestStreak,
    int? currentStreak,
    int? timeSpent,
  }) {
    return SessionStats(
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      bestStreak: bestStreak ?? this.bestStreak,
      currentStreak: currentStreak ?? this.currentStreak,
      timeSpent: timeSpent ?? this.timeSpent,
    );
  }
}

class SessionStatsNotifier extends StateNotifier<SessionStats> {
  SessionStatsNotifier() : super(SessionStats());

  void recordAnswer(String operation, bool isCorrect, int timeSeconds, bool usedHint) {
    final newTotal = state.questionsAnswered + 1;
    final newCorrect = isCorrect ? state.correctAnswers + 1 : state.correctAnswers;
    final newStreak = isCorrect ? state.currentStreak + 1 : 0;
    final newBest = newStreak > state.bestStreak ? newStreak : state.bestStreak;
    final newTime = state.timeSpent + timeSeconds;

    state = state.copyWith(
      questionsAnswered: newTotal,
      correctAnswers: newCorrect,
      currentStreak: newStreak,
      bestStreak: newBest,
      timeSpent: newTime,
    );
  }

  void checkInactivity() {}
  void reset() => state = SessionStats();
}

final sessionStatsProvider = StateNotifierProvider<SessionStatsNotifier, SessionStats>((ref) {
  return SessionStatsNotifier();
});

final bestStreakProvider = Provider<int>((ref) {
  return ref.watch(sessionStatsProvider).bestStreak;
});
