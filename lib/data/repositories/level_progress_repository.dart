import '../models/level_progress.dart';
import 'database_service.dart';

class LevelProgressRepository {
  DatabaseService? _db;

  Future<DatabaseService> get db async {
    _db ??= await DatabaseService.instance;
    return _db!;
  }

  LevelProgressRepository();

  Future<List<LevelProgress>> getAllProgress() async {
    final database = await db;
    return await database.getAllLevelProgress();
  }

  Future<LevelProgress?> getProgress(String operationId, int level) async {
    final database = await db;
    return await database.getLevelProgress(operationId, level);
  }

  Future<List<LevelProgress>> getProgressByOperation(String operationId) async {
    final allProgress = await getAllProgress();
    return allProgress.where((p) => p.operationId == operationId).toList();
  }

  Future<void> saveProgress(LevelProgress progress) async {
    final database = await db;
    await database.saveLevelProgress(progress);
  }

  Future<void> saveProgresses(List<LevelProgress> progresses) async {
    final database = await db;
    for (final progress in progresses) {
      await database.saveLevelProgress(progress);
    }
  }

  Future<int> getCompletedLevelCount() async {
    final allProgress = await getAllProgress();
    return allProgress.where((p) => p.stars > 0).length;
  }

  Future<int> getTotalStars() async {
    final allProgress = await getAllProgress();
    return allProgress.fold<int>(0, (int sum, LevelProgress p) => sum + p.stars);
  }

  Future<int> getHighScore(String operationId, int level) async {
    final progress = await getProgress(operationId, level);
    return progress?.highScore ?? 0;
  }

Future<void> updateHighScore(String operationId, int level, int score) async {
    var progress = await getProgress(operationId, level);
    
    if (progress == null) {
      progress = LevelProgress(
        operationId: operationId,
        level: level,
        stars: score >= 40 ? 3 : score >= 31 ? 2 : score >= 22 ? 1 : 0,
        highScore: score,
        isUnlocked: true,
      );
    } else {
      final newStars = score >= 40 ? 3 : score >= 31 ? 2 : score >= 22 ? 1 : 0;
      progress = LevelProgress(
        id: progress.id,
        operationId: operationId,
        level: level,
        stars: progress.stars > newStars ? progress.stars : newStars,
        highScore: score > progress.highScore ? score : progress.highScore,
        isUnlocked: true,
      );
    }

    final database = await db;
    await database.saveLevelProgress(progress);

    // Unlock next level only if score >= 35 (out of 45)
    if (score >= 35 && level < 100) {
      var nextLevel = await getProgress(operationId, level + 1);
      if (nextLevel == null || !nextLevel.isUnlocked) {
        await unlockLevel(operationId, level + 1);
      }
    }
  }

  Future<void> unlockLevel(String operationId, int level) async {
    var progress = await getProgress(operationId, level);
    
    if (progress == null) {
      progress = LevelProgress(
        operationId: operationId,
        level: level,
        stars: 0,
        highScore: 0,
        isUnlocked: true,
      );
    } else {
      progress = LevelProgress(
        id: progress.id,
        operationId: operationId,
        level: level,
        stars: progress.stars,
        highScore: progress.highScore,
        isUnlocked: true,
      );
    }

    final database = await db;
    await database.saveLevelProgress(progress);
  }

  Future<void> updateStars(String operationId, int level, int stars, int score) async {
    var progress = await getProgress(operationId, level);
    
    if (progress != null) {
      // Always preserve isUnlocked: true if it was already unlocked
      progress = LevelProgress(
        id: progress.id,
        operationId: operationId,
        level: level,
        stars: stars > progress.stars ? stars : progress.stars,
        highScore: score > progress.highScore ? score : progress.highScore,
        isUnlocked: true, // Replaying a level keeps it unlocked
      );
    } else {
      progress = LevelProgress(
        operationId: operationId,
        level: level,
        stars: stars,
        highScore: score,
        isUnlocked: true,
      );
    }

    final database = await db;
    await database.saveLevelProgress(progress);

    if (level < 100) {
      // Requirement to unlock next level: current level must have at least 1 star.
      // We also check total stars to ensure the linear (level-1)*2 requirement is met.
      if (stars > 0) {
        final totalStars = await getTotalStars();
        // The requirement for Level (L+1) is L*2 stars.
        // E.g., to unlock Level 11, you need 10*2 = 20 stars.
        final starsNeeded = level * 2;
        
        if (totalStars >= starsNeeded) {
          var nextLevel = await getProgress(operationId, level + 1);
          if (nextLevel == null || !nextLevel.isUnlocked) {
            await unlockLevel(operationId, level + 1);
          }
        }
      }
    }
  }

  Future<void> initializeLevels() async {
    final operations = [
      'addition',
      'subtraction',
      'multiplication',
      'division',
      'arithmetic',
      'logic',
      'math_riddle',
      'cross_numbers',
    ];
    for (final op in operations) {
      final existing = await getProgress(op, 1);
      if (existing == null) {
        await unlockLevel(op, 1);
      }
    }
  }
}
