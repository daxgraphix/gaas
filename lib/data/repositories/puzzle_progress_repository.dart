import 'package:shared_preferences/shared_preferences.dart';
import '../models/puzzle_progress.dart';

class PuzzleProgressRepository {
  static const String _storageKey = 'puzzle_progress';
  List<PuzzleProgress> _progressList = [];
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await _loadFromStorage();
    _initialized = true;
  }

  Future<PuzzleProgress?> getProgress(String puzzleId) async {
    await initialize();
    try {
      return _progressList.firstWhere((p) => p.puzzleId == puzzleId);
    } catch (_) {
      return null;
    }
  }

  Future<List<PuzzleProgress>> getAllProgress() async {
    await initialize();
    return List.from(_progressList);
  }

  Future<List<PuzzleProgress>> getProgressByType(String puzzleType) async {
    await initialize();
    return _progressList.where((p) => p.puzzleType == puzzleType).toList();
  }

  Future<void> saveProgress(PuzzleProgress progress) async {
    await initialize();
    final index = _progressList.indexWhere(
      (p) => p.puzzleId == progress.puzzleId,
    );
    if (index >= 0) {
      _progressList[index] = progress;
    } else {
      _progressList.add(progress);
    }
    await _saveToStorage();
  }

  Future<void> updateProgress({
    required String puzzleId,
    int? stars,
    bool? isCompleted,
    int? bestTimeSeconds,
    int? hintsUsed,
  }) async {
    await initialize();
    final index = _progressList.indexWhere((p) => p.puzzleId == puzzleId);

    if (index >= 0) {
      final existing = _progressList[index];
      final updatedStars = stars != null && stars > existing.stars
          ? stars
          : existing.stars;
      final updatedBestTime =
          bestTimeSeconds != null &&
              (existing.bestTimeSeconds == 0 ||
                  bestTimeSeconds < existing.bestTimeSeconds)
          ? bestTimeSeconds
          : existing.bestTimeSeconds;

      _progressList[index] = existing.copyWith(
        stars: updatedStars,
        isCompleted: isCompleted ?? existing.isCompleted,
        bestTimeSeconds: updatedBestTime,
        hintsUsed: hintsUsed ?? existing.hintsUsed,
        completedAt: (isCompleted == true && existing.completedAt == null)
            ? DateTime.now()
            : existing.completedAt,
        lastAttemptAt: DateTime.now(),
      );
    } else {
      final newProgress = PuzzleProgress(
        puzzleId: puzzleId,
        puzzleType: 'puzzle',
        stars: stars ?? 0,
        isCompleted: isCompleted ?? false,
        bestTimeSeconds: bestTimeSeconds ?? 0,
        hintsUsed: hintsUsed ?? 0,
        completedAt: isCompleted == true ? DateTime.now() : null,
      );
      _progressList.add(newProgress);
    }
    await _saveToStorage();
  }

  Future<int> getTotalStarsEarned() async {
    await initialize();
    int total = 0;
    for (final p in _progressList) {
      total += p.stars;
    }
    return total;
  }

  Future<int> getCompletedPuzzlesCount() async {
    await initialize();
    return _progressList.where((p) => p.isCompleted).length;
  }

  Future<void> resetAllProgress() async {
    _progressList = [];
    await _saveToStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_storageKey);
      if (json != null && json.isNotEmpty) {
        _progressList = PuzzleProgress.decode(json);
      }
    } catch (_) {
      _progressList = [];
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, PuzzleProgress.encode(_progressList));
    } catch (_) {}
  }
}
