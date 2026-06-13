import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/dark_mode_provider.dart';
import 'core/providers/language_provider.dart';
import 'core/theme/app_theme.dart';
import 'router.dart';

class CardApp extends ConsumerWidget {
  const CardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(languageProvider);
    final isDark = ref.watch(darkModeProvider);

    return MaterialApp.router(
      title: 'Wannas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
      builder: (context, child) => Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
    );
  }
}
