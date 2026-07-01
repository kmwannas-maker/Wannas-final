import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/models/game_mode.dart';
import '../../core/models/question.dart';
import '../../core/providers/game_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/services/questions_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class LevelSelectScreen extends ConsumerWidget {
  final GameMode mode;
  const LevelSelectScreen({super.key, required this.mode});

  String get _modeKey {
    switch (mode) {
      case GameMode.dateMode:
        return 'date';
      case GameMode.spiceItUp:
        return 'spice';
      case GameMode.familyTime:
        return 'family';
      case GameMode.sportMode:
        return 'sport';
    }
  }

  /// Fallback route if there's nothing to pop back to.
  /// This screen is reached directly from Home for every mode
  /// (Home -> /vibe -> /game for Dating is the only exception,
  /// where Dating goes through VibeSelectScreen first). For all
  /// modes that land here, the correct fallback is Home, not a
  /// hardcoded route belonging to a different mode.
  String get _fallbackRoute {
    switch (mode) {
      case GameMode.dateMode:
        return '/vibe';
      case GameMode.spiceItUp:
      case GameMode.familyTime:
      case GameMode.sportMode:
        return '/';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(languageProvider);
    final s = S(isArabic);

    // Premium is open for all users for now
    const isPremium = true;

    final questionsAsync = ref.watch(questionsByModeProvider(_modeKey));
    final Color accentColor = _accentFor(mode);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(_fallbackRoute),
        ),
        title: Text(
          _modeTitle(mode, s),
          style: appFont(
            isArabic: isArabic,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: questionsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
          error: (_, __) => _buildLevelList(
            context, ref, [], isPremium, s, isArabic, accentColor,
          ),
          data: (questions) => _buildLevelList(
            context, ref, questions, isPremium, s, isArabic, accentColor,
          ),
        ),
      ),
    );
  }

  String _sectionLabel(S s) {
    switch (mode) {
      case GameMode.familyTime:
        return s.selectAgeGroup;
      case GameMode.sportMode:
        return s.selectLeague;
      default:
        return s.selectLevel;
    }
  }

  Widget _buildLevelList(
    BuildContext context,
    WidgetRef ref,
    List<Question> questions,
    bool isPremium,
    S s,
    bool isArabic,
    Color accent,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _sectionLabel(s),
            style: appFont(
              isArabic: isArabic,
              fontSize: 15,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: mode == GameMode.sportMode
                ? _buildSportOptions(
                    context, ref, questions, s, isArabic, accent)
                : Column(
                    children: _buildOptions(
                        context, ref, questions, isPremium, s, isArabic, accent),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSportOptions(
    BuildContext context,
    WidgetRef ref,
    List<Question> questions,
    S s,
    bool isArabic,
    Color accent,
  ) {
    List<Question> byDepth(int depth) =>
        questions.where((q) => q.depth == depth).toList();

    final leagues = [
      (emoji: '🇪🇬', title: s.egyptianLeague, desc: s.egyptianLeagueDesc, depth: 1),
      (emoji: '🏴󠁧󠁢󠁥󠁮󠁧󠁿', title: s.premierLeague, desc: s.premierLeagueDesc, depth: 2),
      (emoji: '⭐', title: s.uclLeague, desc: s.uclLeagueDesc, depth: 3),
      (emoji: '🏆', title: s.worldCup, desc: s.worldCupDesc, depth: 4),
    ];

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: leagues.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final l = leagues[i];
        return _LevelTile(
          emoji: l.emoji,
          title: l.title,
          desc: l.desc,
          badge: s.free,
          badgeColor: Colors.green,
          locked: false,
          accent: accent,
          isArabic: isArabic,
          onTap: () => _startGame(context, ref, mode, byDepth(l.depth)),
        );
      },
    );
  }

  List<Widget> _buildOptions(
    BuildContext context,
    WidgetRef ref,
    List<Question> questions,
    bool isPremium,
    S s,
    bool isArabic,
    Color accent,
  ) {
    List<Question> byDepth(int depth) =>
        questions.where((q) => q.depth == depth).toList();

    switch (mode) {
      case GameMode.dateMode:
        return [
          _LevelTile(
            emoji: '☀️',
            title: s.light,
            desc: s.lightDesc,
            badge: s.free,
            badgeColor: Colors.green,
            locked: false,
            accent: accent,
            isArabic: isArabic,
            onTap: () => _startGame(context, ref, mode, byDepth(1)),
          ),
          const SizedBox(height: 12),
          _LevelTile(
            emoji: '🌙',
            title: s.medium,
            desc: s.mediumDesc,
            badge: s.free,
            badgeColor: Colors.green,
            locked: false,
            accent: accent,
            isArabic: isArabic,
            onTap: () => _startGame(context, ref, mode, byDepth(2)),
          ),
          const SizedBox(height: 12),
          _LevelTile(
            emoji: '🌌',
            title: s.deep,
            desc: s.deepDesc,
            badge: s.free,
            badgeColor: Colors.green,
            locked: false,
            accent: accent,
            isArabic: isArabic,
            onTap: () => _startGame(context, ref, mode, byDepth(3)),
          ),
        ];

      case GameMode.spiceItUp:
        return [
          _LevelTile(
            emoji: '🌡️',
            title: s.warm,
            desc: s.warmDesc,
            badge: s.free,
            badgeColor: Colors.green,
            locked: false,
            accent: accent,
            isArabic: isArabic,
            onTap: () => _startGame(context, ref, mode, byDepth(1)),
          ),
          const SizedBox(height: 12),
          _LevelTile(
            emoji: '🌶️',
            title: s.hot,
            desc: s.hotDesc,
            badge: s.free,
            badgeColor: Colors.green,
            locked: false,
            accent: accent,
            isArabic: isArabic,
            onTap: () => _startGame(context, ref, mode, byDepth(2)),
          ),
          const SizedBox(height: 12),
          _LevelTile(
            emoji: '🔥',
            title: s.onFire,
            desc: s.onFireDesc,
            badge: s.free,
            badgeColor: Colors.green,
            locked: false,
            accent: accent,
            isArabic: isArabic,
            onTap: () => _startGame(context, ref, mode, byDepth(3)),
          ),
        ];

      case GameMode.familyTime:
        return [
          _LevelTile(
            emoji: '🧸',
            title: s.littleOnes,
            desc: s.littleOnesDesc,
            badge: s.free,
            badgeColor: Colors.green,
            locked: false,
            accent: accent,
            isArabic: isArabic,
            onTap: () => _startGame(context, ref, mode, byDepth(1)),
          ),
          const SizedBox(height: 12),
          _LevelTile(
            emoji: '🎮',
            title: s.tweens,
            desc: s.tweensDesc,
            badge: s.free,
            badgeColor: Colors.green,
            locked: false,
            accent: accent,
            isArabic: isArabic,
            onTap: () => _startGame(context, ref, mode, byDepth(2)),
          ),
          const SizedBox(height: 12),
          _LevelTile(
            emoji: '🎧',
            title: s.teens,
            desc: s.teensDesc,
            badge: s.free,
            badgeColor: Colors.green,
            locked: false,
            accent: accent,
            isArabic: isArabic,
            onTap: () => _startGame(context, ref, mode, byDepth(3)),
          ),
        ];

      default:
        return [];
    }
  }

  void _startGame(BuildContext context, WidgetRef ref, GameMode mode,
      List<Question> questions) {
    if (questions.isEmpty) return;
    ref.read(gameStateProvider.notifier).startGame(mode, questions);
    context.push('/game');
  }

  String _modeTitle(GameMode mode, S s) {
    switch (mode) {
      case GameMode.dateMode:
        return s.dateMode;
      case GameMode.spiceItUp:
        return s.spiceMode;
      case GameMode.familyTime:
        return s.familyMode;
      case GameMode.sportMode:
        return s.sportMode;
    }
  }

  Color _accentFor(GameMode mode) {
    switch (mode) {
      case GameMode.dateMode:
        return AppColors.dateGradientStart;
      case GameMode.spiceItUp:
        return AppColors.spiceGradientStart;
      case GameMode.familyTime:
        return AppColors.familyGradientStart;
      case GameMode.sportMode:
        return AppColors.sportGradientEnd;
    }
  }
}

class _LevelTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;
  final String badge;
  final Color badgeColor;
  final bool locked;
  final Color accent;
  final bool isArabic;
  final VoidCallback onTap;

  const _LevelTile({
    required this.emoji,
    required this.title,
    required this.desc,
    required this.badge,
    required this.badgeColor,
    required this.locked,
    required this.accent,
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: locked
                ? AppColors.textMuted.withValues(alpha: 0.2)
                : accent.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: isArabic
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: appFont(
                          isArabic: isArabic,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: locked
                              ? AppColors.textMuted
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badge,
                          style: appFont(
                            isArabic: isArabic,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    desc,
                    style: appFont(
                      isArabic: isArabic,
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (locked)
              const Icon(Icons.lock_rounded, color: AppColors.gold, size: 20)
            else
              Icon(Icons.arrow_forward_ios_rounded, color: accent, size: 18),
          ],
        ),
      ),
    );
  }
}