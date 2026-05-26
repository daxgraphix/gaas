import 'dart:math';
import '../../../data/models/math_riddle.dart';

class AdvancedTopicsEngine {
  static final Random _random = Random();

  static MathRiddle generateFractionsProblem(int difficulty) {
    final problemTypes = ['addition', 'subtraction', 'multiplication', 'comparison', 'simplification'];
    final type = problemTypes[_random.nextInt(problemTypes.length)];

    String question, correctAnswer;
    List<String> options, hints;

    switch (type) {
      case 'addition':
        final num1 = _random.nextInt(5) + 1;
        final den1 = _random.nextInt(8) + 2;
        final num2 = _random.nextInt(5) + 1;
        final den2 = den1; // Same denominator for simplicity

        final resultNum = num1 + num2;
        question = 'What is $num1/$den1 + $num2/$den2?';
        correctAnswer = '$resultNum/$den1';
        options = _generateFractionOptions(resultNum, den1);
        hints = [
          'Add the numerators together',
          '$num1 + $num2 = $resultNum',
          'Keep the same denominator: $den1'
        ];
        break;

      case 'comparison':
        final num1 = _random.nextInt(8) + 1;
        final den1 = _random.nextInt(8) + 2;
        final num2 = _random.nextInt(8) + 1;
        final den2 = _random.nextInt(8) + 2;

        final frac1 = num1 / den1;
        final frac2 = num2 / den2;

        question = 'Which is larger: $num1/$den1 or $num2/$den2?';
        correctAnswer = frac1 > frac2 ? '$num1/$den1' : frac2 > frac1 ? '$num2/$den2' : 'equal';
        options = ['$num1/$den1', '$num2/$den2', 'Equal'];
        hints = [
          'Convert to decimals: $num1/$den1 = ${frac1.toStringAsFixed(2)}, $num2/$den2 = ${frac2.toStringAsFixed(2)}',
          'Compare the decimal values',
          'The larger decimal is the larger fraction'
        ];
        break;

      default:
        question = 'Simplify 4/8';
        correctAnswer = '1/2';
        options = ['1/2', '2/4', '4/8', '8/16'];
        hints = ['Divide numerator and denominator by 4', '4÷4=1, 8÷4=2', '1/2'];
    }

    return MathRiddle(
      id: 'fraction_${DateTime.now().millisecondsSinceEpoch}',
      question: question,
      options: options,
      correctAnswer: correctAnswer,
      explanation: 'Fractions represent parts of a whole.',
      progressiveHints: hints,
      difficulty: difficulty,
      basePoints: 100,
      type: MathRiddleType.arithmetic,
    );
  }

  static MathRiddle generateDecimalsProblem(int difficulty) {
    final problemTypes = ['addition', 'rounding', 'conversion', 'comparison'];
    final type = problemTypes[_random.nextInt(problemTypes.length)];

    String question, correctAnswer;
    List<String> options, hints;

    switch (type) {
      case 'addition':
        final num1 = (_random.nextInt(50) + 10) + (_random.nextInt(99) + 1) / 100.0;
        final num2 = (_random.nextInt(30) + 5) + (_random.nextInt(99) + 1) / 100.0;
        final result = num1 + num2;

        question = 'What is ${num1.toStringAsFixed(2)} + ${num2.toStringAsFixed(2)}?';
        correctAnswer = result.toStringAsFixed(2);
        options = _generateDecimalOptions(result);
        hints = [
          'Align the decimal points',
          'Add like you would with whole numbers',
          'Keep the decimal point in the same place'
        ];
        break;

      case 'rounding':
        final number = (_random.nextInt(100) + 10) + (_random.nextInt(999) + 1) / 1000.0;
        final places = _random.nextInt(2) + 1; // 1 or 2 decimal places

        question = 'Round ${number.toStringAsFixed(3)} to $places decimal place${places > 1 ? 's' : ''}.';
        correctAnswer = _roundToDecimalPlaces(number, places).toString();
        options = _generateRoundingOptions(number, places);
        hints = [
          'Look at the digit after the place you\'re rounding to',
          'If 5 or above, round up; if below 5, round down',
          'Keep the specified number of decimal places'
        ];
        break;

      default:
        final number = (_random.nextInt(20) + 5) + (_random.nextInt(99) + 1) / 100.0;
        question = 'What is ${number.toStringAsFixed(2)} as a fraction?';
        correctAnswer = _decimalToFraction(number);
        options = _generateFractionOptionsFromDecimal(number);
        hints = [
          'Convert the decimal to a fraction over 100',
          'Then simplify the fraction',
          'Remove common factors from numerator and denominator'
        ];
    }

    return MathRiddle(
      id: 'decimal_${DateTime.now().millisecondsSinceEpoch}',
      question: question,
      options: options,
      correctAnswer: correctAnswer,
      explanation: 'Decimals represent parts of a whole number.',
      progressiveHints: hints,
      difficulty: difficulty,
      basePoints: 110,
      type: MathRiddleType.arithmetic,
    );
  }

  static MathRiddle generateGeometryProblem(int difficulty) {
    final problemTypes = ['area', 'perimeter', 'volume', 'angles'];
    final type = problemTypes[_random.nextInt(problemTypes.length)];

    String question, correctAnswer;
    List<String> options, hints;

    switch (type) {
      case 'area':
        final length = _random.nextInt(10) + 5;
        final width = _random.nextInt(10) + 3;
        final area = length * width;

        question = 'What is the area of a rectangle with length ${length}cm and width ${width}cm?';
        correctAnswer = '$area cm²';
        options = _generateAreaOptions(area);
        hints = [
          'Area of rectangle = length × width',
          '$length × $width',
          '$length × $width = $area'
        ];
        break;

      case 'perimeter':
        final side = _random.nextInt(15) + 5;
        final perimeter = side * 4;

        question = 'What is the perimeter of a square with side length ${side}cm?';
        correctAnswer = '$perimeter cm';
        options = _generatePerimeterOptions(perimeter);
        hints = [
          'Perimeter of square = 4 × side length',
          '4 × $side',
          '4 × $side = $perimeter'
        ];
        break;

      case 'volume':
        final length = _random.nextInt(8) + 3;
        final width = _random.nextInt(8) + 2;
        final height = _random.nextInt(6) + 2;
        final volume = length * width * height;

        question = 'What is the volume of a rectangular prism with dimensions ${length}cm × ${width}cm × ${height}cm?';
        correctAnswer = '$volume cm³';
        options = _generateVolumeOptions(volume);
        hints = [
          'Volume = length × width × height',
          '$length × $width × $height',
          '$length × $width = ${length * width}, then × $height = $volume'
        ];
        break;

      default:
        final angle = _random.nextInt(180) + 1;
        question = 'What type of angle is $angle degrees?';
        correctAnswer = _classifyAngle(angle);
        options = ['Acute', 'Right', 'Obtuse', 'Straight'];
        hints = [
          'Acute angles are less than 90°',
          'Right angles are exactly 90°',
          'Obtuse angles are greater than 90°',
          'Straight angles are exactly 180°'
        ];
    }

    return MathRiddle(
      id: 'geometry_${DateTime.now().millisecondsSinceEpoch}',
      question: question,
      options: options,
      correctAnswer: correctAnswer,
      explanation: 'Geometry deals with shapes, sizes, and properties of space.',
      progressiveHints: hints,
      difficulty: difficulty,
      basePoints: 120,
      type: MathRiddleType.logicChallenge,
    );
  }

  static MathRiddle generateWordProblem(int difficulty) {
    final templates = [
      {
        'template': 'John has {num1} apples. He gives {num2} to his friend. How many does he have left?',
        'operation': 'subtraction',
        'answer': '{num1} - {num2} = {result}'
      },
      {
        'template': 'Sarah bought {num1} pencils. Each pencil costs {num2} dollars. How much did she spend?',
        'operation': 'multiplication',
        'answer': '{num1} × {num2} = {result}'
      },
      {
        'template': 'There are {num1} students in class. {num2} are boys. How many are girls?',
        'operation': 'subtraction',
        'answer': '{num1} - {num2} = {result}'
      },
      {
        'template': 'A train travels {num1} miles in {num2} hours. How many miles per hour?',
        'operation': 'division',
        'answer': '{num1} ÷ {num2} = {result}'
      },
    ];

    final template = templates[_random.nextInt(templates.length)];
    final num1 = _random.nextInt(20) + 5;
    final num2 = _random.nextInt(num1 - 2) + 1;
    final result = template['operation'] == 'subtraction' ? num1 - num2 :
                   template['operation'] == 'multiplication' ? num1 * num2 :
                   num1 ~/ num2;

    final question = template['template']!
        .replaceAll('{num1}', num1.toString())
        .replaceAll('{num2}', num2.toString());

    final answer = template['answer']!
        .replaceAll('{num1}', num1.toString())
        .replaceAll('{num2}', num2.toString())
        .replaceAll('{result}', result.toString());

    return MathRiddle(
      id: 'word_${DateTime.now().millisecondsSinceEpoch}',
      question: question,
      options: _generateWordProblemOptions(result, difficulty),
      correctAnswer: result.toString(),
      explanation: answer,
      progressiveHints: [
        'Identify what the question is asking',
        'Pick out the important numbers',
        'Choose the right operation: ${template['operation']}',
        'Calculate: $answer'
      ],
      difficulty: difficulty,
      basePoints: 130,
      type: MathRiddleType.wordProblem,
    );
  }

  // Helper methods
  static List<String> _generateFractionOptions(int num, int den) {
    final options = <String>['$num/$den'];
    while (options.length < 4) {
      final wrongNum = num + _random.nextInt(4) - 2;
      final wrongDen = den + _random.nextInt(4) - 2;
      if (wrongNum > 0 && wrongDen > 0 && '$wrongNum/$wrongDen' != '$num/$den') {
        options.add('$wrongNum/$wrongDen');
      }
    }
    return options.take(4).toList()..shuffle();
  }

  static List<String> _generateDecimalOptions(double correct) {
    final options = <String>[correct.toStringAsFixed(2)];
    while (options.length < 4) {
      final offset = (_random.nextDouble() - 0.5) * 4;
      final wrong = correct + offset;
      if (wrong >= 0) {
        options.add(wrong.toStringAsFixed(2));
      }
    }
    return options.take(4).toList()..shuffle();
  }

  static double _roundToDecimalPlaces(double number, int places) {
    final factor = pow(10, places);
    return (number * factor).round() / factor;
  }

  static List<String> _generateRoundingOptions(double number, int places) {
    final correct = _roundToDecimalPlaces(number, places);
    final options = <String>[correct.toString()];
    while (options.length < 4) {
      final offset = (_random.nextDouble() - 0.5) * 2;
      final wrong = _roundToDecimalPlaces(number + offset, places);
      if (!options.contains(wrong.toString())) {
        options.add(wrong.toString());
      }
    }
    return options.take(4).toList()..shuffle();
  }

  static String _decimalToFraction(double decimal) {
    final whole = decimal.floor();
    final fractional = decimal - whole;

    if (fractional == 0) return '$whole/1';

    // Simple cases
    if ((fractional - 0.5).abs() < 0.01) return '${whole * 2 + 1}/2';
    if ((fractional - 0.33).abs() < 0.01) return '${whole * 3 + 1}/3';
    if ((fractional - 0.25).abs() < 0.01) return '${whole * 4 + 1}/4';

    return '${(decimal * 100).round()}/100';
  }

  static List<String> _generateFractionOptionsFromDecimal(double decimal) {
    final correct = _decimalToFraction(decimal);
    final options = <String>[correct];

    // Add some common wrong answers
    options.addAll(['${(decimal * 10).round()}/10', '${(decimal * 100).round()}/100', decimal.toString()]);

    return options.take(4).toList()..shuffle();
  }

  static List<String> _generateAreaOptions(int area) {
    final options = <String>['$area cm²'];
    while (options.length < 4) {
      final wrong = area + _random.nextInt(20) - 10;
      if (wrong > 0 && !options.contains('$wrong cm²')) {
        options.add('$wrong cm²');
      }
    }
    return options.take(4).toList()..shuffle();
  }

  static List<String> _generatePerimeterOptions(int perimeter) {
    final options = <String>['$perimeter cm'];
    while (options.length < 4) {
      final wrong = perimeter + _random.nextInt(20) - 10;
      if (wrong > 0 && !options.contains('$wrong cm')) {
        options.add('$wrong cm');
      }
    }
    return options.take(4).toList()..shuffle();
  }

  static List<String> _generateVolumeOptions(int volume) {
    final options = <String>['$volume cm³'];
    while (options.length < 4) {
      final wrong = volume + _random.nextInt(50) - 25;
      if (wrong > 0 && !options.contains('$wrong cm³')) {
        options.add('$wrong cm³');
      }
    }
    return options.take(4).toList()..shuffle();
  }

  static String _classifyAngle(int degrees) {
    if (degrees < 90) return 'Acute';
    if (degrees == 90) return 'Right';
    if (degrees < 180) return 'Obtuse';
    return 'Straight';
  }

  static List<String> _generateWordProblemOptions(int correct, int difficulty) {
    final options = <String>[correct.toString()];
    while (options.length < 4) {
      final offset = _random.nextInt(10) - 5;
      final wrong = correct + offset;
      if (wrong >= 0 && !options.contains(wrong.toString())) {
        options.add(wrong.toString());
      }
    }
    return options.take(4).toList()..shuffle();
  }
}