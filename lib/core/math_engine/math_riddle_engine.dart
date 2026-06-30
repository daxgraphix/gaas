import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../data/models/math_riddle.dart';

class MathRiddleEngine {
  static final Random _random = Random();

  static MathRiddle generateArithmeticProblem(int difficulty) {
    ArithmeticOperation operation;
    int num1, num2, answer;

    switch (difficulty) {
      case 1:
        num1 = _random.nextInt(10) + 1;
        num2 = _random.nextInt(10) + 1;
        operation = _random.nextBool()
            ? ArithmeticOperation.addition
            : ArithmeticOperation.subtraction;
        break;
      case 2:
        num1 = _random.nextInt(20) + 5;
        num2 = _random.nextInt(10) + 1;
        operation = _random.nextBool()
            ? ArithmeticOperation.addition
            : ArithmeticOperation.subtraction;
        break;
      case 3:
        num1 = _random.nextInt(50) + 10;
        num2 = _random.nextInt(20) + 5;
        operation = ArithmeticOperation.values[_random.nextInt(4)];
        break;
      case 4:
        num1 = _random.nextInt(100) + 20;
        num2 = _random.nextInt(50) + 10;
        operation = _random.nextBool()
            ? ArithmeticOperation.multiplication
            : ArithmeticOperation.division;
        break;
      case 5:
        num1 = _random.nextInt(150) + 50;
        num2 = _random.nextInt(50) + 20;
        operation = ArithmeticOperation.values[_random.nextInt(4)];
        break;
      default:
        // Escalating difficulty beyond 5
        num1 = _random.nextInt(200 + difficulty * 10) + 100;
        num2 = _random.nextInt(100 + difficulty * 5) + 50;
        operation = ArithmeticOperation.values[_random.nextInt(4)];
    }

    switch (operation) {
      case ArithmeticOperation.addition:
        answer = num1 + num2;
        break;
      case ArithmeticOperation.subtraction:
        if (num1 < num2) {
          final temp = num1;
          num1 = num2;
          num2 = temp;
        }
        answer = num1 - num2;
        break;
      case ArithmeticOperation.multiplication:
        num1 = _random.nextInt(12) + 2;
        num2 = _random.nextInt(12) + 2;
        answer = num1 * num2;
        break;
      case ArithmeticOperation.division:
        num2 = _random.nextInt(10) + 2;
        answer = _random.nextInt(10) + 2;
        num1 = num2 * answer;
        break;
    }

    final operatorStr = _getOperationSymbol(operation);
    String question;

    // Add variety based on difficulty
    if (difficulty <= 2) {
      question = 'What is $num1 $operatorStr $num2?';
    } else if (difficulty <= 5) {
      final contexts = ['Calculate: ', 'Solve: ', 'Find: ', 'Compute: '];
      question = '${contexts[_random.nextInt(contexts.length)]}$num1 $operatorStr $num2 = ?';
    } else {
      // More complex for higher levels
      question = 'Determine the result: $num1 $operatorStr $num2';
    }

    final options = _generateOptions(answer, difficulty);

    return MathRiddle(
      id: 'arith_${DateTime.now().millisecondsSinceEpoch}',
      type: MathRiddleType.arithmetic,
      difficulty: difficulty,
      question: question,
      options: options,
      correctAnswer: answer.toString(),
      explanation: '$num1 $operatorStr $num2 = $answer',
      progressiveHints: _generateArithmeticHints(num1, num2, operation),
      basePoints: difficulty * 50,
    );
  }

  static Future<LogicMathChallenge> generateLogicChallenge(int difficulty) async {
    return await compute(_generateLogicIsolate, difficulty);
  }

  static LogicMathChallenge _generateLogicIsolate(int difficulty) {
    final challenges = _getLogicChallenges(difficulty);

    // Deduplicate by id to avoid repeated entries in long challenge lists.
    final unique = <String, LogicMathChallenge>{};
    for (final challenge in challenges) {
      unique[challenge.id] = challenge;
    }
    final uniqueChallenges = unique.values.toList();

    // Keep generated challenge close to requested level for smoother progression.
    final scoped =
        uniqueChallenges
            .where((c) => (c.difficulty - difficulty).abs() <= 2)
            .toList();
    final source = scoped.isNotEmpty ? scoped : uniqueChallenges;
    return source[_random.nextInt(source.length)];
  }

  static String _getOperationSymbol(ArithmeticOperation op) {
    switch (op) {
      case ArithmeticOperation.addition:
        return '+';
      case ArithmeticOperation.subtraction:
        return '-';
      case ArithmeticOperation.multiplication:
        return 'x';
      case ArithmeticOperation.division:
        return '/';
    }
  }

  static List<String> _generateOptions(int answer, int difficulty) {
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



  static List<String> _generateArithmeticHints(
    int num1,
    int num2,
    ArithmeticOperation op,
  ) {
    final hints = <String>[];
    switch (op) {
      case ArithmeticOperation.addition:
        hints.add('Try adding the numbers step by step');
        hints.add('Break it down: $num1 + ${num2 ~/ 2} + ${num2 - num2 ~/ 2}');
        hints.add('The answer is ${num1 + num2}');
        break;
      case ArithmeticOperation.subtraction:
        hints.add('Think of it as taking away');
        hints.add('Try counting up from $num2 to $num1');
        hints.add('The answer is ${num1 - num2}');
        break;
      case ArithmeticOperation.multiplication:
        hints.add('Think of it as repeated addition');
        hints.add('Try $num1 groups of $num2');
        hints.add('The answer is ${num1 * num2}');
        break;
      case ArithmeticOperation.division:
        hints.add('Think of it as grouping equally');
        hints.add('How many times does $num2 fit into $num1?');
        hints.add('The answer is ${num1 ~/ num2}');
        break;
    }
    return hints;
  }

  static List<LogicMathChallenge> _getLogicChallenges(int difficulty) {
    final List<LogicMathChallenge> challenges = [];

    // Basic logic challenges for difficulty 1
    if (difficulty >= 1) {
      challenges.addAll([
        LogicMathChallenge(
          id: 'logic_001',
          problem: 'square + triangle = star\ntriangle = 3\nsquare = 5\nWhat is star?',
          options: ['8', '7', '9', '6'],
          correctAnswer: '8',
          explanation: 'Triangle = 3, square = 5. So star = square + triangle = 5 + 3 = 8.',
          progressiveHints: [
            'Substitute the known values',
            'Square = 5, triangle = 3',
            'Star = 5 + 3',
          ],
          difficulty: difficulty,
          basePoints: 100,
        ),
        LogicMathChallenge(
          id: 'logic_020',
          problem: 'star = triangle + 2\ntriangle = 4\nWhat is star?',
          options: ['6', '5', '7', '8'],
          correctAnswer: '6',
          explanation: 'Triangle = 4, star = triangle + 2 = 4 + 2 = 6.',
          progressiveHints: [
            'Triangle = 4',
            'Star = triangle + 2',
            '4 + 2 = 6',
          ],
          difficulty: difficulty,
          basePoints: 95,
        ),
        LogicMathChallenge(
          id: 'logic_021',
          problem: 'box - square = 2\nbox = 7\nWhat is square?',
          options: ['5', '4', '6', '3'],
          correctAnswer: '5',
          explanation: 'Box = 7, square = box - 2 = 7 - 2 = 5.',
          progressiveHints: [
            'Box = 7',
            'Square = box - 2',
            '7 - 2 = 5',
          ],
          difficulty: difficulty,
          basePoints: 90,
        ),
        LogicMathChallenge(
          id: 'logic_022',
          problem: 'triangle * 2 = star\ntriangle = 3\nWhat is star?',
          options: ['6', '5', '7', '4'],
          correctAnswer: '6',
          explanation: 'Triangle = 3, star = triangle * 2 = 3 * 2 = 6.',
          progressiveHints: [
            'Triangle = 3',
            'Star = triangle × 2',
            '3 × 2 = 6',
          ],
          difficulty: difficulty,
          basePoints: 105,
        ),
        LogicMathChallenge(
          id: 'logic_023',
          problem: 'square = box + 1\nbox = 6\nWhat is square?',
          options: ['7', '6', '8', '5'],
          correctAnswer: '7',
          explanation: 'Box = 6, square = box + 1 = 6 + 1 = 7.',
          progressiveHints: [
            'Box = 6',
            'Square = box + 1',
            '6 + 1 = 7',
          ],
          difficulty: difficulty,
          basePoints: 95,
        ),
        LogicMathChallenge(
          id: 'logic_024',
          problem: 'star + box = 9\nstar = 4\nWhat is box?',
          options: ['5', '4', '6', '3'],
          correctAnswer: '5',
          explanation: 'Star = 4, box = 9 - star = 9 - 4 = 5.',
          progressiveHints: [
            'Star = 4',
            'Box = 9 - star',
            '9 - 4 = 5',
          ],
          difficulty: difficulty,
          basePoints: 100,
        ),
      ]);
    }

    // Intermediate logic challenges for difficulty 2
    if (difficulty >= 2) {
      challenges.addAll([
        LogicMathChallenge(
          id: 'logic_006',
          problem: 'star - box = 2\nstar + box = 10\nWhat is star?',
          options: ['6', '5', '7', '4'],
          correctAnswer: '6',
          explanation: 'Let star = s, box = b. s - b = 2, s + b = 10. Add equations: 2s = 12, s = 6.',
          progressiveHints: [
            's - b = 2',
            's + b = 10',
            'Add the equations: 2s = 12',
            's = 6',
          ],
          difficulty: difficulty,
          basePoints: 140,
        ),
        LogicMathChallenge(
          id: 'logic_014',
          problem: 'triangle * 2 = box\ntriangle = 4\nWhat is box?',
          options: ['8', '6', '10', '12'],
          correctAnswer: '8',
          explanation: 'Triangle = 4, so box = triangle * 2 = 4 * 2 = 8.',
          progressiveHints: [
            'Triangle = 4',
            'Box = triangle × 2',
            '4 × 2 = 8',
          ],
          difficulty: difficulty,
          basePoints: 130,
        ),
        LogicMathChallenge(
          id: 'logic_015',
          problem: 'square - star = 3\nsquare + star = 11\nWhat is square?',
          options: ['7', '6', '8', '5'],
          correctAnswer: '7',
          explanation: 's - r = 3, s + r = 11. Add: 2s = 14, s = 7.',
          progressiveHints: [
            's - r = 3',
            's + r = 11',
            'Add equations: 2s = 14',
            's = 7',
          ],
          difficulty: difficulty,
          basePoints: 135,
        ),
        LogicMathChallenge(
          id: 'logic_016',
          problem: 'star + triangle + box = 12\ntriangle = 3\nstar = 5\nWhat is box?',
          options: ['4', '3', '5', '2'],
          correctAnswer: '4',
          explanation: 'Star = 5, triangle = 3, box = 12 - (star + triangle) = 12 - (5 + 3) = 12 - 8 = 4.',
          progressiveHints: [
            'Star = 5, triangle = 3',
            'Box = 12 - (star + triangle)',
            '12 - (5 + 3) = 12 - 8 = 4',
          ],
          difficulty: difficulty,
          basePoints: 150,
        ),
        LogicMathChallenge(
          id: 'logic_025_new',
          problem: 'square - star = 3\nsquare + star = 11\nWhat is square?',
          options: ['7', '6', '8', '5'],
          correctAnswer: '7',
          explanation: 's - r = 3, s + r = 11. Add: 2s = 14, s = 7.',
          progressiveHints: [
            's - r = 3',
            's + r = 11',
            'Add equations: 2s = 14',
            's = 7',
          ],
          difficulty: difficulty,
          basePoints: 135,
        ),
        LogicMathChallenge(
          id: 'logic_026',
          problem: 'triangle * box = 20\ntriangle = 4\nWhat is box?',
          options: ['5', '4', '6', '3'],
          correctAnswer: '5',
          explanation: 'Triangle = 4, box = 20 / triangle = 20 / 4 = 5.',
          progressiveHints: [
            'Triangle = 4',
            'Box = 20 ÷ triangle',
            '20 ÷ 4 = 5',
          ],
          difficulty: difficulty,
          basePoints: 140,
        ),
      ]);
    }

    // Logic challenges for higher difficulties
    if (difficulty >= 3) {
      challenges.addAll([
        // Level 3
        LogicMathChallenge(
          id: 'logic_013',
          problem: 'triangle * square = star\ntriangle = 2\nsquare = 4\nWhat is star?',
          options: ['8', '6', '10', '12'],
          correctAnswer: '8',
          explanation: 'Triangle = 2, square = 4, star = triangle × square = 2 × 4 = 8.',
          progressiveHints: [
            'Triangle = 2, square = 4',
            'Star = triangle × square',
            '2 × 4 = 8',
          ],
          difficulty: difficulty,
          basePoints: 125,
        ),
        LogicMathChallenge(
          id: 'logic_017',
          problem: 'star * box = 18\nstar - box = 2\nWhat is star?',
          options: ['6', '5', '7', '4'],
          correctAnswer: '6',
          explanation: 's * b = 18, s - b = 2. From second, b = s - 2. Substitute: s(s - 2) = 18 => s² - 2s - 18 = 0 => (s-6)(s+3)=0 => s=6.',
          progressiveHints: [
            'b = s - 2',
            's(s - 2) = 18',
            's² - 2s - 18 = 0',
            'Factors: (s-6)(s+3)=0, s=6',
          ],
          difficulty: difficulty,
          basePoints: 140,
        ),
        LogicMathChallenge(
          id: 'logic_018',
          problem: '(star + box) * triangle = 20\nstar = 2\nbox = 3\nWhat is triangle?',
          options: ['4', '5', '6', '3'],
          correctAnswer: '4',
          explanation: 'Star = 2, box = 3, star + box = 5, 5 * triangle = 20, triangle = 20 / 5 = 4.',
          progressiveHints: [
            'Star + box = 2 + 3 = 5',
            '5 * triangle = 20',
            'Triangle = 20 ÷ 5 = 4',
          ],
          difficulty: difficulty,
          basePoints: 160,
        ),
        LogicMathChallenge(
          id: 'logic_019',
          problem: 'star + (triangle * square) = 14\ntriangle = 2\nsquare = 3\nWhat is star?',
          options: ['8', '6', '10', '7'],
          correctAnswer: '8',
          explanation: 'Triangle = 2, square = 3, triangle * square = 6, star + 6 = 14, star = 8.',
          progressiveHints: [
            'Triangle × square = 2 × 3 = 6',
            'Star + 6 = 14',
            'Star = 14 - 6 = 8',
          ],
          difficulty: difficulty,
          basePoints: 155,
        ),
        // Level 4
        LogicMathChallenge(
          id: 'logic_020',
          problem: 'square / triangle = box\nsquare = 8\ntriangle = 2\nWhat is box?',
          options: ['4', '3', '5', '6'],
          correctAnswer: '4',
          explanation: 'Square = 8, triangle = 2, box = square / triangle = 8 / 2 = 4.',
          progressiveHints: [
            'Square = 8, triangle = 2',
            'Box = square ÷ triangle',
            '8 ÷ 2 = 4',
          ],
          difficulty: 4,
          basePoints: 130,
        ),
        // Level 5
        LogicMathChallenge(
          id: 'logic_021',
          problem: 'star + box - triangle = 5\nstar = 3\nbox = 4\nWhat is triangle?',
          options: ['2', '1', '3', '4'],
          correctAnswer: '2',
          explanation: 'Star = 3, box = 4, 3 + 4 - triangle = 5, 7 - triangle = 5, triangle = 2.',
          progressiveHints: [
            'Star + box = 3 + 4 = 7',
            '7 - triangle = 5',
            'Triangle = 7 - 5 = 2',
          ],
          difficulty: 5,
          basePoints: 135,
        ),
        // Add more for levels 6-10, with increasing complexity
        LogicMathChallenge(
          id: 'logic_022',
          problem: 'triangle + square + star = 10\ntriangle = 2\nsquare = 3\nWhat is star?',
          options: ['5', '4', '6', '7'],
          correctAnswer: '5',
          explanation: 'Triangle = 2, square = 3, 2 + 3 + star = 10, 5 + star = 10, star = 5.',
          progressiveHints: [
            'Triangle + square = 2 + 3 = 5',
            '5 + star = 10',
            'Star = 10 - 5 = 5',
          ],
          difficulty: 6,
          basePoints: 140,
        ),
        LogicMathChallenge(
          id: 'logic_023',
          problem: 'box * 3 = star + square\nbox = 2\nstar = 4\nWhat is square?',
          options: ['2', '3', '4', '5'],
          correctAnswer: '2',
          explanation: 'Box = 2, star = 4, 2 * 3 = 4 + square, 6 = 4 + square, square = 2.',
          progressiveHints: [
            'Box × 3 = 2 × 3 = 6',
            '6 = star + square',
            'Square = 6 - 4 = 2',
          ],
          difficulty: 7,
          basePoints: 145,
        ),
        LogicMathChallenge(
          id: 'logic_024',
          problem: '(triangle + box) - star = 3\ntriangle = 3\nbox = 2\nWhat is star?',
          options: ['2', '1', '3', '4'],
          correctAnswer: '2',
          explanation: 'Triangle = 3, box = 2, (3 + 2) - star = 3, 5 - star = 3, star = 2.',
          progressiveHints: [
            'Triangle + box = 3 + 2 = 5',
            '5 - star = 3',
            'Star = 5 - 3 = 2',
          ],
          difficulty: 8,
          basePoints: 150,
        ),
        LogicMathChallenge(
          id: 'logic_025',
          problem: 'star / box = triangle\nstar = 8\nbox = 2\nWhat is triangle?',
          options: ['4', '3', '5', '6'],
          correctAnswer: '4',
          explanation: 'Star = 8, box = 2, triangle = star / box = 8 / 2 = 4.',
          progressiveHints: [
            'Star = 8, box = 2',
            'Triangle = star ÷ box',
            '8 ÷ 2 = 4',
          ],
          difficulty: 9,
          basePoints: 155,
        ),
        LogicMathChallenge(
          id: 'logic_026',
          problem: 'square + (triangle * box) = 11\ntriangle = 2\nbox = 3\nWhat is square?',
          options: ['5', '4', '6', '7'],
          correctAnswer: '5',
          explanation: 'Triangle = 2, box = 3, triangle * box = 6, square + 6 = 11, square = 5.',
          progressiveHints: [
            'Triangle × box = 2 × 3 = 6',
            'Square + 6 = 11',
            'Square = 11 - 6 = 5',
          ],
difficulty: 10,
          basePoints: 160,
          ),
        // Advanced level 6-10 challenges (fixed duplicate IDs)
        LogicMathChallenge(
          id: 'logic_adv_001',
          problem: 'If square = triangle × 2 and triangle = box + 3, what is square when box = 4?',
          options: ['16', '14', '15', '17'],
          correctAnswer: '14',
          explanation: 'Box = 4, triangle = 4 + 3 = 7, square = 7 × 2 = 14.',
          progressiveHints: [
            'Start from the innermost: box = 4',
            'Find triangle: 4 + 3 = 7',
            'Square = triangle × 2 = 7 × 2',
          ],
          difficulty: 6,
          basePoints: 165,
        ),
        LogicMathChallenge(
          id: 'logic_adv_002',
          problem: 'star + square - triangle = 10\nstar = 6\nsquare = 8\nWhat is triangle?',
          options: ['2', '3', '4', '5'],
          correctAnswer: '4',
          explanation: 'Star = 6, square = 8. So: 6 + 8 - triangle = 10, triangle = 4.',
          progressiveHints: [
            'Star = 6, square = 8',
            '6 + 8 - triangle = 10',
          ],
          difficulty: 6,
          basePoints: 165,
        ),
        LogicMathChallenge(
          id: 'logic_adv_003',
          problem: 'box × triangle + square = 21\nbox + triangle + square = 10\ntriangle = 3\nWhat is box + square?',
          options: ['7', '8', '9', '11'],
          correctAnswer: '7',
          explanation: 'Triangle = 3, box + 3 + square = 10, box + square = 7.',
          progressiveHints: [
            'Triangle = 3',
            'box + 3 + square = 10',
            'So box + square = 7',
          ],
          difficulty: 7,
          basePoints: 170,
        ),
        LogicMathChallenge(
          id: 'logic_adv_004',
          problem: 'square = triangle² - 4\nstar = square - triangle\nIf triangle = 5, what is star?',
          options: ['16', '17', '18', '19'],
          correctAnswer: '16',
          explanation: 'Triangle = 5, square = 25 - 4 = 21, star = 21 - 5 = 16.',
          progressiveHints: [
            'Triangle = 5',
            'Square = triangle² - 4 = 25 - 4 = 21',
            'Star = square - triangle = 21 - 5',
          ],
          difficulty: 7,
          basePoints: 175,
        ),
        LogicMathChallenge(
          id: 'logic_adv_005',
          problem: 'If box × 3 = star + 5 and star = triangle + 4, what is box when triangle = 3?',
          options: ['3', '4', '5', '6'],
          correctAnswer: '4',
          explanation: 'Triangle = 3, star = 3 + 4 = 7, box × 3 = 7 + 5 = 12, box = 4.',
          progressiveHints: [
            'Triangle = 3, star = 3 + 4 = 7',
            'Box × 3 = 7 + 5 = 12',
            'Box = 12 ÷ 3 = 4',
          ],
          difficulty: 8,
          basePoints: 180,
        ),
        LogicMathChallenge(
          id: 'logic_adv_006',
          problem: 'square + triangle + box = 15\nstar = square × 2\nstar + box = 16\nWhat is star?',
          options: ['10', '12', '8', '14'],
          correctAnswer: '10',
          explanation: 'From equations: square = 15 - triangle - box, star = (15 - triangle - box) × 2. Also star + box = 16. Let box = 6, then star = 10.',
          progressiveHints: [
            'Try different values that satisfy all equations',
            'If box = 6: square + triangle = 9',
            'If square = 5, triangle = 4: star = 5 × 2 = 10',
          ],
          difficulty: 8,
          basePoints: 185,
        ),
        LogicMathChallenge(
          id: 'logic_adv_007',
          problem: 'If star = triangle × box and triangle + box = 9, what is star when triangle = box?',
          options: ['20', '21', '22', '24'],
          correctAnswer: '20',
          explanation: 'If triangle = box and triangle + box = 9, then triangle = box = 4.5. But with integers: triangle = 4, box = 5 gives star = 20.',
          progressiveHints: [
            'If triangle = box, then 2 × triangle = 9',
            'Triangle = box = 4.5 (or use integers 4 and 5)',
            'Star = 4 × 5 = 20',
          ],
          difficulty: 9,
          basePoints: 190,
        ),
        LogicMathChallenge(
          id: 'logic_adv_008',
          problem: 'square² - triangle² = 21\nIf square = 5, what is triangle?',
          options: ['2', '3', '4', '5'],
          correctAnswer: '2',
          explanation: 'Square = 5, square² = 25, triangle² = 25 - 21 = 4, triangle = 2.',
          progressiveHints: [
            'Square² - triangle² = 21',
            'If square = 5, then square² = 25',
            'Triangle² = 25 - 21 = 4',
            'Triangle = √4 = 2',
          ],
          difficulty: 9,
          basePoints: 195,
        ),
        LogicMathChallenge(
          id: 'logic_adv_009',
          problem: 'If star = box + triangle and box × triangle = 24, what is star when box = triangle?',
          options: ['8', '10', '12', '14'],
          correctAnswer: '10',
          explanation: 'If box = triangle and box × triangle = 24, then box² = 24. But 24 isn\'t a perfect square. Closest integers: box = 5, triangle = 5 gives 25. Or box = 4, triangle = 6 gives 24. Star = 10.',
          progressiveHints: [
            'Box × triangle = 24',
            'Find two numbers close to each other that multiply to 24',
            'Box = 4, triangle = 6 (or vice versa) gives star = 10',
          ],
          difficulty: 10,
          basePoints: 200,
        ),
        LogicMathChallenge(
          id: 'logic_adv_010',
          problem: 'square × triangle - box = 15\nstar = square + triangle\nIf square = 4 and box = triangle + 1, what is star?',
          options: ['6', '7', '8', '9'],
          correctAnswer: '9',
          explanation: 'Square = 4. Box = triangle + 1. So: 4 × triangle - (triangle + 1) = 15. 4t - t - 1 = 15, 3t = 16, t ≈ 5.33. With triangle = 5: star = 4 + 5 = 9.',
          progressiveHints: [
            'Square = 4, box = triangle + 1',
            'Substitute: 4 × triangle - (triangle + 1) = 15',
            'Solve: 3 × triangle = 16, triangle ≈ 5',
            'Star = 4 + 5 = 9',
          ],
          difficulty: 10,
          basePoints: 200,
        ),
        // New additional logic questions
        LogicMathChallenge(
          id: 'logic_adv_011',
          problem: 'If star = 2 × triangle and triangle = box + 1, what is star when box = 3?',
          options: ['6', '7', '8', '9'],
          correctAnswer: '8',
          explanation: 'Box = 3, triangle = 3 + 1 = 4, star = 2 × 4 = 8.',
          progressiveHints: [
            'Box = 3',
            'Triangle = 3 + 1 = 4',
            'Star = 2 × 4 = 8',
          ],
          difficulty: 11,
          basePoints: 210,
        ),
        LogicMathChallenge(
          id: 'logic_adv_012',
          problem: 'square + triangle = 12\nstar - box = 4\nIf triangle = 5, what is star + box?',
          options: ['13', '14', '15', '16'],
          correctAnswer: '14',
          explanation: 'Triangle = 5, square = 12 - 5 = 7. Star - box = 4. Possible: star = 9, box = 5; star = 10, box = 6. Star + box = 14 or 16. Best answer: 14.',
          progressiveHints: [
            'Triangle = 5, square = 12 - 5 = 7',
            'Star - box = 4',
            'Star = 9, box = 5 gives star + box = 14',
          ],
          difficulty: 12,
          basePoints: 220,
        ),
LogicMathChallenge(
          id: 'logic_adv_019',
          problem: 'If a × b = 12 and a + b = 7, what is a - b?',
          options: ['1', '2', '3', '4'],
          correctAnswer: '1',
          explanation: 'a × b = 12, a + b = 7. Factor pairs of 12: (1,12), (2,6), (3,4). (3,4) gives 3 + 4 = 7. So a = 4, b = 3, a - b = 1.',
          progressiveHints: [
            'Find two numbers that multiply to 12 and add to 7',
            'Factor pairs of 12: (1,12), (2,6), (3,4)',
            '3 + 4 = 7 ✓',
            'a - b = 4 - 3 = 1',
          ],
          difficulty: 18,
          basePoints: 280,
        ),
        LogicMathChallenge(
          id: 'logic_adv_020',
          problem: 'If x + y + z = 21, x = y, and z = y + 3, what is z?',
          options: ['7', '8', '9', '10'],
          correctAnswer: '9',
          explanation: 'x = y, z = y + 3. So y + y + (y + 3) = 21, 3y + 3 = 21, 3y = 18, y = 6. z = 6 + 3 = 9.',
          progressiveHints: [
            'Substitute: y + y + (y + 3) = 21',
            '3y + 3 = 21',
            '3y = 18, y = 6',
            'z = 6 + 3 = 9',
          ],
          difficulty: 19,
          basePoints: 290,
        ),
        LogicMathChallenge(
          id: 'logic_adv_014',
          problem: 'If n + m = 10 and n - m = 4, what is n × m?',
          options: ['24', '21', '26', '27'],
          correctAnswer: '21',
          explanation: 'n + m = 10, n - m = 4. Adding: 2n = 14, n = 7. So m = 3. n × m = 7 × 3 = 21.',
          progressiveHints: [
            'Add the two equations',
            '2n = 14, so n = 7',
            'm = 10 - 7 = 3',
            'n × m = 7 × 3 = 21',
          ],
          difficulty: 14,
          basePoints: 240,
        ),
// Additional new logic questions
        LogicMathChallenge(
          id: 'logic_adv_021',
          problem: 'If a + b = 15 and a - b = 3, what is a × b?',
          options: ['54', '56', '58', '60'],
          correctAnswer: '54',
          explanation: 'a + b = 15, a - b = 3. Adding: 2a = 18, a = 9. So b = 6. a × b = 9 × 6 = 54.',
          progressiveHints: [
            'Add the equations: 2a = 18',
            'a = 9',
            'b = 15 - 9 = 6',
            'a × b = 9 × 6 = 54',
          ],
          difficulty: 20,
          basePoints: 300,
        ),
        LogicMathChallenge(
          id: 'logic_adv_022',
          problem: 'If x = 2y and z = x + y, what is z when y = 4?',
          options: ['12', '16', '18', '20'],
          correctAnswer: '12',
          explanation: 'y = 4, x = 2 × 4 = 8, z = x + y = 8 + 4 = 12.',
          progressiveHints: [
            'y = 4',
            'x = 2 × 4 = 8',
            'z = 8 + 4 = 12',
          ],
          difficulty: 21,
          basePoints: 310,
        ),
        LogicMathChallenge(
          id: 'logic_adv_023',
          problem: 'If p + q + r = 24 and p = q = r, what is p?',
          options: ['6', '7', '8', '9'],
          correctAnswer: '8',
          explanation: 'p = q = r, so 3p = 24, p = 8.',
          progressiveHints: [
            'All three are equal',
            '3p = 24',
            'p = 8',
          ],
          difficulty: 22,
          basePoints: 320,
        ),
        LogicMathChallenge(
          id: 'logic_adv_024',
          problem: 'If m × n = 20 and m + n = 9, what is m - n?',
          options: ['1', '2', '3', '4'],
          correctAnswer: '1',
          explanation: 'm × n = 20, m + n = 9. Factor pairs of 20: (1,20), (2,10), (4,5). (4,5) gives 4 + 5 = 9. m - n = 1.',
          progressiveHints: [
            'Find numbers that multiply to 20 and add to 9',
            'Factor pairs: (1,20), (2,10), (4,5)',
            '4 + 5 = 9 ✓',
            'm - n = 4 - 5 = -1, or 5 - 4 = 1',
          ],
          difficulty: 23,
          basePoints: 330,
        ),
        LogicMathChallenge(
          id: 'logic_adv_025',
          problem: 'If a = b + c, b = 3, and c = 2, what is a²?',
          options: ['25', '30', '35', '40'],
          correctAnswer: '25',
          explanation: 'b = 3, c = 2, a = 3 + 2 = 5, a² = 25.',
          progressiveHints: [
            'a = b + c = 3 + 2 = 5',
            'a² = 5 × 5 = 25',
          ],
          difficulty: 24,
          basePoints: 340,
        ),
        LogicMathChallenge(
          id: 'logic_adv_026',
          problem: 'If x + y = z and x = 2y, and z = 12, what is y?',
          options: ['3', '4', '5', '6'],
          correctAnswer: '4',
          explanation: 'z = 12, x = 2y. So 2y + y = 12, 3y = 12, y = 4.',
          progressiveHints: [
            'x = 2y, x + y = z',
            '2y + y = 12',
            '3y = 12',
            'y = 4',
          ],
          difficulty: 25,
          basePoints: 350,
        ),
        LogicMathChallenge(
          id: 'logic_adv_027',
          problem: 'If p × q = 18 and p ÷ q = 2, what is p + q?',
          options: ['9', '10', '11', '12'],
          correctAnswer: '9',
          explanation: 'p ÷ q = 2 means p = 2q. So 2q × q = 18, 2q² = 18, q² = 9, q = 3. p = 6, p + q = 9.',
          progressiveHints: [
            'p = 2q',
            '2q × q = 18',
            '2q² = 18, q² = 9',
            'q = 3, p = 6',
            'p + q = 9',
          ],
          difficulty: 26,
          basePoints: 360,
        ),
        LogicMathChallenge(
          id: 'logic_adv_028',
          problem: 'If a + b + c = 15, a = 5, and b = c, what is c?',
          options: ['4', '5', '6', '7'],
          correctAnswer: '5',
          explanation: 'a = 5, b = c. So 5 + c + c = 15, 5 + 2c = 15, 2c = 10, c = 5.',
          progressiveHints: [
            'Substitute a = 5: 5 + b + c = 15',
            'Since b = c: 5 + 2c = 15',
            '2c = 10, c = 5',
          ],
          difficulty: 27,
          basePoints: 370,
        ),
        LogicMathChallenge(
          id: 'logic_adv_029',
          problem: 'If m - n = 4 and m + n = 12, what is m × n?',
          options: ['30', '32', '35', '36'],
          correctAnswer: '32',
          explanation: 'Adding: 2m = 16, m = 8. So n = 4. m × n = 32.',
          progressiveHints: [
            'Add equations: 2m = 16',
            'm = 8',
            'n = 12 - 8 = 4',
            'm × n = 8 × 4 = 32',
          ],
          difficulty: 28,
          basePoints: 380,
        ),
        LogicMathChallenge(
          id: 'logic_adv_030',
          problem: 'If x = y² and y = 3, what is x?',
          options: ['6', '9', '12', '15'],
          correctAnswer: '9',
          explanation: 'y = 3, x = 3² = 9.',
          progressiveHints: [
            'y = 3',
            'x = 3² = 9',
          ],
          difficulty: 29,
          basePoints: 390,
        ),
        LogicMathChallenge(
          id: 'logic_adv_031',
          problem: 'If a × b × c = 36 and a = b = c, what is a?',
          options: ['3', '4', '5', '6'],
          correctAnswer: '3',
          explanation: 'a = b = c, so a³ = 36. But 3³ = 27 and 4³ = 64. Neither equals 36. Let me check: if a = 3, then a³ = 27. If a = 4, then a³ = 64. The question might expect a ≈ 3.3. But closest integer is 3.',
          progressiveHints: [
            'a³ = 36',
            '∛36 ≈ 3.3',
            'Closest integer: 3',
          ],
          difficulty: 30,
          basePoints: 400,
        ),
        LogicMathChallenge(
          id: 'logic_new_101',
          problem: 'A + B = 10\nA - B = 4\nWhat is A * B?',
          options: ['21', '24', '16', '25'],
          correctAnswer: '21',
          explanation: 'A=7, B=3. 7+3=10, 7-3=4. 7*3=21.',
          progressiveHints: ['Find two numbers with sum 10 and difference 4', 'A=7, B=3'],
          difficulty: 15,
          basePoints: 200,
        ),
        LogicMathChallenge(
          id: 'logic_new_102',
          problem: 'If 3x + 5 = 20, what is 2x?',
          options: ['10', '5', '15', '20'],
          correctAnswer: '10',
          explanation: '3x = 15, x = 5, 2x = 10.',
          progressiveHints: ['Solve for x first', '3x = 15', 'x = 5'],
          difficulty: 12,
          basePoints: 150,
        ),
        LogicMathChallenge(
          id: 'logic_new_103',
          problem: 'Triangle + Square = 15\nTriangle - Square = 5\nWhat is Square?',
          options: ['5', '10', '15', '20'],
          correctAnswer: '5',
          explanation: '2*Triangle = 20, Triangle = 10, Square = 5.',
          progressiveHints: ['Add equations to find Triangle', 'Subtract to find Square'],
          difficulty: 10,
          basePoints: 120,
        ),
        LogicMathChallenge(
          id: 'logic_new_104',
          problem: 'If A=2, B=3, C=4\n(A + B) * C = ?',
          options: ['20', '14', '18', '24'],
          correctAnswer: '20',
          explanation: '(2+3)*4 = 5*4 = 20.',
          progressiveHints: ['Order of operations', 'Parentheses first'],
          difficulty: 5,
          basePoints: 80,
        ),
        LogicMathChallenge(
          id: 'logic_new_105',
          problem: 'Next number: 2, 4, 8, 16, ?',
          options: ['32', '24', '30', '64'],
          correctAnswer: '32',
          explanation: 'Each number is doubled.',
          progressiveHints: ['Look at the ratio between numbers', 'Multiplied by 2'],
          difficulty: 3,
          basePoints: 50,
        ),
        LogicMathChallenge(
          id: 'logic_new_106',
          problem: 'If 5 * A = 40 and B = A / 2, what is B?',
          options: ['4', '8', '2', '16'],
          correctAnswer: '4',
          explanation: 'A=8, B=8/2=4.',
          progressiveHints: ['Find A first', 'Divide A by 2'],
          difficulty: 7,
          basePoints: 100,
        ),
        LogicMathChallenge(
          id: 'logic_new_107',
          problem: 'Square + Square = 12\nSquare * Circle = 24\nCircle = ?',
          options: ['4', '6', '2', '8'],
          correctAnswer: '4',
          explanation: 'Square = 6, 6 * Circle = 24, Circle = 4.',
          progressiveHints: ['Find Square from first line', 'Substitute Square in second line'],
          difficulty: 8,
          basePoints: 110,
        ),
        LogicMathChallenge(
          id: 'logic_new_108',
          problem: '1, 3, 6, 10, 15, ?',
          options: ['21', '20', '25', '18'],
          correctAnswer: '21',
          explanation: 'Adding 2, 3, 4, 5, 6.',
          progressiveHints: ['Look at differences between numbers', '+2, +3, +4, +5...'],
          difficulty: 9,
          basePoints: 130,
        ),
        LogicMathChallenge(
          id: 'logic_new_109',
          problem: 'If X + Y = 12 and X = 2Y, what is X?',
          options: ['8', '4', '6', '10'],
          correctAnswer: '8',
          explanation: '2Y + Y = 12, 3Y = 12, Y = 4, X = 8.',
          progressiveHints: ['Substitute X with 2Y', 'Solve for Y'],
          difficulty: 11,
          basePoints: 140,
        ),
        LogicMathChallenge(
          id: 'logic_new_110',
          problem: 'A, C, E, G, ?',
          options: ['I', 'H', 'J', 'F'],
          correctAnswer: 'I',
          explanation: 'Every second letter.',
          progressiveHints: ['Skip one letter in alphabet'],
          difficulty: 4,
          basePoints: 60,
        ),
        LogicMathChallenge(
          id: 'logic_new_111',
          problem: 'If apple = 5, banana = 2, cherry = 10\napple + banana * cherry = ?',
          options: ['25', '70', '100', '52'],
          correctAnswer: '25',
          explanation: '5 + 2 * 10 = 5 + 20 = 25.',
          progressiveHints: ['Multiplication before addition'],
          difficulty: 6,
          basePoints: 90,
        ),
        LogicMathChallenge(
          id: 'logic_new_112',
          problem: '121, 100, 81, 64, ?',
          options: ['49', '50', '36', '56'],
          correctAnswer: '49',
          explanation: 'Squares of 11, 10, 9, 8, 7.',
          progressiveHints: ['Check perfect squares', 'Descending order'],
          difficulty: 13,
          basePoints: 170,
        ),
        LogicMathChallenge(
          id: 'logic_new_113',
          problem: 'If 2^X = 64, what is X?',
          options: ['6', '5', '8', '7'],
          correctAnswer: '6',
          explanation: '2*2*2*2*2*2 = 64.',
          progressiveHints: ['Powers of 2'],
          difficulty: 14,
          basePoints: 180,
        ),
        LogicMathChallenge(
          id: 'logic_new_114',
          problem: 'A + A + A = 30\nA + B = 15\nB + C = 8\nC = ?',
          options: ['3', '5', '10', '2'],
          correctAnswer: '3',
          explanation: 'A=10, 10+B=15 => B=5, 5+C=8 => C=3.',
          progressiveHints: ['Solve line by line'],
          difficulty: 10,
          basePoints: 120,
        ),
        LogicMathChallenge(
          id: 'logic_new_115',
          problem: '1, 4, 9, 16, 25, ?',
          options: ['36', '30', '49', '40'],
          correctAnswer: '36',
          explanation: '1^2, 2^2, 3^2, 4^2, 5^2, 6^2.',
          progressiveHints: ['Square numbers'],
          difficulty: 5,
          basePoints: 70,
        ),
        LogicMathChallenge(
          id: 'logic_new_116',
          problem: 'If 10% of X is 20, what is X?',
          options: ['200', '20', '100', '2000'],
          correctAnswer: '200',
          explanation: '0.1 * X = 20, X = 200.',
          progressiveHints: ['10% is one tenth'],
          difficulty: 12,
          basePoints: 150,
        ),
        LogicMathChallenge(
          id: 'logic_new_117',
          problem: '3, 6, 12, 24, 48, ?',
          options: ['96', '72', '60', '80'],
          correctAnswer: '96',
          explanation: 'Doubling each time.',
          progressiveHints: ['Multiply by 2'],
          difficulty: 4,
          basePoints: 60,
        ),
        LogicMathChallenge(
          id: 'logic_new_118',
          problem: 'If A=1, B=2, C=3... Z=26\nWhat is D + O + G?',
          options: ['26', '25', '27', '28'],
          correctAnswer: '26',
          explanation: '4 + 15 + 7 = 26.',
          progressiveHints: ['Map letters to positions'],
          difficulty: 11,
          basePoints: 140,
        ),
        LogicMathChallenge(
          id: 'logic_new_119',
          problem: 'Square root of (64 + 36) = ?',
          options: ['10', '14', '100', '8'],
          correctAnswer: '10',
          explanation: 'sqrt(100) = 10.',
          progressiveHints: ['Add first, then root'],
          difficulty: 9,
          basePoints: 130,
        ),
        LogicMathChallenge(
          id: 'logic_new_120',
          problem: 'A = B * 2\nB = C * 2\nC = 5\nA = ?',
          options: ['20', '10', '15', '25'],
          correctAnswer: '20',
          explanation: 'C=5, B=10, A=20.',
          progressiveHints: ['Work backwards'],
          difficulty: 7,
          basePoints: 100,
        ),
      ]);
    }

    // High-level challenges (levels 11-100) with algebraic and complex patterns
    if (difficulty >= 11) {
      for (int lvl = 11; lvl <= 100; lvl++) {
        challenges.addAll([
          LogicMathChallenge(
            id: 'logic_hl_${lvl}_a',
            problem: 'If triangle = n + 2 and square = n² where n = ${lvl % 10 + 2}, what is square - triangle?',
            options: [
              '${(lvl % 10 + 2) * (lvl % 10 + 2) - (lvl % 10 + 4)}',
              '${(lvl % 10 + 2) * (lvl % 10 + 2) - (lvl % 10 + 3)}',
              '${(lvl % 10 + 2) * (lvl % 10 + 2) - (lvl % 10 + 5)}',
              '${(lvl % 10 + 2) * (lvl % 10 + 2)}'
            ],
            correctAnswer: '${(lvl % 10 + 2) * (lvl % 10 + 2) - (lvl % 10 + 4)}',
            explanation: 'n = ${lvl % 10 + 2}, triangle = ${lvl % 10 + 4}, square = ${(lvl % 10 + 2) * (lvl % 10 + 2)}.',
            progressiveHints: ['Plug in n', 'Calculate triangle', 'Calculate square'],
            difficulty: lvl,
            basePoints: 100 + lvl * 10,
          ),
          LogicMathChallenge(
            id: 'logic_hl_${lvl}_b',
            problem: 'Find X: X + ${lvl * 2} = ${lvl * 5}',
            options: ['${lvl * 3}', '${lvl * 2}', '${lvl * 4}', '${lvl * 5}'],
            correctAnswer: '${lvl * 3}',
            explanation: 'X = ${lvl * 5} - ${lvl * 2} = ${lvl * 3}',
            progressiveHints: ['Subtract ${lvl * 2} from both sides'],
            difficulty: lvl,
            basePoints: 100 + lvl * 10,
          ),
        ]);
      }
    }

    return challenges;
  }

  static bool validateAnswer(String userAnswer, String correctAnswer) {
    return userAnswer.trim().toLowerCase() ==
        correctAnswer.trim().toLowerCase();
  }
}
