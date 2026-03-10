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

ThemeData light = ThemeData(
  fontFamily: AppConstants.fontFamily,
  textTheme: _buildTextTheme(ThemeData.light().textTheme),
  primaryColor: const Color(0xFFff9e1b),
  secondaryHeaderColor: const Color(0x9Bff9e1b),
  disabledColor: const Color(0xFF9B9B9B),
  brightness: Brightness.light,
  hintColor: const Color(0xFF5E6472),
  cardColor: Colors.white,
  shadowColor: Colors.black.withValues(alpha: 0.03),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: const Color(0xFFff9e1b))),
  colorScheme: const ColorScheme.light(primary: Color(0xFFff9e1b),
    tertiary: Color(0xFFE88B00),
    tertiaryContainer: Color(0xFFFFCC80),
    secondary: Color(0xFFda281c)).copyWith(surface: const Color(0xFFF5F6F8)).copyWith(error: const Color(0xFFE84D4F),
  ),
  popupMenuTheme: const PopupMenuThemeData(color: Colors.white, surfaceTintColor: Colors.white),
  dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white),
  floatingActionButtonTheme: FloatingActionButtonThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500))),
  bottomAppBarTheme: const BottomAppBarThemeData(
    surfaceTintColor: Colors.white, height: 60,
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
  dividerTheme: DividerThemeData(color: const Color(0xFFBABFC4).withValues(alpha: 0.25), thickness: 0.5),
  tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
);