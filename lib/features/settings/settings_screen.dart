import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/l10n/strings.dart';
import '../../core/providers/card_timer_provider.dart';
import '../../core/providers/dark_mode_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/purchase_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _version = 'v${info.version}');
    } catch (_) {
      if (mounted) setState(() => _version = 'v1.0.0');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(languageProvider);
    final isDark = ref.watch(darkModeProvider);
    final timerOn = ref.watch(cardTimerProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final s = S(isArabic);

    final bg = isDark ? const Color(0xFF1A1A2E) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF252540) : AppColors.surface;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary;
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.06);
    final iconBg = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.primary.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: textColor, size: 20),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text(
          s.settings,
          style: appFont(
            isArabic: isArabic,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── PREMIUM STATUS ─────────────────────────────────────────────────
            _SectionLabel(
              label: isArabic ? 'الاشتراك' : 'SUBSCRIPTION',
              isArabic: isArabic,
            ),
            GestureDetector(
              onTap: isPremium ? null : () => context.push('/paywall'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: isPremium
                      ? AppColors.gold.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isPremium
                        ? AppColors.gold.withValues(alpha: 0.4)
                        : AppColors.primary.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isPremium
                            ? AppColors.gold.withValues(alpha: 0.15)
                            : AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          isPremium ? '⭐' : '🔒',
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPremium
                                ? (isArabic ? 'مشترك مميز' : 'Premium Active')
                                : (isArabic
                                    ? 'ترقية إلى المميز'
                                    : 'Upgrade to Premium'),
                            style: appFont(
                              isArabic: isArabic,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isPremium ? AppColors.gold : textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isPremium
                                ? (isArabic
                                    ? 'جميع المحتويات متاحة لك'
                                    : 'All content unlocked')
                                : (isArabic
                                    ? 'افتح جميع الأوضاع والأسئلة'
                                    : 'Unlock all modes & questions'),
                            style: appFont(
                              isArabic: isArabic,
                              fontSize: 12,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isPremium)
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: AppColors.primary),
                    if (isPremium)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.familyGradientStart, size: 22),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── GAMEPLAY ───────────────────────────────────────────────────────
            _SectionLabel(label: s.gameplay, isArabic: isArabic),
            _SettingsCard(
              bg: cardBg,
              children: [
                _SettingsTile(
                  icon: Icons.timer_outlined,
                  iconBg: iconBg,
                  iconColor: AppColors.primary,
                  title: s.cardTimer,
                  trailing: Switch.adaptive(
                    value: timerOn,
                    onChanged: (_) =>
                        ref.read(cardTimerProvider.notifier).toggle(),
                    activeColor: AppColors.primary,
                  ),
                  textColor: textColor,
                  isArabic: isArabic,
                ),
                Divider(height: 1, color: dividerColor),
                _SettingsTile(
                  icon: Icons.favorite_border_rounded,
                  iconBg: iconBg,
                  iconColor: Colors.pinkAccent,
                  title: s.savedCards,
                  trailing: Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: subtitleColor),
                  textColor: textColor,
                  isArabic: isArabic,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isArabic
                            ? 'قريباً...'
                            : 'Coming soon!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── PREFERENCES ────────────────────────────────────────────────────
            _SectionLabel(label: s.preferences, isArabic: isArabic),
            _SettingsCard(
              bg: cardBg,
              children: [
                _SettingsTile(
                  icon: isDark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  iconBg: iconBg,
                  iconColor: isDark ? AppColors.gold : AppColors.primary,
                  title: isDark ? s.switchToLight : s.switchToDark,
                  trailing: Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: subtitleColor),
                  textColor: textColor,
                  isArabic: isArabic,
                  onTap: () =>
                      ref.read(darkModeProvider.notifier).toggle(),
                ),
                Divider(height: 1, color: dividerColor),
                _SettingsTile(
                  icon: Icons.shield_outlined,
                  iconBg: iconBg,
                  iconColor: Colors.blueAccent,
                  title: s.privacyPolicy,
                  trailing: Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: subtitleColor),
                  textColor: textColor,
                  isArabic: isArabic,
                  onTap: () => _showInfoDialog(
                    context,
                    title: s.privacyPolicy,
                    body: isArabic
                        ? 'لا نجمع أي بيانات شخصية. التطبيق يعمل بدون إنترنت بعد التحميل.'
                        : 'We do not collect any personal data. The app works offline after download.',
                    isDark: isDark,
                    textColor: textColor,
                    cardBg: cardBg,
                  ),
                ),
                Divider(height: 1, color: dividerColor),
                _SettingsTile(
                  icon: Icons.description_outlined,
                  iconBg: iconBg,
                  iconColor: Colors.orange,
                  title: s.termsOfService,
                  trailing: Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: subtitleColor),
                  textColor: textColor,
                  isArabic: isArabic,
                  onTap: () => _showInfoDialog(
                    context,
                    title: s.termsOfService,
                    body: isArabic
                        ? 'باستخدام وناسة، توافق على استخدام التطبيق للأغراض الترفيهية فقط.'
                        : 'By using Wannas, you agree to use the app for entertainment purposes only.',
                    isDark: isDark,
                    textColor: textColor,
                    cardBg: cardBg,
                  ),
                ),
                Divider(height: 1, color: dividerColor),
                _SettingsTile(
                  icon: Icons.refresh_rounded,
                  iconBg: iconBg,
                  iconColor: Colors.green,
                  title: s.restorePurchases,
                  trailing: Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: subtitleColor),
                  textColor: textColor,
                  isArabic: isArabic,
                  onTap: () async {
                    await ref.read(isPremiumProvider.notifier).restore();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isArabic
                              ? 'تم استعادة المشتريات'
                              : 'Purchases restored'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                ),
                Divider(height: 1, color: dividerColor),
                _SettingsTile(
                  icon: Icons.star_border_rounded,
                  iconBg: iconBg,
                  iconColor: AppColors.gold,
                  title: s.rateTheApp,
                  trailing: Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: subtitleColor),
                  textColor: textColor,
                  isArabic: isArabic,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isArabic
                            ? 'شكراً لدعمك! 🙏'
                            : 'Thank you for your support! 🙏'),
                        backgroundColor: AppColors.gold,
                      ),
                    );
                  },
                ),
              ],
            ),

            // ── Version ────────────────────────────────────────────────────────
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Wannas · $_version',
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 13,
                  color: subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(
    BuildContext context, {
    required String title,
    required String body,
    required bool isDark,
    required Color textColor,
    required Color cardBg,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardBg,
        title: Text(title,
            style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w800,
                fontSize: 18)),
        content: Text(body,
            style: TextStyle(color: textColor.withValues(alpha: 0.7))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK',
                style: TextStyle(color: AppColors.primary,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isArabic;
  const _SectionLabel({required this.label, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        label.toUpperCase(),
        style: appFont(
          isArabic: isArabic,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          height: 1,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Color bg;
  final List<Widget> children;
  const _SettingsCard({required this.bg, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final Widget trailing;
  final Color textColor;
  final bool isArabic;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.trailing,
    required this.textColor,
    required this.isArabic,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
