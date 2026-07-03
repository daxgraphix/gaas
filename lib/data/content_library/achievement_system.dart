import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/themes/app_themes.dart';
import '../../l10n/generated/app_localizations.dart';

enum AchievementCategory {
  gameplay,
  progress,
  streak,
  special,
  time,
  collection,
}

typedef AchievementRarity = AppRarity;

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final int points;
  final String iconName;
  final bool isUnlockable;
  final AchievementTrigger? trigger;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.rarity,
    required this.points,
    required this.iconName,
    this.isUnlockable = true,
    this.trigger,
  });

  String getLocalizedTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (id) {
      case 'first_correct': return l10n.firstSteps;
      case 'streak_5': return l10n.onFire;
      case 'streak_10': return l10n.unstoppable;
      case 'heat_master': return l10n.heatIndex;
      case 'flash_calculator': return l10n.flashCalculator;
      case 'streak_25': return l10n.legend;
      case 'accuracy_80_bronze':
      case 'accuracy_80_silver':
      case 'accuracy_80_gold':
      case 'accuracy_80': return l10n.sharpMind;
      case 'accuracy_90': return l10n.precisionExpert;
      case 'accuracy_95': return l10n.accuracyMaster;
      case 'questions_100': return l10n.century;
      case 'questions_500': return l10n.dedicated;
      case 'questions_1000': return l10n.mathGenius;
      case 'perfect_game': return l10n.perfectScore;
      case 'daily_streak_7': return l10n.weeklyChampion;
      case 'daily_streak_30': return l10n.committed;
      case 'campaign_complete': return l10n.campaignMaster;
      case 'duel_master': return l10n.duelMaster;
      case 'stars_10': return l10n.starCollector;
      case 'stars_50': return l10n.stellarPerformer;
      case 'stars_100': return l10n.celestialMaster;
      case 'speed_demon_bronze':
      case 'speed_demon_silver':
      case 'speed_demon_gold': return l10n.speedRun;
      case 'all_operations': return l10n.masterOfOperations;
      case 'high_scorer_1000':
      case 'high_scorer_5000': return l10n.highScorer;
      case 'early_bird': return l10n.earlyBird;
      case 'speed_20_sec': return l10n.lightningFast;
      case 'speed_10_sec': return l10n.instantReaction;
      case 'combo_20': return l10n.comboKing;
      case 'performance_master': return l10n.achiever;
      case 'consistent_player': return l10n.consistentPlayer;
      case 'night_owl': return l10n.nightOwl;
      case 'weekend_warrior': return l10n.weekendWarrior;
      case 'first_place': return l10n.firstPlace;
      case 'all_modes': return l10n.modeExplorer;
      case 'level_perfect_35': return l10n.precisionStrike;
      case 'level_perfect_40': return l10n.masterLevel;
      case 'level_perfect_45': return l10n.perfectLevel;
      case 'campaign_progress_10': return l10n.risingStar;
      case 'campaign_progress_25': return l10n.mathWarrior;
      case 'campaign_progress_50': return l10n.campaignConqueror;
      case 'question_variety': return l10n.questionMaster;
      case 'speed_45_sec_level': return l10n.lightningLevel;
      case 'consistency_master': return l10n.consistencyMaster;
      case 'riddle_master': return l10n.riddleMaster;
      case 'hint_hoarder': return l10n.hintHoarder;
      case 'cross_numbers_novice': return l10n.gridExplorer;
      case 'cross_numbers_speed': return l10n.lightningGrid;
      case 'cross_numbers_master': return l10n.logicArchitect;
      default: return title;
    }
  }

  String getLocalizedDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (id) {
      case 'first_correct': return l10n.firstStepsDesc;
      case 'streak_5': return l10n.onFireDesc;
      case 'streak_10': return l10n.unstoppableDesc;
      case 'heat_master': return l10n.heatIndexDesc;
      case 'flash_calculator': return l10n.flashCalculatorDesc;
      case 'streak_25': return l10n.legendDesc;
      case 'accuracy_80_bronze': return l10n.sharpMindDesc(80);
      case 'accuracy_80_silver': return l10n.sharpMindDesc(85);
      case 'accuracy_80_gold': return l10n.sharpMindDesc(90);
      case 'accuracy_80': return l10n.sharpMindDesc(80);
      case 'accuracy_90': return l10n.sharpMindDesc(90);
      case 'accuracy_95': return l10n.sharpMindDesc(95);
      case 'questions_100': return l10n.centuryDesc;
      case 'questions_500': return l10n.dedicatedDesc;
      case 'questions_1000': return l10n.mathGeniusDesc;
      case 'perfect_game': return l10n.perfectScoreDesc;
      case 'daily_streak_7': return l10n.weeklyChampionDesc;
      case 'daily_streak_30': return l10n.committedDesc;
      case 'campaign_complete': return l10n.campaignMasterDesc;
      case 'duel_master': return l10n.duelMasterDesc;
      case 'stars_10': return l10n.stargazerDesc;
      case 'stars_50': return l10n.stellarPerformerDesc;
      case 'stars_100': return l10n.celestialMasterDesc;
      case 'speed_demon_bronze': return l10n.speedRunDesc(45);
      case 'speed_demon_silver': return l10n.speedRunDesc(30);
      case 'speed_demon_gold': return l10n.speedRunDesc(15);
      case 'all_operations': return l10n.masterOfOperationsDesc;
      case 'high_scorer_1000': return l10n.highScorerDesc(1000);
      case 'high_scorer_5000': return l10n.highScorerDesc(5000);
      case 'early_bird': return l10n.earlyBirdDesc;
      case 'speed_20_sec': return l10n.lightningFastDesc(20);
      case 'speed_10_sec': return l10n.lightningFastDesc(10);
      case 'combo_20': return l10n.comboKingDesc(20);
      case 'performance_master': return l10n.performanceMasterDesc;
      case 'consistent_player': return l10n.consistentPlayerDesc(85, 100);
      case 'night_owl': return l10n.nightOwlDesc;
      case 'weekend_warrior': return l10n.weekendWarriorDesc;
      case 'first_place': return l10n.firstPlaceDesc;
      case 'all_modes': return l10n.modeExplorerDesc;
      case 'level_perfect_35': return l10n.precisionStrikeDesc;
      case 'level_perfect_40': return l10n.masterLevelDesc;
      case 'level_perfect_45': return l10n.perfectLevelDesc;
      case 'campaign_progress_10': return l10n.risingStarDesc;
      case 'campaign_progress_25': return l10n.mathWarriorDesc;
      case 'campaign_progress_50': return l10n.campaignConquerorDesc;
      case 'question_variety': return l10n.questionMasterDesc;
      case 'speed_45_sec_level': return l10n.lightningLevelDesc;
      case 'consistency_master': return l10n.consistentPlayerDesc(90, 50);
      case 'riddle_master': return l10n.riddleMasterDesc;
      case 'hint_hoarder': return l10n.hintHoarderDesc;
      case 'cross_numbers_novice': return l10n.gridExplorerDesc;
      case 'cross_numbers_speed': return l10n.lightningGridDesc;
      case 'cross_numbers_master': return l10n.logicArchitectDesc;
      default: return description;
    }
  }
}

class AchievementTrigger {
  final String type;
  final int targetValue;
  final int? targetTime;
  final String? operation;
  final String? mode;

  const AchievementTrigger({
    required this.type,
    required this.targetValue,
    this.targetTime,
    this.operation,
    this.mode,
  });
}

class UnlockedAchievement {
  final String achievementId;
  final DateTime unlockedAt;
  final int pointsEarned;

  UnlockedAchievement({
    required this.achievementId,
    required this.unlockedAt,
    required this.pointsEarned,
  });
}

final achievementDatabaseProvider = Provider<List<Achievement>>(
  (ref) => _defaultAchievements,
);

final List<Achievement> _defaultAchievements = [
  const Achievement(
    id: 'first_correct',
    title: 'First Steps',
    description: 'Answer your first question correctly',
    category: AchievementCategory.gameplay,
    rarity: AchievementRarity.common,
    points: 10,
    iconName: 'star',
    trigger: AchievementTrigger(type: 'correct_answers', targetValue: 1),
  ),
  const Achievement(
    id: 'streak_5',
    title: 'On Fire',
    description: 'Get 5 correct answers in a row',
    category: AchievementCategory.streak,
    rarity: AchievementRarity.uncommon,
    points: 25,
    iconName: 'local_fire_department',
    trigger: AchievementTrigger(type: 'streak', targetValue: 5),
  ),
  const Achievement(
    id: 'streak_10',
    title: 'Unstoppable',
    description: 'Get 10 correct answers in a row',
    category: AchievementCategory.streak,
    rarity: AchievementRarity.rare,
    points: 50,
    iconName: 'whatshot',
    trigger: AchievementTrigger(type: 'streak', targetValue: 10),
  ),
  const Achievement(
    id: 'heat_master',
    title: 'Heat Master',
    description: 'Maintain a Heat Index above 2.5 for an entire session',
    category: AchievementCategory.special,
    rarity: AchievementRarity.epic,
    points: 200,
    iconName: 'fireplace',
    trigger: AchievementTrigger(type: 'heat', targetValue: 250), // 2.5 * 100 for integer comparison
  ),
  const Achievement(
    id: 'flash_calculator',
    title: 'Flash Calculator',
    description: 'Answer 50 questions with an average time under 2 seconds',
    category: AchievementCategory.time,
    rarity: AchievementRarity.legendary,
    points: 500,
    iconName: 'bolt',
    trigger: AchievementTrigger(type: 'avg_time', targetValue: 50, targetTime: 2),
  ),
  const Achievement(
    id: 'streak_25',
    title: 'Legend',
    description: 'Get 25 correct answers in a row',
    category: AchievementCategory.streak,
    rarity: AchievementRarity.legendary,
    points: 150,
    iconName: 'military_tech',
    trigger: AchievementTrigger(type: 'streak', targetValue: 25),
  ),
  // Multi-tiered Accuracy Achievements
  const Achievement(
    id: 'accuracy_80_bronze',
    title: 'Sharp Mind (Bronze)',
    description: 'Achieve 80% accuracy in any game mode',
    category: AchievementCategory.gameplay,
    rarity: AchievementRarity.common,
    points: 20,
    iconName: 'psychology',
    trigger: AchievementTrigger(type: 'accuracy', targetValue: 80),
  ),
  const Achievement(
    id: 'accuracy_80_silver',
    title: 'Sharp Mind (Silver)',
    description: 'Achieve 85% accuracy in any game mode',
    category: AchievementCategory.gameplay,
    rarity: AchievementRarity.uncommon,
    points: 35,
    iconName: 'psychology',
    trigger: AchievementTrigger(type: 'accuracy', targetValue: 85),
  ),
  const Achievement(
    id: 'accuracy_80_gold',
    title: 'Sharp Mind (Gold)',
    description: 'Achieve 90% accuracy in any game mode',
    category: AchievementCategory.gameplay,
    rarity: AchievementRarity.rare,
    points: 50,
    iconName: 'psychology',
    trigger: AchievementTrigger(type: 'accuracy', targetValue: 90),
  ),
  const Achievement(
    id: 'questions_100',
    title: 'Century',
    description: 'Answer 100 questions',
    category: AchievementCategory.progress,
    rarity: AchievementRarity.uncommon,
    points: 30,
    iconName: 'looks_one',
    trigger: AchievementTrigger(type: 'questions', targetValue: 100),
  ),
  const Achievement(
    id: 'questions_500',
    title: 'Dedicated',
    description: 'Answer 500 questions',
    category: AchievementCategory.progress,
    rarity: AchievementRarity.rare,
    points: 75,
    iconName: 'all_inclusive',
    trigger: AchievementTrigger(type: 'questions', targetValue: 500),
  ),
  const Achievement(
    id: 'questions_1000',
    title: 'Math Champion',
    description: 'Answer 1000 questions',
    category: AchievementCategory.progress,
    rarity: AchievementRarity.epic,
    points: 150,
    iconName: 'workspace_premium',
    trigger: AchievementTrigger(type: 'questions', targetValue: 1000),
  ),
  const Achievement(
    id: 'perfect_game',
    title: 'Perfect Game',
    description: 'Get 100% accuracy in any game',
    category: AchievementCategory.gameplay,
    rarity: AchievementRarity.rare,
    points: 50,
    iconName: 'verified',
    trigger: AchievementTrigger(type: 'perfect', targetValue: 1),
  ),
  // Tiered Speed Achievements
  const Achievement(
    id: 'speed_demon_bronze',
    title: 'Speed Demon (Bronze)',
    description: 'Answer 10 questions in under 45 seconds',
    category: AchievementCategory.time,
    rarity: AchievementRarity.uncommon,
    points: 30,
    iconName: 'bolt',
    trigger: AchievementTrigger(type: 'speed_run', targetValue: 10, targetTime: 45),
  ),
  const Achievement(
    id: 'speed_demon_silver',
    title: 'Speed Demon (Silver)',
    description: 'Answer 10 questions in under 30 seconds',
    category: AchievementCategory.time,
    rarity: AchievementRarity.rare,
    points: 60,
    iconName: 'bolt',
    trigger: AchievementTrigger(type: 'speed_run', targetValue: 10, targetTime: 30),
  ),
  const Achievement(
    id: 'speed_demon_gold',
    title: 'Speed Demon (Gold)',
    description: 'Answer 10 questions in under 15 seconds',
    category: AchievementCategory.time,
    rarity: AchievementRarity.epic,
    points: 100,
    iconName: 'bolt',
    trigger: AchievementTrigger(type: 'speed_run', targetValue: 10, targetTime: 15),
  ),
  const Achievement(
    id: 'daily_streak_7',
    title: 'Weekly Warrior',
    description: 'Play for 7 days in a row',
    category: AchievementCategory.streak,
    rarity: AchievementRarity.rare,
    points: 80,
    iconName: 'date_range',
    trigger: AchievementTrigger(type: 'daily_streak', targetValue: 7),
  ),
  const Achievement(
    id: 'daily_streak_30',
    title: 'Committed',
    description: 'Play for 30 days in a row',
    category: AchievementCategory.streak,
    rarity: AchievementRarity.legendary,
    points: 200,
    iconName: 'calendar_month',
    trigger: AchievementTrigger(type: 'daily_streak', targetValue: 30),
  ),
  const Achievement(
    id: 'campaign_complete',
    title: 'Campaign Hero',
    description: 'Complete all campaign levels',
    category: AchievementCategory.progress,
    rarity: AchievementRarity.legendary,
    points: 300,
    iconName: 'emoji_events',
    trigger: AchievementTrigger(type: 'campaign_complete', targetValue: 1),
  ),
  const Achievement(
    id: 'all_operations',
    title: 'Master of Operations',
    description: 'Use all four operations',
    category: AchievementCategory.collection,
    rarity: AchievementRarity.uncommon,
    points: 40,
    iconName: 'calculate',
    trigger: AchievementTrigger(type: 'operations_used', targetValue: 4),
  ),
  const Achievement(
    id: 'duel_master',
    title: 'Duel Master',
    description: 'Win 10 duel matches',
    category: AchievementCategory.gameplay,
    rarity: AchievementRarity.epic,
    points: 100,
    iconName: 'sports_mma',
    trigger: AchievementTrigger(type: 'duel_wins', targetValue: 10),
  ),
  const Achievement(
    id: 'high_scorer_1000',
    title: 'High Scorer',
    description: 'Score 1000 points in one game',
    category: AchievementCategory.gameplay,
    rarity: AchievementRarity.rare,
    points: 60,
    iconName: 'score',
    trigger: AchievementTrigger(type: 'score', targetValue: 1000),
  ),
  const Achievement(
    id: 'high_scorer_5000',
    title: 'Super High Scorer',
    description: 'Score 5000 points in one game',
    category: AchievementCategory.gameplay,
    rarity: AchievementRarity.epic,
    points: 120,
    iconName: 'leaderboard',
    trigger: AchievementTrigger(type: 'score', targetValue: 5000),
  ),
  const Achievement(
    id: 'early_bird',
    title: 'Early Bird',
    description: 'Play your first game of the day before 8 AM',
    category: AchievementCategory.special,
    rarity: AchievementRarity.uncommon,
    points: 20,
    iconName: 'wb_sunny',
  ),
  const Achievement(
    id: 'accuracy_80',
    title: 'Sharp Mind',
    description: 'Achieve 80% accuracy in any game mode',
    category: AchievementCategory.gameplay,
    rarity: AchievementRarity.uncommon,
    points: 35,
    iconName: 'psychology',
    trigger: AchievementTrigger(type: 'accuracy', targetValue: 80),
  ),
  const Achievement(
    id: 'accuracy_90',
    title: 'Precision Expert',
    description: 'Achieve 90% accuracy in any game mode',
    category: AchievementCategory.gameplay,
    rarity: AchievementRarity.rare,
    points: 70,
    iconName: 'center_focus_strong',
    trigger: AchievementTrigger(type: 'accuracy', targetValue: 90),
  ),
  const Achievement(
    id: 'accuracy_95',
    title: 'Accuracy Master',
    description: 'Achieve 95% accuracy in any game mode',
    category: AchievementCategory.gameplay,
    rarity: AchievementRarity.epic,
    points: 100,
    iconName: 'gps_fixed',
    trigger: AchievementTrigger(type: 'accuracy', targetValue: 95),
  ),
  const Achievement(
    id: 'speed_20_sec',
    title: 'Lightning Fast',
    description: 'Complete a level in under 20 seconds',
    category: AchievementCategory.time,
    rarity: AchievementRarity.rare,
    points: 45,
    iconName: 'flash_on',
    trigger: AchievementTrigger(type: 'level_time', targetValue: 20),
  ),
  const Achievement(
    id: 'speed_10_sec',
    title: 'Instant Reaction',
    description: 'Complete a level in under 10 seconds',
    category: AchievementCategory.time,
    rarity: AchievementRarity.epic,
    points: 80,
    iconName: 'electric_bolt',
    trigger: AchievementTrigger(type: 'level_time', targetValue: 10),
  ),
  const Achievement(
    id: 'combo_20',
    title: 'Combo King',
    description: 'Achieve a 20x combo multiplier',
    category: AchievementCategory.streak,
    rarity: AchievementRarity.epic,
    points: 90,
    iconName: 'trending_up',
    trigger: AchievementTrigger(type: 'combo', targetValue: 20),
  ),
  const Achievement(
    id: 'performance_master',
    title: 'Performance Master',
    description: 'Achieve 95% accuracy with average time under 15 seconds',
    category: AchievementCategory.special,
    rarity: AchievementRarity.legendary,
    points: 250,
    iconName: 'workspace_premium',
    trigger: AchievementTrigger(type: 'performance_score', targetValue: 95),
  ),
  const Achievement(
    id: 'consistent_player',
    title: 'Consistent Player',
    description: 'Maintain 85% accuracy over 100 consecutive questions',
    category: AchievementCategory.progress,
    rarity: AchievementRarity.rare,
    points: 85,
    iconName: 'timeline',
    trigger: AchievementTrigger(type: 'consistency', targetValue: 85),
  ),
  const Achievement(
    id: 'night_owl',
    title: 'Night Owl',
    description: 'Play a game after 10 PM',
    category: AchievementCategory.special,
    rarity: AchievementRarity.uncommon,
    points: 20,
    iconName: 'nightlight',
  ),
  const Achievement(
    id: 'weekend_warrior',
    title: 'Weekend Warrior',
    description: 'Play on both Saturday and Sunday',
    category: AchievementCategory.special,
    rarity: AchievementRarity.rare,
    points: 50,
    iconName: 'weekend',
  ),
  const Achievement(
    id: 'first_place',
    title: 'First Place',
    description: 'Reach #1 on the leaderboard',
    category: AchievementCategory.special,
    rarity: AchievementRarity.legendary,
    points: 250,
    iconName: 'emoji_events',
    trigger: AchievementTrigger(type: 'leaderboard_rank', targetValue: 1),
  ),
  const Achievement(
    id: 'all_modes',
    title: 'Mode Explorer',
    description: 'Play all game modes',
    category: AchievementCategory.collection,
    rarity: AchievementRarity.uncommon,
    points: 35,
    iconName: 'sports_esports',
    trigger: AchievementTrigger(type: 'modes_played', targetValue: 8),
  ),
  const Achievement(
    id: 'level_perfect_35',
    title: 'Precision Strike',
    description: 'Complete a level with 35+ correct answers out of 45',
    category: AchievementCategory.gameplay,
    rarity: AchievementRarity.rare,
    points: 75,
    iconName: 'gps_fixed',
    trigger: AchievementTrigger(type: 'level_score_35_plus', targetValue: 1),
  ),
  const Achievement(
    id: 'level_perfect_40',
    title: 'Master Level',
    description: 'Complete a level with 40+ correct answers out of 45',
    category: AchievementCategory.gameplay,
    rarity: AchievementRarity.epic,
    points: 100,
    iconName: 'military_tech',
    trigger: AchievementTrigger(type: 'level_score_40_plus', targetValue: 1),
  ),
  const Achievement(
    id: 'level_perfect_45',
    title: 'Perfect Level',
    description: 'Complete a level with all 45 questions correct',
    category: AchievementCategory.gameplay,
    rarity: AchievementRarity.legendary,
    points: 200,
    iconName: 'stars',
    trigger: AchievementTrigger(type: 'level_score_45', targetValue: 1),
  ),
  const Achievement(
    id: 'campaign_progress_10',
    title: 'Rising Star',
    description: 'Unlock 10 campaign levels',
    category: AchievementCategory.progress,
    rarity: AchievementRarity.uncommon,
    points: 40,
    iconName: 'trending_up',
    trigger: AchievementTrigger(type: 'campaign_levels_unlocked', targetValue: 10),
  ),
  const Achievement(
    id: 'campaign_progress_25',
    title: 'Math Warrior',
    description: 'Unlock 25 campaign levels',
    category: AchievementCategory.progress,
    rarity: AchievementRarity.rare,
    points: 80,
    iconName: 'local_fire_department',
    trigger: AchievementTrigger(type: 'campaign_levels_unlocked', targetValue: 25),
  ),
  const Achievement(
    id: 'campaign_progress_50',
    title: 'Campaign Conqueror',
    description: 'Complete all 50 campaign levels',
    category: AchievementCategory.progress,
    rarity: AchievementRarity.legendary,
    points: 300,
    iconName: 'emoji_events',
    trigger: AchievementTrigger(type: 'campaign_levels_unlocked', targetValue: 50),
  ),
  const Achievement(
    id: 'question_variety',
    title: 'Question Master',
    description: 'Answer 1000 questions across different categories',
    category: AchievementCategory.collection,
    rarity: AchievementRarity.epic,
    points: 120,
    iconName: 'category',
    trigger: AchievementTrigger(type: 'questions_variety', targetValue: 1000),
  ),
  const Achievement(
    id: 'speed_45_sec_level',
    title: 'Lightning Level',
    description: 'Complete a 45-question level in under 45 seconds',
    category: AchievementCategory.time,
    rarity: AchievementRarity.legendary,
    points: 150,
    iconName: 'flash_on',
    trigger: AchievementTrigger(type: 'level_time_45_sec', targetValue: 45),
  ),
  const Achievement(
    id: 'consistency_master',
    title: 'Consistency Master',
    description: 'Maintain 90% accuracy over 50 consecutive questions',
    category: AchievementCategory.progress,
    rarity: AchievementRarity.epic,
    points: 110,
    iconName: 'timeline',
    trigger: AchievementTrigger(type: 'consistency_90_percent', targetValue: 50),
  ),
  const Achievement(
    id: 'stars_10',
    title: 'Star Collector',
    description: 'Earn your first 10 stars',
    category: AchievementCategory.collection,
    rarity: AchievementRarity.uncommon,
    points: 30,
    iconName: 'star',
    trigger: AchievementTrigger(type: 'total_stars', targetValue: 10),
  ),
  const Achievement(
    id: 'stars_50',
    title: 'Stellar Performer',
    description: 'Earn 50 stars',
    category: AchievementCategory.collection,
    rarity: AchievementRarity.rare,
    points: 75,
    iconName: 'stars',
    trigger: AchievementTrigger(type: 'total_stars', targetValue: 50),
  ),
  const Achievement(
    id: 'stars_100',
    title: 'Celestial Master',
    description: 'Earn 100 stars',
    category: AchievementCategory.collection,
    rarity: AchievementRarity.epic,
    points: 150,
    iconName: 'workspace_premium',
    trigger: AchievementTrigger(type: 'total_stars', targetValue: 100),
  ),
  const Achievement(
    id: 'riddle_master',
    title: 'Riddle Master',
    description: 'Complete all 30 riddle levels',
    category: AchievementCategory.progress,
    rarity: AchievementRarity.legendary,
    points: 400,
    iconName: 'psychology',
    trigger: AchievementTrigger(type: 'riddle_levels_completed', targetValue: 30),
  ),
  const Achievement(
    id: 'hint_hoarder',
    title: 'Hint Hoarder',
    description: 'Obtain 50 hints',
    category: AchievementCategory.collection,
    rarity: AchievementRarity.uncommon,
    points: 40,
    iconName: 'lightbulb',
    trigger: AchievementTrigger(type: 'hints_obtained', targetValue: 50),
  ),
  const Achievement(
    id: 'cross_numbers_novice',
    title: 'Grid Explorer',
    description: 'Complete 5 Cross Numbers puzzles',
    category: AchievementCategory.progress,
    rarity: AchievementRarity.common,
    points: 20,
    iconName: 'grid_view',
    trigger: AchievementTrigger(type: 'cross_numbers_completed', targetValue: 5),
  ),
  const Achievement(
    id: 'cross_numbers_speed',
    title: 'Lightning Grid',
    description: 'Complete a 7x7 Cross Numbers puzzle in under 90 seconds',
    category: AchievementCategory.time,
    rarity: AchievementRarity.rare,
    points: 100,
    iconName: 'speed',
    trigger: AchievementTrigger(type: 'cross_numbers_speed_7x7', targetValue: 1),
  ),
  const Achievement(
    id: 'cross_numbers_master',
    title: 'Logic Architect',
    description: 'Complete 50 Cross Numbers puzzles',
    category: AchievementCategory.progress,
    rarity: AchievementRarity.epic,
    points: 250,
    iconName: 'architecture',
    trigger: AchievementTrigger(type: 'cross_numbers_completed', targetValue: 50),
  ),
];

class AchievementState {
  final List<UnlockedAchievement> unlockedAchievements;
  final Map<String, int> progressTrackers;

  AchievementState({
    this.unlockedAchievements = const [],
    this.progressTrackers = const {},
  });

  AchievementState copyWith({
    List<UnlockedAchievement>? unlockedAchievements,
    Map<String, int>? progressTrackers,
  }) {
    return AchievementState(
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      progressTrackers: progressTrackers ?? this.progressTrackers,
    );
  }
}

final achievementStateProvider =
    StateNotifierProvider<AchievementNotifier, AchievementState>((ref) {
      return AchievementNotifier();
    });

class AchievementNotifier extends StateNotifier<AchievementState> {
  AchievementNotifier() : super(AchievementState());

  void initialize() {
    // Initialization logic if needed, or just to satisfy the call
  }

  bool isUnlocked(String id) {
    return state.unlockedAchievements.any((a) => a.achievementId == id);
  }

  void unlock(Achievement achievement) {
    if (isUnlocked(achievement.id)) return;

    final unlocked = UnlockedAchievement(
      achievementId: achievement.id,
      unlockedAt: DateTime.now(),
      pointsEarned: achievement.points,
    );

    state = state.copyWith(
      unlockedAchievements: [...state.unlockedAchievements, unlocked],
    );
  }

  void updateProgress(String type, int value) {
    final newTrackers = Map<String, int>.from(state.progressTrackers);
    newTrackers[type] = value;
    state = state.copyWith(progressTrackers: newTrackers);
  }

  int getProgress(String type) {
    return state.progressTrackers[type] ?? 0;
  }

  void checkAndUnlock(String type, int value, List<Achievement> achievements, {int? timeValue}) {
    updateProgress(type, value);

    for (final achievement in achievements) {
      if (achievement.trigger?.type == type && !isUnlocked(achievement.id)) {
        bool conditionMet = value >= achievement.trigger!.targetValue;
        
        // Handle time-based secondary conditions
        if (conditionMet && achievement.trigger!.targetTime != null && timeValue != null) {
          conditionMet = timeValue <= achievement.trigger!.targetTime!;
        }

        if (conditionMet) {
          unlock(achievement);
        }
      }
    }
  }

  int get totalPoints {
    return state.unlockedAchievements.fold(0, (sum, a) => sum + a.pointsEarned);
  }

  int get unlockedCount {
    return state.unlockedAchievements.length;
  }
}

class AchievementReward {
  final int totalPoints;
  final int level;

  AchievementReward({required this.totalPoints, required this.level});

  static AchievementReward fromPoints(int points) {
    return AchievementReward(
      totalPoints: points,
      level: _calculateLevel(points),
    );
  }

  static int _calculateLevel(int points) {
    if (points >= 1000) return 10;
    if (points >= 500) return 8;
    if (points >= 250) return 6;
    if (points >= 100) return 4;
    if (points >= 50) return 3;
    if (points >= 20) return 2;
    return 1;
  }

  int get pointsToNextLevel {
    switch (level) {
      case 1:
        return 20 - totalPoints;
      case 2:
        return 50 - totalPoints;
      case 3:
        return 100 - totalPoints;
      case 4:
        return 250 - totalPoints;
      case 5:
        return 500 - totalPoints;
      case 6:
        return 1000 - totalPoints;
      default:
        return 0;
    }
  }
}

final achievementRewardProvider = Provider<AchievementReward>((ref) {
  final achievementState = ref.watch(achievementStateProvider);
  return AchievementReward.fromPoints(
    achievementState.unlockedAchievements.fold(
      0,
      (sum, a) => sum + a.pointsEarned,
    ),
  );
});

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.isUnlocked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class AchievementDialog extends StatelessWidget {
  final Achievement achievement;

  const AchievementDialog({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
