import 'dart:math';
import '../../data/models/cross_numbers_puzzle.dart';

class CrossNumbersEngine {
  static final Random _random = Random();

  static CrossNumbersPuzzle generatePuzzle({required int difficulty, String style = 'Classic'}) {
    int size = difficulty > 20 ? 7 : 5;
    if (style == 'Dense' || style == 'Chaos') {
      if (difficulty > 10) size = 7;
    }
    
    List<List<CrossNumbersCell>> grid = List.generate(
      size,
      (r) => List.generate(
        size,
        (c) => CrossNumbersCell(
          row: r,
          col: c,
          value: '',
          type: CrossNumbersCellType.empty,
        ),
      ),
    );

    bool success = false;
    if (size == 5) {
      success = _generate5x5(grid, difficulty);
    } else {
      success = _generate7x7(grid, difficulty);
    }

    if (!success) {
      _generateFallback(grid, size);
    }

    // Adjust hidden count based on difficulty, size and style
    int hiddenCount;
    if (size == 5) {
      hiddenCount = 5 + (difficulty - 1) ~/ 2; 
    } else {
      hiddenCount = 12 + (difficulty - 21) ~/ 3;
      if (hiddenCount > 28) hiddenCount = 28;
    }

    if (style == 'Chaos') {
      hiddenCount = (hiddenCount * 1.5).toInt();
    } else if (style == 'Dense') {
      hiddenCount = (hiddenCount * 1.2).toInt();
    }

    _hideRandomNumbers(grid, hiddenCount, style: style);

    return CrossNumbersPuzzle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      gridSize: size,
      grid: grid,
      difficulty: difficulty,
    );
  }

  static List<String> _getAllowedOperators(int difficulty) {
    if (difficulty <= 5) return ['+', '-'];
    if (difficulty <= 15) return ['+', '-', '×'];
    return ['+', '-', '×', '÷'];
  }

  static int? _eval(int a, String op, int b) {
    switch (op) {
      case '+': return a + b;
      case '-': 
        if (a - b < 0) return null; // Avoid negative results
        return a - b;
      case '×': return a * b;
      case '÷':
        if (b == 0 || a % b != 0) return null;
        return a ~/ b;
      default: return null;
    }
  }

  static bool _generate5x5(List<List<CrossNumbersCell>> grid, int difficulty) {
    final ops = _getAllowedOperators(difficulty);
    final maxNum = 10 + (difficulty * 2);
    final minNum = difficulty > 10 ? 5 : 1;

    for (int attempt = 0; attempt < 2000; attempt++) {
      int n00 = _random.nextInt(maxNum) + minNum;
      int n02 = _random.nextInt(maxNum) + minNum;
      int n20 = _random.nextInt(maxNum) + minNum;
      int n22 = _random.nextInt(maxNum) + minNum;

      String op01 = ops[_random.nextInt(ops.length)];
      String op21 = ops[_random.nextInt(ops.length)];
      String op10 = ops[_random.nextInt(ops.length)];
      String op12 = ops[_random.nextInt(ops.length)];

      int? n04 = _eval(n00, op01, n02);
      int? n24 = _eval(n20, op21, n22);
      int? n40 = _eval(n00, op10, n20);
      int? n42 = _eval(n02, op12, n22);

      if (n04 == null || n24 == null || n40 == null || n42 == null) continue;
      if (n04 <= 0 || n24 <= 0 || n40 <= 0 || n42 <= 0) continue;
      if (n04 > 200 || n24 > 200 || n40 > 200 || n42 > 200) continue;

      for (String o14 in ops) {
        for (String o41 in ops) {
          int? res1 = _eval(n04, o14, n24);
          int? res2 = _eval(n40, o41, n42);

          if (res1 != null && res1 == res2 && res1 > 0 && res1 <= 500) {
            int n44 = res1;
            
            _setCell(grid, 0, 0, n00.toString());
            _setCell(grid, 0, 1, op01);
            _setCell(grid, 0, 2, n02.toString());
            _setCell(grid, 0, 3, '=');
            _setCell(grid, 0, 4, n04.toString());

            _setCell(grid, 2, 0, n20.toString());
            _setCell(grid, 2, 1, op21);
            _setCell(grid, 2, 2, n22.toString());
            _setCell(grid, 2, 3, '=');
            _setCell(grid, 2, 4, n24.toString());

            _setCell(grid, 4, 0, n40.toString());
            _setCell(grid, 4, 1, o41);
            _setCell(grid, 4, 2, n42.toString());
            _setCell(grid, 4, 3, '=');
            _setCell(grid, 4, 4, n44.toString());

            _setCell(grid, 1, 0, op10);
            _setCell(grid, 3, 0, '=');
            _setCell(grid, 1, 2, op12);
            _setCell(grid, 3, 2, '=');
            _setCell(grid, 1, 4, o14);
            _setCell(grid, 3, 4, '=');

            return true;
          }
        }
      }
    }
    return false;
  }

  static bool _generate7x7(List<List<CrossNumbersCell>> grid, int difficulty) {
    final ops = _getAllowedOperators(difficulty);
    final maxNum = 20 + (difficulty - 10) * 2;
    final minNum = 2 + (difficulty ~/ 5);

    for (int attempt = 0; attempt < 30000; attempt++) {
      // Pick numbers for top-left 3x3 block
      int n00 = _random.nextInt(maxNum) + minNum;
      int n02 = _random.nextInt(maxNum) + minNum;
      int n04 = _random.nextInt(maxNum) + minNum;
      int n20 = _random.nextInt(maxNum) + minNum;
      int n22 = _random.nextInt(maxNum) + minNum;
      int n24 = _random.nextInt(maxNum) + minNum;
      int n40 = _random.nextInt(maxNum) + minNum;
      int n42 = _random.nextInt(maxNum) + minNum;
      int n44 = _random.nextInt(maxNum) + minNum;

      // Row operators
      String op01 = ops[_random.nextInt(ops.length)];
      String op03 = ops[_random.nextInt(ops.length)];
      String op21 = ops[_random.nextInt(ops.length)];
      String op23 = ops[_random.nextInt(ops.length)];
      String op41 = ops[_random.nextInt(ops.length)];
      String op43 = ops[_random.nextInt(ops.length)];

      // Col operators
      String op10 = ops[_random.nextInt(ops.length)];
      String op30 = ops[_random.nextInt(ops.length)];
      String op12 = ops[_random.nextInt(ops.length)];
      String op32 = ops[_random.nextInt(ops.length)];
      String op14 = ops[_random.nextInt(ops.length)];
      String op34 = ops[_random.nextInt(ops.length)];

      // Evaluate rows (Left-to-Right)
      int? n06 = _evalChain(n00, op01, n02, op03, n04);
      int? n26 = _evalChain(n20, op21, n22, op23, n24);
      int? n46 = _evalChain(n40, op41, n42, op43, n44);

      // Evaluate cols
      int? n60 = _evalChain(n00, op10, n20, op30, n40);
      int? n62 = _evalChain(n02, op12, n22, op32, n42);
      int? n64 = _evalChain(n04, op14, n24, op34, n44);

      if ([n06, n26, n46, n60, n62, n64].any((n) => n == null || n <= 0 || n > 1000)) continue;

      // Now check if Row 6 and Col 6 can intersect at n66
      for (String op61 in ops) {
        for (String op63 in ops) {
          for (String op16 in ops) {
            for (String op36 in ops) {
              int? resR6 = _evalChain(n60!, op61, n62!, op63, n64!);
              int? resC6 = _evalChain(n06!, op16, n26!, op36, n46!);

              if (resR6 != null && resR6 == resC6 && resR6 > 0) {
                int n66 = resR6;
                
                // Fill Row 0
                _setCell(grid, 0, 0, n00.toString());
                _setCell(grid, 0, 1, op01);
                _setCell(grid, 0, 2, n02.toString());
                _setCell(grid, 0, 3, op03);
                _setCell(grid, 0, 4, n04.toString());
                _setCell(grid, 0, 5, '=');
                _setCell(grid, 0, 6, n06.toString());

                // Fill Row 2
                _setCell(grid, 2, 0, n20.toString());
                _setCell(grid, 2, 1, op21);
                _setCell(grid, 2, 2, n22.toString());
                _setCell(grid, 2, 3, op23);
                _setCell(grid, 2, 4, n24.toString());
                _setCell(grid, 2, 5, '=');
                _setCell(grid, 2, 6, n26.toString());

                // Fill Row 4
                _setCell(grid, 4, 0, n40.toString());
                _setCell(grid, 4, 1, op41);
                _setCell(grid, 4, 2, n42.toString());
                _setCell(grid, 4, 3, op43);
                _setCell(grid, 4, 4, n44.toString());
                _setCell(grid, 4, 5, '=');
                _setCell(grid, 4, 6, n46.toString());

                // Fill Row 6
                _setCell(grid, 6, 0, n60.toString());
                _setCell(grid, 6, 1, op61);
                _setCell(grid, 6, 2, n62.toString());
                _setCell(grid, 6, 3, op63);
                _setCell(grid, 6, 4, n64.toString());
                _setCell(grid, 6, 5, '=');
                _setCell(grid, 6, 6, n66.toString());

                // Fill Vertical operators and equals
                for (int c = 0; c <= 6; c += 2) {
                  String? vOp1, vOp3;
                  if (c == 0) { vOp1 = op10; vOp3 = op30; }
                  else if (c == 2) { vOp1 = op12; vOp3 = op32; }
                  else if (c == 4) { vOp1 = op14; vOp3 = op34; }
                  else if (c == 6) { vOp1 = op16; vOp3 = op36; }

                  if (vOp1 != null && vOp3 != null) {
                    _setCell(grid, 1, c, vOp1);
                    _setCell(grid, 3, c, vOp3);
                    _setCell(grid, 5, c, '=');
                  }
                }

                return true;
              }
            }
          }
        }
      }
    }
    return false;
  }

  static int? _evalChain(int n1, String op1, int n2, String op2, int n3) {
    int? res1 = _eval(n1, op1, n2);
    if (res1 == null) return null;
    return _eval(res1, op2, n3);
  }

  static void _setCell(List<List<CrossNumbersCell>> grid, int r, int c, String val) {
    CrossNumbersCellType type;
    if (RegExp(r'^\d+$').hasMatch(val)) {
      if ((r == 0 && c == 4) || (r == 2 && c == 4) || (r == 4 && c == 4) || 
          (r == 4 && c == 0) || (r == 4 && c == 2) ||
          (grid.length == 7 && (
            (r == 0 && c == 6) || (r == 2 && c == 6) || (r == 4 && c == 6) || (r == 6 && c == 6) ||
            (r == 6 && c == 0) || (r == 6 && c == 2) || (r == 6 && c == 4)
          ))) {
        type = CrossNumbersCellType.result;
      } else {
        type = CrossNumbersCellType.number;
      }
    } else if (val == '=') {
      type = CrossNumbersCellType.equals;
    } else if (val == '') {
       type = CrossNumbersCellType.empty;
    } else {
      type = CrossNumbersCellType.operator;
    }
    grid[r][c] = CrossNumbersCell(row: r, col: c, value: val, type: type);
  }

  static void _generateFallback(List<List<CrossNumbersCell>> grid, int size) {
    if (size == 5) {
      // Row 0: 1 + 2 = 3; Row 2: 4 + 5 = 9; Row 4: 5 + 7 = 12
      // Col 0: 1 + 4 = 5; Col 2: 2 + 5 = 7; Col 4: 3 + 9 = 12
      _setCell(grid, 0, 0, "1"); _setCell(grid, 0, 1, "+"); _setCell(grid, 0, 2, "2"); _setCell(grid, 0, 3, "="); _setCell(grid, 0, 4, "3");
      _setCell(grid, 2, 0, "4"); _setCell(grid, 2, 1, "+"); _setCell(grid, 2, 2, "5"); _setCell(grid, 2, 3, "="); _setCell(grid, 2, 4, "9");
      _setCell(grid, 4, 0, "5"); _setCell(grid, 4, 1, "+"); _setCell(grid, 4, 2, "7"); _setCell(grid, 4, 3, "="); _setCell(grid, 4, 4, "12");
      
      _setCell(grid, 1, 0, "+"); _setCell(grid, 3, 0, "=");
      _setCell(grid, 1, 2, "+"); _setCell(grid, 3, 2, "=");
      _setCell(grid, 1, 4, "+"); _setCell(grid, 3, 4, "=");
    } else {
      // 7x7 Fallback
      // R0, R2, R4: 1 + 1 + 1 = 3
      // R6: 3 + 3 + 3 = 9
      // C0, C2, C4: 1 + 1 + 1 = 3
      // C6: 3 + 3 + 3 = 9
      for (int r = 0; r <= 4; r += 2) {
        _setCell(grid, r, 0, "1"); _setCell(grid, r, 1, "+"); _setCell(grid, r, 2, "1"); _setCell(grid, r, 3, "+"); _setCell(grid, r, 4, "1"); _setCell(grid, r, 5, "="); _setCell(grid, r, 6, "3");
      }
      _setCell(grid, 6, 0, "3"); _setCell(grid, 6, 1, "+"); _setCell(grid, 6, 2, "3"); _setCell(grid, 6, 3, "+"); _setCell(grid, 6, 4, "3"); _setCell(grid, 6, 5, "="); _setCell(grid, 6, 6, "9");

      for (int c = 0; c <= 6; c += 2) {
        _setCell(grid, 1, c, "+"); _setCell(grid, 3, c, "+"); _setCell(grid, 5, c, "=");
      }
    }
  }

  static void _hideRandomNumbers(List<List<CrossNumbersCell>> grid, int count, {String style = 'Classic'}) {
    final numberCells = <Point<int>>[];
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid[r].length; c++) {
        final cell = grid[r][c];
        if (cell.type == CrossNumbersCellType.number || cell.type == CrossNumbersCellType.result) {
          numberCells.add(Point(r, c));
        }
      }
    }
    
    final toHide = <Point<int>>{};
    
    if (style == 'Symmetry') {
      numberCells.shuffle(_random);
      for (var p in numberCells) {
        if (toHide.length >= count) break;
        if (toHide.contains(p)) continue;
        
        toHide.add(p);
        // Rotational symmetry pair
        Point<int> symmetric = Point(grid.length - 1 - p.x, grid.length - 1 - p.y);
        if (toHide.length < count) {
           toHide.add(symmetric);
        }
      }
    } else {
      numberCells.shuffle(_random);
      for (int i = 0; i < count && i < numberCells.length; i++) {
        toHide.add(numberCells[i]);
      }
    }

    for (var p in toHide) {
      final cell = grid[p.x][p.y];
      grid[p.x][p.y] = CrossNumbersCell(
        row: cell.row,
        col: cell.col,
        value: cell.value,
        type: cell.type,
        isUserEditable: true,
        userValue: '',
        isStatic: false,
      );
    }
  }
}
