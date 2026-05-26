import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/sound_manager.dart';
import '../../../data/models/math_riddle.dart';
import '../../../l10n/generated/app_localizations.dart';

class CustomMixScreen extends ConsumerStatefulWidget {
  const CustomMixScreen({super.key});

  @override
  ConsumerState<CustomMixScreen> createState() => _CustomMixScreenState();
}

class _CustomMixScreenState extends ConsumerState<CustomMixScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

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
            HapticManager.selectionClick();
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? theme.colorScheme.surface.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: theme.brightness == Brightness.light
              ? theme.colorScheme.outline.withValues(alpha: 0.3)
              : Colors.white10,
        ),
      ),
      child: Column(
        children: [
              Text(
                l10n.operationMatrix,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 10,
                  letterSpacing: 0.5,
                  fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.custom.toUpperCase(),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w200,
              color: Colors.white,
              fontFamily: 'monospace',
              letterSpacing: 8,
            ),
          ),
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
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.operationMatrix,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 10,
                  letterSpacing: 0.5,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: ArithmeticOperation.values.map((op) {
                  final isSelected = state.selectedOperations.contains(op);
                  return InkWell(
                    onTap: () {
                      HapticManager.selectionClick();
                      ref.read(customMixArithmeticProvider.notifier).toggleOperation(op);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blueAccent.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.blueAccent : Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getOperationSymbol(op),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
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
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.difficultyLevel,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<int>(
                  value: state.selectedDifficulty,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                  items: List.generate(10, (i) => i + 1).map((diff) {
                    return DropdownMenuItem(
                      value: diff,
                      child: Text(
                        'Level $diff',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      HapticManager.selectionClick();
                      ref.read(customMixArithmeticProvider.notifier).setDifficulty(value);
                    }
                  },
                  dropdownColor: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: state.selectedOperations.isNotEmpty
                ? LinearGradient(
                    colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                  )
                : null,
            color: state.selectedOperations.isNotEmpty ? null : Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ElevatedButton(
            onPressed: state.selectedOperations.isNotEmpty
                ? () {
                    HapticManager.mediumImpact();
                    ref.read(customMixArithmeticProvider.notifier).startMix();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l10n.initiateMixSequence,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameMode(CustomMixArithmeticState state) {
    final theme = Theme.of(context);
    final accuracy = state.questionsCompleted > 0
        ? (state.correctAnswers / state.questionsCompleted * 100).toStringAsFixed(1)
        : '0.0';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.light
                ? theme.colorScheme.surface.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.brightness == Brightness.light
                  ? theme.colorScheme.outline.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              Text(
                'Session Metrics',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(l10n.score, '${state.correctAnswers}/${state.questionsCompleted}'),
                  _buildStatItem(l10n.accuracy, '$accuracy%'),
                  _buildStatItem(l10n.streak, '${state.currentStreak} (${state.bestStreak})'),
                ],
              ),
            ],
          ),
        ),
        if (state.reactionMessage != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: state.lastAnswerCorrect == true
                  ? Colors.greenAccent.withValues(alpha: 0.2)
                  : Colors.redAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: state.lastAnswerCorrect == true
                    ? Colors.greenAccent
                    : Colors.redAccent,
                width: 1,
              ),
            ),
            child: Text(
              state.reactionMessage!,
              style: TextStyle(
                color: state.lastAnswerCorrect == true
                    ? Colors.greenAccent
                    : Colors.redAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        const SizedBox(height: 32),
        if (state.currentQuestion != null) _buildQuestion(state.currentQuestion!, state),
        if (state.questionAnswered) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () {
                HapticManager.lightImpact();
                ref.read(customMixArithmeticProvider.notifier).nextQuestion();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
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
        const SizedBox(height: 32),
        // Action buttons row
        Row(
          children: [
            if (state.canUndo)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      HapticManager.lightImpact();
                      ref.read(customMixArithmeticProvider.notifier).undoLastAnswer();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      l10n.undo,
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
                margin: EdgeInsets.only(
                  left: state.canUndo ? 0 : 8,
                  right: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.amberAccent.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: () => _showHint(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    l10n.hint,
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    HapticManager.mediumImpact();
                    ref.read(customMixArithmeticProvider.notifier).endMix();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    l10n.close,
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

  Widget _buildQuestion(MathRiddle question, CustomMixArithmeticState state) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.light
                ? theme.colorScheme.surface.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.brightness == Brightness.light
                  ? theme.colorScheme.outline.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              question.question,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.4,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: question.options.map((option) {
              final isAnswered = state.questionAnswered;
              final isCorrectAnswer = option == question.correctAnswer;
              final wasSelected = isAnswered && state.questionHistory.isNotEmpty && option == state.questionHistory.last['userAnswer'];

              Color? buttonColor;
              if (isAnswered) {
                if (isCorrectAnswer) {
                  buttonColor = Colors.greenAccent.withValues(alpha: 0.3);
                } else if (wasSelected) {
                  buttonColor = Colors.redAccent.withValues(alpha: 0.3);
                } else {
                  buttonColor = Colors.white.withValues(alpha: 0.05);
                }
              } else {
                buttonColor = Colors.white.withValues(alpha: 0.05);
              }

              return Container(
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isAnswered && isCorrectAnswer
                        ? Colors.greenAccent
                        : Colors.white.withValues(alpha: 0.2),
                    width: isAnswered && isCorrectAnswer ? 2 : 1,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: isAnswered ? null : () {
                    HapticManager.lightImpact();
                    ref.read(customMixArithmeticProvider.notifier).answerQuestion(option);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
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
                  HapticManager.selectionClick();
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
            '2. Choose difficulty level (1-10)\n'
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
                HapticManager.selectionClick();
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