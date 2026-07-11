import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_session.dart';
import '../data/models/game_settings.dart';
import '../data/models/level_progress.dart';
import '../data/models/math_riddle.dart';
import '../data/models/campaign_state.dart';
import '../data/models/challenge_state.dart';
import '../data/models/cross_numbers_puzzle.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/level_progress_repository.dart';
import '../data/repositories/math_riddles_repository.dart';
import '../data/repositories/database_service.dart';
import '../features/analytics/analytics_provider.dart';
import '../data/repositories/statistics_repository.dart';
import '../features/game/logic/session_stats_provider.dart';
import '../features/game/logic/dynamic_difficulty_provider.dart';
import '../data/content_library/achievement_system.dart';
import '../features/game/logic/player_performance_provider.dart';
import 'math_engine/cross_numbers_engine.dart';
import 'math_engine/math_riddle_engine.dart';
import 'sound_manager.dart';
import 'themes/app_themes.dart';

// Repository Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  return StatisticsRepository();
});

final levelProgressRepositoryProvider = Provider<LevelProgressRepository>((ref) {
  return LevelProgressRepository();
});

final mathRiddlesRepositoryProvider = Provider<MathRiddlesRepository>((ref) {
  return MathRiddlesRepository();
});

final soundManagerProvider = Provider<SoundManager>((ref) {
  return SoundManager.instance;
});

// UI State Providers
final reportsFilterProvider = StateProvider<String?>((ref) => null);
final navigationIndexProvider = StateProvider<int>((ref) => 0);

// Locale Provider
class AppLocale {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const AppLocale({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  static const en = AppLocale(code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸');
  static const sw = AppLocale(code: 'sw', name: 'Swahili', nativeName: 'Kiswahili', flag: '🇹🇿');

  static const List<AppLocale> supportedLocales = [en, sw];
}

// Theme Provider
class AppThemeNotifier extends StateNotifier<AppThemeType> {
  final SharedPreferences _prefs;
  static const String _themeKey = 'app_theme';

  AppThemeNotifier(this._prefs) : super(_getInitialTheme(_prefs));

  static AppThemeType _getInitialTheme(SharedPreferences prefs) {
    final themeName = prefs.getString(_themeKey);
    if (themeName == null) return AppThemeType.solar;
    return AppThemeType.values.firstWhere(
      (t) => t.name == themeName,
      orElse: () => AppThemeType.solar,
    );
  }

  Future<void> setTheme(AppThemeType theme) async {
    state = theme;
    await _prefs.setString(_themeKey, theme.name);
  }
}

final themeProvider = StateNotifierProvider<AppThemeNotifier, AppThemeType>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AppThemeNotifier(prefs);
});

// Locale Provider
class LocaleNotifier extends StateNotifier<AppLocale> {
  final SharedPreferences _prefs;
  static const String _localeKey = 'app_locale';

  LocaleNotifier(this._prefs) : super(_getInitialLocale(_prefs));

  static AppLocale _getInitialLocale(SharedPreferences prefs) {
    final code = prefs.getString(_localeKey);
    if (code == null) return AppLocale.en;
    return AppLocale.supportedLocales.firstWhere(
      (l) => l.code == code,
      orElse: () => AppLocale.en,
    );
  }

  Future<void> setLocale(AppLocale locale) async {
    state = locale;
    await _prefs.setString(_localeKey, locale.code);
  }

  Future<void> toggleLanguage() async {
    final next = state.code == 'en' ? AppLocale.sw : AppLocale.en;
    await setLocale(next);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, AppLocale>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

const int hintCostPoints = 50;

// Startup Provider
class StartupState {
  final bool isReady;
  final bool needsIntro;
  final bool needsProfileSetup;

  const StartupState({
    this.isReady = false,
    this.needsIntro = true,
    this.needsProfileSetup = true,
  });

  StartupState copyWith({
    bool? isReady,
    bool? needsIntro,
    bool? needsProfileSetup,
  }) {
    return StartupState(
      isReady: isReady ?? this.isReady,
      needsIntro: needsIntro ?? this.needsIntro,
      needsProfileSetup: needsProfileSetup ?? this.needsProfileSetup,
    );
  }
}

class StartupNotifier extends StateNotifier<StartupState> {
  final Ref ref;
  StartupNotifier(this.ref) : super(const StartupState()) {
    _init();
  }

  Future<void> _init() async {
    // Initialize Database first
    await DatabaseService.instance;

    // Initialize Sound and Haptic Managers
    await Future.wait([
      SoundManager.instance.initialize(),
      HapticManager.instance.initialize(),
    ]);

    // Apply saved settings to hardware managers
    final settings = await ref.read(settingsProvider.notifier).loadSettings();
    await SoundManager.instance.setMuted(!settings.soundEnabled);
    await HapticManager.instance.setHapticsEnabled(settings.vibrationEnabled);

    // Play startup sound
    if (settings.soundEnabled) {
      await SoundManager.instance.playStartupSound();
    }

    // Check user and intro status
    final prefs = ref.read(sharedPreferencesProvider);
    final needsIntro = prefs.getBool('needs_intro') ?? true;
    
    final user = await ref.read(userSessionProvider.notifier).loadUser();

    // Simulate loading
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(
      isReady: true,
      needsIntro: needsIntro,
      needsProfileSetup: user == null,
    );
  }

  Future<void> completeIntro() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('needs_intro', false);
    state = state.copyWith(needsIntro: false);
  }

  Future<void> completeProfileSetup() async {
    state = state.copyWith(needsProfileSetup: false);
  }
}

final startupProvider = StateNotifierProvider<StartupNotifier, StartupState>((ref) {
  return StartupNotifier(ref);
});

// Daily Challenge Provider
class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String type;
  final int targetValue;
  final int currentValue;
  final int rewardPoints;
  final DateTime expiresAt;
  final bool isCompleted;
  final bool isClaimed;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    this.currentValue = 0,
    required this.rewardPoints,
    required this.expiresAt,
    this.isCompleted = false,
    this.isClaimed = false,
  });

  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'rewardPoints': rewardPoints,
      'expiresAt': expiresAt.toIso8601String(),
      'isCompleted': isCompleted,
      'isClaimed': isClaimed,
    };
  }

  factory DailyChallenge.fromMap(Map<String, dynamic> map) {
    return DailyChallenge(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      type: map['type'],
      targetValue: map['targetValue'],
      currentValue: map['currentValue'] ?? 0,
      rewardPoints: map['rewardPoints'],
      expiresAt: DateTime.parse(map['expiresAt']),
      isCompleted: map['isCompleted'] ?? false,
      isClaimed: map['isClaimed'] ?? false,
    );
  }

  DailyChallenge copyWith({
    int? currentValue,
    bool? isCompleted,
    bool? isClaimed,
  }) {
    return DailyChallenge(
      id: id,
      title: title,
      description: description,
      type: type,
      targetValue: targetValue,
      currentValue: currentValue ?? this.currentValue,
      rewardPoints: rewardPoints,
      expiresAt: expiresAt,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}

class DailyChallengeNotifier extends StateNotifier<List<DailyChallenge>> {
  final SharedPreferences _prefs;
  static const String _lastResetKey = 'daily_challenges_last_reset';
  static const String _challengesKey = 'daily_challenges_data';

  DailyChallengeNotifier(this._prefs) : super([]) {
    checkAndResetChallenges();
  }

  void checkAndResetChallenges() {
    final now = DateTime.now();
    final lastResetStr = _prefs.getString(_lastResetKey);
    final lastReset = lastResetStr != null ? DateTime.parse(lastResetStr) : null;

    if (lastReset == null || _isDifferentDay(lastReset, now)) {
      _generateNewChallenges(now);
    } else {
      _loadSavedChallenges();
    }
  }

  void _loadSavedChallenges() {
    final data = _prefs.getString(_challengesKey);
    if (data != null) {
      try {
        final List<dynamic> decoded = json.decode(data);
        state = decoded.map((m) => DailyChallenge.fromMap(Map<String, dynamic>.from(m))).toList();
        
        // If loading failed to produce challenges, generate new ones
        if (state.isEmpty) {
          _generateNewChallenges(DateTime.now());
        }
      } catch (e) {
        _generateNewChallenges(DateTime.now());
      }
    } else {
      _generateNewChallenges(DateTime.now());
    }
  }

  void _saveChallenges() {
    final data = json.encode(state.map((c) => c.toMap()).toList());
    _prefs.setString(_challengesKey, data);
  }

  bool _isDifferentDay(DateTime d1, DateTime d2) {
    return d1.year != d2.year || d1.month != d2.month || d1.day != d2.day;
  }

  void _generateNewChallenges(DateTime now) {
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final random = Random();
    
    final pool = [
      {
        'id': 'questions_daily',
        'title': 'Daily Practice',
        'description': 'Solve 20 questions',
        'type': 'questions',
        'target': 20,
        'reward': 100,
      },
      {
        'id': 'correct_daily',
        'title': 'Sharp Mind',
        'description': 'Get 15 correct answers',
        'type': 'correct',
        'target': 15,
        'reward': 150,
      },
      {
        'id': 'arcade_daily',
        'title': 'Arcade Runner',
        'description': 'Play 3 Arcade sessions',
        'type': 'arcade_sessions',
        'target': 3,
        'reward': 120,
      },
      {
        'id': 'cross_daily',
        'title': 'Grid Master',
        'description': 'Solve 2 Cross Numbers puzzles',
        'type': 'cross_numbers',
        'target': 2,
        'reward': 200,
      },
      {
        'id': 'streak_daily',
        'title': 'Consistency',
        'description': 'Get a 10-question streak',
        'type': 'streak',
        'target': 10,
        'reward': 180,
      },
      {
        'id': 'stars_daily',
        'title': 'Star Collector',
        'description': 'Earn 10 stars in Campaign',
        'type': 'stars',
        'target': 10,
        'reward': 200,
      },
      {
        'id': 'wins_daily',
        'title': 'Duel Champion',
        'description': 'Win 2 Duels',
        'type': 'wins',
        'target': 2,
        'reward': 150,
      },
      {
        'id': 'division_daily',
        'title': 'Division Master',
        'description': 'Solve 10 division problems',
        'type': 'division',
        'target': 10,
        'reward': 120,
      },
    ];

    pool.shuffle(random);
    final selected = pool.take(3).toList(); // Give 3 random challenges daily

    state = selected.map((c) => DailyChallenge(
      id: c['id'] as String,
      title: c['title'] as String,
      description: c['description'] as String,
      type: c['type'] as String,
      targetValue: c['target'] as int,
      rewardPoints: c['reward'] as int,
      expiresAt: endOfDay,
    )).toList();

    _prefs.setString(_lastResetKey, now.toIso8601String());
    _saveChallenges();
  }

  void incrementProgress(String type, int amount) {
    state = state.map((c) {
      if (c.type == type && !c.isCompleted) {
        final newValue = c.currentValue + amount;
        return c.copyWith(
          currentValue: newValue,
          isCompleted: newValue >= c.targetValue,
        );
      }
      return c;
    }).toList();
    _saveChallenges();
  }

  void updateProgressMax(String type, int value) {
     state = state.map((c) {
      if (c.type == type && !c.isCompleted) {
        final newValue = max(c.currentValue, value);
        return c.copyWith(
          currentValue: newValue,
          isCompleted: newValue >= c.targetValue,
        );
      }
      return c;
    }).toList();
    _saveChallenges();
  }

  void claimReward(String id, WidgetRef ref) {
    state = state.map((c) {
      if (c.id == id && c.isCompleted && !c.isClaimed) {
        ref.read(userSessionProvider.notifier).addPoints(c.rewardPoints);
        ref.read(soundManagerProvider).playSuccess();
        
        // Track for achievement
        final totalClaimed = _prefs.getInt('daily_challenges_claimed_total') ?? 0;
        final newTotal = totalClaimed + 1;
        _prefs.setInt('daily_challenges_claimed_total', newTotal);
        
        final achievements = ref.read(achievementDatabaseProvider);
        ref.read(achievementStateProvider.notifier).checkAndUnlock(
          'daily_challenges_claimed', 
          newTotal, 
          achievements
        );

        return c.copyWith(isClaimed: true);
      }
      return c;
    }).toList();
    _saveChallenges();
  }
}

final dailyChallengeProvider = StateNotifierProvider<DailyChallengeNotifier, List<DailyChallenge>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DailyChallengeNotifier(prefs);
});

// Logic Providers
final userSessionProvider = StateNotifierProvider<UserSessionNotifier, UserSession?>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserSessionNotifier(repository);
});


class UserSessionNotifier extends StateNotifier<UserSession?> {
  final UserRepository _repository;
  UserSessionNotifier(this._repository) : super(null) {
    loadUser();
  }

  Future<UserSession?> loadUser() async {
    final user = await _repository.getUserSession();
    state = user;
    return user;
  }

  Future<void> updateName(String name) async {
    if (state != null) {
      final updated = state!.copyWith(name: name);
      await _repository.updateUserSession(updated);
      state = updated;
    }
  }

  Future<void> updateUser({
    String? id,
    String? name,
    String? avatarShape,
    String? avatarColor,
    String? theme,
    String? language,
    int? totalPoints,
    int? skillRating,
    bool? isFocusMode,
    DateTime? lastPlayedAt,
    int? loginStreak,
    List<String>? unlockedAvatars,
    String? lastPlayedMode,
    String? lastPlayedOperation,
    int? lastPlayedLevel,
    double? lastHeatIndex,
  }) async {
    final currentUser = state ?? UserSession(
      name: name ?? 'Player',
      avatarShape: avatarShape ?? 'circle',
      avatarColor: avatarColor ?? '#00BCD4',
    );

    final updated = currentUser.copyWith(
      id: id,
      name: name,
      avatarShape: avatarShape,
      avatarColor: avatarColor,
      theme: theme,
      language: language,
      totalPoints: totalPoints,
      skillRating: skillRating,
      isFocusMode: isFocusMode,
      lastPlayedAt: lastPlayedAt,
      loginStreak: loginStreak,
      unlockedAvatars: unlockedAvatars,
      lastPlayedMode: lastPlayedMode,
      lastPlayedOperation: lastPlayedOperation,
      lastPlayedLevel: lastPlayedLevel,
      lastHeatIndex: lastHeatIndex,
    );
    await _repository.updateUserSession(updated);
    state = updated;
  }

  Future<void> addPoints(int points) async {
    if (state != null) {
      final updated = state!.copyWith(totalPoints: state!.totalPoints + points);
      await _repository.updateUserSession(updated);
      state = updated;
    }
  }

  Future<void> equipAvatar(String shape, [String? color]) async {
    if (state != null) {
      final updated = state!.copyWith(
        avatarShape: shape,
        avatarColor: color ?? state!.avatarColor,
      );
      await _repository.updateUserSession(updated);
      state = updated;
    }
  }

  Future<void> setFocusMode(bool enabled) async {
    if (state != null) {
      final updated = state!.copyWith(isFocusMode: enabled);
      await _repository.updateUserSession(updated);
      state = updated;
    }
  }

  Future<bool> unlockAvatar(String avatarId, int cost, int requiredStars, {int? requiredLevel}) async {
    if (state != null) {
      // Basic validation
      if (state!.totalPoints < cost) return false;
      
      final unlocked = List<String>.from(state!.unlockedAvatars ?? []);
      if (!unlocked.contains(avatarId)) {
        unlocked.add(avatarId);
        final updated = state!.copyWith(
          unlockedAvatars: unlocked,
          totalPoints: state!.totalPoints - cost,
        );
        await _repository.updateUserSession(updated);
        state = updated;
        return true;
      }
    }
    return false;
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, GameSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository);
});

class SettingsNotifier extends StateNotifier<GameSettings> {
  final SettingsRepository _repository;
  SettingsNotifier(this._repository) : super(const GameSettings()) {
    loadSettings();
  }

  Future<GameSettings> loadSettings() async {
    final settings = await _repository.getSettings();
    state = settings;
    return settings;
  }

  Future<void> updateSettings(GameSettings settings) async {
    await _repository.saveSettings(settings);
    state = settings;
  }

  Future<void> toggleNotifications(bool enabled) async {
    final updated = state.copyWith(notificationsEnabled: enabled);
    await updateSettings(updated);
  }

  Future<void> toggleSound(bool enabled) async {
    final updated = state.copyWith(soundEnabled: enabled);
    await SoundManager.instance.setMuted(!enabled);
    await updateSettings(updated);
  }

  Future<void> toggleHaptics(bool enabled) async {
    final updated = state.copyWith(vibrationEnabled: enabled);
    await HapticManager.instance.setHapticsEnabled(enabled);
    await updateSettings(updated);
  }
}

final levelProgressProvider = StateNotifierProvider<LevelProgressNotifier, Map<String, List<LevelProgress>>>((ref) {
  final repository = ref.watch(levelProgressRepositoryProvider);
  return LevelProgressNotifier(repository);
});

class LevelProgressNotifier extends StateNotifier<Map<String, List<LevelProgress>>> {
  final LevelProgressRepository _repository;
  LevelProgressNotifier(this._repository) : super({}) {
    loadProgress();
  }

  Future<void> loadProgress() async {
    final allProgress = await _repository.getAllProgress();
    final Map<String, List<LevelProgress>> groupedProgress = {};
    for (var progress in allProgress) {
      final operationId = progress.operationId ?? 'unknown';
      groupedProgress.putIfAbsent(operationId, () => []).add(progress);
    }
    state = groupedProgress;
  }

  Future<void> refreshProgress() async {
    await loadProgress();
  }

  Future<void> updateProgress(String operation, int level, int stars, int score) async {
    await _repository.updateStars(operation, level, stars, score);
    await loadProgress();
  }

  Future<void> unlockNextLevel(String operation, int level) async {
    await _repository.unlockLevel(operation, level);
    await loadProgress();
  }
}

final totalStarsProvider = Provider<int>((ref) {
  final progress = ref.watch(levelProgressProvider);
  if (progress.isEmpty) return 0;
  
  int total = 0;
  for (var levels in progress.values) {
    for (var level in levels) {
      total += level.stars;
    }
  }
  return total;
});

final completedLevelsProvider = Provider<int>((ref) {
  final progress = ref.watch(levelProgressProvider);
  if (progress.isEmpty) return 0;
  
  int total = 0;
  for (var levels in progress.values) {
    total += levels.where((l) => l.stars > 0).length;
  }
  return total;
});

final overallAccuracyProvider = Provider<double>((ref) {
  final analytics = ref.watch(analyticsProvider);
  return analytics.overallAccuracy;
});

final totalTimePlayedProvider = Provider<int>((ref) {
  final analytics = ref.watch(analyticsProvider);
  return analytics.totalTimeSpent;
});

// Riddles logic
final riddlesProvider = StateNotifierProvider<RiddlesNotifier, List<MathRiddle>>((ref) {
  final repository = ref.watch(mathRiddlesRepositoryProvider);
  return RiddlesNotifier(repository);
});

class RiddlesNotifier extends StateNotifier<List<MathRiddle>> {
  final MathRiddlesRepository _repository;
  RiddlesNotifier(this._repository) : super([]) {
    _loadRiddles();
  }

  Future<void> _loadRiddles() async {
    state = await _repository.getRiddles();
  }
}

// Stats logic
class PuzzleStats {
  final int puzzlesSolved;
  final int totalTime;
  final double averageTime;

  PuzzleStats({
    this.puzzlesSolved = 0,
    this.totalTime = 0,
    this.averageTime = 0.0,
  });
}

final puzzleStatsProvider = StateNotifierProvider<PuzzleStatsNotifier, PuzzleStats>((ref) {
  return PuzzleStatsNotifier();
});

class PuzzleStatsNotifier extends StateNotifier<PuzzleStats> {
  PuzzleStatsNotifier() : super(PuzzleStats());

  void recordSolve(int time) {
    final newCount = state.puzzlesSolved + 1;
    final newTime = state.totalTime + time;
    state = PuzzleStats(
      puzzlesSolved: newCount,
      totalTime: newTime,
      averageTime: newTime / newCount,
    );
  }

  void reset() {
    state = PuzzleStats();
  }
}

class CrossNumbersState {
  final List<CrossNumbersPuzzle> allPuzzles;
  final CrossNumbersPuzzle? puzzle;
  final bool isComplete;
  final int elapsedSeconds;
  final int? selectedRow;
  final int? selectedCol;
  final bool isNewSelection;
  final int hintsUsed;
  final int currentQuestionIndex;
  final int correctQuestions;
  final int totalQuestions;
  final bool isLevelFinished;
  final String gridStyle;
  final Set<int> satisfiedEquations;

  CrossNumbersState({
    this.allPuzzles = const [],
    this.puzzle,
    this.isComplete = false,
    this.elapsedSeconds = 0,
    this.selectedRow,
    this.selectedCol,
    this.isNewSelection = false,
    this.hintsUsed = 0,
    this.currentQuestionIndex = 1,
    this.correctQuestions = 0,
    this.totalQuestions = 7,
    this.isLevelFinished = false,
    this.gridStyle = 'Classic',
    this.satisfiedEquations = const {},
  });

  CrossNumbersState copyWith({
    List<CrossNumbersPuzzle>? allPuzzles,
    CrossNumbersPuzzle? puzzle,
    bool? isComplete,
    int? elapsedSeconds,
    int? selectedRow,
    int? selectedCol,
    bool? isNewSelection,
    int? hintsUsed,
    int? currentQuestionIndex,
    int? correctQuestions,
    int? totalQuestions,
    bool? isLevelFinished,
    String? gridStyle,
    Set<int>? satisfiedEquations,
  }) {
    return CrossNumbersState(
      allPuzzles: allPuzzles ?? this.allPuzzles,
      puzzle: puzzle ?? this.puzzle,
      isComplete: isComplete ?? this.isComplete,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      selectedRow: selectedRow ?? this.selectedRow,
      selectedCol: selectedCol ?? this.selectedCol,
      isNewSelection: isNewSelection ?? this.isNewSelection,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      correctQuestions: correctQuestions ?? this.correctQuestions,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      isLevelFinished: isLevelFinished ?? this.isLevelFinished,
      gridStyle: gridStyle ?? this.gridStyle,
      satisfiedEquations: satisfiedEquations ?? this.satisfiedEquations,
    );
  }
}

class CrossNumbersNotifier extends StateNotifier<CrossNumbersState> {
  final Ref ref;
  CrossNumbersNotifier(this.ref) : super(CrossNumbersState());

  void initLevel(int level) {
    int totalQuestions = 7 + (level ~/ 10);
    
    // Generate ONLY the first puzzle immediately to avoid blocking UI
    String style = _getGridStyle(level, 1);
    if (level % 10 == 0) style = 'Chaos';

    final firstPuzzle = CrossNumbersEngine.generatePuzzle(
      difficulty: level,
      style: style,
    );

    state = CrossNumbersState(
      allPuzzles: [firstPuzzle],
      puzzle: firstPuzzle,
      totalQuestions: totalQuestions,
      currentQuestionIndex: 1,
      correctQuestions: 0,
      isLevelFinished: false,
      gridStyle: style,
      satisfiedEquations: _getSatisfiedEquations(firstPuzzle),
    );

    // Start pre-generating the next puzzle in the background
    _preGenerateNextPuzzle();
  }

  Set<int> _getSatisfiedEquations(CrossNumbersPuzzle puzzle) {
    final satisfied = <int>{};
    for (int i = 0; i < puzzle.equations.length; i++) {
      if (puzzle.equations[i].isSatisfied(puzzle.grid)) {
        satisfied.add(i);
      }
    }
    return satisfied;
  }

  void _preGenerateNextPuzzle() {
    if (state.allPuzzles.length >= state.totalQuestions) return;
    
    // Use a microtask to avoid blocking the current execution flow
    Future.microtask(() {
      if (state.allPuzzles.length < state.totalQuestions) {
        final currentLevel = state.allPuzzles[0].difficulty;
        final nextIndex = state.allPuzzles.length;
        String style = _getGridStyle(currentLevel, nextIndex + 1);
        if (currentLevel % 10 == 0) style = 'Chaos';
        
        final nextPuzzle = CrossNumbersEngine.generatePuzzle(
          difficulty: currentLevel,
          style: style,
        );
        
        if (mounted) {
          state = state.copyWith(
            allPuzzles: [...state.allPuzzles, nextPuzzle],
          );
        }
      }
    });
  }

  void _loadPuzzleAt(int index) {
    if (index < 0 || index >= state.totalQuestions) return;
    
    // If we haven't generated this puzzle yet, generate it now (safety fallback)
    if (index >= state.allPuzzles.length) {
      final currentLevel = state.allPuzzles[0].difficulty;
      final newPuzzles = List<CrossNumbersPuzzle>.from(state.allPuzzles);
      
      while (newPuzzles.length <= index) {
        String style = _getGridStyle(currentLevel, newPuzzles.length + 1);
        if (currentLevel % 10 == 0) style = 'Chaos';
        
        newPuzzles.add(CrossNumbersEngine.generatePuzzle(
          difficulty: currentLevel,
          style: style,
        ));
      }
      state = state.copyWith(allPuzzles: newPuzzles);
    }
    
    final puzzle = state.allPuzzles[index];
    state = state.copyWith(
      puzzle: puzzle,
      isComplete: false,
      gridStyle: _getGridStyle(puzzle.difficulty, index + 1),
      selectedRow: null,
      selectedCol: null,
      satisfiedEquations: _getSatisfiedEquations(puzzle),
    );

    // Try to pre-generate the one AFTER this one
    _preGenerateNextPuzzle();
  }

  String _getGridStyle(int level, int questionIndex) {
    if (level < 5) return 'Classic';
    final styles = ['Classic', 'Dense', 'Symmetry', 'Chaos'];
    if (level >= 30) return styles[(questionIndex + level) % 4]; 
    if (level >= 15) return styles[(questionIndex + level) % 3]; 
    return styles[(questionIndex + level) % 2]; 
  }

  void selectCell(int r, int c) {
    if (state.puzzle == null || state.isLevelFinished) return;
    final cell = state.puzzle!.grid[r][c];
    if (cell.isUserEditable) {
      state = state.copyWith(
        selectedRow: r, 
        selectedCol: c,
        isNewSelection: true,
      );
    }
  }

  void updateCell(int r, int c, String value) {
    if (state.puzzle == null || state.isLevelFinished) return;
    
    final newGrid = List<List<CrossNumbersCell>>.from(
      state.puzzle!.grid.map((row) => List<CrossNumbersCell>.from(row))
    );
    
    final cell = newGrid[r][c];
    if (cell.isUserEditable) {
      String newValue;
      bool nextIsNewSelection = false;
      
      if (value == 'CLEAR') {
        newValue = '';
      } else if (value == 'BACK') {
        if (cell.userValue.isNotEmpty) {
          newValue = cell.userValue.substring(0, cell.userValue.length - 1);
        } else {
          newValue = '';
        }
      } else {
        if (state.isNewSelection) {
          newValue = value;
        } else {
          String current = cell.userValue;
          if (current.length < 4) {
            newValue = current + value;
          } else {
            newValue = current;
          }
        }
      }
      
      newGrid[r][c] = cell.copyWith(userValue: newValue);
      
      final newPuzzle = CrossNumbersPuzzle(
        id: state.puzzle!.id,
        gridSize: state.puzzle!.gridSize,
        grid: newGrid,
        equations: state.puzzle!.equations,
        difficulty: state.puzzle!.difficulty,
      );
      
      final newSatisfied = _getSatisfiedEquations(newPuzzle);
      if (newSatisfied.length > state.satisfiedEquations.length) {
        ref.read(soundManagerProvider).playEffect('correct');
        ref.read(dailyChallengeProvider.notifier).incrementProgress('correct', 1);
      }

      state = state.copyWith(
        puzzle: newPuzzle,
        isComplete: newPuzzle.isComplete,
        isNewSelection: nextIsNewSelection,
        satisfiedEquations: newSatisfied,
      );

      // Auto-submit if all equations are satisfied and all cells are filled
      if (newPuzzle.isComplete && newSatisfied.length == state.puzzle!.equations.length) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted && state.puzzle?.id == newPuzzle.id) {
            submitQuestion();
          }
        });
      }
    }
  }

  void submitQuestion() {
    if (state.puzzle == null || !state.isComplete) return;

    final isCorrect = state.puzzle!.isAllCorrect;
    final nextIndex = state.currentQuestionIndex + 1;
    final newCorrectCount = isCorrect ? state.correctQuestions + 1 : state.correctQuestions;

    ref.read(sessionStatsProvider.notifier).recordAnswer(
      'cross_numbers',
      isCorrect,
      state.elapsedSeconds,
      state.hintsUsed > 0,
    );

    ref.read(playerPerformanceProvider.notifier).recordAnswer(
      operation: 'cross_numbers',
      isCorrect: isCorrect,
      responseTimeMs: state.elapsedSeconds * 1000,
      hintsUsed: state.hintsUsed,
    );
    ref.read(dynamicDifficultyProvider.notifier).recordAssessment(isCorrect: isCorrect);

    ref.read(dailyChallengeProvider.notifier).incrementProgress('correct', isCorrect ? 1 : 0);
    ref.read(dailyChallengeProvider.notifier).incrementProgress('questions', 1);

    if (nextIndex > state.totalQuestions) {
      ref.read(dailyChallengeProvider.notifier).incrementProgress('cross_numbers', 1);
      state = state.copyWith(
        correctQuestions: newCorrectCount,
        isLevelFinished: true,
      );
    } else {
      state = state.copyWith(
        correctQuestions: newCorrectCount,
        currentQuestionIndex: nextIndex,
      );
      _loadPuzzleAt(nextIndex - 1);
    }
  }

  void incrementTime() {
    state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
  }

  void useHint() {
    if (state.puzzle == null || state.isLevelFinished) return;
    
    final user = ref.read(userSessionProvider);
    if (user == null || user.totalPoints < 50) return;

    final emptyCells = <Point<int>>[];
    for (int r = 0; r < state.puzzle!.gridSize; r++) {
      for (int c = 0; c < state.puzzle!.gridSize; c++) {
        final cell = state.puzzle!.grid[r][c];
        if (cell.isUserEditable && cell.userValue != cell.value) {
          emptyCells.add(Point(r, c));
        }
      }
    }

    if (emptyCells.isEmpty) return;

    final target = emptyCells[Random().nextInt(emptyCells.length)];
    ref.read(userSessionProvider.notifier).addPoints(-50);
    
    final newGrid = List<List<CrossNumbersCell>>.from(
      state.puzzle!.grid.map((row) => List<CrossNumbersCell>.from(row))
    );
    
    newGrid[target.x][target.y] = newGrid[target.x][target.y].copyWith(
      userValue: newGrid[target.x][target.y].value,
      isRevealed: true,
    );

    final newPuzzle = CrossNumbersPuzzle(
      id: state.puzzle!.id,
      gridSize: state.puzzle!.gridSize,
      grid: newGrid,
      equations: state.puzzle!.equations,
      difficulty: state.puzzle!.difficulty,
    );

    state = state.copyWith(
      puzzle: newPuzzle,
      hintsUsed: state.hintsUsed + 1,
      isComplete: newPuzzle.isComplete,
      satisfiedEquations: _getSatisfiedEquations(newPuzzle),
    );
  }
}

final crossNumbersProvider = StateNotifierProvider<CrossNumbersNotifier, CrossNumbersState>((ref) {
  return CrossNumbersNotifier(ref);
});

class CampaignChaptersNotifier extends StateNotifier<List<CampaignChapterState>> {
  CampaignChaptersNotifier() : super([]) {
    _init();
  }

  void _init() {
    state = [
      CampaignChapterState(
        chapterNumber: 1,
        title: 'Introduction',
        storyline: 'Your journey into the world of mathematics begins here.',
        stages: [
          PuzzleStageState(id: 'c1_s1', title: 'Basic Arithmetic', type: 'arithmetic', difficulty: 1, isUnlocked: true),
          PuzzleStageState(id: 'c1_s2', title: 'Logic Foundations', type: 'logic', difficulty: 1, isUnlocked: false),
        ],
        totalStars: 6,
      ),
    ];
  }

  void completeStage(String stageId, int stars, int timeSpent) {
    state = state.map((chapter) {
      final updatedStages = chapter.stages.map((stage) {
        if (stage.id == stageId) {
          return stage.copyWith(stars: max(stage.stars, stars));
        }
        return stage;
      }).toList();

      // Unlock next stage if this one was completed
      for (int i = 0; i < updatedStages.length; i++) {
        if (updatedStages[i].id == stageId) {
          if (i + 1 < updatedStages.length) {
            updatedStages[i + 1] = updatedStages[i + 1].copyWith(isUnlocked: true);
          }
          break;
        }
      }

      int earned = 0;
      for (var s in updatedStages) {
        earned += s.stars;
      }

      return chapter.copyWith(stages: updatedStages, earnedStars: earned);
    }).toList();
  }
}

final campaignChaptersProvider = StateNotifierProvider<CampaignChaptersNotifier, List<CampaignChapterState>>((ref) {
  return CampaignChaptersNotifier();
});

class ChallengeModeNotifier extends StateNotifier<ChallengeModeState> {
  ChallengeModeNotifier() : super(const ChallengeModeState());

  void startChallenge({required String type, required int timeLimit}) {
    state = state.copyWith(
      type: type,
      timeLimit: timeLimit,
      remainingSeconds: timeLimit,
      score: 0,
      isPlaying: true,
    );
  }

  void decrementTime() {
    if (state.remainingSeconds > 0) {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    }
  }

  void addScore(int points) {
    state = state.copyWith(score: state.score + points);
  }

  void endChallenge() {
    state = state.copyWith(isPlaying: false);
  }

  void reset() {
    state = const ChallengeModeState();
  }
}

final challengeModeProvider = StateNotifierProvider<ChallengeModeNotifier, ChallengeModeState>((ref) {
  return ChallengeModeNotifier();
});

final mathRiddleProvider = StateNotifierProvider<MathRiddleNotifier, MathRiddleState>((ref) {
  return MathRiddleNotifier(ref);
});

class MathRiddleNotifier extends StateNotifier<MathRiddleState> {
  final Ref ref;
  MathRiddleNotifier(this.ref) : super(const MathRiddleState());

  void incrementTime() {
    state = state.copyWith(timeSpentSeconds: state.timeSpentSeconds + 1);
  }

  Future<void> loadLevel(int difficulty) async {
    // Cap at 50 levels
    final targetDifficulty = difficulty.clamp(1, 50);
    
    final challenges = await MathRiddleEngine.generateMixedChallenges(7, targetDifficulty);
    state = MathRiddleState(
      level: targetDifficulty,
      allChallenges: challenges,
      totalQuestions: 7,
      questionIndex: 1,
      currentRiddle: challenges[0] is MathRiddle ? challenges[0] as MathRiddle : null,
      currentLogic: challenges[0] is LogicMathChallenge ? challenges[0] as LogicMathChallenge : null,
    );
  }

  // Keep these for backward compatibility or specific modes if needed, but update to 7
  Future<void> loadArithmeticProblem(int difficulty) async {
    final challenges = MathRiddleEngine.generateArithmeticProblems(7, difficulty);
    state = MathRiddleState(
      level: difficulty,
      allChallenges: challenges,
      totalQuestions: 7,
      questionIndex: 1,
      currentRiddle: challenges[0],
    );
  }

  Future<void> loadLogicChallenge(int difficulty) async {
    final challenges = MathRiddleEngine.generateLogicChallengesSync(7, difficulty);
    state = MathRiddleState(
      level: difficulty,
      allChallenges: challenges,
      totalQuestions: 7,
      questionIndex: 1,
      currentLogic: challenges[0],
    );
  }

  void selectAnswer(String answer) {
    state = state.copyWith(selectedAnswer: answer);
  }

  void submitAnswer() {
    final isLogic = state.currentLogic != null;
    final correctAnswer = isLogic ? state.currentLogic!.correctAnswer : state.currentRiddle?.correctAnswer;
    final isCorrect = state.selectedAnswer == correctAnswer;
    
    final newCorrectAnswers = isCorrect ? state.correctAnswers + 1 : state.correctAnswers;
    final newStreak = isCorrect ? state.currentStreak + 1 : 0;
    
    state = state.copyWith(
      isCorrect: isCorrect,
      correctAnswers: newCorrectAnswers,
      currentStreak: newStreak,
    );

    // Provide immediate feedback before moving to next
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        if (state.questionIndex >= state.totalQuestions) {
          state = state.copyWith(isAnswered: true);
        } else {
          nextQuestion();
        }
      }
    });
  }

  void nextQuestion() {
    if (state.questionIndex < state.totalQuestions) {
      final nextIndex = state.questionIndex + 1;
      final nextChallenge = state.allChallenges[nextIndex - 1];
      state = state.copyWith(
        questionIndex: nextIndex,
        currentRiddle: nextChallenge is MathRiddle ? nextChallenge : null,
        currentLogic: nextChallenge is LogicMathChallenge ? nextChallenge : null,
        isAnswered: false,
        isCorrect: false,
        selectedAnswer: null,
        revealedHints: [],
      );
    } else {
      state = state.copyWith(isAnswered: true);
    }
  }

  void skipQuestion(int level) {
    nextQuestion();
  }

  void previousQuestion() {
    if (state.questionIndex > 1) {
      final prevIndex = state.questionIndex - 1;
      final prevChallenge = state.allChallenges[prevIndex - 1];
      state = state.copyWith(
        questionIndex: prevIndex,
        currentRiddle: prevChallenge is MathRiddle ? prevChallenge : null,
        currentLogic: prevChallenge is LogicMathChallenge ? prevChallenge : null,
        isAnswered: false,
        isCorrect: false,
        selectedAnswer: null,
      );
    }
  }

  void reset() {
    state = const MathRiddleState();
  }
}

