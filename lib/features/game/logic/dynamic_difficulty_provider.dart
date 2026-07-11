import 'package:flutter_riverpod/flutter_riverpod.dart';

class DynamicDifficultyNotifier extends StateNotifier<double> {
  DynamicDifficultyNotifier() : super(1.0);

  void recordAssessment({required bool isCorrect}) {
    if (isCorrect) {
      state = (state + 0.1).clamp(1.0, 10.0);
    } else {
      state = (state - 0.2).clamp(1.0, 10.0);
    }
  }
}

final dynamicDifficultyProvider = StateNotifierProvider<DynamicDifficultyNotifier, double>((ref) {
  return DynamicDifficultyNotifier();
});
