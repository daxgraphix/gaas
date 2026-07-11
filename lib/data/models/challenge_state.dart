class ChallengeModeState {
  final String type;
  final int score;
  final int remainingSeconds;
  final int timeLimit;
  final Map<String, int> leaderboard;
  final bool isPlaying;

  const ChallengeModeState({
    this.type = 'daily',
    this.score = 0,
    this.remainingSeconds = 300,
    this.timeLimit = 300,
    this.leaderboard = const {},
    this.isPlaying = false,
  });

  ChallengeModeState copyWith({
    String? type,
    int? score,
    int? remainingSeconds,
    int? timeLimit,
    Map<String, int>? leaderboard,
    bool? isPlaying,
  }) {
    return ChallengeModeState(
      type: type ?? this.type,
      score: score ?? this.score,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      timeLimit: timeLimit ?? this.timeLimit,
      leaderboard: leaderboard ?? this.leaderboard,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}
