import 'package:flutter/material.dart';

class AppTheme {
  // Rich Casino Dark Palette matching screenshots
  static const Color background = Color(0xFF130121);       // Deep royal purple background
  static const Color surface = Color(0xFF1E0736);          // Dark violet card/surface
  static const Color surfaceLight = Color(0xFF2C0D4D);     // Elevated violet surface
  static const Color sidebarBg = Color(0xFF170327);        // Left tab bar background
  static const Color sidebarActive = Color(0xFF7B1FA2);    // Active tab background / Magenta glow
  
  // Neon & Metallic Gold Accents
  static const Color gold = Color(0xFFFFC82C);             // Bright gold text & icons
  static const Color goldLight = Color(0xFFFFE082);        // Subtle gold shine
  static const Color goldDark = Color(0xFFB8860B);         // Deep gold border
  static const Color neonPink = Color(0xFFFF2A85);         // Hot / Promo neon pink
  static const Color neonPurple = Color(0xFFA855F7);       // Violet neon accents
  static const Color neonGreen = Color(0xFF10B981);        // "NEW" tag emerald green
  static const Color neonBlue = Color(0xFF00D2FF);         // Ticker / Info blue
  
  // Primary Casino Brand colors
  static const Color primary = Color(0xFF9333EA);          // Electric Purple
  static const Color primaryDark = Color(0xFF6B21A8);
  static const Color accentYellow = Color(0xFFFFB800);
  
  // Semantic
  static const Color success = Color(0xFF22C55E);          // Deposit / win green
  static const Color danger = Color(0xFFEF4444);           // Hot tag red
  static const Color textLight = Color(0xFFFFFFFF);        // Primary White text
  static const Color textMuted = Color(0xFFB099D0);        // Soft purple-grey text
  static const Color border = Color(0xFF38155A);           // Subtle purple border
  static const Color borderGold = Color(0xFFFFD54F);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFDF7A), Color(0xFFFFAB00), Color(0xFFE68A00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8E24AA), Color(0xFF5E17EB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient hotBadgeGradient = LinearGradient(
    colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient newBadgeGradient = LinearGradient(
    colors: [Color(0xFF00B09B), Color(0xFF96C93D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bottomNavGradient = LinearGradient(
    colors: [Color(0xFF4A0E78), Color(0xFF260543)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: gold,
        surface: surface,
        error: danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: textLight,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
        iconTheme: IconThemeData(color: textLight),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
    );
  }
}
