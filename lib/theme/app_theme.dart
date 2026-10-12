import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet CleanGo: teal dari logo + putih "busa" yang sedikit kebiruan.
class AppColors {
  static const teal = Color(0xFF0E7C7B); // warna logo
  static const ink = Color(0xFF0A3D3C); // teks utama (teal sangat gelap)
  static const foam = Color(0xFFF2F8F7); // latar layar
  static const mist = Color(0xFFDDEFED); // tint teal untuk ikon & pilihan aktif
  static const line = Color(0xFFD9E6E4); // garis tepi
  static const muted = Color(0xFF5E7876); // teks sekunder
  static const danger = Color(0xFFC0392B);
  static const success = Color(0xFF1E8E4E);
  static const amber = Color(0xFFB26A00);
  static const blue = Color(0xFF1D6FB8);
  static const violet = Color(0xFF6B4FA0);
}

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.teal).copyWith(
      primary: AppColors.teal,
      onPrimary: Colors.white,
      primaryContainer: AppColors.mist,
      onPrimaryContainer: AppColors.ink,
      surface: Colors.white,
      onSurface: AppColors.ink,
      surfaceContainerHigh: Colors.white,
      outline: AppColors.line,
      outlineVariant: AppColors.line,
      error: AppColors.danger,
    );

    final text = GoogleFonts.plusJakartaSansTextTheme().apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );

    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    const buttonText = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.foam,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.foam,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: AppColors.ink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
        ),
        labelStyle: const TextStyle(color: AppColors.muted),
        floatingLabelStyle: const TextStyle(color: AppColors.teal, fontWeight: FontWeight.w600),
        helperStyle: const TextStyle(color: AppColors.muted),
        prefixIconColor: AppColors.muted,
        suffixIconColor: AppColors.muted,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.teal.withValues(alpha: 0.55),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.teal,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: const BorderSide(color: AppColors.line, width: 1.4),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.teal,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        elevation: 3,
        extendedTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1, space: 1),
    );
  }
}
