import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/game_mode.dart';
import '../../core/providers/dark_mode_provider.dart';
import '../../core/providers/game_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

// ── Static particle dots ──────────────────────────────────────────────────────

class _Dot {
  final double x, y, size;
  final Color color;
  const _Dot(this.x, this.y, this.size, this.color);
}

const _dots = [
  _Dot(0.07, 0.10, 10, Color(0xFFFF6B35)),
  _Dot(0.88, 0.07, 8,  Color(0xFF4ADE80)),
  _Dot(0.93, 0.22, 6,  Color(0xFFFFD700)),
  _Dot(0.04, 0.32, 7,  Color(0xFFE879F9)),
  _Dot(0.80, 0.40, 9,  Color(0xFF60A5FA)),
  _Dot(0.12, 0.58, 6,  Color(0xFF34D399)),
  _Dot(0.89, 0.58, 8,  Color(0xFFF87171)),
  _Dot(0.52, 0.08, 5,  Color(0xFFA78BFA)),
  _Dot(0.22, 0.13, 7,  Color(0xFF38BDF8)),
  _Dot(0.68, 0.76, 6,  Color(0xFFFF6B35)),
  _Dot(0.40, 0.85, 8,  Color(0xFF4ADE80)),
  _Dot(0.96, 0.75, 5,  Color(0xFFFFD700)),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  int _flameCount = 0;
  int? _selectedReaction;
  bool _showAnswer = false;
  int _lastCardIndex = -1;
  bool _isFav = false;
  double _swipeOffset = 0;
  bool _goingDeeper = false;
  bool _midReached = false;

  late final ConfettiController _confettiCtrl;
  late final AnimationController _flipCtrl;

  // Reaction emojis for "How did that land?"
  static const _reactionEmojis = ['🔥', '😂', '💡', '🥺'];

  // Brand dark background
  static const _bg     = Color(0xFF1A1A2E);
  static const _cardBg = Color(0xFF252540);
  static const _accent = AppColors.primary; // #6C5CE7

  static const _deeperEn = [
    'Now share why you feel that way...',
    'Would your answer have been different 5 years ago?',
    'Ask the person next to you the same question.',
    'Tell the group the story behind your answer.',
    'What would your closest friend say about this?',
    'Is there something more you want to add?',
  ];
  static const _deeperAr = [
    'شاركنا لماذا تشعر بذلك...',
    'هل كانت إجابتك مختلفة قبل 5 سنوات؟',
    'اسأل الشخص بجانبك نفس السؤال.',
    'احكِ للمجموعة القصة وراء إجابتك.',
    'ما الذي يقوله أقرب أصدقائك عن هذا؟',
    'هل هناك شيء آخر تريد إضافته؟',
  ];

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(
        duration: const Duration(milliseconds: 2500));
    _confettiCtrl.play();
    _flipCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _flipCtrl.addListener(_onFlipTick);
    _flipCtrl.addStatusListener(_onFlipStatus);
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _flipCtrl.removeListener(_onFlipTick);
    _flipCtrl.removeStatusListener(_onFlipStatus);
    _flipCtrl.dispose();
    super.dispose();
  }

  void _onFlipTick() {
    if (_flipCtrl.value >= 0.5 && !_midReached) {
      _midReached = true;
      ref.read(gameStateProvider.notifier).next();
    }
  }

  void _onFlipStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _flipCtrl.reset();
      if (mounted) setState(() => _midReached = false);
    }
  }

  // Slide to next card. countFlame=false for skip.
  void _flipToNext({bool countFlame = true}) {
    if (_flipCtrl.isAnimating) return;
    _midReached = false;
    setState(() {
      if (countFlame) _flameCount++;
      _selectedReaction = null;
      _showAnswer = false;
      _isFav = false;
      _goingDeeper = false;
      _swipeOffset = 0;
    });
    _flipCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic  = ref.watch(languageProvider);
    final isDark    = ref.watch(darkModeProvider);
    final gameState = ref.watch(gameStateProvider);

    if (gameState == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/vibe'));
      return const Scaffold(backgroundColor: _bg);
    }

    if (gameState.currentIndex != _lastCardIndex) {
      _lastCardIndex    = gameState.currentIndex;
      _selectedReaction = null;
      _showAnswer       = false;
      _isFav            = false;
      _goingDeeper      = false;
    }

    final question     = gameState.currentQuestion;
    final questionText = isArabic ? (question?.ar ?? '') : (question?.en ?? '');
    final answerText   = isArabic ? (question?.answerAr ?? '') : (question?.answerEn ?? '');
    final isTrivia     = question?.hasAnswer ?? false;
    final modeLabel    = _modeLabel(gameState.mode);
    final modeEmoji    = _modeEmoji(gameState.mode);
    final deeperText   = isArabic
        ? _deeperAr[gameState.currentIndex % _deeperAr.length]
        : _deeperEn[gameState.currentIndex % _deeperEn.length];

    // Card theme-aware colors
    final cardBg       = isDark ? _cardBg : Colors.white;
    final cardText     = isDark ? Colors.white : AppColors.textPrimary;
    final cardModeIcon = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : AppColors.primaryLight.withValues(alpha: 0.3);
    final cardDash     = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.grey.withValues(alpha: 0.25);
    final cardShadow   = isDark
        ? _accent.withValues(alpha: 0.25)
        : Colors.black.withValues(alpha: 0.08);
    final heartColor   = _isFav
        ? const Color(0xFFF87171)
        : (isDark
            ? Colors.white.withValues(alpha: 0.45)
            : AppColors.textSecondary);

    final swipeHint = _swipeOffset > 40 ? 'fav' : _swipeOffset < -40 ? 'next' : null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) { ref.read(gameStateProvider.notifier).reset(); context.go('/vibe'); }
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            return Stack(children: [
              // ── Particle dots ─────────────────────────────────────────────
              ..._dots.map((d) => Positioned(
                left: d.x * constraints.maxWidth,
                top:  d.y * constraints.maxHeight,
                child: Container(
                  width: d.size, height: d.size,
                  decoration: BoxDecoration(
                    color: d.color.withValues(alpha: 0.65),
                    shape: BoxShape.circle,
                  ),
                ),
              )),

              // ── Main layout ───────────────────────────────────────────────
              Column(children: [
                // AppBar row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(children: [
                    GestureDetector(
                      onTap: () {
                        ref.read(gameStateProvider.notifier).reset();
                        context.go('/vibe');
                      },
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    Expanded(
                      child: Column(children: [
                        Text(
                          '$modeEmoji  ${modeLabel.toUpperCase()}',
                          style: appFont(isArabic: isArabic, fontSize: 13,
                              fontWeight: FontWeight.w700, color: _accent),
                        ),
                      ]),
                    ),
                    // Flame streak — only shown when ≥ 3
                    SizedBox(
                      width: 60,
                      child: _flameCount >= 3
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '🔥 $_flameCount',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ]),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Column(children: [
                      // ── Swipe hint labels ───────────────────────────────
                      SizedBox(
                        height: 18,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AnimatedOpacity(
                              opacity: swipeHint == 'fav' ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 120),
                              child: const Text('❤️ Saving…',
                                  style: TextStyle(fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFF87171))),
                            ),
                            AnimatedOpacity(
                              opacity: swipeHint == 'next' ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 120),
                              child: Text('Next →',
                                  style: appFont(isArabic: false, fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white70)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),

                      // ── Question card (swipeable + slide/fade transition) ─
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _flipCtrl,
                          builder: (ctx, child) {
                            final v = _flipCtrl.value;
                            // Phase 1 (0→0.5): slide left + fade out
                            // Phase 2 (0.5→1): slide in from right + fade in
                            final double dx;
                            final double opacity;
                            if (v <= 0.5) {
                              dx = -v * 2.0;
                              opacity = (1.0 - v * 2).clamp(0.0, 1.0);
                            } else {
                              dx = (1.0 - v) * 2.0;
                              opacity = ((v - 0.5) * 2).clamp(0.0, 1.0);
                            }
                            return FractionalTranslation(
                              translation: Offset(dx, 0),
                              child: Opacity(
                                opacity: opacity,
                                child: child,
                              ),
                            );
                          },
                          child: GestureDetector(
                            onHorizontalDragUpdate: _flipCtrl.isAnimating
                                ? null
                                : (d) => setState(() {
                                    _swipeOffset = (_swipeOffset + d.delta.dx)
                                        .clamp(-130.0, 130.0);
                                  }),
                            onHorizontalDragEnd: _flipCtrl.isAnimating
                                ? null
                                : (_) {
                                    if (_swipeOffset > 80) {
                                      setState(() {
                                        _isFav = !_isFav;
                                        if (_isFav) _flameCount++;
                                        _swipeOffset = 0;
                                      });
                                    } else if (_swipeOffset < -80) {
                                      setState(() => _swipeOffset = 0);
                                      _flipToNext();
                                    } else {
                                      setState(() => _swipeOffset = 0);
                                    }
                                  },
                            child: Transform(
                              transform: Matrix4.translationValues(
                                      _swipeOffset, 0.0, 0.0)
                                ..rotateZ(_swipeOffset * 0.00045),
                              alignment: Alignment.center,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(28),
                                  border: swipeHint == 'fav'
                                      ? Border.all(
                                          color: const Color(0xFFF87171)
                                              .withValues(alpha: 0.7),
                                          width: 2)
                                      : swipeHint == 'next'
                                          ? Border.all(
                                              color: Colors.white
                                                  .withValues(alpha: 0.3),
                                              width: 2)
                                          : null,
                                  boxShadow: [BoxShadow(
                                    color: cardShadow,
                                    blurRadius: 32,
                                    offset: const Offset(0, 12),
                                  )],
                                ),
                                child: Column(children: [
                                  // Card header
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 42, height: 42,
                                        decoration: BoxDecoration(
                                          color: cardModeIcon,
                                          borderRadius:
                                              BorderRadius.circular(13),
                                        ),
                                        child: Center(
                                            child: Text(modeEmoji,
                                                style: const TextStyle(
                                                    fontSize: 22))),
                                      ),
                                      GestureDetector(
                                        onTap: () => setState(() {
                                          _isFav = !_isFav;
                                          if (_isFav) _flameCount++;
                                        }),
                                        child: Icon(
                                          _isFav
                                              ? Icons.favorite_rounded
                                              : Icons.favorite_border_rounded,
                                          color: heartColor,
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Question + deeper + answer
                                  Expanded(
                                    child: Center(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              questionText,
                                              textAlign: TextAlign.center,
                                              style: appFont(
                                                isArabic: isArabic,
                                                fontSize: isArabic ? 21 : 20,
                                                fontWeight: FontWeight.w800,
                                                color: cardText,
                                                height: 1.45,
                                              ),
                                            ),

                                            // Go Deeper panel
                                            if (_goingDeeper) ...[
                                              const SizedBox(height: 16),
                                              Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.all(14),
                                                decoration: BoxDecoration(
                                                  color: _accent.withValues(
                                                      alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  border: Border.all(
                                                      color: _accent
                                                          .withValues(alpha: 0.4)),
                                                ),
                                                child: Text(
                                                  deeperText,
                                                  textAlign: TextAlign.center,
                                                  style: appFont(
                                                    isArabic: isArabic,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: _accent,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ],

                                            // Trivia reveal
                                            if (isTrivia && !_showAnswer) ...[
                                              const SizedBox(height: 20),
                                              GestureDetector(
                                                onTap: () => setState(
                                                    () => _showAnswer = true),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 22,
                                                      vertical: 10),
                                                  decoration: BoxDecoration(
                                                    color: _accent.withValues(
                                                        alpha: 0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    border: Border.all(
                                                        color: _accent
                                                            .withValues(
                                                                alpha: 0.5)),
                                                  ),
                                                  child: Text(
                                                    isArabic
                                                        ? '👁 اكشف الإجابة'
                                                        : '👁 Reveal Answer',
                                                    style: appFont(
                                                        isArabic: isArabic,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: _accent),
                                                  ),
                                                ),
                                              ),
                                            ],

                                            if (isTrivia && _showAnswer) ...[
                                              const SizedBox(height: 20),
                                              Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.all(14),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF4ADE80)
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  border: Border.all(
                                                      color: const Color(
                                                              0xFF4ADE80)
                                                          .withValues(
                                                              alpha: 0.5)),
                                                ),
                                                child: Text(
                                                  answerText,
                                                  textAlign: TextAlign.center,
                                                  style: appFont(
                                                    isArabic: isArabic,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        const Color(0xFF4ADE80),
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Bottom dash
                                  Container(
                                    width: 40, height: 4,
                                    decoration: BoxDecoration(
                                      color: cardDash,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── "How did that land?" emoji reactions ────────────
                      Text(
                        isArabic ? 'كيف وقع عليك؟' : 'How did that land?',
                        style: appFont(
                            isArabic: isArabic,
                            fontSize: 13,
                            color: Colors.white54),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_reactionEmojis.length, (i) {
                          final sel = _selectedReaction == i;
                          return GestureDetector(
                            onTap: () => setState(() {
                              if (!sel) _flameCount++;
                              _selectedReaction = sel ? null : i;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: sel
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.white.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: sel
                                      ? Colors.white.withValues(alpha: 0.5)
                                      : Colors.transparent,
                                ),
                              ),
                              child: Text(
                                _reactionEmojis[i],
                                style: TextStyle(fontSize: sel ? 26 : 22),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 10),

                      // ── Progress dots ───────────────────────────────────
                      _ProgressDots(
                          current: (gameState.currentIndex % 7) + 1),

                      const SizedBox(height: 10),

                      // ── Buttons ─────────────────────────────────────────
                      gameState.isLastCard
                          ? _FinishBtn(
                              isArabic: isArabic,
                              onTap: () {
                                ref.read(gameStateProvider.notifier).reset();
                                context.go('/vibe');
                              })
                          : Row(children: [
                              // Go Deeper — reveals a follow-up prompt
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _goingDeeper = !_goingDeeper),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    decoration: BoxDecoration(
                                      color: _goingDeeper
                                          ? _accent.withValues(alpha: 0.15)
                                          : Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                          color: _goingDeeper
                                              ? _accent.withValues(alpha: 0.5)
                                              : Colors.white
                                                  .withValues(alpha: 0.2)),
                                    ),
                                    child: Text(
                                      isArabic ? 'أعمق' : 'Go Deeper',
                                      textAlign: TextAlign.center,
                                      style: appFont(
                                          isArabic: isArabic,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: _goingDeeper
                                              ? _accent
                                              : Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Next Card — slides to next
                              Expanded(
                                flex: 2,
                                child: GestureDetector(
                                  onTap: () => _flipToNext(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            AppColors.primaryLight,
                                          ]),
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: [BoxShadow(
                                        color: _accent.withValues(alpha: 0.4),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      )],
                                    ),
                                    child: Text(
                                      isArabic ? 'البطاقة التالية' : 'Next Card',
                                      textAlign: TextAlign.center,
                                      style: appFont(
                                          isArabic: isArabic,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ]),

                      const SizedBox(height: 10),

                      // Skip
                      GestureDetector(
                        onTap: () => _flipToNext(countFlame: false),
                        child: Text(
                          isArabic
                              ? '⏭ تخطَّ هذا السؤال'
                              : '⏭ Skip this question',
                          style: appFont(isArabic: isArabic, fontSize: 13,
                              color: Colors.white38),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ]),
                  ),
                ),
              ]),

              // ── Confetti overlay ────────────────────────────────────────────
              IgnorePointer(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiCtrl,
                    blastDirectionality: BlastDirectionality.explosive,
                    emissionFrequency: 0.05,
                    numberOfParticles: 15,
                    maxBlastForce: 25,
                    minBlastForce: 10,
                    gravity: 0.1,
                  ),
                ),
              ),
            ]);
          }),
        ),
      ),
    );
  }

  String _modeEmoji(GameMode mode) {
    switch (mode) {
      case GameMode.dateMode:   return '❤️';
      case GameMode.spiceItUp:  return '🔥';
      case GameMode.familyTime: return '👨‍👩‍👧';
      case GameMode.sportMode:  return '⚽';
    }
  }

  String _modeLabel(GameMode mode) {
    switch (mode) {
      case GameMode.dateMode:   return 'Date Mode';
      case GameMode.spiceItUp:  return 'Spice It Up';
      case GameMode.familyTime: return 'Family Time';
      case GameMode.sportMode:  return 'Sport Mode';
    }
  }
}

// ── Progress dots ─────────────────────────────────────────────────────────────

class _ProgressDots extends StatelessWidget {
  final int current;
  const _ProgressDots({required this.current});

  @override
  Widget build(BuildContext context) {
    const total = 7;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final filled = i < current;
        final isCur  = i == current - 1;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isCur ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: filled
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ── Finish button ─────────────────────────────────────────────────────────────

class _FinishBtn extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onTap;
  const _FinishBtn({required this.isArabic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight]),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          isArabic ? '🎉 انتهى!' : '🎉 Finish!',
          textAlign: TextAlign.center,
          style: appFont(
              isArabic: isArabic,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white),
        ),
      ),
    );
  }
}
