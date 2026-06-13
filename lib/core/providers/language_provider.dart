import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_prefs_provider.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LanguageNotifier(prefs);
});

class LanguageNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const _key = 'is_arabic';

  LanguageNotifier(this._prefs) : super(_prefs.getBool(_key) ?? false);

  void toggle() {
    state = !state;
    _prefs.setBool(_key, state);
  }
}
