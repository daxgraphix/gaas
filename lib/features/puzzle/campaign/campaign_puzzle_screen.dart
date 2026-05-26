import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/themes/app_themes.dart';
import '../crossword/crossword_screen.dart';
import '../math_riddle/math_riddle_screen.dart';
import '../../../data/models/math_riddle.dart';

class CampaignPuzzleScreen extends ConsumerStatefulWidget {
  final int chapterNumber;

  const CampaignPuzzleScreen({super.key, required this.chapterNumber});

  @override
  ConsumerState<CampaignPuzzleScreen> createState() =>
      _CampaignPuzzleScreenState();
}

class _CampaignPuzzleScreenState extends ConsumerState<CampaignPuzzleScreen> {
  bool _showStoryline = true;

  @override
  Widget build(BuildContext context) {
    final chapters = ref.watch(campaignChaptersProvider);
    final theme = Theme.of(context);

    final chapter = chapters.firstWhere(
      (c) => c.chapterNumber == widget.chapterNumber,
      orElse: () => chapters.first,
    );

    if (_showStoryline) {
      return _buildStorylineOverlay(context, chapter);
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.3),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, chapter),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chapter.stages.length,
                  itemBuilder: (context, index) {
                    return _buildStageCard(
                      context,
                      chapter.stages[index],
                      index,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStorylineOverlay(
    BuildContext context,
    CampaignChapterState chapter,
  ) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.8),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.light
                      ? theme.colorScheme.surface.withValues(alpha: 0.9)
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppDesignTokens.radiusXLarge,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Chapter ${chapter.chapterNumber}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.brightness == Brightness.light
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                            : Colors.white70,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      chapter.title,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: theme.brightness == Brightness.light
                            ? theme.colorScheme.onSurface
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                       decoration: BoxDecoration(
                         color: theme.brightness == Brightness.light
                             ? theme.colorScheme.surfaceContainerHighest
                             : Colors.white.withValues(alpha: 0.15),
                         borderRadius: BorderRadius.circular(
                           AppDesignTokens.radiusLarge,
                         ),
                       ),
                      child: Text(
                        chapter.storyline,
                         style: theme.textTheme.bodyLarge?.copyWith(
                           color: theme.brightness == Brightness.light
                               ? theme.colorScheme.onSurface
                               : Colors.white,
                           height: 1.6,
                         ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '${chapter.stages.length} puzzles await',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.brightness == Brightness.light
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                            : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showStoryline = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Begin Chapter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CampaignChapterState chapter) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  chapter.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Chapter ${chapter.chapterNumber}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${chapter.earnedStars}/${chapter.totalStars}',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageCard(
    BuildContext context,
    PuzzleStageState stage,
    int index,
  ) {
    final theme = Theme.of(context);
    final isLocked = !stage.isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: isLocked ? null : () => _navigateToPuzzle(stage, index),
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isLocked
                      ? Colors.grey.withValues(alpha: 0.2)
                      : theme.colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: isLocked
                      ? const Icon(Icons.lock, color: Colors.grey)
                      : Icon(
                          _getTypeIcon(stage.type),
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isLocked ? Colors.grey : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getTypeLabel(stage.type),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: stage.stars > 0 ? Colors.amber : Colors.grey,
                        ),
                        Icon(
                          Icons.star,
                          size: 16,
                          color: stage.stars > 1 ? Colors.amber : Colors.grey,
                        ),
                        Icon(
                          Icons.star,
                          size: 16,
                          color: stage.stars > 2 ? Colors.amber : Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isLocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${stage.difficulty}*',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Icon(Icons.chevron_right, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPuzzle(PuzzleStageState stage, int index) {
    switch (stage.type) {
      case 'crossword':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CrosswordScreen(theme: stage.type)),
        ).then((_) => _onPuzzleComplete(stage.id));
        break;
      case 'arithmetic':
      case 'wordProblem':
      case 'sequence':
      case 'logic':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MathRiddleScreen(
              riddleType: _getRiddleType(stage.type),
              difficulty: stage.difficulty,
            ),
          ),
        ).then((_) => _onPuzzleComplete(stage.id));
        break;
    }
  }

  void _onPuzzleComplete(String stageId) {
    ref.read(campaignChaptersProvider.notifier).completeStage(stageId, 3, 60);
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'crossword':
        return Icons.grid_on;
      case 'arithmetic':
        return Icons.calculate;
      case 'wordProblem':
        return Icons.description;
      case 'sequence':
        return Icons.timeline;
      case 'logic':
        return Icons.extension;
      default:
        return Icons.extension;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'crossword':
        return 'Crossword';
      case 'arithmetic':
        return 'Arithmetic';
      case 'wordProblem':
        return 'Word Problem';
      case 'sequence':
        return 'Number Sequence';
      case 'logic':
        return 'Logic Challenge';
      default:
        return type;
    }
  }

  MathRiddleType _getRiddleType(String type) {
    switch (type) {
      case 'arithmetic':
        return MathRiddleType.arithmetic;
      case 'wordProblem':
        return MathRiddleType.wordProblem;
      case 'sequence':
        return MathRiddleType.numberSequence;
      case 'logic':
        return MathRiddleType.logicChallenge;
      default:
        return MathRiddleType.arithmetic;
    }
  }
}
