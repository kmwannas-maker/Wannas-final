import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/dark_mode_provider.dart';
import '../../../core/providers/family_ai_providers.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class FamilyActivitiesScreen extends ConsumerWidget {
  const FamilyActivitiesScreen({super.key});

  static const _locations = [
    (emoji: '🏠', label: 'Home',  labelAr: 'البيت'),
    (emoji: '🛍️', label: 'Mall',  labelAr: 'المول'),
    (emoji: '🏖️', label: 'Beach', labelAr: 'الشاطئ'),
    (emoji: '🌳', label: 'Park',  labelAr: 'الحديقة'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(languageProvider);
    final state = ref.watch(activitiesProvider);
    final notifier = ref.read(activitiesProvider.notifier);
    final isDark = ref.watch(darkModeProvider);

    final bg = isDark ? const Color(0xFF0D0D1A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1A1A2E) : AppColors.surface;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? Colors.white60 : AppColors.textSecondary;

    void selectLocation(String location) {
      notifier.generate(location);
      context.push('/family/activities/results');
    }

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
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 20),

              // Kids counter
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CounterButton(
                      icon: Icons.remove,
                      onTap: state.numKids > 1
                          ? () => notifier.setNumKids(state.numKids - 1)
                          : null,
                    ),
                    Column(
                      children: [
                        Text(
                          '${state.numKids}',
                          style: appFont(
                            isArabic: false,
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF4776E6),
                          ),
                        ),
                        Text(
                          isArabic ? 'طفل/أطفال' : 'kid(s)',
                          style: appFont(
                            isArabic: isArabic,
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                    _CounterButton(
                      icon: Icons.add,
                      onTap: state.numKids < 6
                          ? () => notifier.setNumKids(state.numKids + 1)
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Ages
              Text(
                isArabic ? 'أعمارهم' : 'Their ages',
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              ...List.generate(state.numKids, (i) {
                final age = i < state.kidAges.length
                    ? state.kidAges[i]
                    : 6;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text(
                          isArabic ? 'الطفل ${i + 1}' : 'Kid ${i + 1}',
                          style: appFont(
                            isArabic: isArabic,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        const Spacer(),
                        _CounterButton(
                          icon: Icons.remove,
                          size: 32,
                          onTap: age > 1
                              ? () => notifier.setKidAge(i, age - 1)
                              : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '$age',
                            style: appFont(
                              isArabic: false,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        _CounterButton(
                          icon: Icons.add,
                          size: 32,
                          onTap: age < 17
                              ? () => notifier.setKidAge(i, age + 1)
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 28),

              Text(
                isArabic ? 'أين أنتم الآن؟' : 'Where are you?',
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isArabic
                    ? 'اختر الموقع للحصول على أفكار فوراً'
                    : 'Tap your location to get ideas instantly',
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 14,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Location grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: _locations
                    .map((loc) => _LocationCard(
                          emoji: loc.emoji,
                          label: isArabic ? loc.labelAr : loc.label,
                          onTap: () => selectLocation(loc.label),
                        ))
                    .toList(),
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

  const _CounterButton({
    required this.icon,
    required this.onTap,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFF4776E6).withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Icon(
          icon,
          size: size * 0.5,
          color: enabled ? const Color(0xFF4776E6) : Colors.white24,
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _LocationCard({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF4776E6).withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}