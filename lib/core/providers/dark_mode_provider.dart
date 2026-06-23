import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared_prefs_provider.dart';

final darkModeProvider =
    StateNotifierProvider<DarkModeNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DarkModeNotifier(prefs);
});

class DarkModeNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const _key = 'dark_mode';

  DarkModeNotifier(this._prefs) : super(_prefs.getBool(_key) ?? false);

  Future<void> toggle() async {
    state = !state;
    await _prefs.setBool(_key, state);
  }
}
