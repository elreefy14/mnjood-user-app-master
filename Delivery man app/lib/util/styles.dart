import 'package:flutter/material.dart';
import 'package:mnjood_delivery/util/dimensions.dart';

// Font fallback - when primary font doesn't have a glyph, use Roboto
const List<String> _fontFamilyFallback = ['Roboto'];

// Body text styles - GraphikArabic for all text
final robotoRegular = TextStyle(
  fontFamily: 'GraphikArabic',
  fontFamilyFallback: _fontFamilyFallback,
  fontWeight: FontWeight.w400,
  fontSize: Dimensions.fontSizeDefault,
);

final robotoMedium = TextStyle(
  fontFamily: 'GraphikArabic',
  fontFamilyFallback: _fontFamilyFallback,
  fontWeight: FontWeight.w500,
  fontSize: Dimensions.fontSizeDefault,
);

final robotoSemiBold = TextStyle(
  fontFamily: 'GraphikArabic',
  fontFamilyFallback: _fontFamilyFallback,
  fontWeight: FontWeight.w600,
  fontSize: Dimensions.fontSizeDefault,
);

// Bold/Black styles - GraphikArabic for consistent font across app
final robotoBold = TextStyle(
  fontFamily: 'GraphikArabic',
  fontFamilyFallback: _fontFamilyFallback,
  fontWeight: FontWeight.w700,
  fontSize: Dimensions.fontSizeDefault,
);

final robotoBlack = TextStyle(
  fontFamily: 'GraphikArabic',
  fontFamilyFallback: _fontFamilyFallback,
  fontWeight: FontWeight.w900,
  fontSize: Dimensions.fontSizeDefault,
);

// Section title style - GraphikArabic with 14sp and 21sp line height
final sectionTitleStyle = TextStyle(
  fontFamily: 'GraphikArabic',
  fontFamilyFallback: _fontFamilyFallback,
  fontWeight: FontWeight.w500,
  fontSize: 14,
  height: 1.5, // 21sp line height / 14sp font size = 1.5
  color: const Color(0xFF333333),
);
