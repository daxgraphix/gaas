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

  int calculateStars(int timeSeconds, int hintsUsed, bool isCorrect) {
    if (!isCorrect) return 0;
    double timeScore = (timeSeconds < 30)
        ? 3
        : (timeSeconds < 60)
        ? 2
        : 1;
    double hintPenalty = hintsUsed * 0.3;
    double score = timeScore - hintPenalty;
    if (score >= 2.5) return 3;
    if (score >= 1.5) return 2;
    return 1;
  }
}

class MathRiddleState {
  final MathRiddle riddle;
  final String? selectedAnswer;
  final List<String> revealedHints;
  final bool isCorrect;
  final bool isAnswered;
  final int timeSpentSeconds;

  const MathRiddleState({
    required this.riddle,
    this.selectedAnswer,
    this.revealedHints = const [],
    this.isCorrect = false,
    this.isAnswered = false,
    this.timeSpentSeconds = 0,
  });

  MathRiddleState copyWith({
    MathRiddle? riddle,
    String? selectedAnswer,
    List<String>? revealedHints,
    bool? isCorrect,
    bool? isAnswered,
    int? timeSpentSeconds,
  }) {
    return MathRiddleState(
      riddle: riddle ?? this.riddle,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      revealedHints: revealedHints ?? this.revealedHints,
      isCorrect: isCorrect ?? this.isCorrect,
      isAnswered: isAnswered ?? this.isAnswered,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
    );
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
