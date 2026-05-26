import '../models/user_session.dart';
import 'database_service.dart';

class UserRepository {
  DatabaseService? _db;

  Future<DatabaseService> get db async {
    _db ??= await DatabaseService.instance;
    return _db!;
  }

  UserRepository();

  Future<UserSession?> getUserSession() async {
    final database = await db;
    return await database.getUserSession();
  }

  Future<void> saveUserSession(UserSession user) async {
    final database = await db;
    await database.saveUserSession(user);
  }

  Future<UserSession> createUserSession({
    required String name,
    required String avatarShape,
    required String avatarColor,
    required String theme,
    required String language,
    required int totalPoints,
    required int loginStreak,
  }) async {
    final user = UserSession(
      name: name,
      avatarShape: avatarShape,
      avatarColor: avatarColor,
      theme: theme,
      language: language,
      totalPoints: totalPoints,
      loginStreak: loginStreak,
    );
    final database = await db;
    await database.saveUserSession(user);
    return user;
  }

  Future<void> updatePoints(int points) async {
    final user = await getUserSession();
    if (user != null) {
      user.totalPoints += points;
      final database = await db;
      await database.saveUserSession(user);
    }
  }

  Future<void> updateUserSession(UserSession user) async {
    final database = await db;
    await database.saveUserSession(user);
  }

  Future<void> updateAvatar({
    required String shape,
    required String color,
  }) async {
    final user = await getUserSession();
    if (user != null) {
      user.avatarShape = shape;
      user.avatarColor = color;
      final database = await db;
      await database.saveUserSession(user);
    }
  }

  Future<void> updatePreferences({
    required String theme,
    required String language,
  }) async {
    final user = await getUserSession();
    if (user != null) {
      user.theme = theme;
      user.language = language;
      final database = await db;
      await database.saveUserSession(user);
    }
  }

  Future<void> updateLoginStreak() async {
    final user = await getUserSession();
    if (user != null) {
      user.loginStreak += 1;
      user.lastPlayedAt = DateTime.now();
      final database = await db;
      await database.saveUserSession(user);
    }
  }
}