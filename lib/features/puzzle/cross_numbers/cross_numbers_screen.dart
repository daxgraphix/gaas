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
        ref.read(crossNumbersProvider.notifier).initPuzzle(widget.difficulty);
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
      builder: (context) => AlertDialog(
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
    );
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
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => _showExitDialog(),
        ),
        title: Column(
          children: [
            Text(
              'LEVEL ${widget.difficulty}',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            PuzzleTimer(remainingSeconds: puzzleState.elapsedSeconds),
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
                  child: _buildGrid(puzzleState),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(puzzle.gridSize, (r) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(puzzle.gridSize, (c) {
              final cell = puzzle.grid[r][c];
              return _buildCell(cell, state.selectedRow == r && state.selectedCol == c);
            }),
          );
        }),
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildCell(CrossNumbersCell cell, bool isSelected) {
    final theme = Theme.of(context);
    
    if (cell.type == CrossNumbersCellType.empty) {
      return const SizedBox(width: 44, height: 44);
    }

    bool isOperator = cell.type == CrossNumbersCellType.operator;
    bool isResult = cell.type == CrossNumbersCellType.result;
    
    Color bgColor = theme.colorScheme.surface;
    Color textColor = theme.colorScheme.onSurface;
    double elevation = 0;
    
    if (cell.isUserEditable) {
      if (isSelected) {
        bgColor = theme.colorScheme.primaryContainer;
        textColor = theme.colorScheme.onPrimaryContainer;
        elevation = 4;
      } else if (cell.isRevealed) {
        bgColor = Colors.amber.withValues(alpha: 0.1);
        textColor = Colors.amber.shade800;
      }
    } else {
      if (isResult) {
        bgColor = theme.colorScheme.primary.withValues(alpha: 0.1);
        textColor = theme.colorScheme.primary;
      } else {
        bgColor = isOperator ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : theme.colorScheme.surfaceContainerHighest;
        textColor = isOperator ? theme.colorScheme.primary : theme.colorScheme.onSurface;
      }
    }

    return GestureDetector(
      onTap: cell.isUserEditable ? () {
        HapticManager.instance.selectionClick();
        ref.read(crossNumbersProvider.notifier).selectCell(cell.row, cell.col);
      } : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline.withValues(alpha: isSelected ? 1 : 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: elevation > 0 ? [
            BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))
          ] : null,
        ),
        child: Center(
          child: Text(
            cell.isUserEditable ? cell.userValue : cell.value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: cell.isUserEditable ? FontWeight.w300 : FontWeight.w900,
              color: textColor,
              fontSize: isOperator ? 18 : 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad(CrossNumbersState state, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Row(
            children: [1, 2, 3, 4, 5].map((i) => Expanded(child: _buildNumpadButton(i.toString(), state, theme))).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [6, 7, 8, 9, 0].map((i) => Expanded(child: _buildNumpadButton(i.toString(), state, theme))).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildNumpadButton('CLEAR', state, theme, isClear: true),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: PremiumPrimaryButton(
                  onPressed: () => _checkManualCompletion(state),
                  text: 'SUBMIT',
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
            ],
          ),
        ],
      ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms),
    );
  }

  Widget _buildNumpadButton(String label, CrossNumbersState state, ThemeData theme, {bool isClear = false}) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: InkWell(
        onTap: () {
          if (state.selectedRow != null && state.selectedCol != null) {
            HapticManager.instance.lightImpact();
            ref.read(crossNumbersProvider.notifier).updateCell(
              state.selectedRow!,
              state.selectedCol!,
              isClear ? '' : label,
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isClear ? theme.colorScheme.error.withValues(alpha: 0.05) : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isClear 
                  ? theme.colorScheme.error.withValues(alpha: 0.2)
                  : theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: isClear ? theme.colorScheme.error : theme.colorScheme.onSurface,
                fontSize: isClear ? 12 : 18,
                letterSpacing: isClear ? 1 : 0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _checkManualCompletion(CrossNumbersState state) {
    if (state.isComplete) {
      _onComplete();
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
      builder: (context) => AlertDialog(
        title: const Text('Quit Game?'),
        content: const Text('Your progress for this level will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('QUIT', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _onComplete() {
    _timer?.cancel();
    final timeTaken = ref.read(crossNumbersProvider).elapsedSeconds;
    int stars = 1;
    if (timeTaken < 60) {
      stars = 3;
    } else if (timeTaken < 120) {
      stars = 2;
    }

    final score = widget.difficulty * 100 + (stars * 50);
    ref.read(levelProgressProvider.notifier).updateProgress(
      'cross_numbers',
      widget.difficulty,
      stars,
      score,
    );
    ref.read(userSessionProvider.notifier).addPoints(score);
    _showSuccess(stars, score);
  }

  void _showSuccess(int stars, int score) {
    final l10n = AppLocalizations.of(context)!;
    HapticManager.instance.successPattern();
    ref.read(soundManagerProvider).playComplete();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessDialog(
        title: l10n.excellent,
        message: 'You solved Level ${widget.difficulty}!\nEarned $score points.',
        stars: stars,
        onDone: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }
}
