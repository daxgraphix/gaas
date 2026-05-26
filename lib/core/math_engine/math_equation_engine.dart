import 'dart:math';
import '../../data/models/crossword_puzzle.dart';

class MathEquationEngine {
  static final Random _random = Random();

  static MathEquationPuzzle generatePuzzle({
    required String theme,
    required int difficulty,
  }) {
    final equationCount = difficulty <= 2 ? 40 : difficulty <= 4 ? 50 : 60;
    final equations = _generateEquations(difficulty, equationCount);
    return MathEquationPuzzle(
      theme: theme,
      difficulty: difficulty,
      equations: equations,
      timeLimit: difficulty <= 2 ? 600 : difficulty <= 4 ? 900 : 1200, // 10-20 minutes based on difficulty
    );
  }

  static List<MathEquation> _generateEquations(int difficulty, int count) {
    final equations = <MathEquation>[];

    for (int i = 0; i < count; i++) {
      final equation = _generateComplexEquation(difficulty);
      equations.add(equation);
    }

    return equations;
  }

  static MathEquation _generateComplexEquation(int difficulty) {
    final complexTypes = [
      'parentheses', 'multi_step', 'fractions', 'decimals',
      'order_of_operations', 'negative_numbers', 'mixed_operations',
      'large_numbers', 'complex_mixed', 'multiplication_focus', 'division_focus'
    ];
    final type = complexTypes[_random.nextInt(complexTypes.length)];

    int correctAnswer = 0;
    List<String> hints = [];
    int missingIndex = 0;
    String fullEquation = '';

    switch (type) {
      case 'parentheses':
        {
          int a = _random.nextInt(10) + 1;
          int b = _random.nextInt(10) + 1;
          int c = _random.nextInt(5) + 2;
          int result = (a + b) * c;
          missingIndex = _random.nextInt(4);

          if (missingIndex == 0) {
            correctAnswer = a;
            hints = ['Find the first number in parentheses', 'What plus $b, times $c equals $result?', 'Solve: (□ + $b) × $c = $result'];
          } else if (missingIndex == 1) {
            correctAnswer = b;
            hints = ['Find the second number in parentheses', 'What plus $a, times $c equals $result?', 'Solve: ($a + □) × $c = $result'];
          } else if (missingIndex == 2) {
            correctAnswer = c;
            hints = ['Find the multiplier', 'What times ($a + $b) equals $result?', 'Solve: ($a + $b) × □ = $result'];
          } else {
            correctAnswer = result;
            hints = ['Calculate the result', 'First add $a + $b, then multiply by $c', '($a + $b) × $c = ?'];
          }
          fullEquation = '($a + $b) × $c = $result';
        }
        break;

      case 'multi_step':
        {
          int a = _random.nextInt(8) + 2;
          int b = _random.nextInt(8) + 2;
          int c = _random.nextInt(20) + 5;
          int result = a * b + c;
          missingIndex = _random.nextInt(4);

          if (missingIndex == 0) {
            correctAnswer = a;
            hints = ['Find the first number', 'What times $b plus $c equals $result?', 'Solve: □ × $b + $c = $result'];
          } else if (missingIndex == 1) {
            correctAnswer = b;
            hints = ['Find the second number', 'What times $a plus $c equals $result?', 'Solve: $a × □ + $c = $result'];
          } else if (missingIndex == 2) {
            correctAnswer = c;
            hints = ['Find the number to add', 'What plus $a × $b equals $result?', 'Solve: $a × $b + □ = $result'];
          } else {
            correctAnswer = result;
            hints = ['Calculate the result', 'First multiply $a × $b, then add $c', '$a × $b + $c = ?'];
          }
          fullEquation = '$a × $b + $c = $result';
        }
        break;

      case 'fractions':
        {
          int num1 = _random.nextInt(5) + 1;
          int den = _random.nextInt(5) + 2;
          int num2 = _random.nextInt(5) + 1;
          int result = num1 + num2;

          correctAnswer = result;
          hints = ['Add the fractions', 'Since denominators are the same, add numerators', '$num1 + $num2 = $result'];
          missingIndex = 3;
          fullEquation = '$num1/$den + $num2/$den = $result';
        }
        break;

      case 'decimals':
        {
          double base = (_random.nextInt(10) + 1) + (_random.nextInt(10)) * 0.1;
          int multiplier = _random.nextInt(5) + 2;
          double resultDecimal = base * multiplier;
          int result = (resultDecimal * 10).round();

          correctAnswer = result;
          hints = ['Multiply the decimal by $multiplier', 'Treat as multiplication', '${base.toStringAsFixed(1)} × $multiplier = ?'];
          missingIndex = 3;
          fullEquation = '${base.toStringAsFixed(1)} × $multiplier = ${resultDecimal.toStringAsFixed(1)}';
        }
        break;

      case 'order_of_operations':
        {
          int a = _random.nextInt(10) + 1;
          int b = _random.nextInt(5) + 1;
          int c = _random.nextInt(5) + 1;
          int result = a + b * c;
          missingIndex = _random.nextInt(4);

          if (missingIndex == 0) {
            correctAnswer = a;
            hints = ['Multiplication first, then add to get $result', 'What plus $b × $c equals $result?', 'Solve: □ + $b × $c = $result'];
          } else if (missingIndex == 1) {
            correctAnswer = b;
            hints = ['Multiplication first: □ × $c, then add $a', 'What times $c, plus $a equals $result?', 'Solve: $a + □ × $c = $result'];
          } else if (missingIndex == 2) {
            correctAnswer = c;
            hints = ['Multiplication first: $b × □, then add $a', 'What times $b, plus $a equals $result?', 'Solve: $a + $b × □ = $result'];
          } else {
            correctAnswer = result;
            hints = ['Calculate $a + $b × $c', 'Multiplication before addition', '$a + ($b × $c) = ?'];
          }
          fullEquation = '$a + $b × $c = $result';
        }
        break;

      case 'negative_numbers':
        {
          int a = _random.nextInt(20) + 1;
          int b = _random.nextInt(15) + 1;
          bool isAddition = _random.nextBool();
          int result = isAddition ? a + (-b) : a - b;
          missingIndex = _random.nextInt(3);

          if (missingIndex == 0) {
            correctAnswer = a;
            hints = isAddition ? ['What plus -$b equals $result?', '□ + (-$b) = $result'] : ['What minus $b equals $result?', '□ - $b = $result'];
          } else if (missingIndex == 1) {
            correctAnswer = b;
            hints = isAddition ? ['What is $a plus to equal $result? (negative)', '$a + (-□) = $result'] : ['What does $a minus to equal $result?', '$a - □ = $result'];
          } else {
            correctAnswer = result;
            hints = isAddition ? ['Calculate $a + (-$b)', 'Adding a negative is subtraction', '$a + (-$b) = ?'] : ['Calculate $a - $b', 'Subtraction', '$a - $b = ?'];
          }
          fullEquation = isAddition ? '$a + (-$b) = $result' : '$a - $b = $result';
        }
        break;

      case 'mixed_operations':
        {
          int a = _random.nextInt(8) + 2;
          int b = _random.nextInt(8) + 2;
          int c = _random.nextInt(20) + 1;
          int result = a * b - c;
          missingIndex = _random.nextInt(4);

          if (missingIndex == 0) {
            correctAnswer = a;
            hints = ['What times $b minus $c equals $result?', 'Multiplication first, then subtract', 'Solve: □ × $b - $c = $result'];
          } else if (missingIndex == 1) {
            correctAnswer = b;
            hints = ['What times $a minus $c equals $result?', 'Multiplication first: $a × □', 'Solve: $a × □ - $c = $result'];
          } else if (missingIndex == 2) {
            correctAnswer = c;
            hints = ['What does $a × $b minus equal $result?', 'Subtract from the product', 'Solve: $a × $b - □ = $result'];
          } else {
            correctAnswer = result;
            hints = ['Calculate $a × $b - $c', 'Multiplication before subtraction', '$a × $b - $c = ?'];
          }
          fullEquation = '$a × $b - $c = $result';
        }
        break;

      case 'large_numbers':
        {
          int a = _random.nextInt(900) + 100; // 100-999
          int b = _random.nextInt(900) + 100; // 100-999
          int result = a + b;

          correctAnswer = result;
          hints = ['Add the hundreds digits', 'Add the tens digits', 'Add the ones digits', '$a + $b = ?'];
          missingIndex = 2;
          fullEquation = '$a + $b = $result';
        }
        break;

      case 'complex_mixed':
        {
          int a = _random.nextInt(20) + 5;
          int b = _random.nextInt(20) + 5;
          int c = _random.nextInt(20) + 5;
          int d = _random.nextInt(20) + 5;
          int result = a * b + c * d;

          correctAnswer = result;
          hints = ['Calculate $a × $b first', 'Calculate $c × $d second', 'Add the two results together', '($a×$b) + ($c×$d) = ?'];
          missingIndex = 4;
          fullEquation = '$a × $b + $c × $d = $result';
        }
        break;

      case 'multiplication_focus':
        {
          int a = _random.nextInt(50) + 10; // 10-59
          int b = _random.nextInt(50) + 10; // 10-59
          int result = a * b;

          correctAnswer = result;
          hints = ['Multiply $a by $b', 'Think of it as $a groups of $b', 'Or $b groups of $a', '$a × $b = ?'];
          missingIndex = 2;
          fullEquation = '$a × $b = $result';
        }
        break;

      case 'division_focus':
        {
          int b = _random.nextInt(20) + 5;
          int result = _random.nextInt(20) + 5;
          int a = b * result; // Make it divisible

          correctAnswer = result;
          hints = ['How many times does $b go into $a?', 'Divide $a by $b', '$a ÷ $b = ?'];
          missingIndex = 2;
          fullEquation = '$a ÷ $b = $result';
        }
        break;

      default:
        return _generateSingleEquation(difficulty);
    }

    return MathEquation(
      equation: fullEquation,
      correctAnswer: correctAnswer,
      hints: hints,
      missingIndex: missingIndex,
    );
  }

  static MathEquation _generateSingleEquation(int difficulty) {
    int maxNum = 10 + (difficulty * 5);
    int a = _random.nextInt(maxNum) + 1;
    int b = _random.nextInt(maxNum) + 1;
    int result = a + b;

    return MathEquation(
      equation: '$a + $b = $result',
      correctAnswer: result,
      hints: ['Add $a and $b together'],
      missingIndex: 2,
    );
  }
}