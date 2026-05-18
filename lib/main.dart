// lib/main.dart
//
// Application entry point for Semiram.
//
// Theme: "Champagne Navy" — a luxe 4-color palette designed for
// readability and a premium, boardroom-grade feel.
//
//   - Deep Navy     #101725  — primary background
//   - Slate Navy    #1B2436  — cards / elevated surfaces
//   - Champagne     #C9A06B  — accent (numbers, highlights, focus)
//   - Warm Cream    #F5F1EB  — primary text
//
// Helper tones:
//   - Muted Steel   #6B8AB4  — secondary accents (used sparingly)
//   - Quiet Grey    #9BA4B5  — secondary text

import 'package:flutter/material.dart';

import 'features/home/home_screen.dart';

void main() {
  runApp(const SemiramApp());
}

class SemiramApp extends StatelessWidget {
  const SemiramApp({super.key});

  // Brand palette constants — single source of truth.
  static const Color deepNavy = Color(0xFF101725);
  static const Color slateNavy = Color(0xFF1B2436);
  static const Color slateNavyHigh = Color(0xFF26334A);
  static const Color champagne = Color(0xFFC9A06B);
  static const Color champagneLight = Color(0xFFE0C896);
  static const Color warmCream = Color(0xFFF5F1EB);
  static const Color mutedSteel = Color(0xFF6B8AB4);
  static const Color quietGrey = Color(0xFF9BA4B5);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: champagne,
      brightness: Brightness.dark,
    ).copyWith(
      // Surfaces — navy palette
      surface: deepNavy,
      onSurface: warmCream,
      surfaceContainerLowest: const Color(0xFF0A111C),
      surfaceContainerLow: const Color(0xFF152030),
      surfaceContainer: slateNavy,
      surfaceContainerHigh: slateNavyHigh,
      surfaceContainerHighest: const Color(0xFF2F3D56),
      // Accents — champagne gold
      primary: champagne,
      onPrimary: deepNavy,
      primaryContainer: const Color(0xFF6B5232),
      onPrimaryContainer: champagneLight,
      secondary: champagneLight,
      onSecondary: deepNavy,
      tertiary: mutedSteel,
      onTertiary: warmCream,
      // Outlines / dividers
      outline: const Color(0xFF4E5B73),
      outlineVariant: const Color(0xFF2F3D56),
    );

    return MaterialApp(
      title: 'Semiram',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: deepNavy,
        appBarTheme: const AppBarTheme(
          backgroundColor: deepNavy,
          foregroundColor: warmCream,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: warmCream,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF2A3548),
          thickness: 0.5,
          space: 0.5,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: champagne.withValues(alpha: 0.06),
          side: BorderSide(
            color: champagne.withValues(alpha: 0.22),
            width: 0.8,
          ),
          labelStyle: TextStyle(
            color: champagne.withValues(alpha: 0.88),
            fontSize: 11,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: champagne,
            foregroundColor: deepNavy,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: champagne,
            side: BorderSide(color: champagne.withValues(alpha: 0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
