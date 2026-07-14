// Semiram theme — "Champagne Navy".
//
// Dark: deep navy surfaces, champagne-gold accents, warm cream text.
// Light: warm paper surfaces, deeper gold accents, navy ink text.
//
// ALL colors used by widgets must come from Theme.of(context).colorScheme
// (or these builders) — never hardcode Colors.* in screens.

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Brand palette — single source of truth ──────────────────
  static const Color deepNavy = Color(0xFF101725);
  static const Color slateNavy = Color(0xFF1B2436);
  static const Color slateNavyHigh = Color(0xFF26334A);
  static const Color champagne = Color(0xFFC9A06B);
  static const Color champagneLight = Color(0xFFE0C896);
  static const Color champagneDeep = Color(0xFF8A6A3B); // light-mode accent
  static const Color warmCream = Color(0xFFF5F1EB);
  static const Color mutedSteel = Color(0xFF6B8AB4);
  static const Color quietGrey = Color(0xFF9BA4B5);
  static const Color inkNavy = Color(0xFF1A2233); // light-mode text

  // ── Dark theme ──────────────────────────────────────────────
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: champagne,
      brightness: Brightness.dark,
    ).copyWith(
      surface: deepNavy,
      onSurface: warmCream,
      surfaceContainerLowest: const Color(0xFF0A111C),
      surfaceContainerLow: const Color(0xFF152030),
      surfaceContainer: slateNavy,
      surfaceContainerHigh: slateNavyHigh,
      surfaceContainerHighest: const Color(0xFF2F3D56),
      primary: champagne,
      onPrimary: deepNavy,
      primaryContainer: const Color(0xFF6B5232),
      onPrimaryContainer: champagneLight,
      secondary: champagneLight,
      onSecondary: deepNavy,
      tertiary: mutedSteel,
      onTertiary: warmCream,
      error: const Color(0xFFCF6679),
      outline: const Color(0xFF4E5B73),
      outlineVariant: const Color(0xFF2F3D56),
    );
    return _base(colorScheme, dividerColor: const Color(0xFF2A3548));
  }

  // ── Light theme ─────────────────────────────────────────────
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: champagne,
      brightness: Brightness.light,
    ).copyWith(
      surface: const Color(0xFFFAF7F2),
      onSurface: inkNavy,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFF3EEE6),
      surfaceContainer: const Color(0xFFEDE7DC),
      surfaceContainerHigh: const Color(0xFFE5DDCF),
      surfaceContainerHighest: const Color(0xFFDDD3C2),
      primary: champagneDeep,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFEADCC3),
      onPrimaryContainer: const Color(0xFF5A431F),
      secondary: const Color(0xFFA5814B),
      onSecondary: Colors.white,
      tertiary: const Color(0xFF4A6A94),
      onTertiary: Colors.white,
      error: const Color(0xFFB3261E),
      outline: const Color(0xFFB0A490),
      outlineVariant: const Color(0xFFD8CFC0),
    );
    return _base(colorScheme, dividerColor: const Color(0xFFE2DACB));
  }

  // ── Shared component themes ─────────────────────────────────
  static ThemeData _base(ColorScheme colorScheme,
      {required Color dividerColor}) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 0.5,
        space: 0.5,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.primary.withValues(alpha: 0.06),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.22),
          width: 0.8,
        ),
        labelStyle: TextStyle(
          color: colorScheme.primary.withValues(alpha: 0.88),
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.5)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

/// Semantic text colors that adapt to the active theme.
/// Use these instead of Colors.white70 / white60 / white38.
extension ThemeColorsX on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;

  /// Body text — slightly muted.
  Color get textMedium => cs.onSurface.withValues(alpha: 0.75);

  /// Secondary text — subtitles, captions.
  Color get textSubtle => cs.onSurface.withValues(alpha: 0.58);

  /// Hints, disabled, decorative icons.
  Color get textFaint => cs.onSurface.withValues(alpha: 0.38);
}

/// App-wide theme mode controller with SQLite-free persistence
/// (uses shared_preferences).
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController(super.value);

  void toggle() {
    value = value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}
