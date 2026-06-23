import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'core/models/game_mode.dart';
import 'features/auth/auth_screen.dart';
import 'features/family/activities/family_activities_results_screen.dart';
import 'features/family/activities/family_activities_screen.dart';
import 'features/family/family_hub_screen.dart';
import 'features/family/heart/heart_card_screen.dart';
import 'features/family/heart/heart_group_screen.dart';
import 'features/friends/friends_category_screen.dart';
import 'features/friends/friends_game_screen.dart';
import 'features/friends/friends_game_settings_screen.dart';
import 'features/friends/friends_intro_screen.dart';
import 'features/friends/friends_player_count_screen.dart';
import 'features/friends/friends_player_names_screen.dart';
import 'features/game/game_screen.dart';
import 'features/game/level_select_screen.dart';
import 'features/game/vibe_select_screen.dart';
import 'features/home/home_screen.dart';
import 'features/paywall/paywall_screen.dart';
import 'features/settings/settings_screen.dart';

// Notifies the router whenever the user signs in or out,
// so redirects re-run automatically.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }
}

final _authNotifier = _AuthNotifier();

final appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: _authNotifier,
  redirect: (context, state) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final goingToAuth = state.matchedLocation == '/auth';

    if (!loggedIn && !goingToAuth) return '/auth';
    if (loggedIn && goingToAuth) return '/';
    return null;
  },
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/vibe',
      builder: (context, state) => const VibeSelectScreen(),
    ),

    // Family Time
    GoRoute(
      path: '/family',
      builder: (context, state) => const FamilyHubScreen(),
    ),
    GoRoute(
      path: '/family/activities',
      builder: (context, state) => const FamilyActivitiesScreen(),
    ),
    GoRoute(
      path: '/family/activities/results',
      builder: (context, state) => const FamilyActivitiesResultsScreen(),
    ),
    GoRoute(
      path: '/family/heart',
      builder: (context, state) => const HeartGroupScreen(),
    ),
    GoRoute(
      path: '/family/heart/play',
      builder: (context, state) => const HeartCardScreen(),
    ),

    // Friends Mode
    GoRoute(
      path: '/friends',
      builder: (context, state) => const FriendsIntroScreen(),
    ),
    GoRoute(
      path: '/friends/categories',
      builder: (context, state) => const FriendsCategoryScreen(),
    ),
    GoRoute(
      path: '/friends/players',
      builder: (context, state) => const FriendsPlayerCountScreen(),
    ),
    GoRoute(
      path: '/friends/settings',
      builder: (context, state) => const FriendsGameSettingsScreen(),
    ),
    GoRoute(
      path: '/friends/names',
      builder: (context, state) => const FriendsPlayerNamesScreen(),
    ),
    GoRoute(
      path: '/friends/game',
      builder: (context, state) => const FriendsGameScreen(),
    ),

    // Other modes (Date / Couples / old static game)
    GoRoute(
      path: '/mode/:mode',
      builder: (context, state) {
        final modeName = state.pathParameters['mode']!;
        final mode = GameMode.values.firstWhere((e) => e.name == modeName);
        return LevelSelectScreen(mode: mode);
      },
    ),
    GoRoute(
      path: '/game',
      builder: (context, state) => const GameScreen(),
    ),
    GoRoute(
      path: '/paywall',
      builder: (context, state) => const PaywallScreen(),
    ),
  ],
);