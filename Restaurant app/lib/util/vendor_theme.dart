import 'package:flutter/material.dart';
import 'package:mnjood_vendor/helper/business_type_helper.dart';

/// Vendor-specific theme data
class VendorTheme {
  final BusinessType type;
  final Color primaryColor;
  final Color primaryLightColor;
  final Color primaryDarkColor;
  final Color secondaryColor;
  final List<Color> gradientColors;
  final String typeName;
  final String typeLabel;

  const VendorTheme({
    required this.type,
    required this.primaryColor,
    required this.primaryLightColor,
    required this.primaryDarkColor,
    required this.secondaryColor,
    required this.gradientColors,
    required this.typeName,
    required this.typeLabel,
  });

  /// Restaurant theme
  static const VendorTheme restaurant = VendorTheme(
    type: BusinessType.restaurant,
    primaryColor: Color(0xFFFF9E1B),
    primaryLightColor: Color(0xFFFFF3E0),
    primaryDarkColor: Color(0xFFE68900),
    secondaryColor: Color(0xFFFFB800),
    gradientColors: [Color(0xFFFF9E1B), Color(0xFFFF6B35)],
    typeName: 'restaurant',
    typeLabel: 'Restaurant',
  );

  /// Supermarket theme
  static const VendorTheme supermarket = VendorTheme(
    type: BusinessType.supermarket,
    primaryColor: Color(0xFF4CAF50),
    primaryLightColor: Color(0xFFE8F5E9),
    primaryDarkColor: Color(0xFF388E3C),
    secondaryColor: Color(0xFF8BC34A),
    gradientColors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
    typeName: 'supermarket',
    typeLabel: 'Supermarket',
  );

  /// Pharmacy theme
  static const VendorTheme pharmacy = VendorTheme(
    type: BusinessType.pharmacy,
    primaryColor: Color(0xFF2196F3),
    primaryLightColor: Color(0xFFE3F2FD),
    primaryDarkColor: Color(0xFF1976D2),
    secondaryColor: Color(0xFF03A9F4),
    gradientColors: [Color(0xFF2196F3), Color(0xFF1565C0)],
    typeName: 'pharmacy',
    typeLabel: 'Pharmacy',
  );

  /// Coffee Shop theme
  static const VendorTheme coffeeShop = VendorTheme(
    type: BusinessType.coffeeShop,
    primaryColor: Color(0xFF8B4513),
    primaryLightColor: Color(0xFFF5E6D3),
    primaryDarkColor: Color(0xFF5D2906),
    secondaryColor: Color(0xFFD2691E),
    gradientColors: [Color(0xFF8B4513), Color(0xFF5D2906)],
    typeName: 'coffee_shop',
    typeLabel: 'Coffee Shop',
  );

  /// Get theme by business type
  static VendorTheme fromType(BusinessType type) {
    switch (type) {
      case BusinessType.restaurant:
        return restaurant;
      case BusinessType.supermarket:
        return supermarket;
      case BusinessType.pharmacy:
        return pharmacy;
      case BusinessType.coffeeShop:
        return coffeeShop;
    }
  }

  /// Get current vendor theme
  static VendorTheme get current {
    return fromType(BusinessTypeHelper.getCurrentBusinessType());
  }

  /// Generate a LinearGradient from the theme colors
  LinearGradient get gradient => LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Get color with opacity for backgrounds
  Color backgroundOpacity([double opacity = 0.1]) =>
      primaryColor.withOpacity(opacity);

  /// Get color scheme based on vendor theme
  ColorScheme get colorScheme => ColorScheme.light(
        primary: primaryColor,
        primaryContainer: primaryLightColor,
        secondary: secondaryColor,
        secondaryContainer: secondaryColor.withOpacity(0.2),
        surface: Colors.white,
        error: const Color(0xFFEF4444),
      );

  /// Get dark color scheme based on vendor theme
  ColorScheme get darkColorScheme => ColorScheme.dark(
        primary: primaryColor,
        primaryContainer: primaryDarkColor,
        secondary: secondaryColor,
        secondaryContainer: secondaryColor.withOpacity(0.3),
        surface: const Color(0xFF1F2937),
        error: const Color(0xFFEF4444),
      );
}

/// Extension to easily access vendor theme in widgets
extension VendorThemeContext on BuildContext {
  VendorTheme get vendorTheme => VendorTheme.current;
}

/// Vendor-specific color utilities
class VendorColors {
  VendorColors._();

  /// Get primary color for current vendor
  static Color get primary => VendorTheme.current.primaryColor;

  /// Get light primary color for current vendor
  static Color get primaryLight => VendorTheme.current.primaryLightColor;

  /// Get dark primary color for current vendor
  static Color get primaryDark => VendorTheme.current.primaryDarkColor;

  /// Get secondary color for current vendor
  static Color get secondary => VendorTheme.current.secondaryColor;

  /// Get gradient colors for current vendor
  static List<Color> get gradientColors => VendorTheme.current.gradientColors;

  /// Get gradient for current vendor
  static LinearGradient get gradient => VendorTheme.current.gradient;

  /// Get background color with opacity for current vendor
  static Color background([double opacity = 0.1]) =>
      VendorTheme.current.backgroundOpacity(opacity);
}
