import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/models/question.dart';
import '../../core/providers/game_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'friends_category_screen.dart';
import '../../core/providers/friends_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────────────────────────────────────

class FriendsGameScreen extends ConsumerStatefulWidget {
  const FriendsGameScreen({super.key});

  @override
  ConsumerState<FriendsGameScreen> createState() => _FriendsGameScreenState();
}

class _FriendsGameScreenState extends ConsumerState<FriendsGameScreen> {
  int _timeLeft = 0;
  bool _showScoring = false;
  bool _showFinalScore = false;
  // Multi-select: set of player indices who got it right
  Set<int> _selectedWinners = {};
  bool _noneIsRight = false;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startRound());
  }

  // ── Timer management ──────────────────────────────────────────────────────

  void _startRound() {
    if (!mounted) return;
    final difficulty = ref.read(friendsDifficultyProvider);

    setState(() {
      _showScoring = false;
      _showFinalScore = false;
      _selectedWinners = {};
      _noneIsRight = false;
    });

    if (difficulty == 'easy') return; // no timer

    final baseSecs = ref.read(friendsTimerSecondsProvider);
    final secs = difficulty == 'hard' ? 10 : baseSecs;

    setState(() => _timeLeft = secs);
    _countdownTimer?.cancel();
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_timeLeft > 1) {
          _timeLeft--;
        } else {
          _timeLeft = 0;
          t.cancel();
          _showScoring = true;
        }
      });
    });
  }

  void _endQuestion() {
    _countdownTimer?.cancel();
    setState(() {
      _timeLeft = 0;
      _showScoring = true;
    });
  }

  // ── Advance to next question ───────────────────────────────────────────────

  void _submitAndAdvance() {
    // Award a point to each selected winner
    if (_selectedWinners.isNotEmpty && !_noneIsRight) {
      final scores = List<int>.from(ref.read(playerScoresProvider));
      for (final i in _selectedWinners) {
        if (i >= 0 && i < scores.length) scores[i]++;
      }
      ref.read(playerScoresProvider.notifier).state = scores;
    }

    final gameState = ref.read(gameStateProvider);
    if (gameState?.isLastCard ?? true) {
      setState(() => _showFinalScore = true);
      return;
    }

    ref.read(gameStateProvider.notifier).next();
    _startRound();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(languageProvider);
    final gameState = ref.watch(gameStateProvider);
    final names = ref.watch(playerNamesProvider);
    final scores = ref.watch(playerScoresProvider);
    final difficulty = ref.watch(friendsDifficultyProvider);
    final category = ref.watch(selectedCategoryProvider);
    final s = S(isArabic);

    if (gameState == null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => context.go('/'));
      return const Scaffold(backgroundColor: Color(0xFF0D0D1A));
    }

    const gameBg = Color(0xFF0D0D1A);
    const accent = AppColors.sportGradientStart;
    final question = gameState.currentQuestion;
    final questionText =
        isArabic ? (question?.ar ?? '') : (question?.en ?? '');
    final answerText = isArabic
        ? (question?.answerAr ?? '')
        : (question?.answerEn ?? '');
    final categoryEmoji = category?.emoji ?? '🎮';
    final categoryTitle = (category?.title ?? 'Friends').toUpperCase();
    final qLabel =
        'Q${gameState.currentIndex + 1}/${gameState.totalCards}';
    final diffLabel = difficulty;

    // ── Final score screen ────────────────────────────────────────────────
    if (_showFinalScore) {
      return _FinalScoreScreen(
        names: names,
        scores: scores,
        isArabic: isArabic,
        s: s,
        accent: accent,
        onPlayAgain: () {
          ref.read(playerScoresProvider.notifier).state =
              List.filled(names.length, 0);
          ref.read(gameStateProvider.notifier).reset();
          context.go('/friends/categories');
        },
        onHome: () {
          ref.read(gameStateProvider.notifier).reset();
          context.go('/');
        },
      );
    }

    // ── Game scaffold ─────────────────────────────────────────────────────
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _countdownTimer?.cancel();
          ref.read(gameStateProvider.notifier).reset();
          context.go('/');
        }
      },
      child: Scaffold(
      backgroundColor: gameBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white70, size: 20),
          onPressed: () {
            _countdownTimer?.cancel();
            ref.read(gameStateProvider.notifier).reset();
            context.go('/');
          },
        ),
        title: Column(
          children: [
            Text(
              '$categoryEmoji $categoryTitle',
              style: appFont(
                isArabic: isArabic,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: accent,
                height: 1,
              ),
            ),
            Text(
              '$qLabel · $diffLabel',
              style: appFont(
                isArabic: false,
                fontSize: 11,
                color: Colors.white38,
                height: 1.4,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (!_showScoring)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: _endQuestion,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isArabic ? 'إنهاء' : 'End',
                    style: appFont(
                      isArabic: isArabic,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _showScoring
            ? _ScoringView(
                questionText: questionText,
                answerText: answerText,
                names: names,
                scores: scores,
                selectedWinners: _selectedWinners,
                noneIsRight: _noneIsRight,
                isArabic: isArabic,
                s: s,
                accent: accent,
                isLastCard: gameState.isLastCard,
                onToggleWinner: (i) => setState(() {
                  final updated = Set<int>.from(_selectedWinners);
                  if (updated.contains(i)) {
                    updated.remove(i);
                  } else {
                    updated.add(i);
                    _noneIsRight = false;
                  }
                  _selectedWinners = updated;
                }),
                onSelectNobody: () => setState(() {
                  _noneIsRight = !_noneIsRight;
                  if (_noneIsRight) _selectedWinners = {};
                }),
                onNext: _submitAndAdvance,
              )
            : _QuestionView(
                questionText: questionText,
                correctAnswer: answerText,
                questionOptions: isArabic
                    ? question?.optionsAr
                    : question?.optionsEn,
                questionPool: gameState.questions,
                timeLeft: _timeLeft,
                hasTimer: difficulty != 'easy',
                categoryEmoji: categoryEmoji,
                isArabic: isArabic,
                accent: accent,
                s: s,
                onEndQuestion: _endQuestion,
              ),
      ),
    ), // Scaffold
    ); // PopScope
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Question view
// ─────────────────────────────────────────────────────────────────────────────

class _QuestionView extends StatefulWidget {
  final String questionText;
  final String correctAnswer;           // localized correct answer
  final List<String>? questionOptions;  // [A,B,C,D] from data — null → use pool
  final List<Question> questionPool;    // fallback distractor pool
  final int timeLeft;
  final bool hasTimer;
  final String categoryEmoji;
  final bool isArabic;
  final Color accent;
  final S s;
  final VoidCallback onEndQuestion;

  const _QuestionView({
    required this.questionText,
    required this.correctAnswer,
    required this.questionPool,
    required this.timeLeft,
    required this.hasTimer,
    required this.categoryEmoji,
    required this.isArabic,
    required this.accent,
    required this.s,
    required this.onEndQuestion,
    this.questionOptions,
  });

  @override
  State<_QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<_QuestionView> {
  static const _labels = ['A', 'B', 'C', 'D'];
  static final _rng = Random();

  /// Shuffled list of 4 answer strings shown to the player.
  List<String> _options = [];

  /// Index inside [_options] that holds the correct answer.
  int _correctIndex = -1;

  /// Which tile the player has tapped (-1 = none).
  int _selectedAnswer = -1;

  /// Whether the correct answer has been revealed (after "Discuss & Score").
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _buildOptions();
  }

  @override
  void didUpdateWidget(_QuestionView old) {
    super.didUpdateWidget(old);
    if (old.questionText != widget.questionText ||
        old.correctAnswer != widget.correctAnswer) {
      _selectedAnswer = -1;
      _revealed = false;
      _buildOptions();
    }
  }

  /// Builds the 4 shuffled answer options.
  ///
  /// Priority:
  ///  1. Use `questionOptions` (real A/B/C/D from the data) — shuffled.
  ///  2. Fall back to the similarity-based pool algorithm.
  void _buildOptions() {
    final correct = widget.correctAnswer;

    if (correct.isEmpty) {
      _options = [];
      _correctIndex = -1;
      return;
    }

    // ── Priority 1: use real options from question data ────────────────────
    final opts = widget.questionOptions;
    if (opts != null && opts.length == 4) {
      final shuffled = List<String>.from(opts)..shuffle(_rng);
      _options = shuffled;
      _correctIndex = shuffled.indexOf(correct);
      return;
    }

    // ── Priority 2: similarity-based fallback from the pool ───────────────
    final pool = widget.questionPool
        .map((q) => widget.isArabic
            ? (q.answerAr ?? '')
            : (q.answerEn ?? ''))
        .where((a) => a.isNotEmpty && a != correct)
        .toSet()
        .toList();

    if (pool.length <= 3) {
      final combined = [...pool, correct]..shuffle(_rng);
      _options = combined;
      _correctIndex = combined.indexOf(correct);
      return;
    }

    final scored = pool
        .map((a) => _Scored(a, _similarity(correct, a)))
        .toList()
      ..sort((x, y) => y.score.compareTo(x.score));

    final window = scored.take(8).toList()..shuffle(_rng);
    final wrong = window.take(3).map((s) => s.answer).toList();

    final combined = [...wrong, correct]..shuffle(_rng);
    _options = combined;
    _correctIndex = combined.indexOf(correct);
  }

  /// Returns a 0‒1 similarity score between two answer strings.
  double _similarity(String a, String b) {
    final aW = a.trim().split(RegExp(r'\s+')); // words in a
    final bW = b.trim().split(RegExp(r'\s+')); // words in b

    // ── Word-count similarity (most important) ───────────────────────────────
    final aWc = aW.length;
    final bWc = bW.length;
    final wordRatio = aWc < bWc ? aWc / bWc : bWc / aWc; // 0..1

    // ── Char-length similarity ───────────────────────────────────────────────
    final aLen = a.length;
    final bLen = b.length;
    final lenRatio = aLen < bLen ? aLen / bLen : bLen / aLen; // 0..1

    // ── Both start with a digit? (years, counts, durations) ─────────────────
    final aDigit = a.isNotEmpty && a[0].contains(RegExp(r'[0-9٠-٩]'));
    final bDigit = b.isNotEmpty && b[0].contains(RegExp(r'[0-9٠-٩]'));
    final digitBonus = (aDigit == bDigit) ? 0.25 : 0.0;

    // ── Shared first word? (e.g. both start with "Real" or a player's name) ──
    final firstMatch =
        (aW.first.toLowerCase() == bW.first.toLowerCase()) ? 0.15 : 0.0;

    return wordRatio * 0.40 + lenRatio * 0.20 + digitBonus + firstMatch;
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = widget.isArabic;
    final accent = widget.accent;
    final s = widget.s;
    final hasOptions = _options.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Timer ────────────────────────────────────────────────────────
          if (widget.hasTimer) ...[
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${widget.timeLeft}',
                    style: appFont(
                      isArabic: false,
                      fontSize: 80,
                      fontWeight: FontWeight.w800,
                      color: widget.timeLeft <= 5 && widget.timeLeft > 0
                          ? Colors.red
                          : Colors.white,
                      height: 1,
                    ),
                  ),
                  TextSpan(
                    text: '  ${s.sec}',
                    style: appFont(
                      isArabic: isArabic,
                      fontSize: 18,
                      color: Colors.white38,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Question card ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E30),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Card header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(widget.categoryEmoji,
                            style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                    const Icon(Icons.favorite_border_rounded,
                        color: Colors.white38, size: 22),
                  ],
                ),
                const SizedBox(height: 20),

                // Question text
                Text(
                  widget.questionText,
                  textAlign: TextAlign.center,
                  style: appFont(
                    isArabic: isArabic,
                    fontSize: isArabic ? 20 : 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 20),

                // Accent line
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Answer tiles (only when questions have answers) ───────────
          if (hasOptions) ...[
            Text(
              isArabic ? 'اختر إجابتك' : 'Pick your answer',
              style: appFont(
                  isArabic: isArabic, fontSize: 12, color: Colors.white38),
            ),
            const SizedBox(height: 10),

            // 2-column grid of answer tiles
            Column(
              children: [
                Row(
                  children: [
                    _AnswerTile(
                      label: _labels[0],
                      text: _options[0],
                      isSelected: _selectedAnswer == 0,
                      isCorrect: _revealed && _correctIndex == 0,
                      isWrong: _revealed &&
                          _selectedAnswer == 0 &&
                          _correctIndex != 0,
                      accent: accent,
                      onTap: () => setState(
                          () => _selectedAnswer =
                              _selectedAnswer == 0 ? -1 : 0),
                    ),
                    const SizedBox(width: 10),
                    _AnswerTile(
                      label: _labels[1],
                      text: _options[1],
                      isSelected: _selectedAnswer == 1,
                      isCorrect: _revealed && _correctIndex == 1,
                      isWrong: _revealed &&
                          _selectedAnswer == 1 &&
                          _correctIndex != 1,
                      accent: accent,
                      onTap: () => setState(
                          () => _selectedAnswer =
                              _selectedAnswer == 1 ? -1 : 1),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _AnswerTile(
                      label: _labels[2],
                      text: _options[2],
                      isSelected: _selectedAnswer == 2,
                      isCorrect: _revealed && _correctIndex == 2,
                      isWrong: _revealed &&
                          _selectedAnswer == 2 &&
                          _correctIndex != 2,
                      accent: accent,
                      onTap: () => setState(
                          () => _selectedAnswer =
                              _selectedAnswer == 2 ? -1 : 2),
                    ),
                    const SizedBox(width: 10),
                    _AnswerTile(
                      label: _labels[3],
                      text: _options.length > 3 ? _options[3] : '',
                      isSelected: _selectedAnswer == 3,
                      isCorrect: _revealed && _correctIndex == 3,
                      isWrong: _revealed &&
                          _selectedAnswer == 3 &&
                          _correctIndex != 3,
                      accent: accent,
                      onTap: () => setState(
                          () => _selectedAnswer =
                              _selectedAnswer == 3 ? -1 : 3),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
          ] else
            const SizedBox(height: 20),

          // ── Discuss & Score button ────────────────────────────────────
          GestureDetector(
            onTap: () {
              if (hasOptions && !_revealed) {
                // First tap: reveal the correct answer
                setState(() => _revealed = true);
              } else {
                // Second tap (or no options): go to scoring
                widget.onEndQuestion();
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: _revealed ? Colors.white.withValues(alpha: 0.15) : accent,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  if (!_revealed)
                    BoxShadow(
                      color: accent.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                ],
              ),
              child: Text(
                _revealed
                    ? (isArabic ? 'التالي — التقييم →' : 'Next — Score →')
                    : (isArabic ? 'اكشف الإجابة →' : 'Reveal Answer →'),
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
          const SizedBox(height: 8),
        ],
      ),
    );
  }
} // end _QuestionViewState

// ── Tiny helper: answer + similarity score ────────────────────────────────────

class _Scored {
  final String answer;
  final double score;
  const _Scored(this.answer, this.score);
}

// ── Single answer tile ────────────────────────────────────────────────────────

class _AnswerTile extends StatelessWidget {
  final String label;
  final String text;
  final bool isSelected;
  final bool isCorrect;   // revealed and this is the right answer
  final bool isWrong;     // revealed and player picked this but it's wrong
  final Color accent;
  final VoidCallback onTap;

  const _AnswerTile({
    required this.label,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color border;
    final Color labelBg;

    if (isCorrect) {
      bg = const Color(0xFF00C897).withValues(alpha: 0.18);
      border = const Color(0xFF00C897).withValues(alpha: 0.8);
      labelBg = const Color(0xFF00C897);
    } else if (isWrong) {
      bg = const Color(0xFFFF6B6B).withValues(alpha: 0.15);
      border = const Color(0xFFFF6B6B).withValues(alpha: 0.7);
      labelBg = const Color(0xFFFF6B6B);
    } else if (isSelected) {
      bg = accent.withValues(alpha: 0.20);
      border = accent.withValues(alpha: 0.8);
      labelBg = accent;
    } else {
      bg = Colors.white.withValues(alpha: 0.07);
      border = Colors.white.withValues(alpha: 0.12);
      labelBg = Colors.white.withValues(alpha: 0.12);
    }

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Letter badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: labelBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    isCorrect
                        ? '✓'
                        : isWrong
                            ? '✗'
                            : label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Answer text
              Expanded(
                child: Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isCorrect
                        ? const Color(0xFF00C897)
                        : isWrong
                            ? const Color(0xFFFF6B6B)
                            : isSelected
                                ? Colors.white
                                : Colors.white70,
                    fontSize: 12,
                    fontWeight: isSelected || isCorrect || isWrong
                        ? FontWeight.w700
                        : FontWeight.w500,
                    height: 1.3,
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

// ─────────────────────────────────────────────────────────────────────────────
// Scoring view
// ─────────────────────────────────────────────────────────────────────────────

class _ScoringView extends StatelessWidget {
  final String questionText;
  final String answerText;
  final List<String> names;
  final List<int> scores;
  final Set<int> selectedWinners;
  final bool noneIsRight;
  final bool isArabic;
  final S s;
  final Color accent;
  final bool isLastCard;
  final void Function(int) onToggleWinner;
  final VoidCallback onSelectNobody;
  final VoidCallback onNext;

  const _ScoringView({
    required this.questionText,
    required this.answerText,
    required this.names,
    required this.scores,
    required this.selectedWinners,
    required this.noneIsRight,
    required this.isArabic,
    required this.s,
    required this.accent,
    required this.isLastCard,
    required this.onToggleWinner,
    required this.onSelectNobody,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              children: [
                // Question in italic at top
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Text(
                    '"$questionText"',
                    textAlign: TextAlign.center,
                    style: appFont(
                      isArabic: isArabic,
                      fontSize: 14,
                      color: Colors.white54,
                      height: 1.5,
                    ).copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
                const SizedBox(height: 12),

                // Correct Answer reveal
                if (answerText.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D2B1A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.greenAccent.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('✅', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic ? 'الإجابة الصحيحة' : 'Correct Answer',
                                style: appFont(
                                  isArabic: isArabic,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.greenAccent,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                answerText,
                                style: appFont(
                                  isArabic: isArabic,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // DISCUSS! card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        s.discuss,
                        style: appFont(
                          isArabic: isArabic,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: accent,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.shareYourAnswers,
                        textAlign: TextAlign.center,
                        style: appFont(
                          isArabic: isArabic,
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // WHO GOT IT RIGHT? section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        s.whoGotItRight,
                        textAlign: TextAlign.center,
                        style: appFont(
                          isArabic: isArabic,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white38,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Player buttons — tap to toggle, multiple allowed
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: names.asMap().entries.map((e) {
                          final i = e.key;
                          final name = e.value;
                          final score = i < scores.length ? scores[i] : 0;
                          final isSelected = selectedWinners.contains(i);
                          return GestureDetector(
                            onTap: () => onToggleWinner(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? accent.withValues(alpha: 0.2)
                                    : Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? accent : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    name,
                                    style: appFont(
                                      isArabic: isArabic,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected ? Colors.white : Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$score ${s.pts}',
                                    style: appFont(
                                      isArabic: isArabic,
                                      fontSize: 12,
                                      color: isSelected ? accent : Colors.white38,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // No one is right
                      GestureDetector(
                        onTap: onSelectNobody,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                            color: noneIsRight
                                ? Colors.red.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: noneIsRight
                                  ? Colors.red.withValues(alpha: 0.5)
                                  : Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Text(
                            s.noOneIsRight,
                            textAlign: TextAlign.center,
                            style: appFont(
                              isArabic: isArabic,
                              fontSize: 13,
                              color: noneIsRight
                                  ? Colors.red
                                  : Colors.white38,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Sticky Next Question / Finish button
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: GestureDetector(
            onTap: onNext,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                isLastCard ? s.finish : s.nextQuestion,
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
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Final score screen
// ─────────────────────────────────────────────────────────────────────────────

class _FinalScoreScreen extends StatelessWidget {
  final List<String> names;
  final List<int> scores;
  final bool isArabic;
  final S s;
  final Color accent;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  const _FinalScoreScreen({
    required this.names,
    required this.scores,
    required this.isArabic,
    required this.s,
    required this.accent,
    required this.onPlayAgain,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    // Sort by score descending
    final entries = names.asMap().entries.map((e) {
      final score = e.key < scores.length ? scores[e.key] : 0;
      return (name: e.value, score: score);
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    final maxScore =
        entries.isNotEmpty ? entries.first.score : 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text('🏆',
                  style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                s.finalScores,
                style: appFont(
                  isArabic: isArabic,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // Score rows
              ...entries.map((e) {
                final isWinner =
                    e.score == maxScore && maxScore > 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isWinner
                          ? accent.withValues(alpha: 0.18)
                          : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isWinner
                            ? accent
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (isWinner) ...[
                          const Text('👑',
                              style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: Text(
                            e.name,
                            style: appFont(
                              isArabic: isArabic,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isWinner
                                  ? Colors.white
                                  : Colors.white70,
                            ),
                          ),
                        ),
                        Text(
                          '${e.score} ${s.pts}',
                          style: appFont(
                            isArabic: isArabic,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isWinner
                                ? accent
                                : Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const Spacer(),

              // Play Again
              GestureDetector(
                onTap: onPlayAgain,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    s.playAgain,
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

              // Back to Home
              GestureDetector(
                onTap: onHome,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    s.backHome,
                    textAlign: TextAlign.center,
                    style: appFont(
                      isArabic: isArabic,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
