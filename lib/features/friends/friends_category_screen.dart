import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/providers/language_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

// Stores the selected category for the player count screen
final selectedCategoryProvider = StateProvider<_Category?>((ref) => null);

class FriendsCategoryScreen extends ConsumerWidget {
  const FriendsCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(languageProvider);
    final s = S(isArabic);
    final isDark = ref.watch(darkModeProvider);

    final bg = isDark ? const Color(0xFF0D0D1A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1A1A2E) : AppColors.surface;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary;

    final categories = [
      _Category(emoji: '⚽', title: s.catFootball, available: true,  mode: 'sport'),
      _Category(emoji: '📺', title: s.catTV,       available: true,  mode: 'tv'),
      _Category(emoji: '💄', title: s.catBeauty,   available: true,  mode: 'beauty'),
      _Category(emoji: '🎵', title: s.catMusic,    available: true,  mode: 'music'),
      _Category(emoji: '🎮', title: s.catGaming,   available: true,  mode: 'gaming'),
      _Category(emoji: '🧠', title: s.catWYR,      available: true,  mode: 'wyr'),
      _Category(emoji: '✈️', title: s.catTravel,   available: true,  mode: 'travel'),
      _Category(emoji: '🍕', title: s.catFood,     available: true,  mode: 'food'),
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
        title: Text(
          s.friendsModeHeader,
          style: appFont(
            isArabic: isArabic,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            height: 1,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Text(
                s.pickCategoryTitle,
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.pickCategorySub,
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 14,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Category grid
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (_, i) {
                    final cat = categories[i];
                    return GestureDetector(
                      onTap: () {
                        if (cat.available) {
                          ref.read(selectedCategoryProvider.notifier).state = cat;
                          context.push('/friends/players');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(s.comingSoon),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: cat.available
                                ? AppColors.primary.withValues(alpha: 0.3)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.black.withValues(alpha: 0.06)),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: cat.available
                                          ? AppColors.primary
                                              .withValues(alpha: 0.12)
                                          : (isDark
                                              ? Colors.white
                                                  .withValues(alpha: 0.06)
                                              : Colors.black
                                                  .withValues(alpha: 0.05)),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: Text(cat.emoji,
                                          style:
                                              const TextStyle(fontSize: 26)),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    cat.title,
                                    textAlign: TextAlign.center,
                                    style: appFont(
                                      isArabic: isArabic,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: cat.available
                                          ? textPrimary
                                          : textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // "Soon" badge for unavailable
                            if (!cat.available)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Soon',
                                    style: appFont(
                                      isArabic: false,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Switch mode
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: GestureDetector(
                  onTap: () => context.go('/'),
                  child: Text(
                    isArabic ? 'تغيير الوضع' : 'Switch mode',
                    style: appFont(
                      isArabic: isArabic,
                      fontSize: 14,
                      color: textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Category {
  final String emoji;
  final String title;
  final bool available;
  final String mode;
  const _Category({
    required this.emoji,
    required this.title,
    required this.available,
    required this.mode,
  });
}
