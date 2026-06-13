import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/models/game_mode.dart';
import '../../core/providers/game_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/services/questions_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class VibeSelectScreen extends ConsumerWidget {
  const VibeSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(languageProvider);
    final s = S(isArabic);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF0D0D1A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1A1A2E) : AppColors.surface;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary;
    final questionsAsync = ref.watch(questionsByModeProvider('date'));

    final vibes = [
      _Vibe(emoji: '🎯', title: s.vibeCurious,  depth: 1),
      _Vibe(emoji: '😄', title: s.vibePlayful,  depth: 2),
      _Vibe(emoji: '🥂', title: s.vibeRomantic, depth: 3),
      _Vibe(emoji: '🗝️', title: s.vibeDeep,     depth: 3),
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: textPrimary, size: 20),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Mode icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.dateGradientStart,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text('💑', style: TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                s.whatsTheVibe,
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.tapOneToCont,
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 15,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // 2×2 vibe grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  physics: const NeverScrollableScrollPhysics(),
                  children: vibes.map((vibe) {
                    return GestureDetector(
                      onTap: () {
                        questionsAsync.whenData((allQuestions) {
                          final filtered = allQuestions
                              .where((q) => q.depth == vibe.depth)
                              .toList();
                          if (filtered.isEmpty) return;
                          ref
                              .read(gameStateProvider.notifier)
                              .startGame(GameMode.dateMode, filtered);
                          context.push('/game');
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.dateGradientStart
                                .withValues(alpha: 0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(vibe.emoji,
                                style: const TextStyle(fontSize: 36)),
                            const SizedBox(height: 10),
                            Text(
                              vibe.title,
                              textAlign: TextAlign.center,
                              style: appFont(
                                isArabic: isArabic,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Vibe {
  final String emoji;
  final String title;
  final int depth;
  const _Vibe({required this.emoji, required this.title, required this.depth});
}
