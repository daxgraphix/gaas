import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum QuestionCategory {
  addition,
  subtraction,
  multiplication,
  division,
  mixed,
  visualCounting,
  logic,
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
    bank._loadLogicQuestions();
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
      {'q': '39935 ÷ 17 = ?', 'a': 2349},
      {'q': '43834 ÷ 18 = ?', 'a': 2435},
      {'q': '46848 ÷ 19 = ?', 'a': 2465},
      {'q': '45061 ÷ 20 = ?', 'a': 2253},
      {'q': '112233 ÷ 21 = ?', 'a': 5344},
      {'q': '223344 ÷ 22 = ?', 'a': 10152},
      {'q': '334455 ÷ 23 = ?', 'a': 14541},
      {'q': '445566 ÷ 24 = ?', 'a': 18565},
      {'q': '556677 ÷ 25 = ?', 'a': 22267},
      {'q': '667788 ÷ 26 = ?', 'a': 25684},
      {'q': '778899 ÷ 27 = ?', 'a': 28848},
      {'q': '889900 ÷ 28 = ?', 'a': 31782},
      {'q': '990011 ÷ 29 = ?', 'a': 34138},
      {'q': '101112 ÷ 30 = ?', 'a': 3370},
      {'q': '234567 ÷ 31 = ?', 'a': 7566},
      // Even more challenging divisions
      {'q': '1000000 ÷ 100 = ?', 'a': 10000},
      {'q': '2000000 ÷ 200 = ?', 'a': 10000},
      {'q': '3000000 ÷ 300 = ?', 'a': 10000},
      {'q': '4000000 ÷ 400 = ?', 'a': 10000},
      {'q': '5000000 ÷ 500 = ?', 'a': 10000},
      {'q': '12345678 ÷ 123 = ?', 'a': 100371},
      {'q': '23456789 ÷ 234 = ?', 'a': 100242},
      {'q': '34567890 ÷ 345 = ?', 'a': 100196},
      {'q': '45678901 ÷ 456 = ?', 'a': 100173},
      {'q': '56789012 ÷ 567 = ?', 'a': 100156},
      {'q': '67890123 ÷ 678 = ?', 'a': 100132},
      {'q': '78901234 ÷ 789 = ?', 'a': 100001},
      {'q': '89012345 ÷ 890 = ?', 'a': 100013},
      {'q': '90123456 ÷ 901 = ?', 'a': 100026},
      {'q': '11223344 ÷ 1122 = ?', 'a': 10003},
      {'q': '22334455 ÷ 2233 = ?', 'a': 10002},
      {'q': '33445566 ÷ 3344 = ?', 'a': 10001},
      {'q': '44556677 ÷ 4455 = ?', 'a': 10001},
      {'q': '55667788 ÷ 5566 = ?', 'a': 10001},
      {'q': '66778899 ÷ 6677 = ?', 'a': 10001},
      {'q': '77889900 ÷ 7788 = ?', 'a': 10001},
      {'q': '88990011 ÷ 8899 = ?', 'a': 10001},
      {'q': '99001122 ÷ 9900 = ?', 'a': 10001},
      {'q': '101112233 ÷ 10111 = ?', 'a': 10000},
      {'q': '112233445 ÷ 11223 = ?', 'a': 10000},
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
  static const int totalLevels = 100;
  static const int questionsPerLevel = 50;
  static const int levelsPerChapter = 10;
  static const int totalChapters = 10;

  static List<GameLevel> generateLevels() {
    return List.generate(totalLevels, (i) {
      final levelNum = i + 1;
      final chapter = ((levelNum - 1) ~/ levelsPerChapter) + 1;
      final difficulty = _calculateDifficulty(levelNum);

      return GameLevel(
        levelNumber: levelNum,
        chapter: chapter,
        difficulty: difficulty,
        questionCount: levelNum > 50 ? 60 : 50,
        timeLimit: _getTimeLimit(difficulty),
        starsRequired: _getStarsRequired(levelNum),
        isBossLevel: levelNum % 10 == 0,
        unlocksChapter: levelNum % levelsPerChapter == 0 ? chapter + 1 : null,
      );
    });
  }

  static QuestionDifficulty _calculateDifficulty(int level) {
    if (level <= 15) return QuestionDifficulty.beginner;
    if (level <= 35) return QuestionDifficulty.easy;
    if (level <= 55) return QuestionDifficulty.medium;
    if (level <= 75) return QuestionDifficulty.hard;
    if (level <= 90) return QuestionDifficulty.expert;
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
    if (level <= 1) return 0;
    // For level > 1, require about 2 stars per level from previous levels
    // but capped at a reasonable progression.
    // Level 100 would require (99 * 2) = 198 stars out of 297 available.
    // For Level 11, it would require 20 stars. 
    // This is more balanced than the previous (level-10)*3 logic.
    return (level - 1) * 2;
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
