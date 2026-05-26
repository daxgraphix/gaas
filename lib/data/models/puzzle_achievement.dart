import 'dart:convert';

class PuzzleAchievement {
  final int id;
  final String achievementId;
  final String title;
  final String description;
  final String iconName;
  final int rewardPoints;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progress;
  final int targetProgress;

  PuzzleAchievement({
    this.id = 0,
    required this.achievementId,
    required this.title,
    required this.description,
    required this.iconName,
    required this.rewardPoints,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0,
    required this.targetProgress,
  });

  double get progressPercentage {
    if (targetProgress == 0) return 0.0;
    return (progress / targetProgress).clamp(0.0, 1.0);
  }

  PuzzleAchievement copyWith({
    int? id,
    String? achievementId,
    String? title,
    String? description,
    String? iconName,
    int? rewardPoints,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? progress,
    int? targetProgress,
  }) {
    return PuzzleAchievement(
      id: id ?? this.id,
      achievementId: achievementId ?? this.achievementId,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      targetProgress: targetProgress ?? this.targetProgress,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'achievementId': achievementId,
    'title': title,
    'description': description,
    'iconName': iconName,
    'rewardPoints': rewardPoints,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
    'progress': progress,
    'targetProgress': targetProgress,
  };

  factory PuzzleAchievement.fromJson(Map<String, dynamic> json) {
    return PuzzleAchievement(
      id: json['id'] ?? 0,
      achievementId: json['achievementId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      iconName: json['iconName'] ?? 'star',
      rewardPoints: json['rewardPoints'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
      progress: json['progress'] ?? 0,
      targetProgress: json['targetProgress'] ?? 1,
    );
  }

  static String encode(List<PuzzleAchievement> achievements) {
    return jsonEncode(achievements.map((a) => a.toJson()).toList());
  }

  static List<PuzzleAchievement> decode(String jsonString) {
    final list = jsonDecode(jsonString) as List;
    return list.map((item) => PuzzleAchievement.fromJson(item)).toList();
  }
}

class PuzzleStats {
  final int totalPuzzlesSolved;
  final int totalCrosswordsSolved;
  final int totalMathRiddlesSolved;
  final int totalNumberSequencesSolved;
  final int totalLogicMathSolved;
  final int averageCompletionTimeSeconds;
  final int bestTimeSeconds;
  final int totalHintsUsed;
  final int totalStarsEarned;
  final String? favoritePuzzleType;
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastPuzzleDate;

  const PuzzleStats({
    this.totalPuzzlesSolved = 0,
    this.totalCrosswordsSolved = 0,
    this.totalMathRiddlesSolved = 0,
    this.totalNumberSequencesSolved = 0,
    this.totalLogicMathSolved = 0,
    this.averageCompletionTimeSeconds = 0,
    this.bestTimeSeconds = 0,
    this.totalHintsUsed = 0,
    this.totalStarsEarned = 0,
    this.favoritePuzzleType,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastPuzzleDate,
  });

  PuzzleStats copyWith({
    int? totalPuzzlesSolved,
    int? totalCrosswordsSolved,
    int? totalMathRiddlesSolved,
    int? totalNumberSequencesSolved,
    int? totalLogicMathSolved,
    int? averageCompletionTimeSeconds,
    int? bestTimeSeconds,
    int? totalHintsUsed,
    int? totalStarsEarned,
    String? favoritePuzzleType,
    int? currentStreak,
    int? bestStreak,
    DateTime? lastPuzzleDate,
  }) {
    return PuzzleStats(
      totalPuzzlesSolved: totalPuzzlesSolved ?? this.totalPuzzlesSolved,
      totalCrosswordsSolved:
          totalCrosswordsSolved ?? this.totalCrosswordsSolved,
      totalMathRiddlesSolved:
          totalMathRiddlesSolved ?? this.totalMathRiddlesSolved,
      totalNumberSequencesSolved:
          totalNumberSequencesSolved ?? this.totalNumberSequencesSolved,
      totalLogicMathSolved: totalLogicMathSolved ?? this.totalLogicMathSolved,
      averageCompletionTimeSeconds:
          averageCompletionTimeSeconds ?? this.averageCompletionTimeSeconds,
      bestTimeSeconds: bestTimeSeconds ?? this.bestTimeSeconds,
      totalHintsUsed: totalHintsUsed ?? this.totalHintsUsed,
      totalStarsEarned: totalStarsEarned ?? this.totalStarsEarned,
      favoritePuzzleType: favoritePuzzleType ?? this.favoritePuzzleType,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastPuzzleDate: lastPuzzleDate ?? this.lastPuzzleDate,
    );
  }
}
