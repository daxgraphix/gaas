enum CrossNumbersCellType { number, operator, equals, empty, result }

class CrossNumbersCell {
  final int row;
  final int col;
  final String value; // e.g., "5", "+", "=", or ""
  final CrossNumbersCellType type;
  final bool isUserEditable;
  final String userValue;
  final bool isStatic;
  final bool isRevealed;

  CrossNumbersCell({
    required this.row,
    required this.col,
    required this.value,
    required this.type,
    this.isUserEditable = false,
    this.userValue = '',
    this.isStatic = true,
    this.isRevealed = false,
  });

  bool get isCorrect => !isUserEditable || userValue == value;

  CrossNumbersCell copyWith({
    String? userValue,
    bool? isRevealed,
  }) {
    return CrossNumbersCell(
      row: row,
      col: col,
      value: value,
      type: type,
      isUserEditable: isUserEditable,
      userValue: userValue ?? this.userValue,
      isStatic: isStatic,
      isRevealed: isRevealed ?? this.isRevealed,
    );
  }
}

class CrossNumbersPuzzle {
  final String id;
  final int gridSize;
  final List<List<CrossNumbersCell>> grid;
  final int difficulty;
  final int timeLimit;

  CrossNumbersPuzzle({
    required this.id,
    required this.gridSize,
    required this.grid,
    required this.difficulty,
    this.timeLimit = 300,
  });

  bool get isComplete {
    for (var row in grid) {
      for (var cell in row) {
        if (cell.isUserEditable && cell.userValue.isEmpty) return false;
      }
    }
    return true;
  }

  bool get isAllCorrect {
    for (var row in grid) {
      for (var cell in row) {
        if (!cell.isCorrect) return false;
      }
    }
    return true;
  }
}
