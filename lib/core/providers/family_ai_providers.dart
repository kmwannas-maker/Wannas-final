import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/activity.dart';
import '../models/heart_card.dart';
import '../services/claude_service.dart';

// ── Shared service ────────────────────────────────────────────────────────────

final claudeServiceProvider = Provider<ClaudeService>((_) => ClaudeService());

// ── Activities ────────────────────────────────────────────────────────────────

class ActivitiesState {
  final AsyncValue<List<Activity>> activities;
  final int numKids;
  final List<int> kidAges;
  final String location;

  const ActivitiesState({
    this.activities = const AsyncValue.data([]),
    this.numKids = 1,
    this.kidAges = const [6],
    this.location = 'Home',
  });

  ActivitiesState copyWith({
    AsyncValue<List<Activity>>? activities,
    int? numKids,
    List<int>? kidAges,
    String? location,
  }) =>
      ActivitiesState(
        activities: activities ?? this.activities,
        numKids: numKids ?? this.numKids,
        kidAges: kidAges ?? this.kidAges,
        location: location ?? this.location,
      );
}

class ActivitiesNotifier extends StateNotifier<ActivitiesState> {
  final ClaudeService _service;
  ActivitiesNotifier(this._service) : super(const ActivitiesState());

  void setNumKids(int n) {
    final ages = List<int>.generate(n, (i) {
      return i < state.kidAges.length ? state.kidAges[i] : 6;
    });
    state = state.copyWith(numKids: n, kidAges: ages);
  }

  void setKidAge(int index, int age) {
    final ages = [...state.kidAges];
    if (index < ages.length) ages[index] = age;
    state = state.copyWith(kidAges: ages);
  }

  Future<void> generate(String location) async {
    state = state.copyWith(
      location: location,
      activities: const AsyncValue.loading(),
    );
    try {
      final result = await _service.generateActivities(
        numKids: state.numKids,
        kidAges: state.kidAges,
        location: location,
      );
      state = state.copyWith(activities: AsyncValue.data(result));
    } catch (e, st) {
      state = state.copyWith(activities: AsyncValue.error(e, st));
    }
  }

  Future<void> regenerate() => generate(state.location);
}

final activitiesProvider =
    StateNotifierProvider<ActivitiesNotifier, ActivitiesState>(
  (ref) => ActivitiesNotifier(ref.read(claudeServiceProvider)),
);

// ── Heart to Heart ────────────────────────────────────────────────────────────

class HeartState {
  final AsyncValue<HeartCard?> card;
  final String groupType;
  final int cardNumber;
  final int totalAttempts;
  final bool showFollowUp;

  const HeartState({
    this.card = const AsyncValue.data(null),
    this.groupType = 'mixed',
    this.cardNumber = 0,
    this.totalAttempts = 0,
    this.showFollowUp = false,
  });

  HeartState copyWith({
    AsyncValue<HeartCard?>? card,
    String? groupType,
    int? cardNumber,
    int? totalAttempts,
    bool? showFollowUp,
  }) =>
      HeartState(
        card: card ?? this.card,
        groupType: groupType ?? this.groupType,
        cardNumber: cardNumber ?? this.cardNumber,
        totalAttempts: totalAttempts ?? this.totalAttempts,
        showFollowUp: showFollowUp ?? this.showFollowUp,
      );
}

class HeartNotifier extends StateNotifier<HeartState> {
  final ClaudeService _service;
  HeartNotifier(this._service) : super(const HeartState());

  void setGroupType(String groupType) =>
      state = state.copyWith(groupType: groupType, cardNumber: 0, totalAttempts: 0);

  Future<void> nextCard() async {
    state = state.copyWith(
      card: const AsyncValue.loading(),
      showFollowUp: false,
      cardNumber: state.cardNumber + 1,
      totalAttempts: state.totalAttempts + 1,
    );
    try {
      final card = await _service.generateHeartCard(
        groupType: state.groupType,
        cardNumber: state.cardNumber,
        action: 'new_card',
      );
      state = state.copyWith(card: AsyncValue.data(card));
    } catch (e, st) {
      state = state.copyWith(card: AsyncValue.error(e, st));
    }
  }

  Future<void> goDeeper() async {
    final current = state.card.valueOrNull;
    if (current == null) return;

    state = state.copyWith(
      totalAttempts: state.totalAttempts + 1,
      showFollowUp: false,
    );

    try {
      final updated = await _service.generateHeartCard(
        groupType: state.groupType,
        cardNumber: state.cardNumber,
        action: 'go_deeper',
        currentQuestion: current.question,
      );
      state = state.copyWith(
        card: AsyncValue.data(updated),
        showFollowUp: true,
      );
    } catch (e, st) {
      state = state.copyWith(card: AsyncValue.error(e, st));
    }
  }

  Future<void> skip() => nextCard();

  void reset() =>
      state = const HeartState();
}

final heartProvider =
    StateNotifierProvider<HeartNotifier, HeartState>(
  (ref) => HeartNotifier(ref.read(claudeServiceProvider)),
);
