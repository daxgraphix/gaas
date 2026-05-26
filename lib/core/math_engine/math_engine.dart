import 'dart:math';
import '../constants/app_constants.dart';
import 'advanced_topics_engine.dart';

class MathQuestion {
  final int operand1;
  final int operand2;
  final int? operand3;
  final String operation;
  final int correctAnswer;
  final String difficulty;
  final String? hint;

  MathQuestion({
    required this.operand1,
    required this.operand2,
    this.operand3,
    required this.operation,
    required this.correctAnswer,
    this.difficulty = 'medium',
    this.hint,
  });

  String get displayString {
    final symbol = AppConstants.operationSymbols[operation] ?? '+';
    if (operand3 != null) {
      return '$operand1 $symbol $operand2 $symbol $operand3 = ?';
    }
    return '$operand1 $symbol $operand2 = ?';
  }
}

class MathEngine {
  static final Random _random = Random();
  static final Map<String, List<MathQuestion>> _questionCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 30);

  static (int min, int max) getNumberRange(int level, String operation) {
    final l = level.toDouble();
    final minVal = pow(10, l / 10).toInt().clamp(1, 100);
    final maxVal = pow(10, (l + 5) / 10).toInt().clamp(10, 1000);
    return (minVal, maxVal);
  }

  // Performance optimization: Cache frequently generated questions
  static List<MathQuestion> _getCachedQuestions(String operation, int level, int count) {
    final cacheKey = '${operation}_${level}_$count';
    final now = DateTime.now();

    if (_questionCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        now.difference(_cacheTimestamps[cacheKey]!) < _cacheExpiry) {
      return List.from(_questionCache[cacheKey]!);
    }

    return [];
  }

  static void _cacheQuestions(String operation, int level, int count, List<MathQuestion> questions) {
    final cacheKey = '${operation}_${level}_$count';
    _questionCache[cacheKey] = List.from(questions);
    _cacheTimestamps[cacheKey] = DateTime.now();

    // Limit cache size to prevent memory issues
    if (_questionCache.length > 50) {
      final oldestKey = _cacheTimestamps.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _questionCache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
    }
  }

  // Memory cleanup method
  static void clearCache() {
    _questionCache.clear();
    _cacheTimestamps.clear();
  }

  static MathQuestion generateQuestion(
    String operation,
    int level, {
    bool isArcade = false,
    Set<String>? excludeQuestions,
  }) {
    // Handle advanced topics
    if (['fractions', 'decimals', 'geometry', 'word_problems'].contains(operation)) {
      return _generateAdvancedQuestion(operation, level);
    }

    MathQuestion question;
    int attempts = 0;

    do {
      if (isArcade) {
        question = _generateArcadeQuestion(operation, level);
      } else {
        final (min, max) = getNumberRange(level, operation);
        switch (operation) {
          case 'addition':
            question = _generateAddition(min, max, level);
            break;
          case 'subtraction':
            question = _generateSubtraction(min, max, level);
            break;
          case 'multiplication':
            question = _generateMultiplication(level);
            break;
          case 'division':
            question = _generateDivision(level);
            break;
          default:
            question = _generateAddition(min, max, level);
        }
      }
      attempts++;
    } while (excludeQuestions != null && excludeQuestions.contains(question.displayString) && attempts < 50);

    return question;
  }

  // Optimized batch question generation for better performance
  static List<MathQuestion> generateQuestionsBatch(
    String operation,
    int level,
    int count, {
    bool isArcade = false,
    bool useCache = true,
  }) {
    if (useCache && !isArcade) {
      final cached = _getCachedQuestions(operation, level, count);
      if (cached.isNotEmpty) {
        return cached;
      }
    }

    final questions = <MathQuestion>{};
    final excludeSet = <String>{};
    int attempts = 0;
    const maxAttempts = 1000; // Prevent infinite loops

    while (questions.length < count && attempts < maxAttempts) {
      final question = generateQuestion(
        operation,
        level,
        isArcade: isArcade,
        excludeQuestions: excludeSet,
      );

      if (!excludeSet.contains(question.displayString)) {
        questions.add(question);
        excludeSet.add(question.displayString);
      }

      attempts++;
    }

    final result = questions.toList();
    if (useCache && !isArcade && result.length == count) {
      _cacheQuestions(operation, level, count, result);
    }

    return result;
  }

  static MathQuestion _generateArcadeQuestion(String operation, int level) {
    final difficulty = _getArcadeDifficulty(level);

    switch (operation) {
      case 'addition':
        return _generateArcadeAddition(difficulty);
      case 'subtraction':
        return _generateArcadeSubtraction(difficulty);
      case 'multiplication':
        return _generateArcadeMultiplication(difficulty);
      case 'division':
        return _generateArcadeDivision(difficulty);
      default:
        return _generateArcadeAddition(difficulty);
    }
  }

  static String _getArcadeDifficulty(int level) {
    if (level <= 5) return 'easy';
    if (level <= 15) return 'medium';
    if (level <= 25) return 'hard';
    return 'expert';
  }

  static MathQuestion _generateArcadeAddition(String difficulty) {
    int min, max;
    switch (difficulty) {
      case 'easy':
        min = 1;
        max = 99;  // Single to double digits
        break;
      case 'medium':
        min = 10;
        max = 499; // Double digits
        break;
      case 'hard':
        min = 100;
        max = 999; // Triple digits
        break;
      case 'expert':
      default:
        min = 500;
        max = 9999; // Large triple digits
    }

    final a = _random.nextInt(max - min + 1) + min;
    final b = _random.nextInt(max - min + 1) + min;
    final result = a + b;
    return MathQuestion(
      operand1: a,
      operand2: b,
      operation: 'addition',
      correctAnswer: result,
      difficulty: difficulty,
      hint: 'Ends with ${result % 10}',
    );
  }

  static MathQuestion _generateArcadeSubtraction(String difficulty) {
    int min, max;
    switch (difficulty) {
      case 'easy':
        min = 1;
        max = 99;  // Single to double digits
        break;
      case 'medium':
        min = 10;
        max = 499; // Double digits
        break;
      case 'hard':
        min = 100;
        max = 999; // Triple digits
        break;
      case 'expert':
      default:
        min = 500;
        max = 9999; // Large triple digits
    }

    var a = _random.nextInt(max - min + 1) + min;
    var b = _random.nextInt(max - min + 1) + min;
    if (a < b) {
      final temp = a;
      a = b;
      b = temp;
    }
    final result = a - b;
    return MathQuestion(
      operand1: a,
      operand2: b,
      operation: 'subtraction',
      correctAnswer: result,
      difficulty: difficulty,
      hint: 'Ends with ${result % 10}',
    );
  }

  static MathQuestion _generateArcadeMultiplication(String difficulty) {
    int maxFactor;
    switch (difficulty) {
      case 'easy':
        maxFactor = 12;  // Single digit multiplication
        break;
      case 'medium':
        maxFactor = 25;  // Up to double digits
        break;
      case 'hard':
        maxFactor = 50;  // Larger double digits
        break;
      case 'expert':
      default:
        maxFactor = 99;  // Triple digit results possible
    }

    final a = _random.nextInt(maxFactor) + 2;
    final b = _random.nextInt(maxFactor) + 2;
    final result = a * b;
    return MathQuestion(
      operand1: a,
      operand2: b,
      operation: 'multiplication',
      correctAnswer: result,
      difficulty: difficulty,
      hint: 'Starts with ${result.toString()[0]}',
    );
  }

  static MathQuestion _generateArcadeDivision(String difficulty) {
    int maxDivisor;
    switch (difficulty) {
      case 'easy':
        maxDivisor = 12;  // Single digit division
        break;
      case 'medium':
        maxDivisor = 25;  // Up to double digits
        break;
      case 'hard':
        maxDivisor = 50;  // Larger double digits
        break;
      case 'expert':
      default:
        maxDivisor = 99;  // Triple digit dividends possible
    }

    final divisor = _random.nextInt(maxDivisor) + 2;
    final quotient = _random.nextInt(maxDivisor) + 2;
    final dividend = divisor * quotient;

    return MathQuestion(
      operand1: dividend,
      operand2: divisor,
      operation: 'division',
      correctAnswer: quotient,
      difficulty: difficulty,
      hint: 'Result is $quotient',
    );
  }

  static MathQuestion _generateAddition(int min, int max, int level) {
    // Campaign specific scaling for addition - progressive difficulty
    final range = (10 + level * 15).clamp(20, 2000);
    final a = _random.nextInt(range) + 1;
    final b = _random.nextInt(range) + 1;
    final result = a + b;
    return MathQuestion(
      operand1: a,
      operand2: b,
      operation: 'addition',
      correctAnswer: result,
      hint: 'Ends with ${result % 10}',
    );
  }

  static MathQuestion _generateSubtraction(int min, int max, int level) {
    // Campaign specific scaling for subtraction - progressive difficulty
    final range = (10 + level * 15).clamp(20, 2000);
    var a = _random.nextInt(range) + 5;
    var b = _random.nextInt(range) + 2;
    if (a < b) {
      final temp = a;
      a = b;
      b = temp;
    }
    final result = a - b;
    return MathQuestion(
      operand1: a,
      operand2: b,
      operation: 'subtraction',
      correctAnswer: result,
      hint: 'Ends with ${result % 10}',
    );
  }

  static MathQuestion _generateMultiplication(int level) {
    int maxFactor;
    if (level <= 10) {
      maxFactor = 10 + level;  // Single digits
    } else if (level <= 20) {
      maxFactor = 20 + (level - 10) * 3;  // Up to double digits
    } else if (level <= 30) {
      maxFactor = 50 + (level - 20) * 5;  // Triple digits
    } else {
      maxFactor = 100 + (level - 30) * 10;  // Large numbers
    }

    final a = _random.nextInt(maxFactor.clamp(2, 50)) + 1;
    final b = _random.nextInt(maxFactor.clamp(2, 50)) + 1;
    final result = a * b;
    return MathQuestion(
      operand1: a,
      operand2: b,
      operation: 'multiplication',
      correctAnswer: result,
      hint: 'Ends with ${result % 10}',
    );
  }

  static MathQuestion _generateDivision(int level) {
    int maxDivisor;
    if (level <= 10) {
      maxDivisor = 10 + level;  // Single digits
    } else if (level <= 20) {
      maxDivisor = 20 + (level - 10) * 2;  // Up to double digits
    } else if (level <= 30) {
      maxDivisor = 40 + (level - 20) * 3;  // Triple digits
    } else {
      maxDivisor = 70 + (level - 30) * 5;  // Large numbers
    }

    final divisor = _random.nextInt(maxDivisor.clamp(2, 30)) + 1;
    final quotient = _random.nextInt(maxDivisor.clamp(2, 30)) + 1;
    final dividend = divisor * quotient;

    return MathQuestion(
      operand1: dividend,
      operand2: divisor,
      operation: 'division',
      correctAnswer: quotient,
      hint: 'Result is $quotient',
    );
  }

  static int calculateStars(int correctAnswers, int totalQuestions) {
    final percentage = (correctAnswers / totalQuestions) * 100;
    if (percentage >= 90) return 3;
    if (percentage >= 70) return 2;
    if (percentage >= 50) return 1;
    return 0;
  }

  static int generateVisualCount(int level) {
    final (min, max) = getNumberRange(level, 'addition');
    return _random.nextInt(max ~/ 2 - min ~/ 2 + 1) + min ~/ 2;
  }

  static int getAIAnswerTime(String operation, int level) {
    final baseTime = 3000;
    final difficultyReduction = (level * 100).clamp(0, 2000);
    final operationMultiplier = switch (operation) {
      'addition' => 1.0,
      'subtraction' => 1.1,
      'multiplication' => 1.5,
      'division' => 1.8,
      _ => 1.0,
    };
    return ((baseTime - difficultyReduction) * operationMultiplier)
        .toInt()
        .clamp(500, 3000);
  }

  static MathQuestion _generateAdvancedQuestion(String operation, int level) {
    // Generate advanced topic questions using the AdvancedTopicsEngine
    final riddle = switch (operation) {
      'fractions' => AdvancedTopicsEngine.generateFractionsProblem(level),
      'decimals' => AdvancedTopicsEngine.generateDecimalsProblem(level),
      'geometry' => AdvancedTopicsEngine.generateGeometryProblem(level),
      'word_problems' => AdvancedTopicsEngine.generateWordProblem(level),
      _ => AdvancedTopicsEngine.generateFractionsProblem(level),
    };

    // Convert MathRiddle to MathQuestion format
    return MathQuestion(
      operand1: 0, // Not used for advanced topics
      operand2: 0, // Not used for advanced topics
      operation: operation,
      correctAnswer: int.tryParse(riddle.correctAnswer) ?? 0,
      difficulty: level <= 3 ? 'easy' : level <= 6 ? 'medium' : 'hard',
      hint: riddle.progressiveHints.isNotEmpty ? riddle.progressiveHints.first : null,
    );
  }
}
