// lib/main.dart
//
// Application entry point for Semiram.
// Theme definitions live in core/theme/app_theme.dart.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';

/// Global theme controller — toggled from the home menu,
/// persisted across launches.
final themeController = ThemeController(ThemeMode.dark);

const _kThemePrefKey = 'theme_mode';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Restore saved theme mode.
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_kThemePrefKey);
  if (saved == 'light') themeController.value = ThemeMode.light;

  // Persist on change.
  themeController.addListener(() {
    prefs.setString(
      _kThemePrefKey,
      themeController.value == ThemeMode.light ? 'light' : 'dark',
    );
  });

  runApp(const SemiramApp());
}

class SemiramApp extends StatelessWidget {
  const SemiramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Semiram',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
