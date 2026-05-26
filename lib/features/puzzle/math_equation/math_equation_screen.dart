import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sound_manager.dart';
import '../../../core/math_engine/math_equation_engine.dart';
import '../../../data/models/crossword_puzzle.dart';

class MathEquationScreen extends ConsumerStatefulWidget {
  final String theme;
  final bool isChallengeMode;
  final int? timeLimit;
  final int level;
  final String operationId;

  const MathEquationScreen({
    super.key,
    this.theme = 'equations',
    this.isChallengeMode = false,
    this.timeLimit,
    this.level = 1,
    this.operationId = 'equations',
  });

  @override
  ConsumerState<MathEquationScreen> createState() => _MathEquationScreenState();
}

class _MathEquationScreenState extends ConsumerState<MathEquationScreen> with TickerProviderStateMixin {
  late MathEquationPuzzle _puzzle;
  final Map<int, String> _userAnswers = {};
  int _selectedEquation = -1;
  int _elapsedSeconds = 0;
  int _hintsUsed = 0;
  late AnimationController _timerController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _puzzle = MathEquationEngine.generatePuzzle(
      theme: widget.theme,
      difficulty: widget.level,
    );

    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _puzzle.timeLimit),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    if (!widget.isChallengeMode) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timerController.forward().whenComplete(() {
      _endGame();
    });

    _timerController.addListener(() {
      setState(() {
        _elapsedSeconds = (_timerController.value * _puzzle.timeLimit).toInt();
      });
    });
  }

  @override
  void dispose() {
    _timerController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _selectEquation(int index) {
    setState(() {
      _selectedEquation = index;
    });
  }

  void _enterNumber(int number) {
    if (_selectedEquation == -1) return;

    setState(() {
      final currentAnswer = _userAnswers[_selectedEquation] ?? '';
      _userAnswers[_selectedEquation] = currentAnswer + number.toString();
    });

    // Auto-submit if answer length exceeds reasonable limit
    final currentAnswer = _userAnswers[_selectedEquation] ?? '';
    if (currentAnswer.length > 6) {
      _checkCompletion();
    }
  }

  void _checkCompletion() {
    final answeredCount = _userAnswers.values.where((answer) => answer.isNotEmpty).length;
    if (answeredCount == _puzzle.equations.length) {
      bool allCorrect = true;
      for (int i = 0; i < _puzzle.equations.length; i++) {
        final userAnswerStr = _userAnswers[i];
        if (userAnswerStr == null || userAnswerStr.isEmpty) {
          allCorrect = false;
          break;
        }
        final userAnswer = int.tryParse(userAnswerStr);
        if (userAnswer == null || !_puzzle.equations[i].isCorrectWithAnswer(userAnswer)) {
          allCorrect = false;
          break;
        }
      }

      if (allCorrect) {
        _endGame();
      } else {
        _shakeController.forward(from: 0);
        HapticManager.errorPattern();
      }
    }
  }

  void _endGame() {
    final stars = _puzzle.calculateStars(_elapsedSeconds, _hintsUsed);

    Navigator.of(context).pop({
      'stars': stars,
      'time': _elapsedSeconds,
      'hints': _hintsUsed,
      'completed': _puzzle.isComplete,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('MATH EQUATIONS - LVL ${widget.level}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _userAnswers.values.where((answer) => answer.isNotEmpty).length / _puzzle.equations.length,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              '${_userAnswers.values.where((answer) => answer.isNotEmpty).length}/${_puzzle.equations.length}',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          if (!widget.isChallengeMode)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_puzzle.timeLimit - _elapsedSeconds}s',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/carbon-fibre.png',
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _buildEquationsList(theme),
                ),
                _buildNumberKeypad(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquationsList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _puzzle.equations.length,
      itemBuilder: (context, index) {
        final equation = _puzzle.equations[index];
        final userAnswerStr = _userAnswers[index];
        final isSelected = _selectedEquation == index;
        final isAnswered = userAnswerStr != null && userAnswerStr.isNotEmpty;
        final userAnswer = isAnswered ? int.tryParse(userAnswerStr) : null;
        final isCorrect = userAnswer != null && equation.isCorrectWithAnswer(userAnswer);

        return AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: isSelected ? Offset(_shakeAnimation.value, 0) : Offset.zero,
              child: GestureDetector(
                onTap: () => _selectEquation(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.08)
                        : isAnswered
                            ? (isCorrect ? Colors.green.withValues(alpha: 0.08) : Colors.red.withValues(alpha: 0.08))
                            : theme.colorScheme.surface,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.8)
                          : isAnswered
                              ? (isCorrect ? Colors.green.withValues(alpha: 0.6) : Colors.red.withValues(alpha: 0.6))
                              : theme.colorScheme.outline.withValues(alpha: 0.2),
                      width: isSelected ? 2 : 1.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        )
                      else if (isAnswered && isCorrect)
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        )
                      else if (isAnswered && !isCorrect)
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                    ],
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withValues(alpha: 0.05),
                              theme.colorScheme.primary.withValues(alpha: 0.02),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                         Container(
                           padding: const EdgeInsets.all(20),
                           decoration: BoxDecoration(
                             color: theme.colorScheme.surface.withValues(alpha: 0.6),
                             borderRadius: BorderRadius.circular(16),
                             border: Border.all(
                               color: theme.colorScheme.outline.withValues(alpha: 0.2),
                             ),
                             boxShadow: [
                               BoxShadow(
                                 color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                                 blurRadius: 6,
                                 offset: const Offset(0, 2),
                               ),
                             ],
                           ),
                           child: Row(
                             children: [
                               Expanded(
                                 child: FittedBox(
                                   fit: BoxFit.scaleDown,
                                   alignment: Alignment.center,
                                   child: Text(
                                     equation.displayEquation,
                                     style: TextStyle(
                                       fontSize: 36,
                                       fontFamily: 'monospace',
                                       color: theme.colorScheme.onSurface,
                                       fontWeight: FontWeight.w800,
                                       letterSpacing: 2,
                                       height: 1.2,
                                     ),
                                   ),
                                 ),
                               ),
                             ],
                           ),
                         ),
                      if (isAnswered) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? Colors.green.withValues(alpha: 0.15)
                                : Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isCorrect ? Colors.green.withValues(alpha: 0.4) : Colors.red.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                userAnswerStr,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'monospace',
                                  color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isCorrect ? Icons.check_circle : Icons.cancel,
                                size: 18,
                                color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (isSelected && _hintsUsed < equation.hints.length) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lightbulb,
                                color: theme.colorScheme.secondary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  equation.hints[_hintsUsed],
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _hintsUsed < equation.hints.length - 1 ? () {
                                  setState(() => _hintsUsed++);
                                } : null,
                                icon: const Icon(Icons.navigate_next, size: 16),
                                label: Text(_hintsUsed < equation.hints.length - 1 ? 'NEXT' : 'LAST'),
                                style: TextButton.styleFrom(
                                  foregroundColor: theme.colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNumberKeypad(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Number pad 1-5 with better spacing
          Row(
            children: [
              for (int i = 1; i <= 5; i++) ...[
                Expanded(child: _buildKeypadButton(i.toString(), i, theme)),
                if (i < 5) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Number pad 6-0 with better spacing
          Row(
            children: [
              for (int i = 6; i <= 9; i++) ...[
                Expanded(child: _buildKeypadButton(i.toString(), i, theme)),
                if (i < 9) const SizedBox(width: 8),
              ],
              const SizedBox(width: 8),
              Expanded(child: _buildKeypadButton('0', 0, theme)),
            ],
          ),
          const SizedBox(height: 16),
          // Control buttons with enhanced layout
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildKeypadButton('DEL', -1, theme, isControl: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _buildKeypadButton('CLR', -2, theme, isControl: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _buildKeypadButton('✓', -3, theme, isControl: true, isSubmit: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String label, int value, ThemeData theme, {bool isControl = false, bool isSubmit = false}) {
    return InkWell(
        onTap: () {
          if (value == -1) {
            // Delete last digit
            if (_selectedEquation != -1) {
              setState(() {
                final currentAnswer = _userAnswers[_selectedEquation] ?? '';
                if (currentAnswer.isNotEmpty) {
                  _userAnswers[_selectedEquation] = currentAnswer.substring(0, currentAnswer.length - 1);
                }
              });
            }
          } else if (value == -2) {
            // Clear all
            setState(() {
              _userAnswers.clear();
              _selectedEquation = -1;
            });
          } else if (value == -3) {
            // Submit
            _checkCompletion();
          } else {
            _enterNumber(value);
          }
          HapticManager.selectionClick();
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 50,
          decoration: BoxDecoration(
            color: isSubmit
                ? theme.colorScheme.primary
                : isControl
                    ? theme.colorScheme.secondary.withValues(alpha: 0.15)
                    : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSubmit
                  ? theme.colorScheme.primary.withValues(alpha: 0.6)
                  : isControl
                      ? theme.colorScheme.secondary.withValues(alpha: 0.4)
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: isSubmit ? [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ] : !isControl && !isSubmit ? [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ] : null,
            gradient: !isControl && !isSubmit ? LinearGradient(
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surface.withValues(alpha: 0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ) : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSubmit
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.9),
                fontSize: isControl ? 14 : 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
    );
  }
}