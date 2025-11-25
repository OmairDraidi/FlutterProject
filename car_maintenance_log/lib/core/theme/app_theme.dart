import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Material 3 theme configuration for the app with Omair Brand colors
class AppTheme {
  // Omair Brand - Primary Blue
  static const Color _omairBlueDark = Color(0xFF1D4ED8);
  static const Color _omairBlue = Color(0xFF2563EB);
  static const Color _omairBlueLight = Color(0xFF60A5FA);

  // Omair Brand - Secondary Emerald
  static const Color _emerald = Color(0xFF22C55E);
  static const Color _emeraldDark = Color(0xFF16A34A);

  // Omair Brand - Tertiary Purple
  static const Color _purple = Color(0xFF8B5CF6);

  // Omair Brand - Status Colors
  static const Color _error = Color(0xFFDC2626);
  static const Color _warning = Color(0xFFF59E0B);
  static const Color _success = Color(0xFF22C55E);

  // Light theme colors
  static const Color _lightBackground = Color(0xFFF9FAFB);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightOutline = Color(0xFFD1D5DB);
  static const Color _lightOnBackground = Color(0xFF020617);
  static const Color _lightOnSurface = Color(0xFF0F172A);

  // Dark theme colors
  static const Color _darkBackground = Color(0xFF020617);
  static const Color _darkSurface = Color(0xFF0F172A);
  static const Color _darkOutline = Color(0xFF334155);
  static const Color _darkOnBackground = Color(0xFFE5E7EB);
  static const Color _darkOnSurface = Color(0xFFF1F5F9);

  /// Light color scheme - Omair Brand
  static final ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    // Primary - Omair Blue
    primary: _omairBlue,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDBEAFE),
    onPrimaryContainer: _omairBlueDark,
    // Secondary - Emerald
    secondary: _emerald,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFD1FAE5),
    onSecondaryContainer: _emeraldDark,
    // Tertiary - Purple
    tertiary: _purple,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFEDE9FE),
    onTertiaryContainer: Color(0xFF5B21B6),
    // Error
    error: _error,
    onError: Colors.white,
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: Color(0xFF991B1B),
    // Background & Surface
    background: _lightBackground,
    onBackground: _lightOnBackground,
    surface: _lightSurface,
    onSurface: _lightOnSurface,
    surfaceVariant: Color(0xFFF3F4F6),
    onSurfaceVariant: Color(0xFF6B7280),
    // Outline
    outline: _lightOutline,
    outlineVariant: Color(0xFFE5E7EB),
    // Shadow & Scrim
    shadow: Colors.black.withOpacity(0.05),
    scrim: Colors.black.withOpacity(0.5),
    // Inverse
    inverseSurface: Color(0xFF1E293B),
    onInverseSurface: Color(0xFFF1F5F9),
    inversePrimary: _omairBlueLight,
    surfaceTint: _omairBlue,
  );

  /// Dark color scheme - Omair Brand
  static final ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    // Primary - Omair Blue (brighter for dark mode)
    primary: _omairBlueLight,
    onPrimary: _darkBackground,
    primaryContainer: _omairBlueDark,
    onPrimaryContainer: Color(0xFFDBEAFE),
    // Secondary - Emerald
    secondary: _emerald,
    onSecondary: _darkBackground,
    secondaryContainer: _emeraldDark,
    onSecondaryContainer: Color(0xFFD1FAE5),
    // Tertiary - Purple
    tertiary: Color(0xFFA78BFA),
    onTertiary: _darkBackground,
    tertiaryContainer: Color(0xFF5B21B6),
    onTertiaryContainer: Color(0xFFEDE9FE),
    // Error
    error: Color(0xFFEF4444),
    onError: _darkBackground,
    errorContainer: Color(0xFF991B1B),
    onErrorContainer: Color(0xFFFEE2E2),
    // Background & Surface
    background: _darkBackground,
    onBackground: _darkOnBackground,
    surface: _darkSurface,
    onSurface: _darkOnSurface,
    surfaceVariant: Color(0xFF1E293B),
    onSurfaceVariant: Color(0xFF94A3B8),
    // Outline
    outline: _darkOutline,
    outlineVariant: Color(0xFF1E293B),
    // Shadow & Scrim
    shadow: Colors.black.withOpacity(0.3),
    scrim: Colors.black.withOpacity(0.7),
    // Inverse
    inverseSurface: Color(0xFFF1F5F9),
    onInverseSurface: Color(0xFF1E293B),
    inversePrimary: _omairBlue,
    surfaceTint: _omairBlueLight,
  );

  /// Build text theme with Inter font
  static TextTheme _buildTextTheme(TextTheme base) {
    return GoogleFonts.interTextTheme(base).copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Build theme from color scheme
  static ThemeData _buildTheme(ColorScheme colorScheme, Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(
        brightness == Brightness.light
            ? ThemeData.light().textTheme
            : ThemeData.dark().textTheme,
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: isDark ? 2 : 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark
                ? colorScheme.outline.withOpacity(0.2)
                : colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),

      // FAB theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? colorScheme.surface
            : colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(isDark ? 0.3 : 0.4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(isDark ? 0.3 : 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        helperStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 8,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        backgroundColor: colorScheme.surface,
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Icon theme
      iconTheme: IconThemeData(color: colorScheme.onSurface),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withOpacity(0.2),
        thickness: 1,
      ),

      // Scaffold background
      scaffoldBackgroundColor: colorScheme.background,
    );
  }

  /// Light theme - Omair Brand
  static ThemeData lightTheme = _buildTheme(
    _lightColorScheme,
    Brightness.light,
  );

  /// Dark theme - Omair Brand
  static ThemeData darkTheme = _buildTheme(_darkColorScheme, Brightness.dark);
}
