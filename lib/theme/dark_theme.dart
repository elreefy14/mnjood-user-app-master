import 'package:mnjood/util/app_constants.dart';
import 'package:flutter/material.dart';

TextTheme _buildTextTheme(TextTheme base) {
  return base.copyWith(
    // All text uses GraphikArabic font
    displayLarge: base.displayLarge?.copyWith(fontFamily: AppConstants.headingFontFamily),
    displayMedium: base.displayMedium?.copyWith(fontFamily: AppConstants.headingFontFamily),
    displaySmall: base.displaySmall?.copyWith(fontFamily: AppConstants.headingFontFamily),
    headlineLarge: base.headlineLarge?.copyWith(fontFamily: AppConstants.headingFontFamily),
    headlineMedium: base.headlineMedium?.copyWith(fontFamily: AppConstants.headingFontFamily),
    headlineSmall: base.headlineSmall?.copyWith(fontFamily: AppConstants.headingFontFamily),
    titleLarge: base.titleLarge?.copyWith(fontFamily: AppConstants.headingFontFamily),
    titleMedium: base.titleMedium?.copyWith(fontFamily: AppConstants.fontFamily),
    titleSmall: base.titleSmall?.copyWith(fontFamily: AppConstants.fontFamily),
    bodyLarge: base.bodyLarge?.copyWith(fontFamily: AppConstants.fontFamily),
    bodyMedium: base.bodyMedium?.copyWith(fontFamily: AppConstants.fontFamily),
    bodySmall: base.bodySmall?.copyWith(fontFamily: AppConstants.fontFamily),
    labelLarge: base.labelLarge?.copyWith(fontFamily: AppConstants.fontFamily),
    labelMedium: base.labelMedium?.copyWith(fontFamily: AppConstants.fontFamily),
    labelSmall: base.labelSmall?.copyWith(fontFamily: AppConstants.fontFamily),
  );
}

ThemeData dark = ThemeData(
  fontFamily: AppConstants.fontFamily,
  textTheme: _buildTextTheme(ThemeData.dark().textTheme),
  primaryColor: const Color(0xFFff9e1b),
  secondaryHeaderColor: const Color(0x9Bff9e1b),
  disabledColor: const Color(0xffa2a7ad),
  brightness: Brightness.dark,
  hintColor: const Color(0xFF5E6472),
  cardColor: const Color(0xFF141313),
  shadowColor: Colors.white.withValues(alpha: 0.03),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: const Color(0xFFff9e1b))),
  colorScheme: const ColorScheme.dark(primary: Color(0xFFff9e1b),
    tertiary: Color(0xFFE88B00),
    tertiaryContainer: Color(0xFFCC7A00),
    secondary: Color(0xFFda281c)).copyWith(surface: const Color(0xFF272727)).copyWith(error: const Color(0xFFdd3135),
  ),
  popupMenuTheme: const PopupMenuThemeData(color: Color(0xFF29292D), surfaceTintColor: Color(0xFF29292D)),
  dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white10),
  floatingActionButtonTheme: FloatingActionButtonThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500))),
  bottomAppBarTheme: const BottomAppBarThemeData(
    surfaceTintColor: Colors.black, height: 60,
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
  dividerTheme: DividerThemeData(color: const Color(0xffa2a7ad).withValues(alpha: 0.25), thickness: 0.5),
  tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
);
