import '../../core/security/security_service.dart';

class UserSession {
  String? id;
  String name;
  String avatarShape;
  String avatarColor;
  String theme;
  String language;
  int totalPoints;
  int skillRating;
  bool isFocusMode;
  DateTime createdAt;
  DateTime lastPlayedAt;
  int loginStreak;
  List<String>? unlockedAvatars;
  String? lastPlayedMode;
  String? lastPlayedOperation;
  int? lastPlayedLevel;
  double? lastHeatIndex;

  UserSession({
    this.id,
    this.name = '',
    this.avatarShape = 'circle',
    this.avatarColor = '#00BCD4',
    this.theme = 'light',
    this.language = 'en',
    this.totalPoints = 0,
    this.skillRating = 1000,
    this.isFocusMode = false,
    DateTime? createdAt,
    DateTime? lastPlayedAt,
    this.loginStreak = 0,
    this.unlockedAvatars,
    this.lastPlayedMode,
    this.lastPlayedOperation,
    this.lastPlayedLevel,
    this.lastHeatIndex,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastPlayedAt = lastPlayedAt ?? DateTime.now();

  int get level => (totalPoints / 2500).floor() + 1;
  double get levelProgress => (totalPoints % 2500) / 2500;
  int get pointsToNextLevel => 2500 - (totalPoints % 2500);

  UserSession copyWith({
    String? id,
    String? name,
    String? avatarShape,
    String? avatarColor,
    String? theme,
    String? language,
    int? totalPoints,
    int? skillRating,
    bool? isFocusMode,
    DateTime? createdAt,
    DateTime? lastPlayedAt,
    int? loginStreak,
    List<String>? unlockedAvatars,
    String? lastPlayedMode,
    String? lastPlayedOperation,
    int? lastPlayedLevel,
    double? lastHeatIndex,
  }) {
    return UserSession(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarShape: avatarShape ?? this.avatarShape,
      avatarColor: avatarColor ?? this.avatarColor,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      totalPoints: totalPoints ?? this.totalPoints,
      skillRating: skillRating ?? this.skillRating,
      isFocusMode: isFocusMode ?? this.isFocusMode,
      createdAt: createdAt ?? this.createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      loginStreak: loginStreak ?? this.loginStreak,
      unlockedAvatars: unlockedAvatars ?? this.unlockedAvatars,
      lastPlayedMode: lastPlayedMode ?? this.lastPlayedMode,
      lastPlayedOperation: lastPlayedOperation ?? this.lastPlayedOperation,
      lastPlayedLevel: lastPlayedLevel ?? this.lastPlayedLevel,
      lastHeatIndex: lastHeatIndex ?? this.lastHeatIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': SecurityService.instance.sanitizeInput(name, maxLength: 30),
      'avatarShape': avatarShape,
      'avatarColor': avatarColor,
      'theme': theme,
      'language': language,
      'totalPoints': SecurityService.instance.validateAndSanitizeScore(totalPoints, 999999),
      'skillRating': skillRating,
      'isFocusMode': isFocusMode,
      'createdAt': createdAt.toIso8601String(),
      'lastPlayedAt': lastPlayedAt.toIso8601String(),
      'loginStreak': SecurityService.instance.validateAndSanitizeScore(loginStreak, 365),
      'unlockedAvatars': unlockedAvatars,
      'lastPlayedMode': lastPlayedMode,
      'lastPlayedOperation': lastPlayedOperation,
      'lastPlayedLevel': lastPlayedLevel,
      'lastHeatIndex': lastHeatIndex,
    };
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      id: json['id'],
      name: SecurityService.instance.sanitizeInput(json['name'] ?? ''),
      avatarShape: json['avatarShape'] ?? 'circle',
      avatarColor: json['avatarColor'] ?? '#00BCD4',
      theme: json['theme'] ?? 'light',
      language: json['language'] ?? 'en',
      totalPoints: SecurityService.instance.validateAndSanitizeScore(json['totalPoints'] ?? 0, 999999),
      skillRating: json['skillRating'] ?? 1000,
      isFocusMode: json['isFocusMode'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastPlayedAt: json['lastPlayedAt'] != null
          ? DateTime.parse(json['lastPlayedAt'])
          : DateTime.now(),
      loginStreak: SecurityService.instance.validateAndSanitizeScore(json['loginStreak'] ?? 0, 365),
      unlockedAvatars: (json['unlockedAvatars'] as List<dynamic>?)?.cast<String>(),
      lastPlayedMode: json['lastPlayedMode'],
      lastPlayedOperation: json['lastPlayedOperation'],
      lastPlayedLevel: json['lastPlayedLevel'],
      lastHeatIndex: (json['lastHeatIndex'] as num?)?.toDouble(),
    );
  }
}
