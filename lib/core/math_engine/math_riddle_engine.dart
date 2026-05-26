import 'dart:math';
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

  static MathRiddle generateWordProblem(int difficulty) {
    final templates = _getWordProblemTemplates(difficulty);
    final template = templates[_random.nextInt(templates.length)];

    final optionsStr = template['options']!;
    final optionsList = optionsStr
        .substring(1, optionsStr.length - 1)
        .split(', ');
    final options = optionsList.map((s) => s.replaceAll('"', '')).toList();

    final hintsStr = template['hints']!;
    final hintsList = hintsStr.substring(1, hintsStr.length - 1).split(', ');
    final hints = hintsList.map((s) => s.replaceAll('"', '')).toList();

    return MathRiddle(
      id: 'wordprob_${DateTime.now().millisecondsSinceEpoch}',
      type: MathRiddleType.wordProblem,
      difficulty: difficulty,
      question: template['question']!,
      options: options,
      correctAnswer: template['answer']!,
      explanation: template['explanation']!,
      progressiveHints: hints,
      basePoints: difficulty * 75,
    );
  }

  static NumberSequence generateNumberSequence(int difficulty) {
    List<String> rules;

    if (difficulty <= 1) {
      rules = ['+n', '+n'];
    } else if (difficulty <= 3) {
      rules = ['+n', '-n', '*n', 'powers_of_2', 'larger_squares'];
    } else if (difficulty <= 5) {
      rules = [
        '+n',
        '-n',
        '*n',
        '/n',
        '+n +m',
        'squares',
        'cubes',
        'primes',
        'powers_of_2',
        'powers_of_3',
        'triangle_numbers',
        'alternating',
        'factorials',
        'larger_squares',
      ];
    } else {
      rules = [
        '+n',
        '-n',
        '*n',
        '/n',
        '+n +m',
        '-n +m',
        '*n +m',
        'squares',
        'cubes',
        'primes',
        'powers_of_2',
        'powers_of_3',
        'triangle_numbers',
        'alternating',
        'geometric',
        'perfect_squares_reverse',
        'prime_differences',
        'digit_sum',
        'palindromic',
        'factorials',
        'prime_squares',
        'alternating_sum',
        'fibonacci',
        'reciprocal_sum',
      ];
    }

    String explanation = '';
    List<String> progressiveHints = [];

    final rule = rules[_random.nextInt(rules.length)];

    int missingIndex;
    List<int> sequence;
    int correctAnswer;
    String displayRule;

    switch (rule) {
      case '+n':
        final step = _random.nextInt(5) + 2;
        final start = _random.nextInt(10);
        missingIndex = _random.nextInt(5) + 2;
        sequence = List.generate(6, (i) => start + i * step);
        correctAnswer = start + missingIndex * step;
        displayRule = 'Each number increases by $step';
        break;
      case '-n':
        final start = _random.nextInt(50) + 50;
        final step = _random.nextInt(5) + 2;
        missingIndex = _random.nextInt(3) + 2;
        sequence = List.generate(6, (i) => start - i * step);
        correctAnswer = start - missingIndex * step;
        displayRule = 'Each number decreases by $step';
        break;
      case '*n':
        final factor = _random.nextInt(5) + 2; // Up to ×6 for more challenge
        missingIndex = _random.nextInt(2) + 3;
        sequence = [
          1,
          factor,
          factor * factor,
          pow(factor, 3).toInt(),
          pow(factor, 4).toInt(),
        ];
        correctAnswer = pow(factor, 5).toInt();
        sequence.add(correctAnswer);
        displayRule = 'Each number is multiplied by $factor';
        break;
      case 'fibonacci':
        missingIndex = 5;
        sequence = [1, 1, 2, 3, 5];
        correctAnswer = 8;
        sequence.add(correctAnswer);
        displayRule = 'Each number is the sum of the previous two';
        break;
      case 'larger_squares':
        missingIndex = 4;
        final start = _random.nextInt(10) + 6; // Start from 6² or higher
        sequence = List.generate(5, (i) => (start + i) * (start + i));
        correctAnswer = (start + 5) * (start + 5);
        sequence.add(correctAnswer);
        displayRule = 'These are consecutive square numbers';
        break;
      case '+n +m':
        final n = _random.nextInt(3) + 2;
        final m = _random.nextInt(3) + 4;
        missingIndex = _random.nextInt(3) + 3;
        sequence = List.generate(5, (i) => 5 + i * n + (i ~/ 2) * m);
        correctAnswer = 5 + missingIndex * n + (missingIndex ~/ 2) * m;
        sequence.add(correctAnswer);
        displayRule = 'Numbers increase by alternating amounts';
        break;
      case 'squares':
        missingIndex = 4;
        sequence = [1, 4, 9, 16, 25];
        correctAnswer = 36;
        sequence.add(correctAnswer);
        displayRule = 'These are square numbers';
        break;
      case 'cubes':
        missingIndex = 4;
        sequence = [1, 8, 27, 64, 125];
        correctAnswer = 216;
        sequence.add(correctAnswer);
        displayRule = 'These are cube numbers';
        break;
      case 'powers_of_3':
        missingIndex = 4;
        sequence = [3, 9, 27, 81, 243];
        correctAnswer = 729;
        sequence.add(correctAnswer);
        displayRule = 'Powers of 3';
        break;
      case 'primes':
        missingIndex = 4;
        sequence = [2, 3, 5, 7, 11];
        correctAnswer = 13;
        sequence.add(correctAnswer);
        displayRule = 'These are prime numbers';
        break;
      case 'powers_of_2':
        missingIndex = 4;
        sequence = [2, 4, 8, 16, 32];
        correctAnswer = 64;
        sequence.add(correctAnswer);
        displayRule = 'Each number is double the previous';
        break;
      case 'triangle_numbers':
        missingIndex = 4;
        sequence = [1, 3, 6, 10, 15];
        correctAnswer = 21;
        sequence.add(correctAnswer);
        displayRule = 'Sum of consecutive positive integers';
        break;
      case 'alternating':
        missingIndex = 4;
        sequence = [1, -1, 1, -1, 1];
        correctAnswer = -1;
        sequence.add(correctAnswer);
        displayRule = 'Alternates between 1 and -1';
        break;
      case 'geometric':
        final ratio = _random.nextInt(2) + 2;
        missingIndex = _random.nextInt(2) + 3;
        sequence = List.generate(5, (i) => (i + 1) * ratio);
        correctAnswer = (missingIndex + 1) * ratio;
        sequence.add(correctAnswer);
        displayRule = 'Multiply by $ratio each time';
        break;
      case 'perfect_squares_reverse':
        missingIndex = 3;
        sequence = [100, 81, 64, 49, 36];
        correctAnswer = 25;
        sequence.add(correctAnswer);
        displayRule = 'Perfect squares in reverse order';
        break;
      case 'prime_differences':
        missingIndex = 4;
        sequence = [2, 3, 5, 11, 17];
        correctAnswer = 29;
        sequence.add(correctAnswer);
        displayRule = 'Primes with increasing gaps';
        break;
      case 'digit_sum':
        missingIndex = 4;
        sequence = [1, 2, 3, 4, 5, 6, 7, 8, 9, 1]; // digit sums of 1,2,3,...,10
        correctAnswer = 0; // 10 has digit sum 1+0=1, but let's use a simpler pattern
        sequence = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        correctAnswer = 11;
        sequence.add(correctAnswer);
        displayRule = 'Consecutive positive integers';
        break;
      case 'palindromic':
        missingIndex = 3;
        sequence = [1, 2, 3, 4, 5, 6, 7, 8, 9];
        correctAnswer = 11; // 11 is palindromic
        sequence.add(correctAnswer);
        displayRule = 'First palindromic numbers';
        break;
      case '-n +m':
        final n = _random.nextInt(3) + 2;
        final m = _random.nextInt(3) + 1;
        missingIndex = _random.nextInt(2) + 3;
        sequence = List.generate(5, (i) => 20 - i * n + (i % 2) * m);
        correctAnswer = 20 - missingIndex * n + (missingIndex % 2) * m;
        sequence.add(correctAnswer);
        displayRule = 'Complex alternating pattern';
        break;
      case '*n +m':
        final n = _random.nextInt(2) + 2;
        final m = _random.nextInt(5) + 1;
        missingIndex = _random.nextInt(2) + 3;
        sequence = List.generate(5, (i) => (i + 1) * n + m);
        correctAnswer = (missingIndex + 1) * n + m;
        sequence.add(correctAnswer);
        displayRule = 'Multiply by $n and add $m';
        explanation = 'Each term is (position) × $n + $m.';
        progressiveHints = [
          'Look at the differences between terms',
          'Try multiplying position by $n',
          'Add $m to get the sequence',
        ];
        break;
      case 'factorials':
        missingIndex = 4;
        sequence = [1, 2, 6, 24, 120];
        correctAnswer = 720;
        sequence.add(correctAnswer);
        displayRule = 'Factorial numbers (n!)';
        explanation = 'Factorials: n! = n × (n-1) × ... × 1';
        progressiveHints = [
          'Each term multiplies by the next integer',
          '1! = 1, 2! = 2, 3! = 6, etc.',
          'Next is 5! = 120',
        ];
        break;
      case 'prime_squares':
        missingIndex = 4;
        sequence = [4, 9, 25, 49, 121];
        correctAnswer = 169;
        sequence.add(correctAnswer);
        displayRule = 'Squares of prime numbers';
        explanation = 'Squares of primes: 2², 3², 5², 7², 11², 13²';
        progressiveHints = [
          'The numbers are squares',
          'The bases are prime numbers',
          'Next prime after 11 is 13',
        ];
        break;
      case 'alternating_sum':
        missingIndex = 4;
        sequence = [1, -1, 2, -2, 3];
        correctAnswer = -3;
        sequence.add(correctAnswer);
        displayRule = 'Alternating positive and negative integers';
        explanation = 'Positive and negative integers alternating';
        progressiveHints = [
          'Signs alternate',
          'Absolute values increase by 1',
          'Next is negative 3',
        ];
        break;
      case 'powers_of_three':
        missingIndex = 4;
        sequence = [3, 9, 27, 81, 243];
        correctAnswer = 729;
        sequence.add(correctAnswer);
        displayRule = 'Powers of 3';
        explanation = '3^1, 3^2, 3^3, 3^4, 3^5, 3^6';
        progressiveHints = [
          'Each term multiplies by 3',
          'Geometric sequence with ratio 3',
          'Next is 3^6 = 729',
        ];
        break;
      case 'reciprocal_sum':
        missingIndex = 4;
        sequence = [1, 3, 7, 15, 31];
        correctAnswer = 63;
        sequence.add(correctAnswer);
        displayRule = 'Sum of reciprocals: 1 + 1/2 + 1/4 + ...';
        explanation = 'Each term = 2^n - 1';
        progressiveHints = [
          'Differences: 2, 4, 8, 16',
          'Powers of 2 minus 1',
          'Next is 64 - 1 = 63',
        ];
        break;
      default:
        missingIndex = 3;
        sequence = [2, 4, 6, 8, 10];
        correctAnswer = 12;
        sequence.add(correctAnswer);
        displayRule = 'Numbers increase by 2';
        explanation = 'Arithmetic sequence with common difference 2';
        progressiveHints = [
          'Even numbers',
          'Increase by 2 each time',
          'Next is 10 + 2 = 12',
        ];
    }

    final options = _generateOptions(correctAnswer, difficulty);

    return NumberSequence(
      id: 'seq_${DateTime.now().millisecondsSinceEpoch}',
      sequence: sequence,
      missingIndex: missingIndex,
      rule: displayRule,
      options: options,
      correctAnswer: correctAnswer.toString(),
      explanation: explanation,
      progressiveHints: progressiveHints,
      difficulty: difficulty,
    );
  }

  static LogicMathChallenge generateLogicChallenge(int difficulty) {
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

  static List<Map<String, String>> _getWordProblemTemplates(int difficulty) {
    final templates = <Map<String, String>>[
      {
        'question':
            'Sarah has 12 apples. She gives 5 to her friend. How many does she have left?',
        'options': '["3", "7", "17", "8"]',
        'answer': '7',
        'explanation': '12 - 5 = 7 apples remaining',
        'hints':
            '["Subtraction is needed here", "Take 5 away from 12", "12 - 5 = 7"]',
      },
      {
        'question':
            'A baker makes 24 cupcakes. He puts them in boxes of 6. How many boxes does he need?',
        'options': '["3", "4", "5", "6"]',
        'answer': '4',
        'explanation': '24 / 6 = 4 boxes',
        'hints':
            '["Division is needed", "How many groups of 6 make 24?", "24 / 6 = 4"]',
      },
      {
        'question':
            'Tom has 3 bags with 4 marbles each. How many marbles does he have total?',
        'options': '["10", "12", "14", "7"]',
        'answer': '12',
        'explanation': '3 x 4 = 12 marbles',
        'hints':
            '["Multiplication is needed", "Add 4 three times", "3 x 4 = 12"]',
      },
      {
        'question':
            'A bus has 45 seats. If 28 passengers are seated, how many empty seats remain?',
        'options': '["17", "18", "73", "27"]',
        'answer': '17',
        'explanation': '45 - 28 = 17 empty seats',
        'hints': '["Subtraction needed", "45 minus 28", "45 - 28 = 17"]',
      },
      {
        'question':
            'Anna buys 5 books at 8 dollars each. How much does she spend in total?',
        'options': '["35", "40", "45", "13"]',
        'answer': '40',
        'explanation': '5 x 8 = 40 dollars',
        'hints': '["Multiply number of books by price", "5 x 8", "5 x 8 = 40"]',
      },
      {
        'question':
            'A farmer has 56 cows. He divides them into 8 equal pens. How many cows per pen?',
        'options': '["6", "7", "8", "9"]',
        'answer': '7',
        'explanation': '56 / 8 = 7 cows per pen',
        'hints': '["Division needed", "Divide 56 by 8", "56 ÷ 8 = 7"]',
      },
      {
        'question':
            'Jack saves 15 dollars per week. After 6 weeks, how much will he have saved?',
        'options': '["80", "90", "21", "75"]',
        'answer': '90',
        'explanation': '15 x 6 = 90 dollars',
        'hints':
            '["Multiply weekly savings by weeks", "6 x 15", "15 times 6 = 90"]',
      },
      {
        'question':
            'A garden has 144 flowers planted in 12 rows. How many flowers per row?',
        'options': '["10", "11", "12", "13"]',
        'answer': '12',
        'explanation': '144 / 12 = 12 flowers per row',
        'hints': '["Divide total by rows", "144 ÷ 12", "144 / 12 = 12"]',
      },
      {
        'question':
            'A train travels 240 km in 4 hours. What is its average speed?',
        'options': '["50 km/h", "60 km/h", "70 km/h", "80 km/h"]',
        'answer': '60 km/h',
        'explanation': '240 / 4 = 60 km per hour',
        'hints': '["Divide distance by time", "240 ÷ 4", "240 / 4 = 60"]',
      },
      {
        'question':
            'Lisa bought 7 packs of stickers with 9 stickers each. How many stickers total?',
        'options': '["63", "54", "72", "16"]',
        'answer': '63',
        'explanation': '7 x 9 = 63 stickers',
        'hints':
            '["Multiply packs by stickers per pack", "7 × 9", "7 × 9 = 63"]',
      },
    ];

    if (difficulty >= 4) {
      templates.addAll([
        {
          'question':
              'A company makes 50000 dollars profit. They share it equally among 5 partners. How much each?',
          'options': '["9000", "10000", "11000", "12000"]',
          'answer': '10000',
          'explanation': '50000 / 5 = 10000 dollars each',
          'hints':
              '["Divide profit by partners", "50000 divided by 5", "50000 / 5 = 10000"]',
        },
        {
          'question':
              'A rectangle has length 15m and width 8m. What is the perimeter?',
          'options': '["23m", "46m", "120m", "30m"]',
          'answer': '46m',
          'explanation': '(15 + 8) × 2 = 46m',
          'hints':
              '["Perimeter is total distance around", "Add length and width, then double", "(15+8)×2 = 46"]',
        },
        {
          'question':
              'John is 24 years old. His sister is 6 years younger. How old is his sister?',
          'options': '["16", "18", "20", "30"]',
          'answer': '18',
          'explanation': '24 - 6 = 18 years old',
          'hints': '["Subtract sister\'s age difference", "24 minus 6", "24 - 6 = 18"]',
        },
        {
          'question':
              'A store sells 120 books. 75 are sold. What percentage remains?',
          'options': '["37.5%", "62.5%", "50%", "25%"]',
          'answer': '37.5%',
          'explanation': '(120 - 75) / 120 × 100 = 37.5%',
          'hints': '["Find remaining books first", "Then divide by total and multiply by 100", "(45/120)×100 = 37.5"]',
        },
      ]);
    }

    if (difficulty >= 6) {
      templates.addAll([
        {
          'question':
              'A car travels 300km at 60km/h. How long does it take?',
          'options': '["4 hours", "5 hours", "6 hours", "3 hours"]',
          'answer': '5 hours',
          'explanation': '300 / 60 = 5 hours',
          'hints': '["Divide distance by speed", "300 ÷ 60", "300 / 60 = 5"]',
        },
        {
          'question':
              'If 3 apples cost 6 dollars, how much do 7 apples cost?',
          'options': '["12", "14", "16", "18"]',
          'answer': '14',
          'explanation': '(6 / 3) × 7 = 14 dollars',
          'hints': '["Find price per apple first", "Then multiply by 7", "(6÷3)×7 = 14"]',
        },
      {
        'question':
            'A tank holds 1000 liters. It uses 150 liters per day. How many days does it last?',
        'options': '["6 days", "7 days", "5 days", "8 days"]',
        'answer': '6 days',
        'explanation': '1000 / 150 ≈ 6.67, but since it\'s daily use, approximately 6 days',
        'hints': '["Divide total by daily use", "1000 ÷ 150", "1000 / 150 = 6.67"]',
      },
      {
        'question':
            'A rectangle garden is 15 meters long and 8 meters wide. What is its area?',
        'options': '["23 m²", "120 m²", "46 m²", "15 m²"]',
        'answer': '120 m²',
        'explanation': '15 × 8 = 120 square meters',
        'hints': '["Area = length × width", "15 × 8", "15 × 8 = 120"]',
      },
      {
        'question':
            'John has 3 times as many marbles as Mary. Mary has 12 marbles. How many does John have?',
        'options': '["4", "24", "36", "15"]',
        'answer': '36',
        'explanation': '12 × 3 = 36 marbles',
        'hints': '["John has 3 times Mary\'s amount", "12 × 3", "12 × 3 = 36"]',
      },
      {
        'question':
            'A pizza is cut into 8 equal slices. If 5 friends eat 1 slice each, how many slices remain?',
        'options': '["3", "5", "8", "13"]',
        'answer': '3',
        'explanation': '8 - 5 = 3 slices remaining',
        'hints': '["Subtract eaten slices from total", "8 - 5", "8 - 5 = 3"]',
      },
      {
        'question':
            'Sarah runs 5 kilometers every day. How many kilometers does she run in 7 days?',
        'options': '["12 km", "35 km", "28 km", "42 km"]',
        'answer': '35 km',
        'explanation': '5 × 7 = 35 kilometers',
        'hints': '["Multiply daily distance by number of days", "5 × 7", "5 × 7 = 35"]',
      },
      {
        'question':
            'A bookshelf has 4 shelves with 15 books each. How many books total?',
        'options': '["19", "45", "60", "75"]',
        'answer': '60',
        'explanation': '4 × 15 = 60 books',
        'hints': '["Multiply shelves by books per shelf", "4 × 15", "4 × 15 = 60"]',
      },
      {
        'question':
            'Tom has 25 stickers. He gives away 9. What fraction of his stickers did he give away?',
        'options': '["9/25", "16/25", "25/9", "9/16"]',
        'answer': '9/25',
        'explanation': '9 ÷ 25 = 9/25 of his stickers',
        'hints': '["Given away over total stickers", "9 out of 25", "9/25"]',
      },
      {
        'question':
            'A train travels at 80 km/h. How far does it travel in 2.5 hours?',
        'options': '["200 km", "100 km", "160 km", "250 km"]',
        'answer': '200 km',
        'explanation': '80 × 2.5 = 200 kilometers',
        'hints': '["Distance = speed × time", "80 × 2.5", "80 × 2.5 = 200"]',
      },
      {
        'question':
            'Lisa has 48 candies. She wants to share them equally among 6 friends. How many each?',
        'options': '["6", "7", "8", "9"]',
        'answer': '8',
        'explanation': '48 ÷ 6 = 8 candies each',
        'hints': '["Divide total by number of friends", "48 ÷ 6", "48 ÷ 6 = 8"]',
      },
      {
        'question':
            'A movie theater has 350 seats. If 287 are occupied, how many are empty?',
        'options': '["63", "73", "83", "93"]',
        'answer': '63',
        'explanation': '350 - 287 = 63 empty seats',
        'hints': '["Subtract occupied from total seats", "350 - 287", "350 - 287 = 63"]',
      },
      {
        'question':
            'Mike buys 3 video games at 25 dollars each and 2 controllers at 15 dollars each. How much total?',
        'options': '["75", "90", "105", "120"]',
        'answer': '105',
        'explanation': '(3 × 25) + (2 × 15) = 75 + 30 = 105 dollars',
        'hints': '["Calculate cost of games and controllers separately", "3×25 + 2×15", "75 + 30 = 105"]',
      },
      {
        'question':
            'A pizza has 12 slices. 5 friends each eat 2 slices. How many slices remain?',
        'options': '["2", "7", "10", "17"]',
        'answer': '2',
        'explanation': '12 - (5 × 2) = 12 - 10 = 2 slices',
        'hints': '["Each friend eats 2 slices", "5 friends × 2 slices each = 10 slices eaten", "12 - 10 = 2"]',
      },
      {
        'question':
            'Sarah has 3 boxes with 8 stickers each. She gives away 12 stickers. How many does she have left?',
        'options': '["12", "16", "20", "24"]',
        'answer': '12',
        'explanation': '(3 × 8) - 12 = 24 - 12 = 12 stickers',
        'hints': '["First find total stickers", "3 boxes × 8 stickers = 24", "24 - 12 = 12"]',
      },
      {
        'question':
            'A train travels 180 km in 3 hours. What is its speed?',
        'options': '["50 km/h", "55 km/h", "60 km/h", "65 km/h"]',
        'answer': '60 km/h',
        'explanation': '180 ÷ 3 = 60 km per hour',
        'hints': '["Speed = distance ÷ time", "180 ÷ 3", "180 ÷ 3 = 60"]',
      },
      {
        'question':
            'Tom collects 7 marbles each day for 6 days. How many marbles does he have?',
        'options': '["35", "36", "37", "42"]',
        'answer': '42',
        'explanation': '7 × 6 = 42 marbles',
        'hints': '["Multiply marbles per day by number of days", "7 × 6", "7 × 6 = 42"]',
      },
      {
        'question':
            'There are 24 students. Each gets 3 pencils. How many pencils total?',
        'options': '["70", "72", "74", "76"]',
        'answer': '72',
        'explanation': '24 × 3 = 72 pencils',
        'hints': '["Multiply students by pencils each", "24 × 3", "24 × 3 = 72"]',
      },
      {
        'question':
            'Anna has 45 dollars. She spends 18 dollars. How much remains?',
        'options': '["25", "26", "27", "28"]',
        'answer': '27',
        'explanation': '45 - 18 = 27 dollars',
        'hints': '["Subtract spent money from total", "45 - 18", "45 - 18 = 27"]',
      },
      {
        'question':
            'A rectangle is 12 meters long and 5 meters wide. What is the perimeter?',
        'options': '["29m", "34m", "60m", "17m"]',
        'answer': '34m',
        'explanation': '(12 + 5) × 2 = 17 × 2 = 34 meters',
        'hints': '["Add length and width, then double", "(12 + 5) × 2", "17 × 2 = 34"]',
      },
      {
        'question':
            'A pizza costs 12 dollars. Sarah has 8 dollars. How much more does she need?',
        'options': '["3 dollars", "4 dollars", "5 dollars", "6 dollars"]',
        'answer': '4 dollars',
        'explanation': '12 - 8 = 4 dollars',
        'hints': '["Subtract what she has from the cost", "12 - 8", "12 - 8 = 4"]',
      },
      {
        'question':
            'There are 24 students in a class. 6 students are absent. How many are present?',
        'options': '["16", "17", "18", "19"]',
        'answer': '18',
        'explanation': '24 - 6 = 18 students present',
        'hints': '["Subtract absent students from total", "24 - 6", "24 - 6 = 18"]',
      },
      {
        'question':
            'Anna reads 8 pages per day. How many pages does she read in 6 days?',
        'options': '["42 pages", "44 pages", "46 pages", "48 pages"]',
        'answer': '48 pages',
        'explanation': '8 × 6 = 48 pages',
        'hints': '["Multiply pages per day by number of days", "8 × 6", "8 × 6 = 48"]',
      },
      {
        'question':
            'A box contains 36 chocolates. Tom eats 9. How many remain?',
        'options': '["25", "26", "27", "28"]',
        'answer': '27',
        'explanation': '36 - 9 = 27 chocolates',
        'hints': '["Subtract eaten chocolates from total", "36 - 9", "36 - 9 = 27"]',
      },
      {
        'question':
            'Sarah has 15 stickers. She gives 7 to her friend. How many does she have left?',
        'options': '["7", "8", "9", "10"]',
        'answer': '8',
        'explanation': '15 - 7 = 8 stickers',
        'hints': '["Subtract given stickers from total", "15 - 7", "15 - 7 = 8"]',
      },
      {
        'question':
            'There are 5 apples in a basket. Mom adds 3 more. How many apples now?',
        'options': '["6", "7", "8", "9"]',
        'answer': '8',
        'explanation': '5 + 3 = 8 apples',
        'hints': '["Add the new apples to the existing ones", "5 + 3", "5 + 3 = 8"]',
      },
      {
        'question':
            'John has 12 marbles. He loses 4. How many does he have now?',
        'options': '["6", "7", "8", "9"]',
        'answer': '8',
        'explanation': '12 - 4 = 8 marbles',
        'hints': '["Subtract lost marbles from total", "12 - 4", "12 - 4 = 8"]',
      },
      {
        'question':
            'A train has 8 cars. Each car has 6 passengers. How many passengers total?',
        'options': '["42", "44", "46", "48"]',
        'answer': '48',
        'explanation': '8 × 6 = 48 passengers',
        'hints': '["Multiply cars by passengers per car", "8 × 6", "8 × 6 = 48"]',
      },
      {
        'question':
            'Lisa buys 4 books at 7 dollars each. How much does she spend?',
        'options': '["25 dollars", "26 dollars", "27 dollars", "28 dollars"]',
        'answer': '28 dollars',
        'explanation': '4 × 7 = 28 dollars',
        'hints': '["Multiply number of books by price each", "4 × 7", "4 × 7 = 28"]',
      },
      {
        'question':
            'There are 50 students. 18 are boys. How many are girls?',
        'options': '["30", "31", "32", "33"]',
        'answer': '32',
        'explanation': '50 - 18 = 32 girls',
        'hints': '["Subtract boys from total students", "50 - 18", "50 - 18 = 32"]',
      },
      {
        'question':
            'Tom has 9 toy cars. He gets 5 more for his birthday. How many now?',
        'options': '["12", "13", "14", "15"]',
        'answer': '14',
        'explanation': '9 + 5 = 14 toy cars',
        'hints': '["Add new cars to existing cars", "9 + 5", "9 + 5 = 14"]',
      },
      {
        'question':
            'A garden has 22 flowers. 8 wilt. How many flowers remain?',
        'options': '["12", "13", "14", "15"]',
        'answer': '14',
        'explanation': '22 - 8 = 14 flowers',
        'hints': '["Subtract wilted flowers from total", "22 - 8", "22 - 8 = 14"]',
      },
      {
        'question':
            'Sarah has 6 cookies. She eats 3. How many left?',
        'options': '["2", "3", "4", "5"]',
        'answer': '3',
        'explanation': '6 - 3 = 3 cookies',
        'hints': '["Subtract eaten cookies from total", "6 - 3", "6 - 3 = 3"]',
      },
      {
        'question':
            'There are 3 baskets with 7 apples each. How many apples total?',
        'options': '["19", "20", "21", "22"]',
        'answer': '21',
        'explanation': '3 × 7 = 21 apples',
        'hints': '["Multiply baskets by apples per basket", "3 × 7", "3 × 7 = 21"]',
      },
      {
        'question':
            'Mike has 16 stickers. He gives 9 to his sister. How many left?',
        'options': '["5", "6", "7", "8"]',
        'answer': '7',
        'explanation': '16 - 9 = 7 stickers',
        'hints': '["Subtract given stickers from total", "16 - 9", "16 - 9 = 7"]',
      },
      {
        'question':
            'A movie theater has 120 seats. 87 are occupied. How many empty?',
        'options': '["31", "32", "33", "34"]',
        'answer': '33',
        'explanation': '120 - 87 = 33 empty seats',
        'hints': '["Subtract occupied seats from total", "120 - 87", "120 - 87 = 33"]',
      },
      {
        'question':
            'Anna has 14 pencils. She buys 6 more. How many now?',
        'options': '["18", "19", "20", "21"]',
        'answer': '20',
        'explanation': '14 + 6 = 20 pencils',
        'hints': '["Add new pencils to existing ones", "14 + 6", "14 + 6 = 20"]',
      },
      {
        'question':
            'There are 25 birds in a tree. 11 fly away. How many remain?',
        'options': '["12", "13", "14", "15"]',
        'answer': '14',
        'explanation': '25 - 11 = 14 birds',
        'hints': '["Subtract flown birds from total", "25 - 11", "25 - 11 = 14"]',
      },
      {
        'question':
            'A bakery makes 8 cakes per hour. How many in 5 hours?',
        'options': '["35", "36", "37", "38"]',
        'answer': '40',
        'explanation': '8 × 5 = 40 cakes',
        'hints': '["Multiply cakes per hour by hours", "8 × 5", "8 × 5 = 40"]',
      },
      {
        'question':
            'Sarah has 19 marbles. She loses 6. How many left?',
        'options': '["11", "12", "13", "14"]',
        'answer': '13',
        'explanation': '19 - 6 = 13 marbles',
        'hints': '["Subtract lost marbles from total", "19 - 6", "19 - 6 = 13"]',
      },
      {
        'question':
            '7 + 8 = ?',
        'options': '["14", "15", "16", "17"]',
        'answer': '15',
        'explanation': '7 + 8 = 15',
        'hints': '["Add the two numbers", "7 + 8", "7 + 8 = 15"]',
      },
      {
        'question':
            '12 - 5 = ?',
        'options': '["5", "6", "7", "8"]',
        'answer': '7',
        'explanation': '12 - 5 = 7',
        'hints': '["Subtract 5 from 12", "12 - 5", "12 - 5 = 7"]',
      },
      {
        'question':
            '6 × 4 = ?',
        'options': '["20", "22", "24", "26"]',
        'answer': '24',
        'explanation': '6 × 4 = 24',
        'hints': '["Multiply 6 by 4", "6 × 4", "6 × 4 = 24"]',
      },
      {
        'question':
            '18 ÷ 3 = ?',
        'options': '["4", "5", "6", "7"]',
        'answer': '6',
        'explanation': '18 ÷ 3 = 6',
        'hints': '["Divide 18 by 3", "18 ÷ 3", "18 ÷ 3 = 6"]',
      },
      {
        'question':
            '9 + 11 = ?',
        'options': '["18", "19", "20", "21"]',
        'answer': '20',
        'explanation': '9 + 11 = 20',
        'hints': '["Add 9 and 11", "9 + 11", "9 + 11 = 20"]',
      },
      {
        'question':
            '15 - 7 = ?',
        'options': '["6", "7", "8", "9"]',
        'answer': '8',
        'explanation': '15 - 7 = 8',
        'hints': '["Subtract 7 from 15", "15 - 7", "15 - 7 = 8"]',
      },
      {
        'question':
            '5 × 7 = ?',
        'options': '["30", "32", "35", "37"]',
        'answer': '35',
        'explanation': '5 × 7 = 35',
        'hints': '["Multiply 5 by 7", "5 × 7", "5 × 7 = 35"]',
      },
      {
        'question':
            '24 ÷ 4 = ?',
        'options': '["4", "5", "6", "7"]',
        'answer': '6',
        'explanation': '24 ÷ 4 = 6',
        'hints': '["Divide 24 by 4", "24 ÷ 4", "24 ÷ 4 = 6"]',
      },
      {
        'question':
            '13 + 9 = ?',
        'options': '["20", "21", "22", "23"]',
        'answer': '22',
        'explanation': '13 + 9 = 22',
        'hints': '["Add 13 and 9", "13 + 9", "13 + 9 = 22"]',
      },
      {
        'question':
            '20 - 8 = ?',
        'options': '["10", "11", "12", "13"]',
        'answer': '12',
        'explanation': '20 - 8 = 12',
        'hints': '["Subtract 8 from 20", "20 - 8", "20 - 8 = 12"]',
      },
      {
        'question':
            '8 × 3 = ?',
        'options': '["21", "22", "23", "24"]',
        'answer': '24',
        'explanation': '8 × 3 = 24',
        'hints': '["Multiply 8 by 3", "8 × 3", "8 × 3 = 24"]',
      },
      {
        'question':
            '27 ÷ 9 = ?',
        'options': '["2", "3", "4", "5"]',
        'answer': '3',
        'explanation': '27 ÷ 9 = 3',
        'hints': '["Divide 27 by 9", "27 ÷ 9", "27 ÷ 9 = 3"]',
      },
      {
        'question':
            'A square has sides of 12 cm. What is its perimeter?',
        'options': '["24 cm", "36 cm", "48 cm", "144 cm"]',
        'answer': '48 cm',
        'explanation': '4 × 12 = 48 cm (all sides equal)',
        'hints': '["Perimeter = 4 × side length", "4 × 12", "4 × 12 = 48"]',
      },
      {
        'question':
            'Emma reads 8 pages per day. How many days to read 120 pages?',
        'options': '["13 days", "14 days", "15 days", "16 days"]',
        'answer': '15 days',
        'explanation': '120 ÷ 8 = 15 days',
        'hints': '["Divide total pages by daily reading", "120 ÷ 8", "120 ÷ 8 = 15"]',
      },
      {
        'question':
            'A bag contains 85 marbles. 23 are red, 31 are blue. How many are other colors?',
        'options': '["31", "39", "46", "54"]',
        'answer': '31',
        'explanation': '85 - (23 + 31) = 85 - 54 = 31 marbles',
        'hints': '["Subtract known colors from total", "85 - (23 + 31)", "85 - 54 = 31"]',
      },
      {
        'question':
            'Sarah is 14 years old. Her brother is 3 years younger. How old will he be in 5 years?',
        'options': '["16", "17", "19", "22"]',
        'answer': '16',
        'explanation': '(14 - 3) + 5 = 11 + 5 = 16 years old',
        'hints': '["First find brother\'s current age", "14 - 3 = 11, then 11 + 5", "11 + 5 = 16"]',
      },
      {
        'question':
            'A store sells pencils in packs of 12. How many packs needed for 156 pencils?',
        'options': '["11 packs", "12 packs", "13 packs", "14 packs"]',
        'answer': '13 packs',
        'explanation': '156 ÷ 12 = 13 packs',
        'hints': '["Divide total pencils by pack size", "156 ÷ 12", "156 ÷ 12 = 13"]',
      },
      ]);
    }

    return templates;
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
          id: 'logic_025',
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
      ]);
    }

    return challenges;
  }

  static bool validateAnswer(String userAnswer, String correctAnswer) {
    return userAnswer.trim().toLowerCase() ==
        correctAnswer.trim().toLowerCase();
  }

  static bool validateSequenceAnswer(int? userAnswer, String correctAnswer) {
    if (userAnswer == null) return false;
    return userAnswer.toString() == correctAnswer;
  }
}
