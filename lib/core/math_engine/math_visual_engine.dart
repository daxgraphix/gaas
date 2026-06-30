import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../data/models/math_riddle.dart';

class VisualEquationPart {
  final String shape;
  final int value;

  VisualEquationPart(this.shape, this.value);
}

class MathVisualEngine {
  static final Random _random = Random();

  static final List<String> _shapes = [
    'square',
    'circle',
    'triangle',
    'pentagon',
    'star',
    'diamond',
    'hexagon',
    'octagon',
    'heart',
    'moon',
  ];

  static Future<LogicMathChallenge> generateVisualLogicChallenge(
    int difficulty,
  ) async {
    return await compute(_generateInternal, difficulty);
  }

  static LogicMathChallenge _generateInternal(int difficulty) {
    // Pick a generator type based on difficulty and randomness
    final type = _random.nextInt(100);

    if (difficulty <= 20) {
      if (type < 40) return _generateSubstitution(difficulty);
      if (type < 80) return _generateSimpleSystem(difficulty);
      return _generateBalanceScale(difficulty);
    } else if (difficulty <= 60) {
      if (type < 30) return _generateSimpleSystem(difficulty);
      if (type < 60) return _generateBalanceScale(difficulty);
      if (type < 90) return _generateMultiOpSystem(difficulty);
      return _generateGridLogic(difficulty);
    } else {
      if (type < 25) return _generateMultiOpSystem(difficulty);
      if (type < 50) return _generateGridLogic(difficulty);
      if (type < 75) return _generateComplexSystem(difficulty);
      return _generateGeometricLogic(difficulty);
    }
  }

  static LogicMathChallenge _generateSubstitution(int difficulty) {
    final s = _getRandomShapes(2);
    final val1 = _random.nextInt(10) + 1;
    final val2 = _random.nextInt(10) + 1;

    final equations = [
      '${s[0]} = $val1',
      '${s[0]} + ${s[1]} = ${val1 + val2}',
    ];

    return _createChallenge(
      '${equations.join('\n')}\n${s[1]} = ?',
      val2.toString(),
      difficulty,
      ['The first line tells you the value of ${s[0]}.', 'Substitute it into the second line.'],
    );
  }

  static LogicMathChallenge _generateSimpleSystem(int difficulty) {
    final s = _getRandomShapes(3);
    final val1 = _random.nextInt(10) + 2;
    final val2 = _random.nextInt(10) + 2;
    final val3 = _random.nextInt(10) + 2;

    final equations = [
      '${s[0]} + ${s[0]} = ${val1 * 2}',
      '${s[0]} + ${s[1]} = ${val1 + val2}',
      '${s[1]} + ${s[2]} = ${val2 + val3}',
    ];

    return _createChallenge(
      '${equations.join('\n')}\n${s[2]} = ?',
      val3.toString(),
      difficulty,
      ['Divide the first sum by 2 to find ${s[0]}.', 'Use ${s[0]} to find ${s[1]}.'],
    );
  }

  static LogicMathChallenge _generateBalanceScale(int difficulty) {
    final s = _getRandomShapes(3);
    final valA = (_random.nextInt(5) + 2) * 2; // Even number for easier division
    final valB = valA ~/ 2;
    final valC = _random.nextInt(10) + 5;

    final equations = [
      '${s[0]} = ${s[1]} + ${s[1]}',
      '${s[0]} + ${s[1]} = ${valA + valB}',
      '${s[1]} + ${s[2]} = ${valB + valC}',
    ];

    return _createChallenge(
      '${equations.join('\n')}\n${s[2]} = ?',
      valC.toString(),
      difficulty,
      ['One ${s[0]} is equal to two ${s[1]}s.', 'Substitute the first line into the second.'],
    );
  }

  static LogicMathChallenge _generateMultiOpSystem(int difficulty) {
    final s = _getRandomShapes(3);
    final val1 = _random.nextInt(8) + 2;
    final val2 = _random.nextInt(8) + 2;
    final val3 = _random.nextInt(8) + 2;

    final equations = [
      '${s[0]} × ${s[0]} = ${val1 * val1}',
      '${s[0]} × ${s[1]} = ${val1 * val2}',
      '${s[1]} + ${s[2]} - ${s[0]} = ${val2 + val3 - val1}',
    ];

    return _createChallenge(
      '${equations.join('\n')}\n${s[2]} = ?',
      val3.toString(),
      difficulty,
      ['Find the square root of ${val1 * val1} for ${s[0]}.', 'Use multiplication to find ${s[1]}.'],
    );
  }

  static LogicMathChallenge _generateGridLogic(int difficulty) {
    final s = _getRandomShapes(3);
    final val1 = _random.nextInt(10) + 1;
    final val2 = _random.nextInt(10) + 1;
    final val3 = _random.nextInt(10) + 1;

    final problem = [
      'Grid Sums:',
      '[ ${s[0]}   ${s[1]} ] = ${val1 + val2}',
      '[ ${s[2]}   ${s[0]} ] = ${val3 + val1}',
      '[ ${s[1]}   ${s[2]} ] = ${val2 + val3}',
      'Total Sum = ${val1 + val2 + val3}',
      'Find ${s[0]} + ${s[1]} + ${s[2]}',
    ].join('\n');

    final answer = (val1 + val2 + val3).toString();

    return _createChallenge(
      problem,
      answer,
      difficulty,
      ['Notice that each shape appears twice in the row sums.', 'Try adding all row sums and dividing by 2.'],
    );
  }

  static LogicMathChallenge _generateComplexSystem(int difficulty) {
    final s = _getRandomShapes(4);
    final v = List.generate(4, (_) => _random.nextInt(12) + 2);

    final equations = [
      '${s[0]} + ${s[1]} = ${v[0] + v[1]}',
      '${s[1]} - ${s[2]} = ${v[1] - v[2]}',
      '${s[2]} × ${s[3]} = ${v[2] * v[3]}',
      '${s[3]} + ${s[0]} = ${v[3] + v[0]}',
      'If ${s[0]} = ${v[0]}',
    ];

    return _createChallenge(
      '${equations.join('\n')}\n${s[2]} + ${s[3]} = ?',
      (v[2] + v[3]).toString(),
      difficulty,
      ['Start with the given value of ${s[0]}.', 'Follow the chain of equations.'],
    );
  }

  static LogicMathChallenge _generateGeometricLogic(int difficulty) {
    // Logic based on number of sides/points
    final shapeValues = {
      'triangle': 3,
      'square': 4,
      'pentagon': 5,
      'hexagon': 6,
      'octagon': 8,
      'star': 10,
    };

    final selected = (shapeValues.keys.toList()..shuffle(_random)).take(3).toList();
    final s1 = selected[0];
    final s2 = selected[1];
    final s3 = selected[2];

    final equations = [
      '$s1 + $s1 = ${shapeValues[s1]! * 2}',
      '$s1 × $s2 = ${shapeValues[s1]! * shapeValues[s2]!}',
      '$s2 + $s3 = ${shapeValues[s2]! + shapeValues[s3]!}',
    ];

    return _createChallenge(
      '${equations.join('\n')}\n$s3 = ?',
      shapeValues[s3]!.toString(),
      difficulty,
      ['Count the sides or points of the shapes.', 'The values are based on geometric properties.'],
    );
  }

  static List<String> _getRandomShapes(int count) {
    return (_shapes.toList()..shuffle(_random)).take(count).toList();
  }

  static LogicMathChallenge _createChallenge(
    String problem,
    String answer,
    int difficulty,
    List<String> hints,
  ) {
    final options = <String>[answer];
    while (options.length < 4) {
      final ansInt = int.tryParse(answer) ?? 0;
      final wrong = (ansInt + _random.nextInt(15) - 7).toString();
      if (!options.contains(wrong) && (int.tryParse(wrong) ?? -1) >= 0) {
        options.add(wrong);
      }
    }
    options.shuffle(_random);

    return LogicMathChallenge(
      id: 'visual_${DateTime.now().microsecondsSinceEpoch}',
      problem: problem,
      options: options,
      correctAnswer: answer,
      explanation: 'Determined through logical deduction and step-by-step substitution.',
      progressiveHints: hints,
      difficulty: difficulty,
      basePoints: difficulty * 100,
    );
  }
}
