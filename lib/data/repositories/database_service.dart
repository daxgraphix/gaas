import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level_progress.dart';
import '../models/statistics.dart';
import '../models/user_session.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static SharedPreferences? _prefs;

  DatabaseService._private();

  factory DatabaseService() {
    if (_instance == null) {
      _instance = DatabaseService._private();
      SharedPreferences.getInstance().then((prefs) => _prefs = prefs);
    }
    return _instance!;
  }

  static Future<DatabaseService> get instance async {
    if (_instance != null) return _instance!;
    _instance = DatabaseService._private();
    _prefs = await SharedPreferences.getInstance();
    return _instance!;
  }

  Future<void> saveUserSession(UserSession userSession) async {
    final json = userSession.toJson();
    await _prefs?.setString('user_session', jsonEncode(json));
  }

  Future<UserSession?> getUserSession() async {
    final jsonString = _prefs?.getString('user_session');
    if (jsonString == null) return null;
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return UserSession.fromJson(json);
  }

  Future<void> saveLevelProgress(LevelProgress progress) async {
    final key = 'level_progress_${progress.operationId}_${progress.level}';
    final json = progress.toJson();
    await _prefs?.setString(key, jsonEncode(json));
  }

  Future<LevelProgress?> getLevelProgress(String operationId, int level) async {
    final key = 'level_progress_${operationId}_$level';
    final jsonString = _prefs?.getString(key);
    if (jsonString == null) return null;
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return LevelProgress.fromJson(json);
  }

  Future<List<LevelProgress>> getAllLevelProgress() async {
    final keys = _prefs?.getKeys() ?? {};
    final progressList = <LevelProgress>[];
    
    for (final key in keys) {
      if (key.startsWith('level_progress_')) {
        final jsonString = _prefs?.getString(key);
        if (jsonString != null) {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          progressList.add(LevelProgress.fromJson(json));
        }
      }
    }
    
    return progressList;
  }

  Future<void> saveStatistics(Statistics stats) async {
    final key = 'statistics_${stats.operationId ?? 'all'}';
    final json = stats.toJson();
    await _prefs?.setString(key, jsonEncode(json));
  }

  Future<Statistics?> getStatistics(String? operationId) async {
    final key = 'statistics_${operationId ?? 'all'} ';
    final jsonString = _prefs?.getString(key.trim());
    if (jsonString == null) return null;
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return Statistics.fromJson(json);
  }

  Future<List<Statistics>> getAllStatistics() async {
    final keys = _prefs?.getKeys() ?? {};
    final statsList = <Statistics>[];
    
    for (final key in keys) {
      if (key.startsWith('statistics_')) {
        final jsonString = _prefs?.getString(key);
        if (jsonString != null) {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          statsList.add(Statistics.fromJson(json));
        }
      }
    }
    
    return statsList;
  }

  Future<void> clearAll() async {
    final keys = _prefs?.getKeys() ?? {};
    for (final key in keys) {
      if (key.startsWith('level_progress_') ||
          key.startsWith('statistics_') ||
          key == 'user_session') {
        await _prefs?.remove(key);
      }
    }
  }
}
