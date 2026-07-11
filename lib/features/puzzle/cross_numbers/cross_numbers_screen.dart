import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../../../core/providers.dart';
import '../../../core/sound_manager.dart';
import '../../../data/models/cross_numbers_puzzle.dart';

class CrossNumbersScreen extends ConsumerStatefulWidget {
  final int difficulty;
  const CrossNumbersScreen({super.key, required this.difficulty});

  @override
  ConsumerState<CrossNumbersScreen> createState() => _CrossNumbersScreenState();
}

class _CrossNumbersScreenState extends ConsumerState<CrossNumbersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(crossNumbersProvider.notifier).initLevel(widget.difficulty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crossNumbersProvider);
    final theme = Theme.of(context);

    if (state.puzzle == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('LEVEL ${widget.difficulty}', style: const TextStyle(fontFamily: 'Monospace', letterSpacing: 2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () => ref.read(crossNumbersProvider.notifier).useHint(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildInfoBar(context, state),
          Expanded(
            child: _buildGrid(context, ref, state),
          ),
          _buildKeypad(context, ref),
        ],
      ),
    );
  }

  Widget _buildInfoBar(BuildContext context, CrossNumbersState state) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(context, 'PROGRESS', '${state.currentQuestionIndex}/${state.totalQuestions}'),
          _buildStatItem(context, 'SOLVED', '${state.satisfiedEquations.length}/${state.puzzle?.equations.length ?? 0}'),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Monospace')),
      ],
    );
  }

  Widget _buildGrid(BuildContext context, WidgetRef ref, CrossNumbersState state) {
    final puzzle = state.puzzle!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final gridSize = min(constraints.maxWidth, constraints.maxHeight) * 0.95;
        final cellSize = gridSize / puzzle.gridSize;

        return Center(
          child: Container(
            width: gridSize,
            height: gridSize,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: puzzle.gridSize,
              ),
              itemCount: puzzle.gridSize * puzzle.gridSize,
              itemBuilder: (context, index) {
                final row = index ~/ puzzle.gridSize;
                final col = index % puzzle.gridSize;
                final cell = puzzle.grid[row][col];
                
                bool isInSatisfied = false;
                for (int eqIdx in state.satisfiedEquations) {
                  if (puzzle.equations[eqIdx].cells.contains(Point(row, col))) {
                    isInSatisfied = true;
                    break;
                  }
                }

                return _CrossNumberCell(
                  cell: cell,
                  size: cellSize,
                  isSelected: state.selectedRow == row && state.selectedCol == col,
                  isInSatisfiedEq: isInSatisfied,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildKeypad(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['1', '2', '3', '4', '5'].map((n) => _buildKeypadButton(context, ref, n)).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['6', '7', '8', '9', '0'].map((n) => _buildKeypadButton(context, ref, n)).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeypadButton(context, ref, 'BACK'),
              _buildKeypadButton(context, ref, 'CLEAR'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(BuildContext context, WidgetRef ref, String label) {
    final theme = Theme.of(context);
    final isAction = label == 'BACK' || label == 'CLEAR';
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: isAction ? theme.colorScheme.secondaryContainer : theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              HapticManager.instance.lightImpact();
              final state = ref.read(crossNumbersProvider);
              if (state.selectedRow != null && state.selectedCol != null) {
                ref.read(crossNumbersProvider.notifier).updateCell(
                  state.selectedRow!,
                  state.selectedCol!,
                  label,
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 50,
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isAction ? 14 : 20,
                  fontWeight: FontWeight.bold,
                  color: isAction ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CrossNumberCell extends ConsumerWidget {
  final CrossNumbersCell cell;
  final double size;
  final bool isSelected;
  final bool isInSatisfiedEq;

  const _CrossNumberCell({
    required this.cell,
    required this.size,
    required this.isSelected,
    required this.isInSatisfiedEq,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gameTheme = theme.extension<CrossNumbersTheme>() ?? CrossNumbersTheme.dark();
    
    if (cell.type == CrossNumbersCellType.empty) {
      return Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: gameTheme.cellBlocked,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    final isEditable = cell.isUserEditable;
    final isOperator = cell.type == CrossNumbersCellType.operator;
    final isEquals = cell.type == CrossNumbersCellType.equals;
    
    Color bgColor = (isOperator || isEquals) ? gameTheme.cellOperatorBackground : gameTheme.cellBackground;
    Color textColor = (isOperator || isEquals) ? gameTheme.cellOperatorText : gameTheme.cellText;
    Color borderColor = gameTheme.cellBorder;
    
    double fontSize = size * 0.5;
    if (isOperator || isEquals) fontSize = size * 0.6;
    
    if (isEditable) {
      if (cell.userValue.isNotEmpty) {
        textColor = gameTheme.cellUserText;
      }
      
      if (isSelected) {
        borderColor = gameTheme.cellSelectedBorder;
        bgColor = gameTheme.cellSelectedBackground;
      }
    }

    if (cell.isRevealed) {
      textColor = Colors.amberAccent;
      bgColor = theme.colorScheme.primary.withValues(alpha: 0.1);
    }
    
    if (isInSatisfiedEq && !isOperator && !isEquals) {
      if (isEditable) {
         bgColor = Colors.green.withValues(alpha: 0.1);
         borderColor = Colors.green.withValues(alpha: 0.6);
      } else {
         borderColor = Colors.green.withValues(alpha: 0.5);
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEditable ? () {
          HapticManager.instance.selectionClick();
          ref.read(crossNumbersProvider.notifier).selectCell(cell.row, cell.col);
        } : null,
        borderRadius: BorderRadius.circular(size > 42 ? 8 : (size > 36 ? 6 : 4)),
        child: Stack(
          children: [
            Ink(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(size > 42 ? 8 : (size > 36 ? 6 : 4)),
                border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
              ),
              child: Center(
                child: Text(
                  isEditable ? cell.userValue : cell.value,
                  style: TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                    height: 1.0,
                    fontWeight: (isOperator || isEquals) ? FontWeight.w900 : FontWeight.w700,
                    fontFamily: 'Monospace',
                  ),
                ),
              ),
            ),
            if (isInSatisfiedEq && !isOperator && !isEquals && !isEditable)
               Positioned(
                right: 2,
                bottom: 2,
                child: Icon(Icons.check_circle, size: size * 0.25, color: Colors.green.withValues(alpha: 0.8)),
              ),
            if (cell.clueNumber != null)
              Positioned(
                top: size > 40 ? 4 : 2,
                left: size > 40 ? 5 : 3,
                child: Text(
                  '${cell.clueNumber}',
                  style: TextStyle(
                    fontSize: size > 40 ? 9 : 7,
                    color: (isSelected && isEditable) ? theme.colorScheme.primary : textColor.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CrossNumbersTheme extends ThemeExtension<CrossNumbersTheme> {
  final Color cellBackground;
  final Color cellOperatorBackground;
  final Color cellBlocked;
  final Color cellText;
  final Color cellOperatorText;
  final Color cellUserText;
  final Color cellBorder;
  final Color cellSelectedBorder;
  final Color cellSelectedBackground;

  CrossNumbersTheme({
    required this.cellBackground,
    required this.cellOperatorBackground,
    required this.cellBlocked,
    required this.cellText,
    required this.cellOperatorText,
    required this.cellUserText,
    required this.cellBorder,
    required this.cellSelectedBorder,
    required this.cellSelectedBackground,
  });

  factory CrossNumbersTheme.dark() {
    return CrossNumbersTheme(
      cellBackground: const Color(0xFF1E1E1E),
      cellOperatorBackground: const Color(0xFF2D2D2D),
      cellBlocked: Colors.black87,
      cellText: Colors.white,
      cellOperatorText: const Color(0xFF00FFFF),
      cellUserText: const Color(0xFFFFFF00),
      cellBorder: Colors.white24,
      cellSelectedBorder: const Color(0xFF00FFFF),
      cellSelectedBackground: const Color(0xFF00FFFF).withValues(alpha: 0.1),
    );
  }

  @override
  CrossNumbersTheme copyWith({
    Color? cellBackground,
    Color? cellOperatorBackground,
    Color? cellBlocked,
    Color? cellText,
    Color? cellOperatorText,
    Color? cellUserText,
    Color? cellBorder,
    Color? cellSelectedBorder,
    Color? cellSelectedBackground,
  }) {
    return CrossNumbersTheme(
      cellBackground: cellBackground ?? this.cellBackground,
      cellOperatorBackground: cellOperatorBackground ?? this.cellOperatorBackground,
      cellBlocked: cellBlocked ?? this.cellBlocked,
      cellText: cellText ?? this.cellText,
      cellOperatorText: cellOperatorText ?? this.cellOperatorText,
      cellUserText: cellUserText ?? this.cellUserText,
      cellBorder: cellBorder ?? this.cellBorder,
      cellSelectedBorder: cellSelectedBorder ?? this.cellSelectedBorder,
      cellSelectedBackground: cellSelectedBackground ?? this.cellSelectedBackground,
    );
  }

  @override
  CrossNumbersTheme lerp(ThemeExtension<CrossNumbersTheme>? other, double t) {
    if (other is! CrossNumbersTheme) return this;
    return CrossNumbersTheme(
      cellBackground: Color.lerp(cellBackground, other.cellBackground, t)!,
      cellOperatorBackground: Color.lerp(cellOperatorBackground, other.cellOperatorBackground, t)!,
      cellBlocked: Color.lerp(cellBlocked, other.cellBlocked, t)!,
      cellText: Color.lerp(cellText, other.cellText, t)!,
      cellOperatorText: Color.lerp(cellOperatorText, other.cellOperatorText, t)!,
      cellUserText: Color.lerp(cellUserText, other.cellUserText, t)!,
      cellBorder: Color.lerp(cellBorder, other.cellBorder, t)!,
      cellSelectedBorder: Color.lerp(cellSelectedBorder, other.cellSelectedBorder, t)!,
      cellSelectedBackground: Color.lerp(cellSelectedBackground, other.cellSelectedBackground, t)!,
    );
  }
}
