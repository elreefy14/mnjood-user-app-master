import 'package:mnjood_vendor/util/app_constants.dart';
import 'package:flutter/material.dart';

// Font fallback - when GraphikArabic doesn't have a glyph, use Roboto
const List<String> _fontFamilyFallback = ['Roboto'];

TextTheme _buildTextTheme(TextTheme base) {
  return base.copyWith(
    // Headlines and Display use GraphikArabic font
    displayLarge: base.displayLarge?.copyWith(fontFamily: AppConstants.headingFontFamily, fontFamilyFallback: _fontFamilyFallback),
    displayMedium: base.displayMedium?.copyWith(fontFamily: AppConstants.headingFontFamily, fontFamilyFallback: _fontFamilyFallback),
    displaySmall: base.displaySmall?.copyWith(fontFamily: AppConstants.headingFontFamily, fontFamilyFallback: _fontFamilyFallback),
    headlineLarge: base.headlineLarge?.copyWith(fontFamily: AppConstants.headingFontFamily, fontFamilyFallback: _fontFamilyFallback),
    headlineMedium: base.headlineMedium?.copyWith(fontFamily: AppConstants.headingFontFamily, fontFamilyFallback: _fontFamilyFallback),
    headlineSmall: base.headlineSmall?.copyWith(fontFamily: AppConstants.headingFontFamily, fontFamilyFallback: _fontFamilyFallback),
    titleLarge: base.titleLarge?.copyWith(fontFamily: AppConstants.headingFontFamily, fontFamilyFallback: _fontFamilyFallback),
    titleMedium: base.titleMedium?.copyWith(fontFamily: AppConstants.fontFamily, fontFamilyFallback: _fontFamilyFallback),
    titleSmall: base.titleSmall?.copyWith(fontFamily: AppConstants.fontFamily, fontFamilyFallback: _fontFamilyFallback),
    // Body and Label use GraphikArabic font
    bodyLarge: base.bodyLarge?.copyWith(fontFamily: AppConstants.fontFamily, fontFamilyFallback: _fontFamilyFallback),
    bodyMedium: base.bodyMedium?.copyWith(fontFamily: AppConstants.fontFamily, fontFamilyFallback: _fontFamilyFallback),
    bodySmall: base.bodySmall?.copyWith(fontFamily: AppConstants.fontFamily, fontFamilyFallback: _fontFamilyFallback),
    labelLarge: base.labelLarge?.copyWith(fontFamily: AppConstants.fontFamily, fontFamilyFallback: _fontFamilyFallback),
    labelMedium: base.labelMedium?.copyWith(fontFamily: AppConstants.fontFamily, fontFamilyFallback: _fontFamilyFallback),
    labelSmall: base.labelSmall?.copyWith(fontFamily: AppConstants.fontFamily, fontFamilyFallback: _fontFamilyFallback),
  );
}

ThemeData dark = ThemeData(
  fontFamily: AppConstants.fontFamily,
  textTheme: _buildTextTheme(ThemeData.dark().textTheme),
  primaryColor: const Color(0xFFFF9E1B),
  secondaryHeaderColor: const Color(0xFF9CA3AF),
  disabledColor: const Color(0xFF6B7280),
  brightness: Brightness.dark,
  hintColor: const Color(0xFF9CA3AF),
  cardColor: const Color(0xFF1F1F1F),
  shadowColor: Colors.black.withValues(alpha: 0.2),
  scaffoldBackgroundColor: const Color(0xFF121212),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF9E1B))),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFFF9E1B),
    onPrimary: Colors.white,
    secondary: Color(0xFF9CA3AF),
    onSecondary: Colors.white,
    tertiary: Color(0xFFFFB347),
    tertiaryContainer: Color(0xFF4A3000),
    surface: Color(0xFF121212),
    onSurface: Color(0xFFF5F5F5),
    surfaceContainerHighest: Color(0xFF1F1F1F),
  ).copyWith(error: const Color(0xFFEF4444)),
  popupMenuTheme: const PopupMenuThemeData(color: Color(0xFF1F1F1F), surfaceTintColor: Color(0xFF1F1F1F)),
  dialogTheme: const DialogThemeData(surfaceTintColor: Color(0xFF1F1F1F)),
  floatingActionButtonTheme: FloatingActionButtonThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
  bottomAppBarTheme: const BottomAppBarThemeData(
    surfaceTintColor: Color(0xFF1F1F1F), height: 65,
    padding: EdgeInsets.symmetric(vertical: 8),
  ),
  dividerTheme: DividerThemeData(thickness: 0.5, color: const Color(0xFF374151).withValues(alpha: 0.5)),
  tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1F1F1F),
    foregroundColor: Color(0xFFF5F5F5),
    elevation: 0,
    scrolledUnderElevation: 0.5,
    centerTitle: true,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1F1F1F),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF374151)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF374151)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFFF9E1B), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFEF4444)),
    ),
    hintStyle: const TextStyle(color: Color(0xFF6B7280)),
  ),
);
