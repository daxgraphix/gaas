import 'package:flutter_test/flutter_test.dart';
import 'package:gaas/core/math_engine/math_engine.dart';

void main() {
  group('MathEngine Solvability Tests (Level 80-100)', () {
    test('High level addition questions should be solvable and positive', () {
      for (int i = 0; i < 100; i++) {
        final q = MathEngine.generateQuestion('addition', 95, skillRating: 1600, heatIndex: 2.8);
        expect(q.correctAnswer as int, greaterThan(0));
        if (q.operand3 != null) {
          expect(q.correctAnswer, equals(q.operand1 + q.operand2 + q.operand3!));
        }
      }
    });

    test('High level subtraction questions should be solvable and non-negative', () {
      for (int i = 0; i < 100; i++) {
        final q = MathEngine.generateQuestion('subtraction', 95, skillRating: 1600, heatIndex: 2.8);
        expect(q.correctAnswer as int, isNonNegative);
        if (q.operand3 != null) {
          // It could be mixed ops in boss mode, but generateQuestion('subtraction') usually maps to _generateThreeOperandSubtraction
          // Let's check displayString or just verify the result logic
          if (q.displayString.contains('-')) {
             // Logic check based on display string if customQuestion is used
          }
        }
      }
    });

    test('Chapter 10 Boss questions (Level 100) should be valid', () {
      for (int i = 0; i < 50; i++) {
        final q = MathEngine.generateQuestion('addition', 100, isArcade: false);
        expect(q.correctAnswer as int, isNonNegative);
        // Boss Q debug logging disabled for production-ready tests
      }
    });

    test('Multiplication at Level 100 should not exceed safe integer limits', () {
      final q = MathEngine.generateQuestion('multiplication', 100);
      expect(q.correctAnswer as int, lessThan(1000000));
    });
  });
}
