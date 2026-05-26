class MathEquationPuzzle {
  final String theme;
  final int difficulty;
  final List<MathEquation> equations;
  final Map<int, int?> userAnswers; // equation index -> user answer
  final int timeLimit;

  MathEquationPuzzle({
    required this.theme,
    required this.difficulty,
    required this.equations,
    this.userAnswers = const {},
    this.timeLimit = 300,
  });

  bool get isComplete {
    return equations.every((eq) => userAnswers[equations.indexOf(eq)] != null);
  }

  bool get isCorrect {
    for (int i = 0; i < equations.length; i++) {
      final userAnswer = userAnswers[i];
      if (userAnswer == null) return false;
      if (!equations[i].isCorrectWithAnswer(userAnswer)) return false;
    }
    return true;
  }

  int calculateStars(int timeSeconds, int hintsUsed) {
    if (!isCorrect) return 0;

    int timeScore = timeSeconds < 60 ? 3 : (timeSeconds < 120 ? 2 : 1);
    double hintPenalty = hintsUsed * 0.3;
    double rawScore = timeScore - hintPenalty;
    return rawScore.clamp(1, 3).toInt();
  }
}

class MathEquation {
  final String equation;
  final int correctAnswer;
  final List<String> hints;
  final int missingIndex; // which part of the equation is missing (0, 1, or 2 for A op B = C)

  MathEquation({
    required this.equation,
    required this.correctAnswer,
    required this.hints,
    required this.missingIndex,
  });

  String get displayEquation {
    final parts = equation.split(' ');
    if (parts.length >= 5) { // a op b = result
      if (missingIndex == 0) {
        parts[0] = '□';
      } else if (missingIndex == 2) {
        parts[2] = '□';
      } else if (missingIndex == 3) {
        parts[4] = '□';
      }
    }
    return parts.join(' ');
  }

  bool isCorrectWithAnswer(int answer) {
    return answer == correctAnswer;
  }
}

class CrosswordPuzzle {
  final String theme;
  final int gridSize;
  final List<List<String>> grid;
  final List<List<bool>> isBlocked;
  final List<CrosswordClue> clues;
  final int wordCount;
  final int difficulty;

  CrosswordPuzzle({
    required this.theme,
    required this.gridSize,
    required this.grid,
    required this.isBlocked,
    required this.clues,
    required this.wordCount,
    required this.difficulty,
  });

  int calculateStars(int timeSeconds, int hintsUsed) {
    int timeScore = timeSeconds < 30 ? 3 : (timeSeconds < 60 ? 2 : 1);
    double hintPenalty = hintsUsed * 0.3;
    double accuracyBonus = 0.0; // Could be added later
    double rawScore = timeScore - hintPenalty + accuracyBonus;
    return rawScore.clamp(1, 3).toInt();
  }
}

class CrosswordClue {
  final int number;
  final String direction;
  final int startRow;
  final int startCol;
  final String clue;
  final String answer;
  final List<String> hint;

  const CrosswordClue({
    required this.number,
    required this.direction,
    required this.startRow,
    required this.startCol,
    required this.clue,
    required this.answer,
    this.hint = const [],
  });

  int get length => answer.length;

  String getId() => '${direction}_$number';
}

class CrosswordCell {
  final int row;
  final int col;
  final String? correctLetter;
  final String? userLetter;
  final bool isBlocked;
  final bool isHighlighted;
  final bool isSelected;
  final int? clueNumber;
  final String? acrossClueRef;
  final String? downClueRef;
  final CrosswordCellState state;

  const CrosswordCell({
    required this.row,
    required this.col,
    this.correctLetter,
    this.userLetter,
    this.isBlocked = false,
    this.isHighlighted = false,
    this.isSelected = false,
    this.clueNumber,
    this.acrossClueRef,
    this.downClueRef,
    this.state = CrosswordCellState.empty,
  });

  CrosswordCell copyWith({
    int? row,
    int? col,
    String? correctLetter,
    String? userLetter,
    bool? isBlocked,
    bool? isHighlighted,
    bool? isSelected,
    int? clueNumber,
    String? acrossClueRef,
    String? downClueRef,
    CrosswordCellState? state,
  }) {
    return CrosswordCell(
      row: row ?? this.row,
      col: col ?? this.col,
      correctLetter: correctLetter ?? this.correctLetter,
      userLetter: userLetter ?? this.userLetter,
      isBlocked: isBlocked ?? this.isBlocked,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isSelected: isSelected ?? this.isSelected,
      clueNumber: clueNumber ?? this.clueNumber,
      acrossClueRef: acrossClueRef ?? this.acrossClueRef,
      downClueRef: downClueRef ?? this.downClueRef,
      state: state ?? this.state,
    );
  }

  bool get isCorrect =>
      userLetter?.toUpperCase() == correctLetter?.toUpperCase();
  bool get isFilled => userLetter != null && userLetter!.isNotEmpty;
}

enum CrosswordCellState { empty, filled, correct, incorrect, revealed }
