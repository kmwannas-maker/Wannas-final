import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_prefs_provider.dart';

final isPremiumProvider = StateNotifierProvider<PurchaseNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PurchaseNotifier(prefs);
});

class PurchaseNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const _key = 'is_premium';

  PurchaseNotifier(this._prefs) : super(_prefs.getBool(_key) ?? false);

  Future<void> unlock() async {
    // TODO: Wire up RevenueCat purchase here
    state = true;
    await _prefs.setBool(_key, true);
  }

  Future<void> restore() async {
    // TODO: Wire up RevenueCat restore here
  }
}
