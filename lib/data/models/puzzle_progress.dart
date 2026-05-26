import 'dart:convert';

class PuzzleProgress {
  final int id;
  final String puzzleId;
  final String puzzleType;
  final int stars;
  final bool isCompleted;
  final int bestTimeSeconds;
  final int hintsUsed;
  final DateTime? completedAt;
  final DateTime lastAttemptAt;

  PuzzleProgress({
    this.id = 0,
    required this.puzzleId,
    required this.puzzleType,
    this.stars = 0,
    this.isCompleted = false,
    this.bestTimeSeconds = 0,
    this.hintsUsed = 0,
    this.completedAt,
    DateTime? lastAttemptAt,
  }) : lastAttemptAt = lastAttemptAt ?? DateTime.now();

  PuzzleProgress copyWith({
    int? id,
    String? puzzleId,
    String? puzzleType,
    int? stars,
    bool? isCompleted,
    int? bestTimeSeconds,
    int? hintsUsed,
    DateTime? completedAt,
    DateTime? lastAttemptAt,
  }) {
    return PuzzleProgress(
      id: id ?? this.id,
      puzzleId: puzzleId ?? this.puzzleId,
      puzzleType: puzzleType ?? this.puzzleType,
      stars: stars ?? this.stars,
      isCompleted: isCompleted ?? this.isCompleted,
      bestTimeSeconds: bestTimeSeconds ?? this.bestTimeSeconds,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      completedAt: completedAt ?? this.completedAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'puzzleId': puzzleId,
    'puzzleType': puzzleType,
    'stars': stars,
    'isCompleted': isCompleted,
    'bestTimeSeconds': bestTimeSeconds,
    'hintsUsed': hintsUsed,
    'completedAt': completedAt?.toIso8601String(),
    'lastAttemptAt': lastAttemptAt.toIso8601String(),
  };

  factory PuzzleProgress.fromJson(Map<String, dynamic> json) {
    return PuzzleProgress(
      id: json['id'] ?? 0,
      puzzleId: json['puzzleId'] ?? '',
      puzzleType: json['puzzleType'] ?? '',
      stars: json['stars'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      bestTimeSeconds: json['bestTimeSeconds'] ?? 0,
      hintsUsed: json['hintsUsed'] ?? 0,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      lastAttemptAt: json['lastAttemptAt'] != null
          ? DateTime.parse(json['lastAttemptAt'])
          : DateTime.now(),
    );
  }

  static String encode(List<PuzzleProgress> progressList) {
    return jsonEncode(progressList.map((p) => p.toJson()).toList());
  }

  static List<PuzzleProgress> decode(String jsonString) {
    final list = jsonDecode(jsonString) as List;
    return list.map((item) => PuzzleProgress.fromJson(item)).toList();
  }
}

enum PuzzleType { crossword, mathRiddle, numberSequence, logicMath }

enum PuzzleDifficulty { easy, medium, hard, expert }

class CampaignChapter {
  final int chapterNumber;
  final String title;
  final String description;
  final String storyline;
  final List<String> puzzleIds;
  final int requiredStars;
  final bool isUnlocked;
  final int earnedStars;

  const CampaignChapter({
    required this.chapterNumber,
    required this.title,
    required this.description,
    required this.storyline,
    required this.puzzleIds,
    required this.requiredStars,
    this.isUnlocked = false,
    this.earnedStars = 0,
  });

  double get completionPercentage {
    if (puzzleIds.isEmpty) return 0.0;
    return earnedStars / (puzzleIds.length * 3);
  }

  CampaignChapter copyWith({
    int? chapterNumber,
    String? title,
    String? description,
    String? storyline,
    List<String>? puzzleIds,
    int? requiredStars,
    bool? isUnlocked,
    int? earnedStars,
  }) {
    return CampaignChapter(
      chapterNumber: chapterNumber ?? this.chapterNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      storyline: storyline ?? this.storyline,
      puzzleIds: puzzleIds ?? this.puzzleIds,
      requiredStars: requiredStars ?? this.requiredStars,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      earnedStars: earnedStars ?? this.earnedStars,
    );
  }
}

class PuzzleHint {
  final String hintText;
  final int cost;
  final bool isRevealed;

  const PuzzleHint({
    required this.hintText,
    required this.cost,
    this.isRevealed = false,
  });

  PuzzleHint reveal() =>
      PuzzleHint(hintText: hintText, cost: cost, isRevealed: true);
}
