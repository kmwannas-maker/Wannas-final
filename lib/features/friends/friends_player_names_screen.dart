import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/models/game_mode.dart';
import '../../core/providers/game_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/services/questions_repository.dart';
import 'friends_category_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/friends_providers.dart';

class FriendsPlayerNamesScreen extends ConsumerWidget {
  const FriendsPlayerNamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(languageProvider);
    final s = S(isArabic);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final names = ref.watch(playerNamesProvider);
    final category = ref.watch(selectedCategoryProvider);
    final categoryMode = category?.mode ?? 'sport';
    final questionsAsync = ref.watch(questionsByModeProvider(categoryMode));

    final bg = isDark ? const Color(0xFF0D0D1A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1A1A2E) : AppColors.surface;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary =
        isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.primary.withValues(alpha: 0.12);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_rounded, color: textPrimary, size: 20),
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
                s.whatsEveryonesNames,
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.tapNameToEdit,
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 14,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 28),

              // Player name tiles — scrollable so 8 players fit
              Expanded(
                child: ListView.builder(
                  itemCount: names.length,
                  itemBuilder: (context, i) {
                    final name = names[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => _editName(
                          context,
                          ref,
                          i,
                          name,
                          isArabic,
                          cardBg,
                          textPrimary,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person_rounded,
                                    color: AppColors.primary, size: 18),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  name,
                                  style: appFont(
                                    isArabic: isArabic,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                              Icon(Icons.edit_rounded,
                                  color: textSecondary, size: 16),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Start Game →
              GestureDetector(
                onTap: () {
                  questionsAsync.whenData((questions) {
                    if (questions.isEmpty) return;
                    ref.read(gameStateProvider.notifier).startGame(
                          GameMode.sportMode,
                          questions,
                          maxCards: 7,
                        );
                    context.push('/friends/game');
                  });
                },
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
                    s.startGame,
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

  void _editName(
    BuildContext context,
    WidgetRef ref,
    int index,
    String currentName,
    bool isArabic,
    Color dialogBg,
    Color textColor,
  ) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogBg,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isArabic ? 'اسم اللاعب' : 'Player Name',
          style: appFont(
            isArabic: isArabic,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: appFont(isArabic: isArabic, fontSize: 16, color: textColor),
          decoration: InputDecoration(
            hintText: isArabic ? 'أدخل الاسم' : 'Enter name',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onSubmitted: (v) {
            _saveName(ref, index, v.trim(), currentName);
            Navigator.of(ctx).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              isArabic ? 'إلغاء' : 'Cancel',
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              _saveName(ref, index, controller.text.trim(), currentName);
              Navigator.of(ctx).pop();
            },
            child: Text(
              isArabic ? 'حفظ' : 'Save',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _saveName(
      WidgetRef ref, int index, String newName, String fallback) {
    if (newName.isEmpty) return;
    final names = List<String>.from(ref.read(playerNamesProvider));
    names[index] = newName;
    ref.read(playerNamesProvider.notifier).state = names;
  }
}
