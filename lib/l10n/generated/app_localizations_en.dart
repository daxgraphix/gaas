// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GAAS';

  @override
  String get home => 'Home';

  @override
  String get campaign => 'Campaign';

  @override
  String get arcade => 'Arcade';

  @override
  String get profile => 'Profile';

  @override
  String get practice => 'Practice';

  @override
  String get startGame => 'Start Game';

  @override
  String get continueGame => 'Continue';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get totalPoints => 'Total Points';

  @override
  String get levelsCompleted => 'Levels Completed';

  @override
  String get commandCenter => 'COMMAND CENTER';

  @override
  String get quickResume => 'QUICK RESUME';

  @override
  String get todaysSession => 'Today\'s Session';

  @override
  String ptsToLevel(Object level, Object pts) {
    return '$pts pts to Level $level';
  }

  @override
  String timeLeftShort(Object hours, Object minutes) {
    return '${hours}h ${minutes}m left';
  }

  @override
  String levelUppercase(Object level) {
    return 'LEVEL $level';
  }

  @override
  String get accuracy => 'Accuracy';

  @override
  String get completed => 'Completed';

  @override
  String get victory => 'VICTORY';

  @override
  String get defeat => 'DEFEAT';

  @override
  String get levelStabilized => 'LEVEL STABILIZED';

  @override
  String get integrityFailed => 'INTEGRITY FAILED';

  @override
  String get coreScore => 'CORE SCORE';

  @override
  String get playAgain => 'PLAY AGAIN';

  @override
  String get levelUp => 'LEVEL UP!';

  @override
  String get rewardPoints => 'REWARD POINTS';

  @override
  String get timePlayed => 'Time Played';

  @override
  String get addition => 'Addition';

  @override
  String get subtraction => 'Subtraction';

  @override
  String get multiplication => 'Multiplication';

  @override
  String get division => 'Division';

  @override
  String get visualCounting => 'Visual Counting';

  @override
  String get level => 'Level';

  @override
  String get stars => 'Stars';

  @override
  String get locked => 'Locked';

  @override
  String get unlocked => 'Unlocked';

  @override
  String get score => 'SCORE';

  @override
  String get lives => 'Lives';

  @override
  String get time => 'Time';

  @override
  String get gameOver => 'Game Over';

  @override
  String get levelComplete => 'Level Complete!';

  @override
  String get continueText => 'CONTINUE';

  @override
  String get resume => 'RESUME';

  @override
  String get gamePaused => 'Game Paused';

  @override
  String get exitGame => 'Exit Game?';

  @override
  String get exitGameDesc =>
      'Are you sure you want to exit? Current progress will be lost.';

  @override
  String get correct => 'Correct!';

  @override
  String get incorrect => 'Incorrect!';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get nextLevel => 'Next Level';

  @override
  String get backToMenu => 'Back to Menu';

  @override
  String get scoreAttack => 'Score Attack';

  @override
  String get endless => 'Endless';

  @override
  String get duel => 'Duel';

  @override
  String get flash => 'Flash';

  @override
  String get scoreAttackDesc => '60 seconds to score as high as possible';

  @override
  String get endlessDesc => '3 lives - keep playing as long as you can';

  @override
  String get duelDesc => 'Race against the AI';

  @override
  String get flashDesc => 'Memory challenge - recall the numbers';

  @override
  String get simulation => 'Simulation';

  @override
  String get solar => 'Solar';

  @override
  String get cyber => 'Cyber';

  @override
  String get selectOperation => 'Select Operation';

  @override
  String get selectLevel => 'Select Level';

  @override
  String get customize => 'Customize';

  @override
  String get numberRange => 'Number Range';

  @override
  String get timer => 'Timer';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get countTheShapes => 'Count the shapes!';

  @override
  String get enterAnswer => 'Enter your answer';

  @override
  String get submit => 'Submit';

  @override
  String get clear => 'Clear';

  @override
  String get dots => 'Dots';

  @override
  String get triangles => 'Triangles';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get minutes => 'min';

  @override
  String get seconds => 's';

  @override
  String get highScore => 'High Score';

  @override
  String get newHighScore => 'New High Score!';

  @override
  String get avatar => 'Avatar';

  @override
  String get shape => 'Shape';

  @override
  String get color => 'Color';

  @override
  String get customMix => 'Custom Mix';

  @override
  String get customMixArithmetic => 'Custom Mix Arithmetic';

  @override
  String get operationMatrix => 'Operation Matrix';

  @override
  String get difficultyLevel => 'Difficulty Level';

  @override
  String get initiateMixSequence => 'Start Mix';

  @override
  String get sessionMetrics => 'Session Metrics';

  @override
  String get gameSession => 'Game Session';

  @override
  String get configuration => 'Configuration';

  @override
  String get terminateSession => 'End Session';

  @override
  String get requestHint => 'Request Hint';

  @override
  String get systemHint => 'System Hint';

  @override
  String get acknowledge => 'Acknowledge';

  @override
  String get understood => 'Understood';

  @override
  String get mixModeProtocol => 'Mix Mode Protocol';

  @override
  String get standard => 'Standard';

  @override
  String get suddenDeath => 'Sudden Death';

  @override
  String get zen => 'Zen';

  @override
  String get timeAttack => 'Time Attack';

  @override
  String get gameMode => 'Game Mode';

  @override
  String get intensity => 'Intensity';

  @override
  String get initializeMix => 'Initialize Mix';

  @override
  String get nextSequence => 'Next Sequence';

  @override
  String get abortSession => 'ABORT SESSION';

  @override
  String get abortSessionConfirm =>
      'Abort current session? Progress will be recorded.';

  @override
  String get modeProtocols => 'Mode Protocols';

  @override
  String get standardDesc => 'STANDARD: Classic practice mode.';

  @override
  String get suddenDeathDesc =>
      'SUDDEN DEATH: One wrong answer ends the session.';

  @override
  String get zenDesc => 'ZEN: No timers, focus on accuracy.';

  @override
  String get timeAttackDesc => 'TIME ATTACK: Score as much as possible in 60s.';

  @override
  String get coreMetrics => 'Core Metrics';

  @override
  String get progressionStatus => 'Progression Status';

  @override
  String get performanceAnalytics => 'Performance Analytics';

  @override
  String get realTimePerformance => 'Real Time Performance';

  @override
  String get levelCompletionStats => 'Level Completion Stats';

  @override
  String get reactionAnalytics => 'Reaction Analytics';

  @override
  String get speedMetrics => 'Speed Metrics';

  @override
  String get temporalInvestment => 'Time Invested';

  @override
  String get realTimeAccuracy => 'Real Time Accuracy';

  @override
  String get levelMastery => 'Level Mastery';

  @override
  String get achievementProgress => 'Achievement Progress';

  @override
  String get endOfReport => 'End of Report';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get shop => 'Shop';

  @override
  String get stats => 'Stats';

  @override
  String get calc => 'Calc';

  @override
  String get dailyMissions => 'Daily Missions';

  @override
  String get close => 'Close';

  @override
  String get adventure => 'Adventure';

  @override
  String get gameModes => '🎮 Game Modes';

  @override
  String get puzzleWorld => 'Puzzle World';

  @override
  String get resourcesTools => 'Resources & Tools';

  @override
  String get logicRiddles => 'Logic Riddles';

  @override
  String get crossNumbers => 'Cross Numbers';

  @override
  String get crossNumbersDesc => 'Solve cross number puzzles';

  @override
  String get calculator => 'Calculator';

  @override
  String get reports => 'Reports';

  @override
  String get avatarShop => 'Avatar Shop';

  @override
  String get focusMode => 'Focus Mode';

  @override
  String get focusModeDesc => 'Simplified UI for concentration';

  @override
  String get performanceMode => 'Performance Mode';

  @override
  String get performanceModeDesc =>
      'Reduce transparency for better performance';

  @override
  String get visualTheme => 'Visual Theme';

  @override
  String get audioOutput => 'Audio Output';

  @override
  String get hapticFeedback => 'Haptic Feedback';

  @override
  String get notifications => 'Notifications';

  @override
  String get arithmeticMixGenerator => 'Arithmetic Mix Generator';

  @override
  String get custom => 'Custom';

  @override
  String get nextQuestion => 'Next Question';

  @override
  String get undo => 'Undo';

  @override
  String get hint => 'HINT';

  @override
  String get level_1 => 'Level 1';

  @override
  String get level_2 => 'Level 2';

  @override
  String get level_3 => 'Level 3';

  @override
  String get level_4 => 'Level 4';

  @override
  String get level_5 => 'Level 5';

  @override
  String get level_6 => 'Level 6';

  @override
  String get level_7 => 'Level 7';

  @override
  String get level_8 => 'Level 8';

  @override
  String get level_9 => 'Level 9';

  @override
  String get level_10 => 'Level 10';

  @override
  String get plus => '+';

  @override
  String get minus => '-';

  @override
  String get multiply => '×';

  @override
  String get divide => '÷';

  @override
  String get hotStreak => '🔥 HOT STREAK!';

  @override
  String get unstoppable => 'Unstoppable!';

  @override
  String get keepItUp => '⚡ KEEP IT UP!';

  @override
  String get streakBroken => '💔 STREAK BROKEN!';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get swahili => 'Swahili';

  @override
  String get swahiliTanzania => 'Swahili (Tanzania)';

  @override
  String get languageChanged => 'Language changed';

  @override
  String get exportReport => 'Export Report';

  @override
  String get accuracyTrend => 'ACCURACY';

  @override
  String get streak => 'STREAK';

  @override
  String get accuracyTrends => 'Accuracy Trends';

  @override
  String get help => 'HELP';

  @override
  String get refreshAnalytics => 'Refresh Analytics';

  @override
  String get avgSession => 'Avg Session';

  @override
  String get sysOp => 'SYS_OP';

  @override
  String get neuralAccuracy => 'NEURAL_ACCURACY';

  @override
  String get coreStars => 'CORE_STARS';

  @override
  String get unitsCleared => 'UNITS_CLEARED';

  @override
  String get temporalInvestmentLabel => 'TEMPORAL_INVESTMENT';

  @override
  String get status => 'STATUS';

  @override
  String get missionActive => 'MISSION_ACTIVE';

  @override
  String get endOfTransmission => 'END_OF_TRANSMISSION';

  @override
  String get exportProtocol => 'EXPORT_PROTOCOL';

  @override
  String get dismiss => 'DISMISS';

  @override
  String get debriefCopied => 'DEBRIEF_COPIED_TO_CLIPBOARD';

  @override
  String get copyToClipboard => 'COPY_TO_CLIPBOARD';

  @override
  String get neuralEfficiencyIndex => 'NEURAL_EFFICIENCY_INDEX';

  @override
  String get performanceScore => 'PERFORMANCE_SCORE';

  @override
  String get avgSpeed => 'Avg Speed';

  @override
  String get high => 'HIGH';

  @override
  String get med => 'MED';

  @override
  String get low => 'LOW';

  @override
  String get accuracyProgression => 'ACCURACY_PROGRESSION';

  @override
  String get peakAccuracy => 'Peak Accuracy';

  @override
  String get responseAnalytics => 'RESPONSE_ANALYTICS';

  @override
  String get avgResponse => 'AVG_RESPONSE';

  @override
  String get fastest => 'Fastest';

  @override
  String get improvement => 'Improvement';

  @override
  String get livePerformanceMetrics => 'LIVE_PERFORMANCE_METRICS';

  @override
  String get currentAccuracy => 'CURRENT_ACCURACY';

  @override
  String get sessionTime => 'SESSION_TIME';

  @override
  String get activeStreak => 'ACTIVE_STREAK';

  @override
  String get calculating => 'CALCULATING...';

  @override
  String get difficultyLevelLabel => 'DIFFICULTY_LEVEL';

  @override
  String get advanced => 'ADVANCED';

  @override
  String get performanceTrend => 'PERFORMANCE_TREND';

  @override
  String get reactionTimeAnalysis => 'Reaction Time Analysis';

  @override
  String get operationUsage => 'Operation Usage';

  @override
  String get levelMasteryBreakdown => 'LEVEL_MASTERY_BREAKDOWN';

  @override
  String get perfectLevels => 'PERFECT_LEVELS';

  @override
  String get levelsWith35Plus => 'Levels with 35+ correct';

  @override
  String get highPerformance => 'HIGH_PERFORMANCE';

  @override
  String get levelsWith30Plus => 'Levels with 30+ correct';

  @override
  String get goodProgress => 'GOOD_PROGRESS';

  @override
  String get levelsWith25Plus => 'Levels with 25+ correct';

  @override
  String get totalAttempts => 'TOTAL_ATTEMPTS';

  @override
  String get totalLevelsAttempted => 'Total levels attempted';

  @override
  String get player => 'Player';

  @override
  String get del => 'DEL';

  @override
  String get mc => 'MC';

  @override
  String get mr => 'MR';

  @override
  String get divByZero => 'DIV BY ZERO';

  @override
  String get allModes => 'All Modes';

  @override
  String get mathLearningProgress => 'Math Learning Progress';

  @override
  String get preparingPdf => 'Preparing PDF...';

  @override
  String get overview => 'Overview';

  @override
  String get myGaasProgressReport => 'My GAAS Progress Report';

  @override
  String get pdfSharedSuccessfully => 'PDF shared successfully!';

  @override
  String shareFailed(Object error) {
    return 'Share failed: $error';
  }

  @override
  String get readyToChallenge => '🎯 Ready to Challenge?';

  @override
  String get masterMathematicsDesc =>
      'Master mathematics through engaging games and track your progress.';

  @override
  String get yourProgress => '📊 Your Progress';

  @override
  String get starsEarned => 'Stars Earned';

  @override
  String get quickActions => '⚡ Quick Actions';

  @override
  String get dailyChallenge => 'Daily Challenge';

  @override
  String get completeTodaysChallenge =>
      'Complete today\'s math challenge to earn bonus rewards!';

  @override
  String get challengeReward => '🔥 5 problems • 100 XP reward';

  @override
  String get completeLevelsProgressively => 'Complete levels progressively';

  @override
  String get fastPacedChallenges => 'Fast-paced challenges';

  @override
  String get improveSpecificSkills => 'Improve specific skills';

  @override
  String get createYourOwnChallenges => 'Create your own challenges';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get goodNight => 'Good night';

  @override
  String get welcomeToGAAS => 'Welcome to GAAS';

  @override
  String get quickStart => 'Quick Start';

  @override
  String get campaignMode => 'Campaign Mode';

  @override
  String get startYourMathematicalJourney => 'Start your mathematical journey';

  @override
  String get practiceMode => 'Practice Mode';

  @override
  String get focusOnSpecificOperations => 'Focus on specific operations';

  @override
  String get arcadeMode => 'Arcade Mode';

  @override
  String get fastPacedGamingExperience => 'Fast-paced gaming experience';

  @override
  String get cancel => 'Cancel';

  @override
  String get chapter => 'CHAPTER';

  @override
  String chapterStarsProgress(Object stars, Object total) {
    return '$stars / $total STARS';
  }

  @override
  String lockedNeedStars(Object stars) {
    return 'LOCKED - NEED $stars TOTAL STARS';
  }

  @override
  String get solveLogicChallenges => 'Solve challenging logic puzzles';

  @override
  String get pushUpdates => 'Push updates';

  @override
  String get sfxAndMusic => 'SFX & Music';

  @override
  String get tactileResponse => 'Tactile response';

  @override
  String get noLimit => 'No limit';

  @override
  String get equipped => 'EQUIPPED';

  @override
  String get achievementUnlocked => 'ACHIEVEMENT_UNLOCKED';

  @override
  String get protocolInitialized =>
      'Protocol \"Star Collector\" has been successfully initialized.';

  @override
  String get newLogicNodesAvailable =>
      'Three new logic nodes available for processing.';

  @override
  String get levelClearanceGranted =>
      'Level 10 clearance granted. New sectors unlocked.';

  @override
  String get viewStreak => 'View Streak';

  @override
  String get viewAchievement => 'View Achievement';

  @override
  String get startMission => 'Start Mission';

  @override
  String get viewProgress => 'View Progress';

  @override
  String hoursAgo(Object count) {
    return '${count}h ago';
  }

  @override
  String daysAgo(Object count) {
    return '${count}d ago';
  }

  @override
  String get pleaseEnterYourName => 'Please enter your name';

  @override
  String get errorSavingProfile => 'Error saving profile';

  @override
  String get welcomeExclamation => 'Welcome!';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get letsSetupYourProfile => 'Let\'s set up your profile';

  @override
  String get customizeYourProfile => 'Customize your profile';

  @override
  String get getStarted => 'Get Started';

  @override
  String get yourName => 'Your Name';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get avatarShape => 'Avatar Shape';

  @override
  String get avatarColor => 'Avatar Color';

  @override
  String get basicMode => 'Basic Mode';

  @override
  String get scientificMode => 'Scientific Mode';

  @override
  String get calculationHistory => 'Calculation History';

  @override
  String get noCalculationsYet => 'No calculations yet';

  @override
  String get memory => 'Memory';

  @override
  String get memoryIsEmpty => 'Memory is empty';

  @override
  String get switchLanguage => 'Switch Language';

  @override
  String get switchedTo => 'Switched to';

  @override
  String get userProfile => 'User Profile';

  @override
  String get systemStatusActive => 'System Status: Active';

  @override
  String get storeAndCustomization => 'Store & Customization';

  @override
  String get unlockNewAvatarsWithPoints => 'Unlock new avatars with points';

  @override
  String get systemSettings => 'System Settings';

  @override
  String get interface => 'Interface';

  @override
  String get audioAndHaptics => 'Audio & Haptics';

  @override
  String get builtInArithmeticTool => 'Built-in arithmetic tool';

  @override
  String get quickLanguageToggle => 'Quick Language Toggle';

  @override
  String get stargazer => 'Stargazer';

  @override
  String get sharpshooter => 'Sharpshooter';

  @override
  String get timeLord => 'Time Lord';

  @override
  String get scholar => 'Scholar';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get correctAnswer => 'Correct!';

  @override
  String get wrongAnswer => 'Wrong!';

  @override
  String get achievements => 'Achievements';

  @override
  String get save => 'Save';

  @override
  String get activeChallenges => 'Active Challenges';

  @override
  String get speedDemon => 'Speed Demon';

  @override
  String get speedDemonDesc => 'Answer as fast as possible!';

  @override
  String get mathMaster => 'Math Master';

  @override
  String get mathMasterDesc => 'Achieve perfect accuracy';

  @override
  String get marathon => 'Marathon';

  @override
  String get marathonDesc => 'Endurance challenge';

  @override
  String get practiceLab => 'Practice Lab';

  @override
  String get configurations => 'Configurations';

  @override
  String get visualCountingDesc => 'Count shapes and objects';

  @override
  String get timePressure => 'Time Pressure';

  @override
  String get timePressureDesc => 'Race against time';

  @override
  String get adaptiveDifficulty => 'Adaptive Difficulty';

  @override
  String get adaptiveDifficultyDesc => 'Difficulty adjusts to your skill';

  @override
  String get timeLimit => 'Time Limit';

  @override
  String get questionsCount => 'Questions Count';

  @override
  String get startPractice => 'Start Practice';

  @override
  String get additionProcedure => 'Addition Mode';

  @override
  String get subtractionProcedure => 'Subtraction Mode';

  @override
  String get multiplicationProcedure => 'Multiplication Mode';

  @override
  String get divisionProcedure => 'Division Mode';

  @override
  String get timesUp => 'Time\'s Up!';

  @override
  String get yourScore => 'Your score';

  @override
  String get exit => 'Exit';

  @override
  String get operation => 'Operation';

  @override
  String get dailyRewardClaimed => 'Daily reward claimed!';

  @override
  String get claimTodaysReward => 'CLAIM TODAY\'S REWARD';

  @override
  String get noGameSession => 'No game session';

  @override
  String get playerLabel => 'Player';

  @override
  String get generatingImage => 'Generating image...';

  @override
  String get imageSharedSuccessfully => 'Image shared successfully!';

  @override
  String get imageExportFailed => 'Image export failed';

  @override
  String get preparingDocument => 'Preparing document for printing...';

  @override
  String get performanceReportTitle => 'GAAS Performance Report';

  @override
  String reportSaved(Object path) {
    return 'Report saved to: $path';
  }

  @override
  String reportSaveFailed(Object error) {
    return 'Save failed: $error';
  }

  @override
  String get generatingPdf => 'Generating PDF...';

  @override
  String get skip => 'SKIP';

  @override
  String get allChallengesComplete => 'All challenges complete!';

  @override
  String get play => 'Play';

  @override
  String get unlimitedTime => 'Unlimited Time';

  @override
  String get practiceWithoutPressure => 'Practice without pressure';

  @override
  String get showFeedback => 'Show Feedback';

  @override
  String get seeCorrectAnswersImmediately => 'See correct answers immediately';

  @override
  String get answerRevealed => 'Answer revealed!';

  @override
  String get excellent => 'Excellent!';

  @override
  String get done => 'Done';

  @override
  String get selectRiddleLevel => 'SELECT RIDDLE LEVEL';

  @override
  String get loadingGame => 'Loading game...';

  @override
  String get thankYouForFeedback => 'Thank you for your feedback!';

  @override
  String get notEnoughPoints => 'Not enough points! Keep playing to earn more.';

  @override
  String get avatarUnlocked => 'Avatar unlocked!';

  @override
  String get documentSentToPrinter => 'Document sent to printer!';

  @override
  String printFailed(Object error) {
    return 'Print failed';
  }

  @override
  String get noProgressDataAvailable => 'No progress data available';

  @override
  String get exportOptions => 'Export Options';

  @override
  String get exportAsPdf => 'Export as PDF';

  @override
  String get generateDetailedPdfReport =>
      'Generate and share detailed PDF report';

  @override
  String get shareAsImage => 'Share as Image';

  @override
  String get captureHighQualityImage =>
      'Capture and share report as high-quality image';

  @override
  String get printReport => 'Print Report';

  @override
  String get sendReportToPrinter => 'Send report to printer';

  @override
  String get saveToDevice => 'Save to Device';

  @override
  String get savePdfToDeviceStorage => 'Save PDF to device storage';

  @override
  String get firstSteps => 'First Steps';

  @override
  String get firstStepsDesc => 'Answer your first question correctly';

  @override
  String get speedDemonTitle => 'Speed Demon';

  @override
  String get mathMasterTitle => 'Math Master';

  @override
  String get weeklyChampion => 'Weekly Champion';

  @override
  String get streakMaster => 'Streak Master';

  @override
  String get puzzleGenius => 'Puzzle Genius';

  @override
  String get timeLordTitle => 'Time Lord';

  @override
  String get onFire => 'On Fire';

  @override
  String get onFireDesc => 'Get 5 correct answers in a row';

  @override
  String get perfectScore => 'Perfect Score';

  @override
  String get weekendMaster => 'Weekend Master';

  @override
  String get equip => 'EQUIP';

  @override
  String get coreConcept => 'Core Concept';

  @override
  String get adventureTitle => 'ADVENTURE';

  @override
  String get campaignProgression => 'Campaign Progression';

  @override
  String get challengeTitle => 'CHALLENGE';

  @override
  String get arcadeDailyMissions => 'Arcade + Daily Missions';

  @override
  String get puzzlesTitle => 'PUZZLES';

  @override
  String get mathRiddles => 'Math Riddles';

  @override
  String get firstVictory => 'First Victory';

  @override
  String get campaignMaster => 'Campaign Master';

  @override
  String get mathGenius => 'Math Genius';

  @override
  String get unstoppableDesc => 'Get 10 correct answers in a row';

  @override
  String get heatIndexDesc =>
      'Maintain a Heat Index above 2.5 for an entire session';

  @override
  String get flashCalculator => 'Flash Calculator';

  @override
  String get flashCalculatorDesc =>
      'Answer 50 questions with an average time under 2 seconds';

  @override
  String get dedicated => 'Dedicated';

  @override
  String get dedicatedDesc => 'Answer 500 questions';

  @override
  String get stargazerDesc => 'Earn your first 10 stars';

  @override
  String get centuryDesc => 'Answer 100 questions';

  @override
  String get mathGeniusDesc => 'Answer 1000 questions';

  @override
  String get perfectScoreDesc => 'Get 100% accuracy in any game';

  @override
  String get weeklyChampionDesc => 'Play for 7 days in a row';

  @override
  String get campaignMasterDesc => 'Complete all campaign levels';

  @override
  String get duelMasterDesc => 'Win 10 duel matches';

  @override
  String get legendDesc => 'Get 25 correct answers in a row';

  @override
  String get sharpMind => 'Sharp Mind';

  @override
  String sharpMindDesc(Object percentage) {
    return 'Achieve $percentage% accuracy in any game mode';
  }

  @override
  String get speedRun => 'Speed Run';

  @override
  String speedRunDesc(Object seconds) {
    return 'Answer 10 questions in under $seconds seconds';
  }

  @override
  String get committed => 'Committed';

  @override
  String get committedDesc => 'Play for 30 days in a row';

  @override
  String get masterOfOperations => 'Master of Operations';

  @override
  String get masterOfOperationsDesc => 'Use all four operations';

  @override
  String get highScorer => 'High Scorer';

  @override
  String highScorerDesc(Object points) {
    return 'Score $points points in one game';
  }

  @override
  String get earlyBird => 'Early Bird';

  @override
  String get earlyBirdDesc => 'Play your first game of the day before 8 AM';

  @override
  String get precisionExpert => 'Precision Expert';

  @override
  String get accuracyMaster => 'Accuracy Master';

  @override
  String get lightningFast => 'Lightning Fast';

  @override
  String lightningFastDesc(Object seconds) {
    return 'Complete a level in under $seconds seconds';
  }

  @override
  String get instantReaction => 'Instant Reaction';

  @override
  String get comboKing => 'Combo King';

  @override
  String comboKingDesc(Object multiplier) {
    return 'Achieve a ${multiplier}x combo multiplier';
  }

  @override
  String get performanceMasterDesc =>
      'Achieve 95% accuracy with average time under 15 seconds';

  @override
  String get consistentPlayer => 'Consistent Player';

  @override
  String consistentPlayerDesc(Object count, Object percentage) {
    return 'Maintain $percentage% accuracy over $count consecutive questions';
  }

  @override
  String get nightOwl => 'Night Owl';

  @override
  String get nightOwlDesc => 'Play a game after 10 PM';

  @override
  String get weekendWarrior => 'Weekend Warrior';

  @override
  String get weekendWarriorDesc => 'Play on both Saturday and Sunday';

  @override
  String get firstPlace => 'First Place';

  @override
  String get firstPlaceDesc => 'Reach #1 on the leaderboard';

  @override
  String get modeExplorer => 'Mode Explorer';

  @override
  String get modeExplorerDesc => 'Play all game modes';

  @override
  String get precisionStrike => 'Precision Strike';

  @override
  String get precisionStrikeDesc => 'Complete a level with 35+ correct answers';

  @override
  String get masterLevel => 'Master Level';

  @override
  String get masterLevelDesc => 'Complete a level with 40+ correct answers';

  @override
  String get perfectLevel => 'Perfect Level';

  @override
  String get perfectLevelDesc =>
      'Complete a level with all 45 questions correct';

  @override
  String get risingStar => 'Rising Star';

  @override
  String get risingStarDesc => 'Unlock 10 campaign levels';

  @override
  String get mathWarrior => 'Math Warrior';

  @override
  String get mathWarriorDesc => 'Unlock 25 campaign levels';

  @override
  String get campaignConqueror => 'Campaign Conqueror';

  @override
  String get campaignConquerorDesc => 'Complete all 50 campaign levels';

  @override
  String get questionMaster => 'Question Master';

  @override
  String get questionMasterDesc =>
      'Answer 1000 questions across different categories';

  @override
  String get lightningLevel => 'Lightning Level';

  @override
  String get lightningLevelDesc =>
      'Complete a 45-question level in under 45 seconds';

  @override
  String get consistencyMaster => 'Consistency Master';

  @override
  String get starCollector => 'Star Collector';

  @override
  String get stellarPerformer => 'Stellar Performer';

  @override
  String get stellarPerformerDesc => 'Earn 50 stars';

  @override
  String get celestialMaster => 'Celestial Master';

  @override
  String get celestialMasterDesc => 'Earn 100 stars';

  @override
  String get riddleMaster => 'Riddle Master';

  @override
  String get riddleMasterDesc => 'Complete all 30 riddle levels';

  @override
  String get hintHoarder => 'Hint Hoarder';

  @override
  String get hintHoarderDesc => 'Obtain 50 hints';

  @override
  String get gridExplorer => 'Grid Explorer';

  @override
  String get gridExplorerDesc => 'Complete 5 Cross Numbers puzzles';

  @override
  String get lightningGrid => 'Lightning Grid';

  @override
  String get lightningGridDesc =>
      'Complete a 7x7 Cross Numbers puzzle in under 90 seconds';

  @override
  String get logicArchitect => 'Logic Architect';

  @override
  String get logicArchitectDesc => 'Complete 50 Cross Numbers puzzles';

  @override
  String get campaignGrinder => 'Campaign Grinder';

  @override
  String get duelMaster => 'Duel Master';

  @override
  String get endlessSurvivor => 'Endless Survivor';

  @override
  String get divisionExpert => 'Division Expert';

  @override
  String get additionMastery => 'Addition Mastery';

  @override
  String get singleDigitAddition => 'Single Digit Addition';

  @override
  String get twoDigitAddition => 'Two Digit Addition';

  @override
  String get threeDigitAddition => 'Three Digit Addition';

  @override
  String get additionWithCarrying => 'Addition with Carrying';

  @override
  String get advancedAddition => 'Advanced Addition';

  @override
  String get subtractionMastery => 'Subtraction Mastery';

  @override
  String get singleDigitSubtraction => 'Single Digit Subtraction';

  @override
  String get twoDigitSubtraction => 'Two Digit Subtraction';

  @override
  String get threeDigitSubtraction => 'Three Digit Subtraction';

  @override
  String get subtractionWithBorrowing => 'Subtraction with Borrowing';

  @override
  String get advancedSubtraction => 'Advanced Subtraction';

  @override
  String get multiplicationMastery => 'Multiplication Mastery';

  @override
  String get timesTables1to5 => 'Times Tables 1-5';

  @override
  String get timesTables6to10 => 'Times Tables 6-10';

  @override
  String get twoDigitMultiplication => 'Two Digit Multiplication';

  @override
  String get threeDigitMultiplication => 'Three Digit Multiplication';

  @override
  String get advancedMultiplication => 'Advanced Multiplication';

  @override
  String get multiplicationPatterns => 'Multiplication Patterns';

  @override
  String get divisionMastery => 'Division Mastery';

  @override
  String get divisionBasics => 'Division Basics';

  @override
  String get divisionWithRemainders => 'Division with Remainders';

  @override
  String get twoDigitDivision => 'Two Digit Division';

  @override
  String get threeDigitDivision => 'Three Digit Division';

  @override
  String get longDivision => 'Long Division';

  @override
  String get legend => 'Legend';

  @override
  String get century => 'Century';

  @override
  String get mathEquationsLevelPrefix => 'MATH EQUATIONS - LVL';

  @override
  String get selectDifficultyLevel => 'SELECT DIFFICULTY LEVEL';

  @override
  String get levelPrefix => 'L';

  @override
  String get performanceOverview => 'Performance Overview';

  @override
  String get currentSession => 'Current Session';

  @override
  String get realTimeStats => 'Real-time Stats';

  @override
  String get questions => 'Questions';

  @override
  String get bestStreak => 'Best Streak';

  @override
  String get sessions => 'Sessions';

  @override
  String get gameModeDistribution => 'Game Mode Distribution';

  @override
  String get performanceInsights => 'Performance Insights';

  @override
  String get bestAccuracy => 'Best Accuracy';

  @override
  String get averageResponseTime => 'Avg Response Time';

  @override
  String get completionRate => 'Completion Rate';

  @override
  String get engineIntensity => 'ENGINE INTENSITY';

  @override
  String get averageHeat => 'AVG HEAT';

  @override
  String get currentHeat => 'CURRENT HEAT';

  @override
  String get maxHeat => 'MAX HEAT';

  @override
  String get heatIndex => 'Heat Index';

  @override
  String get intensityNormal => 'NORMAL';

  @override
  String get intensityMedium => 'MEDIUM';

  @override
  String get intensityHigh => 'HIGH';

  @override
  String get intensityCritical => 'CRITICAL';

  @override
  String get totalScore => 'TOTAL SCORE';

  @override
  String xpToLevelFull(Object xp) {
    return '$xp XP to NEXT LEVEL';
  }

  @override
  String get achiever => 'ACHIEVER';

  @override
  String get avatarUnlocks => 'AVATAR UNLOCKS';

  @override
  String requiresLevelAndStars(Object level, Object stars) {
    return 'Requires Level $level and $stars stars!';
  }

  @override
  String requiresStarsToUnlock(Object stars) {
    return 'Requires $stars stars to unlock!';
  }

  @override
  String requiresLevelToUnlock(Object level) {
    return 'Requires Level $level to unlock!';
  }

  @override
  String get unlockAvatarQuestion => 'Unlock Avatar?';

  @override
  String unlockAvatarConfirm(Object cost, Object name) {
    return 'Do you want to spend $cost points to unlock the $name avatar?';
  }

  @override
  String get unlock => 'Unlock';

  @override
  String get rarityCommon => 'Common';

  @override
  String get rarityUncommon => 'Uncommon';

  @override
  String get rarityRare => 'Rare';

  @override
  String get rarityEpic => 'Epic';

  @override
  String get rarityLegendary => 'Legendary';

  @override
  String get rarityMythic => 'Mythic';

  @override
  String generatedOn(Object date) {
    return 'Generated on $date';
  }
}
