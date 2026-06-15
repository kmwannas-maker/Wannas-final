import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/activity.dart';
import '../../../core/providers/family_ai_providers.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

const _activityBank = [
  Activity(emoji: '🎨', title: 'Drawing Challenge', duration: '20–30 min',
      description: 'Everyone draws the same object — compare and vote for the funniest!'),
  Activity(emoji: '🧩', title: 'Puzzle Race', duration: '30–45 min',
      description: 'Split into teams and race to finish a puzzle. Fastest team wins!'),
  Activity(emoji: '📖', title: 'Story Round', duration: '15–20 min',
      description: 'Each person adds one sentence to build a silly story together.'),
  Activity(emoji: '🎭', title: 'Charades', duration: '20–30 min',
      description: 'Act out movies, animals, or household objects. No talking allowed!'),
  Activity(emoji: '🏆', title: 'Trivia Battle', duration: '20–30 min',
      description: 'Take turns asking each other fun trivia questions from different topics.'),
  Activity(emoji: '🎵', title: 'Humming Game', duration: '15–20 min',
      description: 'Hum a song and let the family guess what it is. Most correct guesses wins!'),
  Activity(emoji: '🌟', title: 'Talent Show', duration: '30–45 min',
      description: 'Everyone performs their best talent. Cheer for each other!'),
  Activity(emoji: '🍪', title: 'Baking Together', duration: '45–60 min',
      description: 'Pick a simple recipe and bake something delicious as a team.'),
  Activity(emoji: '🎲', title: 'Board Game Night', duration: '45–90 min',
      description: 'Pick a family board game and play a full tournament with scorekeeping.'),
  Activity(emoji: '📸', title: 'Photo Challenge', duration: '20–30 min',
      description: 'Each person takes 3 creative photos around the house. Vote for the best!'),
  Activity(emoji: '🏃', title: 'Indoor Olympics', duration: '30–45 min',
      description: 'Create fun mini-challenges like balloon keep-up, paper toss, and more.'),
  Activity(emoji: '🎤', title: 'Karaoke Time', duration: '30–45 min',
      description: 'Sing your favourite songs out loud. Extra points for costumes!'),
  Activity(emoji: '🌈', title: 'Art Gallery', duration: '30–40 min',
      description: 'Everyone creates an artwork and hangs it up. Tour the gallery together.'),
  Activity(emoji: '🧠', title: 'Memory Game', duration: '15–20 min',
      description: 'Place 10 objects on a tray, memorise them, then guess what was removed.'),
  Activity(emoji: '🤸', title: 'Yoga Flow', duration: '20–30 min',
      description: 'Do a fun family yoga session together. Try to hold the poses!'),
  Activity(emoji: '🎯', title: 'Target Toss', duration: '15–20 min',
      description: 'Set up targets around the room and toss paper balls. Keep score!'),
  Activity(emoji: '🌙', title: 'Storytime', duration: '20–30 min',
      description: 'One person reads a book aloud while everyone listens and relaxes.'),
  Activity(emoji: '🏗️', title: 'Building Challenge', duration: '25–35 min',
      description: 'Use blocks, LEGO, or household items to build the tallest tower possible.'),
  Activity(emoji: '🎪', title: 'Magic Show', duration: '20–30 min',
      description: 'Take turns performing simple magic tricks. Fool the family!'),
  Activity(emoji: '🌍', title: 'World Tour', duration: '20–30 min',
      description: 'Pick a country on the map and learn 3 fun facts about it together.'),
];

List<Activity> _pickActivities(List<int> kidAges) {
  final rng = Random();
  final shuffled = List<Activity>.from(_activityBank)..shuffle(rng);
  return shuffled.take(4).toList();
}

class FamilyActivitiesScreen extends ConsumerWidget {
  const FamilyActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(languageProvider);
    final state = ref.watch(activitiesProvider);
    final notifier = ref.read(activitiesProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF0D0D1A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1A1A2E) : AppColors.surface;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? Colors.white60 : AppColors.textSecondary;

    void generateActivities() {
      final picked = _pickActivities(state.kidAges);
      notifier.setLocalActivities(picked);
      context.push('/family/activities/results');
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: textPrimary, size: 20),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text(
          isArabic ? '🎮 الأنشطة' : '🎮 Activities',
          style: appFont(
            isArabic: isArabic,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF4776E6),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                isArabic ? 'كم طفلاً سيلعبون؟' : 'How many kids?',
                style: appFont(isArabic: isArabic, fontSize: 22,
                    fontWeight: FontWeight.w800, color: textPrimary),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CounterButton(icon: Icons.remove,
                        onTap: state.numKids > 1 ? () => notifier.setNumKids(state.numKids - 1) : null),
                    Column(children: [
                      Text('${state.numKids}', style: appFont(isArabic: false, fontSize: 44,
                          fontWeight: FontWeight.w800, color: const Color(0xFF4776E6))),
                      Text(isArabic ? 'طفل/أطفال' : 'kid(s)',
                          style: appFont(isArabic: isArabic, fontSize: 13, color: textSecondary)),
                    ]),
                    _CounterButton(icon: Icons.add,
                        onTap: state.numKids < 6 ? () => notifier.setNumKids(state.numKids + 1) : null),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(isArabic ? 'أعمارهم' : 'Their ages',
                  style: appFont(isArabic: isArabic, fontSize: 16,
                      fontWeight: FontWeight.w700, color: textSecondary)),
              const SizedBox(height: 12),
              ...List.generate(state.numKids, (i) {
                final age = i < state.kidAges.length ? state.kidAges[i] : 6;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                    child: Row(children: [
                      Text(isArabic ? 'الطفل ${i + 1}' : 'Kid ${i + 1}',
                          style: appFont(isArabic: isArabic, fontSize: 15,
                              fontWeight: FontWeight.w600, color: textPrimary)),
                      const Spacer(),
                      _CounterButton(icon: Icons.remove, size: 32,
                          onTap: age > 1 ? () => notifier.setKidAge(i, age - 1) : null),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('$age', style: appFont(isArabic: false, fontSize: 22,
                              fontWeight: FontWeight.w800, color: textPrimary))),
                      _CounterButton(icon: Icons.add, size: 32,
                          onTap: age < 17 ? () => notifier.setKidAge(i, age + 1) : null),
                    ]),
                  ),
                );
              }),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: generateActivities,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [BoxShadow(color: const Color(0xFF4776E6).withValues(alpha: 0.4),
                        blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Text(isArabic ? '🎮 اقترح أنشطة' : '🎮 Generate Activities',
                      textAlign: TextAlign.center,
                      style: appFont(isArabic: isArabic, fontSize: 17,
                          fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  const _CounterButton({required this.icon, required this.onTap, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF4776E6).withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Icon(icon, size: size * 0.5,
            color: enabled ? const Color(0xFF4776E6) : Colors.white24),
      ),
    );
  }
}