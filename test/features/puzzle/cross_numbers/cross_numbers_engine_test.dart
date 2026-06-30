import 'package:flutter_test/flutter_test.dart';
import 'package:gaas/core/math_engine/cross_numbers_engine.dart';

void main() {
  group('CrossNumbersEngine Tests', () {
    test('generatePuzzle creates a 5x5 grid for low difficulty', () {
      final puzzle = CrossNumbersEngine.generatePuzzle(difficulty: 5);
      expect(puzzle.gridSize, 5);
      expect(puzzle.grid.length, 5);
      expect(puzzle.grid[0].length, 5);
    });

    test('generatePuzzle creates a 7x7 grid for high difficulty', () {
      final puzzle = CrossNumbersEngine.generatePuzzle(difficulty: 15);
      expect(puzzle.gridSize, 7);
      expect(puzzle.grid.length, 7);
      expect(puzzle.grid[0].length, 7);
    });

    test('5x5 grid mathematical consistency', () {
      for (int i = 0; i < 50; i++) {
        final puzzle = CrossNumbersEngine.generatePuzzle(difficulty: 5);
        if (puzzle.gridSize != 5) continue;
        
        final grid = puzzle.grid;
        // Check Row 0
        expect(_checkEq(grid[0][0].value, grid[0][1].value, grid[0][2].value, grid[0][4].value), true);
        // Check Row 2
        expect(_checkEq(grid[2][0].value, grid[2][1].value, grid[2][2].value, grid[2][4].value), true);
        // Check Row 4
        expect(_checkEq(grid[4][0].value, grid[4][1].value, grid[4][2].value, grid[4][4].value), true);
        
        // Check Col 0
        expect(_checkEq(grid[0][0].value, grid[1][0].value, grid[2][0].value, grid[4][0].value), true);
        // Check Col 2
        expect(_checkEq(grid[0][2].value, grid[1][2].value, grid[2][2].value, grid[4][2].value), true);
        // Check Col 4
        expect(_checkEq(grid[0][4].value, grid[1][4].value, grid[2][4].value, grid[4][4].value), true);
      }
    });

    test('7x7 grid mathematical consistency and stability', () {
      int successCount = 0;
      for (int i = 0; i < 50; i++) {
        final puzzle = CrossNumbersEngine.generatePuzzle(difficulty: 15);
        if (puzzle.gridSize != 7) continue;
        
        final grid = puzzle.grid;
        
        // Skip if it's a fallback (fallback might not have all cells filled the same way)
        if (grid[6][6].value.isEmpty) continue;
        successCount++;

        // Rows
        expect(_checkChain(grid[0][0].value, grid[0][1].value, grid[0][2].value, grid[0][3].value, grid[0][4].value, grid[0][6].value), true);
        expect(_checkChain(grid[2][0].value, grid[2][1].value, grid[2][2].value, grid[2][3].value, grid[2][4].value, grid[2][6].value), true);
        expect(_checkChain(grid[4][0].value, grid[4][1].value, grid[4][2].value, grid[4][3].value, grid[4][4].value, grid[4][6].value), true);
        expect(_checkChain(grid[6][0].value, grid[6][1].value, grid[6][2].value, grid[6][3].value, grid[6][4].value, grid[6][6].value), true);

        // Cols
        expect(_checkChain(grid[0][0].value, grid[1][0].value, grid[2][0].value, grid[3][0].value, grid[4][0].value, grid[6][0].value), true);
        expect(_checkChain(grid[0][2].value, grid[1][2].value, grid[2][2].value, grid[3][2].value, grid[4][2].value, grid[6][2].value), true);
        expect(_checkChain(grid[0][4].value, grid[1][4].value, grid[2][4].value, grid[3][4].value, grid[4][4].value, grid[6][4].value), true);
        expect(_checkChain(grid[0][6].value, grid[1][6].value, grid[2][6].value, grid[3][6].value, grid[4][6].value, grid[6][6].value), true);
      }
      expect(successCount, greaterThan(40), reason: 'Generator should succeed most of the time');
    });
  });
}

bool _checkEq(String n1s, String op, String n2s, String resS) {
  int n1 = int.parse(n1s);
  int n2 = int.parse(n2s);
  int res = int.parse(resS);
  
  switch (op) {
    case '+': return n1 + n2 == res;
    case '-': return n1 - n2 == res;
    case '×': return n1 * n2 == res;
    case '÷': return n2 != 0 && n1 % n2 == 0 && n1 ~/ n2 == res;
  }
  return false;
}

bool _checkChain(String n1s, String op1, String n2s, String op2, String n3s, String resS) {
  int n1 = int.parse(n1s);
  int n2 = int.parse(n2s);
  int n3 = int.parse(n3s);
  int res = int.parse(resS);

  int? mid;
  switch (op1) {
    case '+': mid = n1 + n2; break;
    case '-': mid = n1 - n2; break;
    case '×': mid = n1 * n2; break;
    case '÷': if (n2 != 0 && n1 % n2 == 0) mid = n1 ~/ n2; break;
  }
  
  if (mid == null) return false;

  switch (op2) {
    case '+': return mid + n3 == res;
    case '-': return mid - n3 == res;
    case '×': return mid * n3 == res;
    case '÷': return n3 != 0 && mid % n3 == 0 && mid ~/ n3 == res;
  }
  return false;
}
