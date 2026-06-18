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
        toolbarHeight: 60,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, size: 20, color: theme.colorScheme.primary),
            onPressed: () => _showHelp(),
            tooltip: l10n.help,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '${l10n.sysOp}: ${l10n.mixModeProtocol}',
                style: TextStyle(
                  fontSize: 8,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderPanel(),
              const SizedBox(height: 32),
              _buildSectionHeader(state.isActive ? l10n.gameSession : l10n.configuration),
              const SizedBox(height: 16),
              state.isActive ? _buildGameMode(state) : _buildSetupMode(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderPanel() {
    final theme = Theme.of(context);
    return RepaintBoundary(
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
                fontSize: 48,
                fontWeight: FontWeight.w200,
                color: AppDesignTokens.textPrimary,
                fontFamily: 'monospace',
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 2,
              width: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, theme.colorScheme.primary, Colors.transparent],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 4,
          height: 12,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: Colors.white54,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildSetupMode(CustomMixArithmeticState state) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PremiumCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OPERATIONS',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: ArithmeticOperation.values.map((op) {
                  final isSelected = state.selectedOperations.contains(op);
                  return Hero(
                    tag: 'op_${op.name}',
                    child: InkWell(
                      onTap: () {
                        HapticManager.instance.selectionClick();
                        ref.read(customMixArithmeticProvider.notifier).toggleOperation(op);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: 200.ms,
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : AppDesignTokens.textMuted.withValues(alpha: 0.3),
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            _getOperationSymbol(op),
                            style: TextStyle(
                              color: isSelected ? AppDesignTokens.textPrimary : AppDesignTokens.textSecondary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PremiumCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DIFFICULTY',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 10,
                      letterSpacing: 2,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Level ${state.selectedDifficulty}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: theme.colorScheme.primary,
                  inactiveTrackColor: AppDesignTokens.surfaceLighter,
                  thumbColor: theme.colorScheme.primary,
                  overlayColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                  valueIndicatorColor: theme.colorScheme.primary,
                ),
                child: Slider(
                  value: state.selectedDifficulty.toDouble(),
                  min: 1,
                  max: 30,
                  divisions: 29,
                  onChanged: (value) {
                    HapticManager.instance.lightImpact();
                    ref.read(customMixArithmeticProvider.notifier).setDifficulty(value.round());
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('EASY', style: TextStyle(color: AppDesignTokens.textMuted, fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  Text('HARD', style: TextStyle(color: AppDesignTokens.textMuted, fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        PremiumPrimaryButton(
          text: 'START MIX',
          onPressed: state.selectedOperations.isNotEmpty
              ? () {
                  HapticManager.instance.mediumImpact();
                  ref.read(customMixArithmeticProvider.notifier).startMix();
                }
              : () {},
          icon: Icons.play_arrow_rounded,
        ),
      ],
    );
  }

  Widget _buildGameMode(CustomMixArithmeticState state) {
    final theme = Theme.of(context);
    final progress = state.questionsCompleted > 0
        ? (state.correctAnswers / state.questionsCompleted).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.light
                ? theme.colorScheme.surface.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.brightness == Brightness.light
                  ? theme.colorScheme.outline.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(l10n.score, '${state.correctAnswers}/${state.questionsCompleted}'),
                  _buildStatItem(l10n.accuracy, '${(progress * 100).toStringAsFixed(1)}%'),
                  _buildStatItem(l10n.streak, '${state.currentStreak}'),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                minHeight: 4,
              ),
            ],
          ),
        ),
        if (state.reactionMessage != null) ...[
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: state.lastAnswerCorrect == true
                        ? Colors.greenAccent.withValues(alpha: 0.2)
                        : Colors.redAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: state.lastAnswerCorrect == true ? Colors.greenAccent : Colors.redAccent,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    state.reactionMessage!,
                    style: TextStyle(
                      color: state.lastAnswerCorrect == true ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ).animate().fadeIn(duration: 300.ms).shake(),
        ],
        const SizedBox(height: 24),
        if (state.currentQuestion != null)
          _buildQuestion(state.currentQuestion!, state, theme),
        if (state.questionAnswered) ...[
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.secondary, theme.colorScheme.tertiary],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                HapticManager.instance.lightImpact();
                ref.read(customMixArithmeticProvider.notifier).nextQuestion();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              label: Text(
                l10n.nextQuestion,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            if (state.canUndo)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticManager.instance.lightImpact();
                      ref.read(customMixArithmeticProvider.notifier).undoLastAnswer();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.undo, size: 18, color: Colors.white),
                    label: Text(
                      'UNDO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: state.canUndo ? 0 : 8, right: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton.icon(
                  onPressed: () => _showHint(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.lightbulb, size: 18, color: Colors.white70),
                  label: Text(
                    'HINT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticManager.instance.mediumImpact();
                    ref.read(customMixArithmeticProvider.notifier).endMix();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.close, size: 18, color: Colors.white),
                  label: Text(
                    'END',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 8,
            letterSpacing: 1,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildQuestion(MathRiddle question, CustomMixArithmeticState state, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? theme.colorScheme.surface.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.light
              ? theme.colorScheme.outline.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              question.question,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.4,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: question.options.map((option) {
              final isAnswered = state.questionAnswered;
              final isCorrectAnswer = option == question.correctAnswer;
              final wasSelected = isAnswered &&
                  state.questionHistory.isNotEmpty &&
                  option == state.questionHistory.last['userAnswer'];

              Color? buttonColor;
              if (isAnswered) {
                if (isCorrectAnswer) {
                  buttonColor = theme.colorScheme.primary.withValues(alpha: 0.3);
                } else if (wasSelected) {
                  buttonColor = Colors.redAccent.withValues(alpha: 0.3);
                } else {
                  buttonColor = Colors.white.withValues(alpha: 0.05);
                }
              } else {
                buttonColor = Colors.white.withValues(alpha: 0.05);
              }

              return Hero(
                tag: 'answer_$option',
                child: Container(
                  width: 100,
                  height: 50,
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isAnswered && isCorrectAnswer
                          ? theme.colorScheme.primary
                          : Colors.white.withValues(alpha: 0.2),
                      width: isAnswered && isCorrectAnswer ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: isAnswered
                        ? null
                        : () {
                            HapticManager.instance.lightImpact();
                            ref.read(customMixArithmeticProvider.notifier).answerQuestion(option);
                            if (!mounted) return;
                            _reactionController.forward(from: 0);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      option,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showHint() {
    final theme = Theme.of(context);
    final state = ref.read(customMixArithmeticProvider);
    if (state.currentQuestion != null && state.currentQuestion!.progressiveHints.isNotEmpty) {
      ref.read(soundManagerProvider).playEffect('hint');
      HapticManager.instance.mediumImpact();
      showDialog(
        context: context,
        barrierColor: theme.brightness == Brightness.light
            ? Colors.black.withValues(alpha: 0.5)
            : Colors.black.withValues(alpha: 0.8),
        builder: (context) => AlertDialog(
          backgroundColor: theme.brightness == Brightness.light
              ? theme.colorScheme.surface
              : const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.brightness == Brightness.light
                  ? theme.colorScheme.outline.withValues(alpha: 0.3)
                  : Colors.white10,
              width: 0.5,
            ),
          ),
          title: const Center(
            child: Text(
              'System Hint',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 14,
                letterSpacing: 2,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              state.currentQuestion!.progressiveHints[0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  HapticManager.instance.selectionClick();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Acknowledge',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showHelp() {
    HapticManager.instance.selectionClick();
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white10, width: 0.5),
        ),
        title: Center(
          child: Text(
            'Mix Mode Protocol',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 14,
              letterSpacing: 0.5,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'CUSTOM MIX ARITHMETIC allows you to create personalized arithmetic challenges.\n\n'
            '1. Select one or more operations (+, -, ×, ÷)\n'
            '2. Choose difficulty level (1-30)\n'
            '3. Questions will be generated using only your selected operations\n'
            '4. Answer correctly to build your score\n'
            '5. Use hints if needed (reveals the answer)\n\n'
            'Perfect for targeted practice and skill development.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.5,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.left,
          ),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                HapticManager.instance.selectionClick();
                Navigator.pop(context);
              },
              child: Text(
                'Understood',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontFamily: 'monospace',
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getOperationSymbol(ArithmeticOperation op) {
    switch (op) {
      case ArithmeticOperation.addition:
        return '+';
      case ArithmeticOperation.subtraction:
        return '-';
      case ArithmeticOperation.multiplication:
        return '×';
      case ArithmeticOperation.division:
        return '÷';
    }
  }
}