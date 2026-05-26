import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/sound_manager.dart';

class CrosswordScreen extends ConsumerStatefulWidget {
  final String theme;
  final bool isChallengeMode;
  final int? timeLimit;
  final int level;
  final String operationId;

  const CrosswordScreen({
    super.key,
    this.theme = 'animals',
    this.isChallengeMode = false,
    this.timeLimit,
    this.level = 1,
    this.operationId = 'crossword',
  });

  @override
  ConsumerState<CrosswordScreen> createState() => _CrosswordScreenState();
}

class _CrosswordScreenState extends ConsumerState<CrosswordScreen> with SingleTickerProviderStateMixin {
  final _focusNode = FocusNode();
  final _textController = TextEditingController();
  int _selectedRow = -1;
  int _selectedCol = -1;
  String _currentDirection = 'across';
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(crosswordPuzzleProvider.notifier)
          .loadPuzzle(theme: widget.theme, difficulty: widget.level);
      if (widget.isChallengeMode && widget.timeLimit != null) {
        ref
            .read(challengeModeProvider.notifier)
            .startChallenge(timeLimit: widget.timeLimit!);
      }
    });
  }

  void _triggerShake() {
    HapticManager.errorPattern();
    _shakeController.forward(from: 0);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final puzzleState = ref.watch(crosswordPuzzleProvider);
    final puzzle = puzzleState.puzzle;

    if (puzzle == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary, strokeWidth: 1),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        foregroundColor: theme.colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () {
            HapticManager.selectionClick();
            Navigator.pop(context);
          },
        ),
        title: Text('CROSSWORD - ${widget.theme.toUpperCase()}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                _formatTime(puzzleState.elapsedSeconds),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w200,
                  color: theme.brightness == Brightness.light
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                      : Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value * sin(_shakeAnimation.value * pi * 4), 0),
                      child: child,
                    );
                  },
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildGrid(context, puzzle),
                      const SizedBox(height: 32),
                      _buildCluesList(context, puzzle),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            _buildKeyboard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, dynamic puzzle) {
    final theme = Theme.of(context);
    final state = ref.watch(crosswordPuzzleProvider);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.brightness == Brightness.light
                ? theme.colorScheme.outline.withValues(alpha: 0.3)
                : Colors.white10,
            width: 0.5,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(puzzle.gridSize, (row) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(puzzle.gridSize, (col) {
                  final isBlocked = puzzle.isBlocked[row][col];
                  final cellData =
                      state.grid.length > row && state.grid[row].length > col
                      ? state.grid[row][col]
                      : null;
                  final isSelected = cellData?.isSelected ?? false;
                  final isCorrect = cellData?.isCorrect ?? false;
                  final isRevealed = cellData?.isRevealed ?? false;
                  final userLetter = cellData?.userLetter;

                  return GestureDetector(
                    onTap: isBlocked
                        ? null
                        : () {
                            HapticManager.selectionClick();
                            _selectCell(row, col);
                          },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isBlocked
                            ? (theme.brightness == Brightness.light ? theme.colorScheme.surface : Colors.black)
                            : isSelected
                            ? (theme.brightness == Brightness.light ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.1))
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? (theme.brightness == Brightness.light ? theme.colorScheme.primary.withValues(alpha: 0.5) : Colors.white54)
                              : (theme.brightness == Brightness.light ? theme.colorScheme.outline.withValues(alpha: 0.3) : Colors.white10),
                          width: 0.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          userLetter ?? '',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            color: theme.brightness == Brightness.light
                                ? (isRevealed || isCorrect ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.7))
                                : (isRevealed || isCorrect ? Colors.white : Colors.white70),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildCluesList(BuildContext context, dynamic puzzle) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACROSS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
            color: theme.brightness == Brightness.light
                ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                : Colors.white54,
          ),
        ),
        const SizedBox(height: 16),
        ...puzzle.acrossClues.map<Widget>((clue) => _buildClueItem(clue)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Divider(
            color: theme.brightness == Brightness.light
                ? theme.colorScheme.outline.withValues(alpha: 0.3)
                : Colors.white10,
            thickness: 0.5,
          ),
        ),
        const Text(
          'DOWN',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 16),
        ...puzzle.downClues.map<Widget>((clue) => _buildClueItem(clue)),
      ],
    );
  }

  Widget _buildClueItem(dynamic clue) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        HapticManager.selectionClick();
        _selectClue(clue);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 30,
              child: Text(
                '${clue.number}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w200,
                  color: theme.brightness == Brightness.light
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                      : Colors.white38,
                ),
              ),
            ),
            Expanded(
              child: Text(
                clue.clue,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w200,
                  color: theme.brightness == Brightness.light
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                      : Colors.white70,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboard(BuildContext context) {
    final theme = Theme.of(context);
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    final user = ref.watch(userSessionProvider);
    final canUseHint = (user?.totalPoints ?? 0) >= hintCostPoints;

    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? theme.colorScheme.surface
            : const Color(0xFF151519),
        border: Border(
          top: BorderSide(
            color: theme.brightness == Brightness.light
                ? theme.colorScheme.outline.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Row(
              children: [
                _buildModeChip(
                  label: 'ACROSS',
                  selected: _currentDirection == 'across',
                  onTap: () => setState(() => _currentDirection = 'across'),
                ),
                const SizedBox(width: 8),
                _buildModeChip(
                  label: 'DOWN',
                  selected: _currentDirection == 'down',
                  onTap: () => setState(() => _currentDirection = 'down'),
                ),
                const Spacer(),
                Text(
                  'Hint $hintCostPoints pts',
                  style: TextStyle(
                    color: theme.brightness == Brightness.light
                        ? (canUseHint ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.4))
                        : (canUseHint ? Colors.white70 : Colors.white38),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _buildKeyboardRow(letters.take(10).toList()),
          _buildKeyboardRow(letters.skip(10).take(9).toList()),
          _buildKeyboardRowWithSpecial(
            letters.skip(19).take(7).toList(),
            canUseHint: canUseHint,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    return Row(children: keys.map((key) => _buildKey(key)).toList());
  }

  Widget _buildKeyboardRowWithSpecial(List<String> keys, {required bool canUseHint}) {
    return Row(
      children: [
        _buildSpecialKey(Icons.backspace_outlined, () {
          HapticManager.lightImpact();
          if (_selectedRow >= 0 && _selectedCol >= 0) {
            ref
                .read(crosswordPuzzleProvider.notifier)
                .enterLetter('', _selectedRow, _selectedCol);
          }
        }),
        ...keys.map((key) => _buildKey(key)),
        _buildSpecialKey(
          Icons.lightbulb_outline,
          () {
          HapticManager.mediumImpact();
          final user = ref.read(userSessionProvider);
          if (user != null && user.totalPoints >= hintCostPoints) {
            ref.read(crosswordPuzzleProvider.notifier).revealLetter();
          } else {
            _triggerShake();
          }
          },
          enabled: canUseHint,
        ),
      ],
    );
  }

  Widget _buildKey(String letter) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticManager.lightImpact();
          _onLetterPressed(letter);
        },
        child: Container(
          height: 45,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: theme.brightness == Brightness.light
                  ? [theme.colorScheme.primary.withValues(alpha: 0.08), theme.colorScheme.primary.withValues(alpha: 0.03)]
                  : [Colors.white.withValues(alpha: 0.08), Colors.white.withValues(alpha: 0.03)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: theme.brightness == Brightness.light
                  ? theme.colorScheme.primary.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.12),
              width: 0.7,
            ),
          ),
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w200,
                color: theme.brightness == Brightness.light
                    ? theme.colorScheme.primary
                    : Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey(IconData icon, VoidCallback onTap, {bool enabled = true}) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Container(
          height: 45,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: theme.brightness == Brightness.light
                  ? [
                      theme.colorScheme.primary.withValues(alpha: enabled ? 0.12 : 0.04),
                      theme.colorScheme.primary.withValues(alpha: enabled ? 0.05 : 0.02),
                    ]
                  : [
                      Colors.white.withValues(alpha: enabled ? 0.12 : 0.04),
                      Colors.white.withValues(alpha: enabled ? 0.05 : 0.02),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: theme.brightness == Brightness.light
                  ? theme.colorScheme.primary.withValues(alpha: enabled ? 0.2 : 0.1)
                  : Colors.white.withValues(alpha: enabled ? 0.16 : 0.06),
              width: 0.7,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 18,
              color: theme.brightness == Brightness.light
                  ? (enabled ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.3))
                  : (enabled ? Colors.white70 : Colors.white30),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected
              ? (theme.brightness == Brightness.light ? theme.colorScheme.primary.withValues(alpha: 0.16) : Colors.white.withValues(alpha: 0.16))
              : (theme.brightness == Brightness.light ? theme.colorScheme.surface.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.04)),
          border: Border.all(
            color: theme.brightness == Brightness.light
                ? theme.colorScheme.primary.withValues(alpha: selected ? 0.3 : 0.1)
                : Colors.white.withValues(alpha: selected ? 0.28 : 0.08),
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? (theme.brightness == Brightness.light ? theme.colorScheme.onPrimary : Colors.white)
                : (theme.brightness == Brightness.light ? theme.colorScheme.onSurface.withValues(alpha: 0.6) : Colors.white60),
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _selectCell(int row, int col) {
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });
    ref.read(crosswordPuzzleProvider.notifier).selectCell(row, col);
  }

  void _selectClue(dynamic clue) {
    setState(() {
      _selectedRow = clue.startRow - 1;
      _selectedCol = clue.startCol - 1;
      _currentDirection = clue.direction;
    });
  }

  void _onLetterPressed(String letter) {
    if (_selectedRow >= 0 && _selectedCol >= 0) {
      ref
          .read(crosswordPuzzleProvider.notifier)
          .enterLetter(letter, _selectedRow, _selectedCol);

      final state = ref.read(crosswordPuzzleProvider);
      if (state.isComplete) {
        _showSuccess(state);
      } else {
        _moveToNextCell();
      }
    }
  }

  void _showSuccess(CrosswordPuzzleState state) {
    final stars = state.stars;

    ref
        .read(levelProgressRepositoryProvider)
        .updateStars(
          widget.operationId,
          widget.level,
          stars,
          stars * 200, // Score
        )
        .then((_) {
          ref.read(levelProgressProvider.notifier).loadProgress();
          // Update Daily Challenge
          if (stars > 0) {
            ref.read(dailyChallengeProvider.notifier).incrementProgress('stars', stars);
          }
        });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.white10, width: 0.5),
        ),
        title: const Center(
          child: Text(
            'PUZZLE SOLVED',
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 4,
              fontWeight: FontWeight.w100,
              fontSize: 18,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Icon(
                  Icons.star,
                  size: 32,
                  color: i < stars ? Colors.white : Colors.white12,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Time: ${_formatTime(state.elapsedSeconds)}',
              style: const TextStyle(
                color: Colors.white60,
                fontWeight: FontWeight.w200,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'BACK TO LEVELS',
              style: TextStyle(
                color: Colors.white38,
                fontWeight: FontWeight.w200,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      CrosswordScreen(
                        theme: widget.theme,
                        level: widget.level + 1,
                        operationId: widget.operationId,
                      ),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                ),
              );
            },
            child: const Text(
              'NEXT LEVEL',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _moveToNextCell() {
    if (_currentDirection == 'across') {
      if (_selectedCol <
          ref.read(crosswordPuzzleProvider).puzzle!.gridSize - 1) {
        _selectedCol++;
      }
    } else {
      if (_selectedRow <
          ref.read(crosswordPuzzleProvider).puzzle!.gridSize - 1) {
        _selectedRow++;
      }
    }
    ref
        .read(crosswordPuzzleProvider.notifier)
        .selectCell(_selectedRow, _selectedCol);
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
