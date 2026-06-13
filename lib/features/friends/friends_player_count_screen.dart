import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/providers/language_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'friends_category_screen.dart';
import '../../core/providers/friends_providers.dart';

class FriendsPlayerCountScreen extends ConsumerStatefulWidget {
  const FriendsPlayerCountScreen({super.key});

  @override
  ConsumerState<FriendsPlayerCountScreen> createState() =>
      _FriendsPlayerCountScreenState();
}

class _FriendsPlayerCountScreenState
    extends ConsumerState<FriendsPlayerCountScreen> {
  int _playerCount = 3;

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(languageProvider);
    final s = S(isArabic);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = ref.watch(selectedCategoryProvider);

    final bg = isDark ? const Color(0xFF0D0D1A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1A1A2E) : AppColors.surface;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary =
        isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary;

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
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category icon
              if (category != null)
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(category.emoji,
                        style: const TextStyle(fontSize: 38)),
                  ),
                ),
              const SizedBox(height: 28),

              // Title
              Text(
                s.howManyPlaying,
                textAlign: TextAlign.center,
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.trackScoreSub,
                textAlign: TextAlign.center,
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 15,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 48),

              // Counter
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CounterBtn(
                    icon: Icons.remove_rounded,
                    enabled: _playerCount > 2,
                    cardBg: cardBg,
                    onTap: () {
                      if (_playerCount > 2) {
                        setState(() => _playerCount--);
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      '$_playerCount',
                      style: appFont(
                        isArabic: false,
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  _CounterBtn(
                    icon: Icons.add_rounded,
                    enabled: _playerCount < 8,
                    cardBg: cardBg,
                    onTap: () {
                      if (_playerCount < 8) {
                        setState(() => _playerCount++);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                s.minMaxPlayers,
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 13,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 56),

              // Next button → initialise names/scores then go to settings
              GestureDetector(
                onTap: () {
                  final names = List.generate(
                      _playerCount, (i) => 'Player ${i + 1}');
                  ref.read(playerNamesProvider.notifier).state = names;
                  ref.read(playerScoresProvider.notifier).state =
                      List.filled(_playerCount, 0);
                  context.push('/friends/settings');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.dateGradientEnd,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color:
                            AppColors.dateGradientEnd.withValues(alpha: 0.4),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final Color cardBg;
  final VoidCallback onTap;

  const _CounterBtn({
    required this.icon,
    required this.enabled,
    required this.cardBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.primary : AppColors.textMuted,
          size: 24,
        ),
      ),
    );
  }
}
