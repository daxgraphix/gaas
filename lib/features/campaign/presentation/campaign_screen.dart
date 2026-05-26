import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/themes/app_themes.dart';
import '../../../core/providers.dart';
import '../../../core/sound_manager.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../game/logic/game_session_provider.dart';
import '../../game/ui/game_screen.dart';
import '../../../data/models/level_progress.dart';

class CampaignScreen extends ConsumerStatefulWidget {
  const CampaignScreen({super.key});

  @override
  ConsumerState<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends ConsumerState<CampaignScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.campaignMode),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 2,
          dividerColor: Colors.transparent,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          labelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontFamily: 'monospace',
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            letterSpacing: 2,
            fontFamily: 'monospace',
          ),
          tabs: [
            Tab(text: l10n.addition.toUpperCase()),
            Tab(text: l10n.subtraction.toUpperCase()),
            Tab(text: l10n.multiplication.toUpperCase()),
            Tab(text: l10n.division.toUpperCase()),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/carbon-fibre.png',
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          TabBarView(
            controller: _tabController,
            children: [
              _buildLevelGrid('addition', progressMap['addition'] ?? []),
              _buildLevelGrid('subtraction', progressMap['subtraction'] ?? []),
              _buildLevelGrid('multiplication', progressMap['multiplication'] ?? []),
              _buildLevelGrid('division', progressMap['division'] ?? []),
            ],
          ),
        ],
      ),
    );
  }

  String _getSubtype(String primaryType, int level) {
    // All campaign operations are arithmetic
    return 'arithmetic';
  }

  String _getShortLabel(String subType, String primaryType) {
    if (subType == 'arithmetic') {
      return primaryType.substring(0, 3).toUpperCase();
    }
    return '';
  }

  Widget _buildLevelGrid(String type, List<LevelProgress> progressList) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: GridView.count(
        crossAxisCount: 5,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: List.generate(30, (index) {
          final level = index + 1;
          final actualSubType = _getSubtype(type, level);

          final progress = progressList.firstWhere(
            (p) => p.level == level,
            orElse: () => LevelProgress(
              operationId: type,
              level: level,
              stars: 0,
              isUnlocked: level == 1,
              highScore: 0,
            ),
          );

          // All levels are now unlocked in campaign mode
          final isUnlocked = true;

          return _buildGridNode(level, isUnlocked, progress.stars, actualSubType, type, progressList);
        }),
      ),
    );
  }

  Widget _buildGridNode(int level, bool isUnlocked, int stars, String subType, String primaryType, List<LevelProgress> progressList) {
    final theme = Theme.of(context);
    final accentColor = isUnlocked ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.1);
    final label = _getShortLabel(subType, primaryType);

    return GestureDetector(
      onTap: isUnlocked ? () => _startCampaignLevel(subType, level, primaryType) : null,
      child: Container(
        decoration: BoxDecoration(
          color: AppDesignTokens.techBlack,
          border: Border.all(
            color: isUnlocked ? accentColor : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'L${level.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: isUnlocked ? Colors.white : Colors.white10,
                  fontSize: 14,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (stars > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) => Icon(
                    Icons.star,
                    size: 10,
                    color: i < stars ? AppDesignTokens.neonYellow : Colors.white10,
                  )),
                ),
            ],
          ),
        ),
      ).animate(target: isUnlocked ? 1 : 0)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
    );
  }

  void _startCampaignLevel(String subType, int level, String primaryType) {
    HapticManager.selectionClick();

    // Only arithmetic operations in campaign mode
    ref.read(gameSessionProvider.notifier).startGame(
      mode: GameMode.campaign,
      level: level,
      operation: primaryType,
      totalQuestions: 45,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const GameScreen(),
      ),
    );
  }
}
