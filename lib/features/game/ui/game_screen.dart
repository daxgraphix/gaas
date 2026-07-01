import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/themes/app_themes.dart';
import '../../../core/providers.dart';
import '../logic/game_session_provider.dart';
import '../../../shared/widgets/custom_keypad.dart';
import '../../../core/sound_manager.dart';
import '../../../data/models/user_session.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'widgets/level_up_overlay.dart';



class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  String _currentInput = '';
  late AnimationController _comboAnimationController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
late AnimationController _progressAnimationController;
    late Animation<double> _progressAnimation;
    late AnimationController _questionAnimationController;
    final Random _random = Random();

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

    _questionAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _triggerShake() {
    ref.read(soundManagerProvider).playEffect('incorrect');
    _shakeController.forward(from: 0);
  }

  void _showLevelUpOverlay(int level, int reward) {
    ref.read(soundManagerProvider).playEffect('level_up');
    
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return LevelUpOverlay(
          level: level,
          rewardPoints: reward,
          onDismiss: () => Navigator.of(context).pop(),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
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
    final l10n = AppLocalizations.of(context)!;

    if (gameSession == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.noGameSession),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.backToMenu),
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
          if (next.currentQuestionIndex > previous.currentQuestionIndex &&
              next.correctAnswers == previous.correctAnswers) {
            ref.read(soundManagerProvider).playEffect('incorrect');
          }

          if (next.currentQuestionIndex > previous.currentQuestionIndex &&
              next.correctAnswers > previous.correctAnswers) {
            ref.read(soundManagerProvider).playEffect('correct');
            if (next.comboMultiplier == 5) {
              ref.read(soundManagerProvider).playEffect('level_up');
            } else if (next.comboMultiplier == 10) {
              ref.read(soundManagerProvider).playEffect('level_up');
            }
          }

          if (next.comboMultiplier > previous.comboMultiplier) {
          }
        }
      });

    ref.listen<UserSession?>(userSessionProvider, (previous, next) {
      if (previous != null && next != null && next.level > previous.level) {
        _showLevelUpOverlay(next.level, (next.level * 250));
      }
    });

    final userSession = ref.watch(userSessionProvider);
    final isFocusMode = userSession?.isFocusMode ?? false;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Dynamic Particle Background
          if (!isFocusMode)
            Positioned.fill(
              child: _DynamicParticleBackground(
                gameSession: gameSession,
              ),
            ),

          // HUD Scanlines
          if (!isFocusMode)
            Positioned.fill(
              child: Opacity(
                opacity: 0.015,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black54,
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: CustomPaint(
                    painter: _ScanlinePainter(),
                  ),
                ),
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  RepaintBoundary(child: _buildHeader(gameSession, theme)),
                  const Divider(height: 1),
                  RepaintBoundary(
                    child: _buildScoreBar(gameSession, theme, isFocusMode),
                  ),
                  if (gameSession.heatIndex > 1.2 && !isFocusMode)
                    _buildHeatIndicator(gameSession.heatIndex, theme),
                  const Divider(height: 1),
                  Flexible(
                    flex: 4,
                    child: AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        final heatShake = (gameSession.heatIndex - 1.0) * 0.5;
                        return Transform.translate(
                          offset: Offset(
                            (_shakeAnimation.value + heatShake * _random.nextDouble()) *
                                sin(_shakeAnimation.value * pi * 4),
                            0,
                          ),
                          child: child,
                        );
                      },
                      child: Stack(
                        children: [
                          Center(
                            child: RepaintBoundary(
                              child: gameSession.isVisualCounting
                                  ? _buildVisualQuestion(context, theme)
                                  : _buildMathQuestion(
                                      gameSession,
                                      theme,
                                      isFocusMode,
                                    ),
                            ),
                          ),
                          if (gameSession.level == 1 &&
                              gameSession.currentQuestionIndex == 0 &&
                              gameSession.currentQuestion?.options == null)
                            _buildGhostOnboarding('SOLVE_TO_INIT', theme),
                        ],
                      ),
                    ),
                  ),
                  RepaintBoundary(
                    child: _buildInputArea(context, theme, gameSession),
                  ),
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
              HapticManager.instance.mediumImpact();
              ref.read(gameSessionProvider.notifier).endGame();
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Expanded(
            child: Text(
              _getModeTitle(gameSession.mode).toUpperCase(),
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
                letterSpacing: 2,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (gameSession.mode != GameMode.campaign && (gameSession.isBossLevel ||
              gameSession.mode == GameMode.scoreAttack ||
              gameSession.mode == GameMode.speedDemon))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${gameSession.timeRemaining}S',
                    style: TextStyle(
                      color: gameSession.timeRemaining <= 10
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    size: 16,
                  ),
                ),
              ),
            ),
if (gameSession.mode == GameMode.duel)
             _buildDuelIndicator(gameSession, theme),
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
          color: playerAhead ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.38),
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

  Widget _buildScoreBar(
    GameSession gameSession,
    ThemeData theme,
    bool isFocusMode,
  ) {
    final progress =
        gameSession.currentQuestionIndex / gameSession.totalQuestions;
    if (_progressAnimationController.value != progress) {
      _progressAnimationController.animateTo(progress);
    }

    // Calculate real-time statistics
    final currentAccuracy = gameSession.currentQuestionIndex > 0
        ? (gameSession.correctAnswers / gameSession.currentQuestionIndex * 100)
            .round()
        : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMinimalStat('SCORE', '${gameSession.score}', theme),
              if (!isFocusMode)
                _buildMinimalStat('ACCURACY', '$currentAccuracy%', theme),
              _buildMinimalStat(
                'PROGRESS',
                '${gameSession.correctAnswers}/${gameSession.currentQuestionIndex}',
                theme,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!isFocusMode)
                _buildStreakStat(gameSession.comboMultiplier, theme)
              else
                const SizedBox(width: 40), // Placeholder to maintain alignment
              _buildMinimalStat('LEVEL', '${gameSession.level}', theme),
              if (gameSession.mode != GameMode.campaign &&
                  (gameSession.isBossLevel ||
                      gameSession.mode == GameMode.scoreAttack ||
                      gameSession.mode == GameMode.speedDemon))
                _buildMinimalStat(
                  'TIME',
                  '${gameSession.timeRemaining}s',
                  theme,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
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
              if (gameSession.ghostScore != null &&
                  gameSession.mode == GameMode.scoreAttack &&
                  !isFocusMode)
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    // Estimate ghost progress based on totalQuestions and ghostScore
                    // This is a simplification; in a real app we'd track ghost progress per question
                    final ghostProgress = (gameSession.ghostScore! /
                            (gameSession.totalQuestions * 20))
                        .clamp(0.0, 1.0);
                    return Positioned(
                      left: (MediaQuery.of(context).size.width - 48) *
                          ghostProgress,
                      child: Icon(
                        Icons.directions_run,
                        size: 14,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakStat(int streak, ThemeData theme) {
    final isMilestone = streak == 5 || streak == 10 || streak == 15;
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department,
              color: isMilestone 
                  ? (streak == 5 ? Colors.orange : streak == 10 ? Colors.red : Colors.purple)
                  : theme.colorScheme.secondary,
              size: 16,
            ),
            if (isMilestone) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.star,
                color: streak == 10 ? Colors.yellow : theme.colorScheme.onSurface,
                size: 12,
              ),
            ],
            const SizedBox(width: 4),
            Text(
              '$streak',
              style: TextStyle(
                color: isMilestone 
                    ? (streak == 5 ? Colors.orange : streak == 10 ? Colors.red : Colors.purple)
                    : theme.colorScheme.secondary,
                fontSize: 20,
                fontWeight: isMilestone ? FontWeight.bold : FontWeight.w900,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'STREAK',
          style: TextStyle(
            color: theme.colorScheme.secondary.withValues(alpha: 0.5),
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildGhostOnboarding(String text, ThemeData theme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(top: 160),
        child:
            Text(
                  text,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
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

  Widget _buildHeatIndicator(double heatIndex, ThemeData theme) {
    final intensity = ((heatIndex - 1.0) / 2.0).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      width: double.infinity,
      color: Colors.red.withValues(alpha: 0.1 * intensity),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.whatshot,
            size: 14,
            color: Color.lerp(Colors.orange, Colors.red, intensity),
          ),
          const SizedBox(width: 8),
          Text(
            'ENGINE HEAT: ${(heatIndex * 100).toInt()}%',
            style: TextStyle(
              color: Color.lerp(Colors.orange, Colors.red, intensity),
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().shimmer(duration: 2.seconds, color: Colors.white24);
  }

  Widget _buildMinimalStat(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildMathQuestion(
    GameSession session,
    ThemeData theme,
    bool isFocusMode,
  ) {
    final question = session.currentQuestion;
    if (question == null) return const SizedBox();

    final isRiddle = question.customQuestion != null;
    final questionText = isRiddle
        ? question.customQuestion!
        : '${question.operand1} ${_getOperationSymbol(session.operation)} ${question.operand2}';

    if (isFocusMode) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            questionText,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, isRiddle ? 32 : 64),
              fontWeight: FontWeight.w400,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  questionText,
                  style: TextStyle(
                    fontSize:
                        _getResponsiveFontSize(context, isRiddle ? 32 : 84),
                    fontWeight: isRiddle ? FontWeight.w600 : FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: isRiddle ? 0 : -2,
                    fontFamily: isRiddle ? null : 'monospace',
                    shadows: [
                      Shadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height < 600 ? 12 : 24),
            if (session.hintsUsed[session.currentQuestionIndex] == true)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'HINT: ${question.hint?.toUpperCase() ?? 'NOT AVAILABLE'}',
                  style: TextStyle(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.7),
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
              color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
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
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
            child: CustomPaint(
              size: const Size(300, 300),
              painter: VisualShapesPainter(shapes: visualData.shapes, theme: theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, ThemeData theme, GameSession session) {
    final question = session.currentQuestion;
    final useOptions = question != null && question.options != null && question.options!.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
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
                label: AppLocalizations.of(context)!.hint,
                theme: theme,
                onTap: () {
                  HapticManager.instance.lightImpact();
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
                label: AppLocalizations.of(context)!.skip,
                theme: theme,
                onTap: () {
                  HapticManager.instance.lightImpact();
                  ref.read(gameSessionProvider.notifier).skipQuestion();
                  setState(() => _currentInput = '');
                },
              ),
            ],
          ),
        ),
        if (useOptions)
          _buildOptionsGrid(question.options!, theme)
        else
          CustomKeypad(
            currentInput: _currentInput,
            onKeyPressed: (key) {
              if (_currentInput.length < 10) { // Increased for more flexible input
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

  Widget _buildOptionsGrid(List<String> options, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          return ElevatedButton(
            onPressed: () {
              HapticManager.instance.lightImpact();
              _submitAnswer(option);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.05),
              foregroundColor: theme.colorScheme.onSurface,
              side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.1), width: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              option,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
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
              Icon(icon, color: theme.colorScheme.onSurface.withValues(alpha: 0.7), size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
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

  void _submitAnswer([String? directAnswer]) {
    final answer = directAnswer ?? _currentInput;
    if (answer.isEmpty) return;

    final gameSession = ref.read(gameSessionProvider);
    if (gameSession == null) return;

    // Submit answer
    if (gameSession.isVisualCounting) {
      final numericAnswer = int.tryParse(answer);
      if (numericAnswer != null) {
        ref
            .read(gameSessionProvider.notifier)
            .answerVisualCounting(numericAnswer);
      }
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
        isCampaign ? session.correctAnswers >= GameSessionNotifier.getCampaignPassThreshold(session.totalQuestions) : true;
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
              opacity: 0.01,
              child: CustomPaint(painter: _ScanlinePainter()),
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
                    color: stars > 0 ? theme.colorScheme.secondary : theme.colorScheme.error,
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
                          color: index < stars ? Colors.amber : theme.colorScheme.secondary.withValues(alpha: 0.1),
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
                          onPressed: () async {
                            HapticManager.instance.mediumImpact();
                            final nextLevel = passed ? session.level + 1 : session.level;
                            await ref
                                .read(gameSessionProvider.notifier)
                                .startGame(
                                  mode: GameMode.campaign,
                                  operation: session.operation,
                                  level: nextLevel,
                                );
                            if (mounted) {
                              setState(() => _currentInput = '');
                            }
                          },
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            HapticManager.instance.lightImpact();
                            ref.read(gameSessionProvider.notifier).endGame();
                            Navigator.of(context).pop();
                          },
                          child: Text(AppLocalizations.of(context)!.abortSession),
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
    if (percentage >= 95) return 3;
    if (percentage >= 85) return 2;
    if (percentage >= 75) return 1;
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

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.height; i += 4) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DynamicParticleBackground extends StatefulWidget {
  final GameSession gameSession;

  const _DynamicParticleBackground({required this.gameSession});

  @override
  State<_DynamicParticleBackground> createState() =>
      _DynamicParticleBackgroundState();
}

class _DynamicParticleBackgroundState extends State<_DynamicParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    for (int i = 0; i < 20; i++) {
      _particles.add(_Particle(_random));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        for (var p in _particles) {
          p.update(widget.gameSession.comboMultiplier);
        }
        return CustomPaint(
          painter: _ParticlePainter(
            _particles,
            Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }
}

class _Particle {
  double x = 0;
  double y = 0;
  double speed = 0;
  double size = 0;
  double opacity = 0;
  final Random random;

  _Particle(this.random) {
    reset();
  }

  void reset() {
    x = random.nextDouble();
    y = random.nextDouble();
    speed = 0.001 + random.nextDouble() * 0.002;
    size = 2 + random.nextDouble() * 4;
    opacity = 0.1 + random.nextDouble() * 0.3;
  }

  void update(int combo) {
    y -= speed * (1 + combo * 0.2);
    if (y < -0.1) {
      y = 1.1;
      x = random.nextDouble();
    }
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;

  _ParticlePainter(this.particles, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final paint = Paint()..color = color.withValues(alpha: p.opacity);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class VisualShapesPainter extends CustomPainter {
  final List<ShapeData> shapes;
  final ThemeData theme;

  VisualShapesPainter({required this.shapes, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    // Add semantics for accessibility
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.transparent,
    );

    final paint = Paint()
      ..color = theme.colorScheme.onSurface.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final glowPaint = Paint()
      ..color = theme.colorScheme.onSurface.withValues(alpha: 0.1)
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

  @override
  SemanticsBuilderCallback? get semanticsBuilder {
    return (Size size) {
      return [
        CustomPainterSemantics(
          rect: Offset.zero & size,
          properties: const SemanticsProperties(
            label: 'Visual counting area',
            textDirection: TextDirection.ltr,
          ),
        ),
      ];
    };
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
