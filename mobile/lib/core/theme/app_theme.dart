import 'package:flutter/material.dart';

class AppTheme {
  // ── Palet Warna Resmi Desain Smart Tani ──
  // Ekstrak langsung dari kartu palet & spektrum gradasi
  static const Color neonLime = Color(0xFFE3EF2D);        // Lime primer berpendar
  static const Color neonLimeBright = Color(0xFFE5FF2E);  // Lime cerah
  static const Color pastelLime = Color(0xFFE2FBCE);      // Mint lime pastel lembut
  static const Color creamWhite = Color(0xFFFFFDEE);      // Cream highlight
  static const Color emeraldGreen = Color(0xFF1F6652);    // Hijau zamrud natural
  static const Color deepTeal = Color(0xFF1F4A4A);        // Teal slate malam
  static const Color oceanTeal = Color(0xFF245863);       // Ocean teal sejuk
  static const Color darkSpruce = Color(0xFF0C241C);      // Spruce gelap elegan
  static const Color darkForest = Color(0xFF061D10);      // Background dasar gelap pekat
  static const Color darkGreenTop = Color(0xFF071B15);    // Top level container
  static const Color darkGreenBottom = Color(0xFF124E3B); // Bottom gradient anchor
  static const Color cardSurface = Color(0xFF0D2821);     // Permukaan kartu squircle
  static const Color inputFill = Color(0xFF091E18);       // Fill textfield
  static const Color textGrey = Color(0xFF8FA99F);        // Teks sekunder
  static const Color textLight = Color(0xFFFFFDEE);       // Teks primer kontras

  // ── Gradasi Background & Card Resmi ──
  // Gradasi Background Utama (Malam Kehutanan Mewah)
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF061D10),
      Color(0xFF0A261E),
      Color(0xFF0F3A2E),
      Color(0xFF124E3B),
    ],
  );

  // Gradasi Kartu Squircle (Aksentuasi Mewah seperti Squircle Icon)
  static const LinearGradient squircleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF163A33),
      Color(0xFF0C2720),
      Color(0xFF071B15),
    ],
  );

  // Gradasi Tombol Aksi Utama (Vibrant Lime)
  static const LinearGradient limeButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      creamWhite,
      neonLime,
      Color(0xFFD0ED22),
    ],
  );

  // Gradasi Aksen (Pastel Lime ke Emerald)
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      pastelLime,
      neonLime,
      emeraldGreen,
    ],
  );

  // ── ThemeData Gelap yang Konsisten & Nyaman ──
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkForest,
      primaryColor: neonLime,
      colorScheme: const ColorScheme.dark(
        primary: neonLime,
        secondary: emeraldGreen,
        surface: darkForest,
        onSurface: creamWhite,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: creamWhite,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: neonLime),
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: emeraldGreen.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
      ),
    );
  }
}