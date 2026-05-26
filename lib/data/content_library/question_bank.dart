import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum QuestionCategory {
  addition,
  subtraction,
  multiplication,
  division,
  mixed,
  visualCounting,
  wordProblems,
  logic,
  fractions,
  decimals,
}

enum QuestionDifficulty { beginner, easy, medium, hard, expert, master }

class Question {
  final int id;
  final String question;
  final int correctAnswer;
  final List<int> options;
  final QuestionCategory category;
  final QuestionDifficulty difficulty;
  final String? hint;
  final String? explanation;
  final Map<String, dynamic>? tags;

  const Question({
    required this.id,
    required this.question,
    required this.correctAnswer,
    required this.options,
    required this.category,
    required this.difficulty,
    this.hint,
    this.explanation,
    this.tags,
  });
}

class QuestionBank {
  final Map<QuestionCategory, List<Question>> _questions;
  final Random _random = Random();
  int _currentId = 0;

  QuestionBank._internal(this._questions);

  factory QuestionBank() {
    final bank = QuestionBank._internal({});
    for (var category in QuestionCategory.values) {
      bank._questions[category] = [];
    }
    return bank;
  }

  factory QuestionBank.preloaded() {
    final bank = QuestionBank._internal({});
    for (var category in QuestionCategory.values) {
      bank._questions[category] = [];
    }
    bank._loadAdditionQuestions();
    bank._loadSubtractionQuestions();
    bank._loadMultiplicationQuestions();
    bank._loadDivisionQuestions();
    bank._loadMixedQuestions();
    bank._loadVisualCountingQuestions();
    bank._loadWordProblems();
    bank._loadLogicQuestions();
    bank._loadFractionsQuestions();
    bank._loadDecimalsQuestions();
    return bank;
  }

  void _loadAdditionQuestions() {
    final category = QuestionCategory.addition;
    for (var diff in QuestionDifficulty.values) {
      final (min, max) = _getRangeForDifficulty(diff);
      for (int a = min; a <= max; a += _getStep(diff)) {
        for (int b = min; b <= max; b += _getStep(diff)) {
          if (a + b <= 10000) { // Increased max to 10000 for harder questions
            _questions[category]!.add(
              Question(
                id: _currentId++,
                question: '$a + $b = ?',
                correctAnswer: a + b,
                options: _generateOptions(a + b),
                category: category,
                difficulty: diff,
                hint: 'Add $a and $b together',
                tags: {
                  'operands': [a, b],
                },
              ),
            );
          }
        }
      }
    }
    // Add challenging multi-digit addition
    _addChallengingAddition();
  }

  void _addChallengingAddition() {
    final category = QuestionCategory.addition;
    final challengingAdditions = [
      {'q': '999 + 876 = ?', 'a': 1875},
      {'q': '2345 + 6789 = ?', 'a': 9134},
      {'q': '5678 + 4321 = ?', 'a': 9999},
      {'q': '7890 + 1234 = ?', 'a': 9124},
      {'q': '4567 + 5432 = ?', 'a': 9999},
      {'q': '1234 + 5678 = ?', 'a': 6912},
      {'q': '3456 + 6543 = ?', 'a': 9999},
      {'q': '789 + 987 = ?', 'a': 1776},
      {'q': '2468 + 1357 = ?', 'a': 3825},
      {'q': '8642 + 9753 = ?', 'a': 18395},
      {'q': '13579 + 24680 = ?', 'a': 38259},
      {'q': '97531 + 86420 = ?', 'a': 183951},
      {'q': '86420 + 97531 = ?', 'a': 183951},
      {'q': '75319 + 86420 = ?', 'a': 161739},
      {'q': '64208 + 97531 = ?', 'a': 161739},
      // Even more challenging additions with larger numbers
      {'q': '123456 + 789012 = ?', 'a': 912468},
      {'q': '345678 + 901234 = ?', 'a': 1246912},
      {'q': '567890 + 123456 = ?', 'a': 691346},
      {'q': '789012 + 345678 = ?', 'a': 1134690},
      {'q': '901234 + 567890 = ?', 'a': 1469124},
      {'q': '112233 + 445566 = ?', 'a': 557799},
      {'q': '223344 + 556677 = ?', 'a': 780021},
      {'q': '334455 + 667788 = ?', 'a': 1002243},
      {'q': '445566 + 778899 = ?', 'a': 1224465},
      {'q': '556677 + 889900 = ?', 'a': 1446577},
      {'q': '667788 + 990011 = ?', 'a': 1657799},
      {'q': '778899 + 101112 = ?', 'a': 880011},
      {'q': '889900 + 112233 = ?', 'a': 1002133},
      {'q': '990011 + 223344 = ?', 'a': 1213355},
      {'q': '101112 + 334455 = ?', 'a': 435567},
      {'q': '234567 + 890123 = ?', 'a': 1124690},
      {'q': '456789 + 123456 = ?', 'a': 580245},
      {'q': '678901 + 234567 = ?', 'a': 913468},
      {'q': '890123 + 345678 = ?', 'a': 1235801},
      {'q': '102345 + 678901 = ?', 'a': 781246},
      {'q': '345678 + 901234 = ?', 'a': 1246912},
      {'q': '567890 + 123456 = ?', 'a': 691346},
      {'q': '789012 + 345678 = ?', 'a': 1134690},
      {'q': '901234 + 567890 = ?', 'a': 1469124},
      {'q': '112233 + 445566 = ?', 'a': 557799},
      {'q': '223344 + 556677 = ?', 'a': 780021},
      {'q': '334455 + 667788 = ?', 'a': 1002243},
      {'q': '445566 + 778899 = ?', 'a': 1224465},
      {'q': '556677 + 889900 = ?', 'a': 1446577},
      {'q': '667788 + 990011 = ?', 'a': 1657799},
      {'q': '778899 + 101112 = ?', 'a': 880011},
      {'q': '889900 + 112233 = ?', 'a': 1002133},
      {'q': '990011 + 223344 = ?', 'a': 1213355},
      {'q': '101112 + 334455 = ?', 'a': 435567},
      {'q': '234567 + 890123 = ?', 'a': 1124690},
      {'q': '456789 + 123456 = ?', 'a': 580245},
    ];

    for (var item in challengingAdditions) {
      _questions[category]!.add(
        Question(
          id: _currentId++,
          question: item['q'] as String,
          correctAnswer: item['a'] as int,
          options: _generateOptions(item['a'] as int, range: 10),
          category: category,
          difficulty: QuestionDifficulty.expert,
          hint: 'Add the numbers carefully, carry over when needed',
        ),
      );
    }
  }

  void _loadSubtractionQuestions() {
    final category = QuestionCategory.subtraction;
    for (var diff in QuestionDifficulty.values) {
      final (min, max) = _getRangeForDifficulty(diff);
      for (int a = min; a <= max; a += _getStep(diff)) {
        for (int b = min; b <= a && b <= max; b += _getStep(diff)) {
          if (a - b >= 0) {
            _questions[category]!.add(
              Question(
                id: _currentId++,
                question: '$a - $b = ?',
                correctAnswer: a - b,
                options: _generateOptions(a - b),
                category: category,
                difficulty: diff,
                hint: 'Subtract $b from $a',
                tags: {
                  'operands': [a, b],
                },
              ),
            );
          }
        }
      }
    }
    // Add challenging subtraction questions
    _addChallengingSubtraction();
  }

  void _addChallengingSubtraction() {
    final category = QuestionCategory.subtraction;
    final challengingSubtractions = [
      // Large number subtractions
      {'q': '123456 - 78901 = ?', 'a': 44555},
      {'q': '234567 - 89012 = ?', 'a': 145555},
      {'q': '345678 - 90123 = ?', 'a': 255555},
      {'q': '456789 - 12345 = ?', 'a': 444444},
      {'q': '567890 - 23456 = ?', 'a': 544434},
      {'q': '678901 - 34567 = ?', 'a': 644334},
      {'q': '789012 - 45678 = ?', 'a': 743334},
      {'q': '890123 - 56789 = ?', 'a': 833334},
      {'q': '901234 - 67890 = ?', 'a': 833344},
      {'q': '112233 - 44556 = ?', 'a': 67677},
      {'q': '223344 - 55667 = ?', 'a': 167677},
      {'q': '334455 - 66778 = ?', 'a': 267677},
      {'q': '445566 - 77889 = ?', 'a': 367677},
      {'q': '556677 - 88990 = ?', 'a': 467687},
      {'q': '667788 - 99001 = ?', 'a': 568787},
      {'q': '778899 - 10112 = ?', 'a': 768787},
      {'q': '889900 - 11223 = ?', 'a': 878677},
      {'q': '990011 - 22334 = ?', 'a': 967677},
      {'q': '101112 - 33445 = ?', 'a': 67667},
      {'q': '234567 - 89012 = ?', 'a': 145555},
      // Even more challenging with borrowing across multiple digits
      {'q': '1000000 - 123456 = ?', 'a': 876544},
      {'q': '2000000 - 234567 = ?', 'a': 1765433},
      {'q': '3000000 - 345678 = ?', 'a': 2654322},
      {'q': '4000000 - 456789 = ?', 'a': 3543211},
      {'q': '5000000 - 567890 = ?', 'a': 4432110},
      {'q': '6000000 - 678901 = ?', 'a': 5321099},
      {'q': '7000000 - 789012 = ?', 'a': 6210988},
      {'q': '8000000 - 890123 = ?', 'a': 7109877},
      {'q': '9000000 - 901234 = ?', 'a': 8098766},
      {'q': '10000000 - 1122334 = ?', 'a': 8877666},
      {'q': '12345678 - 8765432 = ?', 'a': 3580246},
      {'q': '23456789 - 9876543 = ?', 'a': 13580246},
      {'q': '34567890 - 1098765 = ?', 'a': 33469125},
      {'q': '45678901 - 2109876 = ?', 'a': 43569025},
      {'q': '56789012 - 3210987 = ?', 'a': 53578025},
      {'q': '67890123 - 4321098 = ?', 'a': 63569025},
      {'q': '78901234 - 5432109 = ?', 'a': 73469125},
      {'q': '89012345 - 6543210 = ?', 'a': 82469135},
      {'q': '90123456 - 7654321 = ?', 'a': 82469135},
      {'q': '11223344 - 5566778 = ?', 'a': 5656566},
    ];

    for (var item in challengingSubtractions) {
      _questions[category]!.add(
        Question(
          id: _currentId++,
          question: item['q'] as String,
          correctAnswer: item['a'] as int,
          options: _generateOptions(item['a'] as int, range: 15),
          category: category,
          difficulty: QuestionDifficulty.expert,
          hint: 'Subtract carefully, borrow when needed',
        ),
      );
    }
  }

  void _loadMultiplicationQuestions() {
    final category = QuestionCategory.multiplication;
    for (var diff in QuestionDifficulty.values) {
      final (min, max) = _getMultRangeForDifficulty(diff);
      for (int a = min; a <= max; a++) {
        for (int b = min; b <= max; b++) {
          if (a * b <= 10000) { // Increased max to 10000 for harder questions
            _questions[category]!.add(
              Question(
                id: _currentId++,
                question: '$a × $b = ?',
                correctAnswer: a * b,
                options: _generateOptions(a * b),
                category: category,
                difficulty: diff,
                hint: 'Multiply $a by $b',
                tags: {
                  'operands': [a, b],
                },
              ),
            );
          }
        }
      }
    }
    // Add challenging multiplication
    _addChallengingMultiplication();
  }

  void _addChallengingMultiplication() {
    final category = QuestionCategory.multiplication;
    final challengingMultiplications = [
      {'q': '17 × 13 = ?', 'a': 221},
      {'q': '19 × 11 = ?', 'a': 209},
      {'q': '23 × 17 = ?', 'a': 391},
      {'q': '29 × 13 = ?', 'a': 377},
      {'q': '31 × 19 = ?', 'a': 589},
      {'q': '37 × 23 = ?', 'a': 851},
      {'q': '41 × 29 = ?', 'a': 1189},
      {'q': '43 × 31 = ?', 'a': 1333},
      {'q': '47 × 37 = ?', 'a': 1739},
      {'q': '53 × 41 = ?', 'a': 2173},
      {'q': '59 × 47 = ?', 'a': 2773},
      {'q': '61 × 53 = ?', 'a': 3233},
      {'q': '67 × 59 = ?', 'a': 3953},
      {'q': '71 × 61 = ?', 'a': 4331},
      {'q': '73 × 67 = ?', 'a': 4891},
      {'q': '79 × 71 = ?', 'a': 5609},
      {'q': '83 × 73 = ?', 'a': 6059},
      {'q': '89 × 79 = ?', 'a': 7031},
      {'q': '97 × 83 = ?', 'a': 8051},
      // Even more challenging multiplication with larger numbers
      {'q': '123 × 456 = ?', 'a': 56088},
      {'q': '234 × 567 = ?', 'a': 132678},
      {'q': '345 × 678 = ?', 'a': 233910},
      {'q': '456 × 789 = ?', 'a': 359784},
      {'q': '567 × 890 = ?', 'a': 504630},
      {'q': '678 × 901 = ?', 'a': 610878},
      {'q': '789 × 012 = ?', 'a': 9468}, // Note: 012 = 12
      {'q': '890 × 123 = ?', 'a': 109470},
      {'q': '901 × 234 = ?', 'a': 210834},
      {'q': '112 × 345 = ?', 'a': 38640},
      {'q': '223 × 456 = ?', 'a': 101688},
      {'q': '334 × 567 = ?', 'a': 189378},
      {'q': '445 × 678 = ?', 'a': 301710},
      {'q': '556 × 789 = ?', 'a': 438684},
      {'q': '667 × 890 = ?', 'a': 593630},
      {'q': '778 × 901 = ?', 'a': 700978},
      {'q': '889 × 112 = ?', 'a': 99568},
      {'q': '990 × 223 = ?', 'a': 220770},
      {'q': '111 × 334 = ?', 'a': 37074},
      {'q': '222 × 445 = ?', 'a': 98790},
      {'q': '333 × 556 = ?', 'a': 185148},
      {'q': '444 × 667 = ?', 'a': 296148},
      {'q': '555 × 778 = ?', 'a': 431790},
      {'q': '666 × 889 = ?', 'a': 592074},
      {'q': '777 × 990 = ?', 'a': 769230},
      {'q': '888 × 111 = ?', 'a': 98568},
      {'q': '999 × 222 = ?', 'a': 221778},
      {'q': '1234 × 5 = ?', 'a': 6170},
      {'q': '2345 × 6 = ?', 'a': 14070},
      {'q': '3456 × 7 = ?', 'a': 24192},
      {'q': '4567 × 8 = ?', 'a': 36536},
      {'q': '5678 × 9 = ?', 'a': 51102},
      {'q': '6789 × 10 = ?', 'a': 67890},
      {'q': '7890 × 11 = ?', 'a': 86790},
      {'q': '8901 × 12 = ?', 'a': 106812},
      {'q': '9012 × 13 = ?', 'a': 117156},
      {'q': '1122 × 14 = ?', 'a': 15708},
      {'q': '2233 × 15 = ?', 'a': 33495},
      {'q': '3344 × 16 = ?', 'a': 53504},
      {'q': '4455 × 17 = ?', 'a': 75735},
      {'q': '5566 × 18 = ?', 'a': 100188},
      {'q': '6677 × 19 = ?', 'a': 126863},
      {'q': '7788 × 20 = ?', 'a': 155760},
      {'q': '8899 × 21 = ?', 'a': 186879},
      {'q': '9900 × 22 = ?', 'a': 217800},
    ];

    for (var item in challengingMultiplications) {
      _questions[category]!.add(
        Question(
          id: _currentId++,
          question: item['q'] as String,
          correctAnswer: item['a'] as int,
          options: _generateOptions(item['a'] as int, range: 15),
          category: category,
          difficulty: QuestionDifficulty.master,
          hint: 'Use multiplication strategies or break down the numbers',
        ),
      );
    }
  }

  void _loadDivisionQuestions() {
    final category = QuestionCategory.division;
    for (var diff in QuestionDifficulty.values) {
      final (min, max) = _getMultRangeForDifficulty(diff);
      for (int b = min; b <= max; b++) {
        for (int q = min; q <= max; q++) {
          final dividend = b * q;
          if (dividend <= 5000 && dividend > 0) {
            _questions[category]!.add(
              Question(
                id: _currentId++,
                question: '$dividend ÷ $b = ?',
                correctAnswer: q,
                options: _generateOptions(q),
                category: category,
                difficulty: diff,
                hint: 'Divide $dividend by $b',
                tags: {'dividend': dividend, 'divisor': b},
              ),
            );
          }
        }
      }
    }
    // Add challenging division questions
    _addChallengingDivision();
  }

  void _addChallengingDivision() {
    final category = QuestionCategory.division;
    final challengingDivisions = [
      // Large number divisions
      {'q': '123456 ÷ 12 = ?', 'a': 10288},
      {'q': '234567 ÷ 13 = ?', 'a': 18043},
      {'q': '345678 ÷ 14 = ?', 'a': 24691},
      {'q': '456789 ÷ 15 = ?', 'a': 30452},
      {'q': '567890 ÷ 16 = ?', 'a': 35493},
      {'q': '678901 ÷ 17 = ?', 'a': 39935},
      {'q': '789012 ÷ 18 = ?', 'a': 43834},
      {'q': '890123 ÷ 19 = ?', 'a': 46848},
      {'q': '901234 ÷ 20 = ?', 'a': 45061},
      {'q': '112233 ÷ 21 = ?', 'a': 5344},
      {'q': '223344 ÷ 22 = ?', 'a': 10151},
      {'q': '334455 ÷ 23 = ?', 'a': 14541},
      {'q': '445566 ÷ 24 = ?', 'a': 18565},
      {'q': '556677 ÷ 25 = ?', 'a': 22267},
      {'q': '667788 ÷ 26 = ?', 'a': 25684},
      {'q': '778899 ÷ 27 = ?', 'a': 28848},
      {'q': '889900 ÷ 28 = ?', 'a': 31782},
      {'q': '990011 ÷ 29 = ?', 'a': 34138},
      {'q': '101112 ÷ 30 = ?', 'a': 3370},
      {'q': '234567 ÷ 31 = ?', 'a': 7563},
      // Even more challenging divisions
      {'q': '1000000 ÷ 100 = ?', 'a': 10000},
      {'q': '2000000 ÷ 200 = ?', 'a': 10000},
      {'q': '3000000 ÷ 300 = ?', 'a': 10000},
      {'q': '4000000 ÷ 400 = ?', 'a': 10000},
      {'q': '5000000 ÷ 500 = ?', 'a': 10000},
      {'q': '12345678 ÷ 123 = ?', 'a': 100372},
      {'q': '23456789 ÷ 234 = ?', 'a': 100245},
      {'q': '34567890 ÷ 345 = ?', 'a': 100197},
      {'q': '45678901 ÷ 456 = ?', 'a': 100172},
      {'q': '56789012 ÷ 567 = ?', 'a': 100155},
      {'q': '67890123 ÷ 678 = ?', 'a': 100133},
      {'q': '78901234 ÷ 789 = ?', 'a': 100013},
      {'q': '89012345 ÷ 890 = ?', 'a': 100014},
      {'q': '90123456 ÷ 901 = ?', 'a': 100026},
      {'q': '11223344 ÷ 1122 = ?', 'a': 10002},
      {'q': '22334455 ÷ 2233 = ?', 'a': 10001},
      {'q': '33445566 ÷ 3344 = ?', 'a': 10001},
      {'q': '44556677 ÷ 4455 = ?', 'a': 10001},
      {'q': '55667788 ÷ 5566 = ?', 'a': 10001},
      {'q': '66778899 ÷ 6677 = ?', 'a': 10001},
      {'q': '77889900 ÷ 7788 = ?', 'a': 10001},
      {'q': '88990011 ÷ 8899 = ?', 'a': 10001},
      {'q': '99001122 ÷ 9900 = ?', 'a': 10001},
      {'q': '101112233 ÷ 10111 = ?', 'a': 10001},
      {'q': '112233445 ÷ 11223 = ?', 'a': 10001},
    ];

    for (var item in challengingDivisions) {
      _questions[category]!.add(
        Question(
          id: _currentId++,
          question: item['q'] as String,
          correctAnswer: item['a'] as int,
          options: _generateOptions(item['a'] as int, range: 20),
          category: category,
          difficulty: QuestionDifficulty.expert,
          hint: 'Divide step by step, or use multiplication to check',
        ),
      );
    }
  }

  void _loadMixedQuestions() {
    final category = QuestionCategory.mixed;
    for (int i = 0; i < 100; i++) {
      final ops = ['+', '-', '×', '÷'];
      final op = ops[_random.nextInt(ops.length)];
      final diff = QuestionDifficulty
          .values[_random.nextInt(QuestionDifficulty.values.length)];
      final (min, max) = _getRangeForDifficulty(diff);
      final a = min + _random.nextInt(max - min);
      final b = min + _random.nextInt(max - min);

      int answer;
      String question;
      if (op == '+') {
        answer = a + b;
        question = '$a + $b = ?';
      } else if (op == '-') {
        final larger = a > b ? a : b;
        final smaller = a > b ? b : a;
        answer = larger - smaller;
        question = '$larger - $smaller = ?';
      } else if (op == '×') {
        final ma = _random.nextInt(12) + 1;
        final mb = _random.nextInt(12) + 1;
        answer = ma * mb;
        question = '$ma × $mb = ?';
      } else {
        final divisor = _random.nextInt(10) + 2;
        final quotient = _random.nextInt(10) + 2;
        answer = quotient;
        question = '${divisor * quotient} ÷ $divisor = ?';
      }

      _questions[category]!.add(
        Question(
          id: _currentId++,
          question: question,
          correctAnswer: answer,
          options: _generateOptions(answer),
          category: category,
          difficulty: diff,
          hint: 'Solve the $op operation',
        ),
      );
    }
  }

  void _loadVisualCountingQuestions() {
    final category = QuestionCategory.visualCounting;
    for (int count = 1; count <= 20; count++) {
      for (var diff in QuestionDifficulty.values) {
        _questions[category]!.add(
          Question(
            id: _currentId++,
            question: 'Count the shapes: there are $count items',
            correctAnswer: count,
            options: _generateOptions(count, range: 5),
            category: category,
            difficulty: diff,
            hint: 'Count each shape carefully',
          ),
        );
      }
    }
  }

  void _loadWordProblems() {
    final category = QuestionCategory.wordProblems;
    final wordProblems = [
      {
        'text':
            'Emma has 15 apples. She buys 10 more. How many apples does she have?',
        'answer': 25,
      },
      {
        'text':
            'Tom had 20 candies. He gave 8 to his friends. How many are left?',
        'answer': 12,
      },
      {
        'text': 'There are 7 boxes with 6 toys each. How many toys in total?',
        'answer': 42,
      },
      {
        'text':
            'A farmer has 56 eggs. He puts them in cartons of 8. How many cartons?',
        'answer': 7,
      },
      {
        'text':
            'Lisa has 100 stickers. She shares them equally among 10 friends. How many each?',
        'answer': 10,
      },
      {
        'text': 'John ran 25 laps on Monday and 30 on Tuesday. How many total?',
        'answer': 55,
      },
      {
        'text': 'A bakery made 200 cookies. They sold 150. How many left?',
        'answer': 50,
      },
      {
        'text': 'Each packet has 5 pencils. How many pencils in 40 packets?',
        'answer': 200,
      },
      {
        'text': '360 students go on buses. Each bus holds 40. How many buses?',
        'answer': 9,
      },
      {
        'text': 'Sarah saved \$500 in 5 weeks. How much per week?',
        'answer': 100,
      },
      {
        'text': 'A garden has 48 flowers. 16 are red roses. How many are other flowers?',
        'answer': 32,
      },
      {
        'text': 'Mike reads 8 pages per day. How many days to read 120 pages?',
        'answer': 15,
      },
      {
        'text': 'There are 144 students in 9 classes. How many students per class?',
        'answer': 16,
      },
      {
        'text': 'Anna bought 3 books for \$45 each. How much total?',
        'answer': 135,
      },
      {
        'text': 'A movie theater has 250 seats. 187 are occupied. How many empty?',
        'answer': 63,
      },
      {
        'text': 'Tom has 75 marbles. He gives away 28. How many left?',
        'answer': 47,
      },
      {
        'text': 'Each pizza has 8 slices. How many slices in 6 pizzas?',
        'answer': 48,
      },
      {
        'text': 'Sarah walked 3 km each day for 14 days. How far total?',
        'answer': 42,
      },
      {
        'text': 'A store sold 156 toys. 89 are dolls. How many are other toys?',
        'answer': 67,
      },
      {
        'text': 'Each group has 12 students. How many groups for 84 students?',
        'answer': 7,
      },
      {
        'text': 'Lisa saved \$12 per week. How much in 8 weeks?',
        'answer': 96,
      },
      {
        'text': 'There are 216 books on shelves. Each shelf holds 24. How many shelves?',
        'answer': 9,
      },
      {
        'text': 'Tom collected 35 stamps. He gave 19 to his sister. How many left?',
        'answer': 16,
      },
      {
        'text': 'Each box contains 15 chocolates. How many in 8 boxes?',
        'answer': 120,
      },
      {
        'text': 'A train travels 180 km in 3 hours. What is the speed?',
        'answer': 60,
      },
      {
        'text': 'Sarah has 240 stickers. She shares with 8 friends equally. How many each?',
        'answer': 30,
      },
      {
        'text': 'Mike ran 5 laps of 400m each. How far did he run?',
        'answer': 2000,
      },
      {
        'text': 'There are 320 students. Each bus holds 40. How many buses needed?',
        'answer': 8,
      },
      {
        'text': 'Anna baked 96 cookies. She puts 8 in each box. How many boxes?',
        'answer': 12,
      },
      {
        'text': 'Tom has \$150. Each game costs \$25. How many games can he buy?',
        'answer': 6,
      },
      {
        'text': 'A library has 500 books. 325 are fiction. How many non-fiction?',
        'answer': 175,
      },
      {
        'text': 'Each team has 11 players. How many players in 7 teams?',
        'answer': 77,
      },
      {
        'text': 'Lisa read 9 pages per day for 12 days. How many pages total?',
        'answer': 108,
      },
      {
        'text': 'A train travels 450 km in 6 hours. What is the average speed?',
        'answer': 75,
      },
      {
        'text': 'Sarah bought 3 books for \$45 each and 2 notebooks for \$12 each. How much total?',
        'answer': 171,
      },
      {
        'text': 'There are 360 students in a school. 240 are in grades 1-6. How many in grades 7-12?',
        'answer': 120,
      },
      {
        'text': 'Mike collected 85 stamps. He gave 28 to his sister and 17 to his brother. How many left?',
        'answer': 40,
      },
      {
        'text': 'A factory produces 150 cars per day. How many in 28 days?',
        'answer': 4200,
      },
      {
        'text': 'Anna has 200 stickers. She shares them equally among 8 friends. How many each?',
        'answer': 25,
      },
      {
        'text': 'The school cafeteria serves 450 meals per day. Each meal costs \$8. What is daily revenue?',
        'answer': 3600,
      },
      {
        'text': 'Tom ran 3 laps of 400m each and walked 2 laps of 300m each. How far did he travel?',
        'answer': 2100,
      },
      {
        'text': 'A store sold 156 toys on Monday and 189 on Tuesday. How many total?',
        'answer': 345,
      },
      {
        'text': 'Each class has 25 students. How many students in 12 classes?',
        'answer': 300,
      },
      {
        'text': 'Lisa saved \$450 in 6 months. How much per month on average?',
        'answer': 75,
      },
      {
        'text': 'There are 480 books in the library. 320 are borrowed. What percentage remains?',
        'answer': 33,
      },
      {
        'text': 'Mike bought 4 pizzas for \$48 each. How much total?',
        'answer': 192,
      },
      {
        'text': 'A plane flies 1200 km in 3 hours. How far in 7 hours at same speed?',
        'answer': 2800,
      },
      {
        'text': 'A rectangle has length 15cm and width 8cm. What is the perimeter?',
        'answer': 46,
      },
      {
        'text': 'Sarah has 360 minutes to complete her homework. Each assignment takes 45 minutes. How many can she finish?',
        'answer': 8,
      },
      {
        'text': 'The bakery sold 234 muffins on Friday and 189 on Saturday. How many total?',
        'answer': 423,
      },
      {
        'text': 'A garden is 25m long and 18m wide. What is the area?',
        'answer': 450,
      },
      {
        'text': 'Tom bought 6 notebooks for \$12 each and 3 pens for \$8 each. How much change from \$100?',
        'answer': 28,
      },
      {
        'text': 'There are 480 books in the library. 320 are borrowed. What percentage remains?',
        'answer': 33,
      },
      {
        'text': 'Mike bought 4 pizzas for \$48 each. How much total?',
        'answer': 192,
      },
      {
        'text': 'A factory produces 150 cars per day. How many in 28 days?',
        'answer': 4200,
      },
      {
        'text': 'Anna has 200 stickers. She shares them equally among 8 friends. How many each?',
        'answer': 25,
      },
      {
        'text': 'The school cafeteria serves 450 meals per day. Each meal costs \$8. What is daily revenue?',
        'answer': 3600,
      },
      {
        'text': 'Tom ran 3 laps of 400m each and walked 2 laps of 300m each. How far did he travel?',
        'answer': 2100,
      },
      {
        'text': 'A store sold 156 toys on Monday and 189 on Tuesday. How many total?',
        'answer': 345,
      },
      {
        'text': 'Each class has 25 students. How many students in 12 classes?',
        'answer': 300,
      },
      {
        'text': 'Lisa saved \$450 in 6 months. How much per month on average?',
        'answer': 75,
      },
      {
        'text': 'There are 360 students in a school. 240 are in grades 1-6. How many in grades 7-12?',
        'answer': 120,
      },
      {
        'text': 'Mike collected 85 stamps. He gave 28 to his sister and 17 to his brother. How many left?',
        'answer': 40,
      },
      {
        'text': 'Sarah bought 3 books for \$45 each and 2 notebooks for \$12 each. How much total?',
        'answer': 171,
      },
      {
        'text': 'A train travels 450 km in 6 hours. What is the average speed?',
        'answer': 75,
      },
      {
        'text': 'There are 480 books in the library. 320 are borrowed. What percentage remains?',
        'answer': 33,
      },
      {
        'text': 'Mike bought 4 pizzas for \$48 each. How much total?',
        'answer': 192,
      },
      {
        'text': 'A plane flies 1200 km in 3 hours. How far in 7 hours at same speed?',
        'answer': 2800,
      },
      {
        'text': 'A rectangle has length 15cm and width 8cm. What is the perimeter?',
        'answer': 46,
      },
      {
        'text': 'Sarah has 360 minutes to complete her homework. Each assignment takes 45 minutes. How many can she finish?',
        'answer': 8,
      },
      {
        'text': 'The bakery sold 234 muffins on Friday and 189 on Saturday. How many total?',
        'answer': 423,
      },
      {
        'text': 'A garden is 25m long and 18m wide. What is the area?',
        'answer': 450,
      },
      {
        'text': 'Tom bought 6 notebooks for \$12 each and 3 pens for \$8 each. How much change from \$100?',
        'answer': 28,
      },
      {
        'text': 'A factory produces 150 cars per day. How many in 28 days?',
        'answer': 4200,
      },
      {
        'text': 'Anna has 200 stickers. She shares them equally among 8 friends. How many each?',
        'answer': 25,
      },
      {
        'text': 'The school cafeteria serves 450 meals per day. Each meal costs \$8. What is daily revenue?',
        'answer': 3600,
      },
      {
        'text': 'Tom ran 3 laps of 400m each and walked 2 laps of 300m each. How far did he travel?',
        'answer': 2100,
      },
      {
        'text': 'A store sold 156 toys on Monday and 189 on Tuesday. How many total?',
        'answer': 345,
      },
      {
        'text': 'Each class has 25 students. How many students in 12 classes?',
        'answer': 300,
      },
      {
        'text': 'Lisa saved \$450 in 6 months. How much per month on average?',
        'answer': 75,
      },
      {
        'text': 'There are 360 students in a school. 240 are in grades 1-6. How many in grades 7-12?',
        'answer': 120,
      },
      {
        'text': 'Mike collected 85 stamps. He gave 28 to his sister and 17 to his brother. How many left?',
        'answer': 40,
      },
      {
        'text': 'Sarah bought 3 books for \$45 each and 2 notebooks for \$12 each. How much total?',
        'answer': 171,
      },
      {
        'text': 'A train travels 450 km in 6 hours. What is the average speed?',
        'answer': 75,
      },
    ];

    for (var i = 0; i < wordProblems.length; i++) {
      for (var diff in QuestionDifficulty.values) {
        _questions[category]!.add(
          Question(
            id: _currentId++,
            question: wordProblems[i]['text'] as String,
            correctAnswer: wordProblems[i]['answer'] as int,
            options: _generateOptions(wordProblems[i]['answer'] as int),
            category: category,
            difficulty: diff,
          ),
        );
      }
    }
  }

  void _loadLogicQuestions() {
    final category = QuestionCategory.logic;
    final logicProblems = [
      {
        'text':
            'If + means ×, × means -, - means ÷, ÷ means +, solve: 3 + 2 × 4',
        'answer': 11,
      },
      {'text': 'What comes next: 2, 6, 12, 20, 30, ?', 'answer': 42},
      {'text': 'Find the pattern: 1, 1, 2, 3, 5, 8, ?', 'answer': 13},
      {
        'text':
            'If all roses are flowers and some flowers fade, do all roses fade?',
        'answer': 1,
        'options': [1, 0, 2],
      },
      {'text': 'Complete: 1, 4, 9, 16, 25, ?', 'answer': 36},
      {'text': 'What comes next: 1, 3, 6, 10, 15, ?', 'answer': 21},
      {'text': 'Find the pattern: 0, 1, 1, 2, 3, 5, ?', 'answer': 8},
      {'text': 'Complete: 2, 4, 8, 16, 32, ?', 'answer': 64},
      {'text': 'What comes next: 5, 10, 20, 40, 80, ?', 'answer': 160},
      {'text': 'Find the pattern: 1, 8, 27, 64, 125, ?', 'answer': 216},
      {'text': 'Complete: 2, 3, 5, 7, 11, ?', 'answer': 13},
      {'text': 'What comes next: 1, 4, 9, 16, 25, 36, ?', 'answer': 49},
      {'text': 'Find the pattern: 0, 2, 6, 12, 20, 30, ?', 'answer': 42},
      {'text': 'Complete: 1, 2, 4, 8, 16, 31, ?', 'answer': 57},
      {'text': 'What comes next: 3, 6, 9, 12, 15, ?', 'answer': 18},
      {'text': 'Find the pattern: 1, 1, 2, 3, 5, 8, 13, ?', 'answer': 21},
      {'text': 'Complete: 1, 3, 6, 10, 15, 21, ?', 'answer': 28},
      {'text': 'What comes next: 0, 1, 3, 6, 10, 15, ?', 'answer': 21},
      {'text': 'Find the pattern: 2, 5, 10, 17, 26, ?', 'answer': 37},
      {'text': 'Complete: 1, 2, 6, 24, 120, ?', 'answer': 720},
      {'text': 'What comes next: 1, 11, 21, 1211, 111221, ?', 'answer': 312211},
      {'text': 'Find the pattern: 1, 2, 4, 7, 11, 16, ?', 'answer': 22},
      {'text': 'Complete: 2, 3, 5, 8, 13, 21, ?', 'answer': 34},
      {'text': 'What comes next: 1, 8, 27, 64, 125, 216, ?', 'answer': 343},
      {'text': 'Find the pattern: 0, 1, 4, 9, 16, 25, 36, ?', 'answer': 49},
      {'text': 'Complete: 1, 4, 27, 256, 3125, ?', 'answer': 46656},
      {'text': 'What comes next: 2, 9, 28, 65, 126, ?', 'answer': 217},
      {'text': 'Find the pattern: 1, 3, 9, 27, 81, ?', 'answer': 243},
      {'text': 'Complete: 3, 9, 27, 81, 243, ?', 'answer': 729},
      {'text': 'What comes next: 1, 2, 6, 15, 31, ?', 'answer': 56},
      {'text': 'Find the pattern: 0, 1, 8, 35, 104, ?', 'answer': 229},
      {'text': 'Complete: 1, 3, 7, 15, 31, 63, ?', 'answer': 127},
      {'text': 'What comes next: 2, 12, 36, 80, 150, ?', 'answer': 252},
      {'text': 'Find the pattern: 1, 5, 17, 53, 161, ?', 'answer': 485},
      {'text': 'Complete: 4, 9, 25, 81, 289, ?', 'answer': 1089},
      {'text': 'What comes next: 1, 4, 13, 40, 121, ?', 'answer': 364},
      {'text': 'Find the pattern: 2, 6, 18, 54, 162, ?', 'answer': 486},
      {'text': 'Complete: 1, 8, 22, 43, 71, ?', 'answer': 106},
      {'text': 'What comes next: 3, 7, 15, 31, 63, 127, ?', 'answer': 255},
    ];

    for (var i = 0; i < logicProblems.length; i++) {
      for (var diff in QuestionDifficulty.values) {
        final answer = logicProblems[i]['answer'] as int;
        _questions[category]!.add(
          Question(
            id: _currentId++,
            question: logicProblems[i]['text'] as String,
            correctAnswer: answer,
            options: _generateOptions(answer),
            category: category,
            difficulty: diff,
          ),
        );
      }
    }
  }

  void _loadFractionsQuestions() {
    final category = QuestionCategory.fractions;
    final fractionProblems = [
      {'text': '1/2 + 1/4 = ?', 'answer': 75},
      {'text': '3/4 - 1/2 = ?', 'answer': 25},
      {'text': '1/3 × 3/4 = ?', 'answer': 25},
       {'text': '2/3 ÷ 1/3 = ?', 'answer': 2},
       {'text': '1/2 of 80 = ?', 'answer': 40},
       {'text': '2/5 + 1/5 = ?', 'answer': 60},
       {'text': '3/5 - 1/5 = ?', 'answer': 40},
       {'text': '1/4 × 2/3 = ?', 'answer': 17}, // 1/4 * 2/3 = 1/6 ≈ 0.1667, but using 17 for 17%
       {'text': '6/4 ÷ 3/4 = ?', 'answer': 2}, // 6/4 ÷ 3/4 = 2
       {'text': '1/3 of 90 = ?', 'answer': 30},
       {'text': '2/3 + 1/6 = ?', 'answer': 75},
       {'text': '5/6 - 1/3 = ?', 'answer': 50},
       {'text': '1/2 × 3/4 = ?', 'answer': 38}, // 3/8 = 0.375, using 38 for approximation
       {'text': '12/5 ÷ 6/5 = ?', 'answer': 2}, // 12/5 ÷ 6/5 = 2
       {'text': '1/4 of 120 = ?', 'answer': 30},
       {'text': '3/5 + 1/10 = ?', 'answer': 70},
       {'text': '7/8 - 1/4 = ?', 'answer': 63},
       {'text': '2/3 × 3/5 = ?', 'answer': 40},
       {'text': '10/3 ÷ 5/3 = ?', 'answer': 2}, // 10/3 ÷ 5/3 = 2
      {'text': '1/5 of 200 = ?', 'answer': 40},
    ];

    for (var i = 0; i < fractionProblems.length; i++) {
      for (var diff in QuestionDifficulty.values) {
        final answer = fractionProblems[i]['answer'] as int;
        _questions[category]!.add(
          Question(
            id: _currentId++,
            question: fractionProblems[i]['text'] as String,
            correctAnswer: answer,
            options: _generateOptions(answer),
            category: category,
            difficulty: diff,
          ),
        );
      }
    }
  }

  void _loadDecimalsQuestions() {
    final category = QuestionCategory.decimals;
    final decimalProblems = [
      {'text': '12.5 + 7.3 = ?', 'answer': 198},
      {'text': '15.8 - 9.4 = ?', 'answer': 64},
      {'text': '3.5 × 4 = ?', 'answer': 14},
       {'text': '24 ÷ 4 = ?', 'answer': 6}, // No remainder division
       {'text': '0.5 × 0.8 = ?', 'answer': 4},
       {'text': '6.7 + 8.9 = ?', 'answer': 156},
       {'text': '23.4 - 12.8 = ?', 'answer': 106},
       {'text': '2.5 × 6 = ?', 'answer': 15},
       {'text': '30 ÷ 3 = ?', 'answer': 10}, // No remainder division
       {'text': '0.3 × 0.7 = ?', 'answer': 21},
       {'text': '18.9 + 5.1 = ?', 'answer': 240},
       {'text': '31.7 - 16.3 = ?', 'answer': 154},
       {'text': '4.2 × 5 = ?', 'answer': 21},
       {'text': '64 ÷ 8 = ?', 'answer': 8}, // No remainder division
       {'text': '0.9 × 0.6 = ?', 'answer': 54},
       {'text': '7.8 + 14.2 = ?', 'answer': 220},
       {'text': '25.9 - 13.5 = ?', 'answer': 124},
       {'text': '1.5 × 12 = ?', 'answer': 18},
       {'text': '84 ÷ 7 = ?', 'answer': 12}, // No remainder division
       {'text': '0.4 × 0.25 = ?', 'answer': 1},
    ];

    for (var i = 0; i < decimalProblems.length; i++) {
      for (var diff in QuestionDifficulty.values) {
        final mult = i < 2 ? 100 : (i < 4 ? 10 : 100);
        final answer = decimalProblems[i]['answer'] as int;
        _questions[category]!.add(
          Question(
            id: _currentId++,
            question: decimalProblems[i]['text'] as String,
            correctAnswer: answer,
            options: _generateOptions(answer),
            category: category,
            difficulty: diff,
            tags: {'scaled': mult},
          ),
        );
      }
    }
  }

  (int, int) _getRangeForDifficulty(QuestionDifficulty diff) {
    switch (diff) {
      case QuestionDifficulty.beginner:
        return (1, 10);
      case QuestionDifficulty.easy:
        return (1, 25);
      case QuestionDifficulty.medium:
        return (10, 50);
      case QuestionDifficulty.hard:
        return (25, 100);
      case QuestionDifficulty.expert:
        return (50, 200);
      case QuestionDifficulty.master:
        return (100, 500);
    }
  }

  (int, int) _getMultRangeForDifficulty(QuestionDifficulty diff) {
    switch (diff) {
      case QuestionDifficulty.beginner:
        return (1, 5);
      case QuestionDifficulty.easy:
        return (1, 10);
      case QuestionDifficulty.medium:
        return (1, 12);
      case QuestionDifficulty.hard:
        return (1, 15);
      case QuestionDifficulty.expert:
        return (1, 20);
      case QuestionDifficulty.master:
        return (1, 25);
    }
  }

  int _getStep(QuestionDifficulty diff) {
    switch (diff) {
      case QuestionDifficulty.beginner:
        return 1;
      case QuestionDifficulty.easy:
        return 2;
      case QuestionDifficulty.medium:
        return 5;
      case QuestionDifficulty.hard:
        return 10;
      case QuestionDifficulty.expert:
        return 15;
      case QuestionDifficulty.master:
        return 25;
    }
  }

  List<int> _generateOptions(int correct, {int range = 4}) {
    final options = <int>{correct};
    final diff = (range / 2).round();

    while (options.length < 4) {
      final offset = _random.nextInt(range) - diff;
      final wrong = correct + offset;
      if (wrong != correct && wrong >= 0) {
        options.add(wrong);
      }
    }

    while (options.length < 4) {
      options.add(correct + options.length);
    }

    final list = options.toList();
    list.shuffle(_random);
    return list;
  }

  List<Question> getQuestions({
    QuestionCategory? category,
    QuestionDifficulty? difficulty,
    int? limit,
  }) {
    var questions = _questions[category] ?? [];

    if (difficulty != null) {
      questions = questions.where((q) => q.difficulty == difficulty).toList();
    }

    if (limit != null && questions.length > limit) {
      questions = questions.take(limit).toList();
    }

    return questions;
  }

  List<Question> getRandomQuestions({
    QuestionCategory? category,
    QuestionDifficulty? difficulty,
    int count = 10,
  }) {
    var pool = getQuestions(category: category, difficulty: difficulty);
    pool.shuffle(_random);
    return pool.take(count).toList();
  }
}

final questionBankProvider = Provider<QuestionBank>((ref) {
  return QuestionBank.preloaded();
});

class QuestionBankStats {
  final int totalQuestions;
  final Map<QuestionCategory, int> byCategory;
  final Map<QuestionDifficulty, int> byDifficulty;

  QuestionBankStats({
    required this.totalQuestions,
    required this.byCategory,
    required this.byDifficulty,
  });
}

final questionBankStatsProvider = Provider<QuestionBankStats>((ref) {
  final bank = ref.watch(questionBankProvider);

  final byCategory = <QuestionCategory, int>{};
  final byDifficulty = <QuestionDifficulty, int>{};

  for (var category in QuestionCategory.values) {
    byCategory[category] = bank.getQuestions(category: category).length;
  }

  for (var difficulty in QuestionDifficulty.values) {
    byDifficulty[difficulty] = bank.getQuestions(difficulty: difficulty).length;
  }

  return QuestionBankStats(
    totalQuestions: byCategory.values.fold(0, (a, b) => a + b),
    byCategory: byCategory,
    byDifficulty: byDifficulty,
  );
});

class GameLevels {
  static const int totalLevels = 50;
  static const int questionsPerLevel = 45;
  static const int levelsPerChapter = 10;
  static const int totalChapters = 5;

  static List<GameLevel> generateLevels() {
    return List.generate(totalLevels, (i) {
      final levelNum = i + 1;
      final chapter = ((levelNum - 1) ~/ levelsPerChapter) + 1;
      final difficulty = _calculateDifficulty(levelNum);

      return GameLevel(
        levelNumber: levelNum,
        chapter: chapter,
        difficulty: difficulty,
        questionCount: questionsPerLevel,
        timeLimit: _getTimeLimit(difficulty),
        starsRequired: _getStarsRequired(levelNum),
        isBossLevel: levelNum % 10 == 0,
        unlocksChapter: levelNum % levelsPerChapter == 0 ? chapter + 1 : null,
      );
    });
  }

  static QuestionDifficulty _calculateDifficulty(int level) {
    if (level <= 10) return QuestionDifficulty.beginner;
    if (level <= 20) return QuestionDifficulty.easy;
    if (level <= 30) return QuestionDifficulty.medium;
    if (level <= 40) return QuestionDifficulty.hard;
    if (level <= 45) return QuestionDifficulty.expert;
    return QuestionDifficulty.master;
  }

  static int _getTimeLimit(QuestionDifficulty difficulty) {
    switch (difficulty) {
      case QuestionDifficulty.beginner:
        return 120;
      case QuestionDifficulty.easy:
        return 90;
      case QuestionDifficulty.medium:
        return 75;
      case QuestionDifficulty.hard:
        return 60;
      case QuestionDifficulty.expert:
        return 45;
      case QuestionDifficulty.master:
        return 30;
    }
  }

  static int _getStarsRequired(int level) {
    if (level <= 10) return 0;
    return (level - 10) * 3;
  }
}

class GameLevel {
  final int levelNumber;
  final int chapter;
  final QuestionDifficulty difficulty;
  final int questionCount;
  final int timeLimit;
  final int starsRequired;
  final bool isBossLevel;
  final int? unlocksChapter;

  const GameLevel({
    required this.levelNumber,
    required this.chapter,
    required this.difficulty,
    required this.questionCount,
    required this.timeLimit,
    required this.starsRequired,
    required this.isBossLevel,
    this.unlocksChapter,
  });
}

final gameLevelsProvider = Provider<List<GameLevel>>((ref) {
  return GameLevels.generateLevels();
});
