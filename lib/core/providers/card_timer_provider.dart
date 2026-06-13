import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final cardTimerProvider =
    StateNotifierProvider<CardTimerNotifier, bool>((ref) => CardTimerNotifier());

class CardTimerNotifier extends StateNotifier<bool> {
  CardTimerNotifier() : super(false) {
    _load();
  }

  static const _key = 'card_timer';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, state);
  }
}
