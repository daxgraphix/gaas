import '../models/math_riddle.dart';

class MathRiddlesRepository {
  Future<List<MathRiddle>> getRiddles() async {
    // Return a dummy list or load from a data source
    return [
      MathRiddle(
        id: '1',
        type: MathRiddleType.arithmetic,
        question: 'What is 2 + 2?',
        options: ['2', '3', '4', '5'],
        correctAnswer: '4',
        explanation: 'Addition of 2 and 2 is 4.',
        difficulty: 1,
        progressiveHints: ['Count them on your fingers', 'It is even'],
        basePoints: 10,
      ),
      MathRiddle(
        id: '2',
        type: MathRiddleType.arithmetic,
        question: 'What is 5 * 3?',
        options: ['8', '12', '15', '20'],
        correctAnswer: '15',
        explanation: 'Multiplication of 5 and 3 is 15.',
        difficulty: 1,
        progressiveHints: ['5 + 5 + 5', 'Ends in 5'],
        basePoints: 15,
      ),
    ];
  }
}
