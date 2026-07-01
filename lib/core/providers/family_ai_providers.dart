import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/activity.dart';
import '../models/heart_card.dart';
import '../services/claude_service.dart';

// ── Shared service ────────────────────────────────────────────────────────────

final claudeServiceProvider = Provider<ClaudeService>((_) => ClaudeService());

// ── Built-in activity bank (20 activities, 5 per location) ───────────────────

const _activitiesBank = {
  'Home': [
    Activity(
      emoji: '🎨',
      title: 'Family Art Battle',
      duration: '30 min',
      description: 'Everyone draws the same subject — a pet, a superhero, or your house. Vote for the funniest, most creative, and most realistic!',
    ),
    Activity(
      emoji: '🍕',
      title: 'Build-Your-Own Pizza Night',
      duration: '45 min',
      description: 'Set out toppings and let everyone create their own mini pizza. Rate each other\'s creations before eating them.',
    ),
    Activity(
      emoji: '🎭',
      title: 'Charades Marathon',
      duration: '25 min',
      description: 'Act out movies, animals, and everyday objects. Kids vs parents — who can guess the most?',
    ),
    Activity(
      emoji: '🏰',
      title: 'Epic Blanket Fort',
      duration: '40 min',
      description: 'Use cushions, blankets, and chairs to build the biggest fort you can. Then have a movie or snack inside it together.',
    ),
    Activity(
      emoji: '📸',
      title: 'Family Photo Challenge',
      duration: '20 min',
      description: 'Each person picks 3 objects to photograph creatively. Share them on the TV and vote for the most artistic shot.',
    ),
  ],
  'Mall': [
    Activity(
      emoji: '🛍️',
      title: 'Budget Treasure Hunt',
      duration: '30 min',
      description: 'Give each kid a small budget and challenge them to find the most interesting item they can buy. Share and explain your choices!',
    ),
    Activity(
      emoji: '🍦',
      title: 'Mystery Ice Cream Order',
      duration: '20 min',
      description: 'Order a flavour you\'ve never tried before. Everyone rates it 1–10 and shares their honest reaction.',
    ),
    Activity(
      emoji: '👗',
      title: 'Silly Outfit Contest',
      duration: '25 min',
      description: 'Find the funniest outfit combination in one store. Try it on (or just hold it up) and take photos for the family album.',
    ),
    Activity(
      emoji: '🎯',
      title: 'Wish List Window Tour',
      duration: '20 min',
      description: 'Walk past 5 shops and each person picks their dream item from the window. Share why — no buying required!',
    ),
    Activity(
      emoji: '🎮',
      title: 'Arcade Team Challenge',
      duration: '35 min',
      description: 'Pool your tokens and take turns on different games. Work together to win as many tickets as possible and redeem them together.',
    ),
  ],
  'Beach': [
    Activity(
      emoji: '🏖️',
      title: 'Sandcastle Competition',
      duration: '40 min',
      description: 'Split into teams and build the most impressive sandcastle you can. Judge on size, detail, and creativity. Winning team picks the next activity!',
    ),
    Activity(
      emoji: '🦀',
      title: 'Nature Scavenger Hunt',
      duration: '25 min',
      description: 'Find a shell, a smooth stone, something round, something colourful, and a feather. First to collect all five wins!',
    ),
    Activity(
      emoji: '🌊',
      title: 'Wave Jump Championship',
      duration: '20 min',
      description: 'Take turns jumping waves and rating each other\'s style out of 10. Bonus points for creative mid-air poses!',
    ),
    Activity(
      emoji: '🎨',
      title: 'Sand Drawing Gallery',
      duration: '20 min',
      description: 'Each person draws something in the sand — an animal, a portrait, or a scene. Take photos before the tide washes them away.',
    ),
    Activity(
      emoji: '🏃',
      title: 'Beach Olympics',
      duration: '35 min',
      description: 'Run relay races, do long jumps in the sand, and have a skipping stone contest. Keep score and crown the Beach Champion!',
    ),
  ],
  'Park': [
    Activity(
      emoji: '🌿',
      title: 'Leaf & Nature Art',
      duration: '25 min',
      description: 'Collect leaves, sticks, and petals to arrange into a picture on the ground. Take a photo of your nature masterpiece!',
    ),
    Activity(
      emoji: '🏃',
      title: 'Park Obstacle Course',
      duration: '30 min',
      description: 'Use benches, trees, and paths to design a course. Time everyone running it — then redesign to make it trickier!',
    ),
    Activity(
      emoji: '🔭',
      title: 'Cloud Story Time',
      duration: '15 min',
      description: 'Lie on the grass and find shapes in the clouds. Each person picks a cloud and tells a 1-minute story about what they see.',
    ),
    Activity(
      emoji: '🥏',
      title: 'Frisbee Trick Shot Contest',
      duration: '20 min',
      description: 'Take turns attempting trick throws — around a tree, between two people, behind the back. Rate each throw and crown the champion!',
    ),
    Activity(
      emoji: '🧺',
      title: 'Picnic Quiz',
      duration: '20 min',
      description: 'Sit down with snacks and take turns asking each other questions — trivia, favourites, and "would you rather" rounds.',
    ),
  ],
};

List<Activity> _pickActivities(String location, {int count = 3}) {
  final pool = _activitiesBank[location] ?? _activitiesBank['Home']!;
  final shuffled = [...pool]..shuffle(Random());
  return shuffled.take(count).toList();
}

// ── Activities ────────────────────────────────────────────────────────────────

class ActivitiesState {
  final List<Activity> activities;
  final int numKids;
  final List<int> kidAges;
  final String location;

  const ActivitiesState({
    this.activities = const [],
    this.numKids = 1,
    this.kidAges = const [6],
    this.location = 'Home',
  });

  ActivitiesState copyWith({
    List<Activity>? activities,
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
  ActivitiesNotifier() : super(const ActivitiesState());

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

  void generate(String location) {
    final activities = _pickActivities(location);
    state = state.copyWith(location: location, activities: activities);
  }

  void regenerate() => generate(state.location);
}

final activitiesProvider =
    StateNotifierProvider<ActivitiesNotifier, ActivitiesState>(
  (ref) => ActivitiesNotifier(),
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

  void reset() => state = const HeartState();
}

final heartProvider =
    StateNotifierProvider<HeartNotifier, HeartState>(
  (ref) => HeartNotifier(ref.read(claudeServiceProvider)),
);