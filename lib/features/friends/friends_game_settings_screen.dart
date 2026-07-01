import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/providers/dark_mode_provider.dart';
import '../../core/providers/friends_providers.dart';
import '../../core/providers/language_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class FriendsGameSettingsScreen extends ConsumerWidget {
  const FriendsGameSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(languageProvider);
    final s = S(isArabic);
    final isDark = ref.watch(darkModeProvider);
    final difficulty = ref.watch(friendsDifficultyProvider);
    final timerSecs = ref.watch(friendsTimerSecondsProvider);

    final bg = isDark ? const Color(0xFF0D0D1A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1A1A2E) : AppColors.surface;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary =
        isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary;
    final borderIdle = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.primary.withValues(alpha: 0.12);

    final difficulties = [
      {'key': 'easy',   'title': s.easyDiff,   'desc': s.easyDiffDesc},
      {'key': 'medium', 'title': s.mediumDiff,  'desc': s.mediumDiffDesc},
      {'key': 'hard',   'title': s.hardDiff,    'desc': s.hardDiffDesc},
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
              Text(
                s.gameSettings,
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.chooseDiffAndTimer,
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 14,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // ── DIFFICULTY ────────────────────────────────────────────────
              Text(
                s.difficultyLabel,
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textSecondary,
                  height: 1,
                ),
              ),
              const SizedBox(height: 12),

              ...difficulties.map((d) {
                final isSelected = difficulty == d['key'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => ref
                        .read(friendsDifficultyProvider.notifier)
                        .state = d['key']!,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : borderIdle,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            d['title']!,
                            style: appFont(
                              isArabic: isArabic,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? AppColors.primary
                                  : textPrimary,
                            ),
                          ),
                          Text(
                            d['desc']!,
                            style: appFont(
                              isArabic: isArabic,
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // ── TIMER — only shown for medium difficulty ───────────────────
              if (difficulty == 'medium') ...[
                const SizedBox(height: 20),
                Text(
                  s.timerPerQuestion,
                  style: appFont(
                    isArabic: isArabic,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textSecondary,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [10, 20, 30].map((secs) {
                    final isSelected = timerSecs == secs;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => ref
                              .read(friendsTimerSecondsProvider.notifier)
                              .state = secs,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : borderIdle,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              '${secs}s',
                              textAlign: TextAlign.center,
                              style: appFont(
                                isArabic: false,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppColors.primary
                                    : textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              const Spacer(),

              // Next →
              GestureDetector(
                onTap: () => context.push('/friends/names'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    isArabic ? 'التالي →' : 'Next →',
                    textAlign: TextAlign.center,
                    style: appFont(
                      isArabic: isArabic,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
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