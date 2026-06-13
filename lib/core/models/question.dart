class Question {
  final String en;
  final String ar;
  final int depth;

  /// The correct answer text (trivia reveal + scoring).
  final String? answerEn;
  final String? answerAr;

  /// All 4 answer options [A, B, C, D] in English.
  /// When present, used directly as the multiple-choice tiles in Friends mode.
  final List<String>? optionsEn;

  /// All 4 answer options [A, B, C, D] in Arabic.
  final List<String>? optionsAr;

  const Question({
    required this.en,
    required this.ar,
    required this.depth,
    this.answerEn,
    this.answerAr,
    this.optionsEn,
    this.optionsAr,
  });

  bool get hasAnswer => answerEn != null && answerEn!.isNotEmpty;
  bool get hasOptions => optionsEn != null && optionsEn!.isNotEmpty;
}
