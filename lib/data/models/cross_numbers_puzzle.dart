import 'dart:math';

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
  final bool isClue;
  final int? clueNumber;
  final bool isHorizontalPart;
  final bool isVerticalPart;

  CrossNumbersCell({
    required this.row,
    required this.col,
    required this.value,
    required this.type,
    this.isUserEditable = false,
    this.userValue = '',
    this.isStatic = true,
    this.isRevealed = false,
    this.isClue = false,
    this.clueNumber,
    this.isHorizontalPart = false,
    this.isVerticalPart = false,
  });

  bool get isCorrect => !isUserEditable || userValue == value;

  CrossNumbersCell copyWith({
    String? userValue,
    bool? isRevealed,
    bool? isUserEditable,
    bool? isStatic,
    bool? isClue,
    int? clueNumber,
    bool? isHorizontalPart,
    bool? isVerticalPart,
  }) {
    return CrossNumbersCell(
      row: row,
      col: col,
      value: value,
      type: type,
      isUserEditable: isUserEditable ?? this.isUserEditable,
      userValue: userValue ?? this.userValue,
      isStatic: isStatic ?? this.isStatic,
      isRevealed: isRevealed ?? this.isRevealed,
      isClue: isClue ?? this.isClue,
      clueNumber: clueNumber ?? this.clueNumber,
      isHorizontalPart: isHorizontalPart ?? this.isHorizontalPart,
      isVerticalPart: isVerticalPart ?? this.isVerticalPart,
    );
  }
}

class CrossNumbersEquation {
  final List<Point<int>> cells;
  final bool isHorizontal;

  CrossNumbersEquation({required this.cells, required this.isHorizontal});

  bool isSatisfied(List<List<CrossNumbersCell>> grid) {
    List<String> segs = [];
    for (var p in cells) {
      final cell = grid[p.x][p.y];
      String val = cell.isUserEditable ? cell.userValue : cell.value;
      if (val.isEmpty) return false;
      segs.add(val);
    }
    
    int eqIdx = segs.indexOf('=');
    if (eqIdx == -1) return false;
    
    List<String> lhs = segs.sublist(0, eqIdx);
    List<String> rhs = segs.sublist(eqIdx + 1);
    
    if (rhs.length != 1) return false;
    
    int? leftVal = _evalLinear(lhs);
    int? rightVal = int.tryParse(rhs[0]);
    
    return leftVal != null && rightVal != null && leftVal == rightVal;
  }

  int? _evalLinear(List<String> segs) {
    if (segs.isEmpty) return null;
    if (segs.length == 1) return int.tryParse(segs[0]);
    
    // We assume the engine generates simple linear chains without operator precedence for this mode
    // (L to R evaluation as implemented in the engine)
    try {
      int res = int.parse(segs[0]);
      for (int i = 1; i < segs.length; i += 2) {
        String op = segs[i];
        int val = int.parse(segs[i + 1]);
        if (op == '+') { res += val; }
        else if (op == '-') { res -= val; }
        else if (op == '×') { res *= val; }
        else if (op == '÷') {
          if (val == 0) return null;
          res ~/= val;
        }
      }
      return res;
    } catch (e) {
      return null;
    }
  }
}

class CrossNumbersPuzzle {
  final String id;
  final int gridSize;
  final List<List<CrossNumbersCell>> grid;
  final List<CrossNumbersEquation> equations;
  final int difficulty;
  final int timeLimit;

  CrossNumbersPuzzle({
    required this.id,
    required this.gridSize,
    required this.grid,
    this.equations = const [],
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
