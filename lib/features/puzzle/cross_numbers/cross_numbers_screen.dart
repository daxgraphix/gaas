import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers.dart';
import '../../../core/sound_manager.dart';
import '../../../core/themes/app_themes.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../data/models/cross_numbers_puzzle.dart';
import '../../../shared/widgets/puzzle_widgets.dart';

class CrossNumbersScreen extends ConsumerStatefulWidget {
  final int difficulty;
  const CrossNumbersScreen({super.key, this.difficulty = 1});

  @override
  ConsumerState<CrossNumbersScreen> createState() => _CrossNumbersScreenState();
}

class _CrossNumbersScreenState extends ConsumerState<CrossNumbersScreen> {
  Timer? _timer;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        ref.read(crossNumbersProvider.notifier).initLevel(widget.difficulty);
        _showTutorialIfNeeded();
      }
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isDisposed) {
        ref.read(crossNumbersProvider.notifier).incrementTime();
      }
    });
  }

  void _showTutorialIfNeeded() {
    // Show tutorial only for the first level or if explicitly requested
    if (widget.difficulty == 1) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_isDisposed) _showTutorial();
      });
    }
  }

  void _showTutorial() {
    showDialog(
      context: context,
      builder: (context) => PremiumGlassOverlay(
        borderRadius: 24,
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.help_outline_rounded, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            const Text('How to Play'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTutorialItem(Icons.grid_4x4_rounded, 'Fill in the missing numbers to complete the equations.'),
            _buildTutorialItem(Icons.swap_horiz_rounded, 'Equations work both horizontally and vertically.'),
            _buildTutorialItem(Icons.lightbulb_outline_rounded, 'Use hints if you get stuck (costs 50 points).'),
            _buildTutorialItem(Icons.check_circle_outline_rounded, 'Tap SUBMIT when you think you\'ve solved it!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('GOT IT'),
          ),
        ],
      ),
    ));
  }

  Widget _buildTutorialItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final puzzleState = ref.watch(crossNumbersProvider);
    final theme = Theme.of(context);
    final user = ref.watch(userSessionProvider);

    if (puzzleState.puzzle == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
          onPressed: () => _showExitDialog(),
        ),
        title: Column(
          children: [
            Text(
              'LEVEL ${widget.difficulty} - ${puzzleState.gridStyle}',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              'Question ${puzzleState.currentQuestionIndex} / ${puzzleState.totalQuestions}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          _buildHintButton(puzzleState, user, theme),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100),
            _buildPointsDisplay(user, theme),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: _buildGrid(puzzleState),
                  ),
                ),
              ),
            ),
            _buildNumpad(puzzleState, theme),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsDisplay(dynamic user, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          Text(
            '${user?.totalPoints ?? 0}',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.5, end: 0);
  }

  Widget _buildHintButton(CrossNumbersState state, dynamic user, ThemeData theme) {
    final canAfford = (user?.totalPoints ?? 0) >= 50;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        onPressed: canAfford ? () => ref.read(crossNumbersProvider.notifier).useHint() : null,
        icon: Stack(
          alignment: Alignment.topRight,
          children: [
            Icon(
              Icons.lightbulb_rounded,
              color: canAfford ? Colors.amber : theme.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            if (canAfford)
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Text('50', style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(CrossNumbersState state) {
    final puzzle = state.puzzle!;
    final gameTheme = Theme.of(context).extension<GameThemeExtension>()!;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use screen width if constraints are unbounded (common in scroll views)
        double width = constraints.maxWidth.isFinite ? constraints.maxWidth : screenWidth;
        double availableWidth = width - 32; // Allow for screen padding and margins
        double cellSize = (availableWidth / puzzle.gridSize).floorToDouble();
        
        // Ensure cells are not too large or too small
        cellSize = cellSize.clamp(32.0, 52.0);
        
        double cellMargin = puzzle.gridSize >= 9 ? 0.5 : 1.0;
        double innerCellSize = cellSize - (cellMargin * 2);

        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: gameTheme.numpadBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: gameTheme.gridLineColor),
            boxShadow: [
              BoxShadow(
                color: gameTheme.gridLineColor.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(puzzle.gridSize, (r) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(puzzle.gridSize, (c) {
                  final cell = puzzle.grid[r][c];
                  final isSelected = state.selectedRow == r && state.selectedCol == c;
                  
                  bool isInSatisfiedEq = false;
                  for (int eqIdx in state.satisfiedEquations) {
                    if (puzzle.equations[eqIdx].cells.any((p) => p.x == r && p.y == c)) {
                      isInSatisfiedEq = true;
                      break;
                    }
                  }

                  return _buildCell(cell, isSelected, innerCellSize, cellMargin, isInSatisfiedEq);
                }),
              );
            }),
          ),
        ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
      },
    );
  }

  Widget _buildCell(CrossNumbersCell cell, bool isSelected, double size, double margin, bool isInSatisfiedEq) {
    if (cell.type == CrossNumbersCellType.empty) {
      return Padding(
        padding: EdgeInsets.all(margin),
        child: SizedBox(width: size, height: size),
      );
    }

    final theme = Theme.of(context);
    final gameTheme = theme.extension<GameThemeExtension>()!;
    final isOperator = cell.type == CrossNumbersCellType.operator || cell.type == CrossNumbersCellType.equals;
    final isEditable = cell.isUserEditable;
    
    Color bgColor = gameTheme.cellBackground;
    Color textColor = gameTheme.numpadText;
    Color borderColor = gameTheme.gridLineColor;
    
    double fontSize = _getFontSize(cell, isOperator, size);

    if (isOperator) {
      textColor = gameTheme.operatorColor;
      bgColor = Colors.transparent;
      borderColor = Colors.transparent;
    } else if (isEditable) {
      if (cell.userValue.isEmpty) {
        borderColor = gameTheme.gridLineColor.withValues(alpha: 0.2);
        bgColor = gameTheme.numpadBackground.withValues(alpha: 0.3);
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
    
    if (isInSatisfiedEq && !isSelected && !isOperator) {
      borderColor = Colors.green.withValues(alpha: 0.5);
      // bgColor = Colors.green.withValues(alpha: 0.05); // Too subtle?
    }

    return GestureDetector(
      onTap: isEditable ? () {
        HapticManager.instance.selectionClick();
        ref.read(crossNumbersProvider.notifier).selectCell(cell.row, cell.col);
      } : null,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            margin: EdgeInsets.all(margin),
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
                  fontWeight: isOperator ? FontWeight.w900 : FontWeight.w700,
                  fontFamily: 'Monospace',
                ),
              ),
            ),
          ),
          if (isInSatisfiedEq && !isOperator && !isEditable)
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
    );
  }

  double _getFontSize(CrossNumbersCell cell, bool isOperator, double cellSize) {
    double base = cellSize * 0.45;
    if (isOperator) return base;
    String val = cell.isUserEditable ? cell.userValue : cell.value;
    if (val.length > 3) return base * 0.6;
    if (val.length > 2) return base * 0.7;
    if (val.length > 1) return base * 0.8;
    return base * 1.0;
  }

  Widget _buildNumpad(CrossNumbersState state, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: ['1', '2', '3', '4', '5'].map((i) => Expanded(child: _buildNumpadButton(i, state, theme))).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['6', '7', '8', '9', '0'].map((i) => Expanded(child: _buildNumpadButton(i, state, theme))).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNumpadButton('BACK', state, theme, isSpecial: true),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildNumpadButton('CLEAR', state, theme, isClear: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: PremiumAnimatedButton(
                  onPressed: () => _checkManualCompletion(state),
                  backgroundColor: theme.colorScheme.primary,
                  borderColor: theme.colorScheme.primary,
                  padding: EdgeInsets.zero,
                  child: const SizedBox(
                    height: 54,
                    child: Center(
                      child: Text(
                        'SUBMIT',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms),
    );
  }

  Widget _buildNumpadButton(String label, CrossNumbersState state, ThemeData theme, {bool isClear = false, bool isSpecial = false}) {
    final gameTheme = theme.extension<GameThemeExtension>()!;
    return Padding(
      padding: const EdgeInsets.all(3),
      child: PremiumAnimatedButton(
        onPressed: () {
          if (state.selectedRow != null && state.selectedCol != null) {
            HapticManager.instance.lightImpact();
            ref.read(crossNumbersProvider.notifier).updateCell(
              state.selectedRow!,
              state.selectedCol!,
              label,
            );
          }
        },
        padding: EdgeInsets.zero,
        backgroundColor: gameTheme.numpadButtonBackground,
        borderColor: isClear 
            ? Colors.red.withValues(alpha: 0.5)
            : isSpecial
                ? Colors.orange.withValues(alpha: 0.5)
                : gameTheme.gridLineColor,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: label == 'BACK' 
              ? Icon(Icons.backspace_outlined, size: 20, color: gameTheme.numpadText.withValues(alpha: 0.7))
              : Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: isClear ? Colors.redAccent : isSpecial ? Colors.orangeAccent : gameTheme.numpadText,
                    fontSize: 20,
                  ),
                ),
          ),
        ),
      ),
    );
  }

  void _checkManualCompletion(CrossNumbersState state) {
    if (state.isComplete) {
      ref.read(crossNumbersProvider.notifier).submitQuestion();
      if (ref.read(crossNumbersProvider).isLevelFinished) {
        _onLevelFinished();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Correct! Next Question: ${ref.read(crossNumbersProvider).currentQuestionIndex}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Some numbers are missing or incorrect!'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => PremiumGlassOverlay(
        borderRadius: 24,
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Quit Game?'),
          content: const Text('Your progress for this level will be lost.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('QUIT', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          ],
        ),
      ),
    );
  }

  void _onLevelFinished() {
    _timer?.cancel();
    final state = ref.read(crossNumbersProvider);
    final correct = state.correctQuestions;
    final total = state.totalQuestions;
    
    bool passed = correct >= 5; // User requirement: 5+ to open new levels
    
    int stars = 0;
    if (passed) {
      double ratio = correct / total;
      if (ratio >= 1.0) {
        stars = 3;
      } else if (ratio >= 0.8) {
        stars = 2;
      } else {
        stars = 1;
      }
    }

    final score = correct * 50 + (stars * 100);
    
    if (passed) {
      ref.read(levelProgressProvider.notifier).updateProgress(
        'cross_numbers',
        widget.difficulty,
        stars,
        score,
      );
      // Unlock next level if not already unlocked
      ref.read(levelProgressProvider.notifier).unlockNextLevel('cross_numbers', widget.difficulty + 1);
    }

    ref.read(userSessionProvider.notifier).addPoints(score);
    _showLevelSummary(passed, stars, score, correct, total);
  }

  void _showLevelSummary(bool passed, int stars, int score, int correct, int total) {
    final l10n = AppLocalizations.of(context)!;
    if (passed) {
      HapticManager.instance.successPattern();
      ref.read(soundManagerProvider).playComplete();
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessDialog(
        title: passed ? l10n.excellent : 'Level Failed',
        message: passed 
          ? 'You solved $correct/$total questions!\nEarned $score points.'
          : 'You only got $correct/$total questions.\nYou need at least 5 to pass.',
        stars: stars,
        isSuccess: passed,
        onDone: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }
}
