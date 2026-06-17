import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/providers/dark_mode_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/purchase_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(languageProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final isDark = ref.watch(darkModeProvider);
    final s = S(isArabic);

    final bg = isDark ? const Color(0xFF1A1A2E) : AppColors.background;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary;
    final cardSurface = isDark ? const Color(0xFF252540) : AppColors.surface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.primary.withValues(alpha: 0.15);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                ignoring: _step == 0,
                child: AnimatedOpacity(
                  opacity: _step == 1 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 350),
                  child: _ModeGridContent(
                    isArabic: isArabic,
                    isPremium: isPremium,
                    isDark: isDark,
                    s: s,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    cardSurface: cardSurface,
                    borderColor: borderColor,
                    onLanguageToggle: () =>
                        ref.read(languageProvider.notifier).toggle(),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: _step == 1,
                child: AnimatedOpacity(
                  opacity: _step == 0 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 350),
                  child: _SplashContent(
                    isArabic: isArabic,
                    s: s,
                    onStart: () => setState(() => _step = 1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  final bool isArabic;
  final S s;
  final VoidCallback onStart;

  const _SplashContent({
    required this.isArabic,
    required this.s,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _WannasLogo(size: 100),
              const SizedBox(height: 28),
              Text(
                s.appName,
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 46,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.primary],
                ).createShader(bounds),
                child: Text(
                  s.appTagline,
                  textAlign: TextAlign.center,
                  style: appFont(
                    isArabic: isArabic,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  isArabic ? '4 أوضاع · أكثر من 400 سؤال' : '4 modes · 400+ questions',
                  style: appFont(
                    isArabic: isArabic,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 52),
              GestureDetector(
                onTap: onStart,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Text(
                    isArabic ? '← ابدأ الآن' : 'Get Started →',
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
            ],
          ),
        ),
      ),
    );
  }
}

class _WannasLogo extends StatelessWidget {
  final double size;
  const _WannasLogo({this.size = 100});

  @override
  Widget build(BuildContext context) {
    final cardW = size * 0.70;
    final cardH = size * 0.88;
    final radius = size * 0.16;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: size * 0.20,
            child: Container(
              width: cardW,
              height: cardH,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          ),
          Positioned(
            top: size * 0.12,
            left: 0,
            child: Container(
              width: cardW,
              height: cardH,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(radius),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    blurRadius: size * 0.28,
                    offset: Offset(0, size * 0.10),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.44,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WannasLogoSmall extends StatelessWidget {
  const _WannasLogoSmall();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 10,
            child: Container(
              width: 24,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          Positioned(
            top: 6,
            left: 0,
            child: Container(
              width: 24,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeGridContent extends StatelessWidget {
  final bool isArabic;
  final bool isPremium;
  final bool isDark;
  final S s;
  final Color textPrimary;
  final Color textSecondary;
  final Color cardSurface;
  final Color borderColor;
  final VoidCallback onLanguageToggle;

  const _ModeGridContent({
    required this.isArabic,
    required this.isPremium,
    required this.isDark,
    required this.s,
    required this.textPrimary,
    required this.textSecondary,
    required this.cardSurface,
    required this.borderColor,
    required this.onLanguageToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const _WannasLogoSmall(),
                  const SizedBox(width: 8),
                  Text(
                    s.appName,
                    style: appFont(
                      isArabic: isArabic,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.push('/settings'),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: cardSurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor),
                      ),
                      child: Icon(
                        Icons.settings_rounded,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onLanguageToggle,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: cardSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                      ),
                      child: Text(
                        s.languageToggle,
                        style: appFont(
                          isArabic: isArabic,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
          child: Text(
            s.whoIsPlaying,
            style: appFont(
              isArabic: isArabic,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: textPrimary,
              height: 1.2,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Text(
            s.personaliseExp,
            style: appFont(
              isArabic: isArabic,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.88,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _ModeCard(
                  emoji: '💑',
                  title: s.dateMode,
                  tagline: s.dateModeTagline,
                  cardBg: isDark ? const Color(0xFF2A1A2E) : AppColors.dateBg,
                  iconBg: AppColors.dateGradientStart,
                  isLocked: false,
                  isDark: isDark,
                  isArabic: isArabic,
                  onTap: () => context.push('/vibe'),
                ),
                _ModeCard(
                  emoji: '🔥',
                  title: s.spiceMode,
                  tagline: s.spiceModeTagline,
                  cardBg: isDark ? const Color(0xFF2A1E14) : AppColors.couplesBg,
                  iconBg: AppColors.spiceGradientStart,
                  isLocked: !isPremium,
                  isPremiumBadge: true,
                  isDark: isDark,
                  isArabic: isArabic,
                  onTap: () => context.push('/mode/spiceItUp'),
                ),
                _ModeCard(
                  emoji: '👫',
                  title: s.sportMode,
                  tagline: s.sportModeTagline,
                  cardBg: isDark ? const Color(0xFF1A1A2E) : AppColors.friendsBg,
                  iconBg: AppColors.sportGradientStart,
                  isLocked: false,
                  isDark: isDark,
                  isArabic: isArabic,
                  onTap: () => context.push('/friends'),
                ),
                _ModeCard(
                  emoji: '👨‍👩‍👧',
                  title: s.familyMode,
                  tagline: s.familyModeTagline,
                  cardBg: isDark ? const Color(0xFF0F2A1A) : AppColors.familyBg,
                  iconBg: AppColors.familyGradientStart,
                  isLocked: false,
                  isDark: isDark,
                  isArabic: isArabic,
                  onTap: () => context.push('/family'),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
          child: Center(
            child: Text(
              s.appTagline,
              style: appFont(
                isArabic: isArabic,
                fontSize: 13,
                color: textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String tagline;
  final Color cardBg;
  final Color iconBg;
  final bool isLocked;
  final bool isPremiumBadge;
  final bool isDark;
  final bool isArabic;
  final VoidCallback onTap;

  const _ModeCard({
    required this.emoji,
    required this.title,
    required this.tagline,
    required this.cardBg,
    required this.iconBg,
    required this.isLocked,
    required this.isDark,
    required this.isArabic,
    required this.onTap,
    this.isPremiumBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: iconBg.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: iconBg.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 30)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: appFont(
                      isArabic: isArabic,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tagline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: appFont(
                      isArabic: isArabic,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isPremiumBadge)
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'PREMIUM',
                    style: appFont(
                      isArabic: isArabic,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            if (isLocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Icon(Icons.lock_rounded, color: Colors.white, size: 28),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}