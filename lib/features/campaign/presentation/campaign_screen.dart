import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../game/logic/game_session_provider.dart';
import '../../game/ui/game_screen.dart';
import 'widgets/sync_map.dart';

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
    _loadUnlockedLevels();
  }

  void _loadUnlockedLevels() {
    ref.read(levelProgressProvider.notifier).loadProgress();
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
            child: Container(
              color: theme.scaffoldBackgroundColor,
              child: Stack(
                children: [
                  Positioned(
                    top: -100,
                    right: -100,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.1),
                            theme.colorScheme.primary.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    left: -100,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            theme.colorScheme.secondary.withValues(alpha: 0.05),
                            theme.colorScheme.secondary.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          TabBarView(
            controller: _tabController,
            children: [
              SyncMap(
                operation: 'addition',
                progressList: progressMap['addition'] ?? [],
                onLevelTap: (level) => _startCampaignLevel('arithmetic', level, 'addition'),
              ),
              SyncMap(
                operation: 'subtraction',
                progressList: progressMap['subtraction'] ?? [],
                onLevelTap: (level) => _startCampaignLevel('arithmetic', level, 'subtraction'),
              ),
              SyncMap(
                operation: 'multiplication',
                progressList: progressMap['multiplication'] ?? [],
                onLevelTap: (level) => _startCampaignLevel('arithmetic', level, 'multiplication'),
              ),
              SyncMap(
                operation: 'division',
                progressList: progressMap['division'] ?? [],
                onLevelTap: (level) => _startCampaignLevel('arithmetic', level, 'division'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _startCampaignLevel(String subType, int level, String primaryType) async {
    ref.read(soundManagerProvider).playGameStart();

    // Questions count increases from 50 to 60 after level 50
    final totalQuestions = level > 50 ? 60 : 50;

    await ref.read(gameSessionProvider.notifier).startGame(
      mode: GameMode.campaign,
      level: level,
      operation: primaryType,
      totalQuestions: totalQuestions,
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const GameScreen(),
        ),
      );
    }
  }
}

