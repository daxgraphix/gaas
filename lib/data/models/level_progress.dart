class LevelProgress {
  String? id;
  String? operationId;
  int level;
  int stars;
  bool isUnlocked;
  int highScore;

  LevelProgress({
    this.id,
    required this.operationId,
    required this.level,
    required this.stars,
    required this.isUnlocked,
    required this.highScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operationId': operationId,
      'level': level,
      'stars': stars,
      'isUnlocked': isUnlocked,
      'highScore': highScore,
    };
  }

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      id: json['id'],
      operationId: json['operationId'],
      level: json['level'] ?? 0,
      stars: json['stars'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      highScore: json['highScore'] ?? 0,
    );
  }
}
