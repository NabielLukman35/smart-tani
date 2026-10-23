import 'package:flutter/material.dart';

/// Design Taste: Smart Greenhouse & Agronomy Instrumentation
/// Rules:
/// - One ground, one ink, one accent
/// - Flat color and real material over gradients
/// - No gradients as background, text, or buttons
/// - No shadows on static elements
/// - Surfaces separated by tone differences, not thin lines or glows
/// - Left alignment by default
/// - Headlines 2 lines or fewer at every width
class AppTheme {
  // ── Palet Tiga Elemen Disiplin (Ground, Ink, Accent) ──
  static const Color ground = Color(0xFF0A1410);          // Ground dasar (tanah malam pekat)
  static const Color panel = Color(0xFF122019);           // Surface panel instrumen lahan
  static const Color panelElevated = Color(0xFF182A22);   // Kontainer elevasi / input field
  static const Color borderQuiet = Color(0xFF1F352B);     // Batas tenang pemisah tone

  static const Color ink = Color(0xFFF3F7F2);             // Ink primer (kontras, mudah dibaca)
  static const Color inkSecondary = Color(0xFF8FA396);    // Ink sekunder (sage netral)
  static const Color inkTertiary = Color(0xFF607569);     // Ink metadata pendukung
  static const Color accent = Color(0xFFD4E838);          // Aksen agronomi fungsional (lime)

  static const Color statusAlert = Color(0xFFE06C75);     // Peringatan kritis
  static const Color statusOk = Color(0xFF73C991);        // Status optimal / normal
  static const Color statusWarning = Color(0xFFE5A93C);   // Perhatian

  // ── Alias Kompatibilitas Kode Eksisting (Flat & Selaras) ──
  static const Color darkForest = ground;
  static const Color cardSurface = panel;
  static const Color darkSpruce = panel;
  static const Color inputFill = panelElevated;
  static const Color creamWhite = ink;
  static const Color textLight = ink;
  static const Color textGrey = inkSecondary;
  static const Color pastelLime = inkSecondary;
  static const Color neonLime = accent;
  static const Color neonLimeBright = accent;
  static const Color emeraldGreen = borderQuiet;
  static const Color deepTeal = panel;
  static const Color oceanTeal = panelElevated;
  static const Color darkGreenTop = ground;
  static const Color darkGreenBottom = ground;

  // ── Gradasi Dinonaktifkan (Flat Solid Color demi Kepatuhan Design Taste) ──
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [ground, ground],
  );

  static const LinearGradient squircleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [panel, panel],
  );

  static const LinearGradient limeButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accent],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accent],
  );

  // ── Typography Tokens (Left-aligned, Scaled, Clean) ──
  static const TextStyle display = TextStyle(
    color: ink,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    height: 1.15,
  );

  static const TextStyle headline = TextStyle(
    color: ink,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.25,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: ink,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    color: ink,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static const TextStyle bodyMuted = TextStyle(
    color: inkSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    color: inkTertiary,
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  // ── ThemeData Flat & Bebas Bayangan Palsu ──
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ground,
      primaryColor: accent,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: panelElevated,
        surface: ground,
        onSurface: ink,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: ground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: ink),
      ),
      cardTheme: CardThemeData(
        color: panel,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(
            color: borderQuiet,
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: panelElevated,
        hintStyle: const TextStyle(color: inkTertiary, fontSize: 13.5),
        labelStyle: const TextStyle(color: inkSecondary, fontSize: 13.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderQuiet, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderQuiet, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: accent,
          foregroundColor: ground,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: const BorderSide(color: borderQuiet, width: 1),
          textStyle: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderQuiet,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
