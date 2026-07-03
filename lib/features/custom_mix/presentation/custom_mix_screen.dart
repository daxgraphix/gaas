import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers.dart';
import '../../../core/sound_manager.dart';
import '../../../core/themes/app_themes.dart';
import '../../../data/models/math_riddle.dart';
import '../../../l10n/generated/app_localizations.dart';

class CustomMixScreen extends ConsumerStatefulWidget {
  const CustomMixScreen({super.key});

  @override
  ConsumerState<CustomMixScreen> createState() => _CustomMixScreenState();
}

class _CustomMixScreenState extends ConsumerState<CustomMixScreen>
    with TickerProviderStateMixin {
  late AnimationController _reactionController;
  late Animation<double> _scaleAnimation;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _reactionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _reactionController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _reactionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(customMixArithmeticProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
          onPressed: () {
            HapticManager.instance.selectionClick();
            Navigator.pop(context);
          },
        ),
        title: Text(
          l10n.customMixArithmetic,
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1,
            fontWeight: FontWeight.w400,
            fontFamily: 'monospace',
            color: theme.colorScheme.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, size: 20, color: theme.colorScheme.primary),
            onPressed: () => _showHelp(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (state.isActive) _buildCompactHeader(state) else if (!state.isFinished) _buildFullHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    if (state.isFinished)
                      _buildSummaryScreen(state)
                    else if (!state.isActive)
                      _buildSetupMode(state)
                    else
                      _buildGameMode(state),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullHeader() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: GlassmorphicContainer(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        borderRadius: 12,
        child: Column(
          children: [
            Text(
              l10n.operationMatrix.toUpperCase(),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 10,
                letterSpacing: 2,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.custom.toUpperCase(),
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w200,
                color: theme.colorScheme.onSurface,
                fontFamily: 'monospace',
                letterSpacing: 8,
              ),
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: -0.2, end: 0),
    );
  }

  Widget _buildCompactHeader(CustomMixArithmeticState state) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCompactStat(l10n.score, '${state.correctAnswers}/${state.questionsCompleted}', theme),
          if (state.timeLimit > 0)
            _buildTimerDisplay(state.remainingTime, theme)
          else
            _buildCompactStat(l10n.accuracy, '${(state.questionsCompleted > 0 ? (state.correctAnswers / state.questionsCompleted * 100) : 0).toStringAsFixed(0)}%', theme),
          _buildCompactStat(l10n.streak, '${state.currentStreak}', theme),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildTimerDisplay(int seconds, ThemeData theme) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    final timeStr = '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    final isLowTime = seconds < 10;
    
    return Column(
      children: [
        Text(
          timeStr,
          style: TextStyle(
            color: isLowTime ? Colors.redAccent : theme.colorScheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ).animate(target: isLowTime ? 1 : 0).shake(duration: 500.ms),
        Text(
          l10n.time.toUpperCase(),
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            fontSize: 8,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildCompactStat(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            fontSize: 8,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildSetupMode(CustomMixArithmeticState state) {
    // Removed unused theme variable
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.gameMode.toUpperCase()),
        const SizedBox(height: 12),
        _buildModeSelector(state),
        const SizedBox(height: 24),
        _buildSectionHeader(l10n.selectOperation.toUpperCase()),
        const SizedBox(height: 12),
        _buildOperationsGrid(state),
        const SizedBox(height: 24),
        _buildSectionHeader(l10n.intensity.toUpperCase()),
        const SizedBox(height: 12),
        _buildDifficultySlider(state),
        const SizedBox(height: 32),
        PremiumPrimaryButton(
          text: l10n.initializeMix.toUpperCase(),
          onPressed: state.selectedOperations.isNotEmpty
              ? () {
                  ref.read(soundManagerProvider).playEffect('click');
                  HapticManager.instance.mediumImpact();
                  ref.read(customMixArithmeticProvider.notifier).startMix();
                }
              : () {},
          icon: Icons.power_settings_new,
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildModeSelector(CustomMixArithmeticState state) {
    final theme = Theme.of(context);
    return PremiumCard(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: CustomMixMode.values.map((mode) {
          final isSelected = state.mode == mode;
          return Expanded(
            child: InkWell(
              onTap: () {
                HapticManager.instance.selectionClick();
                ref.read(customMixArithmeticProvider.notifier).setMode(mode);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      _getModeIcon(mode),
                      size: 16,
                      color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getModeName(mode).toUpperCase(),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getModeName(CustomMixMode mode) {
    switch (mode) {
      case CustomMixMode.standard:
        return l10n.standard;
      case CustomMixMode.suddenDeath:
        return l10n.suddenDeath;
      case CustomMixMode.zen:
        return l10n.zen;
      case CustomMixMode.timeAttack:
        return l10n.timeAttack;
    }
  }

  IconData _getModeIcon(CustomMixMode mode) {
    switch (mode) {
      case CustomMixMode.standard: return Icons.settings_input_component;
      case CustomMixMode.suddenDeath: return Icons.bolt;
      case CustomMixMode.zen: return Icons.self_improvement;
      case CustomMixMode.timeAttack: return Icons.timer;
    }
  }

  Widget _buildOperationsGrid(CustomMixArithmeticState state) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: ArithmeticOperation.values.map((op) {
        final isSelected = state.selectedOperations.contains(op);
        return InkWell(
          onTap: () {
            HapticManager.instance.selectionClick();
            ref.read(customMixArithmeticProvider.notifier).toggleOperation(op);
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: 200.ms,
            width: (MediaQuery.of(context).size.width - 48 - 36) / 4,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
          child: Center(
            child: _getOperationSymbol(op, isSelected: isSelected),
          ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDifficultySlider(CustomMixArithmeticState state) {
    final theme = Theme.of(context);
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.intensity.toUpperCase(),
                style: TextStyle(fontSize: 10, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              Text(
                '${l10n.levelPrefix} ${state.selectedDifficulty}',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Slider(
            value: state.selectedDifficulty.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            activeColor: theme.colorScheme.primary,
            onChanged: (v) {
              HapticManager.instance.lightImpact();
              ref.read(customMixArithmeticProvider.notifier).setDifficulty(v.round());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameMode(CustomMixArithmeticState state) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: _buildReaction(state),
        ),
        const SizedBox(height: 24),
        if (state.currentQuestion != null)
          _buildQuestionCard(state.currentQuestion!, state, theme),
        const SizedBox(height: 32),
        if (state.questionAnswered)
          PremiumPrimaryButton(
            text: l10n.nextSequence.toUpperCase(),
            onPressed: () {
              ref.read(customMixArithmeticProvider.notifier).nextQuestion();
            },
            icon: Icons.navigate_next,
          ).animate().slideY(begin: 0.2, end: 0).fadeIn()
        else
          _buildActionRow(state, theme),
      ],
    );
  }

  Widget _buildQuestionCard(MathRiddle question, CustomMixArithmeticState state, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            question.question,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontFamily: 'monospace',
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildOptionsGrid(question, state, theme),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildOptionsGrid(MathRiddle question, CustomMixArithmeticState state, ThemeData theme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: question.options.map((option) {
        final isAnswered = state.questionAnswered;
        final isCorrect = option == question.correctAnswer;
        final isSelected = isAnswered && state.questionHistory.isNotEmpty && state.questionHistory.last['userAnswer'] == option;

        Color? color;
        if (isAnswered) {
          if (isCorrect) {
            color = Colors.greenAccent.withValues(alpha: 0.2);
          } else if (isSelected) {
            color = Colors.redAccent.withValues(alpha: 0.2);
          }
        }

        return InkWell(
          onTap: isAnswered ? null : () {
            ref.read(customMixArithmeticProvider.notifier).answerQuestion(option);
            if (option == question.correctAnswer) {
              ref.read(soundManagerProvider).playEffect('correct');
              _reactionController.forward(from: 0);
            } else {
              ref.read(soundManagerProvider).playEffect('wrong');
              HapticManager.instance.errorPattern();
            }
          },
          child: AnimatedContainer(
            duration: 300.ms,
            decoration: BoxDecoration(
              color: color ?? theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isAnswered 
                  ? (isCorrect ? Colors.greenAccent : (isSelected ? Colors.redAccent : theme.colorScheme.outline.withValues(alpha: 0.1)))
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
                width: (isCorrect || isSelected) ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isAnswered 
                    ? (isCorrect ? Colors.greenAccent : (isSelected ? Colors.redAccent : theme.colorScheme.onSurface.withValues(alpha: 0.3)))
                    : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionRow(CustomMixArithmeticState state, ThemeData theme) {
    return Row(
      children: [
        if (state.canUndo)
          _buildCircleAction(Icons.undo, () => ref.read(customMixArithmeticProvider.notifier).undoLastAnswer(), Colors.orange),
        const Spacer(),
        _buildCircleAction(Icons.lightbulb_outline, () => _showHint(), Colors.yellow),
        const SizedBox(width: 16),
        _buildCircleAction(Icons.power_settings_new, () => _confirmEndSession(), Colors.red),
      ],
    );
  }

  Widget _buildCircleAction(IconData icon, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.5)),
          color: color.withValues(alpha: 0.1),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildReaction(CustomMixArithmeticState state) {
    final theme = Theme.of(context);
    final isCorrect = state.lastAnswerCorrect == true;
    return CustomPaint(
      painter: isCorrect ? ParticlePainter(theme: theme, progress: _reactionController.value) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: (isCorrect ? Colors.greenAccent : Colors.redAccent).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: (isCorrect ? Colors.greenAccent : Colors.redAccent).withValues(alpha: 0.3)),
        ),
        child: Text(
          state.reactionMessage ?? '',
          style: TextStyle(
            color: isCorrect ? Colors.greenAccent : Colors.redAccent,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    ).animate().fadeIn().scale().shake(hz: isCorrect ? 0 : 5);
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(width: 4, height: 12, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        ),
      ],
    );
  }

  void _confirmEndSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.abortSession.toUpperCase()),
        content: Text(l10n.abortSessionConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel.toUpperCase())),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(customMixArithmeticProvider.notifier).endMix();
            },
            child: Text(l10n.abortSession.toUpperCase(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showHint() {
    final state = ref.read(customMixArithmeticProvider);
    if (state.currentQuestion != null) {
      ref.read(soundManagerProvider).playEffect('hint');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.hint}: ${state.currentQuestion!.explanation}'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.modeProtocols.toUpperCase()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.standardDesc, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n.suddenDeathDesc, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n.zenDesc, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n.timeAttackDesc, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.understood.toUpperCase()),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryScreen(CustomMixArithmeticState state) {
    final theme = Theme.of(context);
    final accuracy = state.questionsCompleted > 0
        ? (state.correctAnswers / state.questionsCompleted * 100)
        : 0.0;

    return Column(
      children: [
        GlassmorphicContainer(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          borderRadius: 24,
          child: Column(
            children: [
              Text(
                l10n.gameOver.toUpperCase(),
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 12,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSummaryStat(
                    l10n.score,
                    '${state.correctAnswers}/${state.questionsCompleted}',
                    Icons.emoji_events,
                    theme,
                  ),
                  const SizedBox(width: 40),
                  _buildSummaryStat(
                    l10n.accuracy,
                    '${accuracy.toStringAsFixed(0)}%',
                    Icons.gps_fixed,
                    theme,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSummaryStat(
                    l10n.avgResponse,
                    '${state.averageResponseTime.toStringAsFixed(2)}s',
                    Icons.timer,
                    theme,
                  ),
                  const SizedBox(width: 40),
                  _buildSummaryStat(
                    l10n.bestStreak,
                    '${state.bestStreak}',
                    Icons.local_fire_department,
                    theme,
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn().scale(delay: 200.ms),
        const SizedBox(height: 40),
        PremiumPrimaryButton(
          text: l10n.tryAgain.toUpperCase(),
          onPressed: () {
            ref.read(soundManagerProvider).playEffect('click');
            ref.read(customMixArithmeticProvider.notifier).resetMix();
          },
          icon: Icons.refresh,
        ).animate().slideY(begin: 0.2, end: 0, delay: 400.ms).fadeIn(),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            ref.read(customMixArithmeticProvider.notifier).resetMix();
            Navigator.pop(context);
          },
          child: Text(
            l10n.backToMenu.toUpperCase(),
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }

  Widget _buildSummaryStat(String label, String value, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 8,
            letterSpacing: 1,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _getOperationSymbol(ArithmeticOperation op, {bool isSelected = false}) {
    final theme = Theme.of(context);
    final style = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.5),
    );
    switch (op) {
      case ArithmeticOperation.addition: return Text('+', style: style);
      case ArithmeticOperation.subtraction: return Text('-', style: style);
      case ArithmeticOperation.multiplication: return Text('×', style: style);
      case ArithmeticOperation.division: return Text('÷', style: style);
    }
  }
}

class ParticlePainter extends CustomPainter {
  final ThemeData theme;
  final double progress;

  static final List<_ParticlePoint> _particles = List.generate(20, (i) {
    final random = math.Random(i);
    return _ParticlePoint(
      angle: random.nextDouble() * 2 * math.pi,
      speed: 20 + random.nextDouble() * 60,
      size: 1.0 + random.nextDouble() * 2.0,
    );
  });
  
  ParticlePainter({required this.theme, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    
    final paint = Paint()
      ..color = theme.colorScheme.primary.withValues(alpha: (1 - progress))
      ..style = PaintingStyle.fill;
      
    final center = Offset(size.width / 2, size.height / 2);
    
    for (final p in _particles) {
      final x = center.dx + math.cos(p.angle) * p.speed * progress;
      final y = center.dy + math.sin(p.angle) * p.speed * progress;
      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => oldDelegate.progress != progress;
}

class _ParticlePoint {
  final double angle;
  final double speed;
  final double size;
  _ParticlePoint({required this.angle, required this.speed, required this.size});
}
