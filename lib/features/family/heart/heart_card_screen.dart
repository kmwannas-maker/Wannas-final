import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/family_ai_providers.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/theme/app_theme.dart';

const _kFreeCards = 7;
const _accent = Color(0xFFE8537A);

class HeartCardScreen extends ConsumerWidget {
  const HeartCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(languageProvider);
    final state = ref.watch(heartProvider);
    final notifier = ref.read(heartProvider.notifier);

    final groupLabel = {
      'young_kids': isArabic ? '👦 الأطفال الصغار' : '👦 Young Kids',
      'older_kids': isArabic ? '🧒 الأطفال الكبار' : '🧒 Older Kids',
      'teens': isArabic ? '👫 المراهقون' : '👫 Teens',
    }[state.groupType] ?? '';

    // Paywall check
    void attemptNext(Future<void> Function() action) {
      if (state.totalAttempts >= _kFreeCards) {
        context.push('/paywall');
        return;
      }
      action();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          notifier.reset();
          context.go('/family');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D1A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white70, size: 20),
            onPressed: () {
              notifier.reset();
              context.go('/family');
            },
          ),
          title: Text(
            groupLabel,
            style: appFont(
              isArabic: isArabic,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _accent,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  '${state.cardNumber} / 100',
                  style: appFont(
                    isArabic: false,
                    fontSize: 12,
                    color: Colors.white38,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: state.card.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: _accent),
            ),
            error: (e, _) => _ErrorView(
              isArabic: isArabic,
              onRetry: notifier.nextCard,
            ),
            data: (card) {
              if (card == null) {
                return const Center(
                    child: CircularProgressIndicator(color: _accent));
              }
              return _CardBody(
                question: card.question,
                followUp: state.showFollowUp ? card.followUp : null,
                isArabic: isArabic,
                cardNumber: state.cardNumber,
                totalAttempts: state.totalAttempts,
                onGoDeeper: card.followUp == null || state.showFollowUp
                    ? null
                    : () => attemptNext(notifier.goDeeper),
                onNext: () => attemptNext(notifier.nextCard),
                onSkip: () => attemptNext(notifier.skip),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  final String question;
  final String? followUp;
  final bool isArabic;
  final int cardNumber;
  final int totalAttempts;
  final VoidCallback? onGoDeeper;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _CardBody({
    required this.question,
    required this.followUp,
    required this.isArabic,
    required this.cardNumber,
    required this.totalAttempts,
    required this.onGoDeeper,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = _kFreeCards - totalAttempts;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          _ProgressDots(cardNumber: cardNumber),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: _accent.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_rounded,
                        color: _accent, size: 24),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    question,
                    textAlign: TextAlign.center,
                    style: appFont(
                      isArabic: isArabic,
                      fontSize: isArabic ? 22 : 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.55,
                    ),
                  ),
                  if (followUp != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _accent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            isArabic ? '🔍 أعمق...' : '🔍 Go Deeper...',
                            style: appFont(
                              isArabic: isArabic,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _accent,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            followUp!,
                            textAlign: TextAlign.center,
                            style: appFont(
                              isArabic: isArabic,
                              fontSize: isArabic ? 17 : 15,
                              color: Colors.white.withValues(alpha: 0.8),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _ReactionRow(),
          const SizedBox(height: 20),
          if (onGoDeeper != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: onGoDeeper,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: _accent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    isArabic ? 'أعمق 🔍' : 'Go Deeper 🔍',
                    textAlign: TextAlign.center,
                    style: appFont(
                      isArabic: isArabic,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                    ),
                  ),
                ),
              ),
            ),
          GestureDetector(
            onTap: onNext,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                isArabic ? 'السؤال التالي ←' : 'Next Card ←',
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
          const SizedBox(height: 12),
          if (remaining > 0 && remaining <= 3)
            Text(
              isArabic
                  ? '$remaining بطاقات مجانية متبقية'
                  : '$remaining free card${remaining == 1 ? '' : 's'} left',
              style: appFont(
                isArabic: isArabic,
                fontSize: 12,
                color: Colors.orange.shade300,
              ),
            )
          else
            GestureDetector(
              onTap: onSkip,
              child: Text(
                isArabic ? 'تخطَّ هذا السؤال' : 'Skip this question',
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 13,
                  color: Colors.white38,
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  final int cardNumber;
  const _ProgressDots({required this.cardNumber});

  @override
  Widget build(BuildContext context) {
    const visible = 7;
    final filled = cardNumber.clamp(0, visible);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(visible, (i) {
        final active = i < filled;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active
                ? _accent
                : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _ReactionRow extends StatefulWidget {
  @override
  State<_ReactionRow> createState() => _ReactionRowState();
}

class _ReactionRowState extends State<_ReactionRow> {
  int? _selected;

  static const _reactions = ['🔥', '😂', '💡', '😮'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_reactions.length, (i) {
        final selected = _selected == i;
        return GestureDetector(
          onTap: () => setState(() => _selected = selected ? null : i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? _accent.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? _accent : Colors.transparent,
              ),
            ),
            child: Text(
              _reactions[i],
              style: TextStyle(fontSize: selected ? 22 : 20),
            ),
          ),
        );
      }),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final bool isArabic;
  final Future<void> Function() onRetry;

  const _ErrorView({required this.isArabic, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😅', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            isArabic
                ? 'حدث خطأ، حاول مجدداً'
                : 'Something went wrong. Try again?',
            style: appFont(
              isArabic: isArabic,
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                isArabic ? 'حاول مجدداً' : 'Try Again',
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}