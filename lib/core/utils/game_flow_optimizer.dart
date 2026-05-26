import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/game_adaptability/dynamic_difficulty_system.dart';
import '../math_engine/math_engine.dart';

class GameFlowOptimizer {
  static final Map<String, Completer<void>> _loadingCompleters = {};
  static final Map<String, dynamic> _preloadCache = {};

  // Preload questions for smoother game transitions
  static Future<void> preloadQuestions({
    required String operation,
    required int level,
    int count = 10,
    bool isArcade = false,
  }) async {
    final key = '${operation}_${level}_${count}_$isArcade';

    if (_loadingCompleters.containsKey(key)) {
      return _loadingCompleters[key]!.future;
    }

    final completer = Completer<void>();
    _loadingCompleters[key] = completer;

    try {
      // Use batch generation for better performance
      final questions = MathEngine.generateQuestionsBatch(
        operation,
        level,
        count,
        isArcade: isArcade,
      );

      _preloadCache[key] = questions;
      completer.complete();
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }

  // Get preloaded questions
  static List<MathQuestion>? getPreloadedQuestions({
    required String operation,
    required int level,
    int count = 10,
    bool isArcade = false,
  }) {
    final key = '${operation}_${level}_${count}_$isArcade';
    return _preloadCache[key] as List<MathQuestion>?;
  }

  // Clear preload cache to free memory
  static void clearPreloadCache() {
    _preloadCache.clear();
    _loadingCompleters.clear();
  }

  // Smooth transition builder for game screens
  static Widget buildTransition({
    required BuildContext context,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      child: child,
    );
  }

  // Optimized loading indicator with platform-specific styling
  static Widget buildPlatformLoadingIndicator(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return const CircularProgressIndicator();
    } else {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
  }

  // Memory-efficient game session management
  static void optimizeMemoryUsage() {
    // Clear caches periodically
    Timer.periodic(const Duration(minutes: 5), (_) {
      clearPreloadCache();
      MathEngine.clearCache();
    });
  }
}

class GameDynamicsController {
  static const int maxStreakBonus = 5;
  static const double maxPerformanceMultiplier = 2.0;

  // Calculate adaptive difficulty based on recent performance
  static double calculateAdaptiveDifficulty({
    required List<bool> recentAnswers,
    required int currentStreak,
    required double averageResponseTime,
  }) {
    if (recentAnswers.isEmpty) return 1.0;

    final recentAccuracy = recentAnswers.where((answer) => answer).length / recentAnswers.length;

    // Base difficulty from accuracy
    double difficulty = recentAccuracy;

    // Streak bonus
    final streakMultiplier = 1.0 + (currentStreak.clamp(0, maxStreakBonus) * 0.1);

    // Response time factor (faster answers = higher difficulty)
    final timeFactor = (5000 / averageResponseTime.clamp(500, 5000)).clamp(0.5, 1.5);

    difficulty = difficulty * streakMultiplier * timeFactor;

    return difficulty.clamp(0.3, maxPerformanceMultiplier);
  }

  // Adaptive hint system
  static bool shouldShowHint({
    required int hintsUsed,
    required int totalQuestions,
    required double accuracy,
    required int currentStreak,
  }) {
    // Show hints more frequently for struggling players
    if (accuracy < 0.5) return true;
    if (currentStreak < 2) return true;

    // Limit hints for high performers
    final hintRatio = hintsUsed / totalQuestions;
    return hintRatio < 0.3 && accuracy < 0.8;
  }

  // Dynamic scoring based on performance
  static int calculateDynamicScore({
    required bool isCorrect,
    required int basePoints,
    required int currentStreak,
    required double responseTime,
    required DifficultyLevel difficulty,
  }) {
    if (!isCorrect) return 0;

    double score = basePoints.toDouble();

    // Streak multiplier
    score *= (1.0 + currentStreak * 0.1).clamp(1.0, 2.0);

    // Time bonus (faster answers get more points)
    final timeBonus = (3000 / responseTime.clamp(500, 3000)).clamp(1.0, 1.5);
    score *= timeBonus;

    // Difficulty multiplier
    score *= difficulty.scoreMultiplier;

    return score.round();
  }

  // Performance-based encouragement system
  static String getEncouragementMessage({
    required double accuracy,
    required int streak,
    required int totalQuestions,
  }) {
    if (accuracy >= 0.9 && streak >= 5) {
      return "Outstanding! You're a math superstar! 🌟";
    } else if (accuracy >= 0.8 && streak >= 3) {
      return "Excellent work! Keep up the great performance! 🎯";
    } else if (accuracy >= 0.7) {
      return "Good job! You're doing really well! 👍";
    } else if (accuracy >= 0.6) {
      return "Nice effort! Keep practicing and you'll improve! 💪";
    } else if (totalQuestions > 5) {
      return "Don't worry! Every expert was once a beginner. Try again! 🌱";
    } else {
      return "Let's get started! You've got this! 🚀";
    }
  }
}

class CrossPlatformNavigator {
  static Future<T?> navigateWithLoading<T>(
    BuildContext context,
    WidgetBuilder builder, {
    Duration loadingDelay = const Duration(milliseconds: 100),
  }) async {
    // Show loading indicator briefly for better UX
    if (loadingDelay > Duration.zero) {
      await Future.delayed(loadingDelay);
    }

    // Check if context is still mounted after async operation
    if (!context.mounted) return null;

    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GameFlowOptimizer.buildPlatformLoadingIndicator(context),
                const SizedBox(height: 16),
                const Text('Loading game...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void navigateSmoothly(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}