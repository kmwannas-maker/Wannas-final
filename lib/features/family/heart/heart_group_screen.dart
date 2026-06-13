import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/family_ai_providers.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/theme/app_theme.dart';

class HeartGroupScreen extends ConsumerWidget {
  const HeartGroupScreen({super.key});

  static const _groups = [
    (
      value: 'young_kids',
      emoji: '👦',
      label: 'Young Kids',
      labelAr: 'الأطفال الصغار',
      sub: 'Ages 3–7',
      subAr: 'عمر 3–7',
    ),
    (
      value: 'older_kids',
      emoji: '🧒',
      label: 'Older Kids',
      labelAr: 'الأطفال الكبار',
      sub: 'Ages 8–12',
      subAr: 'عمر 8–12',
    ),
    (
      value: 'teens',
      emoji: '👫',
      label: 'Teens',
      labelAr: 'المراهقون',
      sub: 'Ages 13–17',
      subAr: 'عمر 13–17',
    ),
    (
      value: 'mixed',
      emoji: '❤️',
      label: 'Mixed Ages',
      labelAr: 'أعمار مختلطة',
      sub: 'All ages together',
      subAr: 'كل الأعمار معاً',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white70, size: 20),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/family'),
        ),
        title: Text(
          isArabic ? '💜 من القلب للقلب' : '💜 Heart to Heart',
          style: appFont(
            isArabic: isArabic,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFE8537A),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                isArabic ? 'من بينكم الليلة؟' : 'Who\'s joining tonight?',
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isArabic
                    ? 'نختار الأسئلة المناسبة لفئة عمرهم.'
                    : 'We\'ll pick questions suited to their age group.',
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 14,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 32),
              ...List.generate(_groups.length, (i) {
                final g = _groups[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _GroupCard(
                    emoji: g.emoji,
                    label: isArabic ? g.labelAr : g.label,
                    sub: isArabic ? g.subAr : g.sub,
                    onTap: () {
                      ref
                          .read(heartProvider.notifier)
                          .setGroupType(g.value);
                      ref.read(heartProvider.notifier).nextCard();
                      context.push('/family/heart/play');
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String sub;
  final VoidCallback onTap;

  const _GroupCard({
    required this.emoji,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE8537A).withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Color(0xFFE8537A), size: 16),
          ],
        ),
      ),
    );
  }
}
