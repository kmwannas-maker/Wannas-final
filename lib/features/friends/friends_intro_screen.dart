import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/providers/dark_mode_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class FriendsIntroScreen extends ConsumerWidget {
  const FriendsIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(languageProvider);
    final s = S(isArabic);
    final isDark = ref.watch(darkModeProvider);

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
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Text('👫', style: TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                s.friendsIntroTitle,
                textAlign: TextAlign.center,
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                s.friendsIntroSub,
                textAlign: TextAlign.center,
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 15,
                  color: textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: () => context.push('/friends/categories'),
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
                    s.pickACategory,
                    textAlign: TextAlign.center,
                    style: appFont(
                      isArabic: isArabic,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
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