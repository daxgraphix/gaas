// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appTitle => 'GAAS';

  @override
  String get home => 'Nyumbani';

  @override
  String get campaign => 'Kampeni';

  @override
  String get arcade => 'Ukumbi wa Michezo';

  @override
  String get profile => 'Wasifu';

  @override
  String get practice => 'Mazoezi';

  @override
  String get startGame => 'Anza Mchezo';

  @override
  String get continueGame => 'Endelea';

  @override
  String get settings => 'Mipangilio';

  @override
  String get theme => 'Mandhari';

  @override
  String get language => 'Lugha';

  @override
  String get totalPoints => 'Jumla ya Pointi';

  @override
  String get levelsCompleted => 'Ngazi Zilizokamilika';

  @override
  String get commandCenter => 'KITUO CHA AMRI';

  @override
  String get quickResume => 'ENDELEA HARAKA';

  @override
  String get todaysSession => 'Kipindi cha Leo';

  @override
  String ptsToLevel(Object level, Object pts) {
    return '$pts pointi mpaka Ngazi ya $level';
  }

  @override
  String timeLeftShort(Object hours, Object minutes) {
    return 'Zimebaki ${hours}saa ${minutes}dk';
  }

  @override
  String levelUppercase(Object level) {
    return 'NGAZI $level';
  }

  @override
  String get accuracy => 'Usahihi';

  @override
  String get completed => 'Zilizokamilika';

  @override
  String get victory => 'USHINDI';

  @override
  String get defeat => 'KUSHINDWA';

  @override
  String get levelStabilized => 'NGAZI IMEIMARIKA';

  @override
  String get integrityFailed => 'UTENDAJI UMESHINDWA';

  @override
  String get coreScore => 'ALAMA KUU';

  @override
  String get playAgain => 'CHEZA TENA';

  @override
  String get levelUp => 'NGAZI JUU!';

  @override
  String get rewardPoints => 'POINTI ZA THAWABU';

  @override
  String get timePlayed => 'Muda wa Kucheza';

  @override
  String get addition => 'Kujumlisha';

  @override
  String get subtraction => 'Kutoa';

  @override
  String get multiplication => 'Kuzidisha';

  @override
  String get division => 'Kugawanya';

  @override
  String get visualCounting => 'Kuhesabu kwa Kuona';

  @override
  String get level => 'Ngazi';

  @override
  String get stars => 'Nyota';

  @override
  String get locked => 'Imefungwa';

  @override
  String get unlocked => 'Imefunguliwa';

  @override
  String get score => 'Pointi';

  @override
  String get lives => 'Maisha';

  @override
  String get time => 'Muda';

  @override
  String get timeUppercase => 'MUDA';

  @override
  String get heat => 'JOTO';

  @override
  String get streakUppercase => 'MFULULIZO';

  @override
  String get maxStreak => 'MFULULIZO BORA';

  @override
  String get correctAnswersLabel => 'SAHIHI';

  @override
  String get gameOver => 'Mchezo Umekwisha';

  @override
  String get levelComplete => 'Ngazi Imekamilika!';

  @override
  String get continueText => 'ENDELEA';

  @override
  String get resume => 'ENDELEA';

  @override
  String get gamePaused => 'Mchezo Umesimama';

  @override
  String get exitGame => 'Toka Kwenye Mchezo?';

  @override
  String get exitGameDesc =>
      'Una uhakika unataka kutoka? Maendeleo ya sasa yatapotea.';

  @override
  String get correct => 'Sahihi!';

  @override
  String get incorrect => 'Si sahihi!';

  @override
  String get tryAgain => 'Jaribu Tena';

  @override
  String get nextLevel => 'Ngazi Inayofuata';

  @override
  String get backToMenu => 'Rudi kwenye Menyu';

  @override
  String get scoreAttack => 'Shambulizi la Pointi';

  @override
  String get endless => 'Bila Mwisho';

  @override
  String get duel => 'Pambano';

  @override
  String get flash => 'Haraka';

  @override
  String get scoreAttackDesc => 'Sekunde 60 kupata pointi nyingi';

  @override
  String get endlessDesc => 'Maisha 3 - cheza muda wote';

  @override
  String get duelDesc => 'Pambana na AI';

  @override
  String get flashDesc => 'Changamoto ya kukumbuka';

  @override
  String get simulation => 'Uigaji';

  @override
  String get solar => 'Solar';

  @override
  String get cyber => 'Cyber';

  @override
  String get selectOperation => 'Chagua Operesheni';

  @override
  String get selectLevel => 'Chagua Ngazi';

  @override
  String get customize => 'Badilisha';

  @override
  String get numberRange => 'Kiwango cha Nambari';

  @override
  String get timer => 'Timer';

  @override
  String get on => 'Washa';

  @override
  String get off => 'Zima';

  @override
  String get countTheShapes => 'Hesabu maumbo!';

  @override
  String get enterAnswer => 'Weka jibu lako';

  @override
  String get submit => 'Wasilisha';

  @override
  String get clear => 'Futa';

  @override
  String get dots => 'Nukta';

  @override
  String get triangles => 'Pembetatu';

  @override
  String get easy => 'Rahisi';

  @override
  String get medium => 'Wastani';

  @override
  String get hard => 'Ngumu';

  @override
  String get minutes => 'dakika';

  @override
  String get seconds => 'sekunde';

  @override
  String get highScore => 'Alama ya Juu';

  @override
  String get newHighScore => 'Alama Mpya ya Juu!';

  @override
  String get avatar => 'Picha ya Mtumiaji';

  @override
  String get shape => 'Umbo';

  @override
  String get color => 'Rangi';

  @override
  String get customMix => 'Mchanganyiko Maalum';

  @override
  String get customMixArithmetic => 'Hesabu ya Mchanganyiko Maalum';

  @override
  String get operationMatrix => 'Matriksi ya Operesheni';

  @override
  String get difficultyLevel => 'Kiwango cha Ugumu';

  @override
  String get initiateMixSequence => 'Anza Mchanganyiko';

  @override
  String get sessionMetrics => 'Vipimo vya Kipindi';

  @override
  String get gameSession => 'Kipindi cha Mchezo';

  @override
  String get configuration => 'Usanidi';

  @override
  String get terminateSession => 'Maliza Kipindi';

  @override
  String get requestHint => 'Omba Kidokezo';

  @override
  String get systemHint => 'Kidokezo cha Mfumo';

  @override
  String get acknowledge => 'Kubali';

  @override
  String get understood => 'Nimeelewa';

  @override
  String get mixModeProtocol => 'Itifaki ya Hali ya Mchanganyiko';

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
  String get abortSession => 'SITISHA KIPINDI';

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
  String get coreMetrics => 'Vipimo Vikuu';

  @override
  String get progressionStatus => 'Hali ya Maendeleo';

  @override
  String get performanceAnalytics => 'Uchanganuzi wa Utendaji';

  @override
  String get realTimePerformance => 'Utendaji wa Wakati Halisi';

  @override
  String get levelCompletionStats => 'Takwimu za Kukamilisha Ngazi';

  @override
  String get reactionAnalytics => 'Uchanganuzi wa Majibu';

  @override
  String get speedMetrics => 'Vipimo vya Kasi';

  @override
  String get temporalInvestment => 'Muda Uliotumika';

  @override
  String get realTimeAccuracy => 'Usahihi wa Wakati Halisi';

  @override
  String get levelMastery => 'Ujuzi wa Ngazi';

  @override
  String get achievementProgress => 'Maendeleo ya Mafanikio';

  @override
  String get endOfReport => 'Mwisho wa Ripoti';

  @override
  String get welcomeBack => 'Karibu Tena';

  @override
  String get dashboard => 'Dashibodi';

  @override
  String get shop => 'Duka';

  @override
  String get stats => 'Takwimu';

  @override
  String get calc => 'Hesabu';

  @override
  String get dailyMissions => 'Misheni ya Kila Siku';

  @override
  String get close => 'Funga';

  @override
  String get adventure => 'Safari';

  @override
  String get gameModes => 'Njia za Mchezo';

  @override
  String get puzzleWorld => 'Ulimwengu wa Mafumbo';

  @override
  String get resourcesTools => 'Rasilimali na Zana';

  @override
  String get logicRiddles => 'Vitendawili vya Mantiki';

  @override
  String get crossNumbers => 'Nambari Mtambuka';

  @override
  String get crossNumbersDesc => 'Suluhisha mafumbo ya nambari mtambuka';

  @override
  String get calculator => 'Kikokotoo';

  @override
  String get reports => 'Ripoti';

  @override
  String get avatarShop => 'Duka la Avatar';

  @override
  String get focusMode => 'Hali ya Umakini';

  @override
  String get focusModeDesc => 'Muonekano rahisi kwa umakini zaidi';

  @override
  String get performanceMode => 'Hali ya Kasi';

  @override
  String get performanceModeDesc => 'Punguza urembo kwa ajili ya kasi';

  @override
  String get visualTheme => 'Mandhari';

  @override
  String get audioOutput => 'Sauti';

  @override
  String get hapticFeedback => 'Mtetemo';

  @override
  String get notifications => 'Arifa';

  @override
  String get arithmeticMixGenerator => 'Kizalishaji cha Mchanganyiko wa Hesabu';

  @override
  String get custom => 'Maalum';

  @override
  String get nextQuestion => 'Swali Lijalo';

  @override
  String get undo => 'Tendua';

  @override
  String get hint => 'KIDOKezo';

  @override
  String get level_1 => 'Ngazi 1';

  @override
  String get level_2 => 'Ngazi 2';

  @override
  String get level_3 => 'Ngazi 3';

  @override
  String get level_4 => 'Ngazi 4';

  @override
  String get level_5 => 'Ngazi 5';

  @override
  String get level_6 => 'Ngazi 6';

  @override
  String get level_7 => 'Ngazi 7';

  @override
  String get level_8 => 'Ngazi 8';

  @override
  String get level_9 => 'Ngazi 9';

  @override
  String get level_10 => 'Ngazi 10';

  @override
  String get plus => '+';

  @override
  String get minus => '-';

  @override
  String get multiply => '×';

  @override
  String get divide => '÷';

  @override
  String get hotStreak => '🔥 MFULULIZO MKALI!';

  @override
  String get unstoppable => 'Haiwezi Kuzuiwa!';

  @override
  String get keepItUp => '⚡ ENDELEA!';

  @override
  String get streakBroken => '💔 MFULULIZO UMEVUNJWA!';

  @override
  String get selectLanguage => 'Chagua Lugha';

  @override
  String get english => 'Kiingereza';

  @override
  String get swahili => 'Kiswahili';

  @override
  String get swahiliTanzania => 'Kiswahili (Tanzania)';

  @override
  String get languageChanged => 'Lugha imebadilishwa';

  @override
  String get exportReport => 'Hamisha Ripoti';

  @override
  String get practiceProcedure => 'Practice Procedure';

  @override
  String get practiceMode => 'Hali ya Mazoezi';

  @override
  String get feverMode => 'FEVER MODE';

  @override
  String get getHint => 'GET HINT';

  @override
  String hintCost(Object cost) {
    return '$cost PTS';
  }

  @override
  String get takeYourTime => 'Take your time.';

  @override
  String get practiceSession => 'Practice Session';

  @override
  String get accuracyTrend => 'ACCURACY';

  @override
  String get streak => 'MFULULIZO';

  @override
  String get accuracyTrends => 'Mwelekeo wa Usahihi';

  @override
  String get help => 'MSAADA';

  @override
  String get refreshAnalytics => 'Sasisha Takwimu';

  @override
  String get avgSession => 'Wastani wa Kipindi';

  @override
  String get sysOp => 'UENDESHAJI_MFUMO';

  @override
  String get neuralAccuracy => 'USAHIHI_WA_AKILI';

  @override
  String get coreStars => 'NYOTA_ZIKUU';

  @override
  String get unitsCleared => 'VITENGO_VILIVYOKAMILIKA';

  @override
  String get temporalInvestmentLabel => 'TEMPORAL_INVESTMENT';

  @override
  String get status => 'HALI';

  @override
  String get missionActive => 'MISHE_INAENDELEA';

  @override
  String get endOfTransmission => 'MWISHO_WA_MAWASILIANO';

  @override
  String get exportProtocol => 'ITIFAKI_YA_KUTOA';

  @override
  String get dismiss => 'ONDOA';

  @override
  String get debriefCopied => 'RIPOTI_IMEKOPIWA';

  @override
  String get copyToClipboard => 'NAKILI';

  @override
  String get neuralEfficiencyIndex => 'KIELEZO_CHA_UTENDAJI_AKILI';

  @override
  String get performanceScore => 'Alama ya Utendaji';

  @override
  String get avgSpeed => 'Wastani wa Kasi';

  @override
  String get high => 'JUU';

  @override
  String get med => 'WASTANI';

  @override
  String get low => 'CHINI';

  @override
  String get accuracyProgression => 'MAENDELEO_YA_USAHIHI';

  @override
  String get peakAccuracy => 'Usahihi wa Juu';

  @override
  String get responseAnalytics => 'UCHAMBUZI_WA_MAJIBU';

  @override
  String get avgResponse => 'Wastani wa Majibu';

  @override
  String get fastest => 'Haraka Zaidi';

  @override
  String get improvement => 'Uboreshaji';

  @override
  String get livePerformanceMetrics => 'VIPIMO_VYA_UTENDAJI_MUBASHARA';

  @override
  String get currentAccuracy => 'USAHIHI_WA_SASA';

  @override
  String get sessionTime => 'MUDA_WA_KIPINDI';

  @override
  String get activeStreak => 'MFULULIZO_AMILIFU';

  @override
  String get calculating => 'INAWAKALIKULI...';

  @override
  String get difficultyLevelLabel => 'DIFFICULTY_LEVEL';

  @override
  String get advanced => 'ILIYOBORESHWA';

  @override
  String get performanceTrend => 'MWELEKEO_WA_UTEND_KAJI';

  @override
  String get reactionTimeAnalysis => 'Uchambuzi wa Muda wa Kujibu';

  @override
  String get operationUsage => 'Matumizi ya Operesheni';

  @override
  String get levelMasteryBreakdown => 'UCHAMBUZI_WA_UJUZI';

  @override
  String get perfectLevels => 'NGAZI_KAMILIFU';

  @override
  String get levelsWith35Plus => 'Ngazi zenye sahihi 35+';

  @override
  String get highPerformance => 'UTENDAJI_WA_JUU';

  @override
  String get levelsWith30Plus => 'Ngazi zenye sahihi 30+';

  @override
  String get goodProgress => 'MAENDELEO_MAZURI';

  @override
  String get levelsWith25Plus => 'Ngazi zenye sahihi 25+';

  @override
  String get totalAttempts => 'JARIBIO_ZOTE';

  @override
  String get totalLevelsAttempted => 'Jumla ya ngazi';

  @override
  String get player => 'MCHEZAJI';

  @override
  String get del => 'FUTA';

  @override
  String get mc => 'MC';

  @override
  String get mr => 'MR';

  @override
  String get divByZero => 'GAWANYA NA SIFURI';

  @override
  String get allModes => 'Njia Zote';

  @override
  String get mathLearningProgress => 'Maendeleo ya Kujifunza Hisabati';

  @override
  String get preparingPdf => 'Inatayarisha PDF...';

  @override
  String get overview => 'Muhtasari';

  @override
  String get myGaasProgressReport =>
      'Ripoti Yangu ya Maendeleo ya Hisabati ya GAAS';

  @override
  String get pdfSharedSuccessfully => 'PDF imeshirikiwa kwa mafanikio!';

  @override
  String shareFailed(Object error) {
    return 'Ushiriki umeshindwa: $error';
  }

  @override
  String get readyToChallenge => '🎯 Tayari Kupambana na Changamoto?';

  @override
  String get masterMathematicsDesc =>
      'Boresha hesabu kupitia michezo ya kuvutia na fuatilia maendeleo yako.';

  @override
  String get yourProgress => '📊 Maendeleo Yako';

  @override
  String get starsEarned => 'Nyota Zilizopatikana';

  @override
  String get quickActions => '⚡ Vitendo vya Haraka';

  @override
  String get dailyChallenge => 'Changamoto ya Kila Siku';

  @override
  String get completeTodaysChallenge =>
      'Kamilisha changamoto ya hesabu ya leo ili upate thawabu za ziada!';

  @override
  String get challengeReward => '🔥 Matatizo 5 • Thawabu 100 XP';

  @override
  String get completeLevelsProgressively => 'Kamilisha ngazi hatua kwa hatua';

  @override
  String get fastPacedChallenges => 'Changamoto za kasi ya juu';

  @override
  String get improveSpecificSkills => 'Boresha ujuzi maalum';

  @override
  String get createYourOwnChallenges => 'Tengeneza changamoto zako mwenyewe';

  @override
  String get goodMorning => 'Habari za asubuhi';

  @override
  String get goodAfternoon => 'Habari za mchana';

  @override
  String get goodEvening => 'Habari za jioni';

  @override
  String get goodNight => 'Habari za usiku';

  @override
  String get welcomeToGAAS => 'Karibu kwenye GAAS';

  @override
  String get quickStart => 'Anza Haraka';

  @override
  String get campaignMode => 'Hali ya Kampeni';

  @override
  String get startYourMathematicalJourney => 'Anza safari yako ya hisabati';

  @override
  String get focusOnSpecificOperations => 'Zingatia operesheni maalum';

  @override
  String get arcadeMode => 'Hali ya Kumbi ya Michezo';

  @override
  String get fastPacedGamingExperience => 'Uzoefu wa michezo wa kasi ya juu';

  @override
  String get cancel => 'Ghairi';

  @override
  String get chapter => 'SURA';

  @override
  String chapterStarsProgress(Object stars, Object total) {
    return '$stars / $total NYOTA';
  }

  @override
  String lockedNeedStars(Object stars) {
    return 'IMEFUNGWA - UNAHITAJI JUMLA YA NYOTA $stars';
  }

  @override
  String get solveLogicChallenges => 'Suluhisha fumbo za akili ngumu';

  @override
  String get pushUpdates => 'Arifa za Kushinikiza';

  @override
  String get sfxAndMusic => 'Sauti na Muziki';

  @override
  String get tactileResponse => 'Jibu la Kugusa';

  @override
  String get noLimit => 'Hakuna kikomo';

  @override
  String get equipped => 'IMEVAALIWA';

  @override
  String get achievementUnlocked => 'MAFANIKIO_YAMEFUNGULIWA';

  @override
  String get protocolInitialized =>
      'Itifaki \"Mkusanyaji wa Nyota\" imewashwa.';

  @override
  String get newLogicNodesAvailable =>
      'Nodi mpya za akili zinapatikana kwa usindikaji.';

  @override
  String get levelClearanceGranted =>
      'Kibali cha ngazi 10 kimetolewa. Sekta mpya zimefunguliwa.';

  @override
  String get viewStreak => 'Angalia Mfululizo';

  @override
  String get viewAchievement => 'Angalia Mafanikio';

  @override
  String get startMission => 'Anza Utume';

  @override
  String get viewProgress => 'Angalia Maendeleo';

  @override
  String hoursAgo(Object count) {
    return 'saa $count zilizopita';
  }

  @override
  String daysAgo(Object count) {
    return 'siku $count zilizopita';
  }

  @override
  String get pleaseEnterYourName => 'Tafadhali weka jina lako';

  @override
  String get errorSavingProfile => 'Kosa katika kuhifadhi wasifu';

  @override
  String get welcomeExclamation => 'Karibu!';

  @override
  String get editProfile => 'Hariri Wasifu';

  @override
  String get letsSetupYourProfile => 'Wacha tuanzishe wasifu wako';

  @override
  String get customizeYourProfile => 'Badilisha wasifu wako';

  @override
  String get getStarted => 'Anza';

  @override
  String get yourName => 'Jina Lako';

  @override
  String get enterYourName => 'Weka jina lako';

  @override
  String get avatarShape => 'Umbo la Picha';

  @override
  String get avatarColor => 'Rangi ya Picha';

  @override
  String get basicMode => 'Hali ya Msingi';

  @override
  String get scientificMode => 'Hali ya Kisayansi';

  @override
  String get calculationHistory => 'Historia ya Hesabu';

  @override
  String get noCalculationsYet => 'Hakuna hesabu bado';

  @override
  String get memory => 'Kumbukumbu';

  @override
  String get memoryIsEmpty => 'Kumbukumbu ni tupu';

  @override
  String get switchLanguage => 'Badilisha Lugha';

  @override
  String get switchedTo => 'Imepitishwa hadi';

  @override
  String get userProfile => 'Wasifu wa Mtumiaji';

  @override
  String get systemStatusActive => 'Hali ya Mfumo: Amilifu';

  @override
  String get storeAndCustomization => 'Duka na Ubadilishaji';

  @override
  String get unlockNewAvatarsWithPoints => 'Fungua picha mpya kwa pointi';

  @override
  String get systemSettings => 'Mipangilio ya Mfumo';

  @override
  String get interface => 'Kiolesura';

  @override
  String get audioAndHaptics => 'Sauti na Miguso';

  @override
  String get builtInArithmeticTool => 'Zana ya hesabu iliyojengwa ndani';

  @override
  String get quickLanguageToggle => 'Kubadili Lugha Haraka';

  @override
  String get stargazer => 'Mtazamaji wa Nyota';

  @override
  String get sharpshooter => 'Mpiga Shaba';

  @override
  String get timeLord => 'Bwana wa Muda';

  @override
  String get scholar => 'Msomi';

  @override
  String get selectTheme => 'Chagua Mandhari';

  @override
  String get correctAnswer => 'Sahihi!';

  @override
  String get wrongAnswer => 'Si sahihi!';

  @override
  String get achievements => 'Mafanikio';

  @override
  String get save => 'Hifadhi';

  @override
  String get activeChallenges => 'Changamoto Zinazoendelea';

  @override
  String get speedDemon => 'Shetani wa Kasi';

  @override
  String get speedDemonDesc => 'Jibu haraka iwezekanavyo!';

  @override
  String get mathMaster => 'Mwalimu wa Hesabu';

  @override
  String get mathMasterDesc => 'Pata usahihi kamili';

  @override
  String get marathon => 'Mbio za Masafa Marefu';

  @override
  String get marathonDesc => 'Changamoto ya uvumilivu';

  @override
  String get practiceLab => 'Maabara ya Mazoezi';

  @override
  String get configurations => 'Usanidi';

  @override
  String get visualCountingDesc => 'Hesabu maumbo na vitu';

  @override
  String get timePressure => 'Shinikizo la Muda';

  @override
  String get timePressureDesc => 'Pambana na muda';

  @override
  String get adaptiveDifficulty => 'Ugumu wa Kujirekebisha';

  @override
  String get adaptiveDifficultyDesc =>
      'Ugumu unarekebishwa kulingana na ujuzi wako';

  @override
  String get timeLimit => 'Kikomo cha Muda';

  @override
  String get questionsCount => 'Idadi ya Maswali';

  @override
  String get startPractice => 'Anza Mazoezi';

  @override
  String get additionProcedure => 'Hali ya Kuongeza';

  @override
  String get subtractionProcedure => 'Hali ya Kutoa';

  @override
  String get multiplicationProcedure => 'Hali ya Kuzidisha';

  @override
  String get divisionProcedure => 'Hali ya Kugawanya';

  @override
  String get timesUp => 'Wakati Umeisha!';

  @override
  String get yourScore => 'Alama yako';

  @override
  String get exit => 'Toka';

  @override
  String get operation => 'Operesheni';

  @override
  String get dailyRewardClaimed => 'Zawadi ya kila siku imenukuliwa!';

  @override
  String get claimTodaysReward => 'CHUKUA ZAWADI YA LEO';

  @override
  String get noGameSession => 'Hakuna kipindi cha mchezo';

  @override
  String get playerLabel => 'Mchezaji';

  @override
  String get generatingImage => 'Inatengeneza picha...';

  @override
  String get imageSharedSuccessfully => 'Picha imeshirikiwa!';

  @override
  String get imageExportFailed => 'Imeshindwa kutoa picha';

  @override
  String get preparingDocument => 'Inatayarisha hati...';

  @override
  String get performanceReportTitle => 'Ripoti ya Utendaji ya GAAS';

  @override
  String reportSaved(Object path) {
    return 'Ripoti imehifadhiwa: $path';
  }

  @override
  String reportSaveFailed(Object error) {
    return 'Imeshindwa kuhifadhi: $error';
  }

  @override
  String get generatingPdf => 'Inatengeneza PDF...';

  @override
  String get skip => 'RUKA';

  @override
  String get allChallengesComplete => 'Changamoto zote zimekamilika!';

  @override
  String get play => 'Cheza';

  @override
  String get unlimitedTime => 'Muda Usio na Kikomo';

  @override
  String get practiceWithoutPressure => 'Mazoezi bila shinikizo';

  @override
  String get showFeedback => 'Onyesha Majibu';

  @override
  String get seeCorrectAnswersImmediately => 'Ona majibu sahihi papo hapo';

  @override
  String get answerRevealed => 'Jibu limeonyeshwa!';

  @override
  String get excellent => 'Excellent!';

  @override
  String get done => 'Done';

  @override
  String get selectRiddleLevel => 'CHAGUA NGAZI YA FUMBO';

  @override
  String get loadingGame => 'Mchezo unapakia...';

  @override
  String get thankYouForFeedback => 'Asante kwa maoni yako!';

  @override
  String get notEnoughPoints => 'Pointi hazitoshi! Endelea kucheza.';

  @override
  String get avatarUnlocked => 'Avatar imefunguliwa!';

  @override
  String get documentSentToPrinter => 'Hati imetumwa kwenye printa!';

  @override
  String printFailed(Object error) {
    return 'Imeshindwa kuchapisha: $error';
  }

  @override
  String get noProgressDataAvailable => 'Hakuna data ya maendeleo';

  @override
  String get exportOptions => 'Chaguzi za Kuhamisha';

  @override
  String get exportAsPdf => 'Hamisha kama PDF';

  @override
  String get generateDetailedPdfReport =>
      'Tengeneza na shiriki ripoti ya kina ya PDF';

  @override
  String get shareAsImage => 'Shiriki kama Picha';

  @override
  String get captureHighQualityImage =>
      'Piga picha ya ubora wa juu na ishiriki ripoti';

  @override
  String get printReport => 'Chapisha Ripoti';

  @override
  String get sendReportToPrinter => 'Tuma ripoti kwa printa';

  @override
  String get saveToDevice => 'Hifadhi kwenye Kifaa';

  @override
  String get savePdfToDeviceStorage => 'Hifadhi PDF kwenye hifadhi ya kifaa';

  @override
  String get firstSteps => 'Hatua za Mwanzo';

  @override
  String get firstStepsDesc => 'Jibu swali lako la kwanza kwa usahihi';

  @override
  String get speedDemonTitle => 'Shetani wa Kasi';

  @override
  String get mathMasterTitle => 'Mwalimu wa Hesabu';

  @override
  String get weeklyChampion => 'Bingwa wa Wiki';

  @override
  String get streakMaster => 'Bingwa wa Mfululizo';

  @override
  String get puzzleGenius => 'Genius wa Mafumbo';

  @override
  String get timeLordTitle => 'Bwana wa Muda';

  @override
  String get onFire => 'Anawaka!';

  @override
  String get onFireDesc => 'Pata majibu 5 sahihi mfululizo';

  @override
  String get perfectScore => 'Alama Kamili';

  @override
  String get weekendMaster => 'Bingwa wa Wikiendi';

  @override
  String get equip => 'VAZA';

  @override
  String get coreConcept => 'Dhana ya Msingi';

  @override
  String get adventureTitle => 'SAFARI';

  @override
  String get campaignProgression => 'Maendeleo ya Safari';

  @override
  String get challengeTitle => 'CHANGAMOTO';

  @override
  String get arcadeDailyMissions => 'Ukumbi + Misheni';

  @override
  String get puzzlesTitle => 'MAFUMBO';

  @override
  String get mathRiddles => 'Math Riddles';

  @override
  String get firstVictory => 'Ushindi wa Kwanza';

  @override
  String get campaignMaster => 'Bingwa wa Msafara';

  @override
  String get mathGenius => 'Genius wa Hesabu';

  @override
  String get unstoppableDesc => 'Pata majibu 10 sahihi mfululizo';

  @override
  String get heatIndexDesc =>
      'Dumisha Kielezo cha Joto juu ya 2.5 kwa kipindi chote';

  @override
  String get flashCalculator => 'Kikokotoo cha Haraka';

  @override
  String get flashCalculatorDesc =>
      'Jibu maswali 50 kwa wastani wa muda chini ya sekunde 2';

  @override
  String get dedicated => 'Aliyejitolea';

  @override
  String get dedicatedDesc => 'Jibu maswali 500';

  @override
  String get stargazerDesc => 'Pata nyota zako 10 za kwanza';

  @override
  String get centuryDesc => 'Jibu maswali 100';

  @override
  String get mathGeniusDesc => 'Jibu maswali 1000';

  @override
  String get perfectScoreDesc => 'Pata usahihi wa 100% katika mchezo wowote';

  @override
  String get weeklyChampionDesc => 'Cheza kwa siku 7 mfululizo';

  @override
  String get campaignMasterDesc => 'Kamilisha ngazi zote za kampeni';

  @override
  String get duelMasterDesc => 'Shinda mechi 10 za pambano';

  @override
  String get legendDesc => 'Pata majibu 25 sahihi mfululizo';

  @override
  String get sharpMind => 'Akili Kali';

  @override
  String sharpMindDesc(Object percentage) {
    return 'Fikia usahihi wa $percentage% katika hali yoyote ya mchezo';
  }

  @override
  String get speedRun => 'Mbio za Kasi';

  @override
  String speedRunDesc(Object seconds) {
    return 'Jibu maswali 10 chini ya sekunde $seconds';
  }

  @override
  String get committed => 'Aliyejitolea';

  @override
  String get committedDesc => 'Cheza kwa siku 30 mfululizo';

  @override
  String get masterOfOperations => 'Mwalimu wa Operesheni';

  @override
  String get masterOfOperationsDesc => 'Tumia operesheni zote nne';

  @override
  String get highScorer => 'Mfungaji Bora';

  @override
  String highScorerDesc(Object points) {
    return 'Pata pointi $points katika mchezo mmoja';
  }

  @override
  String get earlyBird => 'Ndege wa Mapema';

  @override
  String get earlyBirdDesc =>
      'Cheza mchezo wako wa kwanza wa siku kabla ya saa 2 asubuhi';

  @override
  String get precisionExpert => 'Mtaalamu wa Usahihi';

  @override
  String get accuracyMaster => 'Mwalimu wa Usahihi';

  @override
  String get lightningFast => 'Kasi ya Umeme';

  @override
  String lightningFastDesc(Object seconds) {
    return 'Kamilisha ngazi chini ya sekunde $seconds';
  }

  @override
  String get instantReaction => 'Mwitikio wa Papo hapo';

  @override
  String get comboKing => 'Mfalme wa Combo';

  @override
  String comboKingDesc(Object multiplier) {
    return 'Fikia kizidishio cha combo cha ${multiplier}x';
  }

  @override
  String get performanceMasterDesc =>
      'Fikia usahihi wa 95% na wastani wa muda chini ya sekunde 15';

  @override
  String get consistentPlayer => 'Mchezaji Thabiti';

  @override
  String consistentPlayerDesc(Object count, Object percentage) {
    return 'Dumisha usahihi wa $percentage% kwa maswali $count mfululizo';
  }

  @override
  String get nightOwl => 'Bundi wa Usiku';

  @override
  String get nightOwlDesc => 'Cheza mchezo baada ya saa 4 usiku';

  @override
  String get weekendWarrior => 'Shujaa wa Wikiendi';

  @override
  String get weekendWarriorDesc => 'Cheza Jumamosi na Jumapili';

  @override
  String get firstPlace => 'Nafasi ya Kwanza';

  @override
  String get firstPlaceDesc => 'Fikia nafasi ya #1 kwenye ubao wa wanaoongoza';

  @override
  String get modeExplorer => 'Mvumbuzi wa Njia';

  @override
  String get modeExplorerDesc => 'Cheza njia zote za mchezo';

  @override
  String get precisionStrike => 'Shambulio la Usahihi';

  @override
  String get precisionStrikeDesc => 'Kamilisha ngazi yenye majibu 35+ sahihi';

  @override
  String get masterLevel => 'Ngazi ya Ustadi';

  @override
  String get masterLevelDesc => 'Kamilisha ngazi yenye majibu 40+ sahihi';

  @override
  String get perfectLevel => 'Ngazi Kamilifu';

  @override
  String get perfectLevelDesc => 'Kamilisha ngazi yenye maswali yote 45 sahihi';

  @override
  String get risingStar => 'Nyota Inayochomoza';

  @override
  String get risingStarDesc => 'Fungua ngazi 10 za kampeni';

  @override
  String get mathWarrior => 'Shujaa wa Hesabu';

  @override
  String get mathWarriorDesc => 'Fungua ngazi 25 za kampeni';

  @override
  String get campaignConqueror => 'Mshindi wa Kampeni';

  @override
  String get campaignConquerorDesc => 'Kamilisha ngazi zote 50 za kampeni';

  @override
  String get questionMaster => 'Mwalimu wa Maswali';

  @override
  String get questionMasterDesc => 'Jibu maswali 1000 katika kategoria tofauti';

  @override
  String get lightningLevel => 'Ngazi ya Umeme';

  @override
  String get lightningLevelDesc =>
      'Kamilisha ngazi ya maswali 45 chini ya sekunde 45';

  @override
  String get consistencyMaster => 'Mwalimu wa Uthabiti';

  @override
  String get starCollector => 'Mkusanyaji wa Nyota';

  @override
  String get stellarPerformer => 'Mtendaji Bora';

  @override
  String get stellarPerformerDesc => 'Pata nyota 50';

  @override
  String get celestialMaster => 'Mwalimu wa Mbinguni';

  @override
  String get celestialMasterDesc => 'Pata nyota 100';

  @override
  String get riddleMaster => 'Mwalimu wa Vitendawili';

  @override
  String get riddleMasterDesc => 'Kamilisha ngazi zote 30 za vitendawili';

  @override
  String get hintHoarder => 'Mkusanyaji wa Vidokezo';

  @override
  String get hintHoarderDesc => 'Pata vidokezo 50';

  @override
  String get gridExplorer => 'Mvumbuzi wa Gridi';

  @override
  String get gridExplorerDesc => 'Kamilisha mafumbo 5 ya Nambari Mtambuka';

  @override
  String get lightningGrid => 'Gridi ya Umeme';

  @override
  String get lightningGridDesc =>
      'Kamilisha fumbo la 7x7 la Nambari Mtambuka chini ya sekunde 90';

  @override
  String get logicArchitect => 'Mbunifu wa Mantiki';

  @override
  String get logicArchitectDesc => 'Kamilisha mafumbo 50 ya Nambari Mtambuka';

  @override
  String get campaignGrinder => 'Mshiriki wa Kampeni';

  @override
  String get duelMaster => 'Bingwa wa Pambano';

  @override
  String get endlessSurvivor => 'Mshindi wa Endless';

  @override
  String get divisionExpert => 'Mtaalamu wa Kugawanya';

  @override
  String get additionMastery => 'Ujuzi wa Kuongeza';

  @override
  String get singleDigitAddition => 'Kuongeza Nambari Moja';

  @override
  String get twoDigitAddition => 'Kuongeza Nambari Mbili';

  @override
  String get threeDigitAddition => 'Kuongeza Nambari Tatu';

  @override
  String get additionWithCarrying => 'Kuongeza kwa Kubeba';

  @override
  String get advancedAddition => 'Kuongeza ya Juu';

  @override
  String get subtractionMastery => 'Ujuzi wa Kutoa';

  @override
  String get singleDigitSubtraction => 'Kutoa Nambari Moja';

  @override
  String get twoDigitSubtraction => 'Kutoa Nambari Mbili';

  @override
  String get threeDigitSubtraction => 'Kutoa Nambari Tatu';

  @override
  String get subtractionWithBorrowing => 'Kutoa kwa Kukopa';

  @override
  String get advancedSubtraction => 'Kutoa ya Juu';

  @override
  String get multiplicationMastery => 'Ujuzi wa Kuzidisha';

  @override
  String get timesTables1to5 => 'Majedwali ya Kuzidisha 1-5';

  @override
  String get timesTables6to10 => 'Majedwali ya Kuzidisha 6-10';

  @override
  String get twoDigitMultiplication => 'Kuzidisha Nambari Mbili';

  @override
  String get threeDigitMultiplication => 'Kuzidisha Nambari Tatu';

  @override
  String get advancedMultiplication => 'Kuzidisha ya Juu';

  @override
  String get multiplicationPatterns => 'Mifumo ya Kuzidisha';

  @override
  String get divisionMastery => 'Ujuzi wa Kugawanya';

  @override
  String get divisionBasics => 'Misingi ya Kugawanya';

  @override
  String get divisionWithRemainders => 'Kugawanya na Mabaki';

  @override
  String get twoDigitDivision => 'Kugawanya Nambari Mbili';

  @override
  String get threeDigitDivision => 'Kugawanya Nambari Tatu';

  @override
  String get longDivision => 'Kugawanya kwa Muda Mrefu';

  @override
  String get legend => 'Hadithi';

  @override
  String get century => 'Karne';

  @override
  String get mathEquationsLevelPrefix => 'HESABU za MATH - NGazi';

  @override
  String get selectDifficultyLevel => 'CHAGUA KIWANGO CHA UGUMU';

  @override
  String get levelPrefix => 'N';

  @override
  String get performanceOverview => 'Muhtasari wa Utendaji';

  @override
  String get currentSession => 'Kipindi cha Sasa';

  @override
  String get realTimeStats => 'Takwimu za Wakati Halisi';

  @override
  String get questions => 'Maswali';

  @override
  String get bestStreak => 'Mfululizo Bora';

  @override
  String get sessions => 'Vipindi';

  @override
  String get gameModeDistribution => 'Usambazaji wa Modi ya Mchezo';

  @override
  String get performanceInsights => 'Maarifa ya Utendaji';

  @override
  String get bestAccuracy => 'Usahihi Bora';

  @override
  String get averageResponseTime => 'Muda wa Wastani wa Kujibu';

  @override
  String get completionRate => 'Kiwango cha Ukamilishaji';

  @override
  String get engineIntensity => 'NGUVU YA INJINI';

  @override
  String get averageHeat => 'WASTANI WA JOTO';

  @override
  String get currentHeat => 'JOTO LA SASA';

  @override
  String get maxHeat => 'JOTO LA JUU';

  @override
  String get heatIndex => 'Kielezo cha Joto';

  @override
  String get intensityNormal => 'KAWAIDA';

  @override
  String get intensityMedium => 'WASTANI';

  @override
  String get intensityHigh => 'JUU';

  @override
  String get intensityCritical => 'HATARI';

  @override
  String get totalScore => 'JUMLA YA ALAMA';

  @override
  String xpToLevelFull(Object xp) {
    return '$xp XP hadi NGAZI INAYOFUATA';
  }

  @override
  String get achiever => 'MFIKIAJI';

  @override
  String get avatarUnlocks => 'UFUNGUAJI WA AVATAR';

  @override
  String requiresLevelAndStars(Object level, Object stars) {
    return 'Inahitaji Ngazi ya $level na nyota $stars!';
  }

  @override
  String requiresStarsToUnlock(Object stars) {
    return 'Inahitaji nyota $stars ili kufungua!';
  }

  @override
  String requiresLevelToUnlock(Object level) {
    return 'Inahitaji Ngazi ya $level ili kufungua!';
  }

  @override
  String get unlockAvatarQuestion => 'Fungua Avatar?';

  @override
  String unlockAvatarConfirm(Object cost, Object name) {
    return 'Je, unataka kutumia pointi $cost kufungua avatar ya $name?';
  }

  @override
  String get unlock => 'Fungua';

  @override
  String get rarityCommon => 'Kawaida';

  @override
  String get rarityUncommon => 'Si ya Kawaida';

  @override
  String get rarityRare => 'Adimu';

  @override
  String get rarityEpic => 'Epic';

  @override
  String get rarityLegendary => 'Hadithi';

  @override
  String get rarityMythic => 'Mythic';

  @override
  String generatedOn(Object date) {
    return 'Imetolewa mnamo $date';
  }

  @override
  String get challengesSummary => 'Challenges Summary';

  @override
  String get dailyChallenges => 'Daily Challenges';

  @override
  String get weeklyChallenges => 'Weekly Challenges';

  @override
  String get claimed => 'Claimed';
}
