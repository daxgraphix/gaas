import '../../core/security/security_service.dart';

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
      'name': SecurityService.instance.sanitizeInput(name, maxLength: 30),
      'avatarShape': avatarShape,
      'avatarColor': avatarColor,
      'theme': theme,
      'language': language,
      'totalPoints': SecurityService.instance.validateAndSanitizeScore(totalPoints, 999999),
      'createdAt': createdAt.toIso8601String(),
      'lastPlayedAt': lastPlayedAt.toIso8601String(),
      'loginStreak': SecurityService.instance.validateAndSanitizeScore(loginStreak, 365),
      'unlockedAvatars': unlockedAvatars,
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
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastPlayedAt: json['lastPlayedAt'] != null
          ? DateTime.parse(json['lastPlayedAt'])
          : DateTime.now(),
      loginStreak: SecurityService.instance.validateAndSanitizeScore(json['loginStreak'] ?? 0, 365),
      unlockedAvatars: (json['unlockedAvatars'] as List<dynamic>?)?.cast<String>(),
    );
  }
}
