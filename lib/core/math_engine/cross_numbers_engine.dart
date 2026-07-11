import 'dart:math';
import '../../data/models/cross_numbers_puzzle.dart';

class CrossNumbersEngine {
  static final Random _random = Random();
  static final RegExp _numericRegex = RegExp(r'^\d+$');

  /// Generates a Cross Numbers puzzle based on the given [difficulty].
  /// [difficulty] scales grid size (5x5, 7x7, 9x9) and hiding strategy.
  static CrossNumbersPuzzle generatePuzzle({required int difficulty, String style = 'Classic'}) {
    int size = 5;
    if (difficulty >= 25 || style == 'Dense' || style == 'Chaos') {
      size = 7;
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
    int attemptsBase = 2000 + (difficulty * 50);

    if (size == 5) {
      success = _generate5x5(grid, difficulty, min(attemptsBase, 4000));
    } else {
      success = _generate7x7(grid, difficulty, min(attemptsBase, 8000));
    }

    if (!success) {
      _generateFallback(grid, size);
    }

    // Hide more cells to make it challenging
    int hiddenCount = _calculateHiddenCount(size, difficulty, style);
    _hideCells(grid, hiddenCount, style: style, difficulty: difficulty);
    
    // Ensure solvability but don't over-reveal
    int safetyReveals = 0;
    while (!isSolvable(grid) && safetyReveals < 3) {
      _revealOneCell(grid);
      safetyReveals++;
    }

    _assignClueNumbers(grid);

    final equations = <CrossNumbersEquation>[];
    for (int r = 0; r < size; r += 2) {
      final cells = <Point<int>>[];
      for (int c = 0; c < size; c++) {
        if (grid[r][c].type != CrossNumbersCellType.empty) {
          cells.add(Point(r, c));
        }
      }
      if (cells.length >= 3) {
        equations.add(CrossNumbersEquation(cells: cells, isHorizontal: true));
      }
    }
    for (int c = 0; c < size; c += 2) {
      final cells = <Point<int>>[];
      for (int r = 0; r < size; r++) {
        if (grid[r][c].type != CrossNumbersCellType.empty) {
          cells.add(Point(r, c));
        }
      }
      if (cells.length >= 3) {
        equations.add(CrossNumbersEquation(cells: cells, isHorizontal: false));
      }
    }

    return CrossNumbersPuzzle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      gridSize: size,
      grid: grid,
      equations: equations,
      difficulty: difficulty,
    );
  }

  static int _calculateHiddenCount(int size, int difficulty, String style) {
    int totalNumbers = (size == 5) ? 9 : 16;
    // We want more empty spaces. 70-85% hidden is good for a challenge.
    int maxHidden = (totalNumbers * 0.85).floor();
    maxHidden = min(maxHidden, totalNumbers - 1);

    int base;
    if (size == 5) {
      base = 5 + (difficulty ~/ 8);
    } else {
      base = 10 + (difficulty - 20) ~/ 5;
    }

    double multiplier = (style == 'Chaos') ? 1.4 : ((style == 'Dense') ? 1.2 : 1.0);
    int count = (base * multiplier).toInt();
    return count.clamp(size == 5 ? 4 : 8, maxHidden);
  }

  static List<String> _getAllowedOperators(int difficulty) {
    if (difficulty <= 5) {
      return ['+', '-'];
    }
    if (difficulty <= 15) {
      return ['+', '-', '×'];
    }
    return ['+', '-', '×', '÷'];
  }

  static int? _eval(int a, String op, int b, {int difficulty = 0}) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return (a - b < 0) ? null : a - b;
      case '×':
        int res = a * b;
        return (res > 1000) ? null : res;
      case '÷':
        if (b == 0 || a % b != 0) {
          return null;
        }
        int q = a ~/ b;
        if (difficulty >= 30 && (b == 1 || q == 1)) {
          return null;
        }
        return q;
      default:
        return null;
    }
  }

  static int _getInterestingNumber(int minVal, int maxVal, int difficulty) {
    if (difficulty < 20 || _random.nextDouble() > 0.3) {
      return _random.nextInt(maxVal - minVal + 1) + minVal;
    }
    int type = _random.nextInt(3);
    if (type == 0) {
      int factor = _random.nextBool() ? 10 : 5;
      int n = ((_random.nextInt(maxVal ~/ factor - minVal ~/ factor + 1) + minVal ~/ factor) * factor);
      if (n >= minVal && n <= maxVal) {
        return n;
      }
    } else if (type == 1) {
      int sMin = sqrt(minVal).ceil();
      int sMax = sqrt(maxVal).floor();
      if (sMax >= sMin) {
        int s = _random.nextInt(sMax - sMin + 1) + sMin;
        return s * s;
      }
    } else if (type == 2) {
      List<int> primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97];
      var valid = primes.where((p) => p >= minVal && p <= maxVal).toList();
      if (valid.isNotEmpty) {
        return valid[_random.nextInt(valid.length)];
      }
    }
    return _random.nextInt(maxVal - minVal + 1) + minVal;
  }

  static String _pickOperator(int difficulty, List<String> allowed) {
    if (allowed.length <= 1) {
      return allowed.first;
    }
    if (difficulty > 30) {
      bool hasComplex = false;
      for (var op in allowed) {
        if (op == '×' || op == '÷') {
          hasComplex = true;
          break;
        }
      }

      if (hasComplex && _random.nextDouble() < 0.5) {
        // Fast pick without allocation
        for (int i = 0; i < 5; i++) {
          String op = allowed[_random.nextInt(allowed.length)];
          if (op == '×' || op == '÷') {
            return op;
          }
        }
      }
    }
    return allowed[_random.nextInt(allowed.length)];
  }

  static bool _generate5x5(List<List<CrossNumbersCell>> grid, int difficulty, int attempts) {
    final ops = _getAllowedOperators(difficulty);
    final maxNum = 15 + (difficulty * 2);
    final minNum = difficulty > 15 ? 5 : 1;

    for (int attempt = 0; attempt < attempts; attempt++) {
      int n00 = _getInterestingNumber(minNum, maxNum, difficulty);
      int n02 = _getInterestingNumber(minNum, maxNum, difficulty);
      int n20 = _getInterestingNumber(minNum, maxNum, difficulty);
      int n22 = _getInterestingNumber(minNum, maxNum, difficulty);
      String op01 = _pickOperator(difficulty, ops);
      String op21 = _pickOperator(difficulty, ops);
      String op10 = _pickOperator(difficulty, ops);
      String op12 = _pickOperator(difficulty, ops);
      int? n04 = _eval(n00, op01, n02, difficulty: difficulty);
      int? n24 = _eval(n20, op21, n22, difficulty: difficulty);
      int? n40 = _eval(n00, op10, n20, difficulty: difficulty);
      int? n42 = _eval(n02, op12, n22, difficulty: difficulty);
      if ([n04, n24, n40, n42].any((n) => n == null || n <= 0)) {
        continue;
      }
      int n04v = n04!;
      int n24v = n24!;
      int n40v = n40!;
      int n42v = n42!;

      for (String o14 in ops) {
        for (String o41 in ops) {
          int? res1 = _eval(n04v, o14, n24v, difficulty: difficulty);
          int? res2 = _eval(n40v, o41, n42v, difficulty: difficulty);
          if (res1 != null && res1 == res2 && res1 > 0) {
            _fill5x5Grid(grid, [n00, n02, n04v, n20, n22, n24v, n40v, n42v, res1], [op01, op21, op10, op12, o14, o41]);
            return true;
          }
        }
      }
    }
    return false;
  }

  static void _fill5x5Grid(List<List<CrossNumbersCell>> grid, List<int> n, List<String> o) {
    _setCell(grid, 0, 0, n[0].toString());
    _setCell(grid, 0, 1, o[0]);
    _setCell(grid, 0, 2, n[1].toString());
    _setCell(grid, 0, 3, '=');
    _setCell(grid, 0, 4, n[2].toString());
    _setCell(grid, 2, 0, n[3].toString());
    _setCell(grid, 2, 1, o[1]);
    _setCell(grid, 2, 2, n[4].toString());
    _setCell(grid, 2, 3, '=');
    _setCell(grid, 2, 4, n[5].toString());
    _setCell(grid, 4, 0, n[6].toString());
    _setCell(grid, 4, 1, o[5]);
    _setCell(grid, 4, 2, n[7].toString());
    _setCell(grid, 4, 3, '=');
    _setCell(grid, 4, 4, n[8].toString());
    _setCell(grid, 1, 0, o[2]);
    _setCell(grid, 3, 0, '=');
    _setCell(grid, 1, 2, o[3]);
    _setCell(grid, 3, 2, '=');
    _setCell(grid, 1, 4, o[4]);
    _setCell(grid, 3, 4, '=');
  }

  static bool _generate7x7(List<List<CrossNumbersCell>> grid, int difficulty, int attempts) {
    final ops = _getAllowedOperators(difficulty);
    final maxNum = 25 + (difficulty - 15) * 4;
    final minNum = 2 + (difficulty ~/ 10);
    for (int attempt = 0; attempt < attempts; attempt++) {
      List<int> n = List.generate(9, (_) => _getInterestingNumber(minNum, maxNum, difficulty));
      List<String> rOps = List.generate(6, (_) => _pickOperator(difficulty, ops));
      List<String> cOps = List.generate(6, (_) => _pickOperator(difficulty, ops));
      int? n06 = _evalChain(n[0], rOps[0], n[1], rOps[1], n[2], difficulty: difficulty);
      int? n26 = _evalChain(n[3], rOps[2], n[4], rOps[3], n[5], difficulty: difficulty);
      int? n46 = _evalChain(n[6], rOps[4], n[7], rOps[5], n[8], difficulty: difficulty);
      int? n60 = _evalChain(n[0], cOps[0], n[3], cOps[1], n[6], difficulty: difficulty);
      int? n62 = _evalChain(n[1], cOps[2], n[4], cOps[3], n[7], difficulty: difficulty);
      int? n64 = _evalChain(n[2], cOps[4], n[5], cOps[5], n[8], difficulty: difficulty);
      if ([n06, n26, n46, n60, n62, n64].any((v) => v == null || v <= 0 || v > 5000)) {
        continue;
      }

      int n06v = n06!;
      int n26v = n26!;
      int n46v = n46!;
      int n60v = n60!;
      int n62v = n62!;
      int n64v = n64!;

      Map<int, List<String>> colFinals = {};
      for (var o1 in ops) {
        for (var o2 in ops) {
          int? res = _evalChain(n60v, o1, n62v, o2, n64v, difficulty: difficulty);
          if (res != null && res > 0) {
            colFinals[res] = [o1, o2];
          }
        }
      }

      for (var o1 in ops) {
        for (var o2 in ops) {
          int? res = _evalChain(n06v, o1, n26v, o2, n46v, difficulty: difficulty);
          if (res != null && colFinals.containsKey(res)) {
            _fill7x7Grid(
              grid,
              [n[0], n[1], n[2], n06v, n[3], n[4], n[5], n26v, n[6], n[7], n[8], n46v, n60v, n62v, n64v, res],
              [rOps[0], rOps[1], rOps[2], rOps[3], rOps[4], rOps[5], colFinals[res]![0], colFinals[res]![1], cOps[0], cOps[1], cOps[2], cOps[3], cOps[4], cOps[5], o1, o2],
            );
            return true;
          }
        }
      }
    }
    return false;
  }

  static void _fill7x7Grid(List<List<CrossNumbersCell>> grid, List<int> nums, List<String> ops) {
    for (int r = 0; r <= 6; r += 2) {
      int bN = (r ~/ 2) * 4;
      int bO = (r ~/ 2) * 2;
      _setCell(grid, r, 0, nums[bN].toString());
      _setCell(grid, r, 1, ops[bO]);
      _setCell(grid, r, 2, nums[bN + 1].toString());
      _setCell(grid, r, 3, ops[bO + 1]);
      _setCell(grid, r, 4, nums[bN + 2].toString());
      _setCell(grid, r, 5, "=");
      _setCell(grid, r, 6, nums[bN + 3].toString());
    }
    for (int c = 0; c <= 6; c += 2) {
      int bO = 8 + (c ~/ 2) * 2;
      _setCell(grid, 1, c, ops[bO]);
      _setCell(grid, 3, c, ops[bO + 1]);
      _setCell(grid, 5, c, "=");
    }
  }

  static int? _evalChain(int n1, String op1, int n2, String op2, int n3, {int difficulty = 0}) {
    int? r1 = _eval(n1, op1, n2, difficulty: difficulty);
    if (r1 == null) {
      return null;
    }
    if (difficulty >= 25 && r1 > 2000) {
      return null;
    }
    return _eval(r1, op2, n3, difficulty: difficulty);
  }

  static int? _evalChain3(int n1, String op1, int n2, String op2, int n3, String op3, int n4, {int difficulty = 0}) {
    int? r1 = _eval(n1, op1, n2, difficulty: difficulty);
    if (r1 == null) {
      return null;
    }
    if (difficulty >= 45 && r1 > 5000) {
      return null;
    }
    int? r2 = _eval(r1, op2, n3, difficulty: difficulty);
    if (r2 == null) {
      return null;
    }
    if (difficulty >= 45 && r2 > 5000) {
      return null;
    }
    return _eval(r2, op3, n4, difficulty: difficulty);
  }

  static void _setCell(List<List<CrossNumbersCell>> grid, int r, int c, String val) {
    CrossNumbersCellType type;
    if (_numericRegex.hasMatch(val)) {
      bool isRes = (c == grid.length - 1) || (r == grid.length - 1);
      type = isRes ? CrossNumbersCellType.result : CrossNumbersCellType.number;
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
    // A robust, deterministic fallback for when generation fails.
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (r % 2 == 0 && c % 2 == 0) {
          _setCell(grid, r, c, (r + c + 2).toString());
        } else if (r % 2 == 0 && c % 2 != 0) {
          _setCell(grid, r, c, c == size - 2 ? "=" : "+");
        } else if (r % 2 != 0 && c % 2 == 0) {
          _setCell(grid, r, c, r == size - 2 ? "=" : "+");
        } else {
          _setCell(grid, r, c, "");
        }
      }
    }
    for (int r = 0; r < size - 1; r += 2) {
      int sum = 0;
      for (int c = 0; c < size - 2; c += 2) {
        sum += (r + c + 2);
      }
      _setCell(grid, r, size - 1, sum.toString());
    }
    for (int c = 0; c < size - 1; c += 2) {
      int sum = 0;
      for (int r = 0; r < size - 2; r += 2) {
        sum += (r + c + 2);
      }
      _setCell(grid, size - 1, c, sum.toString());
    }
    int finalSum = 0;
    for (int i = 0; i < size - 2; i += 2) {
      finalSum += int.parse(grid[i][size - 1].value);
    }
    _setCell(grid, size - 1, size - 1, finalSum.toString());
    for (int i = 1; i < size - 2; i += 2) {
      _setCell(grid, size - 1, i, "+");
      _setCell(grid, i, size - 1, "+");
    }
  }

  static void _hideCells(List<List<CrossNumbersCell>> grid, int count, {String style = 'Classic', required int difficulty}) {
    final size = grid.length;
    final eqMap = <Point<int>, List<int>>{};
    final eqs = <List<Point<int>>>[];
    final nums = <Point<int>>[];
    
    void addEq(List<Point<int>> eq) {
      if (eq.isEmpty) return;
      int idx = eqs.length;
      eqs.add(eq);
      for (var p in eq) {
        eqMap.putIfAbsent(p, () => []).add(idx);
        if (!nums.contains(p)) nums.add(p);
      }
    }
    
    for (int r = 0; r < size; r += 2) {
      final eq = <Point<int>>[];
      for (int c = 0; c < size; c += 2) {
        eq.add(Point(r, c));
      }
      addEq(eq);
    }
    for (int c = 0; c < size; c += 2) {
      final eq = <Point<int>>[];
      for (int r = 0; r < size; r += 2) {
        eq.add(Point(r, c));
      }
      addEq(eq);
    }

    nums.shuffle(_random);
    
    // Priority: hide results first, then operands
    nums.sort((a, b) {
      bool aRes = grid[a.x][a.y].type == CrossNumbersCellType.result;
      bool bRes = grid[b.x][b.y].type == CrossNumbersCellType.result;
      if (aRes != bRes) return aRes ? -1 : 1;
      return 0;
    });

    final hidden = <Point<int>>{};
    final eqVis = List.generate(eqs.length, (i) => eqs[i].length);
    
    bool canH(Point<int> p, List<int> vis) {
      for (int idx in eqMap[p]!) {
        // High difficulty: allow hiding almost everything (only 1 must stay)
        // Lower difficulty: keep at least 2 visible to provide more clues
        int minVisible = difficulty > 30 ? 1 : 2;
        if (vis[idx] <= minVisible) {
          return false;
        }
      }
      return true;
    }

    for (var p in nums) {
      if (hidden.length >= count) break;
      if (canH(p, eqVis)) {
        hidden.add(p);
        for (int idx in eqMap[p]!) {
          eqVis[idx]--;
        }
      }
    }

    for (var p in hidden) {
      grid[p.x][p.y] = grid[p.x][p.y].copyWith(
        isUserEditable: true, 
        userValue: '', 
        isStatic: false
      );
    }
  }

  static void _revealOneCell(List<List<CrossNumbersCell>> grid) {
    List<Point<int>> cands = [];
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid.length; c++) {
        if (grid[r][c].isUserEditable) {
          cands.add(Point(r, c));
        }
      }
    }
    if (cands.isNotEmpty) {
      Point<int> p = cands[_random.nextInt(cands.length)];
      grid[p.x][p.y] = grid[p.x][p.y].copyWith(isUserEditable: false, isStatic: true);
    }
  }

  static void _assignClueNumbers(List<List<CrossNumbersCell>> grid) {
    int cur = 1;
    final size = grid.length;
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final cell = grid[r][c];
        if (cell.type == CrossNumbersCellType.number || cell.type == CrossNumbersCellType.result) {
          bool isH = (c == 0 || grid[r][c - 1].type == CrossNumbersCellType.empty) && 
                     (c + 1 < size && grid[r][c + 1].type != CrossNumbersCellType.empty);
          
          bool isV = (r == 0 || grid[r - 1][c].type == CrossNumbersCellType.empty) && 
                     (r + 1 < size && grid[r + 1][c].type != CrossNumbersCellType.empty);
          
          if (isH || isV) {
            grid[r][c] = cell.copyWith(
              isClue: true, 
              clueNumber: cur++, 
              isHorizontalPart: isH, 
              isVerticalPart: isV
            );
          }
        }
      }
    }
  }

  static bool isSolvable(List<List<CrossNumbersCell>> grid) {
    final size = grid.length;
    final working = List.generate(size, (r) => List.generate(size, (c) => grid[r][c].isUserEditable ? null : grid[r][c].value));
    bool changed = true;
    while (changed) {
      changed = false;
      for (int r = 0; r < size; r += 2) {
        if (_solveEq(working, r, true)) {
          changed = true;
        }
      }
      for (int c = 0; c < size; c += 2) {
        if (_solveEq(working, c, false)) {
          changed = true;
        }
      }
      bool all = true;
      for (int r = 0; r < size; r += 2) {
        for (int c = 0; c < size; c += 2) {
          if (working[r][c] == null) {
            all = false;
          }
        }
      }
      if (all) {
        return true;
      }
    }
    return false;
  }

  static bool _solveEq(List<List<String?>> working, int idx, bool isH) {
    final size = working.length;
    List<int> unks = [];
    List<String> segs = [];
    for (int i = 0; i < size; i++) {
      int r = isH ? idx : i; int c = isH ? i : idx;
      String? val = working[r][c];
      if (i % 2 == 0) {
        if (val == null) {
          unks.add(segs.length);
          segs.add("?");
        } else {
          segs.add(val);
        }
      } else {
        if (val == null) {
          return false;
        }
        segs.add(val);
      }
    }
    if (unks.length != 1) return false;
    int eqIdx = segs.indexOf('=');
    if (eqIdx == -1) return false;
    List<String> lhs = segs.sublist(0, eqIdx);
    List<String> rhs = segs.sublist(eqIdx + 1);
    int unkIdx = unks.first;
    if (unkIdx < eqIdx) {
      if (rhs.length != 1 || rhs[0] == "?") {
        return false;
      }
      int target = int.parse(rhs[0]);
      int? solved = _solveLinear(lhs, target);
      if (solved != null && solved >= 0) {
        int rLoc = isH ? idx : unkIdx * 2;
        int cLoc = isH ? unkIdx * 2 : idx;
        working[rLoc][cLoc] = solved.toString();
        return true;
      }
    } else {
      int? res = _evalLinear(lhs);
      if (res != null) {
        int rLoc = isH ? idx : unkIdx * 2;
        int cLoc = isH ? unkIdx * 2 : idx;
        working[rLoc][cLoc] = res.toString();
        return true;
      }
    }
    return false;
  }

  static int? _solveLinear(List<String> segs, int target) {
    if (segs.length == 1) {
      return segs[0] == "?" ? target : (int.tryParse(segs[0]) == target ? target : null);
    }
    String lastN = segs.last;
    String lastO = segs[segs.length - 2];
    List<String> leading = segs.sublist(0, segs.length - 2);
    if (lastN == "?") {
      int? leadVal = _evalLinear(leading);
      if (leadVal == null) {
        return null;
      }
      return _solveSimple(leadVal, lastO, target, false);
    } else {
      int lastNum = int.parse(lastN);
      int? reqLead = _solveSimple(lastNum, lastO, target, true);
      if (reqLead == null) {
        return null;
      }
      return _solveLinear(leading, reqLead);
    }
  }

  static int? _evalLinear(List<String> segs) {
    if (segs.any((s) => s == "?")) {
      return null;
    }
    if (segs.length == 1) {
      return int.parse(segs[0]);
    }
    if (segs.length == 3) {
      return _eval(int.parse(segs[0]), segs[1], int.parse(segs[2]));
    }
    if (segs.length == 5) {
      return _evalChain(
        int.parse(segs[0]),
        segs[1],
        int.parse(segs[2]),
        segs[3],
        int.parse(segs[4]),
      );
    }
    if (segs.length == 7) {
      return _evalChain3(
        int.parse(segs[0]),
        segs[1],
        int.parse(segs[2]),
        segs[3],
        int.parse(segs[4]),
        segs[5],
        int.parse(segs[6]),
      );
    }
    return null;
  }

  static int? _solveSimple(int known, String op, int target, bool unknownFirst) {
    if (unknownFirst) {
      if (op == '+') return target - known;
      if (op == '-') return target + known;
      if (op == '×') return (known != 0 && target % known == 0) ? target ~/ known : null;
      if (op == '÷') return target * known;
    } else {
      if (op == '+') return target - known;
      if (op == '-') return known - target;
      if (op == '×') return (known != 0 && target % known == 0) ? target ~/ known : null;
      if (op == '÷') return (target != 0 && known % target == 0) ? known ~/ target : null;
    }
    return null;
  }
}
