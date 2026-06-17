import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/providers/language_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class FamilyHubScreen extends ConsumerWidget {
  const FamilyHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(languageProvider);
    final isDark = ref.watch(darkModeProvider);
    final s = S(isArabic);

    final bg = isDark ? const Color(0xFF0D0D1A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1A1A2E) : AppColors.surface;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary =
        isDark ? Colors.white60 : AppColors.textSecondary;

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
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined,
                color: textPrimary, size: 22),
            onPressed: () => context.push('/settings'),
          ),
        ],
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
                '👨‍👩‍👧',
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 12),
              Text(
                s.familyMode,
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isArabic
                    ? 'لحظات حقيقية مع من تحب.'
                    : 'Real moments with those you love.',
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 15,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 40),

              // Activities card
              _ModeCard(
                emoji: '🎮',
                title: isArabic ? 'الأنشطة' : 'Activities',
                subtitle: isArabic
                    ? 'أفكار ممتعة لأعمار أطفالكم ومكانكم الآن'
                    : 'AI-picked activities for your kids\' ages & location',
                gradient: const LinearGradient(
                  colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => context.push('/family/activities'),
              ),
              const SizedBox(height: 16),

              // Heart to Heart card
              _ModeCard(
                emoji: '💜',
                title: isArabic ? 'من القلب للقلب' : 'Heart to Heart',
                subtitle: isArabic
                    ? 'أسئلة تفتح قلوب الجميع على بعضهم'
                    : 'Conversation starters that bring everyone closer',
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8537A), Color(0xFFE35D5B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => context.push('/family/heart'),
              ),
              const Spacer(),

              // Bottom hint
              Center(
                child: Text(
                  isArabic
                      ? 'اختر ما يناسبكم الليلة ✨'
                      : 'Pick what feels right tonight ✨',
                  style: appFont(
                    isArabic: isArabic,
                    fontSize: 13,
                    color: textSecondary,
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

class _ModeCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ModeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      height: 1.4,
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
  }
}
