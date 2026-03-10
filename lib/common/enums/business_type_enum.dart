import 'package:get/get.dart';

enum BusinessType {
  all,
  restaurant,
  supermarket,
  pharmacy,
}

extension BusinessTypeExtension on BusinessType {
  String get name {
    switch (this) {
      case BusinessType.all:
        return 'all';
      case BusinessType.restaurant:
        return 'restaurant';
      case BusinessType.supermarket:
        return 'supermarket';
      case BusinessType.pharmacy:
        return 'pharmacy';
    }
  }

  String get displayName {
    switch (this) {
      case BusinessType.all:
        return 'all'.tr;
      case BusinessType.restaurant:
        return 'restaurants'.tr;
      case BusinessType.supermarket:
        return 'supermarkets'.tr;
      case BusinessType.pharmacy:
        return 'pharmacies'.tr;
    }
  }

  String get singularDisplayName {
    switch (this) {
      case BusinessType.all:
        return 'all'.tr;
      case BusinessType.restaurant:
        return 'restaurant_singular'.tr;
      case BusinessType.supermarket:
        return 'supermarket'.tr;
      case BusinessType.pharmacy:
        return 'pharmacy'.tr;
    }
  }

  static BusinessType fromString(String? value) {
    if (value == null) return BusinessType.restaurant;

    switch (value.toLowerCase()) {
      case 'restaurant':
        return BusinessType.restaurant;
      case 'supermarket':
        return BusinessType.supermarket;
      case 'pharmacy':
        return BusinessType.pharmacy;
      case 'all':
        return BusinessType.all;
      default:
        return BusinessType.restaurant;
    }
  }
}
