import 'dart:math';
import '../../data/models/crossword_puzzle.dart';

class CrosswordEngine {
  static final Random _random = Random();
  static const List<Map<String, dynamic>> _curatedMathEntries = [
    // Addition (1-20)
    {'result': 12, 'clue': '7 + 5'}, {'result': 15, 'clue': '9 + 6'}, {'result': 18, 'clue': '9 + 9'},
    {'result': 23, 'clue': '12 + 11'}, {'result': 27, 'clue': '15 + 12'}, {'result': 31, 'clue': '18 + 13'},
    {'result': 34, 'clue': '21 + 13'}, {'result': 38, 'clue': '24 + 14'}, {'result': 42, 'clue': '27 + 15'},
    {'result': 46, 'clue': '30 + 16'}, {'result': 49, 'clue': '33 + 16'}, {'result': 53, 'clue': '36 + 17'},
    {'result': 57, 'clue': '39 + 18'}, {'result': 61, 'clue': '42 + 19'}, {'result': 65, 'clue': '43 + 22'},
    {'result': 69, 'clue': '46 + 23'}, {'result': 73, 'clue': '47 + 26'}, {'result': 77, 'clue': '48 + 29'},
    {'result': 81, 'clue': '52 + 29'}, {'result': 85, 'clue': '55 + 30'},

    // Multiplication (21-40)
    {'result': 21, 'clue': '7 x 3'}, {'result': 24, 'clue': '8 x 3'}, {'result': 27, 'clue': '9 x 3'},
    {'result': 32, 'clue': '8 x 4'}, {'result': 36, 'clue': '6 x 6'}, {'result': 40, 'clue': '5 x 8'},
    {'result': 42, 'clue': '6 x 7'}, {'result': 45, 'clue': '9 x 5'}, {'result': 48, 'clue': '6 x 8'},
    {'result': 54, 'clue': '9 x 6'}, {'result': 56, 'clue': '7 x 8'}, {'result': 60, 'clue': '12 x 5'},
    {'result': 63, 'clue': '9 x 7'}, {'result': 64, 'clue': '8 x 8'}, {'result': 70, 'clue': '10 x 7'},
    {'result': 72, 'clue': '9 x 8'}, {'result': 81, 'clue': '9 x 9'}, {'result': 84, 'clue': '12 x 7'},
    {'result': 90, 'clue': '10 x 9'}, {'result': 96, 'clue': '12 x 8'},

    // Subtraction (41-60)
    {'result': 28, 'clue': '35 - 7'}, {'result': 33, 'clue': '45 - 12'}, {'result': 37, 'clue': '50 - 13'},
    {'result': 41, 'clue': '55 - 14'}, {'result': 44, 'clue': '58 - 14'}, {'result': 48, 'clue': '62 - 14'},
    {'result': 52, 'clue': '66 - 14'}, {'result': 55, 'clue': '69 - 14'}, {'result': 59, 'clue': '73 - 15'},
    {'result': 63, 'clue': '77 - 14'}, {'result': 66, 'clue': '80 - 14'}, {'result': 70, 'clue': '84 - 14'},
    {'result': 74, 'clue': '88 - 14'}, {'result': 77, 'clue': '91 - 14'}, {'result': 81, 'clue': '95 - 14'},
    {'result': 85, 'clue': '99 - 14'}, {'result': 88, 'clue': '102 - 14'}, {'result': 92, 'clue': '106 - 14'},
    {'result': 95, 'clue': '109 - 14'}, {'result': 99, 'clue': '113 - 14'},

    // Division (61-80)
    {'result': 13, 'clue': '26 ÷ 2'}, {'result': 15, 'clue': '45 ÷ 3'}, {'result': 17, 'clue': '34 ÷ 2'},
    {'result': 19, 'clue': '38 ÷ 2'}, {'result': 21, 'clue': '63 ÷ 3'}, {'result': 23, 'clue': '46 ÷ 2'},
    {'result': 25, 'clue': '75 ÷ 3'}, {'result': 27, 'clue': '54 ÷ 2'}, {'result': 29, 'clue': '58 ÷ 2'},
    {'result': 31, 'clue': '62 ÷ 2'}, {'result': 33, 'clue': '99 ÷ 3'}, {'result': 35, 'clue': '70 ÷ 2'},
    {'result': 37, 'clue': '74 ÷ 2'}, {'result': 39, 'clue': '78 ÷ 2'}, {'result': 41, 'clue': '82 ÷ 2'},
    {'result': 43, 'clue': '86 ÷ 2'}, {'result': 45, 'clue': '90 ÷ 2'}, {'result': 47, 'clue': '94 ÷ 2'},
    {'result': 49, 'clue': '98 ÷ 2'}, {'result': 51, 'clue': '102 ÷ 2'},

    // Squares and Powers (81-100)
    {'result': 16, 'clue': '4²'}, {'result': 25, 'clue': '5²'}, {'result': 36, 'clue': '6²'},
    {'result': 49, 'clue': '7²'}, {'result': 64, 'clue': '8²'}, {'result': 81, 'clue': '9²'},
    {'result': 100, 'clue': '10²'}, {'result': 121, 'clue': '11²'}, {'result': 144, 'clue': '12²'},
    {'result': 169, 'clue': '13²'}, {'result': 196, 'clue': '14²'}, {'result': 225, 'clue': '15²'},
    {'result': 256, 'clue': '16²'}, {'result': 289, 'clue': '17²'}, {'result': 324, 'clue': '18²'},
    {'result': 361, 'clue': '19²'}, {'result': 400, 'clue': '20²'}, {'result': 441, 'clue': '21²'},
    {'result': 484, 'clue': '22²'}, {'result': 529, 'clue': '23²'},

    // Advanced Operations (101-120)
    {'result': 125, 'clue': '5³'}, {'result': 216, 'clue': '6³'}, {'result': 343, 'clue': '7³'},
    {'result': 512, 'clue': '8³'}, {'result': 729, 'clue': '9³'}, {'result': 1000, 'clue': '10³'},
    {'result': 8, 'clue': '2⁴'}, {'result': 16, 'clue': '2⁵'}, {'result': 32, 'clue': '2⁶'},
    {'result': 64, 'clue': '2⁷'}, {'result': 128, 'clue': '2⁸'}, {'result': 256, 'clue': '2⁹'},
    {'result': 512, 'clue': '2¹⁰'}, {'result': 1024, 'clue': '2¹¹'}, {'result': 2048, 'clue': '2¹²'},
    {'result': 4096, 'clue': '2¹³'}, {'result': 8192, 'clue': '2¹⁴'}, {'result': 16384, 'clue': '2¹⁵'},
    // Progressive addition - single to triple digits
    {'result': 15, 'clue': '8 + 7'}, {'result': 156, 'clue': '89 + 67'}, {'result': 789, 'clue': '456 + 333'},
    {'result': 1247, 'clue': '789 + 458'}, {'result': 2345, 'clue': '1234 + 1111'}, {'result': 5678, 'clue': '3456 + 2222'},
    {'result': 8912, 'clue': '5678 + 3234'}, {'result': 12345, 'clue': '6789 + 5556'}, {'result': 24680, 'clue': '12345 + 12335'},

    // Progressive subtraction - single to triple digits
    {'result': 12, 'clue': '25 - 13'}, {'result': 234, 'clue': '456 - 222'}, {'result': 567, 'clue': '890 - 323'},
    {'result': 1234, 'clue': '2345 - 1111'}, {'result': 3456, 'clue': '5678 - 2222'}, {'result': 6789, 'clue': '8901 - 2112'},
    {'result': 12345, 'clue': '23456 - 11111'}, {'result': 34567, 'clue': '45678 - 11111'}, {'result': 56789, 'clue': '67890 - 11101'},

    // Progressive multiplication - single to triple digits
    {'result': 18, 'clue': '3 × 6'}, {'result': 156, 'clue': '12 × 13'}, {'result': 567, 'clue': '21 × 27'},
    {'result': 1234, 'clue': '34 × 36'}, {'result': 3456, 'clue': '48 × 72'}, {'result': 5678, 'clue': '67 × 85'},
    {'result': 8912, 'clue': '89 × 100'}, {'result': 12345, 'clue': '111 × 111'}, {'result': 24680, 'clue': '123 × 201'},

    // Progressive division - single to triple digits
    {'result': 5, 'clue': '25 ÷ 5'}, {'result': 12, 'clue': '156 ÷ 13'}, {'result': 21, 'clue': '567 ÷ 27'},
    {'result': 34, 'clue': '1234 ÷ 36'}, {'result': 48, 'clue': '3456 ÷ 72'}, {'result': 67, 'clue': '5678 ÷ 85'},
    {'result': 89, 'clue': '8912 ÷ 100'}, {'result': 111, 'clue': '12345 ÷ 111'}, {'result': 123, 'clue': '24680 ÷ 201'},

    // Progressive squares - single to triple digits
    {'result': 1, 'clue': '1²'}, {'result': 121, 'clue': '11²'}, {'result': 441, 'clue': '21²'},
    {'result': 961, 'clue': '31²'}, {'result': 1681, 'clue': '41²'}, {'result': 2601, 'clue': '51²'},
    {'result': 3721, 'clue': '61²'}, {'result': 5041, 'clue': '71²'}, {'result': 6561, 'clue': '81²'},
    {'result': 8281, 'clue': '91²'}, {'result': 10201, 'clue': '101²'}, {'result': 12321, 'clue': '111²'},

    // Progressive doubles/halves - single to triple digits
    {'result': 14, 'clue': '7 × 2'}, {'result': 246, 'clue': '123 × 2'}, {'result': 1134, 'clue': '567 × 2'},
    {'result': 2468, 'clue': '1234 × 2'}, {'result': 7, 'clue': '14 ÷ 2'}, {'result': 123, 'clue': '246 ÷ 2'},
    {'result': 567, 'clue': '1134 ÷ 2'}, {'result': 1234, 'clue': '2468 ÷ 2'}, {'result': 4321, 'clue': '8642 ÷ 2'},

    // Progressive mixed operations
    {'result': 25, 'clue': '20 + 5'}, {'result': 468, 'clue': '234 × 2'}, {'result': 1357, 'clue': '1234 + 123'},
    {'result': 2468, 'clue': '3690 - 1222'}, {'result': 3690, 'clue': '41 × 90'}, {'result': 4920, 'clue': '6150 ÷ 5'},
    {'result': 6150, 'clue': '123 × 50'}, {'result': 7380, 'clue': '9840 ÷ 4'}, {'result': 8610, 'clue': '70 × 123'},
  ];

  static final Map<int, String> _numberToWords = {
    0: 'ZERO', 1: 'ONE', 2: 'TWO', 3: 'THREE', 4: 'FOUR', 5: 'FIVE',
    6: 'SIX', 7: 'SEVEN', 8: 'EIGHT', 9: 'NINE', 10: 'TEN',
    11: 'ELEVEN', 12: 'TWELVE', 13: 'THIRTEEN', 14: 'FOURTEEN', 15: 'FIFTEEN',
    16: 'SIXTEEN', 17: 'SEVENTEEN', 18: 'EIGHTEEN', 19: 'NINETEEN', 20: 'TWENTY',
    30: 'THIRTY', 40: 'FORTY', 50: 'FIFTY', 60: 'SIXTY', 70: 'SEVENTY',
    80: 'EIGHTY', 90: 'NINETY', 100: 'HUNDRED',
  };

  static String _getWordForNumber(int number) {
    if (_numberToWords.containsKey(number)) {
      return _numberToWords[number]!;
    }
    if (number < 100) {
      int tens = (number ~/ 10) * 10;
      int ones = number % 10;
      return '${_numberToWords[tens]}${_numberToWords[ones]}';
    }
    return '';
  }

  static MapEntry<String, String> _generateMathEntry(int difficulty) {
    int num1, num2, result;
    String clue;
    
    // Ensure the result is within a range we can convert to words (1-99 for simplicity)
    // and that the resulting word is not too long for a standard grid.
    
    bool valid = false;
    String word = '';
    clue = '';
    
    while (!valid) {
      int opType = _random.nextInt(difficulty > 10 ? 4 : (difficulty > 5 ? 3 : 2)); // Scale operations with difficulty
      
      switch (opType) {
        case 0: // Addition
          num1 = _random.nextInt(20 + difficulty) + 1;
          num2 = _random.nextInt(20 + difficulty) + 1;
          result = num1 + num2;
          clue = "$num1 + $num2";
          break;
        case 1: // Subtraction
          num1 = _random.nextInt(30 + difficulty * 2) + 10;
          num2 = _random.nextInt(num1 - 1) + 1;
          result = num1 - num2;
          clue = "$num1 - $num2";
          break;
        case 2: // Multiplication
          num1 = _random.nextInt(8 + (difficulty ~/ 5)) + 2;
          num2 = _random.nextInt(8 + (difficulty ~/ 5)) + 2;
          result = num1 * num2;
          clue = "$num1 × $num2";
          break;
        case 3: // Division
          result = _random.nextInt(12 + (difficulty ~/ 4)) + 2;
          num2 = _random.nextInt(8 + (difficulty ~/ 6)) + 2;
          num1 = result * num2;
          clue = "$num1 ÷ $num2";
          break;
        default:
          result = 10;
          clue = "5 + 5";
      }
      
      if (result > 0 && result < 100) {
        word = _getWordForNumber(result);
        if (word.length >= 3 && word.length <= 12) {
          valid = true;
        }
      }
    }
    
    return MapEntry(word, clue);
  }

  static List<String> get availableThemes => ['Addition', 'Subtraction', 'Multiplication', 'Division', 'Mixed'];

  static List<MapEntry<String, String>> _generateMathWords(int count, int difficulty) {
    final entries = <MapEntry<String, String>>[];
    final usedWords = <String>{};
    final curated = List<Map<String, dynamic>>.from(_curatedMathEntries)..shuffle(_random);

    // Pull from a curated pool first so every level has a stable 20+ source.
    for (final item in curated) {
      if (entries.length >= count) break;
      final result = item['result'] as int;
      final word = _getWordForNumber(result);
      if (word.isEmpty || usedWords.contains(word)) continue;
      entries.add(MapEntry(word, item['clue'] as String));
      usedWords.add(word);
    }
    
    int attempts = 0;
    while (entries.length < count && attempts < 100) {
      final entry = _generateMathEntry(difficulty);
      if (!usedWords.contains(entry.key)) {
        entries.add(entry);
        usedWords.add(entry.key);
      }
      attempts++;
    }
    return entries;
  }

  static CrosswordPuzzle generatePuzzle({
    required String theme,
    required int difficulty,
    int questionCount = 35,
  }) {
    final gridSize = 15;
    final wordCount = questionCount.clamp(10, 25);
    // Advanced difficulty scaling
    int effectiveWordCount = wordCount + (difficulty > 10 ? 2 : (difficulty > 5 ? 1 : 0));
    final entries = _generateMathWords(effectiveWordCount, difficulty);
    final clues = <CrosswordClue>[];

    int clueNumber = 1;
    int row = 1;
    int col = 1;

    for (int i = 0; i < entries.length && row < gridSize - 1; i++) {
      final entry = entries[i];
      final word = entry.key;
      final clueText = entry.value;

      // Simple placement logic (can be improved for real crossword intersections)
      // For now, we keep the improved structure but with math entries
      if (col + word.length >= gridSize - 1) {
        row += 2; // Add spacing
        col = 1;
      }
      
      if (row >= gridSize - 1) break;

      final direction = i % 2 == 0 ? 'across' : 'down';
      
      // Basic bounds check
      if (direction == 'across' && col + word.length > gridSize) continue;
      if (direction == 'down' && row + word.length > gridSize) continue;

      clues.add(
        CrosswordClue(
          number: clueNumber++,
          direction: direction,
          startRow: row,
          startCol: col,
          clue: clueText,
          answer: word,
          hint: _generateHints(word, result: word),
        ),
      );

      if (direction == 'across') {
        col = 1; // Reset col and move down to avoid simple overlap
        row += 2;
      } else {
        col += 3; // Move right
      }
    }

    return CrosswordPuzzle(
      theme: theme,
      gridSize: gridSize,
      grid: _generateGrid(gridSize, clues),
      isBlocked: _generateBlockedGrid(gridSize, clues),
      clues: clues,
      wordCount: clues.length,
      difficulty: difficulty,
    );
  }

  static List<List<String>> _generateGrid(int size, List<CrosswordClue> clues) {
    final grid = List.generate(size, (_) => List.filled(size, ''));

    for (final clue in clues) {
      for (int i = 0; i < clue.length; i++) {
        final row = clue.direction == 'across'
            ? clue.startRow - 1
            : clue.startCol - 1 + i;
        final col = clue.direction == 'across'
            ? clue.startCol - 1 + i
            : clue.startRow - 1;
        if (row >= 0 && row < size && col >= 0 && col < size) {
          grid[row][col] = clue.answer[i];
        }
      }
    }

    return grid;
  }

  static List<List<bool>> _generateBlockedGrid(
    int size,
    List<CrosswordClue> clues,
  ) {
    final grid = List.generate(size, (_) => List.filled(size, false));
    for (final clue in clues) {
      for (int i = 0; i < clue.length; i++) {
        final row = clue.direction == 'across'
            ? clue.startRow - 1
            : clue.startCol - 1 + i;
        final col = clue.direction == 'across'
            ? clue.startCol - 1 + i
            : clue.startRow - 1;
        if (row >= 0 && row < size && col >= 0 && col < size) {
          grid[row][col] = true;
        }
      }
    }
    return grid;
  }

  static List<String> _generateHints(String word, {String? result}) {
    final hints = <String>[];
    final letterCount = word.length;

    hints.add('The result has $letterCount letters');
    if (letterCount >= 4) {
      hints.add('The first letter is: ${word[0]}');
    }
    hints.add('The last letter is: ${word[word.length - 1]}');

    return hints;
  }

  static bool validateAnswer(String userAnswer, String correctAnswer) {
    return userAnswer.toUpperCase().trim() ==
        correctAnswer.toUpperCase().trim();
  }

  static bool validateCell(String userLetter, String correctLetter) {
    return userLetter.toUpperCase() == correctLetter.toUpperCase();
  }

  static bool isPuzzleComplete(
    List<List<String>> grid,
    List<List<String>> solution,
  ) {
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid[r].length; c++) {
        if (solution[r][c].isNotEmpty) {
          if (grid[r][c].isEmpty ||
              grid[r][c].toUpperCase() != solution[r][c].toUpperCase()) {
            return false;
          }
        }
      }
    }
    return true;
  }

  static List<String> getConflictingCells(
    int row,
    int col,
    List<CrosswordClue> clues,
  ) {
    final conflicts = <String>[];

    for (final clue in clues) {
      if (clue.direction == 'across') {
        final endCol = clue.startCol - 1 + clue.length;
        if (row == clue.startRow - 1 &&
            col < endCol &&
            col >= clue.startCol - 1) {
          conflicts.add('${clue.direction}_${clue.number}');
        }
      } else {
        final endRow = clue.startRow - 1 + clue.length;
        if (col == clue.startRow - 1 &&
            row < endRow &&
            row >= clue.startRow - 1) {
          conflicts.add('${clue.direction}_${clue.number}');
        }
      }
    }

    return conflicts;
  }
}
