import 'dart:math';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../../data/models/math_riddle.dart';

class MathQuestion {
  final int operand1;
  final int operand2;
  final int? operand3;
  final String operation;
  final dynamic correctAnswer;
  final String difficulty;
  final String? hint;
  final String? customQuestion;
  final List<String>? options;

  MathQuestion({
    required this.operand1,
    required this.operand2,
    this.operand3,
    required this.operation,
    required this.correctAnswer,
    this.difficulty = 'medium',
    this.hint,
    this.customQuestion,
    this.options,
  });

  String get displayString {
    if (customQuestion != null) return customQuestion!;
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
    // Scale ranges more aggressively for 100 levels
    // Level 1: [2, 12], Level 50: [100, 1000], Level 100: [1000, 10000]
    final minVal = pow(10, l / 33.3 + 0.3).toInt().clamp(2, 2000);
    final maxVal = pow(10, l / 33.3 + 1.1).toInt().clamp(12, 10000);
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
    int skillRating = 1000,
    double heatIndex = 1.0,
  }) {
    // Handle advanced topics
    if (['logic'].contains(operation)) {
      return _generateAdvancedQuestion(operation, level);
    }

    final isBoss = level % 10 == 0 && !isArcade;
    MathQuestion question;
    int attempts = 0;

    // Adjust effective level based on skill rating and real-time heat
    // Heat index > 1.0 boosts the effective difficulty for the session
    final heatBonus = (heatIndex > 1.0) ? (heatIndex - 1.0) * 5 : 0;
    final effectiveLevel = (level + (skillRating - 1000) ~/ 200 + heatBonus.toInt()).clamp(1, 100);

    do {
      if (isArcade) {
        question = _generateArcadeQuestion(operation, effectiveLevel);
      } else if (isBoss) {
        question = _generateBossQuestion(operation, effectiveLevel);
      } else {
        final (min, max) = getNumberRange(effectiveLevel, operation);
        
        // Dynamic complexity: if skill is high OR heat is high, potentially add a third operand
        // High heat makes the chance for 3 operands increase up to 70%
        final threeOperandChance = (0.3 * heatIndex).clamp(0.1, 0.7);
        final useThreeOperands = (skillRating > 1400 || heatIndex > 1.5) && 
                                 _random.nextDouble() < threeOperandChance;

        switch (operation) {
          case 'addition':
            question = useThreeOperands 
                ? _generateThreeOperandAddition(min, max, effectiveLevel)
                : _generateAddition(min, max, effectiveLevel);
            break;
          case 'subtraction':
            question = _generateSubtraction(min, max, effectiveLevel);
            break;
          case 'multiplication':
            question = _generateMultiplication(effectiveLevel);
            break;
          case 'division':
            question = _generateDivision(effectiveLevel);
            break;
          default:
            question = _generateAddition(min, max, effectiveLevel);
        }
      }
      attempts++;
    } while (excludeQuestions != null && excludeQuestions.contains(question.displayString) && attempts < 50);

    return question;
  }

  static MathQuestion _generateThreeOperandAddition(int min, int max, int level) {
    final range = (10 + level * 10).clamp(10, 500);
    final a = _random.nextInt(range) + 1;
    final b = _random.nextInt(range) + 1;
    final c = _random.nextInt(range) + 1;
    return MathQuestion(
      operand1: a,
      operand2: b,
      operand3: c,
      operation: 'addition',
      correctAnswer: a + b + c,
      difficulty: 'hard',
      hint: 'Sum of three numbers',
    );
  }

  // Optimized batch question generation for better performance
  static Future<List<MathQuestion>> generateQuestionsBatch(
    String operation,
    int level,
    int count, {
    bool isArcade = false,
    bool useCache = true,
    int skillRating = 1000,
    double heatIndex = 1.0,
  }) async {
    if (useCache && !isArcade) {
      final cached = _getCachedQuestions(operation, level, count);
      if (cached.isNotEmpty) {
        return cached;
      }
    }

    // Move heavy logic to background isolate for 60fps UI performance
    final result = await compute(_generateBatchIsolate, {
      'operation': operation,
      'level': level,
      'count': count,
      'isArcade': isArcade,
      'skillRating': skillRating,
      'heatIndex': heatIndex,
    });

    if (useCache && !isArcade && result.length == count) {
      _cacheQuestions(operation, level, count, result);
    }

    return result;
  }

  static List<MathQuestion> _generateBatchIsolate(Map<String, dynamic> params) {
    final String operation = params['operation'];
    final int level = params['level'];
    final int count = params['count'];
    final bool isArcade = params['isArcade'];
    final int skillRating = params['skillRating'] ?? 1000;
    final double heatIndex = params['heatIndex'] ?? 1.0;

    final questions = <MathQuestion>{};
    final excludeSet = <String>{};
    int attempts = 0;
    const maxAttempts = 1000;

    while (questions.length < count && attempts < maxAttempts) {
      final question = generateQuestion(
        operation,
        level,
        isArcade: isArcade,
        excludeQuestions: excludeSet,
        skillRating: skillRating,
        heatIndex: heatIndex,
      );

      if (!excludeSet.contains(question.displayString)) {
        questions.add(question);
        excludeSet.add(question.displayString);
      }

      attempts++;
    }
    return questions.toList();
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

  static MathQuestion _generateBossQuestion(String operation, int level) {
    // Boss levels use numbers from 5 levels ahead
    final (min, max) = getNumberRange(level + 5, operation);
    
    // Chapter 10 Boss (Level 100) or high levels ALWAYS use complex three-operand logic
    final bool isHighLevelBoss = level >= 90;
    final useThreeOperands = isHighLevelBoss || _random.nextDouble() < 0.4;

    if (useThreeOperands) {
      final op1 = _random.nextInt(max ~/ 2 - min + 1) + min;
      final op2 = _random.nextInt(max ~/ 2 - min + 1) + min;
      final op3 = _random.nextInt(max ~/ 2 - min + 1) + min;
      
      int result;
      String opSymbol1 = '+';
      String opSymbol2 = '+';
      
      // Randomly mix operations for boss
      // At Chapter 10, we want guaranteed mixed operators
      final mixType = isHighLevelBoss ? _random.nextInt(3) : (_random.nextBool() ? 1 : 0);
      
      if (mixType == 1) {
        result = op1 + op2 - op3;
        opSymbol2 = '-';
      } else if (mixType == 2 && isHighLevelBoss) {
        // Guaranteed mixed: (a - b) + c or (a + b) - c
        if (_random.nextBool()) {
           result = op1 - op2 + op3;
           opSymbol1 = '-';
           opSymbol2 = '+';
        } else {
           result = op1 + op2 - op3;
           opSymbol1 = '+';
           opSymbol2 = '-';
        }
      } else {
        result = op1 + op2 + op3;
      }
      
      return MathQuestion(
        operand1: op1,
        operand2: op2,
        operand3: op3,
        operation: operation,
        correctAnswer: result,
        difficulty: isHighLevelBoss ? 'master' : 'expert',
        hint: isHighLevelBoss ? 'Ultimate Chapter Boss Challenge!' : 'Three-part calculation!',
        customQuestion: '$op1 $opSymbol1 $op2 $opSymbol2 $op3 = ?',
      );
    }

    // Default boss question with increased difficulty
    switch (operation) {
      case 'addition':
        return _generateAddition(min, max, level + 5);
      case 'subtraction':
        return _generateSubtraction(min, max, level + 5);
      case 'multiplication':
        return _generateMultiplication(level + 5);
      case 'division':
        return _generateDivision(level + 5);
      default:
        return _generateAddition(min, max, level + 5);
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
    // Level 1: ~20, Level 50: ~1000, Level 100: ~5000
    final range = (10 + pow(level, 1.35) * 10).toInt().clamp(20, 5000);
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
    final range = (10 + pow(level, 1.35) * 10).toInt().clamp(20, 5000);
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
      maxFactor = 10 + level;
    } else if (level <= 40) {
      maxFactor = 20 + (level - 10) * 2;
    } else if (level <= 70) {
      maxFactor = 80 + (level - 40) * 4;
    } else {
      maxFactor = 200 + (level - 70) * 8;
    }

    // Fixed the bug where factors were capped at 50 regardless of level
    final a = _random.nextInt(maxFactor.clamp(5, 500)) + 2;
    final b = _random.nextInt(maxFactor.clamp(2, 100)) + 1;
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
    int maxQuotient;
    if (level <= 10) {
      maxDivisor = 10;
      maxQuotient = 10;
    } else if (level <= 40) {
      maxDivisor = 12 + (level - 10);
      maxQuotient = 12 + (level - 10);
    } else if (level <= 70) {
      maxDivisor = 42 + (level - 40) * 2;
      maxQuotient = 42 + (level - 40) * 2;
    } else {
      maxDivisor = 100 + (level - 70) * 5;
      maxQuotient = 100 + (level - 70) * 5;
    }

    final divisor = _random.nextInt(maxDivisor.clamp(2, 250)) + 2;
    final quotient = _random.nextInt(maxQuotient.clamp(2, 250)) + 1;
    final dividend = divisor * quotient;

    return MathQuestion(
      operand1: dividend,
      operand2: divisor,
      operation: 'division',
      correctAnswer: quotient,
      difficulty: level <= 30 ? 'easy' : level <= 70 ? 'medium' : 'hard',
      hint: 'Result is $quotient',
    );
  }

  static int calculateStars(int correctAnswers, int totalQuestions) {
    final percentage = (correctAnswers / totalQuestions) * 100;
    if (percentage >= 95) return 3;
    if (percentage >= 85) return 2;
    if (percentage >= 75) return 1;
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
    final dynamic riddle = switch (operation) {
      'logic' => _generateMixedLogicChallenge(level),
      _ => _generateMixedLogicChallenge(level),
    };

    final List<String> hints = (riddle is MathRiddle) 
        ? riddle.progressiveHints 
        : (riddle is LogicMathChallenge)
                ? riddle.progressiveHints
                : [];

    final String questionText = (riddle is MathRiddle) 
        ? riddle.question 
        : (riddle is LogicMathChallenge)
                ? riddle.problem
                : '';

    return MathQuestion(
      operand1: 0,
      operand2: 0,
      operation: operation,
      correctAnswer: riddle.correctAnswer,
      difficulty: level <= 3 ? 'easy' : level <= 6 ? 'medium' : 'hard',
      hint: hints.isNotEmpty ? hints.first : null,
      customQuestion: questionText,
      options: riddle.options,
    );
  }

  static LogicMathChallenge _generateMixedLogicChallenge(int level) {
    if (level <= 3) {
      return _generateBasicLogic(level);
    } else if (level <= 6) {
      return _generateIntermediateLogic(level);
    } else {
      return _generateAdvancedLogic(level);
    }
  }

  static LogicMathChallenge _generateBasicLogic(int level) {
    final random = Random();
    final symbols = ['square', 'triangle', 'star', 'box', 'circle', 'diamond'];
    final a = symbols[random.nextInt(symbols.length)];
    final b = symbols[(random.nextInt(symbols.length))];
    final answer = random.nextInt(10) + 1;
    final operand = random.nextBool() ? '+' : '-';
    
    return LogicMathChallenge(
      id: 'logic_basic_${level}_${DateTime.now().millisecondsSinceEpoch}',
      problem: '$a $operand $b = $answer\n$a = 5\n$b = 3\nWhat is the result?',
      options: ['$answer', '${answer + 1}', '${answer - 1}', '${answer + 2}'],
      correctAnswer: '$answer',
      explanation: '$a = 5, $b = 3, so $a $operand $b = 5 $operand 3 = $answer.',
      progressiveHints: [
        'Substitute the values',
        '5 $operand 3 = $answer',
      ],
      difficulty: level,
      basePoints: 50 + level * 10,
    );
  }

  static LogicMathChallenge _generateIntermediateLogic(int level) {
    final random = Random();
    final symbols = ['square', 'triangle', 'star', 'box'];
    final a = symbols[random.nextInt(symbols.length)];
    final b = symbols[(random.nextInt(symbols.length))];
    final c = symbols[(random.nextInt(symbols.length))];
    
    final val1 = random.nextInt(5) + 2;
    final val2 = random.nextInt(5) + 2;
    final answer = val1 * val2;
    
    return LogicMathChallenge(
      id: 'logic_inter_${level}_${DateTime.now().millisecondsSinceEpoch}',
      problem: '$a × $b = $answer\n$a = $val1\n$b = $val2\nWhat is $c if $c = $a + $b?',
      options: ['${val1 + val2}', '${val1 + val2 + 1}', '${val1 + val2 - 1}', '${val1 * val2}'],
      correctAnswer: '${val1 + val2}',
      explanation: '$a = $val1, $b = $val2, so $c = $val1 + $val2 = ${val1 + val2}.',
      progressiveHints: [
        'Find $a and $b',
        '$a = $val1, $b = $val2',
        '$c = $a + $b = $val1 + $val2',
      ],
      difficulty: level,
      basePoints: 70 + level * 15,
    );
  }

  static LogicMathChallenge _generateAdvancedLogic(int level) {
    final random = Random();
    final symbols = ['square', 'triangle', 'star', 'box'];
    final a = symbols[random.nextInt(symbols.length)];
    final b = symbols[(random.nextInt(symbols.length))];
    final c = symbols[(random.nextInt(symbols.length))];
    
    final val1 = random.nextInt(5) + 3;
    final val2 = random.nextInt(4) + 2;
    final val3 = random.nextInt(4) + 2;
    final answer = val1 * val2 + val3;
    
    return LogicMathChallenge(
      id: 'logic_adv_${level}_${DateTime.now().millisecondsSinceEpoch}',
      problem: '$a × $b + $c = $answer\n$a = $val1\n$b = $val2\n$c = $val3\nWhat is $a + $b + $c?',
      options: ['${val1 + val2 + val3}', '${val1 + val2 + val3 + 1}', '${val1 + val2 + val3 - 1}', '${val1 * val2 * val3}'],
      correctAnswer: '${val1 + val2 + val3}',
      explanation: '$a = $val1, $b = $val2, $c = $val3, so $a + $b + $c = $val1 + $val2 + $val3 = ${val1 + val2 + val3}.',
      progressiveHints: [
        'Add the three values',
        '$val1 + $val2 + $val3 = ${val1 + val2 + val3}',
      ],
      difficulty: level,
      basePoints: 100 + level * 20,
    );
  }
}
