import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/language_provider.dart';
import '../../core/providers/purchase_provider.dart';
import '../../core/theme/app_theme.dart';

enum _Plan { monthly, lifetime }

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  _Plan _selected = _Plan.lifetime;

  static const _bg     = Color(0xFF0D0B26);
  static const _cardBg = Color(0xFF1A1740);
  static const _accent = Color(0xFF6366F1);

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(languageProvider);

    final features = isArabic
        ? [
            '100+ سؤال لكل وضع',
            'جميع فئات Friends Mode مفتوحة',
            'أسئلة Go Deeper لمحادثات حقيقية',
            'أسئلة جديدة كل شهر',
          ]
        : [
            '100+ questions per mode',
            'All 8 Friends categories unlocked',
            'Go Deeper prompts for real conversations',
            'New questions added every month',
          ];

    final ctaLabel = _selected == _Plan.monthly
        ? (isArabic ? 'افتح كل شيء — \$1.99/شهر' : 'Unlock Everything — \$1.99/mo')
        : (isArabic ? 'افتح كل شيء — \$4.99' : 'Unlock Everything — \$4.99');

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // Lock icon
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_open_rounded,
                        color: _accent,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Headline
                    Text(
                      isArabic
                          ? 'لقد استخدمت بطاقاتك السبع المجانية'
                          : "You've used your 7 free cards",
                      textAlign: TextAlign.center,
                      style: appFont(
                        isArabic: isArabic,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isArabic
                          ? 'افتح 100+ بطاقة وجميع الأوضاع'
                          : 'Unlock 100+ cards and all modes',
                      textAlign: TextAlign.center,
                      style: appFont(
                        isArabic: isArabic,
                        fontSize: 15,
                        color: Colors.white54,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Plan selector ─────────────────────────────────────
                    Row(
                      children: [
                        // Monthly plan
                        Expanded(
                          child: _PlanCard(
                            isArabic: isArabic,
                            title: isArabic ? 'شهري' : 'Monthly',
                            price: r'$1.99',
                            sub: isArabic ? 'في الشهر' : 'per month',
                            badge: null,
                            isSelected: _selected == _Plan.monthly,
                            onTap: () => setState(() => _selected = _Plan.monthly),
                            accent: _accent,
                            cardBg: _cardBg,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Lifetime plan
                        Expanded(
                          child: _PlanCard(
                            isArabic: isArabic,
                            title: isArabic ? 'مدى الحياة' : 'Lifetime',
                            price: r'$4.99',
                            sub: isArabic ? 'مرة واحدة فقط' : 'one-time only',
                            badge: isArabic ? 'الأفضل' : 'Best Value',
                            isSelected: _selected == _Plan.lifetime,
                            onTap: () => setState(() => _selected = _Plan.lifetime),
                            accent: _accent,
                            cardBg: _cardBg,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Feature list ──────────────────────────────────────
                    ...features.map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            textDirection: isArabic
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: _accent.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_rounded,
                                    color: _accent, size: 15),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  f,
                                  style: appFont(
                                    isArabic: isArabic,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Bottom CTA ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
              child: Column(
                children: [
                  // Unlock button
                  GestureDetector(
                    onTap: () async {
                      // TODO: trigger real purchase flow for _selected plan
                      await ref.read(isPremiumProvider.notifier).unlock();
                      if (context.mounted) context.go('/');
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          Color(0xFF6366F1),
                          Color(0xFF8B5CF6),
                        ]),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: _accent.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Text(
                        ctaLabel,
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
                  const SizedBox(height: 14),

                  // Restore purchase
                  GestureDetector(
                    onTap: () async {
                      // TODO: wire up RevenueCat restore
                    },
                    child: Text(
                      isArabic ? 'استعادة المشتريات' : 'Restore Purchase',
                      style: appFont(
                        isArabic: isArabic,
                        fontSize: 13,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Maybe later
                  GestureDetector(
                    onTap: () =>
                        context.canPop() ? context.pop() : context.go('/'),
                    child: Text(
                      isArabic ? 'ربما لاحقاً' : 'Maybe later',
                      style: appFont(
                        isArabic: isArabic,
                        fontSize: 14,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Plan card widget ──────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final bool isArabic;
  final String title;
  final String price;
  final String sub;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accent;
  final Color cardBg;

  const _PlanCard({
    required this.isArabic,
    required this.title,
    required this.price,
    required this.sub,
    required this.badge,
    required this.isSelected,
    required this.onTap,
    required this.accent,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? accent.withValues(alpha: 0.15) : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accent : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge!,
                  style: appFont(
                    isArabic: isArabic,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            Text(
              title,
              style: appFont(
                isArabic: isArabic,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : Colors.white60,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: appFont(
                isArabic: false,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: appFont(
                isArabic: isArabic,
                fontSize: 11,
                color: isSelected ? Colors.white54 : Colors.white30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
