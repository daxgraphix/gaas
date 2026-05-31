class Statistics {
  String? id;
  String? operationId;
  double dailyAccuracy;
  int highScore;
  int totalQuestionsAnswered;
  int correctAnswers;
  int timeSpentSeconds;
  int totalHintsUsed;
  int bestStreak;
  int currentStreak;
  DateTime lastUpdated;
  bool isSynced;
  final List<Map<String, dynamic>> timePerQuestion;
  final Map<String, double> accuracyByOperation;

  Statistics({
    this.id,
    this.operationId,
    this.dailyAccuracy = 0.0,
    this.highScore = 0,
    this.totalQuestionsAnswered = 0,
    this.correctAnswers = 0,
    this.timeSpentSeconds = 0,
    this.totalHintsUsed = 0,
    this.bestStreak = 0,
    this.currentStreak = 0,
    DateTime? lastUpdated,
    this.isSynced = false,
    List<Map<String, dynamic>>? timePerQuestion,
    Map<String, double>? accuracyByOperation,
  })  : lastUpdated = lastUpdated ?? DateTime.now(),
        timePerQuestion = timePerQuestion ?? [],
        accuracyByOperation = accuracyByOperation ?? {};

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operationId': operationId,
      'dailyAccuracy': dailyAccuracy,
      'highScore': highScore,
      'totalQuestionsAnswered': totalQuestionsAnswered,
      'correctAnswers': correctAnswers,
      'timeSpentSeconds': timeSpentSeconds,
      'totalHintsUsed': totalHintsUsed,
      'bestStreak': bestStreak,
      'currentStreak': currentStreak,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isSynced': isSynced,
      'timePerQuestion': timePerQuestion,
      'accuracyByOperation': accuracyByOperation,
    };
  }

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      id: json['id'],
      operationId: json['operationId'],
      dailyAccuracy: (json['dailyAccuracy'] as num?)?.toDouble() ?? 0.0,
      highScore: json['highScore'] ?? 0,
      totalQuestionsAnswered: json['totalQuestionsAnswered'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      timeSpentSeconds: json['timeSpentSeconds'] ?? 0,
      totalHintsUsed: json['totalHintsUsed'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated']) 
          : DateTime.now(),
      isSynced: json['isSynced'] ?? false,
      timePerQuestion: (json['timePerQuestion'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      accuracyByOperation: (json['accuracyByOperation'] as Map?)?.cast<String, double>() ?? {},
    );
  }
}
