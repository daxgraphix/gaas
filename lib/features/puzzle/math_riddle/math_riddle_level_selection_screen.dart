import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/sound_manager.dart';
import '../../../data/models/level_progress.dart';
import '../../../data/models/math_riddle.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'math_riddle_screen.dart';

class MathRiddleLevelSelectionScreen extends ConsumerStatefulWidget {
  const MathRiddleLevelSelectionScreen({super.key});

  @override
  ConsumerState<MathRiddleLevelSelectionScreen> createState() => _MathRiddleLevelSelectionScreenState();
}

class _MathRiddleLevelSelectionScreenState extends ConsumerState<MathRiddleLevelSelectionScreen> {
  MathRiddleType _selectedType = MathRiddleType.logicChallenge;

  @override
  void initState() {
    super.initState();
    ref.read(levelProgressProvider.notifier).loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final progressMap = ref.watch(levelProgressProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.selectRiddleLevel),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.logicRiddles.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              _buildTypeSelection(theme),
              const SizedBox(height: 24),
              Text(
                l10n.selectLevel.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: List.generate(30, (index) {
                    final level = index + 1;
                    final difficulty = level <= 10 ? 'EASY' : level <= 20 ? 'MEDIUM' : 'HARD';
                    final color = level <= 10 ? Colors.green : level <= 20 ? Colors.orange : Colors.red;

                    final progress = progressMap['logic']?.firstWhere(
                      (p) => p.level == level,
                      orElse: () => LevelProgress(
                        operationId: 'logic',
                        level: level,
                        stars: 0,
                        isUnlocked: level == 1,
                        highScore: 0,
                      ),
                    );
                    final isUnlocked = progress?.isUnlocked ?? (level == 1);
                    final stars = progress?.stars ?? 0;

                    return _buildLevelCard(
                      level,
                      difficulty,
                      color,
                      theme,
                      isUnlocked,
                      stars,
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelection(ThemeData theme) {
    final types = [
      {'type': MathRiddleType.logicChallenge, 'name': 'PURE LOGIC', 'icon': Icons.psychology},
    ];

    return Wrap(
      spacing: 12,
      children: types.map((typeData) {
        final type = typeData['type'] as MathRiddleType;
        final name = typeData['name'] as String;
        final icon = typeData['icon'] as IconData;
        final isSelected = _selectedType == type;

        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : theme.colorScheme.primary),
              const SizedBox(width: 4),
              Text(name),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) setState(() => _selectedType = type);
          },
          backgroundColor: theme.colorScheme.surface,
          selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          checkmarkColor: theme.colorScheme.primary,
        );
      }).toList(),
    );
  }

  Widget _buildLevelCard(int level, String difficulty, Color color, ThemeData theme, bool isUnlocked, int stars) {
    final accentColor = isUnlocked ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isUnlocked
            ? () {
                HapticManager.instance.selectionClick();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MathRiddleScreen(
                      riddleType: _selectedType,
                      difficulty: level,
                      operationId: 'logic',
                    ),
                  ),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: isUnlocked ? theme.colorScheme.surface : theme.colorScheme.surface.withValues(alpha: 0.1),
            border: Border.all(
              color: isUnlocked ? accentColor : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'LEVEL',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  level.toString(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: isUnlocked ? color : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isUnlocked ? color.withValues(alpha: 0.1) : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    difficulty,
                    style: TextStyle(
                      color: isUnlocked ? color : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (stars > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) => Icon(
                      Icons.star,
                      size: 10,
                      color: i < stars ? theme.colorScheme.tertiary : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    )),
                  ),
                if (!isUnlocked)
                  Icon(
                    Icons.lock,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}