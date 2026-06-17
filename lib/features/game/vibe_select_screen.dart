import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/game_mode.dart';
import '../../core/providers/dark_mode_provider.dart';
import '../../core/providers/game_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/services/questions_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class VibeSelectScreen extends ConsumerWidget {
  const VibeSelectScreen({super.key});

  static const _vibes = [
    _Vibe(
      emoji: '🧊',
      titleEn: 'Ice-Breaking',
      titleAr: 'كسر الجليد',
      subtitleEn: 'Light & fun to get started',
      subtitleAr: 'خفيف وممتع للبداية',
      depth: 1,
      gradient: [Color(0xFF38BDF8), Color(0xFF6366F1)],
    ),
    _Vibe(
      emoji: '💬',
      titleEn: 'Getting Real',
      titleAr: 'الحقيقة',
      subtitleEn: 'Honest & personal questions',
      subtitleAr: 'أسئلة صادقة وشخصية',
      depth: 2,
      gradient: [Color(0xFF34D399), Color(0xFF059669)],
    ),
    _Vibe(
      emoji: '🌹',
      titleEn: 'Romantic',
      titleAr: 'رومانسي',
      subtitleEn: 'Sweet & heartfelt moments',
      subtitleAr: 'لحظات رقيقة ومؤثرة',
      depth: 3,
      gradient: [Color(0xFFF87171), Color(0xFFE8537A)],
    ),
    _Vibe(
      emoji: '🔮',
      titleEn: 'Deep Talk',
      titleAr: 'أعمق',
      subtitleEn: 'Soul-level conversations',
      subtitleAr: 'محادثات من القلب',
      depth: 3,
      gradient: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(languageProvider);
    final isDark = ref.watch(darkModeProvider);
    final questionsAsync = ref.watch(questionsByModeProvider('date'));

    final bg = isDark ? const Color(0xFF0D0D1A) : AppColors.background;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary;

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

              // Header
              Text(
                '❤️',
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 12),
              Text(
                isArabic ? 'اختر المزاج' : 'Date Mode',
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isArabic ? 'اختر نوع الأسئلة للبدء.' : 'Pick a category to begin.',
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 15,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 28),

              // Category list
              Expanded(
                child: ListView.separated(
                  itemCount: _vibes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, i) {
                    final vibe = _vibes[i];
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
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: vibe.gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: vibe.gradient.first.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(vibe.emoji,
                                    style: const TextStyle(fontSize: 28)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isArabic ? vibe.titleAr : vibe.titleEn,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isArabic ? vibe.subtitleAr : vibe.subtitleEn,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                color: Colors.white54, size: 18),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Vibe {
  final String emoji;
  final String titleEn;
  final String titleAr;
  final String subtitleEn;
  final String subtitleAr;
  final int depth;
  final List<Color> gradient;

  const _Vibe({
    required this.emoji,
    required this.titleEn,
    required this.titleAr,
    required this.subtitleEn,
    required this.subtitleAr,
    required this.depth,
    required this.gradient,
  });
}