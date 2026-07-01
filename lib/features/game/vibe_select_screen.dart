import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/models/game_mode.dart';
import '../../core/providers/dark_mode_provider.dart';
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
    final isDark = ref.watch(darkModeProvider);

    final bg = isDark ? const Color(0xFF0D0D1A) : AppColors.background;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary =
        isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary;
    final questionsAsync = ref.watch(questionsByModeProvider('date'));

    // 4 sub-categories with gradients
    final vibes = [
      _Vibe(
        emoji: '🧊',
        title: isArabic ? 'كسر الجليد' : 'Ice-Breaking',
        titleSub: isArabic ? 'ابدأ المحادثة' : 'Start the conversation',
        depth: 1,
        gradientColors: const [Color(0xFF4776E6), Color(0xFF8E54E9)],
      ),
      _Vibe(
        emoji: '💬',
        title: isArabic ? 'الحقيقة' : 'Getting Real',
        titleSub: isArabic ? 'أسئلة شخصية' : 'Personal questions',
        depth: 2,
        gradientColors: const [Color(0xFFE84393), Color(0xFFFF6B6B)],
      ),
      _Vibe(
        emoji: '🌹',
        title: isArabic ? 'رومانسي' : 'Romantic',
        titleSub: isArabic ? 'لحظات دافئة' : 'Warm moments',
        depth: 3,
        gradientColors: const [Color(0xFFFF416C), Color(0xFFFF4B2B)],
      ),
      _Vibe(
        emoji: '🔮',
        title: isArabic ? 'عميق' : 'Deep Talk',
        titleSub: isArabic ? 'محادثات حقيقية' : 'Soul-level conversations',
        depth: 3,
        gradientColors: const [Color(0xFF1A1A2E), Color(0xFF16213E)],
        borderColor: const Color(0xFF4776E6),
      ),
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: textPrimary, size: 20),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/'),
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

              // 2×2 gradient card grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
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
                          gradient: LinearGradient(
                            colors: vibe.gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: vibe.borderColor != null
                              ? Border.all(
                                  color: vibe.borderColor!
                                      .withValues(alpha: 0.6),
                                  width: 1.5)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: vibe.gradientColors.first
                                  .withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(vibe.emoji,
                                  style: const TextStyle(fontSize: 32)),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vibe.title,
                                    style: appFont(
                                      isArabic: isArabic,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    vibe.titleSub,
                                    style: appFont(
                                      isArabic: isArabic,
                                      fontSize: 11,
                                      color: Colors.white
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),
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
  final String titleSub;
  final int depth;
  final List<Color> gradientColors;
  final Color? borderColor;

  const _Vibe({
    required this.emoji,
    required this.title,
    required this.titleSub,
    required this.depth,
    required this.gradientColors,
    this.borderColor,
  });
}