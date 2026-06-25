import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/game_adaptability/dynamic_difficulty_system.dart';
import '../../../core/themes/app_themes.dart';
import '../../../core/sound_manager.dart';
import '../../../core/providers.dart';
import '../../../core/responsive_design.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../game/logic/game_session_provider.dart';
import '../../game/ui/game_screen.dart';
import '../../../core/utils/game_flow_optimizer.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  String _selectedOperation = 'addition';
  int _minNumber = 1;
  int _maxNumber = 10;
  bool _useTimer = false;
  bool _visualCounting = false;
  bool _adaptiveDifficulty = true;
  int _timeLimit = 60;
  int _questionCount = 15;

  final List<Map<String, dynamic>> _operations = [
    {'id': 'addition', 'name': 'ADDITION', 'symbol': '+', 'token': 'primary', 'icon': Icons.add},
    {'id': 'subtraction', 'name': 'SUBTRACTION', 'symbol': '-', 'token': 'secondary', 'icon': Icons.add},
    {'id': 'multiplication', 'name': 'MULTIPLICATION', 'symbol': '×', 'token': 'tertiary', 'icon': Icons.close},
    {'id': 'division', 'name': 'DIVISION', 'symbol': '÷', 'token': 'error', 'icon': Icons.call_split},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: ResponsiveDesign.getIconSize(context, 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.practiceLab,
          style: TextStyle(
            fontSize: ResponsiveDesign.getFontSize(context, 14),
            letterSpacing: 4,
            fontWeight: FontWeight.w200,
          ),
        ),
        toolbarHeight: ResponsiveDesign.getAppBarHeight(context),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = MediaQuery.of(context).size.height;
          final appBarHeight = ResponsiveDesign.getAppBarHeight(context);
          final availableHeight = screenHeight - appBarHeight;

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                availableHeight * 0.12, // 12% of available height as bottom padding
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: availableHeight - (availableHeight * 0.12) - 48,
                ),
                child: _buildSimpleLayout(theme, l10n),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimpleLayout(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.selectOperation),
        const SizedBox(height: 16),
        ..._operations.map((op) => RepaintBoundary(child: _buildOperationTile(op, l10n))),
        const SizedBox(height: 32),
        _buildSectionHeader(l10n.numberRange),
        const SizedBox(height: 24),
        _buildRangeSlider(theme),
        const SizedBox(height: 32),
        _buildSectionHeader(l10n.configurations),
        const SizedBox(height: 16),
        _buildToggleTile(l10n.visualCounting, l10n.visualCountingDesc, _visualCounting, (val) => setState(() => _visualCounting = val)),
        _buildToggleTile(l10n.timePressure, l10n.timePressureDesc, _useTimer, (val) => setState(() => _useTimer = val)),
        _buildToggleTile(l10n.adaptiveDifficulty, l10n.adaptiveDifficultyDesc, _adaptiveDifficulty, (val) => setState(() => _adaptiveDifficulty = val)),
        const SizedBox(height: 32),
        _buildTimeLimitSection(theme, l10n),
        const SizedBox(height: 32),
        _buildQuestionCountSection(theme, l10n),
        const SizedBox(height: 48),
        _buildStartButton(l10n),
      ],
    );
  }



  Widget _buildTimeLimitSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.timeLimit.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppDesignTokens.textSecondary(context),
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        _buildTimeLimitSelector(theme),
      ],
    );
  }

  Widget _buildQuestionCountSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.questionsCount.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppDesignTokens.textSecondary(context),
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        _buildQuestionCountSelector(theme),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: ResponsiveDesign.getFontSize(context, 10),
        fontWeight: FontWeight.w300,
        letterSpacing: 2,
        color: AppDesignTokens.textMuted(context),
      ),
    );
  }

  Widget _buildOperationTile(Map<String, dynamic> op, AppLocalizations l10n) {
    final isSelected = _selectedOperation == op['id'];
    final theme = Theme.of(context);
    
    final Color color = switch (op['token']) {
      'primary' => theme.colorScheme.primary,
      'secondary' => theme.colorScheme.secondary,
      'tertiary' => theme.colorScheme.tertiary,
      'error' => theme.colorScheme.error,
      _ => theme.colorScheme.primary,
    };

    final isDesktop = ResponsiveDesign.isDesktop(context);
    final title = switch (op['id']) {
      'addition' => l10n.addition,
      'subtraction' => l10n.subtraction,
      'multiplication' => l10n.multiplication,
      'division' => l10n.division,
      _ => op['name'] as String,
    };
    final subtitle = switch (op['id']) {
      'addition' => 'Practice addition operations',
      'subtraction' => 'Practice subtraction operations',
      'multiplication' => 'Practice multiplication operations',
      'division' => 'Practice division operations',
      _ => 'Practice this operation',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PremiumCard(
        onTap: () {
          HapticManager.instance.selectionClick();
          setState(() => _selectedOperation = op['id']);
        },
        padding: EdgeInsets.all(isDesktop ? 20 : 16),
        borderColor: isSelected ? color : null,
        child: Row(
          children: [
            Container(
              width: isDesktop ? 50 : 40,
              height: isDesktop ? 50 : 40,
              padding: EdgeInsets.all(isDesktop ? 12 : 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                op['icon'],
                color: color,
                size: ResponsiveDesign.getIconSize(context, 20),
              ),
            ),
            SizedBox(width: isDesktop ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? color : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppDesignTokens.textSecondary(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 20,
              ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: _operations.indexOf(op) * 100))
      .fadeIn(duration: 400.ms)
      .slideX(begin: 0.1, end: 0);
  }

  Widget _buildRangeSlider(ThemeData theme) {
    return SizedBox(
      height: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'RANGE: $_minNumber - $_maxNumber',
                  style: TextStyle(color: AppDesignTokens.textSecondary(context), fontSize: 12, letterSpacing: 1),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RangeSlider(
              values: RangeValues(_minNumber.toDouble(), _maxNumber.toDouble()),
              min: 1,
              max: 100,
              divisions: 99,
              activeColor: theme.colorScheme.primary.withValues(alpha: 0.5),
              inactiveColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              onChanged: (values) {
                setState(() {
                  _minNumber = values.start.round();
                  _maxNumber = values.end.round();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return InkWell(
      onTap: () {
        HapticManager.instance.lightImpact();
        onChanged(!value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: AppDesignTokens.textSecondary(context), fontSize: 13, letterSpacing: 1),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: AppDesignTokens.textMuted(context), fontSize: 11),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(AppLocalizations l10n) {
    return PremiumPrimaryButton(
      text: l10n.startPractice.toUpperCase(),
      onPressed: _startPractice,
      icon: Icons.play_arrow_rounded,
    );
  }

  Widget _buildTimeLimitSelector(ThemeData theme) {
    final timeOptions = [30, 60, 120, 300, 0]; // 0 = unlimited

    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: timeOptions.map((time) {
              final isSelected = _timeLimit == time;
              return GestureDetector(
                onTap: () {
                  HapticManager.instance.selectionClick();
                  setState(() => _timeLimit = time);
                },
                child: AnimatedContainer(
                  duration: 200.ms,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    time == 0 ? '∞' : '${time}s',
                    style: TextStyle(
                      color: isSelected ? theme.colorScheme.primary : AppDesignTokens.textPrimary(context),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            _timeLimit == 0 ? 'No time limit' : '$_timeLimit seconds per question',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppDesignTokens.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCountSelector(ThemeData theme) {
    final countOptions = [20, 40, 60, 80, 100, 120];

    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: countOptions.map((count) {
              final isSelected = _questionCount == count;
              return GestureDetector(
                onTap: () {
                  HapticManager.instance.selectionClick();
                  setState(() => _questionCount = count);
                },
                child: AnimatedContainer(
                  duration: 200.ms,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      color: isSelected ? theme.colorScheme.primary : AppDesignTokens.textPrimary(context),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            '$_questionCount questions per session',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppDesignTokens.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startPractice() async {
    int effectiveMin = _minNumber;
    int effectiveMax = _maxNumber;

    if (_adaptiveDifficulty) {
      // Adjust based on user performance
      final accuracy = ref.read(overallAccuracyProvider).value ?? 0.5;
      final recentStreak = ref.read(playerPerformanceProvider).currentStreak;

      if (accuracy > 0.85 && recentStreak > 5) {
        // Advanced user - increase difficulty
        effectiveMin = (_minNumber * 1.8).toInt().clamp(1, 100);
        effectiveMax = (_maxNumber * 1.8).toInt().clamp(10, 1000);
      } else if (accuracy < 0.6 || recentStreak < 2) {
        // Struggling user - decrease difficulty
        effectiveMin = (_minNumber * 0.6).toInt().clamp(1, 10);
        effectiveMax = (_maxNumber * 0.6).toInt().clamp(5, 50);
      }
    }

    final effectiveLevel = ((effectiveMin + effectiveMax) / 2).toInt();

    // Pre-calculate questions to eliminate micro-stutter
    await GameFlowOptimizer.preloadQuestions(
      operation: _selectedOperation,
      level: effectiveLevel,
      count: _questionCount,
    );

    final preloaded = GameFlowOptimizer.getPreloadedQuestions(
      operation: _selectedOperation,
      level: effectiveLevel,
      count: _questionCount,
    );

    ref
        .read(gameSessionProvider.notifier)
        .startGame(
          mode: GameMode.practice,
          operation: _selectedOperation,
          level: effectiveLevel,
          totalQuestions: _questionCount,
          isVisualCounting: _visualCounting,
          minNumber: effectiveMin,
          maxNumber: effectiveMax,
          timeLimit: _useTimer ? (_timeLimit == 0 ? null : _timeLimit) : null,
          preloadedQuestions: preloaded,
        );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GameScreen()),
      );
    }
  }
}
