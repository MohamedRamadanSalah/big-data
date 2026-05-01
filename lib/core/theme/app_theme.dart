import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Palette ──────────────────────────────────────────────────────────────────
  static const _primary = Color(0xFF4F6BFF);
  static const _primaryVariant = Color(0xFF3451E0);
  static const _surface = Color(0xFF1C1E2E);
  static const _surfaceVariant = Color(0xFF252839);
  static const _background = Color(0xFF13141F);
  static const _onSurface = Color(0xFFE8EAF6);
  static const _onSurfaceMuted = Color(0xFF8B8FA8);

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: _surface,

      colorScheme: const ColorScheme.dark(
        primary: _primary,
        primaryContainer: _primaryVariant,
        surface: _surface,
        surfaceContainerHighest: _surfaceVariant,
        onSurface: _onSurface,
        onSurfaceVariant: _onSurfaceMuted,
      ),

      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: _onSurface,
        displayColor: _onSurface,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        hintStyle: GoogleFonts.inter(
          color: _onSurfaceMuted,
          fontWeight: FontWeight.w400,
        ),
      ),

      cardTheme: CardThemeData(
        color: _surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _onSurface,
        ),
        iconTheme: const IconThemeData(color: _onSurface),
      ),

      dividerColor: _surfaceVariant,
    );
  }
}
