import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Player display names — initialised when the player count is confirmed.
final playerNamesProvider = StateProvider<List<String>>((ref) => []);

/// Running scores — one entry per player, same order as [playerNamesProvider].
final playerScoresProvider = StateProvider<List<int>>((ref) => []);

/// 'easy' | 'medium' | 'hard'
final friendsDifficultyProvider = StateProvider<String>((ref) => 'medium');

/// Countdown seconds per question (10, 20, or 30).
final friendsTimerSecondsProvider = StateProvider<int>((ref) => 20);
