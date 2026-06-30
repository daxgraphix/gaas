import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/themes/app_themes.dart';
import '../../../core/utils/game_flow_optimizer.dart';
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
              theme.colorScheme.primary.withValues(alpha: 0.15),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, chapter),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              theme.colorScheme.primary.withValues(alpha: 0.8),
              theme.colorScheme.primary.withValues(alpha: 0.4),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(28),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(
                    AppDesignTokens.radiusXLarge,
                  ),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'CHAPTER ${chapter.chapterNumber}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        letterSpacing: 3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      chapter.title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                       decoration: BoxDecoration(
                         color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                         borderRadius: BorderRadius.circular(
                           AppDesignTokens.radiusLarge,
                         ),
                       ),
                      child: Text(
                        chapter.storyline,
                         style: theme.textTheme.bodyLarge?.copyWith(
                           color: theme.colorScheme.onSurface,
                           height: 1.6,
                         ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '${chapter.stages.length} PUZZLES AWAIT',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
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
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Begin Chapter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new),
            color: theme.colorScheme.onSurface,
            iconSize: 20,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  chapter.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Chapter ${chapter.chapterNumber}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded, color: Colors.amber, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${chapter.earnedStars}/${chapter.totalStars}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.amber.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isLocked
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.05)
                      : theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: isLocked
                      ? Icon(Icons.lock_outline, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5))
                      : Icon(
                          _getTypeIcon(stage.type),
                          color: theme.colorScheme.primary,
                          size: 32,
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
                        color: isLocked ? theme.colorScheme.onSurface.withValues(alpha: 0.4) : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getTypeLabel(stage.type).toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(3, (starIndex) {
                        final isEarned = stage.stars > starIndex;
                        return Icon(
                          isEarned ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 18,
                          color: isEarned ? Colors.amber : theme.colorScheme.outline.withValues(alpha: 0.3),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              if (isLocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'LVL ${stage.difficulty}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Icon(Icons.chevron_right_rounded, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPuzzle(PuzzleStageState stage, int index) {
    // Preload next question in background
    GameFlowOptimizer.preloadRiddles(
      operations: [_getOperationString(stage.type)],
      level: stage.difficulty,
      count: 20,
    );

    switch (stage.type) {
      case 'arithmetic':
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
      case 'arithmetic':
        return Icons.calculate;
      case 'logic':
        return Icons.extension;
      default:
        return Icons.extension;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'arithmetic':
        return 'Arithmetic';
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
      case 'logic':
        return MathRiddleType.logicChallenge;
      default:
        return MathRiddleType.arithmetic;
    }
  }

  String _getOperationString(String type) {
    switch (type) {
      case 'arithmetic':
        return 'arithmetic';
      case 'logic':
        return 'logic';
      default:
        return 'arithmetic';
    }
  }
}
