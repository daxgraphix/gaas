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
    {'id': 'addition', 'name': 'ADDITION', 'symbol': '+', 'color': AppDesignTokens.neonGreen, 'icon': Icons.add},
    {'id': 'subtraction', 'name': 'SUBTRACTION', 'symbol': '-', 'color': AppDesignTokens.brightBlue, 'icon': Icons.remove},
    {'id': 'multiplication', 'name': 'MULTIPLICATION', 'symbol': '×', 'color': AppDesignTokens.neonOrange, 'icon': Icons.close},
    {'id': 'division', 'name': 'DIVISION', 'symbol': '÷', 'color': AppDesignTokens.neonPurple, 'icon': Icons.call_split},
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
        ..._operations.map((op) => _buildOperationTile(op, l10n)),
        const SizedBox(height: 32),
        _buildSectionHeader(l10n.numberRange),
        const SizedBox(height: 24),
        _buildRangeSlider(),
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
          l10n.timeLimit,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
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
          l10n.questionsCount,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
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
        color: Colors.white24,
      ),
    );
  }

  Widget _buildOperationTile(Map<String, dynamic> op, AppLocalizations l10n) {
    final isSelected = _selectedOperation == op['id'];
    final theme = Theme.of(context);
    final color = op['color'] as Color;
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

    return GestureDetector(
        onTap: () {
          HapticManager.selectionClick();
          setState(() => _selectedOperation = op['id']);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: EdgeInsets.all(isDesktop ? 20 : 16),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.15)
                : theme.colorScheme.surface.withValues(alpha: 0.5),
            border: Border.all(
              color: isSelected
                  ? color
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Row(
            children: [
              Container(
                width: isDesktop ? 50 : 40,
                height: isDesktop ? 50 : 40,
                padding: EdgeInsets.all(isDesktop ? 12 : 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
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
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: ResponsiveDesign.getFontSize(context, 14),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: ResponsiveDesign.getFontSize(context, 11),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: isSelected ? Icon(
                Icons.check_circle,
                color: color,
                size: 20,
              ) : null,
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: _operations.indexOf(op) * 100))
      .fadeIn(duration: 400.ms)
      .slideX(begin: 0.1, end: 0);
  }

  Widget _buildRangeSlider() {
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
                  style: const TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1),
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
              activeColor: Colors.white38,
              inactiveColor: Colors.white10,
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
        HapticManager.lightImpact();
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
                    style: const TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 1),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white24, fontSize: 11),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white70,
              activeTrackColor: Colors.white10,
              inactiveThumbColor: Colors.white10,
              inactiveTrackColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        HapticManager.heavyImpact();
        _startPractice();
      },
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white10, width: 0.5),
        ),
        child: Center(
          child: Text(
            l10n.startPractice,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w200,
              letterSpacing: 4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeLimitSelector(ThemeData theme) {
    final timeOptions = [30, 60, 120, 300, 0]; // 0 = unlimited

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: timeOptions.map((time) {
              final isSelected = _timeLimit == time;
              return GestureDetector(
                onTap: () => setState(() => _timeLimit = time),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    time == 0 ? '∞' : '${time}s',
                    style: TextStyle(
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            _timeLimit == 0 ? 'No time limit' : '$_timeLimit seconds per question',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCountSelector(ThemeData theme) {
    final countOptions = [20, 40, 60, 80, 100, 120];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: countOptions.map((count) {
              final isSelected = _questionCount == count;
              return GestureDetector(
                onTap: () => setState(() => _questionCount = count),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            '$_questionCount questions per session',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _startPractice() {
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

    ref
        .read(gameSessionProvider.notifier)
        .startGame(
          mode: GameMode.practice,
          operation: _selectedOperation,
          level: ((effectiveMin + effectiveMax) / 2).toInt(),
          totalQuestions: _questionCount,
          isVisualCounting: _visualCounting,
          minNumber: effectiveMin,
          maxNumber: effectiveMax,
          timeLimit: _useTimer ? (_timeLimit == 0 ? null : _timeLimit) : null,
        );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }
}
