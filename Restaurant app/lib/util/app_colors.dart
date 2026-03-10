import 'package:flutter/material.dart';

/// App color constants for consistent theming
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFFFF9E1B);
  static const Color primaryLight = Color(0xFFFFF3E0);
  static const Color primaryDark = Color(0xFFE68900);

  // Neutral Gray Scale
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF059669);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color info = Color(0xFF6B7280);
  static const Color infoLight = Color(0xFFF3F4F6);
  static const Color infoDark = Color(0xFF4B5563);

  // Order Status Colors
  static const Color orderPending = Color(0xFFF59E0B);
  static const Color orderConfirmed = Color(0xFFFFB347);
  static const Color orderProcessing = Color(0xFF8B5CF6);
  static const Color orderReady = Color(0xFF10B981);
  static const Color orderPickedUp = Color(0xFF06B6D4);
  static const Color orderDelivered = Color(0xFF059669);
  static const Color orderCancelled = Color(0xFFEF4444);

  // Helper method to get order status color
  static Color getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return orderPending;
      case 'confirmed':
        return orderConfirmed;
      case 'processing':
      case 'cooking':
        return orderProcessing;
      case 'ready':
      case 'handover':
        return orderReady;
      case 'picked_up':
      case 'on_the_way':
        return orderPickedUp;
      case 'delivered':
        return orderDelivered;
      case 'cancelled':
      case 'canceled':
      case 'failed':
        return orderCancelled;
      default:
        return gray500;
    }
  }

  // Helper method to get status background color (lighter version)
  static Color getOrderStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return warningLight;
      case 'confirmed':
        return infoLight;
      case 'processing':
      case 'cooking':
        return const Color(0xFFEDE9FE);
      case 'ready':
      case 'handover':
        return successLight;
      case 'picked_up':
      case 'on_the_way':
        return const Color(0xFFCFFAFE);
      case 'delivered':
        return successLight;
      case 'cancelled':
      case 'canceled':
      case 'failed':
        return errorLight;
      default:
        return gray200;
    }
  }
}
