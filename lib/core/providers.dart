import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;
import '../core/themes/app_themes.dart';
import '../data/models/user_session.dart';
import '../data/models/level_progress.dart';
import '../data/models/math_riddle.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/level_progress_repository.dart';
import '../data/repositories/statistics_repository.dart';
import '../data/repositories/database_service.dart';
import '../core/math_engine/math_riddle_engine.dart';
import '../core/math_engine/math_visual_engine.dart';
import '../data/models/cross_numbers_puzzle.dart';
import '../core/math_engine/cross_numbers_engine.dart';
import '../core/sound_manager.dart';
import '../core/notification_service.dart';
import '../core/game_adaptability/dynamic_difficulty_system.dart';

import '../core/performance/isar_service.dart';
import '../core/performance/performance_models.dart';
import '../core/utils/game_flow_optimizer.dart';
import '../data/content_library/achievement_system.dart';

import '../features/game/logic/game_session_provider.dart';

final dbProvider = FutureProvider<DatabaseService>((ref) async {
  return await DatabaseService.instance;
});

final navigationIndexProvider = StateProvider<int>((ref) => 0);

class StartupState {
  final bool isInitialized;
  final bool needsIntro;
  final bool needsProfileSetup;
  final bool isReady;

  StartupState({
    this.isInitialized = false,
    this.needsIntro = true,
    this.needsProfileSetup = true,
    this.isReady = false,
  });

  StartupState copyWith({
    bool? isInitialized,
    bool? needsIntro,
    bool? needsProfileSetup,
    bool? isReady,
  }) {
    return StartupState(
      isInitialized: isInitialized ?? this.isInitialized,
      needsIntro: needsIntro ?? this.needsIntro,
      needsProfileSetup: needsProfileSetup ?? this.needsProfileSetup,
      isReady: isReady ?? this.isReady,
    );
  }
}

class StartupNotifier extends StateNotifier<StartupState> {
  final Ref ref;

  StartupNotifier(this.ref) : super(StartupState()) {
    _init();
  }

  Future<void> _init() async {
    final stopwatch = Stopwatch()..start();
    try {
      // 1. Core Services
      await Future.wait([
        ref.read(themeProvider.notifier).loadTheme(),
        ref.read(localeProvider.notifier).loadLocale(),
        HapticManager.instance.initialize(),
        SoundManager.instance.initialize(),
        NotificationService().initialize(),
      ]);

      // Initialize achievement state
      ref.read(achievementStateProvider.notifier).initialize();

      // 2. Database & Data
      await DatabaseService.instance;
      await ref.read(userSessionProvider.notifier).initializeUser();
      await ref.read(levelProgressProvider.notifier).loadProgress();

      // 3. Determine onboarding status
      final prefs = await SharedPreferences.getInstance();
      final hasSeenIntro = prefs.getBool('seen_intro') ?? false;
      final hasCustomization = prefs.getBool('has_customization') ?? false;

      // 4. Enforce minimum splash duration for branding (3 seconds)
      final elapsed = stopwatch.elapsedMilliseconds;
      if (elapsed < 3000) {
        await Future.delayed(Duration(milliseconds: 3000 - elapsed));
      }

      state = state.copyWith(
        isInitialized: true,
        needsIntro: !hasSeenIntro,
        needsProfileSetup: !hasCustomization,
        isReady: true,
      );
    } catch (e) {
      // Handle init error - at least set ready so app doesn't stuck
      state = state.copyWith(isReady: true);
    } finally {
      stopwatch.stop();
    }
  }

  Future<void> completeIntro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_intro', true);
    state = state.copyWith(needsIntro: false);
  }

  Future<void> completeProfileSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_customization', true);
    state = state.copyWith(needsProfileSetup: false);
  }
}

final startupProvider = StateNotifierProvider<StartupNotifier, StartupState>((ref) {
  return StartupNotifier(ref);
});

final isarServiceProvider = Provider((ref) => IsarService());

final notificationProvider = Provider((ref) => NotificationService());
final userRepositoryProvider = Provider((ref) => UserRepository());
final levelProgressRepositoryProvider = Provider((ref) => LevelProgressRepository());
final statisticsRepositoryProvider = Provider((ref) => StatisticsRepository());
const int hintCostPoints = 50;

final soundManagerProvider = Provider((ref) => SoundManager.instance);
final hapticManagerProvider = Provider((ref) => HapticManager.instance);

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeType>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppThemeType> {
  ThemeNotifier() : super(AppThemeType.solar) {
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString('app_theme');
    if (themeName != null) {
      state = AppThemeType.values.firstWhere(
        (e) => e.name == themeName,
        orElse: () => AppThemeType.solar,
      );
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
    await ref.read(hapticManagerProvider).setHapticsEnabled(hapticsEnabled);
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
    final statsRepo = ref.read(statisticsRepositoryProvider);
    final stats = await statsRepo.getOverallStats();
    
    final recentSessions = stats.timePerQuestion.reversed.toList();
    
    state = state.copyWith(
      sessionCount: stats.totalQuestionsAnswered, // or stats.timePerQuestion.length as a proxy for questions
      averageSessionTime: stats.totalQuestionsAnswered > 0 
          ? stats.timeSpentSeconds / stats.totalQuestionsAnswered 
          : 0.0,
      operationUsage: stats.modeUsage,
      recentSessions: recentSessions,
      totalQuestionsAnswered: stats.totalQuestionsAnswered,
      totalHintsUsed: stats.totalHintsUsed,
    );
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

  void recordSession(String operation, int duration, int questions, int correct, int hints, {String? mode}) {
    final newSession = {
      'operation': operation,
      'mode': mode ?? 'unknown',
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
    
    // Also refresh other real-time providers if needed
    ref.invalidate(overallAccuracyProvider);
    ref.invalidate(totalTimePlayedProvider);
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
        ref.read(notificationProvider).showAchievementNotification(
          '7-Day Streak!',
          'You\'ve played for 7 days in a row! Enjoy 5000 bonus points.',
        );
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
    int? skillRating,
    bool? isFocusMode,
    int? totalPoints,
    String? lastPlayedMode,
    String? lastPlayedOperation,
    int? lastPlayedLevel,
    double? lastHeatIndex,
  }) async {
    if (state == null) return;

    final repo = ref.read(userRepositoryProvider);
    final updatedUser = state!.copyWith(
      name: name,
      avatarShape: avatarShape,
      avatarColor: avatarColor,
      theme: theme,
      language: language,
      skillRating: skillRating,
      isFocusMode: isFocusMode,
      totalPoints: totalPoints,
      lastPlayedMode: lastPlayedMode,
      lastPlayedOperation: lastPlayedOperation,
      lastPlayedLevel: lastPlayedLevel,
      lastHeatIndex: lastHeatIndex,
    );

    await repo.updateUserSession(updatedUser);
    state = updatedUser;
  }

  Future<void> setFocusMode(bool enabled) async {
    if (state == null) return;
    await updateUser(isFocusMode: enabled);
  }

  Future<void> addPoints(int points) async {
    if (state == null) return;
    
    final repo = ref.read(userRepositoryProvider);
    final oldLevel = state!.level;
    
    await repo.updatePoints(points);
    state = state!.copyWith(totalPoints: state!.totalPoints + points);

    if (state!.level > oldLevel) {
      ref.read(notificationProvider).showLevelUpNotification(
        'LEVEL UP!',
        'You\'ve reached Level ${state!.level}! Keep up the great work.',
      );
      // Optional: Add a bonus for leveling up
      await addPoints(250 * state!.level); 
    }
  }

  Future<void> claimDailyReward() async {
    if (state == null) return;
    
    final now = DateTime.now();
    final lastPlayed = state!.lastPlayedAt;
    final today = DateTime(now.year, now.month, now.day);
    final lastPlayedDay = DateTime(lastPlayed.year, lastPlayed.month, lastPlayed.day);

    if (today.isAfter(lastPlayedDay)) {
      final reward = 100 * state!.loginStreak;
      await addPoints(reward);
      
      ref.read(notificationProvider).showAchievementNotification(
        'Daily Reward!',
        'You earned $reward points for your ${state!.loginStreak}-day streak!',
      );
    }
  }

  Future<bool> unlockAvatar(String avatarShape, int cost, int requiredStars, {int requiredLevel = 1}) async {
    if (state == null) return false;
    
    final currentAvatars =
        List<String>.from(state!.unlockedAvatars ?? ['circle', 'square', 'star']);
    
    if (currentAvatars.contains(avatarShape)) return true;
    if (state!.totalPoints < cost) return false;

    final totalStars = await ref.read(levelProgressRepositoryProvider).getTotalStars();
    if (totalStars < requiredStars) return false;
    if (state!.level < requiredLevel) return false;

    final repo = ref.read(userRepositoryProvider);

    currentAvatars.add(avatarShape);
    final updatedUser = state!.copyWith(
      totalPoints: state!.totalPoints - cost,
      unlockedAvatars: currentAvatars,
    );

    await repo.updateUserSession(updatedUser);
    state = updatedUser;
    
    // Track achievement or analytics for purchase
    ref.read(analyticsProvider.notifier).recordSession(
      'shop_purchase',
      0,
      0,
      0,
      0,
      mode: 'avatar_$avatarShape',
    );

    return true;
  }

  Future<void> equipAvatar(String avatarId) async {
    if (state == null) return;
    final updatedUser = state!.copyWith(avatarShape: avatarId);

    final repo = ref.read(userRepositoryProvider);
    await repo.updateUserSession(updatedUser);
    state = updatedUser;
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

  Future<void> updateProgress(String operationId, int level, int stars, int score) async {
    final repo = ref.read(levelProgressRepositoryProvider);
    await repo.updateStars(operationId, level, stars, score);
    await loadProgress();
  }

  Future<void> unlockNextLevel(String operationId, int level) async {
    final repo = ref.read(levelProgressRepositoryProvider);
    
    final nextLevel = level; // This is actually the level number to unlock if passed from updateProgress as difficulty + 1
    final progress = await repo.getProgress(operationId, nextLevel);
    
    if (progress == null || !progress.isUnlocked) {
      final newProgress = LevelProgress(
        operationId: operationId,
        level: nextLevel,
        stars: 0,
        isUnlocked: true,
        highScore: 0,
      );
      await repo.saveProgress(newProgress);
    }

    // Refresh the provider state
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

// Filter provider for reports
final reportsFilterProvider = StateProvider<String?>((ref) => null);

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
  static const Duration sessionTimeout = Duration(minutes: 30);

  SessionStatsNotifier() : super(SessionStats()) {
    _startPeriodicReset();
  }

  void recordAnswer(String operation, bool isCorrect, int timeSpent, bool usedHint) {
    checkInactivity();
    
    final newOperationStats = Map<String, int>.from(state.operationStats);
    newOperationStats[operation] = (newOperationStats[operation] ?? 0) + 1;

    state = state.copyWith(
      questionsAnswered: state.questionsAnswered + 1,
      correctAnswers: state.correctAnswers + (isCorrect ? 1 : 0),
      hintsUsed: state.hintsUsed + (usedHint ? 1 : 0),
      timeSpent: state.timeSpent + timeSpent,
      operationStats: newOperationStats,
      lastUpdate: DateTime.now(),
    );
  }

  void checkInactivity() {
    final now = DateTime.now();
    if (now.difference(state.lastUpdate) > sessionTimeout) {
      resetSession();
    }
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
  final isarService = ref.watch(isarServiceProvider);
  return PerformanceTrendsNotifier(isarService, ref);
});

final filteredPerformanceTrendsProvider = Provider<PerformanceTrends>((ref) {
  final filter = ref.watch(reportsFilterProvider);
  final trends = ref.watch(performanceTrendsProvider);
  
  if (filter == null) return trends;

  final isar = ref.watch(isarServiceProvider);
  final allData = isar.getRecentPerformanceDataSync(100);
  final filteredData = allData.where((p) => p.mode == filter).take(50).toList().reversed.toList();
  
  return PerformanceTrends(
    accuracyHistory: filteredData.map((e) => e.accuracy).toList(),
    timeHistory: filteredData.map((e) => e.averageTime).toList(),
    streakHistory: filteredData.map((e) => e.streak).toList(),
    heatHistory: filteredData.map((e) => e.avgHeatIndex ?? 1.0).toList(),
    timestamps: filteredData.map((e) => e.timestamp).toList(),
  );
});

class PerformanceTrends {
  final List<double> accuracyHistory;
  final List<int> timeHistory;
  final List<int> streakHistory;
  final List<double> heatHistory;
  final List<DateTime> timestamps;
  final DateTime lastUpdated;

  PerformanceTrends({
    List<double>? accuracyHistory,
    List<int>? timeHistory,
    List<int>? streakHistory,
    List<double>? heatHistory,
    List<DateTime>? timestamps,
    DateTime? lastUpdated,
  }) : accuracyHistory = accuracyHistory ?? [],
       timeHistory = timeHistory ?? [],
       streakHistory = streakHistory ?? [],
       heatHistory = heatHistory ?? [],
       timestamps = timestamps ?? [],
       lastUpdated = lastUpdated ?? DateTime.now();

  double get averageAccuracy => accuracyHistory.isEmpty ? 0.0 : accuracyHistory.reduce((a, b) => a + b) / accuracyHistory.length;
  double get peakAccuracy => accuracyHistory.isEmpty ? 0.0 : accuracyHistory.reduce((a, b) => a > b ? a : b);
  double get averageTime => timeHistory.isEmpty ? 0.0 : timeHistory.reduce((a, b) => a + b) / timeHistory.length;
  int get bestStreak => streakHistory.isEmpty ? 0 : streakHistory.reduce((a, b) => a > b ? a : b);
  double get averageHeat => heatHistory.isEmpty ? 1.0 : heatHistory.reduce((a, b) => a + b) / heatHistory.length;

  PerformanceTrends copyWith({
    List<double>? accuracyHistory,
    List<int>? timeHistory,
    List<int>? streakHistory,
    List<double>? heatHistory,
    List<DateTime>? timestamps,
    DateTime? lastUpdated,
  }) {
    return PerformanceTrends(
      accuracyHistory: accuracyHistory ?? this.accuracyHistory,
      timeHistory: timeHistory ?? this.timeHistory,
      streakHistory: streakHistory ?? this.streakHistory,
      heatHistory: heatHistory ?? this.heatHistory,
      timestamps: timestamps ?? this.timestamps,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }
}

class PerformanceTrendsNotifier extends StateNotifier<PerformanceTrends> {
  final IsarService _isarService;
  final Ref ref;

  PerformanceTrendsNotifier(this._isarService, this.ref) : super(PerformanceTrends()) {
    _loadHistoricalData();
  }

  void addDataPoint(double accuracy, int avgTime, int streak, {double? heat}) {
    const maxHistorySize = 50; // Keep last 50 data points
    final now = DateTime.now();

    final newAccuracyHistory = List<double>.from(state.accuracyHistory)..add(accuracy);
    final newTimeHistory = List<int>.from(state.timeHistory)..add(avgTime);
    final newStreakHistory = List<int>.from(state.streakHistory)..add(streak);
    final newHeatHistory = List<double>.from(state.heatHistory)..add(heat ?? 1.0);
    final newTimestamps = List<DateTime>.from(state.timestamps)..add(now);

    // Keep only the most recent data points
    if (newAccuracyHistory.length > maxHistorySize) {
      newAccuracyHistory.removeAt(0);
      newTimeHistory.removeAt(0);
      newStreakHistory.removeAt(0);
      newHeatHistory.removeAt(0);
      newTimestamps.removeAt(0);
    }

    state = state.copyWith(
      accuracyHistory: newAccuracyHistory,
      timeHistory: newTimeHistory,
      streakHistory: newStreakHistory,
      heatHistory: newHeatHistory,
      timestamps: newTimestamps,
    );

    _saveHistoricalData(accuracy, avgTime, streak, heat ?? 1.0);
  }

  Future<void> _loadHistoricalData() async {
    final recentData = await _isarService.getRecentPerformanceData(50);
    
    if (recentData.isEmpty) {
      // Try to migrate from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final accuracyData = prefs.getStringList('performance_accuracy_history') ?? [];
      final timeData = prefs.getStringList('performance_time_history') ?? [];
      final streakData = prefs.getStringList('performance_streak_history') ?? [];

      if (accuracyData.isNotEmpty) {
        final List<PerformanceDataPoint> migratedPoints = [];
        for (int i = 0; i < accuracyData.length; i++) {
          migratedPoints.add(PerformanceDataPoint(
            timestamp: DateTime.now().subtract(Duration(minutes: accuracyData.length - i)),
            accuracy: double.tryParse(accuracyData[i]) ?? 0.0,
            averageTime: i < timeData.length ? int.tryParse(timeData[i]) ?? 0 : 0,
            streak: i < streakData.length ? int.tryParse(streakData[i]) ?? 0 : 0,
            avgHeatIndex: 1.0,
          ));
        }
        
        for (final point in migratedPoints) {
          await _isarService.savePerformanceData(point);
        }
        
        // Clear old data
        await prefs.remove('performance_accuracy_history');
        await prefs.remove('performance_time_history');
        await prefs.remove('performance_streak_history');

        final newData = await _isarService.getRecentPerformanceData(50);
        final historicalData = newData.reversed.toList();
        state = PerformanceTrends(
          accuracyHistory: historicalData.map((e) => e.accuracy).toList(),
          timeHistory: historicalData.map((e) => e.averageTime).toList(),
          streakHistory: historicalData.map((e) => e.streak).toList(),
          heatHistory: historicalData.map((e) => e.avgHeatIndex ?? 1.0).toList(),
          timestamps: historicalData.map((e) => e.timestamp).toList(),
        );
        return;
      }
    }

    // Recent data is Descending, so we reverse it to maintain chronological order in the UI
    final historicalData = recentData.reversed.toList();

    state = PerformanceTrends(
      accuracyHistory: historicalData.map((e) => e.accuracy).toList(),
      timeHistory: historicalData.map((e) => e.averageTime).toList(),
      streakHistory: historicalData.map((e) => e.streak).toList(),
      heatHistory: historicalData.map((e) => e.avgHeatIndex ?? 1.0).toList(),
      timestamps: historicalData.map((e) => e.timestamp).toList(),
    );
  }

  Future<void> _saveHistoricalData(double accuracy, int avgTime, int streak, double heat) async {
    final activeGame = ref.read(gameSessionProvider);
    
    // Use operation name as the primary tag to allow granular filtering in reports
    // Fallback to mode name if operation is not available
    String? modeTag = activeGame?.operation ?? activeGame?.mode.name;
    
    // Check if Custom Mix is active
    final customMix = ref.read(customMixArithmeticProvider);
    if (customMix.isActive || (customMix.isFinished && modeTag == null)) {
      modeTag = 'customMix';
    }

    final dataPoint = PerformanceDataPoint(
      timestamp: DateTime.now(),
      accuracy: accuracy,
      averageTime: avgTime,
      streak: streak,
      avgHeatIndex: heat,
      mode: modeTag,
    );
    await _isarService.savePerformanceData(dataPoint);
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
      'overdrive': Achievement(
        id: 'overdrive',
        title: 'Overdrive',
        description: 'Maintain heat above 2.5 for 30 seconds',
        icon: '🔥',
        rewardPoints: 2000,
        maxProgress: 30,
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

  Future<void> claimReward(String id, WidgetRef ref) async {
    final challenge = state.firstWhere(
      (c) => c.id == id,
      orElse: () => throw Exception('Challenge not found'),
    );
    if (challenge.isCompleted) {
      state = state.where((c) => c.id != id).toList();
      
      // Award bonus points
      ref.read(userSessionProvider.notifier).addPoints(challenge.rewardPoints);
      
      // Show achievement notification
      NotificationService().showAchievementNotification(
        'Daily Challenge Complete!',
        'Rewarded ${challenge.rewardPoints} bonus points',
      );
    }
  }
}

final crossNumbersProvider = StateNotifierProvider.autoDispose<CrossNumbersNotifier, CrossNumbersState>((ref) {
  return CrossNumbersNotifier(ref);
});

final mathRiddleProvider =
    StateNotifierProvider<MathRiddleNotifier, MathRiddleState>((ref) {
      return MathRiddleNotifier(ref);
    });

class MathRiddleNotifier extends StateNotifier<MathRiddleState> {
  final Ref ref;
  MathRiddleNotifier(this.ref) : super(const MathRiddleState());

  void loadArithmeticProblem(int difficulty) {
    const questionCount = 20;
    
    // Attempt to fetch from preloaded cache
    final cached = GameFlowOptimizer.getPreloadedRiddles(
      operations: ['arithmetic'],
      level: difficulty,
    );

    final List<dynamic> riddles = (cached != null && cached.isNotEmpty)
        ? cached
        : List.generate(questionCount, (i) => MathRiddleEngine.generateArithmeticProblem(difficulty));

    state = state.copyWith(
      currentRiddle: riddles.isNotEmpty && riddles[0] is MathRiddle ? riddles[0] as MathRiddle : null,
      allChallenges: riddles,
      level: difficulty,
      totalQuestions: riddles.length,
      questionIndex: 1,
    );
  }

    // removed loadWordProblem
    // removed loadNumberSequence
  Future<void> loadLogicChallenge(int difficulty) async {
    const questionCount = 20;

    final cached = GameFlowOptimizer.getPreloadedRiddles(
      operations: ['logic'],
      level: difficulty,
    );

    if (cached != null && cached.isNotEmpty) {
      state = state.copyWith(
        currentLogic: cached[0] is LogicMathChallenge ? cached[0] as LogicMathChallenge : null,
        allChallenges: cached,
        level: difficulty,
        totalQuestions: cached.length,
        questionIndex: 1,
      );
      return;
    }

    final challenges = <LogicMathChallenge>[];
    for (int i = 0; i < questionCount; i++) {
      if (difficulty >= 2) {
        final logic = await MathVisualEngine.generateVisualLogicChallenge(difficulty);
        challenges.add(logic);
      } else {
        final logic = await MathRiddleEngine.generateLogicChallenge(difficulty);
        challenges.add(logic);
      }
    }

    if (challenges.isNotEmpty) {
      state = state.copyWith(
        currentLogic: challenges[0],
        allChallenges: challenges,
        level: difficulty,
        totalQuestions: questionCount,
        questionIndex: 1,
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
    if (state.currentRiddle != null) {
      isCorrect = state.selectedAnswer == state.currentRiddle!.correctAnswer;
    } else if (state.currentLogic != null) {
      isCorrect = state.selectedAnswer == state.currentLogic!.correctAnswer;
    } else {
      return;
    }

    final newCorrect = state.correctAnswers + (isCorrect ? 1 : 0);
    final newIndex = state.questionIndex + 1;

    // Record per-answer session stats
    final operation = state.currentRiddle != null ? 'riddle' : 'logic';
    ref.read(sessionStatsProvider.notifier).recordAnswer(
      operation,
      isCorrect,
      0, // Time tracking not fully integrated in MathRiddleNotifier yet
      false, // Hints used tracking to be added
    );

    // Record for dynamic difficulty
    ref.read(playerPerformanceProvider.notifier).recordAnswer(
      operation: operation,
      isCorrect: isCorrect,
      responseTimeMs: 0,
      hintsUsed: 0,
    );
    ref.read(dynamicDifficultyProvider.notifier).recordAssessment(isCorrect: isCorrect);

    // Check if level complete
    if (newIndex >= state.totalQuestions) {
      // Level finished - save progress and unlock next level
      _saveLevelCompletion(state.level, newCorrect, state.totalQuestions);
      state = state.copyWith(
        isCorrect: isCorrect,
        isAnswered: true,
        correctAnswers: newCorrect,
        questionIndex: newIndex,
      );
    } else {
      // Move to next question - advance to next item in allChallenges
      MathRiddle? nextRiddle;
      LogicMathChallenge? nextLogic;
      
      if (state.allChallenges.isNotEmpty && newIndex - 1 < state.allChallenges.length) {
        final next = state.allChallenges[newIndex - 1];
        if (next is MathRiddle) {
          nextRiddle = next;
        } else if (next is LogicMathChallenge) {
          nextLogic = next;
        }
      }
      
      state = state.copyWith(
        isCorrect: isCorrect,
        isAnswered: false,
        correctAnswers: newCorrect,
        questionIndex: newIndex,
        selectedAnswer: null,
        revealedHints: [],
        currentRiddle: nextRiddle ?? state.currentRiddle,
        currentLogic: nextLogic ?? state.currentLogic,
      );
    }
  }

  Future<void> _saveLevelCompletion(int level, int correct, int total) async {
    final repo = ref.read(levelProgressRepositoryProvider);
    
    final operation = 'math_riddle'; // Corrected from 'logic'
    
    final stars = state.stars;
    await repo.updateStars(operation, level, stars, correct * 5);
    ref.read(levelProgressProvider.notifier).loadProgress();
    
    if (stars > 0) {
      ref.read(dailyChallengeProvider.notifier).incrementProgress('stars', stars);
    }
  }

  void nextQuestion() {
    // Auto-advance handled in submitAnswer - this is for manual navigation if needed
  }

  void skipQuestion(int currentLevel) {
    // Skip current question and move to next
    final currentQIndex = state.questionIndex - 1;
    final nextIndex = currentQIndex + 1;
    if (nextIndex < state.totalQuestions && state.allChallenges.isNotEmpty) {
      final nextChallenge = state.allChallenges[nextIndex];
      _navigateToQuestion(nextChallenge, nextIndex + 1);
    }
  }

  void previousQuestion() {
    // Go back to previous question
    final currentQIndex = state.questionIndex - 1;
    if (currentQIndex > 0 && state.allChallenges.isNotEmpty) {
      final prevChallenge = state.allChallenges[currentQIndex - 1];
      _navigateToQuestion(prevChallenge, currentQIndex);
    }
  }

  void _navigateToQuestion(dynamic challenge, int newIndex) {
    // Handle navigation to any question type
    if (challenge is MathRiddle) {
      state = state.copyWith(
        currentRiddle: challenge,
        currentLogic: null,
        questionIndex: newIndex,
        selectedAnswer: null,
        revealedHints: [],
        isAnswered: false,
        isCorrect: false,
      );
    } else if (challenge is LogicMathChallenge) {
      state = state.copyWith(
        currentLogic: challenge,
        currentRiddle: null,
        questionIndex: newIndex,
        selectedAnswer: null,
        revealedHints: [],
        isAnswered: false,
        isCorrect: false,
      );
    }
  }

  void revealHint() {
    if (state.isAnswered) return;

    final user = ref.read(userSessionProvider);
    if (user == null || user.totalPoints < hintCostPoints) return;

    List<String> availableHints = [];

    if (state.currentRiddle != null) {
      availableHints = state.currentRiddle!.progressiveHints;
    } else if (state.currentLogic != null) {
      availableHints = state.currentLogic!.progressiveHints;
    }

    if (state.revealedHints.length < availableHints.length) {
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
      state = state.copyWith(timeSpentSeconds: state.timeSpentSeconds + 1);
    }
  }

  void reset() {
    state = const MathRiddleState();
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
  final int totalMathRiddlesSolved;
  final int averageTimeSeconds;
  final int bestTimeSeconds;
  final int totalHintsUsed;
  final int totalStarsEarned;
  final int currentStreak;
  final int bestStreak;

  PuzzleStats({
    this.totalPuzzlesSolved = 0,
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

    state = state.copyWith(
      totalPuzzlesSolved: state.totalPuzzlesSolved + 1,
      totalMathRiddlesSolved: state.totalMathRiddlesSolved + 1,
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
    // Difficulty thresholds for different styles
    if (level >= 30) return styles[(questionIndex + level) % 4]; // All styles
    if (level >= 15) return styles[(questionIndex + level) % 3]; // Classic, Dense, Symmetry
    return styles[(questionIndex + level) % 2]; // Classic, Dense
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
        // Handle digit input
        if (state.isNewSelection) {
          newValue = value;
        } else {
          // Append digit, max 4 digits (to support up to 1000+)
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
      }

      state = state.copyWith(
        puzzle: newPuzzle,
        isComplete: newPuzzle.isComplete,
        isNewSelection: nextIsNewSelection,
        satisfiedEquations: newSatisfied,
      );
    }
  }

  void submitQuestion() {
    if (state.puzzle == null || !state.isComplete) return;

    final isCorrect = state.puzzle!.isAllCorrect;
    final nextIndex = state.currentQuestionIndex + 1;
    final newCorrectCount = isCorrect ? state.correctQuestions + 1 : state.correctQuestions;

    // Record per-answer session stats
    ref.read(sessionStatsProvider.notifier).recordAnswer(
      'cross_numbers',
      isCorrect,
      state.elapsedSeconds,
      state.hintsUsed > 0,
    );

    // Record for dynamic difficulty
    ref.read(playerPerformanceProvider.notifier).recordAnswer(
      operation: 'cross_numbers',
      isCorrect: isCorrect,
      responseTimeMs: state.elapsedSeconds * 1000,
      hintsUsed: state.hintsUsed,
    );
    ref.read(dynamicDifficultyProvider.notifier).recordAssessment(isCorrect: isCorrect);

    if (nextIndex > state.totalQuestions) {
      // Calculate stars based on performance
      final accuracy = newCorrectCount / state.totalQuestions;
      int stars = 0;
      if (accuracy >= 0.95) {
        stars = 3;
      } else if (accuracy >= 0.8) {
        stars = 2;
      } else if (accuracy >= 0.6) {
        stars = 1;
      }

      // Save level progress
      final currentLevel = state.allPuzzles.isNotEmpty ? state.allPuzzles[0].difficulty : 1;
      ref.read(levelProgressRepositoryProvider).updateStars(
        'cross_numbers',
        currentLevel,
        stars,
        newCorrectCount,
      );

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
    if (state.puzzle != null && !state.isLevelFinished) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    }
  }

  void useHint() {
    if (state.puzzle == null || state.isLevelFinished) return;
    
    // Check points
    final user = ref.read(userSessionProvider);
    if ((user?.totalPoints ?? 0) < 50) return;

    // Find a random editable cell that is either empty or incorrect
    final editableCells = <CrossNumbersCell>[];
    for (var row in state.puzzle!.grid) {
      for (var cell in row) {
        if (cell.isUserEditable && (cell.userValue.isEmpty || cell.userValue != cell.value)) {
          editableCells.add(cell);
        }
      }
    }

    if (editableCells.isEmpty) return;

    final target = editableCells[Random().nextInt(editableCells.length)];
    
    // Create new grid with revealed hint
    final newGrid = List<List<CrossNumbersCell>>.from(
      state.puzzle!.grid.map((row) => List<CrossNumbersCell>.from(row))
    );
    
    newGrid[target.row][target.col] = newGrid[target.row][target.col].copyWith(
      userValue: target.value,
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
      isComplete: newPuzzle.isComplete,
      hintsUsed: state.hintsUsed + 1,
      satisfiedEquations: _getSatisfiedEquations(newPuzzle),
    );

    ref.read(userSessionProvider.notifier).addPoints(-50);
    ref.read(soundManagerProvider).playEffect('hint');
  }

  void resetLevel() {
    if (state.puzzle != null) {
      initLevel(state.puzzle!.difficulty);
    }
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
            'You': 0,
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
    
    // Update leaderboard with user's score if it's a high score
    final currentScore = state.score;
    if (currentScore > 0) {
      final newLeaderboard = Map<String, int>.from(state.leaderboard);
      final userScore = newLeaderboard['You'] ?? 0;
      if (currentScore > userScore) {
        newLeaderboard['You'] = currentScore;
        state = state.copyWith(leaderboard: newLeaderboard);
      }
    }
  }

  void reset() {
    state = ChallengeModeState(
      leaderboard: {
        'You': state.leaderboard['You'] ?? 0,
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

enum CustomMixMode { standard, suddenDeath, zen, timeAttack }

class CustomMixArithmeticState {
  final bool isActive;
  final bool isFinished;
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
  final CustomMixMode mode;
  final int timeLimit; // seconds, 0 for no limit
  final int remainingTime;
  final int targetQuestions; // 0 for unlimited
  final bool isPaused;
  final double averageResponseTime;
  final List<double> responseTimes;

  CustomMixArithmeticState({
    this.isActive = false,
    this.isFinished = false,
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
    this.mode = CustomMixMode.standard,
    this.timeLimit = 0,
    this.remainingTime = 0,
    this.targetQuestions = 0,
    this.isPaused = false,
    this.averageResponseTime = 0.0,
    this.responseTimes = const [],
  });

  CustomMixArithmeticState copyWith({
    bool? isActive,
    bool? isFinished,
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
    CustomMixMode? mode,
    int? timeLimit,
    int? remainingTime,
    int? targetQuestions,
    bool? isPaused,
    double? averageResponseTime,
    List<double>? responseTimes,
  }) {
    return CustomMixArithmeticState(
      isActive: isActive ?? this.isActive,
      isFinished: isFinished ?? this.isFinished,
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
      mode: mode ?? this.mode,
      timeLimit: timeLimit ?? this.timeLimit,
      remainingTime: remainingTime ?? this.remainingTime,
      targetQuestions: targetQuestions ?? this.targetQuestions,
      isPaused: isPaused ?? this.isPaused,
      averageResponseTime: averageResponseTime ?? this.averageResponseTime,
      responseTimes: responseTimes ?? this.responseTimes,
    );
  }
}

class CustomMixArithmeticNotifier extends StateNotifier<CustomMixArithmeticState> {
  final Ref _ref;
  final Random _random = Random();
  Timer? _timer;
  DateTime? _questionStartTime;

  CustomMixArithmeticNotifier(this._ref) : super(CustomMixArithmeticState());

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

  void setMode(CustomMixMode mode) {
    state = state.copyWith(mode: mode);
    if (mode == CustomMixMode.timeAttack && state.timeLimit == 0) {
      state = state.copyWith(timeLimit: 60);
    }
  }

  void setTimeLimit(int seconds) {
    state = state.copyWith(timeLimit: seconds);
  }

  void setTargetQuestions(int count) {
    state = state.copyWith(targetQuestions: count);
  }

  void startMix({List<MathRiddle>? preloadedQuestions}) {
    if (state.selectedOperations.isEmpty) return;
    
    _timer?.cancel();
    
    final firstQuestion = (preloadedQuestions != null && preloadedQuestions.isNotEmpty) 
        ? preloadedQuestions.first 
        : _generateMixedQuestion();

    state = state.copyWith(
      isActive: true,
      isFinished: false,
      currentQuestion: firstQuestion,
      questionsCompleted: 0,
      correctAnswers: 0,
      currentStreak: 0,
      bestStreak: state.bestStreak,
      questionHistory: [],
      lastAnswerCorrect: null,
      canUndo: false,
      reactionMessage: null,
      questionAnswered: false,
      sessionStartTime: DateTime.now(),
      remainingTime: state.timeLimit,
      isPaused: false,
      responseTimes: [],
      averageResponseTime: 0,
    );

    _questionStartTime = DateTime.now();

    if (state.timeLimit > 0) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isPaused || !state.isActive) return;
      
      if (state.remainingTime > 0) {
        state = state.copyWith(remainingTime: state.remainingTime - 1);
      } else {
        timer.cancel();
        endMix();
      }
    });
  }

  void togglePause() {
    state = state.copyWith(isPaused: !state.isPaused);
  }

  void answerQuestion(String answer) {
    if (!state.isActive || state.currentQuestion == null || state.questionAnswered) return;

    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds / 1000.0;
    final isCorrect = answer == state.currentQuestion!.correctAnswer;
    
    // Sudden Death logic
    if (state.mode == CustomMixMode.suddenDeath && !isCorrect) {
      _handleSuddenDeath(answer);
      return;
    }

    final newStreak = isCorrect ? state.currentStreak + 1 : 0;
    final newBestStreak = newStreak > state.bestStreak ? newStreak : state.bestStreak;
    
    final newResponseTimes = List<double>.from(state.responseTimes)..add(responseTime);
    final avgResponseTime = newResponseTimes.reduce((a, b) => a + b) / newResponseTimes.length;

    final historyEntry = {
      'question': state.currentQuestion!,
      'userAnswer': answer,
      'wasCorrect': isCorrect,
      'previousStreak': state.currentStreak,
      'previousCorrectAnswers': state.correctAnswers,
      'previousQuestionsCompleted': state.questionsCompleted,
      'responseTime': responseTime,
    };

    final newHistory = List<Map<String, dynamic>>.from(state.questionHistory)..add(historyEntry);

    String reaction;
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
      reaction = state.currentStreak >= 5 ? '💔 STREAK BROKEN!' : '❌ INCORRECT!';
    }

    state = state.copyWith(
      questionsCompleted: state.questionsCompleted + 1,
      correctAnswers: state.correctAnswers + (isCorrect ? 1 : 0),
      currentStreak: newStreak,
      bestStreak: newBestStreak,
      questionHistory: newHistory,
      lastAnswerCorrect: isCorrect,
      canUndo: state.mode != CustomMixMode.suddenDeath,
      reactionMessage: reaction,
      questionAnswered: true,
      responseTimes: newResponseTimes,
      averageResponseTime: avgResponseTime,
    );

    _recordStats(isCorrect, (responseTime * 1000).toInt());

    // Update performance trends in real-time
    _ref.read(performanceTrendsProvider.notifier).addDataPoint(
      isCorrect ? 100.0 : 0.0,
      (responseTime * 1000).toInt(),
      newStreak,
      heat: 1.0, // Default or derived if needed
    );

    if (state.targetQuestions > 0 && state.questionsCompleted >= state.targetQuestions) {
      // Auto next or end? Usually auto-next until the last one is answered.
      // If we've reached the target, we'll let the user see the result then they can click finish or next (which might end it).
    }
  }

  void _handleSuddenDeath(String answer) {
    state = state.copyWith(
      lastAnswerCorrect: false,
      reactionMessage: '💀 SUDDEN DEATH - GAME OVER',
      questionAnswered: true,
      questionsCompleted: state.questionsCompleted + 1,
    );
    _timer?.cancel();
    // Maybe show a specific dialog or end after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) endMix();
    });
  }

  void _recordStats(bool isCorrect, int responseTimeMs) {
    const operation = 'mixed';
    _ref.read(sessionStatsProvider.notifier).recordAnswer(operation, isCorrect, responseTimeMs, false);
    _ref.read(playerPerformanceProvider.notifier).recordAnswer(
      operation: operation,
      isCorrect: isCorrect,
      responseTimeMs: responseTimeMs,
      hintsUsed: 0,
    );
    _ref.read(dynamicDifficultyProvider.notifier).recordAssessment(isCorrect: isCorrect);
  }

  void endMix() {
    _timer?.cancel();
    if (state.questionsCompleted > 0 && state.sessionStartTime != null) {
      final duration = DateTime.now().difference(state.sessionStartTime!).inSeconds;
      final selectedOps = state.selectedOperations.map((op) => op.name).join(',');
      _ref.read(analyticsProvider.notifier).recordSession(
        selectedOps,
        duration,
        state.questionsCompleted,
        state.correctAnswers,
        0,
        mode: 'customMix',
      );

      // Add points based on performance
      final points = (state.correctAnswers * 10) + (state.bestStreak * 5);
      if (points > 0) {
        _ref.read(userSessionProvider.notifier).addPoints(points);
      }
    }

    state = state.copyWith(
      isActive: false,
      isFinished: true,
      sessionStartTime: null,
      isPaused: false,
    );
  }

  void resetMix() {
    _timer?.cancel();
    state = CustomMixArithmeticState();
  }

  void undoLastAnswer() {
    if (!state.canUndo || state.questionHistory.isEmpty || state.mode == CustomMixMode.suddenDeath) return;

    final lastEntry = state.questionHistory.last;
    final newHistory = List<Map<String, dynamic>>.from(state.questionHistory)..removeLast();
    
    final newResponseTimes = List<double>.from(state.responseTimes);
    if (newResponseTimes.isNotEmpty) newResponseTimes.removeLast();
    final avgResponseTime = newResponseTimes.isEmpty ? 0.0 : newResponseTimes.reduce((a, b) => a + b) / newResponseTimes.length;

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
      responseTimes: newResponseTimes,
      averageResponseTime: avgResponseTime,
    );
    _questionStartTime = DateTime.now();
  }

  void nextQuestion({MathRiddle? preloadedQuestion}) {
    if (!state.isActive) return;
    
    if (state.targetQuestions > 0 && state.questionsCompleted >= state.targetQuestions) {
      endMix();
      return;
    }

    state = state.copyWith(
      currentQuestion: preloadedQuestion ?? _generateMixedQuestion(),
      lastAnswerCorrect: null,
      canUndo: false,
      reactionMessage: null,
      questionAnswered: false,
    );
    _questionStartTime = DateTime.now();
  }

  MathRiddle _generateMixedQuestion() {
    final operation = state.selectedOperations[_random.nextInt(state.selectedOperations.length)];
    
    // Occasionally generate more complex problems for higher difficulty
    if (state.selectedDifficulty > 15 && _random.nextDouble() > 0.7) {
       return _generateMultiStepArithmetic(state.selectedDifficulty);
    }
    
    return _generateCustomArithmetic(operation, state.selectedDifficulty);
  }

  MathRiddle _generateMultiStepArithmetic(int difficulty) {
    // Implementation for (a + b) * c or similar
    // For now, fall back to standard but maybe with larger numbers
    final op1 = state.selectedOperations[_random.nextInt(state.selectedOperations.length)];
    return _generateCustomArithmetic(op1, (difficulty * 1.2).toInt().clamp(1, 30));
  }

  void clearReaction() {
    state = state.copyWith(reactionMessage: null);
  }

  MathRiddle _generateCustomArithmetic(ArithmeticOperation operation, int difficulty) {
    int num1, num2, answer;
    String operatorStr;

    // Scale numbers based on difficulty and operation (support up to level 30)
    switch (difficulty) {
      case 1:
      case 2:
        num1 = _random.nextInt(10) + 1;
        num2 = _random.nextInt(10) + 1;
        break;
      case 3:
      case 4:
        num1 = _random.nextInt(25) + 5;
        num2 = _random.nextInt(20) + 1;
        break;
      case 5:
      case 6:
        num1 = _random.nextInt(50) + 10;
        num2 = _random.nextInt(25) + 5;
        break;
      case 7:
      case 8:
        num1 = _random.nextInt(100) + 20;
        num2 = _random.nextInt(50) + 10;
        break;
      case 9:
      case 10:
        num1 = _random.nextInt(200) + 50;
        num2 = _random.nextInt(100) + 20;
        break;
      case 11:
      case 12:
        num1 = _random.nextInt(300) + 100;
        num2 = _random.nextInt(150) + 50;
        break;
      case 13:
      case 14:
        num1 = _random.nextInt(500) + 200;
        num2 = _random.nextInt(200) + 100;
        break;
      default:
        // Levels 15-30: Very challenging numbers
        num1 = _random.nextInt(1000) + 500;
        num2 = _random.nextInt(500) + 200;
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
        // Scale based on difficulty
        int maxMult = difficulty <= 5 ? 12 : (difficulty <= 10 ? 15 : (difficulty <= 20 ? 20 : 25));
        int minMult = difficulty <= 3 ? 2 : (difficulty <= 8 ? 3 : 4);
        num1 = _random.nextInt(maxMult - minMult + 1) + minMult;
        num2 = _random.nextInt(maxMult - minMult + 1) + minMult;
        answer = num1 * num2;
        operatorStr = '×';
        break;
      case ArithmeticOperation.division:
        // Ensure clean division with larger numbers for higher levels
        int divisorRange = difficulty <= 5 ? 10 : (difficulty <= 10 ? 15 : (difficulty <= 20 ? 20 : 30));
        num2 = _random.nextInt(divisorRange - 2) + 2;
        int quotientRange = difficulty <= 5 ? 10 : (difficulty <= 10 ? 15 : (difficulty <= 20 ? 25 : 50));
        answer = _random.nextInt(quotientRange) + 2;
        num1 = num2 * answer;
        operatorStr = '÷';
        break;
    }

// Build question with context based on difficulty
    String question;
    if (difficulty <= 5) {
      question = '$num1 $operatorStr $num2 = ?';
    } else if (difficulty <= 10) {
      final contexts = [
        'Calculate: ',
        'What is ',
        'Solve: ',
        'Find the result of ',
      ];
      question = '${contexts[_random.nextInt(contexts.length)]}$num1 $operatorStr $num2 = ?';
    } else if (difficulty <= 20) {
      // Add more complex word problems
      final contexts = [
        'In a calculation: ',
        'The result of ',
        'Compute ',
        'Evaluate ',
        'Calculate the following: ',
      ];
      question = '${contexts[_random.nextInt(contexts.length)]}$num1 $operatorStr $num2 = ?';
    } else {
      // Very challenging - complex expressions
      final contexts = [
        'Advanced calculation: ',
        'Complex problem: ',
        'Challenging: ',
        'Expert level: ',
        'Find the exact value: ',
      ];
      question = '${contexts[_random.nextInt(contexts.length)]}$num1 $operatorStr $num2 = ?';
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
        case 2:
          offset = _random.nextInt(10) - 5;
          break;
        case 3:
        case 4:
          offset = _random.nextInt(20) - 10;
          break;
        case 5:
        case 6:
          offset = _random.nextInt(25) - 12;
          break;
        case 7:
        case 8:
          offset = _random.nextInt(30) - 15;
          break;
        default:
          offset = _random.nextInt(40) - 20;
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

