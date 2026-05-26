import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;
import '../core/themes/app_themes.dart';
import '../data/models/user_session.dart';
import '../data/models/level_progress.dart';
import '../data/models/crossword_puzzle.dart';
import '../data/models/math_riddle.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/level_progress_repository.dart';
import '../data/repositories/statistics_repository.dart';
import '../data/repositories/database_service.dart';
import '../core/math_engine/crossword_engine.dart';
import '../core/math_engine/math_riddle_engine.dart';
import '../core/math_engine/math_visual_engine.dart';
import '../core/sound_manager.dart';

final userRepositoryProvider = Provider((ref) => UserRepository());
final levelProgressRepositoryProvider = Provider((ref) => LevelProgressRepository());
final statisticsRepositoryProvider = Provider((ref) => StatisticsRepository());
const int hintCostPoints = 0;

final soundManagerProvider = Provider((ref) => SoundManager());

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeType>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppThemeType> {
  ThemeNotifier() : super(AppThemeType.midnight);

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString('app_theme');
    if (themeName != null) {
      state = AppThemeType.values.firstWhere(
        (t) => t.name == themeName,
        orElse: () => AppThemeType.midnight,
      );
    } else {
      // First time users get midnight theme as default
      state = AppThemeType.midnight;
    }
  }

  Future<void> setTheme(AppThemeType theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme', theme.name);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier(ref);
  },
);

class SettingsState {
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool notificationsEnabled;
  final double soundVolume;

  SettingsState({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.notificationsEnabled = true,
    this.soundVolume = 1.0,
  });

  SettingsState copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? notificationsEnabled,
    double? soundVolume,
  }) {
    return SettingsState(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundVolume: soundVolume ?? this.soundVolume,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Ref ref;
  SettingsNotifier(this.ref) : super(SettingsState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final hapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
    state = SettingsState(
      soundEnabled: prefs.getBool('sound_enabled') ?? true,
      hapticsEnabled: hapticsEnabled,
      notificationsEnabled: prefs.getBool('notifications_enabled') ?? true,
      soundVolume: prefs.getDouble('sound_volume') ?? 1.0,
    );
    await HapticManager.setHapticsEnabled(hapticsEnabled);
  }

  Future<void> toggleSound(bool value) async {
    state = state.copyWith(soundEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', value);
    ref.read(soundManagerProvider).setMuted(!value);
  }

  Future<void> toggleHaptics(bool value) async {
    state = state.copyWith(hapticsEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptics_enabled', value);
  }

  Future<void> toggleNotifications(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    // Update notification service
    // Note: This would need to be injected or accessed differently in a real app
  }

  Future<void> setSoundVolume(double volume) async {
    state = state.copyWith(soundVolume: volume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sound_volume', volume);
    ref.read(soundManagerProvider).setVolume(volume);
  }
}

// Enhanced analytics provider for real-time reports
final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier(ref);
});

class AnalyticsState {
  final int sessionCount;
  final double averageSessionTime;
  final Map<String, int> operationUsage;
  final List<Map<String, dynamic>> recentSessions;
  final Map<String, double> performanceTrends;
  final int totalHintsUsed;
  final int totalQuestionsAnswered;
  final DateTime lastUpdated;

  AnalyticsState({
    this.sessionCount = 0,
    this.averageSessionTime = 0.0,
    this.operationUsage = const {},
    this.recentSessions = const [],
    this.performanceTrends = const {},
    this.totalHintsUsed = 0,
    this.totalQuestionsAnswered = 0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  AnalyticsState copyWith({
    int? sessionCount,
    double? averageSessionTime,
    Map<String, int>? operationUsage,
    List<Map<String, dynamic>>? recentSessions,
    Map<String, double>? performanceTrends,
    int? totalHintsUsed,
    int? totalQuestionsAnswered,
    DateTime? lastUpdated,
  }) {
    return AnalyticsState(
      sessionCount: sessionCount ?? this.sessionCount,
      averageSessionTime: averageSessionTime ?? this.averageSessionTime,
      operationUsage: operationUsage ?? this.operationUsage,
      recentSessions: recentSessions ?? this.recentSessions,
      performanceTrends: performanceTrends ?? this.performanceTrends,
      totalHintsUsed: totalHintsUsed ?? this.totalHintsUsed,
      totalQuestionsAnswered: totalQuestionsAnswered ?? this.totalQuestionsAnswered,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final Ref ref;

  AnalyticsNotifier(this.ref) : super(AnalyticsState()) {
    _initializeAnalytics();
  }

  Future<void> _initializeAnalytics() async {
    // Simulate loading analytics data
    await Future.delayed(const Duration(seconds: 1));
    _updateAnalytics();
  }

  void _updateAnalytics() {
    // Get data from various providers
    final progress = ref.read(levelProgressProvider);
    final totalTimeAsync = ref.read(totalTimePlayedProvider);

    final operationCount = <String, int>{};
    int totalSessions = 0;

    for (final operation in progress.keys) {
      final levels = progress[operation] ?? [];
      operationCount[operation] = levels.length;
      totalSessions += levels.where((level) => level.stars > 0).length;
    }

    totalTimeAsync.when(
      data: (time) {
        final avgTime = totalSessions > 0 ? time.toDouble() / totalSessions : 0.0;

        state = state.copyWith(
          sessionCount: totalSessions,
          averageSessionTime: avgTime,
          operationUsage: operationCount,
          lastUpdated: DateTime.now(),
        );
      },
      loading: () {},
      error: (error, stack) {},
    );
  }

  void recordSession(String operation, int duration, int questions, int correct, int hints) {
    final newSession = {
      'operation': operation,
      'duration': duration,
      'questions': questions,
      'correct': correct,
      'accuracy': questions > 0 ? correct / questions : 0.0,
      'hints': hints,
      'timestamp': DateTime.now(),
    };

    final updatedSessions = List<Map<String, dynamic>>.from(state.recentSessions)
      ..add(newSession)
      ..sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));

    // Keep only last 50 sessions
    if (updatedSessions.length > 50) {
      updatedSessions.removeRange(50, updatedSessions.length);
    }

    state = state.copyWith(
      recentSessions: updatedSessions,
      totalQuestionsAnswered: state.totalQuestionsAnswered + questions,
      totalHintsUsed: state.totalHintsUsed + hints,
      lastUpdated: DateTime.now(),
    );

    _updateAnalytics();
  }

  void refreshAnalytics() {
    _updateAnalytics();
  }
}

// Enhanced locale provider with better language management
final localeProvider = StateNotifierProvider<LocaleNotifier, AppLocale>((ref) {
  return LocaleNotifier();
});

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

  static const english = AppLocale(
    code: 'en',
    name: 'English',
    nativeName: 'English',
    flag: '🇺🇸',
  );

  static const swahili = AppLocale(
    code: 'sw',
    name: 'Swahili',
    nativeName: 'Kiswahili',
    flag: '🇹🇿',
  );

  static const supportedLocales = [english, swahili];

  static AppLocale fromCode(String code) {
    return supportedLocales.firstWhere(
      (locale) => locale.code == code,
      orElse: () => english,
    );
  }

  @override
  String toString() => code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLocale && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
}

class LocaleNotifier extends StateNotifier<AppLocale> {
  LocaleNotifier() : super(AppLocale.english);

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString('app_locale');
    if (localeCode != null) {
      state = AppLocale.fromCode(localeCode);
    }
  }

  Future<void> setLocale(AppLocale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', locale.code);

    // Update system locale for proper formatting
    await _updateSystemLocale(locale.code);
  }

  Future<void> toggleLanguage() async {
    final currentIndex = AppLocale.supportedLocales.indexOf(state);
    final nextIndex = (currentIndex + 1) % AppLocale.supportedLocales.length;
    await setLocale(AppLocale.supportedLocales[nextIndex]);
  }

  Future<void> _updateSystemLocale(String localeCode) async {
    // Set the default locale for intl package
    intl.Intl.defaultLocale = localeCode;

    // Additional Swahili-specific setup
    if (localeCode == 'sw') {
      // Swahili cultural considerations:
      // - Uses Western Arabic numerals (no special handling needed)
      // - Right-to-left text is not used (Swahili is LTR)
      // - Date/time formatting follows Western conventions
      // - Currency formatting uses TZS (Tanzanian Shilling) when needed

      // Ensure consistent number formatting
      intl.Intl.defaultLocale = 'sw_TZ';
    } else {
      intl.Intl.defaultLocale = 'en_US';
    }
  }

  bool isSwahili() => state.code == 'sw';
  bool isEnglish() => state.code == 'en';
}

final userSessionProvider =
    StateNotifierProvider<UserSessionNotifier, UserSession?>((ref) {
      return UserSessionNotifier(ref);
    });

class UserSessionNotifier extends StateNotifier<UserSession?> {
  final Ref ref;

  UserSessionNotifier(this.ref) : super(null);

  Future<void> initializeUser() async {
    final repo = ref.read(userRepositoryProvider);
    var user = await repo.getUserSession();
    user ??= await repo.createUserSession(
      name: 'Player',
      avatarShape: 'circle',
      avatarColor: '#00BCD4',
      theme: 'light',
      language: 'en',
      totalPoints: 0,
      loginStreak: 1,
    );

    // Streak Logic
    final now = DateTime.now();
    final lastPlayed = user.lastPlayedAt;

    // Normalize to midnight for fair comparison
    final today = DateTime(now.year, now.month, now.day);
    final lastPlayedDay = DateTime(
      lastPlayed.year,
      lastPlayed.month,
      lastPlayed.day,
    );

    final difference = today.difference(lastPlayedDay).inDays;

    if (difference == 1) {
      user.loginStreak += 1;
      // 7-day streak reward
      if (user.loginStreak % 7 == 0) {
        user.totalPoints += 5000;
        // Optionally trigger a notification/toast here later
      }
    } else if (difference > 1) {
      user.loginStreak = 1;
    }

    user.lastPlayedAt = now;
    await repo.updateUserSession(user);

    state = user;
  }

  Future<void> createUser(String name) async {
    final repo = ref.read(userRepositoryProvider);
    final user = await repo.createUserSession(
      name: name,
      avatarShape: 'circle',
      avatarColor: '#00BCD4',
      theme: 'light',
      language: 'en',
      totalPoints: 0,
      loginStreak: 1,
    );
    state = user;
  }

  Future<void> updateUser({
    String? name,
    String? avatarShape,
    String? avatarColor,
    String? theme,
    String? language,
  }) async {
    if (state == null) return;

    final repo = ref.read(userRepositoryProvider);
    final updatedUser = UserSession(
      name: name ?? state!.name,
      avatarShape: avatarShape ?? state!.avatarShape,
      avatarColor: avatarColor ?? state!.avatarColor,
      theme: theme ?? state!.theme,
      language: language ?? state!.language,
      totalPoints: state!.totalPoints,
      createdAt: state!.createdAt,
      lastPlayedAt: state!.lastPlayedAt,
      unlockedAvatars: state!.unlockedAvatars,
      loginStreak: state!.loginStreak,
    )..id = state!.id;

    await repo.updateUserSession(updatedUser);
    state = updatedUser;
  }

  Future<void> addPoints(int points) async {
    final repo = ref.read(userRepositoryProvider);
    await repo.updatePoints(points);
    if (state != null) {
      state!.totalPoints += points;
      state = state;
    }
  }

  Future<bool> unlockAvatar(String avatarShape, int cost) async {
    if (state == null) return false;
    if (state!.totalPoints < cost) return false;

    final currentAvatars =
        (state!.unlockedAvatars ?? ['circle', 'square', 'star']);
    if (currentAvatars.contains(avatarShape)) return true; // Already unlocked

    final repo = ref.read(userRepositoryProvider);

    state!.totalPoints -= cost;
    currentAvatars.add(avatarShape);
    state!.unlockedAvatars = currentAvatars;

    await repo.updateUserSession(state!);
    state = state;
    return true;
  }
}

final levelProgressProvider =
    StateNotifierProvider<
      LevelProgressNotifier,
      Map<String, List<LevelProgress>>
    >((ref) {
      return LevelProgressNotifier(ref);
    });

class LevelProgressNotifier
    extends StateNotifier<Map<String, List<LevelProgress>>> {
  final Ref ref;

  LevelProgressNotifier(this.ref) : super({});

  Future<void> loadProgress() async {
    final repo = ref.read(levelProgressRepositoryProvider);
    final progress = await repo.getAllProgress();

    final Map<String, List<LevelProgress>> grouped = {};
    for (final p in progress) {
      final key = p.operationId ?? 'unknown';
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(p);
    }

    state = grouped;
  }

  Future<void> refreshProgress() async {
    await loadProgress();
  }
}

final dbInitializedProvider = FutureProvider<bool>((ref) async {
  await DatabaseService.instance;
  return true;
});

final totalStarsProvider = FutureProvider<int>((ref) async {
  final progressMap = ref.watch(levelProgressProvider);
  int total = 0;
  for (final list in progressMap.values) {
    for (final p in list) {
      total += p.stars;
    }
  }
  return total;
});

final completedLevelsProvider = FutureProvider<int>((ref) async {
  final progressMap = ref.watch(levelProgressProvider);
  int total = 0;
  for (final list in progressMap.values) {
    total += list.where((p) => p.stars > 0).length;
  }
  return total;
});

final totalTimePlayedProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(statisticsRepositoryProvider);
  return await repo.getTotalTimePlayed();
});

final campaignUnlockedLevelsProvider =
    StateNotifierProvider<CampaignUnlockedLevelsNotifier, Map<String, int>>((
      ref,
    ) {
      return CampaignUnlockedLevelsNotifier();
    });

class CampaignUnlockedLevelsNotifier extends StateNotifier<Map<String, int>> {
  CampaignUnlockedLevelsNotifier() : super(_loadDefaultUnlockedLevels());

  static Map<String, int> _loadDefaultUnlockedLevels() {
    return {
      'addition': 2,
      'subtraction': 1,
      'multiplication': 1,
      'division': 1,
      'visual': 2,
      'mixed': 1,
    };
  }

  void update(Map<String, int> newState) {
    state = newState;
  }

  void unlockLevel(String operation, int level) {
    state = {...state, operation: level};
  }
}

// Enhanced real-time statistics providers
final overallAccuracyProvider = FutureProvider<double>((ref) async {
  final repo = ref.read(statisticsRepositoryProvider);
  final stats = await repo.getOverallStats();
  if (stats.totalQuestionsAnswered == 0) return 0.0;
  return (stats.correctAnswers / stats.totalQuestionsAnswered) * 100;
});

final averageHintsUsedProvider = FutureProvider<double>((ref) async {
  final repo = ref.read(statisticsRepositoryProvider);
  final stats = await repo.getOverallStats();
  if (stats.totalQuestionsAnswered == 0) return 0.0;
  return stats.totalHintsUsed / stats.totalQuestionsAnswered;
});

final bestStreakProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(statisticsRepositoryProvider);
  final stats = await repo.getOverallStats();
  return stats.bestStreak;
});

final currentStreakProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(statisticsRepositoryProvider);
  final stats = await repo.getOverallStats();
  return stats.currentStreak;
});

// Real-time session statistics
final sessionStatsProvider = StateNotifierProvider<SessionStatsNotifier, SessionStats>((ref) {
  return SessionStatsNotifier();
});

class SessionStats {
  final int questionsAnswered;
  final int correctAnswers;
  final int hintsUsed;
  final int timeSpent;
  final Map<String, int> operationStats;
  final DateTime lastUpdate;

  SessionStats({
    this.questionsAnswered = 0,
    this.correctAnswers = 0,
    this.hintsUsed = 0,
    this.timeSpent = 0,
    Map<String, int>? operationStats,
    DateTime? lastUpdate,
  }) : operationStats = operationStats ?? {},
       lastUpdate = lastUpdate ?? DateTime.now();

  double get accuracy => questionsAnswered > 0 ? (correctAnswers / questionsAnswered) * 100 : 0.0;

  SessionStats copyWith({
    int? questionsAnswered,
    int? correctAnswers,
    int? hintsUsed,
    int? timeSpent,
    Map<String, int>? operationStats,
    DateTime? lastUpdate,
  }) {
    return SessionStats(
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      timeSpent: timeSpent ?? this.timeSpent,
      operationStats: operationStats ?? this.operationStats,
      lastUpdate: lastUpdate ?? DateTime.now(),
    );
  }
}

class SessionStatsNotifier extends StateNotifier<SessionStats> {
  SessionStatsNotifier() : super(SessionStats()) {
    _startPeriodicReset();
  }

  void recordAnswer(String operation, bool isCorrect, int timeSpent, bool usedHint) {
    final newOperationStats = Map<String, int>.from(state.operationStats);
    newOperationStats[operation] = (newOperationStats[operation] ?? 0) + 1;

    state = state.copyWith(
      questionsAnswered: state.questionsAnswered + 1,
      correctAnswers: state.correctAnswers + (isCorrect ? 1 : 0),
      hintsUsed: state.hintsUsed + (usedHint ? 1 : 0),
      timeSpent: state.timeSpent + timeSpent,
      operationStats: newOperationStats,
    );
  }

  void resetSession() {
    state = SessionStats();
  }

  void _startPeriodicReset() {
    // Reset session stats daily at midnight
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);

    Future.delayed(timeUntilMidnight, () {
      resetSession();
      _startPeriodicReset(); // Restart the cycle
    });
  }
}

// Real-time performance trends
final performanceTrendsProvider = StateNotifierProvider<PerformanceTrendsNotifier, PerformanceTrends>((ref) {
  return PerformanceTrendsNotifier();
});

class PerformanceTrends {
  final List<double> accuracyHistory;
  final List<int> timeHistory;
  final List<int> streakHistory;
  final DateTime lastUpdated;

  PerformanceTrends({
    List<double>? accuracyHistory,
    List<int>? timeHistory,
    List<int>? streakHistory,
    DateTime? lastUpdated,
  }) : accuracyHistory = accuracyHistory ?? [],
       timeHistory = timeHistory ?? [],
       streakHistory = streakHistory ?? [],
       lastUpdated = lastUpdated ?? DateTime.now();

  double get averageAccuracy => accuracyHistory.isEmpty ? 0.0 : accuracyHistory.reduce((a, b) => a + b) / accuracyHistory.length;
  double get averageTime => timeHistory.isEmpty ? 0.0 : timeHistory.reduce((a, b) => a + b) / timeHistory.length;
  int get bestStreak => streakHistory.isEmpty ? 0 : streakHistory.reduce((a, b) => a > b ? a : b);

  PerformanceTrends copyWith({
    List<double>? accuracyHistory,
    List<int>? timeHistory,
    List<int>? streakHistory,
    DateTime? lastUpdated,
  }) {
    return PerformanceTrends(
      accuracyHistory: accuracyHistory ?? this.accuracyHistory,
      timeHistory: timeHistory ?? this.timeHistory,
      streakHistory: streakHistory ?? this.streakHistory,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }
}

class PerformanceTrendsNotifier extends StateNotifier<PerformanceTrends> {
  PerformanceTrendsNotifier() : super(PerformanceTrends()) {
    _loadHistoricalData();
  }

  void addDataPoint(double accuracy, int avgTime, int streak) {
    const maxHistorySize = 50; // Keep last 50 data points

    final newAccuracyHistory = List<double>.from(state.accuracyHistory)..add(accuracy);
    final newTimeHistory = List<int>.from(state.timeHistory)..add(avgTime);
    final newStreakHistory = List<int>.from(state.streakHistory)..add(streak);

    // Keep only the most recent data points
    if (newAccuracyHistory.length > maxHistorySize) {
      newAccuracyHistory.removeAt(0);
      newTimeHistory.removeAt(0);
      newStreakHistory.removeAt(0);
    }

    state = state.copyWith(
      accuracyHistory: newAccuracyHistory,
      timeHistory: newTimeHistory,
      streakHistory: newStreakHistory,
    );

    _saveHistoricalData();
  }

  Future<void> _loadHistoricalData() async {
    // Load historical data from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final accuracyData = prefs.getStringList('performance_accuracy_history') ?? [];
    final timeData = prefs.getStringList('performance_time_history') ?? [];
    final streakData = prefs.getStringList('performance_streak_history') ?? [];

    try {
      state = PerformanceTrends(
        accuracyHistory: accuracyData.map(double.parse).toList(),
        timeHistory: timeData.map(int.parse).toList(),
        streakHistory: streakData.map(int.parse).toList(),
      );
    } catch (e) {
      // If parsing fails, start with empty data
      state = PerformanceTrends();
    }
  }

  Future<void> _saveHistoricalData() async {
    // Save historical data to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'performance_accuracy_history',
      state.accuracyHistory.map((e) => e.toString()).toList(),
    );
    await prefs.setStringList(
      'performance_time_history',
      state.timeHistory.map((e) => e.toString()).toList(),
    );
    await prefs.setStringList(
      'performance_streak_history',
      state.streakHistory.map((e) => e.toString()).toList(),
    );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int rewardPoints;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progress;
  final int maxProgress;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.rewardPoints,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0,
    required this.maxProgress,
  });

  double get progressRatio => (progress / maxProgress).clamp(0.0, 1.0);
}

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String type;
  final int targetValue;
  final int currentValue;
  final bool isCompleted;
  final int rewardPoints;
  final DateTime expiresAt;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    this.currentValue = 0,
    this.isCompleted = false,
    required this.rewardPoints,
    required this.expiresAt,
  });

  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);
}

final achievementsProvider =
    StateNotifierProvider<AchievementsNotifier, Map<String, Achievement>>((ref) {
      return AchievementsNotifier();
    });

final dailyChallengeProvider =
    StateNotifierProvider<DailyChallengeNotifier, List<DailyChallenge>>((ref) {
      return DailyChallengeNotifier();
    });

class AchievementsNotifier extends StateNotifier<Map<String, Achievement>> {
  AchievementsNotifier() : super(_generateDefaultAchievements());

  static Map<String, Achievement> _generateDefaultAchievements() {
    return {
      'first_win': Achievement(
        id: 'first_win',
        title: 'First Victory',
        description: 'Complete your first game',
        icon: '🏆',
        rewardPoints: 100,
        maxProgress: 1,
      ),
      'campaign_master': Achievement(
        id: 'campaign_master',
        title: 'Campaign Master',
        description: 'Complete all campaign levels',
        icon: '🌟',
        rewardPoints: 1000,
        maxProgress: 30,
      ),
      'speed_demon': Achievement(
        id: 'speed_demon',
        title: 'Speed Demon',
        description: 'Answer 100 questions in under 10 seconds each',
        icon: '⚡',
        rewardPoints: 500,
        maxProgress: 100,
      ),
      'math_genius': Achievement(
        id: 'math_genius',
        title: 'Math Genius',
        description: 'Achieve 100% accuracy in 10 games',
        icon: '🧠',
        rewardPoints: 750,
        maxProgress: 10,
      ),
    };
  }

  void updateProgress(String id, int newProgress) {
    if (state.containsKey(id)) {
      final achievement = state[id]!;
      final updated = Achievement(
        id: achievement.id,
        title: achievement.title,
        description: achievement.description,
        icon: achievement.icon,
        rewardPoints: achievement.rewardPoints,
        isUnlocked: newProgress >= achievement.maxProgress,
        unlockedAt: newProgress >= achievement.maxProgress ? DateTime.now() : null,
        progress: newProgress.clamp(0, achievement.maxProgress),
        maxProgress: achievement.maxProgress,
      );
      state = {...state, id: updated};
    }
  }

  void unlock(String id) {
    updateProgress(id, state[id]?.maxProgress ?? 0);
  }
}

class DailyChallengeNotifier extends StateNotifier<List<DailyChallenge>> {
  DailyChallengeNotifier() : super(_generateDailyChallenges());

  static List<DailyChallenge> _generateDailyChallenges() {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final allChallenges = [
      DailyChallenge(
        id: 'speed_demon',
        title: 'Speed Demon',
        description: 'Answer 20 questions in under 60 seconds',
        type: 'speed',
        targetValue: 20,
        rewardPoints: 100,
        expiresAt: endOfDay,
      ),
      DailyChallenge(
        id: 'perfect_score',
        title: 'Perfect Score',
        description: 'Get 100% accuracy in any mode',
        type: 'accuracy',
        targetValue: 10,
        rewardPoints: 150,
        expiresAt: endOfDay,
      ),
      DailyChallenge(
        id: 'math_master',
        title: 'Math Master',
        description: 'Complete 50 arithmetic questions',
        type: 'questions',
        targetValue: 50,
        rewardPoints: 200,
        expiresAt: endOfDay,
      ),
      DailyChallenge(
        id: 'streak_10',
        title: 'Unstoppable!',
        description: 'Get 10 correct answers in a row',
        type: 'streak',
        targetValue: 10,
        rewardPoints: 120,
        expiresAt: endOfDay,
      ),
      DailyChallenge(
        id: 'campaign_grinder',
        title: 'Campaign Grinder',
        description: 'Earn 9 stars in Campaign Mode',
        type: 'stars',
        targetValue: 9,
        rewardPoints: 150,
        expiresAt: endOfDay,
      ),
      DailyChallenge(
        id: 'duel_master',
        title: 'Duel Master',
        description: 'Win 3 Duel games against the AI',
        type: 'wins',
        targetValue: 3,
        rewardPoints: 180,
        expiresAt: endOfDay,
      ),
      DailyChallenge(
        id: 'endless_survivor',
        title: 'Endless Survivor',
        description: 'Reach a score of 200 in Endless Mode',
        type: 'score',
        targetValue: 200,
        rewardPoints: 250,
        expiresAt: endOfDay,
      ),
      DailyChallenge(
        id: 'division_expert',
        title: 'Division Expert',
        description: 'Answer 15 division questions correctly',
        type: 'division',
        targetValue: 15,
        rewardPoints: 130,
        expiresAt: endOfDay,
      ),
    ];

    // Randomly select 4 challenges for the day
    allChallenges.shuffle();
    return allChallenges.take(4).toList();
  }

  void incrementProgress(String type, int amount) {
    state = state.map((challenge) {
      if (challenge.type == type && !challenge.isCompleted) {
        final newValue = challenge.currentValue + amount;
        return DailyChallenge(
          id: challenge.id,
          title: challenge.title,
          description: challenge.description,
          type: challenge.type,
          targetValue: challenge.targetValue,
          currentValue: newValue > challenge.targetValue
              ? challenge.targetValue
              : newValue,
          isCompleted: newValue >= challenge.targetValue,
          rewardPoints: challenge.rewardPoints,
          expiresAt: challenge.expiresAt,
        );
      }
      return challenge;
    }).toList();
  }

  void updateProgressMax(String type, int value) {
    state = state.map((challenge) {
      if (challenge.type == type &&
          !challenge.isCompleted &&
          value > challenge.currentValue) {
        return DailyChallenge(
          id: challenge.id,
          title: challenge.title,
          description: challenge.description,
          type: challenge.type,
          targetValue: challenge.targetValue,
          currentValue: value > challenge.targetValue
              ? challenge.targetValue
              : value,
          isCompleted: value >= challenge.targetValue,
          rewardPoints: challenge.rewardPoints,
          expiresAt: challenge.expiresAt,
        );
      }
      return challenge;
    }).toList();
  }

  void updateChallenge(String id, int newValue) {
    state = state.map((challenge) {
      if (challenge.id == id) {
        final isCompleted = newValue >= challenge.targetValue;
        return DailyChallenge(
          id: challenge.id,
          title: challenge.title,
          description: challenge.description,
          type: challenge.type,
          targetValue: challenge.targetValue,
          currentValue: newValue,
          isCompleted: isCompleted,
          rewardPoints: challenge.rewardPoints,
          expiresAt: challenge.expiresAt,
        );
      }
      return challenge;
    }).toList();
  }

  void checkAndResetChallenges() {
    final now = DateTime.now();
    if (now.isAfter(state.first.expiresAt)) {
      state = _generateDailyChallenges();
    }
  }

  bool claimReward(String id) {
    final challenge = state.firstWhere(
      (c) => c.id == id,
      orElse: () => throw Exception('Challenge not found'),
    );
    if (challenge.isCompleted) {
      state = state.where((c) => c.id != id).toList();
      return true;
    }
    return false;
  }
}

final crosswordPuzzleProvider =
    StateNotifierProvider<CrosswordPuzzleNotifier, CrosswordPuzzleState>((ref) {
      return CrosswordPuzzleNotifier(ref);
    });

final mathEquationPuzzleProvider =
    StateNotifierProvider<MathEquationPuzzleNotifier, MathEquationPuzzleState>((ref) {
      return MathEquationPuzzleNotifier(ref);
    });

class CrosswordCellData {
  final String? userLetter;
  final bool isSelected;
  final bool isCorrect;
  final bool isRevealed;

  CrosswordCellData({
    this.userLetter,
    this.isSelected = false,
    this.isCorrect = false,
    this.isRevealed = false,
  });

  CrosswordCellData copyWith({
    String? userLetter,
    bool? isSelected,
    bool? isCorrect,
    bool? isRevealed,
  }) {
    return CrosswordCellData(
      userLetter: userLetter ?? this.userLetter,
      isSelected: isSelected ?? this.isSelected,
      isCorrect: isCorrect ?? this.isCorrect,
      isRevealed: isRevealed ?? this.isRevealed,
    );
  }
}

class CrosswordPuzzleState {
  final CrosswordPuzzle? puzzle;
  final List<List<CrosswordCellData>> grid;
  final String? selectedClueId;
  final int hintsUsed;
  final List<String> revealedHints;
  final int elapsedSeconds;
  final bool isComplete;
  final int stars;

  CrosswordPuzzleState({
    this.puzzle,
    List<List<CrosswordCellData>>? grid,
    this.selectedClueId,
    this.hintsUsed = 0,
    this.revealedHints = const [],
    this.elapsedSeconds = 0,
    this.isComplete = false,
    this.stars = 0,
  }) : grid = grid ?? [];

  CrosswordPuzzleState copyWith({
    CrosswordPuzzle? puzzle,
    List<List<CrosswordCellData>>? grid,
    String? selectedClueId,
    int? hintsUsed,
    List<String>? revealedHints,
    int? elapsedSeconds,
    bool? isComplete,
    int? stars,
  }) {
    return CrosswordPuzzleState(
      puzzle: puzzle ?? this.puzzle,
      grid: grid ?? this.grid,
      selectedClueId: selectedClueId ?? this.selectedClueId,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      revealedHints: revealedHints ?? this.revealedHints,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isComplete: isComplete ?? this.isComplete,
      stars: stars ?? this.stars,
    );
  }
}

class CrosswordPuzzleNotifier extends StateNotifier<CrosswordPuzzleState> {
  final Ref ref;
  CrosswordPuzzleNotifier(this.ref) : super(CrosswordPuzzleState());

  void loadPuzzle({
    String theme = 'animals',
    int gridSize = 11,
    int difficulty = 1,
  }) {
    final puzzle = CrosswordEngine.generatePuzzle(
      theme: theme,
      difficulty: difficulty,
      questionCount: 5 + (difficulty ~/ 5),
    );

    final grid = List.generate(
      gridSize,
      (r) => List.generate(gridSize, (c) => CrosswordCellData()),
    );

    state = CrosswordPuzzleState(puzzle: puzzle, grid: grid);
  }

  void selectCell(int row, int col) {
    if (state.puzzle == null) return;
    if (state.puzzle!.isBlocked[row][col]) return;

    final newGrid = state.grid
        .map((r) => r.map((cell) => cell.copyWith(isSelected: false)).toList())
        .toList();
    newGrid[row][col] = newGrid[row][col].copyWith(isSelected: true);

    state = state.copyWith(grid: newGrid, selectedClueId: 'cell_${row}_$col');
  }

  void enterLetter(String letter, int row, int col) {
    if (state.puzzle == null) return;

    final newGrid = state.grid.map((r) => r.toList()).toList();
    final correctLetter = state.puzzle!.grid[row][col];

    if (correctLetter.isNotEmpty) {
      final isCorrect = letter.toUpperCase() == correctLetter.toUpperCase();
      newGrid[row][col] = newGrid[row][col].copyWith(
        userLetter: letter.toUpperCase(),
        isCorrect: isCorrect,
      );
    }

    state = state.copyWith(grid: newGrid);
    _checkCompletion();
  }

  void revealLetter() {
    if (state.puzzle == null) return;

    // Check if user has enough points
    final user = ref.read(userSessionProvider);
    if (user == null || user.totalPoints < hintCostPoints) return;

    final newGrid = state.grid.map((r) => r.toList()).toList();
    int revealed = 0;

    for (int r = 0; r < newGrid.length; r++) {
      for (int c = 0; c < newGrid[r].length; c++) {
        if (!state.puzzle!.isBlocked[r][c] &&
            newGrid[r][c].userLetter != state.puzzle!.grid[r][c]) {
          newGrid[r][c] = newGrid[r][c].copyWith(
            userLetter: state.puzzle!.grid[r][c],
            isCorrect: true,
            isRevealed: true,
          );
          revealed++;
        }
      }
    }

    if (revealed > 0) {
      // Deduct points
      ref.read(userSessionProvider.notifier).addPoints(-hintCostPoints);
      ref.read(soundManagerProvider).playEffect('hint');

      state = state.copyWith(
        grid: newGrid,
        hintsUsed: state.hintsUsed + revealed,
        revealedHints: [...state.revealedHints, 'Word revealed'],
      );
    }

    _checkCompletion();
  }

  void _checkCompletion() {
    if (state.puzzle == null) return;

    bool complete = true;
    for (int r = 0; r < state.grid.length; r++) {
      for (int c = 0; c < state.grid[r].length; c++) {
        if (!state.puzzle!.isBlocked[r][c]) {
          if (!state.grid[r][c].isCorrect && !state.grid[r][c].isRevealed) {
            complete = false;
          }
        }
      }
    }

    if (complete) {
      final stars = state.puzzle!.calculateStars(
        state.elapsedSeconds,
        state.hintsUsed,
      );
      state = state.copyWith(isComplete: true, stars: stars);
    }
  }

  void incrementTime() {
    if (!state.isComplete) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    }
  }

  void reset() {
    if (state.puzzle != null) {
      loadPuzzle(theme: state.puzzle!.theme, gridSize: state.puzzle!.gridSize);
    }
  }
}

final mathRiddleProvider =
    StateNotifierProvider<MathRiddleNotifier, MathRiddleState>((ref) {
      return MathRiddleNotifier(ref);
    });

class MathRiddleState {
  final MathRiddle? currentRiddle;
  final NumberSequence? currentSequence;
  final LogicMathChallenge? currentLogic;
  final String? selectedAnswer;
  final List<String> revealedHints;
  final int hintsUsed;
  final int elapsedSeconds;
  final bool isCorrect;
  final bool isAnswered;
  final int stars;

  MathRiddleState({
    this.currentRiddle,
    this.currentSequence,
    this.currentLogic,
    this.selectedAnswer,
    this.revealedHints = const [],
    this.hintsUsed = 0,
    this.elapsedSeconds = 0,
    this.isCorrect = false,
    this.isAnswered = false,
    this.stars = 0,
  });

  MathRiddleState copyWith({
    MathRiddle? currentRiddle,
    NumberSequence? currentSequence,
    LogicMathChallenge? currentLogic,
    String? selectedAnswer,
    List<String>? revealedHints,
    int? hintsUsed,
    int? elapsedSeconds,
    bool? isCorrect,
    bool? isAnswered,
    int? stars,
  }) {
    return MathRiddleState(
      currentRiddle: currentRiddle ?? this.currentRiddle,
      currentSequence: currentSequence ?? this.currentSequence,
      currentLogic: currentLogic ?? this.currentLogic,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      revealedHints: revealedHints ?? this.revealedHints,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isCorrect: isCorrect ?? this.isCorrect,
      isAnswered: isAnswered ?? this.isAnswered,
      stars: stars ?? this.stars,
    );
  }
}

class MathRiddleNotifier extends StateNotifier<MathRiddleState> {
  final Ref ref;
  MathRiddleNotifier(this.ref) : super(MathRiddleState());

  void loadArithmeticProblem(int difficulty) {
    final riddle = MathRiddleEngine.generateArithmeticProblem(difficulty);
    state = MathRiddleState(currentRiddle: riddle);
  }

  void loadWordProblem(int difficulty) {
    final riddle = MathRiddleEngine.generateWordProblem(difficulty);
    state = MathRiddleState(currentRiddle: riddle);
  }

  void loadNumberSequence(int difficulty) {
    final sequence = MathRiddleEngine.generateNumberSequence(difficulty);
    state = MathRiddleState(currentSequence: sequence);
  }

  Future<void> loadLogicChallenge(int difficulty) async {
    // Generate 20+ logic challenges per level for higher difficulty
    final questionCount = difficulty >= 3 ? 25 : difficulty >= 2 ? 22 : 20;
    final challenges = <LogicMathChallenge>[];

    for (int i = 0; i < questionCount; i++) {
      if (difficulty >= 2) {
        final logic = await MathVisualEngine.generateVisualLogicChallenge(difficulty);
        challenges.add(logic);
      } else {
        final logic = MathRiddleEngine.generateLogicChallenge(difficulty);
        challenges.add(logic);
      }
    }

    // Use the first challenge initially, store all for progression
    if (challenges.isNotEmpty) {
      state = MathRiddleState(
        currentLogic: challenges[0],
        // Store all challenges for level progression
      );
    }
  }

  void selectAnswer(String answer) {
    if (state.isAnswered) return;
    state = state.copyWith(selectedAnswer: answer);
  }

  void submitAnswer() {
    if (state.selectedAnswer == null || state.isAnswered) return;

    bool isCorrect;
    String correctAnswer;
    int stars = 0;

    if (state.currentRiddle != null) {
      correctAnswer = state.currentRiddle!.correctAnswer;
      isCorrect = state.selectedAnswer == correctAnswer;
    } else if (state.currentSequence != null) {
      correctAnswer = state.currentSequence!.correctAnswer;
      isCorrect = state.selectedAnswer == correctAnswer;
    } else if (state.currentLogic != null) {
      correctAnswer = state.currentLogic!.correctAnswer;
      isCorrect = state.selectedAnswer == correctAnswer;
    } else {
      return;
    }

    if (isCorrect) {
      if (state.currentRiddle != null) {
        stars = state.currentRiddle!.calculateStars(
          state.elapsedSeconds,
          state.hintsUsed,
          isCorrect,
        );
      } else {
        // Default star calculation for other types
        if (state.elapsedSeconds < 30) {
          stars = 3;
        } else if (state.elapsedSeconds < 60) {
          stars = 2;
        } else {
          stars = 1;
        }
        if (state.hintsUsed > 0) stars = (stars - 1).clamp(1, 3);
      }
    }

    state = state.copyWith(
      isCorrect: isCorrect,
      isAnswered: true,
      stars: stars,
    );
  }

  void revealHint() {
    if (state.isAnswered) return;

    // Check if user has enough points
    final user = ref.read(userSessionProvider);
    if (user == null || user.totalPoints < hintCostPoints) return;

    List<String> availableHints = [];
    int maxHints = 0;

    if (state.currentRiddle != null) {
      availableHints = state.currentRiddle!.progressiveHints;
      maxHints = state.currentRiddle!.hintCount;
    } else if (state.currentSequence != null) {
      availableHints = state.currentSequence!.progressiveHints;
      maxHints = state.currentSequence!.progressiveHints.length;
    } else if (state.currentLogic != null) {
      availableHints = state.currentLogic!.progressiveHints;
      maxHints = state.currentLogic!.progressiveHints.length;
    }

    if (state.revealedHints.length < maxHints) {
      // Deduct points
      ref.read(userSessionProvider.notifier).addPoints(-hintCostPoints);
      ref.read(soundManagerProvider).playEffect('hint');

      final nextHint = availableHints[state.revealedHints.length];
      state = state.copyWith(
        revealedHints: [...state.revealedHints, nextHint],
        hintsUsed: state.hintsUsed + 1,
      );
    }
  }

  void incrementTime() {
    if (!state.isAnswered) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    }
  }

  void reset() {
    state = MathRiddleState();
  }
}

final puzzleHintsProvider = StateNotifierProvider<PuzzleHintsNotifier, int>((
  ref,
) {
  return PuzzleHintsNotifier();
});

class PuzzleHintsNotifier extends StateNotifier<int> {
  PuzzleHintsNotifier() : super(5);

  bool useHint(int cost) {
    if (state >= cost) {
      state = state - cost;
      return true;
    }
    return false;
  }

  void addHints(int amount) {
    state = state + amount;
  }

  void reset() {
    state = 5;
  }
}

final puzzleStatsProvider =
    StateNotifierProvider<PuzzleStatsNotifier, PuzzleStats>((ref) {
      return PuzzleStatsNotifier();
    });

class PuzzleStats {
  final int totalPuzzlesSolved;
  final int totalCrosswordsSolved;
  final int totalMathRiddlesSolved;
  final int averageTimeSeconds;
  final int bestTimeSeconds;
  final int totalHintsUsed;
  final int totalStarsEarned;
  final int currentStreak;
  final int bestStreak;

  PuzzleStats({
    this.totalPuzzlesSolved = 0,
    this.totalCrosswordsSolved = 0,
    this.totalMathRiddlesSolved = 0,
    this.averageTimeSeconds = 0,
    this.bestTimeSeconds = 0,
    this.totalHintsUsed = 0,
    this.totalStarsEarned = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
  });

  PuzzleStats copyWith({
    int? totalPuzzlesSolved,
    int? totalCrosswordsSolved,
    int? totalMathRiddlesSolved,
    int? averageTimeSeconds,
    int? bestTimeSeconds,
    int? totalHintsUsed,
    int? totalStarsEarned,
    int? currentStreak,
    int? bestStreak,
  }) {
    return PuzzleStats(
      totalPuzzlesSolved: totalPuzzlesSolved ?? this.totalPuzzlesSolved,
      totalCrosswordsSolved:
          totalCrosswordsSolved ?? this.totalCrosswordsSolved,
      totalMathRiddlesSolved:
          totalMathRiddlesSolved ?? this.totalMathRiddlesSolved,
      averageTimeSeconds: averageTimeSeconds ?? this.averageTimeSeconds,
      bestTimeSeconds: bestTimeSeconds ?? this.bestTimeSeconds,
      totalHintsUsed: totalHintsUsed ?? this.totalHintsUsed,
      totalStarsEarned: totalStarsEarned ?? this.totalStarsEarned,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
    );
  }
}

class PuzzleStatsNotifier extends StateNotifier<PuzzleStats> {
  PuzzleStatsNotifier() : super(PuzzleStats());

  void recordPuzzleSolved({
    required String puzzleType,
    required int timeSeconds,
    required int hintsUsed,
    required int stars,
  }) {
    final newAverage =
        ((state.averageTimeSeconds * state.totalPuzzlesSolved) + timeSeconds) ~/
        (state.totalPuzzlesSolved + 1);

    int crosswords = state.totalCrosswordsSolved;
    int mathRiddles = state.totalMathRiddlesSolved;

    if (puzzleType == 'crossword') {
      crosswords++;
    } else {
      mathRiddles++;
    }

    state = state.copyWith(
      totalPuzzlesSolved: state.totalPuzzlesSolved + 1,
      totalCrosswordsSolved: crosswords,
      totalMathRiddlesSolved: mathRiddles,
      averageTimeSeconds: newAverage,
      bestTimeSeconds:
          timeSeconds < state.bestTimeSeconds || state.bestTimeSeconds == 0
          ? timeSeconds
          : state.bestTimeSeconds,
      totalHintsUsed: state.totalHintsUsed + hintsUsed,
      totalStarsEarned: state.totalStarsEarned + stars,
    );
  }

  void reset() {
    state = PuzzleStats();
  }
}

class MathEquationPuzzleState {
  final MathEquationPuzzle? puzzle;
  final bool isLoading;

  MathEquationPuzzleState({
    this.puzzle,
    this.isLoading = false,
  });

  MathEquationPuzzleState copyWith({
    MathEquationPuzzle? puzzle,
    bool? isLoading,
  }) {
    return MathEquationPuzzleState(
      puzzle: puzzle ?? this.puzzle,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MathEquationPuzzleNotifier extends StateNotifier<MathEquationPuzzleState> {
  final Ref ref;

  MathEquationPuzzleNotifier(this.ref) : super(MathEquationPuzzleState());

  Future<void> loadPuzzle({
    required String theme,
    required int difficulty,
  }) async {
    state = state.copyWith(isLoading: true);

    // Simulate loading (replace with actual engine call)
    await Future.delayed(const Duration(milliseconds: 500));

    // For now, create a simple puzzle
    final puzzle = MathEquationPuzzle(
      theme: theme,
      difficulty: difficulty,
      equations: [
        MathEquation(
          equation: '5 + 3 = 8',
          correctAnswer: 5,
          hints: ['First number', '5 + 3 = 8'],
          missingIndex: 0,
        ),
      ],
    );

    state = state.copyWith(puzzle: puzzle, isLoading: false);
  }
}

final campaignChaptersProvider =
    StateNotifierProvider<CampaignChaptersNotifier, List<CampaignChapterState>>(
      (ref) {
        return CampaignChaptersNotifier();
      },
    );

class CampaignChapterState {
  final int chapterNumber;
  final String title;
  final String description;
  final String storyline;
  final List<PuzzleStageState> stages;
  final int requiredStars;
  final bool isUnlocked;
  final bool isComplete;

  CampaignChapterState({
    required this.chapterNumber,
    required this.title,
    required this.description,
    required this.storyline,
    required this.stages,
    required this.requiredStars,
    this.isUnlocked = false,
    this.isComplete = false,
  });

  int get earnedStars => stages.fold(0, (sum, s) => sum + s.stars);
  int get totalStars => stages.length * 3;
  double get completionPercentage =>
      totalStars > 0 ? earnedStars / totalStars : 0.0;
}

class PuzzleStageState {
  final String id;
  final String title;
  final String type;
  final int difficulty;
  final int stars;
  final bool isUnlocked;
  final bool isCompleted;
  final int bestTime;

  PuzzleStageState({
    required this.id,
    required this.title,
    required this.type,
    required this.difficulty,
    this.stars = 0,
    this.isUnlocked = false,
    this.isCompleted = false,
    this.bestTime = 0,
  });
}

class CampaignChaptersNotifier
    extends StateNotifier<List<CampaignChapterState>> {
  CampaignChaptersNotifier() : super(_generateDefaultChapters());

  static List<CampaignChapterState> _generateDefaultChapters() {
    return [
        CampaignChapterState(
          chapterNumber: 1,
          title: 'Addition Mastery',
          description: 'Master the art of addition',
          storyline:
              'Start your mathematical journey with addition! Build a strong foundation through progressive challenges.',
          stages: [
            PuzzleStageState(
              id: '1_1',
              title: 'Single Digit Addition',
              type: 'arithmetic',
              difficulty: 1,
              isUnlocked: true,
            ),
            PuzzleStageState(
              id: '1_2',
              title: 'Two Digit Addition',
              type: 'arithmetic',
              difficulty: 1,
              isUnlocked: false,
            ),
            PuzzleStageState(
              id: '1_3',
              title: 'Three Digit Addition',
              type: 'arithmetic',
              difficulty: 2,
              isUnlocked: false,
            ),
            PuzzleStageState(
              id: '1_4',
              title: 'Addition with Carrying',
              type: 'arithmetic',
              difficulty: 2,
              isUnlocked: false,
            ),
            PuzzleStageState(
              id: '1_5',
              title: 'Advanced Addition',
              type: 'arithmetic',
              difficulty: 3,
              isUnlocked: false,
            ),
          ],
          requiredStars: 0,
          isUnlocked: true,
        ),
        CampaignChapterState(
          chapterNumber: 2,
          title: 'Subtraction Mastery',
          description: 'Conquer subtraction challenges',
          storyline:
              'Now that you\'ve mastered addition, dive into subtraction! Learn to take away and find differences.',
          stages: [
            PuzzleStageState(
              id: '2_1',
              title: 'Single Digit Subtraction',
              type: 'arithmetic',
              difficulty: 1,
              isUnlocked: false,
            ),
            PuzzleStageState(
              id: '2_2',
              title: 'Two Digit Subtraction',
              type: 'arithmetic',
              difficulty: 1,
              isUnlocked: false,
            ),
            PuzzleStageState(
              id: '2_3',
              title: 'Three Digit Subtraction',
              type: 'arithmetic',
              difficulty: 2,
              isUnlocked: false,
            ),
            PuzzleStageState(
              id: '2_4',
              title: 'Subtraction with Borrowing',
              type: 'arithmetic',
              difficulty: 2,
              isUnlocked: false,
            ),
            PuzzleStageState(
              id: '2_5',
              title: 'Advanced Subtraction',
              type: 'arithmetic',
              difficulty: 3,
              isUnlocked: false,
            ),
            PuzzleStageState(
              id: '2_6',
              title: 'Word Problems - Subtraction',
              type: 'arithmetic',
              difficulty: 2,
              isUnlocked: false,
            ),
          ],
          requiredStars: 15,
          isUnlocked: false,
        ),
        CampaignChapterState(
          chapterNumber: 3,
          title: 'Multiplication Mastery',
          description: 'Multiply your skills',
          storyline:
              'Multiplication awaits! Discover patterns and shortcuts in repeated addition.',
          stages: [
            PuzzleStageState(
              id: '3_1',
              title: 'Times Tables 1-5',
              type: 'arithmetic',
              difficulty: 1,
              isUnlocked: false,
            ),
            PuzzleStageState(
              id: '3_2',
              title: 'Times Tables 6-10',
              type: 'arithmetic',
              difficulty: 2,
              isUnlocked: false,
            ),
            PuzzleStageState(
              id: '3_3',
              title: 'Two Digit Multiplication',
              type: 'arithmetic',
              difficulty: 2,
              isUnlocked: false,
            ),
            PuzzleStageState(
              id: '3_4',
              title: 'Three Digit Multiplication',
              type: 'arithmetic',
              difficulty: 3,
              isUnlocked: false,
            ),
            PuzzleStageState(
              id: '3_5',
              title: 'Multiplication Word Problems',
              type: 'arithmetic',
              difficulty: 3,
              isUnlocked: false,
            ),
            PuzzleStageState(
              id: '3_6',
              title: 'Advanced Multiplication',
              type: 'arithmetic',
              difficulty: 3,
              isUnlocked: false,
            ),
            PuzzleStageState(
              id: '3_7',
              title: 'Multiplication Patterns',
              type: 'arithmetic',
              difficulty: 3,
              isUnlocked: false,
            ),
          ],
          requiredStars: 24,
          isUnlocked: false,
        ),
        CampaignChapterState(
          chapterNumber: 4,
          title: 'Division Mastery',
          description: 'Divide and conquer',
          storyline:
              'The final frontier: division! Learn to share equally and find quotients.',
          stages: [
            PuzzleStageState(
              id: '4_1',
              title: 'Division Basics',
              type: 'arithmetic',
              difficulty: 1,
              isUnlocked: false,
            ),
            PuzzleStageState(
              id: '4_2',
              title: 'Division with Remainders',
              type: 'arithmetic',
              difficulty: 2,
              isUnlocked: false,
            ),
            PuzzleStageState(
              id: '4_3',
              title: 'Two Digit Division',
              type: 'arithmetic',
              difficulty: 2,
              isUnlocked: false,
            ),
            PuzzleStageState(
              id: '4_4',
              title: 'Three Digit Division',
              type: 'arithmetic',
              difficulty: 3,
              isUnlocked: false,
            ),
            PuzzleStageState(
              id: '4_5',
              title: 'Division Word Problems',
              type: 'arithmetic',
              difficulty: 3,
              isUnlocked: false,
            ),
            PuzzleStageState(
              id: '4_6',
              title: 'Long Division',
              type: 'arithmetic',
              difficulty: 3,
              isUnlocked: false,
            ),
            PuzzleStageState(
              id: '4_7',
              title: 'Division Mastery',
              type: 'arithmetic',
              difficulty: 4,
              isUnlocked: false,
            ),
          ],
          requiredStars: 35,
          isUnlocked: false,
        ),
    ];
  }

  void unlockChapter(int chapterNumber) {
    state = state.map((chapter) {
      if (chapter.chapterNumber == chapterNumber) {
        return CampaignChapterState(
          chapterNumber: chapter.chapterNumber,
          title: chapter.title,
          description: chapter.description,
          storyline: chapter.storyline,
          stages: chapter.stages,
          requiredStars: chapter.requiredStars,
          isUnlocked: true,
          isComplete: chapter.isComplete,
        );
      }
      return chapter;
    }).toList();
  }

  void completeStage(String stageId, int stars, int time) {
    state = state.map((chapter) {
      final newStages = chapter.stages.map((stage) {
        if (stage.id == stageId) {
          return PuzzleStageState(
            id: stage.id,
            title: stage.title,
            type: stage.type,
            difficulty: stage.difficulty,
            stars: stars > stage.stars ? stars : stage.stars,
            isUnlocked: stage.isUnlocked,
            isCompleted: true,
            bestTime: time < stage.bestTime || stage.bestTime == 0
                ? time
                : stage.bestTime,
          );
        }
        return stage;
      }).toList();

      final allComplete = newStages.every((s) => s.isCompleted);
      return CampaignChapterState(
        chapterNumber: chapter.chapterNumber,
        title: chapter.title,
        description: chapter.description,
        storyline: chapter.storyline,
        stages: newStages,
        requiredStars: chapter.requiredStars,
        isUnlocked: chapter.isUnlocked,
        isComplete: allComplete,
      );
    }).toList();
  }
}

final challengeModeProvider =
    StateNotifierProvider<ChallengeModeNotifier, ChallengeModeState>((ref) {
      return ChallengeModeNotifier();
    });

final arcadeModeProvider =
    StateNotifierProvider<ArcadeModeNotifier, ArcadeModeState>((ref) {
      return ArcadeModeNotifier(ref);
    });

final practiceModeProvider =
    StateNotifierProvider<PracticeModeNotifier, PracticeModeState>((ref) {
      return PracticeModeNotifier(ref);
    });

final customLevelProvider =
    StateNotifierProvider<CustomLevelNotifier, CustomLevelState>((ref) {
      return CustomLevelNotifier();
    });

final customMixArithmeticProvider =
    StateNotifierProvider<CustomMixArithmeticNotifier, CustomMixArithmeticState>((ref) {
      return CustomMixArithmeticNotifier(ref);
    });

class ChallengeModeState {
  final String? currentChallengeId;
  final String challengeType;
  final int timeLimitSeconds;
  final int remainingSeconds;
  final int hintsRemaining;
  final bool isActive;
  final bool isComplete;
  final int score;
  final Map<String, int> leaderboard;

  ChallengeModeState({
    this.currentChallengeId,
    this.challengeType = 'daily',
    this.timeLimitSeconds = 300,
    this.remainingSeconds = 300,
    this.hintsRemaining = 3,
    this.isActive = false,
    this.isComplete = false,
    this.score = 0,
    this.leaderboard = const {},
  });

  ChallengeModeState copyWith({
    String? currentChallengeId,
    String? challengeType,
    int? timeLimitSeconds,
    int? remainingSeconds,
    int? hintsRemaining,
    bool? isActive,
    bool? isComplete,
    int? score,
    Map<String, int>? leaderboard,
  }) {
    return ChallengeModeState(
      currentChallengeId: currentChallengeId ?? this.currentChallengeId,
      challengeType: challengeType ?? this.challengeType,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      isActive: isActive ?? this.isActive,
      isComplete: isComplete ?? this.isComplete,
      score: score ?? this.score,
      leaderboard: leaderboard ?? this.leaderboard,
    );
  }
}

class ChallengeModeNotifier extends StateNotifier<ChallengeModeState> {
  ChallengeModeNotifier()
    : super(
        ChallengeModeState(
          leaderboard: {
            'Player1': 950,
            'Player2': 875,
            'Player3': 820,
            'Player4': 780,
            'Player5': 720,
          },
        ),
      );

  void startChallenge({String type = 'daily', int timeLimit = 300}) {
    state = ChallengeModeState(
      currentChallengeId: 'challenge_${DateTime.now().millisecondsSinceEpoch}',
      challengeType: type,
      timeLimitSeconds: timeLimit,
      remainingSeconds: timeLimit,
      hintsRemaining: 3,
      isActive: true,
      isComplete: false,
      score: 0,
      leaderboard: state.leaderboard,
    );
  }

  void decrementTime() {
    if (state.isActive && !state.isComplete && state.remainingSeconds > 0) {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      if (state.remainingSeconds <= 0) {
        endChallenge();
      }
    }
  }

  void addScore(int points) {
    if (state.isActive && !state.isComplete) {
      state = state.copyWith(score: state.score + points);
    }
  }

  bool useHint() {
    if (state.hintsRemaining > 0 && state.isActive) {
      state = state.copyWith(hintsRemaining: state.hintsRemaining - 1);
      return true;
    }
    return false;
  }

  void endChallenge() {
    state = state.copyWith(isComplete: true, isActive: false);
  }

  void reset() {
    state = ChallengeModeState(
      leaderboard: {
        'Player1': 950,
        'Player2': 875,
        'Player3': 820,
        'Player4': 780,
        'Player5': 720,
      },
    );
  }
}

class ArcadeModeState {
  final bool isActive;
  final int score;
  final int timeRemaining;
  final int questionsAnswered;
  final int correctAnswers;
  final MathRiddle? currentQuestion;
  final bool isPaused;
  final int highScore;

  ArcadeModeState({
    this.isActive = false,
    this.score = 0,
    this.timeRemaining = 300, // 5 minutes
    this.questionsAnswered = 0,
    this.correctAnswers = 0,
    this.currentQuestion,
    this.isPaused = false,
    this.highScore = 0,
  });

  ArcadeModeState copyWith({
    bool? isActive,
    int? score,
    int? timeRemaining,
    int? questionsAnswered,
    int? correctAnswers,
    MathRiddle? currentQuestion,
    bool? isPaused,
    int? highScore,
  }) {
    return ArcadeModeState(
      isActive: isActive ?? this.isActive,
      score: score ?? this.score,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      isPaused: isPaused ?? this.isPaused,
      highScore: highScore ?? this.highScore,
    );
  }
}

class ArcadeModeNotifier extends StateNotifier<ArcadeModeState> {
  final Ref ref;

  ArcadeModeNotifier(this.ref) : super(ArcadeModeState()) {
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    final highScore = prefs.getInt('arcade_high_score') ?? 0;
    state = state.copyWith(highScore: highScore);
  }

  Future<void> _saveHighScore(int score) async {
    if (score > state.highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('arcade_high_score', score);
      state = state.copyWith(highScore: score);
    }
  }

  void startGame() {
    state = ArcadeModeState(
      isActive: true,
      score: 0,
      timeRemaining: 300,
      questionsAnswered: 0,
      correctAnswers: 0,
      currentQuestion: _generateRandomQuestion(),
      isPaused: false,
      highScore: state.highScore,
    );
  }

  void pauseGame() {
    state = state.copyWith(isPaused: true);
  }

  void resumeGame() {
    state = state.copyWith(isPaused: false);
  }

  void answerQuestion(String answer) {
    if (!state.isActive || state.isPaused || state.currentQuestion == null) return;

    final isCorrect = answer == state.currentQuestion!.correctAnswer;
    final pointsEarned = isCorrect ? _calculatePoints(state.currentQuestion!) : 0;

    state = state.copyWith(
      score: state.score + pointsEarned,
      questionsAnswered: state.questionsAnswered + 1,
      correctAnswers: state.correctAnswers + (isCorrect ? 1 : 0),
      currentQuestion: _generateRandomQuestion(),
    );

    // Add points to user session
    if (isCorrect) {
      ref.read(userSessionProvider.notifier).addPoints(pointsEarned);
    }
  }

  void decrementTime() {
    if (state.isActive && !state.isPaused && state.timeRemaining > 0) {
      state = state.copyWith(timeRemaining: state.timeRemaining - 1);
      if (state.timeRemaining <= 0) {
        endGame();
      }
    }
  }

  void endGame() {
    _saveHighScore(state.score);
    state = state.copyWith(isActive: false, isPaused: false);
  }

  MathRiddle _generateRandomQuestion() {
    final difficulty = 1 + _random.nextInt(3); // 1-3

    return MathRiddleEngine.generateArithmeticProblem(difficulty);
  }

  int _calculatePoints(MathRiddle question) {
    // Base points: 10 for easy, 20 medium, 30 hard
    final base = question.difficulty * 10;
    // Bonus for speed (assuming answered quickly)
    final timeBonus = state.timeRemaining > 240 ? 10 : 0;
    return base + timeBonus;
  }

  static final Random _random = Random();
}

class PracticeModeState {
  final bool isActive;
  final ArithmeticOperation? selectedOperation;
  final int? selectedDifficulty;
  final MathRiddle? currentQuestion;
  final int questionsCompleted;
  final int correctAnswers;
  final int totalTimeSpent;

  PracticeModeState({
    this.isActive = false,
    this.selectedOperation,
    this.selectedDifficulty,
    this.currentQuestion,
    this.questionsCompleted = 0,
    this.correctAnswers = 0,
    this.totalTimeSpent = 0,
  });

  PracticeModeState copyWith({
    bool? isActive,
    ArithmeticOperation? selectedOperation,
    int? selectedDifficulty,
    MathRiddle? currentQuestion,
    int? questionsCompleted,
    int? correctAnswers,
    int? totalTimeSpent,
  }) {
    return PracticeModeState(
      isActive: isActive ?? this.isActive,
      selectedOperation: selectedOperation ?? this.selectedOperation,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      questionsCompleted: questionsCompleted ?? this.questionsCompleted,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
    );
  }
}

class PracticeModeNotifier extends StateNotifier<PracticeModeState> {
  final Ref ref;

  PracticeModeNotifier(this.ref) : super(PracticeModeState());

  void selectOperation(ArithmeticOperation operation) {
    state = state.copyWith(selectedOperation: operation);
  }

  void selectDifficulty(int difficulty) {
    state = state.copyWith(selectedDifficulty: difficulty);
  }

  void startPractice() {
    if (state.selectedOperation == null || state.selectedDifficulty == null) return;

    state = PracticeModeState(
      isActive: true,
      selectedOperation: state.selectedOperation,
      selectedDifficulty: state.selectedDifficulty,
      currentQuestion: _generatePracticeQuestion(),
      questionsCompleted: 0,
      correctAnswers: 0,
      totalTimeSpent: 0,
    );
  }

  void answerQuestion(String answer, int timeSpent) {
    if (!state.isActive || state.currentQuestion == null) return;

    final isCorrect = answer == state.currentQuestion!.correctAnswer;

    state = state.copyWith(
      questionsCompleted: state.questionsCompleted + 1,
      correctAnswers: state.correctAnswers + (isCorrect ? 1 : 0),
      totalTimeSpent: state.totalTimeSpent + timeSpent,
      currentQuestion: _generatePracticeQuestion(),
    );

    // Add points to user session
    if (isCorrect) {
      ref.read(userSessionProvider.notifier).addPoints(5); // Small points for practice
    }
  }

  void nextQuestion() {
    state = state.copyWith(currentQuestion: _generatePracticeQuestion());
  }

  void endPractice() {
    state = state.copyWith(isActive: false);
  }

  MathRiddle _generatePracticeQuestion() {
    if (state.selectedOperation == null || state.selectedDifficulty == null) {
      return MathRiddleEngine.generateArithmeticProblem(1);
    }

    // Generate arithmetic problem with specific operation
    return MathRiddleEngine.generateArithmeticProblem(state.selectedDifficulty!);
    // Note: In a real implementation, you'd modify the engine to generate specific operations
  }
}

class CustomArithmetic {
  final String question;
  final String answer;
  final String explanation;
  final int difficulty;

  CustomArithmetic({
    required this.question,
    required this.answer,
    required this.explanation,
    this.difficulty = 1,
  });
}

class CustomLevelState {
  final List<CustomArithmetic> problems;
  final bool isPlaying;
  final int currentIndex;
  final int correctAnswers;
  final int questionsCompleted;

  CustomLevelState({
    this.problems = const [],
    this.isPlaying = false,
    this.currentIndex = 0,
    this.correctAnswers = 0,
    this.questionsCompleted = 0,
  });

  CustomLevelState copyWith({
    List<CustomArithmetic>? problems,
    bool? isPlaying,
    int? currentIndex,
    int? correctAnswers,
    int? questionsCompleted,
  }) {
    return CustomLevelState(
      problems: problems ?? this.problems,
      isPlaying: isPlaying ?? this.isPlaying,
      currentIndex: currentIndex ?? this.currentIndex,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      questionsCompleted: questionsCompleted ?? this.questionsCompleted,
    );
  }
}

class CustomLevelNotifier extends StateNotifier<CustomLevelState> {
  CustomLevelNotifier() : super(CustomLevelState());

  void addProblem(String question, String answer, String explanation, int difficulty) {
    final newProblem = CustomArithmetic(
      question: question,
      answer: answer,
      explanation: explanation,
      difficulty: difficulty,
    );
    state = state.copyWith(
      problems: [...state.problems, newProblem],
    );
  }

  void removeProblem(int index) {
    final newProblems = List<CustomArithmetic>.from(state.problems)..removeAt(index);
    state = state.copyWith(problems: newProblems);
  }

  void startLevel() {
    state = state.copyWith(
      isPlaying: true,
      currentIndex: 0,
      correctAnswers: 0,
      questionsCompleted: 0,
    );
  }

  void answerQuestion(String userAnswer) {
    if (!state.isPlaying || state.currentIndex >= state.problems.length) return;

    final currentProblem = state.problems[state.currentIndex];
    final isCorrect = userAnswer.trim() == currentProblem.answer.trim();

    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      correctAnswers: state.correctAnswers + (isCorrect ? 1 : 0),
      questionsCompleted: state.questionsCompleted + 1,
    );

    if (state.currentIndex >= state.problems.length) {
      endLevel();
    }
  }

  void endLevel() {
    state = state.copyWith(isPlaying: false);
  }

  void reset() {
    state = CustomLevelState();
  }
}

class CustomMixArithmeticState {
  final bool isActive;
  final List<ArithmeticOperation> selectedOperations;
  final int selectedDifficulty;
  final MathRiddle? currentQuestion;
  final int questionsCompleted;
  final int correctAnswers;
  final int currentStreak;
  final int bestStreak;
  final List<Map<String, dynamic>> questionHistory;
  final bool? lastAnswerCorrect;
  final bool canUndo;
  final String? reactionMessage;
  final bool questionAnswered;
  final DateTime? sessionStartTime;

  CustomMixArithmeticState({
    this.isActive = false,
    this.selectedOperations = const [],
    this.selectedDifficulty = 1,
    this.currentQuestion,
    this.questionsCompleted = 0,
    this.correctAnswers = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.questionHistory = const [],
    this.lastAnswerCorrect,
    this.canUndo = false,
    this.reactionMessage,
    this.questionAnswered = false,
    this.sessionStartTime,
  });

  CustomMixArithmeticState copyWith({
    bool? isActive,
    List<ArithmeticOperation>? selectedOperations,
    int? selectedDifficulty,
    MathRiddle? currentQuestion,
    int? questionsCompleted,
    int? correctAnswers,
    int? currentStreak,
    int? bestStreak,
    List<Map<String, dynamic>>? questionHistory,
    bool? lastAnswerCorrect,
    bool? canUndo,
    String? reactionMessage,
    bool? questionAnswered,
    DateTime? sessionStartTime,
  }) {
    return CustomMixArithmeticState(
      isActive: isActive ?? this.isActive,
      selectedOperations: selectedOperations ?? this.selectedOperations,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      questionsCompleted: questionsCompleted ?? this.questionsCompleted,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      questionHistory: questionHistory ?? this.questionHistory,
      lastAnswerCorrect: lastAnswerCorrect ?? this.lastAnswerCorrect,
      canUndo: canUndo ?? this.canUndo,
      reactionMessage: reactionMessage ?? this.reactionMessage,
      questionAnswered: questionAnswered ?? this.questionAnswered,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
    );
  }
}

class CustomMixArithmeticNotifier extends StateNotifier<CustomMixArithmeticState> {
  final Ref ref;
  final Random _random = Random();

  CustomMixArithmeticNotifier(this.ref) : super(CustomMixArithmeticState());

  void toggleOperation(ArithmeticOperation operation) {
    final newOps = List<ArithmeticOperation>.from(state.selectedOperations);
    if (newOps.contains(operation)) {
      newOps.remove(operation);
    } else {
      newOps.add(operation);
    }
    state = state.copyWith(selectedOperations: newOps);
  }

  void setDifficulty(int difficulty) {
    state = state.copyWith(selectedDifficulty: difficulty);
  }

  void startMix() {
    if (state.selectedOperations.isEmpty) return;
    state = state.copyWith(
      isActive: true,
      currentQuestion: _generateMixedQuestion(),
      questionsCompleted: 0,
      correctAnswers: 0,
      currentStreak: 0,
      bestStreak: state.bestStreak, // Keep best streak
      questionHistory: [],
      lastAnswerCorrect: null,
      canUndo: false,
      reactionMessage: null,
      questionAnswered: false,
      sessionStartTime: DateTime.now(),
    );
  }

  void answerQuestion(String answer) {
    if (!state.isActive || state.currentQuestion == null) return;

    final isCorrect = answer == state.currentQuestion!.correctAnswer;
    final newStreak = isCorrect ? state.currentStreak + 1 : 0;
    final newBestStreak = newStreak > state.bestStreak ? newStreak : state.bestStreak;

    // Store current question in history for undo
    final historyEntry = {
      'question': state.currentQuestion!,
      'userAnswer': answer,
      'wasCorrect': isCorrect,
      'previousStreak': state.currentStreak,
      'previousCorrectAnswers': state.correctAnswers,
      'previousQuestionsCompleted': state.questionsCompleted,
    };

    final newHistory = List<Map<String, dynamic>>.from(state.questionHistory)..add(historyEntry);

    // Generate reaction message
    String? reaction;
    if (isCorrect) {
      if (newStreak == 5) {
        reaction = '🔥 HOT STREAK!';
      } else if (newStreak == 10) {
        reaction = '🌟 UNSTOPPABLE!';
      } else if (newStreak >= 3) {
        reaction = '⚡ KEEP IT UP!';
      } else {
        reaction = '✅ CORRECT!';
      }
    } else {
      if (state.currentStreak >= 5) {
        reaction = '💔 STREAK BROKEN!';
      } else {
        reaction = '❌ INCORRECT!';
      }
    }

    state = state.copyWith(
      questionsCompleted: state.questionsCompleted + 1,
      correctAnswers: state.correctAnswers + (isCorrect ? 1 : 0),
      currentStreak: newStreak,
      bestStreak: newBestStreak,
      questionHistory: newHistory,
      lastAnswerCorrect: isCorrect,
      canUndo: true,
      reactionMessage: reaction,
      questionAnswered: true,
    );


  }

  void endMix() {
    // Record analytics before ending the session
    if (state.questionsCompleted > 0 && state.sessionStartTime != null) {
      final duration = DateTime.now().difference(state.sessionStartTime!).inMinutes;
      final selectedOps = state.selectedOperations.map((op) => op.name).join(',');
      ref.read(analyticsProvider.notifier).recordSession(
        selectedOps,
        duration,
        state.questionsCompleted,
        state.correctAnswers,
        0, // Hints not tracked in custom mix yet
      );
    }

    state = state.copyWith(isActive: false, sessionStartTime: null);
  }

  void undoLastAnswer() {
    if (!state.canUndo || state.questionHistory.isEmpty) return;

    final lastEntry = state.questionHistory.last;
    final newHistory = List<Map<String, dynamic>>.from(state.questionHistory)..removeLast();

    state = state.copyWith(
      questionsCompleted: lastEntry['previousQuestionsCompleted'],
      correctAnswers: lastEntry['previousCorrectAnswers'],
      currentStreak: lastEntry['previousStreak'],
      questionHistory: newHistory,
      canUndo: newHistory.isNotEmpty,
      lastAnswerCorrect: null,
      reactionMessage: null,
      questionAnswered: false,
      currentQuestion: lastEntry['question'],
    );
  }

  void clearReaction() {
    state = state.copyWith(reactionMessage: null);
  }

  void nextQuestion() {
    if (!state.isActive) return;
    state = state.copyWith(
      currentQuestion: _generateMixedQuestion(),
      lastAnswerCorrect: null,
      canUndo: false,
      reactionMessage: null,
      questionAnswered: false,
    );
  }

  MathRiddle _generateMixedQuestion() {
    // Generate arithmetic problem with specific operations
    final operation = state.selectedOperations[_random.nextInt(state.selectedOperations.length)];
    return _generateCustomArithmetic(operation, state.selectedDifficulty);
  }

  MathRiddle _generateCustomArithmetic(ArithmeticOperation operation, int difficulty) {
    int num1, num2, answer;
    String operatorStr;

    // Scale numbers based on difficulty and operation
    switch (difficulty) {
      case 1:
        num1 = _random.nextInt(10) + 1;
        num2 = _random.nextInt(10) + 1;
        break;
      case 2:
        num1 = _random.nextInt(20) + 5;
        num2 = _random.nextInt(15) + 1;
        break;
      case 3:
        num1 = _random.nextInt(50) + 10;
        num2 = _random.nextInt(20) + 5;
        break;
      case 4:
        num1 = _random.nextInt(100) + 20;
        num2 = _random.nextInt(50) + 10;
        break;
      case 5:
        num1 = _random.nextInt(200) + 50;
        num2 = _random.nextInt(100) + 20;
        break;
      default:
        num1 = _random.nextInt(500) + 100;
        num2 = _random.nextInt(200) + 50;
    }

    // Ensure valid operations
    switch (operation) {
      case ArithmeticOperation.addition:
        answer = num1 + num2;
        operatorStr = '+';
        break;
      case ArithmeticOperation.subtraction:
        if (num1 < num2) {
          final temp = num1;
          num1 = num2;
          num2 = temp;
        }
        answer = num1 - num2;
        operatorStr = '-';
        break;
      case ArithmeticOperation.multiplication:
        // Smaller numbers for multiplication
        num1 = _random.nextInt(12) + 2;
        num2 = _random.nextInt(12) + 2;
        answer = num1 * num2;
        operatorStr = '×';
        break;
      case ArithmeticOperation.division:
        // Ensure clean division
        num2 = _random.nextInt(10) + 2;
        answer = _random.nextInt(10) + 2;
        num1 = num2 * answer;
        operatorStr = '÷';
        break;
    }

    // For higher difficulties, add variations
    String question = '$num1 $operatorStr $num2 = ?';
    if (difficulty >= 6) {
      // Add word context
      final contexts = [
        'Calculate: ',
        'What is ',
        'Solve: ',
        'Find the result of ',
      ];
      question = contexts[_random.nextInt(contexts.length)] + question;
    }

    final options = _generateOptions(answer, difficulty);

    return MathRiddle(
      id: 'custom_mix_${DateTime.now().millisecondsSinceEpoch}',
      type: MathRiddleType.arithmetic,
      difficulty: difficulty,
      question: question,
      options: options,
      correctAnswer: answer.toString(),
      explanation: '$num1 $operatorStr $num2 = $answer',
      progressiveHints: _generateArithmeticHints(num1, num2, operation),
      basePoints: difficulty * 10,
    );
  }

  List<String> _generateOptions(int answer, int difficulty) {
    final options = <String>{answer.toString()};

    while (options.length < 4) {
      int offset;
      switch (difficulty) {
        case 1:
          offset = _random.nextInt(10) - 5;
          break;
        case 2:
          offset = _random.nextInt(20) - 10;
          break;
        default:
          offset = _random.nextInt(30) - 15;
      }
      final option = answer + offset;
      if (option > 0 && option != answer) {
        options.add(option.toString());
      }
    }

    final list = options.toList()..shuffle(_random);
    return list;
  }

  List<String> _generateArithmeticHints(int num1, int num2, ArithmeticOperation op) {
    final hints = <String>[];
    switch (op) {
      case ArithmeticOperation.addition:
        hints.add('Add the numbers together');
        hints.add('$num1 + $num2 = ?');
        break;
      case ArithmeticOperation.subtraction:
        hints.add('Subtract the smaller number from the larger');
        hints.add('$num1 - $num2 = ?');
        break;
      case ArithmeticOperation.multiplication:
        hints.add('Multiply the two numbers');
        hints.add('$num1 × $num2 = ?');
        break;
      case ArithmeticOperation.division:
        hints.add('Divide the first number by the second');
        hints.add('$num1 ÷ $num2 = ?');
        break;
    }
    return hints;
  }
}

