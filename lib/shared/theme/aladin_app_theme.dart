import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Colors ─────────────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF141414);
  static const Color card = Color(0xFF1F1F1F);
  static const Color cardHover = Color(0xFF2A2A2A);
  static const Color accent = Color(0xFFE50914); // Netflix red
  static const Color accentLight = Color(0xFFFF3B45);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF6B6B6B);
  static const Color divider = Color(0xFF2A2A2A);
  static const Color overlay = Color(0x99000000);
  static const Color favorite = Color(0xFFFFD700);

  // ── Layout Standards ───────────────────────────────────────────────────────
  static const double cardWidth = 140.0;
  static const double cardHeight = 200.0;
  static const double listSectionHeight = 270.0; // Şeritlerin toplam yüksekliği (Başlık + Liste)
  static const double listHeight = 215.0;        // Sadece yatay listenin (SizedBox) yüksekliği
  static const double gridHeight = 255.0;        // Izgara (Grid) içindeki her bir öğenin toplam yüksekliği (Kart + Yazı)

  // ── Text styles ─────────────────────────────────────────────────────────────
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle channelTitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    color: textSecondary,
  );

  // ── Theme data ───────────────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accentLight,
          surface: surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          titleTextStyle: headingMedium,
          iconTheme: IconThemeData(color: textPrimary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: accent,
          unselectedItemColor: textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        dividerTheme: const DividerThemeData(color: divider, thickness: 1),
        textTheme: const TextTheme(
          headlineLarge: headingLarge,
          headlineMedium: headingMedium,
          bodyMedium: TextStyle(color: textSecondary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: accent),
          ),
          labelStyle: const TextStyle(color: textSecondary),
          hintStyle: const TextStyle(color: textMuted),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      );
}
