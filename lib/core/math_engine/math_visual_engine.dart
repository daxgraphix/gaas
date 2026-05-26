import 'dart:math';
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
  ];

  static Future<LogicMathChallenge> generateVisualLogicChallenge(
    int difficulty,
  ) async {
    // Simulated heavy logic that should ideally run in a background isolate
    // For now, we keep it synchronous but architected for future Isolate move.
    return _generateInternal(difficulty);
  }

  static LogicMathChallenge _generateInternal(int difficulty) {
    final selectedShapes = <String>[];
    final tempShapes = List<String>.from(_shapes)..shuffle(_random);

    int shapeCount = 3;
    if (difficulty > 3) shapeCount = 4;

    for (int i = 0; i < shapeCount; i++) {
      selectedShapes.add(tempShapes[i]);
    }

    final values = <String, int>{};
    for (final shape in selectedShapes) {
      values[shape] = _random.nextInt(10) + 2;
    }

    final equations = <String>[];

    if (difficulty <= 5) {
      final s1 = selectedShapes[0];
      final s2 = selectedShapes[1];
      final s3 = selectedShapes[2];
      equations.add('$s1 + $s1 = ${values[s1]! + values[s1]!}');
      equations.add('$s1 + $s2 = ${values[s1]! + values[s2]!}');
      equations.add('$s2 + $s3 = ${values[s2]! + values[s3]!}');
    } else if (difficulty <= 15) {
      final s1 = selectedShapes[0];
      final s2 = selectedShapes[1];
      final s3 = selectedShapes[2];
      equations.add('$s1 + $s1 + $s1 = ${values[s1]! * 3}');
      equations.add('$s1 + $s2 + $s2 = ${values[s1]! + values[s2]! * 2}');
      equations.add(
        '$s2 + $s3 - $s1 = ${values[s2]! + values[s3]! - values[s1]!}',
      );
    } else {
      final s1 = selectedShapes[0];
      final s2 = selectedShapes[1];
      final s3 = selectedShapes[2];
      final s4 = shapeCount > 3 ? selectedShapes[3] : selectedShapes[0];
      equations.add('$s1 * $s1 = ${values[s1]! * values[s1]!}');
      equations.add(
        '$s1 * $s2 + $s1 = ${values[s1]! * values[s2]! + values[s1]!}',
      );
      equations.add(
        '$s3 * $s2 - $s4 = ${values[s3]! * values[s2]! - values[s4]!}',
      );
    }

    final targetShape = selectedShapes[2];
    String correctAnswer;

    if (difficulty > 10) {
      correctAnswer = (values[selectedShapes[0]]! + values[selectedShapes[2]]!)
          .toString();
    } else {
      correctAnswer = values[targetShape]!.toString();
    }

    final options = <String>[];
    options.add(correctAnswer);
    while (options.length < 4) {
      final wrong = (_random.nextInt(20) + 1).toString();
      if (!options.contains(wrong)) {
        options.add(wrong);
      }
    }
    options.shuffle(_random);

    return LogicMathChallenge(
      id: 'visual_${DateTime.now().millisecondsSinceEpoch}',
      problem: '${equations.join('\n')}\n$targetShape = ?',
      options: options,
      correctAnswer: correctAnswer,
      explanation: 'From logic deduction.',
      progressiveHints: ['Isolate the first equation.', 'Apply substitution.'],
      difficulty: difficulty,
      basePoints: difficulty * 75,
    );
  }
}
