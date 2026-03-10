import 'package:mnjood_delivery/util/app_constants.dart';
import 'package:flutter/material.dart';

// Font fallback - when primary font doesn't have a glyph, use Roboto
const List<String> _fontFamilyFallback = ['Roboto'];

TextTheme _buildTextTheme(TextTheme base) {
  return base.copyWith(
    // Headlines and Display use Guesswhat font
    displayLarge: base.displayLarge?.copyWith(fontFamily: AppConstants.headingFontFamily, fontFamilyFallback: _fontFamilyFallback),
    displayMedium: base.displayMedium?.copyWith(fontFamily: AppConstants.headingFontFamily, fontFamilyFallback: _fontFamilyFallback),
    displaySmall: base.displaySmall?.copyWith(fontFamily: AppConstants.headingFontFamily, fontFamilyFallback: _fontFamilyFallback),
    headlineLarge: base.headlineLarge?.copyWith(fontFamily: AppConstants.headingFontFamily, fontFamilyFallback: _fontFamilyFallback),
    headlineMedium: base.headlineMedium?.copyWith(fontFamily: AppConstants.headingFontFamily, fontFamilyFallback: _fontFamilyFallback),
    headlineSmall: base.headlineSmall?.copyWith(fontFamily: AppConstants.headingFontFamily, fontFamilyFallback: _fontFamilyFallback),
    titleLarge: base.titleLarge?.copyWith(fontFamily: AppConstants.headingFontFamily, fontFamilyFallback: _fontFamilyFallback),
    titleMedium: base.titleMedium?.copyWith(fontFamily: AppConstants.fontFamily, fontFamilyFallback: _fontFamilyFallback),
    titleSmall: base.titleSmall?.copyWith(fontFamily: AppConstants.fontFamily, fontFamilyFallback: _fontFamilyFallback),
    // Body and Label use GE SS Two font
    bodyLarge: base.bodyLarge?.copyWith(fontFamily: AppConstants.fontFamily, fontFamilyFallback: _fontFamilyFallback),
    bodyMedium: base.bodyMedium?.copyWith(fontFamily: AppConstants.fontFamily, fontFamilyFallback: _fontFamilyFallback),
    bodySmall: base.bodySmall?.copyWith(fontFamily: AppConstants.fontFamily, fontFamilyFallback: _fontFamilyFallback),
    labelLarge: base.labelLarge?.copyWith(fontFamily: AppConstants.fontFamily, fontFamilyFallback: _fontFamilyFallback),
    labelMedium: base.labelMedium?.copyWith(fontFamily: AppConstants.fontFamily, fontFamilyFallback: _fontFamilyFallback),
    labelSmall: base.labelSmall?.copyWith(fontFamily: AppConstants.fontFamily, fontFamilyFallback: _fontFamilyFallback),
  );
}

ThemeData light = ThemeData(
  fontFamily: AppConstants.fontFamily,
  textTheme: _buildTextTheme(ThemeData.light().textTheme),
  primaryColor: const Color(0xFFff9e1b),
  secondaryHeaderColor: const Color(0x9Bff9e1b),
  disabledColor: const Color(0xFF9B9B9B),
  brightness: Brightness.light,
  hintColor: const Color(0xFF5E6472),
  cardColor: Colors.white,
  shadowColor: Colors.black.withOpacity(0.03),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: const Color(0xFFff9e1b))),
  colorScheme: const ColorScheme.light(primary: Color(0xFFff9e1b),
    tertiary: Color(0xff102F9C),
    tertiaryContainer: Color(0xff8195DB),
    secondary: Color(0xFFda281c)).copyWith(surface: const Color(0xFFF5F6F8)).copyWith(error: const Color(0xFFE84D4F),
  ),
  popupMenuTheme: const PopupMenuThemeData(color: Colors.white, surfaceTintColor: Colors.white),
  dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white),
  floatingActionButtonTheme: FloatingActionButtonThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500))),
  bottomAppBarTheme: const BottomAppBarThemeData(
    surfaceTintColor: Colors.white, height: 60,
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
  dividerTheme: DividerThemeData(color: const Color(0xFFBABFC4).withOpacity(0.25), thickness: 0.5),
  tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
);
