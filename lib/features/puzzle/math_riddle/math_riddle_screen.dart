import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'dart:math';
import '../../../core/providers.dart';
import '../../../core/sound_manager.dart';
import '../../../core/utils/game_flow_optimizer.dart';
import '../../../core/game_adaptability/dynamic_difficulty_system.dart';
import '../../../core/themes/app_themes.dart';
import '../../../data/models/math_riddle.dart';
import '../../../shared/widgets/puzzle_widgets.dart';

class MathRiddleScreen extends ConsumerStatefulWidget {
  final MathRiddleType riddleType;
  final int difficulty;
  final String? operationId;

  const MathRiddleScreen({
    super.key,
    required this.riddleType,
    this.difficulty = 1,
    this.operationId,
  });

  @override
  ConsumerState<MathRiddleScreen> createState() => _MathRiddleScreenState();
}

class _MathRiddleScreenState extends ConsumerState<MathRiddleScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _answerController = TextEditingController();
  Timer? _timer;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPuzzle());
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      ref.read(mathRiddleProvider.notifier).incrementTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _loadPuzzle() {
    _answerController.clear();
    switch (widget.riddleType) {
      case MathRiddleType.arithmetic:
        ref.read(mathRiddleProvider.notifier).loadArithmeticProblem(widget.difficulty);
        break;
      case MathRiddleType.logicChallenge:
        ref.read(mathRiddleProvider.notifier).loadLogicChallenge(widget.difficulty);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(mathRiddleProvider);

    // Check if level is complete (after answering last question)
    if (state.isAnswered && state.questionIndex >= state.totalQuestions) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLevelComplete(state, theme, l10n);
      });
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, size: 20),
          tooltip: 'Close',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('${l10n.level} ${state.level}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, size: 20),
            tooltip: 'Home',
            onPressed: () {
              HapticManager.instance.selectionClick();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                '${state.questionIndex}/${state.totalQuestions}',
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: state.levelProgress,
            backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildPerformanceFeedback(state, theme),
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value * sin(_shakeAnimation.value * pi * 4), 0),
                    child: child,
                  );
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildPuzzleContent(state, theme),
                ),
              ),
            ),
          ),
          _buildNumpad(state),
        ],
      ),
    );
  }

  Widget _buildPerformanceFeedback(MathRiddleState state, ThemeData theme) {
    if (state.questionIndex <= 1) return const SizedBox.shrink();

    final accuracy = state.questionIndex > 1
        ? state.correctAnswers / (state.questionIndex - 1)
        : 0.0;

    final message = GameDynamicsController.getEncouragementMessage(
      accuracy: accuracy,
      streak: state.currentStreak,
      totalQuestions: state.questionIndex - 1,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ).animate(key: ValueKey(message)).fadeIn().slideY(begin: -0.2, end: 0),
    );
  }

  Widget _buildPuzzleContent(MathRiddleState state, ThemeData theme) {
    if (state.currentLogic == null && state.currentRiddle == null) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
          strokeWidth: 1,
        ),
      );
    }

    if (state.currentLogic != null) {
      return _buildVisualLogic(state.currentLogic!.problem, theme);
    }

    String question = '';
    if (state.currentRiddle != null) question = state.currentRiddle!.question;

    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = (screenWidth * 0.08).clamp(24.0, 36.0);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: screenWidth * 0.9,
      ),
      child: Text(
        question,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w200,
          color: theme.colorScheme.onSurface,
          letterSpacing: 2,
        ),
        textAlign: TextAlign.center,
        softWrap: true,
      ).animate().fadeIn(duration: 600.ms),
    );
  }

  Widget _buildVisualLogic(String problem, ThemeData theme) {
    final lines = problem.split('\n');
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: lines.map((line) => _buildLogicLine(line, theme)).toList(),
      ),
    );
  }

  Widget _buildLogicLine(String line, ThemeData theme) {
    final parts = line.split(' ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: parts.map((part) {
            final screenWidth = MediaQuery.of(context).size.width;
            final symbolFontSize = (screenWidth * 0.07).clamp(20.0, 32.0);

            if (part == '+' || part == '=' || part == '?') {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  part,
                  style: TextStyle(
                    fontSize: symbolFontSize,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w200,
                  ),
                ),
              );
            } else if (int.tryParse(part) != null) {
              return Text(
                part,
                style: TextStyle(
                  fontSize: symbolFontSize,
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w200,
                ),
              );
            } else {
              return _getShapeWidget(part.toLowerCase(), theme);
            }
          }).toList(),
        ),
      ),
    );
  }

  Widget _getShapeWidget(String shape, ThemeData theme) {
    double size = 32;
    Widget icon;
    if (shape.contains('square') || shape.contains('box')) {
      icon = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), width: 1),
        ),
      );
    } else if (shape.contains('circle')) {
      icon = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), width: 1),
        ),
      );
    } else if (shape.contains('triangle')) {
      icon = CustomPaint(
        size: Size(size, size),
        painter: TrianglePainter(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
      );
    } else if (shape.contains('star')) {
      icon = CustomPaint(
        size: Size(size, size),
        painter: StarPainter(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
      );
    } else {
      icon = Text(shape, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3)));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: icon,
    );
  }

  Widget _buildNumpad(MathRiddleState state) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          _buildInputBar(state, theme),
          _buildGrid(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInputBar(MathRiddleState state, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 72,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.skip_next,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              size: 20,
            ),
            tooltip: 'Skip',
            onPressed: state.isAnswered || state.questionIndex >= state.totalQuestions
                ? null
                : () {
                    HapticManager.instance.selectionClick();
                    ref.read(mathRiddleProvider.notifier).skipQuestion(state.level);
                  },
          ),
          IconButton(
            icon: Icon(
              Icons.replay,
              color: state.questionIndex > 1 ? theme.colorScheme.onSurface.withValues(alpha: 0.5) : theme.colorScheme.onSurface.withValues(alpha: 0.1),
              size: 20,
            ),
            tooltip: 'Previous',
            onPressed: state.questionIndex > 1
                ? () {
                    HapticManager.instance.selectionClick();
                    ref.read(mathRiddleProvider.notifier).previousQuestion();
                  }
                : null,
          ),
          Expanded(
            flex: 3,
            child: GlassmorphicContainer(
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              margin: const EdgeInsets.symmetric(vertical: 8),
              backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              opacity: 0.1,
              child: Center(
                child: TextField(
                  controller: _answerController,
                  readOnly: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                  decoration: InputDecoration(
                    hintText: '?',
                    hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              HapticManager.instance.lightImpact();
              if (_answerController.text.isNotEmpty) {
                _answerController.text = _answerController.text.substring(
                  0,
                  _answerController.text.length - 1,
                );
                ref.read(mathRiddleProvider.notifier).selectAnswer(_answerController.text);
              }
            },
            icon: Icon(Icons.backspace_outlined, color: theme.colorScheme.onSurface.withValues(alpha: 0.5), size: 20),
          ),
          IconButton(
            onPressed: () {
              HapticManager.instance.selectionClick();
              _revealAnswer();
            },
            icon: Icon(
              Icons.lightbulb_outline,
              color: Colors.amber.withValues(alpha: 0.7),
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          PremiumAnimatedButton(
            onPressed: () {
              HapticManager.instance.mediumImpact();
              if (_answerController.text.isNotEmpty) {
                final previousCorrect = state.correctAnswers;
                ref.read(mathRiddleProvider.notifier).submitAnswer();
                final newState = ref.read(mathRiddleProvider);
                
                if (newState.isCorrect || newState.correctAnswers > previousCorrect) {
                   // Add dynamic score
                   final difficultyLevel = DifficultyLevel.values[((widget.difficulty - 1) ~/ 10).clamp(0, 2)];
                   final points = GameDynamicsController.calculateDynamicScore(
                     isCorrect: true,
                     basePoints: state.currentRiddle?.basePoints ?? 10,
                     currentStreak: newState.currentStreak,
                     responseTime: state.timeSpentSeconds * 1000.0,
                     difficulty: difficultyLevel,
                   );
                   ref.read(userSessionProvider.notifier).addPoints(points);
                } else {
                  _showIncorrectFeedback();
                }
                _answerController.clear();
              }
            },
            backgroundColor: theme.colorScheme.primary,
            borderColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            borderRadius: 12,
            child: Text(
              'ENTER',
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final theme = Theme.of(context);
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 1.2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          return PremiumAnimatedButton(
            onPressed: () {
              HapticManager.instance.lightImpact();
              if (_answerController.text.length < 6) {
                _answerController.text += keys[index];
                ref.read(mathRiddleProvider.notifier).selectAnswer(_answerController.text);
              }
            },
            backgroundColor: theme.colorScheme.surface,
            borderColor: theme.colorScheme.outline.withValues(alpha: 0.1),
            padding: EdgeInsets.zero,
            borderRadius: 12,
            child: Center(
              child: Text(
                keys[index],
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _revealAnswer() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = ref.read(mathRiddleProvider);
    if (state.currentRiddle == null && state.currentLogic == null) return;

    String correctAnswer = '';
    if (state.currentRiddle != null) {
      correctAnswer = state.currentRiddle!.correctAnswer;
    } else if (state.currentLogic != null) {
      correctAnswer = state.currentLogic!.correctAnswer;
    }

    _answerController.text = correctAnswer;
    ref.read(mathRiddleProvider.notifier).selectAnswer(correctAnswer);

    HapticManager.instance.mediumImpact();
    ref.read(soundManagerProvider).playEffect('hint');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.answerRevealed),
        duration: const Duration(seconds: 1),
        backgroundColor: theme.colorScheme.secondary,
      ),
    );
  }

  void _showLevelComplete(MathRiddleState state, ThemeData theme, AppLocalizations l10n) {
    final passed = state.levelPassed;
    final correctAnswers = state.correctAnswers;
    final totalQuestions = state.totalQuestions;

    if (passed && widget.operationId != null) {
      ref.read(levelProgressProvider.notifier).unlockNextLevel(widget.operationId!, state.level);
    }

    if (passed) {
      ref.read(soundManagerProvider).playComplete();
      HapticManager.instance.successPattern();
    } else {
      ref.read(soundManagerProvider).playWrongAnswer();
      HapticManager.instance.wrongAnswerPattern();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessDialog(
        title: passed ? 'LEVEL COMPLETE' : 'NOT PASSED',
        message: passed 
            ? '$correctAnswers/$totalQuestions correct\nNext level unlocked!'
            : '$correctAnswers/$totalQuestions correct\nNeed 35+ correct to pass',
        stars: passed ? (correctAnswers >= totalQuestions ? 3 : (correctAnswers >= totalQuestions * 0.8 ? 2 : 1)) : 0,
        isSuccess: passed,
        primaryButtonText: passed ? 'NEXT LEVEL' : 'TRY AGAIN',
        secondaryButtonText: 'BACK',
        onSecondaryAction: () {
          Navigator.pop(context);
          Navigator.pop(context);
          ref.read(mathRiddleProvider.notifier).reset();
        },
        onDone: () {
          if (passed) {
            Navigator.pop(context);
            ref.read(mathRiddleProvider.notifier).reset();
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    MathRiddleScreen(
                      riddleType: widget.riddleType,
                      difficulty: widget.difficulty + 1,
                      operationId: widget.operationId,
                    ),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          } else {
            Navigator.pop(context);
            _loadPuzzle();
          }
        },
      ),
    );
  }

  void _showIncorrectFeedback() {
    ref.read(soundManagerProvider).playWrongAnswer();
    HapticManager.instance.wrongAnswerPattern();
    _answerController.clear();
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class StarPainter extends CustomPainter {
  final Color color;
  StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double radius = size.width / 2;

    for (int i = 0; i < 5; i++) {
      double angle = (i * 72 - 90) * 3.14159 / 180;
      double x = centerX + radius * cos(angle);
      double y = centerY + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}