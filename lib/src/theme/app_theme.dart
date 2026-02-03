import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _seed = Color(0xFF5B5BD6);

  static ThemeData light(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _seed,
      brightness: Brightness.light,
      visualDensity: VisualDensity.standard,
    );

    final textTheme = GoogleFonts.ibmPlexSansArabicTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(centerTitle: false),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: base.colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData dark(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _seed,
      brightness: Brightness.dark,
      visualDensity: VisualDensity.standard,
    );

    final textTheme = GoogleFonts.ibmPlexSansArabicTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(centerTitle: false),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: base.colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
