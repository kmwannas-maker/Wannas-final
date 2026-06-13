import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/question.dart';
import '../../data/date_questions.dart';
import '../../data/spice_questions.dart';
import '../../data/family_questions.dart';
import '../../data/sport_questions.dart';
import '../../data/tv_questions.dart';
import '../../data/music_questions.dart';
import '../../data/gaming_questions.dart';
import '../../data/wyr_questions.dart';
import '../../data/beauty_questions.dart';
import '../../data/travel_questions.dart';
import '../../data/food_questions.dart';

class QuestionsRepository {
  final FirebaseFirestore _db;
  QuestionsRepository(this._db);

  /// Fetches all questions for a given mode from Firestore.
  /// Falls back to bundled local data if Firestore is unavailable or empty.
  Future<List<Question>> fetchByMode(String mode) async {
    try {
      final snap = await _db
          .collection('questions')
          .where('mode', isEqualTo: mode)
          .get(const GetOptions(source: Source.serverAndCache));

      if (snap.docs.isEmpty) return _localFallback(mode);

      final allQuestions = snap.docs.map((doc) {
        final d = doc.data();
        return Question(
          en: (d['en'] as String?) ?? '',
          ar: (d['ar'] as String?) ?? '',
          depth: (d['depth'] as int?) ?? 1,
          answerEn: d['answerEn'] as String?,
          answerAr: d['answerAr'] as String?,
          optionsEn: (d['optionsEn'] as List?)?.cast<String>(),
          optionsAr: (d['optionsAr'] as List?)?.cast<String>(),
        );
      }).toList();

      // Sport/Football: only show trivia questions that have an answer
      if (mode == 'sport') {
        final withAnswers = allQuestions.where((q) => q.hasAnswer).toList();
        return withAnswers.isNotEmpty ? withAnswers : _localFallback(mode);
      }
      return allQuestions;
    } catch (_) {
      return _localFallback(mode);
    }
  }

  List<Question> _localFallback(String mode) {
    switch (mode) {
      case 'date':    return dateQuestions;
      case 'spice':   return spiceQuestions;
      case 'family':  return familyQuestions;
      case 'sport':   return sportQuestions;
      case 'tv':      return tvQuestions;
      case 'music':   return musicQuestions;
      case 'gaming':  return gamingQuestions;
      case 'wyr':     return wyrQuestions;
      case 'beauty':  return beautyQuestions;
      case 'travel':  return travelQuestions;
      case 'food':    return foodQuestions;
      default:        return [];
    }
  }
}

// ── Riverpod providers ──────────────────────────────────────────────────────

final questionsRepositoryProvider = Provider<QuestionsRepository>((ref) {
  return QuestionsRepository(FirebaseFirestore.instance);
});

/// Returns questions for a given mode string.
final questionsByModeProvider =
    FutureProvider.family<List<Question>, String>((ref, mode) async {
  final repo = ref.watch(questionsRepositoryProvider);
  return repo.fetchByMode(mode);
});
