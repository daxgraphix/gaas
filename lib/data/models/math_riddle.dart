enum MathRiddleType { arithmetic, wordProblem, numberSequence, logicChallenge }

enum ArithmeticOperation { addition, subtraction, multiplication, division }

class MathRiddle {
  final String id;
  final MathRiddleType type;
  final int difficulty;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final List<String> progressiveHints;
  final int basePoints;

  const MathRiddle({
    required this.id,
    required this.type,
    required this.difficulty,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.progressiveHints,
    required this.basePoints,
  });

  int get hintCount => progressiveHints.length;

  int calculateStars(int timeSeconds, int hintsUsed, bool isCorrect, {int correctCount = 0}) {
    if (!isCorrect || correctCount < 15) return 0;
    
    if (correctCount >= 18) return 3;
    if (correctCount >= 16) return 2;
    if (correctCount >= 15) return 1;
    return 0;
  }
}

class MathRiddleState {
  final MathRiddle? currentRiddle;
  final NumberSequence? currentSequence;
  final LogicMathChallenge? currentLogic;
  final String? selectedAnswer;
  final List<String> revealedHints;
  final bool isCorrect;
  final bool isAnswered;
  final int timeSpentSeconds;
  final int level;
  final int questionIndex;
  final int correctAnswers;
  final int currentStreak;
  final int totalQuestions;
  final int hintsUsed;
  final List<dynamic> allChallenges;

  const MathRiddleState({
    this.currentRiddle,
    this.currentSequence,
    this.currentLogic,
    this.selectedAnswer,
    this.revealedHints = const [],
    this.isCorrect = false,
    this.isAnswered = false,
    this.timeSpentSeconds = 0,
    this.level = 1,
    this.questionIndex = 0,
    this.correctAnswers = 0,
    this.currentStreak = 0,
    this.totalQuestions = 20,
    this.hintsUsed = 0,
    this.allChallenges = const [],
  });

  MathRiddleState copyWith({
    MathRiddle? currentRiddle,
    NumberSequence? currentSequence,
    LogicMathChallenge? currentLogic,
    String? selectedAnswer,
    List<String>? revealedHints,
    bool? isCorrect,
    bool? isAnswered,
    int? timeSpentSeconds,
    int? level,
    int? questionIndex,
    int? correctAnswers,
    int? currentStreak,
    int? totalQuestions,
    int? hintsUsed,
    List<dynamic>? allChallenges,
  }) {
    return MathRiddleState(
      currentRiddle: currentRiddle ?? this.currentRiddle,
      currentSequence: currentSequence ?? this.currentSequence,
      currentLogic: currentLogic ?? this.currentLogic,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      revealedHints: revealedHints ?? this.revealedHints,
      isCorrect: isCorrect ?? this.isCorrect,
      isAnswered: isAnswered ?? this.isAnswered,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      level: level ?? this.level,
      questionIndex: questionIndex ?? this.questionIndex,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      currentStreak: currentStreak ?? this.currentStreak,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      allChallenges: allChallenges ?? this.allChallenges,
    );
  }

  double get levelProgress => totalQuestions > 0 ? questionIndex / totalQuestions : 0;
  bool get levelPassed => correctAnswers >= 15;
  int get stars {
    if (correctAnswers < 15) return 0;
    if (correctAnswers >= 18) return 3;
    if (correctAnswers >= 16) return 2;
    if (correctAnswers >= 15) return 1;
    return 0;
  }
}

class NumberSequence {
  final String id;
  final List<int> sequence;
  final int missingIndex;
  final String rule;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final List<String> progressiveHints;
  final int difficulty;

  const NumberSequence({
    required this.id,
    required this.sequence,
    required this.missingIndex,
    required this.rule,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.progressiveHints,
    required this.difficulty,
  });

  String get displaySequence {
    final display = List<String>.from(sequence.map((n) => n.toString()));
    display.insert(missingIndex, '?');
    return display.join(', ');
  }
}

class LogicMathChallenge {
  final String id;
  final String problem;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final List<String> progressiveHints;
  final int difficulty;
  final int basePoints;

  const LogicMathChallenge({
    required this.id,
    required this.problem,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.progressiveHints,
    required this.difficulty,
    required this.basePoints,
  });
}
