import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_mode.dart';
import '../models/question.dart';

class GameState {
  final GameMode mode;
  final List<Question> questions;
  final int currentIndex;
  final bool isFlipped;

  const GameState({
    required this.mode,
    required this.questions,
    this.currentIndex = 0,
    this.isFlipped = false,
  });

  GameState copyWith({int? currentIndex, bool? isFlipped}) {
    return GameState(
      mode: mode,
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      isFlipped: isFlipped ?? this.isFlipped,
    );
  }

  Question? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  bool get isLastCard => currentIndex >= questions.length - 1;
  int get totalCards => questions.length;
}

final gameStateProvider = StateNotifierProvider<GameNotifier, GameState?>((ref) {
  return GameNotifier();
});

class GameNotifier extends StateNotifier<GameState?> {
  GameNotifier() : super(null);

  /// Shuffles [questions] and takes up to [maxCards] for the session.
  void startGame(GameMode mode, List<Question> questions,
      {int maxCards = 30}) {
    final shuffled = [...questions]..shuffle(Random());
    state = GameState(
      mode: mode,
      questions: shuffled.take(maxCards).toList(),
    );
  }

  void flip() {
    if (state == null) return;
    state = state!.copyWith(isFlipped: !state!.isFlipped);
  }

  void next() {
    if (state == null || state!.isLastCard) return;
    state = state!.copyWith(
      currentIndex: state!.currentIndex + 1,
      isFlipped: false,
    );
  }

  void reset() => state = null;
}
