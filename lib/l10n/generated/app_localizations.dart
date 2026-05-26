import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sw'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GAAS'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @campaign.
  ///
  /// In en, this message translates to:
  /// **'Campaign'**
  String get campaign;

  /// No description provided for @arcade.
  ///
  /// In en, this message translates to:
  /// **'Arcade'**
  String get arcade;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @practice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practice;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startGame;

  /// No description provided for @continueGame.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueGame;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @totalPoints.
  ///
  /// In en, this message translates to:
  /// **'Total Points'**
  String get totalPoints;

  /// No description provided for @levelsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Levels Completed'**
  String get levelsCompleted;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'ACCURACY'**
  String get accuracy;

  /// No description provided for @timePlayed.
  ///
  /// In en, this message translates to:
  /// **'Time Played'**
  String get timePlayed;

  /// No description provided for @addition.
  ///
  /// In en, this message translates to:
  /// **'Addition'**
  String get addition;

  /// No description provided for @subtraction.
  ///
  /// In en, this message translates to:
  /// **'Subtraction'**
  String get subtraction;

  /// No description provided for @multiplication.
  ///
  /// In en, this message translates to:
  /// **'Multiplication'**
  String get multiplication;

  /// No description provided for @division.
  ///
  /// In en, this message translates to:
  /// **'Division'**
  String get division;

  /// No description provided for @visualCounting.
  ///
  /// In en, this message translates to:
  /// **'Visual Counting'**
  String get visualCounting;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @stars.
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get stars;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @unlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'SCORE'**
  String get score;

  /// No description provided for @lives.
  ///
  /// In en, this message translates to:
  /// **'Lives'**
  String get lives;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOver;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect!'**
  String get incorrect;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @nextLevel.
  ///
  /// In en, this message translates to:
  /// **'Next Level'**
  String get nextLevel;

  /// No description provided for @backToMenu.
  ///
  /// In en, this message translates to:
  /// **'Back to Menu'**
  String get backToMenu;

  /// No description provided for @scoreAttack.
  ///
  /// In en, this message translates to:
  /// **'Score Attack'**
  String get scoreAttack;

  /// No description provided for @endless.
  ///
  /// In en, this message translates to:
  /// **'Endless'**
  String get endless;

  /// No description provided for @duel.
  ///
  /// In en, this message translates to:
  /// **'Duel'**
  String get duel;

  /// No description provided for @flash.
  ///
  /// In en, this message translates to:
  /// **'Flash'**
  String get flash;

  /// No description provided for @scoreAttackDesc.
  ///
  /// In en, this message translates to:
  /// **'60 seconds to score as high as possible'**
  String get scoreAttackDesc;

  /// No description provided for @endlessDesc.
  ///
  /// In en, this message translates to:
  /// **'3 lives - keep playing as long as you can'**
  String get endlessDesc;

  /// No description provided for @duelDesc.
  ///
  /// In en, this message translates to:
  /// **'Race against the AI'**
  String get duelDesc;

  /// No description provided for @flashDesc.
  ///
  /// In en, this message translates to:
  /// **'Memory challenge - recall the numbers'**
  String get flashDesc;

  /// No description provided for @simulation.
  ///
  /// In en, this message translates to:
  /// **'Simulation'**
  String get simulation;

  /// No description provided for @paper.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get paper;

  /// No description provided for @midnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get midnight;

  /// No description provided for @forest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get forest;

  /// No description provided for @selectOperation.
  ///
  /// In en, this message translates to:
  /// **'Select Operation'**
  String get selectOperation;

  /// No description provided for @selectLevel.
  ///
  /// In en, this message translates to:
  /// **'Select Level'**
  String get selectLevel;

  /// No description provided for @customize.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get customize;

  /// No description provided for @numberRange.
  ///
  /// In en, this message translates to:
  /// **'Number Range'**
  String get numberRange;

  /// No description provided for @timer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timer;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @countTheShapes.
  ///
  /// In en, this message translates to:
  /// **'Count the shapes!'**
  String get countTheShapes;

  /// No description provided for @enterAnswer.
  ///
  /// In en, this message translates to:
  /// **'Enter your answer'**
  String get enterAnswer;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @dots.
  ///
  /// In en, this message translates to:
  /// **'Dots'**
  String get dots;

  /// No description provided for @triangles.
  ///
  /// In en, this message translates to:
  /// **'Triangles'**
  String get triangles;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutes;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get seconds;

  /// No description provided for @highScore.
  ///
  /// In en, this message translates to:
  /// **'High Score'**
  String get highScore;

  /// No description provided for @newHighScore.
  ///
  /// In en, this message translates to:
  /// **'New High Score!'**
  String get newHighScore;

  /// No description provided for @avatar.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get avatar;

  /// No description provided for @shape.
  ///
  /// In en, this message translates to:
  /// **'Shape'**
  String get shape;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @customMix.
  ///
  /// In en, this message translates to:
  /// **'Custom Mix'**
  String get customMix;

  /// No description provided for @customMixArithmetic.
  ///
  /// In en, this message translates to:
  /// **'Custom Mix Arithmetic'**
  String get customMixArithmetic;

  /// No description provided for @operationMatrix.
  ///
  /// In en, this message translates to:
  /// **'Operation Matrix'**
  String get operationMatrix;

  /// No description provided for @difficultyLevel.
  ///
  /// In en, this message translates to:
  /// **'DIFFICULTY_LEVEL'**
  String get difficultyLevel;

  /// No description provided for @initiateMixSequence.
  ///
  /// In en, this message translates to:
  /// **'Start Mix'**
  String get initiateMixSequence;

  /// No description provided for @sessionMetrics.
  ///
  /// In en, this message translates to:
  /// **'Session Metrics'**
  String get sessionMetrics;

  /// No description provided for @gameSession.
  ///
  /// In en, this message translates to:
  /// **'Game Session'**
  String get gameSession;

  /// No description provided for @configuration.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get configuration;

  /// No description provided for @terminateSession.
  ///
  /// In en, this message translates to:
  /// **'End Session'**
  String get terminateSession;

  /// No description provided for @requestHint.
  ///
  /// In en, this message translates to:
  /// **'Request Hint'**
  String get requestHint;

  /// No description provided for @systemHint.
  ///
  /// In en, this message translates to:
  /// **'System Hint'**
  String get systemHint;

  /// No description provided for @acknowledge.
  ///
  /// In en, this message translates to:
  /// **'Acknowledge'**
  String get acknowledge;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// No description provided for @mixModeProtocol.
  ///
  /// In en, this message translates to:
  /// **'Mix Mode Protocol'**
  String get mixModeProtocol;

  /// No description provided for @coreMetrics.
  ///
  /// In en, this message translates to:
  /// **'Core Metrics'**
  String get coreMetrics;

  /// No description provided for @progressionStatus.
  ///
  /// In en, this message translates to:
  /// **'Progression Status'**
  String get progressionStatus;

  /// No description provided for @performanceAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Performance Analytics'**
  String get performanceAnalytics;

  /// No description provided for @realTimePerformance.
  ///
  /// In en, this message translates to:
  /// **'Real Time Performance'**
  String get realTimePerformance;

  /// No description provided for @levelCompletionStats.
  ///
  /// In en, this message translates to:
  /// **'Level Completion Stats'**
  String get levelCompletionStats;

  /// No description provided for @reactionAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Reaction Analytics'**
  String get reactionAnalytics;

  /// No description provided for @speedMetrics.
  ///
  /// In en, this message translates to:
  /// **'Speed Metrics'**
  String get speedMetrics;

  /// No description provided for @temporalInvestment.
  ///
  /// In en, this message translates to:
  /// **'TEMPORAL_INVESTMENT'**
  String get temporalInvestment;

  /// No description provided for @realTimeAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Real Time Accuracy'**
  String get realTimeAccuracy;

  /// No description provided for @levelMastery.
  ///
  /// In en, this message translates to:
  /// **'Level Mastery'**
  String get levelMastery;

  /// No description provided for @achievementProgress.
  ///
  /// In en, this message translates to:
  /// **'Achievement Progress'**
  String get achievementProgress;

  /// No description provided for @endOfReport.
  ///
  /// In en, this message translates to:
  /// **'End of Report'**
  String get endOfReport;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @calc.
  ///
  /// In en, this message translates to:
  /// **'Calc'**
  String get calc;

  /// No description provided for @dailyMissions.
  ///
  /// In en, this message translates to:
  /// **'Daily Missions'**
  String get dailyMissions;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @adventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get adventure;

  /// No description provided for @gameModes.
  ///
  /// In en, this message translates to:
  /// **'🎮 Game Modes'**
  String get gameModes;

  /// No description provided for @puzzleWorld.
  ///
  /// In en, this message translates to:
  /// **'Puzzle World'**
  String get puzzleWorld;

  /// No description provided for @resourcesTools.
  ///
  /// In en, this message translates to:
  /// **'Resources & Tools'**
  String get resourcesTools;

  /// No description provided for @logicRiddles.
  ///
  /// In en, this message translates to:
  /// **'Logic Riddles'**
  String get logicRiddles;

  /// No description provided for @calculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get calculator;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @avatarShop.
  ///
  /// In en, this message translates to:
  /// **'Avatar Shop'**
  String get avatarShop;

  /// No description provided for @visualTheme.
  ///
  /// In en, this message translates to:
  /// **'Visual Theme'**
  String get visualTheme;

  /// No description provided for @audioOutput.
  ///
  /// In en, this message translates to:
  /// **'Audio Output'**
  String get audioOutput;

  /// No description provided for @hapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @arithmeticMixGenerator.
  ///
  /// In en, this message translates to:
  /// **'Arithmetic Mix Generator'**
  String get arithmeticMixGenerator;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @nextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next Question'**
  String get nextQuestion;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'HINT'**
  String get hint;

  /// No description provided for @level_1.
  ///
  /// In en, this message translates to:
  /// **'Level 1'**
  String get level_1;

  /// No description provided for @level_2.
  ///
  /// In en, this message translates to:
  /// **'Level 2'**
  String get level_2;

  /// No description provided for @level_3.
  ///
  /// In en, this message translates to:
  /// **'Level 3'**
  String get level_3;

  /// No description provided for @level_4.
  ///
  /// In en, this message translates to:
  /// **'Level 4'**
  String get level_4;

  /// No description provided for @level_5.
  ///
  /// In en, this message translates to:
  /// **'Level 5'**
  String get level_5;

  /// No description provided for @level_6.
  ///
  /// In en, this message translates to:
  /// **'Level 6'**
  String get level_6;

  /// No description provided for @level_7.
  ///
  /// In en, this message translates to:
  /// **'Level 7'**
  String get level_7;

  /// No description provided for @level_8.
  ///
  /// In en, this message translates to:
  /// **'Level 8'**
  String get level_8;

  /// No description provided for @level_9.
  ///
  /// In en, this message translates to:
  /// **'Level 9'**
  String get level_9;

  /// No description provided for @level_10.
  ///
  /// In en, this message translates to:
  /// **'Level 10'**
  String get level_10;

  /// No description provided for @plus.
  ///
  /// In en, this message translates to:
  /// **'+'**
  String get plus;

  /// No description provided for @minus.
  ///
  /// In en, this message translates to:
  /// **'-'**
  String get minus;

  /// No description provided for @multiply.
  ///
  /// In en, this message translates to:
  /// **'×'**
  String get multiply;

  /// No description provided for @divide.
  ///
  /// In en, this message translates to:
  /// **'÷'**
  String get divide;

  /// No description provided for @hotStreak.
  ///
  /// In en, this message translates to:
  /// **'🔥 HOT STREAK!'**
  String get hotStreak;

  /// No description provided for @unstoppable.
  ///
  /// In en, this message translates to:
  /// **'🌟 UNSTOPPABLE!'**
  String get unstoppable;

  /// No description provided for @keepItUp.
  ///
  /// In en, this message translates to:
  /// **'⚡ KEEP IT UP!'**
  String get keepItUp;

  /// No description provided for @streakBroken.
  ///
  /// In en, this message translates to:
  /// **'💔 STREAK BROKEN!'**
  String get streakBroken;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @swahili.
  ///
  /// In en, this message translates to:
  /// **'Swahili'**
  String get swahili;

  /// No description provided for @swahiliTanzania.
  ///
  /// In en, this message translates to:
  /// **'Swahili (Tanzania)'**
  String get swahiliTanzania;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed'**
  String get languageChanged;

  /// No description provided for @exportReport.
  ///
  /// In en, this message translates to:
  /// **'Export Report'**
  String get exportReport;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'STREAK'**
  String get streak;

  /// No description provided for @accuracyTrends.
  ///
  /// In en, this message translates to:
  /// **'Accuracy Trends'**
  String get accuracyTrends;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'HELP'**
  String get help;

  /// No description provided for @refreshAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Refresh Analytics'**
  String get refreshAnalytics;

  /// No description provided for @avgSession.
  ///
  /// In en, this message translates to:
  /// **'Avg Session'**
  String get avgSession;

  /// No description provided for @sysOp.
  ///
  /// In en, this message translates to:
  /// **'SYS_OP'**
  String get sysOp;

  /// No description provided for @neuralAccuracy.
  ///
  /// In en, this message translates to:
  /// **'NEURAL_ACCURACY'**
  String get neuralAccuracy;

  /// No description provided for @coreStars.
  ///
  /// In en, this message translates to:
  /// **'CORE_STARS'**
  String get coreStars;

  /// No description provided for @unitsCleared.
  ///
  /// In en, this message translates to:
  /// **'UNITS_CLEARED'**
  String get unitsCleared;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get status;

  /// No description provided for @missionActive.
  ///
  /// In en, this message translates to:
  /// **'MISSION_ACTIVE'**
  String get missionActive;

  /// No description provided for @endOfTransmission.
  ///
  /// In en, this message translates to:
  /// **'END_OF_TRANSMISSION'**
  String get endOfTransmission;

  /// No description provided for @exportProtocol.
  ///
  /// In en, this message translates to:
  /// **'EXPORT_PROTOCOL'**
  String get exportProtocol;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'DISMISS'**
  String get dismiss;

  /// No description provided for @debriefCopied.
  ///
  /// In en, this message translates to:
  /// **'DEBRIEF_COPIED_TO_CLIPBOARD'**
  String get debriefCopied;

  /// No description provided for @copyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'COPY_TO_CLIPBOARD'**
  String get copyToClipboard;

  /// No description provided for @neuralEfficiencyIndex.
  ///
  /// In en, this message translates to:
  /// **'NEURAL_EFFICIENCY_INDEX'**
  String get neuralEfficiencyIndex;

  /// No description provided for @performanceScore.
  ///
  /// In en, this message translates to:
  /// **'PERFORMANCE_SCORE'**
  String get performanceScore;

  /// No description provided for @avgSpeed.
  ///
  /// In en, this message translates to:
  /// **'Avg Speed'**
  String get avgSpeed;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'HIGH'**
  String get high;

  /// No description provided for @med.
  ///
  /// In en, this message translates to:
  /// **'MED'**
  String get med;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'LOW'**
  String get low;

  /// No description provided for @accuracyProgression.
  ///
  /// In en, this message translates to:
  /// **'ACCURACY_PROGRESSION'**
  String get accuracyProgression;

  /// No description provided for @peakAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Peak Accuracy'**
  String get peakAccuracy;

  /// No description provided for @responseAnalytics.
  ///
  /// In en, this message translates to:
  /// **'RESPONSE_ANALYTICS'**
  String get responseAnalytics;

  /// No description provided for @avgResponse.
  ///
  /// In en, this message translates to:
  /// **'AVG_RESPONSE'**
  String get avgResponse;

  /// No description provided for @fastest.
  ///
  /// In en, this message translates to:
  /// **'Fastest'**
  String get fastest;

  /// No description provided for @improvement.
  ///
  /// In en, this message translates to:
  /// **'Improvement'**
  String get improvement;

  /// No description provided for @livePerformanceMetrics.
  ///
  /// In en, this message translates to:
  /// **'LIVE_PERFORMANCE_METRICS'**
  String get livePerformanceMetrics;

  /// No description provided for @currentAccuracy.
  ///
  /// In en, this message translates to:
  /// **'CURRENT_ACCURACY'**
  String get currentAccuracy;

  /// No description provided for @sessionTime.
  ///
  /// In en, this message translates to:
  /// **'SESSION_TIME'**
  String get sessionTime;

  /// No description provided for @activeStreak.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE_STREAK'**
  String get activeStreak;

  /// No description provided for @calculating.
  ///
  /// In en, this message translates to:
  /// **'CALCULATING...'**
  String get calculating;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'ADVANCED'**
  String get advanced;

  /// No description provided for @performanceTrend.
  ///
  /// In en, this message translates to:
  /// **'PERFORMANCE_TREND'**
  String get performanceTrend;

  /// No description provided for @reactionTimeAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Reaction Time Analysis'**
  String get reactionTimeAnalysis;

  /// No description provided for @operationUsage.
  ///
  /// In en, this message translates to:
  /// **'Operation Usage'**
  String get operationUsage;

  /// No description provided for @levelMasteryBreakdown.
  ///
  /// In en, this message translates to:
  /// **'LEVEL_MASTERY_BREAKDOWN'**
  String get levelMasteryBreakdown;

  /// No description provided for @perfectLevels.
  ///
  /// In en, this message translates to:
  /// **'PERFECT_LEVELS'**
  String get perfectLevels;

  /// No description provided for @levelsWith35Plus.
  ///
  /// In en, this message translates to:
  /// **'Levels with 35+ correct'**
  String get levelsWith35Plus;

  /// No description provided for @highPerformance.
  ///
  /// In en, this message translates to:
  /// **'HIGH_PERFORMANCE'**
  String get highPerformance;

  /// No description provided for @levelsWith30Plus.
  ///
  /// In en, this message translates to:
  /// **'Levels with 30+ correct'**
  String get levelsWith30Plus;

  /// No description provided for @goodProgress.
  ///
  /// In en, this message translates to:
  /// **'GOOD_PROGRESS'**
  String get goodProgress;

  /// No description provided for @levelsWith25Plus.
  ///
  /// In en, this message translates to:
  /// **'Levels with 25+ correct'**
  String get levelsWith25Plus;

  /// No description provided for @totalAttempts.
  ///
  /// In en, this message translates to:
  /// **'TOTAL_ATTEMPTS'**
  String get totalAttempts;

  /// No description provided for @totalLevelsAttempted.
  ///
  /// In en, this message translates to:
  /// **'Total levels attempted'**
  String get totalLevelsAttempted;

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get player;

  /// No description provided for @del.
  ///
  /// In en, this message translates to:
  /// **'DEL'**
  String get del;

  /// No description provided for @mc.
  ///
  /// In en, this message translates to:
  /// **'MC'**
  String get mc;

  /// No description provided for @mr.
  ///
  /// In en, this message translates to:
  /// **'MR'**
  String get mr;

  /// No description provided for @divByZero.
  ///
  /// In en, this message translates to:
  /// **'DIV BY ZERO'**
  String get divByZero;

  /// No description provided for @readyToChallenge.
  ///
  /// In en, this message translates to:
  /// **'🎯 Ready to Challenge Yourself?'**
  String get readyToChallenge;

  /// No description provided for @masterMathematicsDesc.
  ///
  /// In en, this message translates to:
  /// **'Master mathematics through engaging games and track your progress.'**
  String get masterMathematicsDesc;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'📊 Your Progress'**
  String get yourProgress;

  /// No description provided for @starsEarned.
  ///
  /// In en, this message translates to:
  /// **'Stars Earned'**
  String get starsEarned;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'⚡ Quick Actions'**
  String get quickActions;

  /// No description provided for @dailyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get dailyChallenge;

  /// No description provided for @completeTodaysChallenge.
  ///
  /// In en, this message translates to:
  /// **'Complete today\'s math challenge to earn bonus rewards!'**
  String get completeTodaysChallenge;

  /// No description provided for @challengeReward.
  ///
  /// In en, this message translates to:
  /// **'🔥 5 problems • 100 XP reward'**
  String get challengeReward;

  /// No description provided for @completeLevelsProgressively.
  ///
  /// In en, this message translates to:
  /// **'Complete levels progressively'**
  String get completeLevelsProgressively;

  /// No description provided for @fastPacedChallenges.
  ///
  /// In en, this message translates to:
  /// **'Fast-paced challenges'**
  String get fastPacedChallenges;

  /// No description provided for @improveSpecificSkills.
  ///
  /// In en, this message translates to:
  /// **'Improve specific skills'**
  String get improveSpecificSkills;

  /// No description provided for @createYourOwnChallenges.
  ///
  /// In en, this message translates to:
  /// **'Create your own challenges'**
  String get createYourOwnChallenges;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @goodNight.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get goodNight;

  /// No description provided for @welcomeToGAAS.
  ///
  /// In en, this message translates to:
  /// **'Welcome to GAAS'**
  String get welcomeToGAAS;

  /// No description provided for @quickStart.
  ///
  /// In en, this message translates to:
  /// **'Quick Start'**
  String get quickStart;

  /// No description provided for @campaignMode.
  ///
  /// In en, this message translates to:
  /// **'Campaign Mode'**
  String get campaignMode;

  /// No description provided for @startYourMathematicalJourney.
  ///
  /// In en, this message translates to:
  /// **'Start your mathematical journey'**
  String get startYourMathematicalJourney;

  /// No description provided for @practiceMode.
  ///
  /// In en, this message translates to:
  /// **'Practice Mode'**
  String get practiceMode;

  /// No description provided for @focusOnSpecificOperations.
  ///
  /// In en, this message translates to:
  /// **'Focus on specific operations'**
  String get focusOnSpecificOperations;

  /// No description provided for @arcadeMode.
  ///
  /// In en, this message translates to:
  /// **'Arcade Mode'**
  String get arcadeMode;

  /// No description provided for @fastPacedGamingExperience.
  ///
  /// In en, this message translates to:
  /// **'Fast-paced gaming experience'**
  String get fastPacedGamingExperience;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @solveLogicChallenges.
  ///
  /// In en, this message translates to:
  /// **'Solve challenging logic puzzles'**
  String get solveLogicChallenges;

  /// No description provided for @pushUpdates.
  ///
  /// In en, this message translates to:
  /// **'Push updates'**
  String get pushUpdates;

  /// No description provided for @sfxAndMusic.
  ///
  /// In en, this message translates to:
  /// **'SFX & Music'**
  String get sfxAndMusic;

  /// No description provided for @tactileResponse.
  ///
  /// In en, this message translates to:
  /// **'Tactile response'**
  String get tactileResponse;

  /// No description provided for @noLimit.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get noLimit;

  /// No description provided for @equipped.
  ///
  /// In en, this message translates to:
  /// **'EQUIPPED'**
  String get equipped;

  /// No description provided for @achievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'ACHIEVEMENT_UNLOCKED'**
  String get achievementUnlocked;

  /// No description provided for @protocolInitialized.
  ///
  /// In en, this message translates to:
  /// **'Protocol \"Star Collector\" has been successfully initialized.'**
  String get protocolInitialized;

  /// No description provided for @newLogicNodesAvailable.
  ///
  /// In en, this message translates to:
  /// **'Three new logic nodes available for processing.'**
  String get newLogicNodesAvailable;

  /// No description provided for @levelClearanceGranted.
  ///
  /// In en, this message translates to:
  /// **'Level 10 clearance granted. New sectors unlocked.'**
  String get levelClearanceGranted;

  /// No description provided for @viewStreak.
  ///
  /// In en, this message translates to:
  /// **'View Streak'**
  String get viewStreak;

  /// No description provided for @viewAchievement.
  ///
  /// In en, this message translates to:
  /// **'View Achievement'**
  String get viewAchievement;

  /// No description provided for @startMission.
  ///
  /// In en, this message translates to:
  /// **'Start Mission'**
  String get startMission;

  /// No description provided for @viewProgress.
  ///
  /// In en, this message translates to:
  /// **'View Progress'**
  String get viewProgress;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'h ago'**
  String get hoursAgo;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'d ago'**
  String get daysAgo;

  /// No description provided for @pleaseEnterYourName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterYourName;

  /// No description provided for @errorSavingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error saving profile'**
  String get errorSavingProfile;

  /// No description provided for @welcomeExclamation.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcomeExclamation;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @letsSetupYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your profile'**
  String get letsSetupYourProfile;

  /// No description provided for @customizeYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Customize your profile'**
  String get customizeYourProfile;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @avatarShape.
  ///
  /// In en, this message translates to:
  /// **'Avatar Shape'**
  String get avatarShape;

  /// No description provided for @avatarColor.
  ///
  /// In en, this message translates to:
  /// **'Avatar Color'**
  String get avatarColor;

  /// No description provided for @basicMode.
  ///
  /// In en, this message translates to:
  /// **'Basic Mode'**
  String get basicMode;

  /// No description provided for @scientificMode.
  ///
  /// In en, this message translates to:
  /// **'Scientific Mode'**
  String get scientificMode;

  /// No description provided for @calculationHistory.
  ///
  /// In en, this message translates to:
  /// **'Calculation History'**
  String get calculationHistory;

  /// No description provided for @noCalculationsYet.
  ///
  /// In en, this message translates to:
  /// **'No calculations yet'**
  String get noCalculationsYet;

  /// No description provided for @memory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get memory;

  /// No description provided for @memoryIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Memory is empty'**
  String get memoryIsEmpty;

  /// No description provided for @switchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Switch Language'**
  String get switchLanguage;

  /// No description provided for @switchedTo.
  ///
  /// In en, this message translates to:
  /// **'Switched to'**
  String get switchedTo;

  /// No description provided for @userProfile.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfile;

  /// No description provided for @systemStatusActive.
  ///
  /// In en, this message translates to:
  /// **'System Status: Active'**
  String get systemStatusActive;

  /// No description provided for @storeAndCustomization.
  ///
  /// In en, this message translates to:
  /// **'Store & Customization'**
  String get storeAndCustomization;

  /// No description provided for @unlockNewAvatarsWithPoints.
  ///
  /// In en, this message translates to:
  /// **'Unlock new avatars with points'**
  String get unlockNewAvatarsWithPoints;

  /// No description provided for @systemSettings.
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get systemSettings;

  /// No description provided for @builtInArithmeticTool.
  ///
  /// In en, this message translates to:
  /// **'Built-in arithmetic tool'**
  String get builtInArithmeticTool;

  /// No description provided for @quickLanguageToggle.
  ///
  /// In en, this message translates to:
  /// **'Quick Language Toggle'**
  String get quickLanguageToggle;

  /// No description provided for @stargazer.
  ///
  /// In en, this message translates to:
  /// **'Stargazer'**
  String get stargazer;

  /// No description provided for @sharpshooter.
  ///
  /// In en, this message translates to:
  /// **'Sharpshooter'**
  String get sharpshooter;

  /// No description provided for @timeLord.
  ///
  /// In en, this message translates to:
  /// **'Time Lord'**
  String get timeLord;

  /// No description provided for @scholar.
  ///
  /// In en, this message translates to:
  /// **'Scholar'**
  String get scholar;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// No description provided for @correctAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correctAnswer;

  /// No description provided for @wrongAnswer.
  ///
  /// In en, this message translates to:
  /// **'Wrong!'**
  String get wrongAnswer;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @activeChallenges.
  ///
  /// In en, this message translates to:
  /// **'Active Challenges'**
  String get activeChallenges;

  /// No description provided for @speedDemon.
  ///
  /// In en, this message translates to:
  /// **'Speed Demon'**
  String get speedDemon;

  /// No description provided for @speedDemonDesc.
  ///
  /// In en, this message translates to:
  /// **'Answer as fast as possible!'**
  String get speedDemonDesc;

  /// No description provided for @mathMaster.
  ///
  /// In en, this message translates to:
  /// **'Math Master'**
  String get mathMaster;

  /// No description provided for @mathMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'Achieve perfect accuracy'**
  String get mathMasterDesc;

  /// No description provided for @marathon.
  ///
  /// In en, this message translates to:
  /// **'Marathon'**
  String get marathon;

  /// No description provided for @marathonDesc.
  ///
  /// In en, this message translates to:
  /// **'Endurance challenge'**
  String get marathonDesc;

  /// No description provided for @practiceLab.
  ///
  /// In en, this message translates to:
  /// **'Practice Lab'**
  String get practiceLab;

  /// No description provided for @configurations.
  ///
  /// In en, this message translates to:
  /// **'Configurations'**
  String get configurations;

  /// No description provided for @visualCountingDesc.
  ///
  /// In en, this message translates to:
  /// **'Count shapes and objects'**
  String get visualCountingDesc;

  /// No description provided for @timePressure.
  ///
  /// In en, this message translates to:
  /// **'Time Pressure'**
  String get timePressure;

  /// No description provided for @timePressureDesc.
  ///
  /// In en, this message translates to:
  /// **'Race against time'**
  String get timePressureDesc;

  /// No description provided for @adaptiveDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Adaptive Difficulty'**
  String get adaptiveDifficulty;

  /// No description provided for @adaptiveDifficultyDesc.
  ///
  /// In en, this message translates to:
  /// **'Difficulty adjusts to your skill'**
  String get adaptiveDifficultyDesc;

  /// No description provided for @timeLimit.
  ///
  /// In en, this message translates to:
  /// **'Time Limit'**
  String get timeLimit;

  /// No description provided for @questionsCount.
  ///
  /// In en, this message translates to:
  /// **'Questions Count'**
  String get questionsCount;

  /// No description provided for @startPractice.
  ///
  /// In en, this message translates to:
  /// **'Start Practice'**
  String get startPractice;

  /// No description provided for @additionProcedure.
  ///
  /// In en, this message translates to:
  /// **'Addition Mode'**
  String get additionProcedure;

  /// No description provided for @subtractionProcedure.
  ///
  /// In en, this message translates to:
  /// **'Subtraction Mode'**
  String get subtractionProcedure;

  /// No description provided for @multiplicationProcedure.
  ///
  /// In en, this message translates to:
  /// **'Multiplication Mode'**
  String get multiplicationProcedure;

  /// No description provided for @divisionProcedure.
  ///
  /// In en, this message translates to:
  /// **'Division Mode'**
  String get divisionProcedure;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
