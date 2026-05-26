import 'package:flutter/material.dart';
import '../../../data/models/math_riddle.dart';
import '../math_riddle/math_riddle_screen.dart';

class MathRiddleLevelSelectionScreen extends StatefulWidget {
  const MathRiddleLevelSelectionScreen({super.key});

  @override
  State<MathRiddleLevelSelectionScreen> createState() => _MathRiddleLevelSelectionScreenState();
}

class _MathRiddleLevelSelectionScreenState extends State<MathRiddleLevelSelectionScreen> {
  MathRiddleType _selectedType = MathRiddleType.logicChallenge;

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
        title: const Text('SELECT RIDDLE LEVEL'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LOGIC RIDDLES ONLY',
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
                'CHOOSE DIFFICULTY',
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

                    return _buildLevelCard(
                      context,
                      level,
                      difficulty,
                      color,
                      theme,
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
    // Only logic challenges are available now
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

  Widget _buildLevelCard(BuildContext context, int level, String difficulty, Color color, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        // Navigate to MathRiddleScreen with selected level and type
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MathRiddleScreen(
              riddleType: _selectedType,
              difficulty: level,
              operationId: 'riddle',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(
            color: color.withValues(alpha: 0.3),
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                level.toString(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  difficulty,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}