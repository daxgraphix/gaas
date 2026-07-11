class CampaignChapterState {
  final int chapterNumber;
  final String title;
  final String storyline;
  final List<PuzzleStageState> stages;
  final int earnedStars;
  final int totalStars;

  CampaignChapterState({
    required this.chapterNumber,
    required this.title,
    required this.storyline,
    required this.stages,
    this.earnedStars = 0,
    this.totalStars = 0,
  });

  CampaignChapterState copyWith({
    int? chapterNumber,
    String? title,
    String? storyline,
    List<PuzzleStageState>? stages,
    int? earnedStars,
    int? totalStars,
  }) {
    return CampaignChapterState(
      chapterNumber: chapterNumber ?? this.chapterNumber,
      title: title ?? this.title,
      storyline: storyline ?? this.storyline,
      stages: stages ?? this.stages,
      earnedStars: earnedStars ?? this.earnedStars,
      totalStars: totalStars ?? this.totalStars,
    );
  }
}

class PuzzleStageState {
  final String id;
  final String title;
  final String type;
  final int difficulty;
  final bool isUnlocked;
  final int stars;

  PuzzleStageState({
    required this.id,
    required this.title,
    required this.type,
    required this.difficulty,
    this.isUnlocked = false,
    this.stars = 0,
  });

  PuzzleStageState copyWith({
    String? id,
    String? title,
    String? type,
    int? difficulty,
    bool? isUnlocked,
    int? stars,
  }) {
    return PuzzleStageState(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      stars: stars ?? this.stars,
    );
  }
}
