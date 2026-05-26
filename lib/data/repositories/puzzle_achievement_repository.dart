import 'package:shared_preferences/shared_preferences.dart';
import '../models/puzzle_achievement.dart';

class PuzzleAchievementRepository {
  static const String _storageKey = 'puzzle_achievements';
  List<PuzzleAchievement> _achievements = [];
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await _loadFromStorage();
    _initialized = true;
  }

  Future<List<PuzzleAchievement>> getAllAchievements() async {
    await initialize();
    if (_achievements.isEmpty) {
      await _initializeDefaultAchievements();
    }
    return List.from(_achievements);
  }

  Future<PuzzleAchievement?> getAchievement(String achievementId) async {
    await initialize();
    try {
      return _achievements.firstWhere((a) => a.achievementId == achievementId);
    } catch (_) {
      return null;
    }
  }

  Future<List<PuzzleAchievement>> getUnlockedAchievements() async {
    await initialize();
    return _achievements.where((a) => a.isUnlocked).toList();
  }

  Future<void> updateProgress(String achievementId, int newProgress) async {
    await initialize();
    final index = _achievements.indexWhere(
      (a) => a.achievementId == achievementId,
    );
    if (index == -1) return;

    final achievement = _achievements[index];
    final updated = achievement.copyWith(
      progress: newProgress,
      isUnlocked: newProgress >= achievement.targetProgress,
      unlockedAt: newProgress >= achievement.targetProgress
          ? DateTime.now()
          : null,
    );
    _achievements[index] = updated;
    await _saveToStorage();
  }

  Future<void> unlockAchievement(String achievementId) async {
    await initialize();
    final index = _achievements.indexWhere(
      (a) => a.achievementId == achievementId,
    );
    if (index == -1) return;

    final achievement = _achievements[index];
    if (achievement.isUnlocked) return;

    final updated = achievement.copyWith(
      isUnlocked: true,
      progress: achievement.targetProgress,
      unlockedAt: DateTime.now(),
    );
    _achievements[index] = updated;
    await _saveToStorage();
  }

  Future<int> getTotalRewardPoints() async {
    final unlocked = await getUnlockedAchievements();
    int total = 0;
    for (final a in unlocked) {
      total += a.rewardPoints;
    }
    return total;
  }

  Future<void> _initializeDefaultAchievements() async {
    _achievements = [
      PuzzleAchievement(
        achievementId: 'first_crossword',
        title: 'Word Hunter',
        description: 'Complete your first crossword puzzle',
        iconName: 'library_books',
        rewardPoints: 100,
        targetProgress: 1,
      ),
      PuzzleAchievement(
        achievementId: 'crossword_master',
        title: 'Crossword Master',
        description: 'Complete 10 crossword puzzles',
        iconName: 'emoji_events',
        rewardPoints: 500,
        targetProgress: 10,
      ),
      PuzzleAchievement(
        achievementId: 'math_wizard',
        title: 'Math Wizard',
        description: 'Complete your first math riddle',
        iconName: 'calculate',
        rewardPoints: 100,
        targetProgress: 1,
      ),
      PuzzleAchievement(
        achievementId: 'math_genius',
        title: 'Math Genius',
        description: 'Complete 20 math riddles',
        iconName: 'psychology',
        rewardPoints: 500,
        targetProgress: 20,
      ),
      PuzzleAchievement(
        achievementId: 'speed_demon',
        title: 'Speed Demon',
        description: 'Complete a puzzle in under 30 seconds',
        iconName: 'speed',
        rewardPoints: 200,
        targetProgress: 1,
      ),
      PuzzleAchievement(
        achievementId: 'no_hints_needed',
        title: 'Independent Thinker',
        description: 'Complete 5 puzzles without using hints',
        iconName: 'lightbulb',
        rewardPoints: 300,
        targetProgress: 5,
      ),
      PuzzleAchievement(
        achievementId: 'perfectionist',
        title: 'Perfectionist',
        description: 'Get 3 stars on 10 puzzles',
        iconName: 'star',
        rewardPoints: 400,
        targetProgress: 10,
      ),
      PuzzleAchievement(
        achievementId: 'streak_7',
        title: 'Week Warrior',
        description: 'Complete puzzles 7 days in a row',
        iconName: 'local_fire_department',
        rewardPoints: 500,
        targetProgress: 7,
      ),
      PuzzleAchievement(
        achievementId: 'sequence_solver',
        title: 'Pattern Seeker',
        description: 'Complete 5 number sequence puzzles',
        iconName: 'timeline',
        rewardPoints: 200,
        targetProgress: 5,
      ),
      PuzzleAchievement(
        achievementId: 'logic_master',
        title: 'Logic Master',
        description: 'Complete 5 logic math challenges',
        iconName: 'extension',
        rewardPoints: 300,
        targetProgress: 5,
      ),
    ];
    await _saveToStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_storageKey);
      if (json != null && json.isNotEmpty) {
        _achievements = PuzzleAchievement.decode(json);
      }
    } catch (_) {
      _achievements = [];
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _storageKey,
        PuzzleAchievement.encode(_achievements),
      );
    } catch (_) {}
  }
}
