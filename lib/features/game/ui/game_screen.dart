import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/themes/app_themes.dart';
import '../../../core/providers.dart';
import '../logic/game_session_provider.dart';
import '../../../shared/widgets/custom_keypad.dart';
import '../../../core/sound_manager.dart';



class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  String _currentInput = '';
  bool _showErrorFlash = false;
  bool _showCorrectFeedback = false;
  bool _showWrongFeedback = false;
  late AnimationController _comboAnimationController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;
  late AnimationController _questionAnimationController;
  late AnimationController _feedbackAnimationController;

  @override
  void initState() {
    super.initState();
    _comboAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_shakeController);

    _progressAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _feedbackAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _questionAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _triggerShake() {
    HapticManager.errorPattern();
    _shakeController.forward(from: 0);
  }

  @override
  void dispose() {
    _comboAnimationController.dispose();
    _shakeController.dispose();
    _progressAnimationController.dispose();
    _questionAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameSession = ref.watch(gameSessionProvider);
    final theme = Theme.of(context);

    if (gameSession == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No game session'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Menu'),
              ),
            ],
          ),
        ),
      );
    }

    if (gameSession.currentQuestionIndex >= gameSession.totalQuestions ||
        (gameSession.mode == GameMode.endless && gameSession.lives <= 0) ||
        (gameSession.mode == GameMode.scoreAttack &&
            gameSession.timeRemaining <= 0)) {
      return _buildResultsScreen(context, gameSession, theme);
    }

    ref.listen<GameSession?>(gameSessionProvider, (previous, next) {
      if (previous != null && next != null) {
        // Did they answer wrong?
        if (next.currentQuestionIndex > previous.currentQuestionIndex &&
            next.correctAnswers == previous.correctAnswers) {
          setState(() => _showErrorFlash = true);
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) setState(() => _showErrorFlash = false);
          });
          _triggerShake();
          // Wrong answer feedback
          ref.read(soundManagerProvider).playWrongAnswer();
          HapticManager.wrongAnswerPattern();
        }

        // Did they answer correctly?
        if (next.currentQuestionIndex > previous.currentQuestionIndex &&
            next.correctAnswers > previous.correctAnswers) {
          // Trigger success animation
          _comboAnimationController.forward(from: 0.0);
          _questionAnimationController.forward(from: 0.0);
          // Correct answer feedback
          ref.read(soundManagerProvider).playCorrectAnswer();
          HapticManager.correctAnswerPattern();
        }

        // Did combo increase?
        if (next.comboMultiplier > previous.comboMultiplier) {
          // Additional feedback for combo
        }
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // HUD Scanlines
          Positioned.fill(
            child: Opacity(
              opacity: 0.02,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/carbon-fibre.png',
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: _showErrorFlash
                  ? Colors.red.withValues(alpha: 0.2)
                  : Colors.transparent,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  RepaintBoundary(child: _buildHeader(gameSession, theme)),
                  const Divider(height: 1),
                  RepaintBoundary(child: _buildScoreBar(gameSession, theme)),
                  const Divider(height: 1),
                  Flexible(
                    flex: 4,
                    child: AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value * sin(_shakeAnimation.value * pi * 4), 0),
                          child: child,
                        );
                      },
                      child: Stack(
                        children: [
                          Center(
                            child: RepaintBoundary(
                              child: gameSession.isVisualCounting
                                  ? _buildVisualQuestion(context, theme)
                                  : _buildMathQuestion(gameSession, theme),
                            ),
                          ),
                          if (gameSession.level == 1 &&
                              gameSession.currentQuestionIndex == 0)
                            _buildGhostOnboarding('SOLVE_TO_INIT'),
                        ],
                      ),
                    ),
                  ),
                  RepaintBoundary(child: _buildInputArea(context, theme)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(GameSession gameSession, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              HapticManager.mediumImpact();
              ref.read(gameSessionProvider.notifier).endGame();
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: Colors.white70,
            ),
          ),
          Expanded(
            child: Text(
              _getModeTitle(gameSession.mode).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                letterSpacing: 2,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (gameSession.isBossLevel ||
              gameSession.mode == GameMode.scoreAttack ||
              gameSession.mode == GameMode.speedDemon)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: Colors.white38,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${gameSession.timeRemaining}S',
                    style: TextStyle(
                      color: gameSession.timeRemaining <= 10
                          ? Colors.redAccent
                          : Colors.white70,
                      fontWeight: FontWeight.w200,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          if (gameSession.mode == GameMode.endless || gameSession.isBossLevel)
            Row(
              children: List.generate(
                3,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    i < gameSession.lives
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: i < gameSession.lives
                        ? Colors.redAccent
                        : Colors.white10,
                    size: 16,
                  ),
                ),
              ),
            ),
          if (gameSession.mode == GameMode.duel)
            _buildDuelIndicator(gameSession, theme),

          // Answer feedback overlay
          if (_showCorrectFeedback || _showWrongFeedback)
            AnimatedBuilder(
              animation: _feedbackAnimationController,
              builder: (context, child) {
                return Container(
                  color: _showCorrectFeedback
                      ? Colors.green.withValues(alpha: 0.3 * _feedbackAnimationController.value)
                      : Colors.red.withValues(alpha: 0.3 * _feedbackAnimationController.value),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: _showCorrectFeedback ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _showCorrectFeedback ? Colors.green : Colors.red,
                            blurRadius: 40 * _feedbackAnimationController.value,
                            spreadRadius: 20 * _feedbackAnimationController.value,
                          ),
                        ],
                      ),
                      child: Icon(
                        _showCorrectFeedback ? Icons.check_circle : Icons.cancel,
                        color: Colors.white,
                        size: 80 * _feedbackAnimationController.value,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDuelIndicator(GameSession session, ThemeData theme) {
    final playerAhead = (session.aiScore ?? 0) < session.score;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        '${session.score} / ${session.aiScore ?? 0}',
        style: TextStyle(
          color: playerAhead ? Colors.white : Colors.white38,
          fontWeight: FontWeight.w300,
          fontSize: 14,
        ),
      ),
    );
  }

  String _getModeTitle(GameMode mode) {
    switch (mode) {
      case GameMode.campaign:
        return 'Campaign';
      case GameMode.practice:
        return 'Practice';
      case GameMode.scoreAttack:
        return 'Score Attack';
      case GameMode.endless:
        return 'Endless';
      case GameMode.duel:
        return 'Duel';
      case GameMode.flash:
        return 'Flash';
      case GameMode.speedDemon:
        return 'Speed Demon';
      case GameMode.mathMaster:
        return 'Math Master';
      case GameMode.marathon:
        return 'Marathon';
    }
  }

  Widget _buildScoreBar(GameSession gameSession, ThemeData theme) {
    final progress = gameSession.currentQuestionIndex / gameSession.totalQuestions;
    if (_progressAnimationController.value != progress) {
      _progressAnimationController.animateTo(progress);
    }

    // Calculate real-time statistics
    final currentAccuracy = gameSession.currentQuestionIndex > 0
        ? (gameSession.correctAnswers / gameSession.currentQuestionIndex * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMinimalStat('SCORE', '${gameSession.score}'),
              _buildMinimalStat('ACCURACY', '$currentAccuracy%'),
              _buildMinimalStat(
                'PROGRESS',
                '${gameSession.correctAnswers}/${gameSession.currentQuestionIndex}',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMinimalStat('STREAK', '${gameSession.comboMultiplier}x'),
              _buildMinimalStat('LEVEL', '${gameSession.level}'),
              _buildMinimalStat('TIME', '${gameSession.timeRemaining}s'),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGhostOnboarding(String text) {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(top: 160),
        child:
            Text(
                  text,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.15),
                    fontSize: 12,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w300,
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .fadeIn(duration: 1.seconds)
                .fadeOut(delay: 1.seconds, duration: 1.seconds),
      ),
    );
  }

  Widget _buildMinimalStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppDesignTokens.neonCyan.withValues(alpha: 0.5),
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppDesignTokens.neonCyan,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildMathQuestion(GameSession session, ThemeData theme) {
    final question = session.currentQuestion;
    if (question == null) return const SizedBox();

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Text(
              '${question.operand1} ${_getOperationSymbol(session.operation)} ${question.operand2}',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 84), // Make font size responsive
                fontWeight: FontWeight.w900,
                color: AppDesignTokens.neonCyan,
                letterSpacing: -2,
                fontFamily: 'monospace',
                shadows: [
                  Shadow(color: AppDesignTokens.neonCyan, blurRadius: 20),
                ],
              ),
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height < 600 ? 12 : 24),
          if (session.hintsUsed[session.currentQuestionIndex] == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'HINT: ${question.hint?.toUpperCase() ?? 'NOT AVAILABLE'}',
                style: TextStyle(
                  color: AppDesignTokens.neonPink.withValues(alpha: 0.7),
                  fontSize: _getResponsiveFontSize(context, 14),
                  letterSpacing: 2,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualQuestion(BuildContext context, ThemeData theme) {
    final gameSession = ref.watch(gameSessionProvider);
    if (gameSession == null || gameSession.currentVisualData == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white24,
          strokeWidth: 1,
        ),
      );
    }

    final visualData = gameSession.currentVisualData!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'COUNT THE SHAPES',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white10,
                width: 0.5,
              ),
            ),
            child: CustomPaint(
              size: const Size(300, 300),
              painter: VisualShapesPainter(shapes: visualData.shapes),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          color: Colors.white10,
          height: 1,
          thickness: 0.5,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlBtn(
                icon: Icons.lightbulb_outline,
                label: 'HINT',
                onTap: () {
                  HapticManager.lightImpact();
                  final user = ref.read(userSessionProvider);
                  if (user != null && user.totalPoints >= hintCostPoints) {
                    ref.read(gameSessionProvider.notifier).useHint();
                  } else {
                    _triggerShake();
                  }
                },
              ),
              _buildControlBtn(
                icon: Icons.skip_next_rounded,
                label: 'SKIP',
                onTap: () {
                  HapticManager.lightImpact();
                  ref.read(gameSessionProvider.notifier).skipQuestion();
                  setState(() => _currentInput = '');
                },
              ),
            ],
          ),
        ),
        CustomKeypad(
          currentInput: _currentInput,
          onKeyPressed: (key) {
            if (_currentInput.length < 6) {
              setState(() {
                _currentInput += key;
              });
            }
          },
          onClear: () => setState(() {
            _currentInput = '';
          }),
          onSubmit: _submitAnswer,
        ),
      ],
    );
  }

  Widget _buildControlBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool disabled = false,
  }) {
    return Opacity(
      opacity: disabled ? 0.2 : 1.0,
      child: InkWell(
        onTap: disabled ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white38,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitAnswer() {
    if (_currentInput.isEmpty) return;

    final answer = int.tryParse(_currentInput);
    if (answer == null) return;

    final gameSession = ref.read(gameSessionProvider);
    if (gameSession == null) return;

    // Check if answer is correct before submitting
    final isCorrect = gameSession.isVisualCounting
        ? (answer == gameSession.currentVisualData?.targetCount)
        : (answer == gameSession.currentQuestion?.correctAnswer);

    // Show visual feedback
    setState(() {
      if (isCorrect) {
        _showCorrectFeedback = true;
        _showWrongFeedback = false;
      } else {
        _showCorrectFeedback = false;
        _showWrongFeedback = true;
      }
      _showErrorFlash = !isCorrect;
    });

    // Animate feedback
    _feedbackAnimationController.forward(from: 0.0).then((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _showCorrectFeedback = false;
            _showWrongFeedback = false;
          });
        }
      });
    });

    // Submit answer
    if (gameSession.isVisualCounting) {
      ref
          .read(gameSessionProvider.notifier)
          .answerVisualCounting(answer);
    } else {
      ref.read(gameSessionProvider.notifier).answerQuestion(answer);
    }

    setState(() {
      _currentInput = '';
    });
  }

  Widget _buildResultsScreen(
    BuildContext context,
    GameSession session,
    ThemeData theme,
  ) {
    final percentage = (session.correctAnswers / session.totalQuestions) * 100;
    final isCampaign = session.mode == GameMode.campaign;
    final passed =
        isCampaign ? session.correctAnswers >= GameSessionNotifier.campaignPassThreshold : true;
    final stars = passed ? _calculateStars(
      session.correctAnswers,
      session.totalQuestions,
    ) : 0;
    final isDuel = session.mode == GameMode.duel;
    final playerWon = session.playerWon;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                const SizedBox(height: 48),
                Text(
                  isDuel
                      ? (playerWon == true ? 'SYS_VICTORY' : 'SYS_DEFEAT')
                      : (stars > 0 ? 'LEVEL_STABILIZED' : 'INTEGRITY_FAILED'),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: stars > 0 ? AppDesignTokens.neonCyan : AppDesignTokens.neonPink,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 48),
                if (!isDuel)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          index < stars ? Icons.star : Icons.star_border,
                          color: index < stars ? AppDesignTokens.neonYellow : AppDesignTokens.neonCyan.withValues(alpha: 0.1),
                          size: 40,
                        ),
                      );
                    }),
                  ),
                const Spacer(),
                _buildMinimalResultRow('CORE_SCORE', '${session.score}', theme),
                _buildMinimalResultRow(
                  'STABILITY',
                  '${session.correctAnswers} / ${session.totalQuestions}',
                  theme,
                ),
                _buildMinimalResultRow(
                  'SYNC_RATE',
                  '${percentage.toStringAsFixed(0)}%',
                  theme,
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      if (session.mode == GameMode.campaign)
                        PremiumPrimaryButton(
                          text: passed ? 'NEXT_PHASE' : 'RECALIBRATE',
                          onPressed: () {
                            HapticManager.mediumImpact();
                            ref
                                .read(gameSessionProvider.notifier)
                                .startGame(
                                  mode: GameMode.campaign,
                                  operation: session.operation,
                                  level: passed ? session.level + 1 : session.level,
                                  totalQuestions:
                                      (passed ? session.level + 1 : session.level) %
                                              10 ==
                                          9
                                      ? 50
                                      : 40,
                                );
                            setState(() => _currentInput = '');
                          },
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            HapticManager.lightImpact();
                            ref.read(gameSessionProvider.notifier).endGame();
                            Navigator.of(context).pop();
                          },
                          child: const Text('ABORT_SESSION'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalResultRow(String label, String value, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
              letterSpacing: 2,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  int _calculateStars(int correct, int total) {
    final percentage = (correct / total) * 100;
    if (percentage >= 90) return 3;
    if (percentage >= 70) return 2;
    if (percentage >= 50) return 1;
    return 0;
  }

  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // For very small screens (small phones)
    if (screenWidth < 360 || screenHeight < 640) {
      return baseSize * 0.5; // Reduce to 50% of base size
    }
    // For small screens (phones)
    else if (screenWidth < 400) {
      return baseSize * 0.6; // Reduce to 60% of base size
    }
    // For medium screens (larger phones, small tablets)
    else if (screenWidth < 600) {
      return baseSize * 0.75; // Reduce to 75% of base size
    }
    // For larger screens (tablets, desktop)
    else if (screenWidth < 1200) {
      return baseSize * 0.9; // Reduce to 90% of base size
    }
    // For very large screens
    else {
      return baseSize; // Use full base size
    }
  }

  String _getOperationSymbol(String operation) {
    switch (operation) {
      case 'addition':
        return '+';
      case 'subtraction':
        return '−';
      case 'multiplication':
        return '×';
      case 'division':
        return '÷';
      default:
        return '+';
    }
  }
}

class VisualShapesPainter extends CustomPainter {
  final List<ShapeData> shapes;

  VisualShapesPainter({required this.shapes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (final shape in shapes) {
      final rect = Rect.fromLTWH(shape.x, shape.y, shape.size, shape.size);

      if (shape.type == 'circle') {
        canvas.drawCircle(rect.center, shape.size / 2, glowPaint);
        canvas.drawCircle(rect.center, shape.size / 2, paint);
      } else if (shape.type == 'triangle') {
        final path = Path()
          ..moveTo(rect.center.dx, rect.top)
          ..lineTo(rect.right, rect.bottom)
          ..lineTo(rect.left, rect.bottom)
          ..close();
        canvas.drawPath(path, glowPaint);
        canvas.drawPath(path, paint);
      } else if (shape.type == 'star') {
        final path = _getStarPath(rect);
        canvas.drawPath(path, glowPaint);
        canvas.drawPath(path, paint);
      } else {
        canvas.drawRect(rect, glowPaint);
        canvas.drawRect(rect, paint);
      }
    }
  }

  Path _getStarPath(Rect rect) {
    final path = Path();
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final outerRadius = rect.width / 2;
    final innerRadius = outerRadius * 0.4;
    const points = 5;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * pi / points) - pi / 2;
      final x = cx + radius * cos(angle);
      final y = cy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant VisualShapesPainter oldDelegate) =>
      oldDelegate.shapes != shapes;
}

class TrianglePainter extends CustomPainter {
  final Color color;
  final bool isFilled;
  TrianglePainter({required this.color, this.isFilled = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StarPainter extends CustomPainter {
  final Color color;
  final bool isFilled;
  StarPainter({required this.color, this.isFilled = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.4;
    const points = 5;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * 3.14159 / points) - 3.14159 / 2;
      final x = cx + radius * cos(angle);
      final y = cy + radius * sin(angle);
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
