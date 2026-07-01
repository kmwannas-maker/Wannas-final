import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/activity.dart';
import '../../../core/providers/family_ai_providers.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/theme/app_theme.dart';

class FamilyActivitiesResultsScreen extends ConsumerWidget {
  const FamilyActivitiesResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(languageProvider);
    final state = ref.watch(activitiesProvider);
    final notifier = ref.read(activitiesProvider.notifier);

    final locationEmoji = {
      'Home': '🏠', 'Mall': '🛍️', 'Beach': '🏖️', 'Park': '🌳',
    }[state.location] ?? '📍';

    final locationLabel = {
      'Home':  isArabic ? 'البيت'    : 'Home',
      'Mall':  isArabic ? 'المول'    : 'Mall',
      'Beach': isArabic ? 'الشاطئ'   : 'Beach',
      'Park':  isArabic ? 'الحديقة'  : 'Park',
    }[state.location] ?? state.location;

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
          '$locationEmoji $locationLabel',
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
        child: state.activities.isEmpty
            ? Center(
                child: Text(
                  isArabic ? 'لا توجد أنشطة' : 'No activities found.',
                  style: appFont(
                    isArabic: isArabic,
                    fontSize: 16,
                    color: Colors.white54,
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      child: Text(
                        isArabic
                            ? '${state.numKids} طفل/أطفال — ٣ أنشطة مقترحة ✨'
                            : '${state.numKids} kid${state.numKids > 1 ? 's' : ''} — 3 suggestions ✨',
                        style: appFont(
                          isArabic: isArabic,
                          fontSize: 14,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                    ...state.activities.map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _ActivityCard(
                              activity: a, isArabic: isArabic),
                        )),
                    const SizedBox(height: 8),

                    // Try Different Activities
                    GestureDetector(
                      onTap: notifier.regenerate,
                      child: Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: const Color(0xFF4776E6)
                                .withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.refresh_rounded,
                                color: Color(0xFF4776E6), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              isArabic
                                  ? 'جرّب أنشطة مختلفة'
                                  : 'Try Different Activities',
                              style: appFont(
                                isArabic: isArabic,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF4776E6),
                              ),
                            ),
                          ],
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

class _ActivityCard extends StatelessWidget {
  final Activity activity;
  final bool isArabic;

  const _ActivityCard({required this.activity, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4776E6).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(activity.emoji,
                  style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activity.duration,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4ADE80),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            activity.description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}