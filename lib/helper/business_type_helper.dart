import 'package:flutter/material.dart';
import 'package:mnjood/common/enums/business_type_enum.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class BusinessTypeHelper {

  /// Get icon for business type
  static IconData getIcon(BusinessType type) {
    switch (type) {
      case BusinessType.restaurant:
        return HeroiconsOutline.buildingStorefront;
      case BusinessType.supermarket:
        return HeroiconsOutline.buildingStorefront;
      case BusinessType.pharmacy:
        return HeroiconsOutline.buildingOffice;
      case BusinessType.all:
        return HeroiconsOutline.squares2x2;
    }
  }

  /// Get color for business type
  static Color getColor(BusinessType type) {
    switch (type) {
      case BusinessType.restaurant:
        return const Color(0xFFFF6B6B); // Red/Orange for restaurants
      case BusinessType.supermarket:
        return const Color(0xFF4ECDC4); // Teal/Blue for supermarkets
      case BusinessType.pharmacy:
        return const Color(0xFF95E1D3); // Green for pharmacies
      case BusinessType.all:
        return const Color(0xFF95A5A6); // Gray for all
    }
  }

  /// Get light background color for business type badges
  static Color getLightColor(BusinessType type) {
    switch (type) {
      case BusinessType.restaurant:
        return const Color(0xFFFFE5E5);
      case BusinessType.supermarket:
        return const Color(0xFFE5F9F7);
      case BusinessType.pharmacy:
        return const Color(0xFFE5F9F3);
      case BusinessType.all:
        return const Color(0xFFF5F5F5);
    }
  }

  /// Get gradient colors for business type
  static List<Color> getGradientColors(BusinessType type) {
    switch (type) {
      case BusinessType.restaurant:
        return [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)];
      case BusinessType.supermarket:
        return [const Color(0xFF4ECDC4), const Color(0xFF44A8A0)];
      case BusinessType.pharmacy:
        return [const Color(0xFF95E1D3), const Color(0xFF6BCF7E)];
      case BusinessType.all:
        return [const Color(0xFF95A5A6), const Color(0xFF7F8C8D)];
    }
  }

  /// Get display name translation key
  static String getTranslationKey(BusinessType type, {bool plural = true}) {
    if (plural) {
      switch (type) {
        case BusinessType.restaurant:
          return 'restaurants';
        case BusinessType.supermarket:
          return 'supermarkets';
        case BusinessType.pharmacy:
          return 'pharmacies';
        case BusinessType.all:
          return 'all_businesses';
      }
    } else {
      switch (type) {
        case BusinessType.restaurant:
          return 'restaurant';
        case BusinessType.supermarket:
          return 'supermarket';
        case BusinessType.pharmacy:
          return 'pharmacy';
        case BusinessType.all:
          return 'business';
      }
    }
  }

  /// Get business type from string (from API)
  static BusinessType getTypeFromString(String? value) {
    return BusinessTypeExtension.fromString(value);
  }

  /// Check if business type is available
  static bool isBusinessTypeEnabled(BusinessType type) {
    // This can be configured from backend config in the future
    return true;
  }

  /// Get business type emoji
  static String getEmoji(BusinessType type) {
    switch (type) {
      case BusinessType.restaurant:
        return '🍽️';
      case BusinessType.supermarket:
        return '🛒';
      case BusinessType.pharmacy:
        return '💊';
      case BusinessType.all:
        return '🏪';
    }
  }

  /// Get business type description translation key
  static String getDescriptionKey(BusinessType type) {
    switch (type) {
      case BusinessType.restaurant:
        return 'restaurant_description';
      case BusinessType.supermarket:
        return 'supermarket_description';
      case BusinessType.pharmacy:
        return 'pharmacy_description';
      case BusinessType.all:
        return 'all_businesses_description';
    }
  }

  /// Get all available business types (excluding 'all')
  static List<BusinessType> getAvailableTypes() {
    return [
      BusinessType.restaurant,
      BusinessType.supermarket,
      BusinessType.pharmacy,
    ];
  }

  /// Get all business types including 'all'
  static List<BusinessType> getAllTypes() {
    return [
      BusinessType.all,
      BusinessType.restaurant,
      BusinessType.supermarket,
      BusinessType.pharmacy,
    ];
  }
}
