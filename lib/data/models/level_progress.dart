import '../../core/security/security_service.dart';

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
      'level': SecurityService.instance.validateAndSanitizeScore(level, 30),
      'stars': SecurityService.instance.validateAndSanitizeScore(stars, 3),
      'isUnlocked': isUnlocked,
      'highScore': SecurityService.instance.validateAndSanitizeScore(highScore, 2000),
    };
  }

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      id: json['id'],
      operationId: json['operationId'],
      level: SecurityService.instance.validateAndSanitizeScore(json['level'] ?? 0, 30),
      stars: SecurityService.instance.validateAndSanitizeScore(json['stars'] ?? 0, 3),
      isUnlocked: json['isUnlocked'] ?? false,
      highScore: SecurityService.instance.validateAndSanitizeScore(json['highScore'] ?? 0, 2000),
    );
  }
}
