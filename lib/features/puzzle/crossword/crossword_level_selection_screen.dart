import 'package:flutter/material.dart';
import '../math_equation/math_equation_screen.dart';

class CrosswordLevelSelectionScreen extends StatelessWidget {
  const CrosswordLevelSelectionScreen({super.key});

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
        title: const Text('SELECT CROSSWORD LEVEL'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

  Widget _buildLevelCard(BuildContext context, int level, String difficulty, Color color, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        // Navigate to MathEquationScreen with selected level
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MathEquationScreen(
              theme: 'equations',
              level: level,
              operationId: 'crossword',
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