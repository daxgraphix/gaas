class UserSession {
  String? id;
  String name;
  String avatarShape;
  String avatarColor;
  String theme;
  String language;
  int totalPoints;
  DateTime createdAt;
  DateTime lastPlayedAt;
  int loginStreak;
  List<String>? unlockedAvatars;

  UserSession({
    this.id,
    this.name = '',
    this.avatarShape = 'circle',
    this.avatarColor = '#00BCD4',
    this.theme = 'light',
    this.language = 'en',
    this.totalPoints = 0,
    DateTime? createdAt,
    DateTime? lastPlayedAt,
    this.loginStreak = 0,
    this.unlockedAvatars,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastPlayedAt = lastPlayedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarShape': avatarShape,
      'avatarColor': avatarColor,
      'theme': theme,
      'language': language,
      'totalPoints': totalPoints,
      'createdAt': createdAt.toIso8601String(),
      'lastPlayedAt': lastPlayedAt.toIso8601String(),
      'loginStreak': loginStreak,
      'unlockedAvatars': unlockedAvatars,
    };
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      id: json['id'],
      name: json['name'] ?? '',
      avatarShape: json['avatarShape'] ?? 'circle',
      avatarColor: json['avatarColor'] ?? '#00BCD4',
      theme: json['theme'] ?? 'light',
      language: json['language'] ?? 'en',
      totalPoints: json['totalPoints'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastPlayedAt: json['lastPlayedAt'] != null
          ? DateTime.parse(json['lastPlayedAt'])
          : DateTime.now(),
      loginStreak: json['loginStreak'] ?? 0,
      unlockedAvatars: (json['unlockedAvatars'] as List<dynamic>?)?.cast<String>(),
    );
  }
}
