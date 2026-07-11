import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/math_riddle.dart';
import '../../game/logic/game_session_provider.dart';

enum CustomMixMode { standard, suddenDeath, zen, timeAttack }

class CustomMixArithmeticState {
  final List<ArithmeticOperation> selectedOperations;
  final int selectedDifficulty;
  final CustomMixMode mode;
  final bool isActive;

  CustomMixArithmeticState({
    this.selectedOperations = const [],
    this.selectedDifficulty = 5,
    this.mode = CustomMixMode.standard,
    this.isActive = false,
  });

  CustomMixArithmeticState copyWith({
    List<ArithmeticOperation>? selectedOperations,
    int? selectedDifficulty,
    CustomMixMode? mode,
    bool? isActive,
  }) {
    return CustomMixArithmeticState(
      selectedOperations: selectedOperations ?? this.selectedOperations,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      mode: mode ?? this.mode,
      isActive: isActive ?? this.isActive,
    );
  }
}

class CustomMixArithmeticNotifier extends StateNotifier<CustomMixArithmeticState> {
  final Ref ref;

  CustomMixArithmeticNotifier(this.ref) : super(CustomMixArithmeticState());

  void toggleOperation(ArithmeticOperation op) {
    final current = List<ArithmeticOperation>.from(state.selectedOperations);
    if (current.contains(op)) {
      current.remove(op);
    } else {
      current.add(op);
    }
    state = state.copyWith(selectedOperations: current);
  }

  void setDifficulty(int difficulty) {
    state = state.copyWith(selectedDifficulty: difficulty);
  }

  void setMode(CustomMixMode mode) {
    state = state.copyWith(mode: mode);
  }

  void startMix() {
    if (state.selectedOperations.isEmpty) return;

    final totalQuestions = state.mode == CustomMixMode.timeAttack ? 100 : 20;
    final timeLimit = state.mode == CustomMixMode.timeAttack ? 60 : (state.mode == CustomMixMode.suddenDeath ? 10 : 0);

    ref.read(gameSessionProvider.notifier).startGame(
      mode: GameMode.customMix,
      operation: state.selectedOperations.map((e) => e.name).join(','),
      level: state.selectedDifficulty,
      totalQuestions: totalQuestions,
      timeLimit: timeLimit > 0 ? timeLimit : null,
    );
    
    state = state.copyWith(isActive: true);
  }

  void resetMix() {
    state = state.copyWith(isActive: false);
  }
}

final customMixArithmeticProvider = StateNotifierProvider<CustomMixArithmeticNotifier, CustomMixArithmeticState>((ref) {
  return CustomMixArithmeticNotifier(ref);
});
