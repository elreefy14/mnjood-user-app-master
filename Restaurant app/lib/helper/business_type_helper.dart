import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:get/get.dart';
import 'package:mnjood_vendor/features/profile/controllers/profile_controller.dart';

/// Enum for business types
enum BusinessType {
  restaurant,
  supermarket,
  pharmacy,
  coffeeShop,
}

/// Extension for BusinessType enum
extension BusinessTypeExtension on BusinessType {
  String get value {
    switch (this) {
      case BusinessType.restaurant:
        return 'restaurant';
      case BusinessType.supermarket:
        return 'supermarket';
      case BusinessType.pharmacy:
        return 'pharmacy';
      case BusinessType.coffeeShop:
        return 'coffee_shop';
    }
  }

  static BusinessType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'supermarket':
        return BusinessType.supermarket;
      case 'pharmacy':
        return BusinessType.pharmacy;
      case 'coffee_shop':
      case 'coffeeshop':
      case 'coffee':
        return BusinessType.coffeeShop;
      default:
        return BusinessType.restaurant;
    }
  }
}

/// Helper class for business type specific labels and functionality
class BusinessTypeHelper {

  /// Get current business type from profile
  static BusinessType getCurrentBusinessType() {
    try {
      final profileController = Get.find<ProfileController>();
      if (profileController.profileModel?.restaurants != null &&
          profileController.profileModel!.restaurants!.isNotEmpty) {
        final businessType = profileController.profileModel!.restaurants![0].businessType;
        return BusinessTypeExtension.fromString(businessType);
      }
    } catch (_) {}
    return BusinessType.restaurant;
  }

  /// Get singular item label (Food/Product/Medicine/Item)
  static String getItemLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'food'.tr;
      case BusinessType.supermarket:
        return 'product'.tr;
      case BusinessType.pharmacy:
        return 'medicine'.tr;
      case BusinessType.coffeeShop:
        return 'drink'.tr;
    }
  }

  /// Get plural items label (Foods/Products/Medicines/Drinks)
  static String getItemsLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'foods'.tr;
      case BusinessType.supermarket:
        return 'products'.tr;
      case BusinessType.pharmacy:
        return 'medicines'.tr;
      case BusinessType.coffeeShop:
        return 'drinks'.tr;
    }
  }

  /// Get "All Food/Products/Medicines/Drinks" label
  static String getAllItemsLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'all_food'.tr;
      case BusinessType.supermarket:
        return 'all_products'.tr;
      case BusinessType.pharmacy:
        return 'all_medicines'.tr;
      case BusinessType.coffeeShop:
        return 'all_drinks'.tr;
    }
  }

  /// Get "Add Food/Product/Medicine/Drink" label
  static String getAddItemLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'add_food'.tr;
      case BusinessType.supermarket:
        return 'add_product'.tr;
      case BusinessType.pharmacy:
        return 'add_medicine'.tr;
      case BusinessType.coffeeShop:
        return 'add_drink'.tr;
    }
  }

  /// Get "Update Food/Product/Medicine/Drink" label
  static String getUpdateItemLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'update_food'.tr;
      case BusinessType.supermarket:
        return 'update_product'.tr;
      case BusinessType.pharmacy:
        return 'update_medicine'.tr;
      case BusinessType.coffeeShop:
        return 'update_drink'.tr;
    }
  }

  /// Get "Food/Product/Medicine/Drink Info" section label
  static String getItemInfoLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'food_info'.tr;
      case BusinessType.supermarket:
        return 'product_info'.tr;
      case BusinessType.pharmacy:
        return 'medicine_info'.tr;
      case BusinessType.coffeeShop:
        return 'drink_info'.tr;
    }
  }

  /// Get "Food/Product/Medicine/Drink Variations" label
  static String getItemVariationsLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'food_variations'.tr;
      case BusinessType.supermarket:
        return 'product_variations'.tr;
      case BusinessType.pharmacy:
        return 'medicine_variations'.tr;
      case BusinessType.coffeeShop:
        return 'drink_variations'.tr;
    }
  }

  /// Get "Food/Product/Medicine/Drink Name" label
  static String getItemNameLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'food_name'.tr;
      case BusinessType.supermarket:
        return 'product_name'.tr;
      case BusinessType.pharmacy:
        return 'medicine_name'.tr;
      case BusinessType.coffeeShop:
        return 'drink_name'.tr;
    }
  }

  /// Get "Food/Product/Medicine/Drink Details" label
  static String getItemDetailsLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'food_details'.tr;
      case BusinessType.supermarket:
        return 'product_details'.tr;
      case BusinessType.pharmacy:
        return 'medicine_details'.tr;
      case BusinessType.coffeeShop:
        return 'drink_details'.tr;
    }
  }

  /// Get "Food/Product/Medicine/Drink Image" label
  static String getItemImageLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'food_image'.tr;
      case BusinessType.supermarket:
        return 'product_image'.tr;
      case BusinessType.pharmacy:
        return 'medicine_image'.tr;
      case BusinessType.coffeeShop:
        return 'drink_image'.tr;
    }
  }

  /// Get "Food/Product/Medicine/Drink Report" label
  static String getItemReportLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'food_report'.tr;
      case BusinessType.supermarket:
        return 'product_report'.tr;
      case BusinessType.pharmacy:
        return 'medicine_report'.tr;
      case BusinessType.coffeeShop:
        return 'drink_report'.tr;
    }
  }

  /// Get "Food/Product/Medicine/Drink List" label
  static String getItemListLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'food_list'.tr;
      case BusinessType.supermarket:
        return 'product_list'.tr;
      case BusinessType.pharmacy:
        return 'medicine_list'.tr;
      case BusinessType.coffeeShop:
        return 'drink_list'.tr;
    }
  }

  /// Get "Food/Product/Medicine/Drink Stock" label
  static String getItemStockLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'food_stock'.tr;
      case BusinessType.supermarket:
        return 'product_stock'.tr;
      case BusinessType.pharmacy:
        return 'medicine_stock'.tr;
      case BusinessType.coffeeShop:
        return 'drink_stock'.tr;
    }
  }

  /// Get "Enter Food/Product/Medicine/Drink Name" label
  static String getEnterItemNameLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'enter_food_name'.tr;
      case BusinessType.supermarket:
        return 'enter_product_name'.tr;
      case BusinessType.pharmacy:
        return 'enter_medicine_name'.tr;
      case BusinessType.coffeeShop:
        return 'enter_drink_name'.tr;
    }
  }

  /// Get "Enter Food/Product/Medicine/Drink Price" label
  static String getEnterItemPriceLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'enter_food_price'.tr;
      case BusinessType.supermarket:
        return 'enter_product_price'.tr;
      case BusinessType.pharmacy:
        return 'enter_medicine_price'.tr;
      case BusinessType.coffeeShop:
        return 'enter_drink_price'.tr;
    }
  }

  /// Get "No Food/Product/Medicine/Drink Found" label
  static String getNoItemFoundLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'no_food_found'.tr;
      case BusinessType.supermarket:
        return 'no_product_found'.tr;
      case BusinessType.pharmacy:
        return 'no_medicine_found'.tr;
      case BusinessType.coffeeShop:
        return 'no_drink_found'.tr;
    }
  }

  /// Get "Food/Product/Medicine/Drink Type" label
  static String getItemTypeLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'food_type'.tr;
      case BusinessType.supermarket:
        return 'product_type'.tr;
      case BusinessType.pharmacy:
        return 'medicine_type'.tr;
      case BusinessType.coffeeShop:
        return 'drink_type'.tr;
    }
  }

  /// Get "Search Food/Product/Medicine/Drink" label
  static String getSearchItemLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'search_food'.tr;
      case BusinessType.supermarket:
        return 'search_product'.tr;
      case BusinessType.pharmacy:
        return 'search_medicine'.tr;
      case BusinessType.coffeeShop:
        return 'search_drink'.tr;
    }
  }

  /// Get "Food/Product/Medicine/Drink Discount" label
  static String getItemDiscountLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'food_discount'.tr;
      case BusinessType.supermarket:
        return 'product_discount'.tr;
      case BusinessType.pharmacy:
        return 'medicine_discount'.tr;
      case BusinessType.coffeeShop:
        return 'drink_discount'.tr;
    }
  }

  /// Get business name label (Restaurant/Store/Pharmacy/Coffee Shop)
  static String getBusinessNameLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'restaurant'.tr;
      case BusinessType.supermarket:
        return 'store'.tr;
      case BusinessType.pharmacy:
        return 'pharmacy'.tr;
      case BusinessType.coffeeShop:
        return 'coffee_shop'.tr;
    }
  }

  /// Get settings label (Restaurant/Store/Pharmacy/Coffee Shop Settings)
  static String getSettingsLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'restaurant_settings'.tr;
      case BusinessType.supermarket:
        return 'store_settings'.tr;
      case BusinessType.pharmacy:
        return 'pharmacy_settings'.tr;
      case BusinessType.coffeeShop:
        return 'coffee_shop_settings'.tr;
    }
  }

  /// Check if business type is supermarket
  static bool isSupermarket({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    return businessType == BusinessType.supermarket;
  }

  /// Check if business type is pharmacy
  static bool isPharmacy({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    return businessType == BusinessType.pharmacy;
  }

  /// Check if business type is restaurant
  static bool isRestaurant({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    return businessType == BusinessType.restaurant;
  }

  // ========== FEATURE VISIBILITY METHODS ==========

  /// Check if cuisines section should be shown (Restaurant only)
  static bool showCuisinesSection({BusinessType? type}) {
    return isRestaurant(type: type);
  }

  /// Check if preparation time field should be shown (Restaurant only)
  static bool showPreparationTime({BusinessType? type}) {
    return isRestaurant(type: type);
  }

  /// Check if veg/non-veg filter should be shown (Restaurant only)
  static bool showVegNonVegFilter({BusinessType? type}) {
    return isRestaurant(type: type);
  }

  /// Check if halal option should be shown (Restaurant only)
  static bool showHalalOption({BusinessType? type}) {
    return isRestaurant(type: type);
  }

  /// Check if nutrition section should be shown (Restaurant/Supermarket)
  static bool showNutritionSection({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    return businessType != BusinessType.pharmacy;
  }

  /// Check if enhanced inventory/stock management should be shown (Supermarket/Pharmacy)
  static bool showEnhancedInventory({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    return businessType == BusinessType.supermarket || businessType == BusinessType.pharmacy;
  }

  /// Check if barcode scanner should be shown (Supermarket/Pharmacy)
  static bool showBarcodeScanner({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    return businessType == BusinessType.supermarket || businessType == BusinessType.pharmacy;
  }

  /// Check if expiry date field should be shown (Supermarket/Pharmacy)
  static bool showExpiryDate({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    return businessType == BusinessType.supermarket || businessType == BusinessType.pharmacy;
  }

  /// Check if prescription section should be shown (Pharmacy only)
  static bool showPrescriptionSection({BusinessType? type}) {
    return isPharmacy(type: type);
  }

  /// Check if dosage section should be shown (Pharmacy only)
  static bool showDosageSection({BusinessType? type}) {
    return isPharmacy(type: type);
  }

  /// Check if generic alternatives should be shown (Pharmacy only)
  static bool showGenericAlternatives({BusinessType? type}) {
    return isPharmacy(type: type);
  }

  // ========== ICON METHODS ==========

  /// Get primary icon for business type
  static IconData getPrimaryIcon({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return HeroiconsOutline.buildingStorefront;
      case BusinessType.supermarket:
        return HeroiconsOutline.shoppingCart;
      case BusinessType.pharmacy:
        return HeroiconsOutline.beaker;
      case BusinessType.coffeeShop:
        return HeroiconsSolid.fire;
    }
  }

  /// Get item icon for business type
  static IconData getItemIcon({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return HeroiconsOutline.cake;
      case BusinessType.supermarket:
        return HeroiconsOutline.shoppingBag;
      case BusinessType.pharmacy:
        return HeroiconsOutline.beaker;
      case BusinessType.coffeeShop:
        return HeroiconsSolid.fire;
    }
  }

  /// Get inventory icon
  static IconData getInventoryIcon({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.pharmacy:
        return HeroiconsOutline.beaker;
      default:
        return HeroiconsOutline.cube;
    }
  }

  // ========== COLOR METHODS ==========

  /// Get accent color for business type
  static Color getAccentColor({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return const Color(0xFFFF6B35); // Orange
      case BusinessType.supermarket:
        return const Color(0xFF4CAF50); // Green
      case BusinessType.pharmacy:
        return const Color(0xFF2196F3); // Blue
      case BusinessType.coffeeShop:
        return const Color(0xFF8B4513); // Brown
    }
  }

  /// Get secondary color for business type
  static Color getSecondaryColor({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return const Color(0xFFFFB800); // Yellow
      case BusinessType.supermarket:
        return const Color(0xFF8BC34A); // Light Green
      case BusinessType.pharmacy:
        return const Color(0xFF03A9F4); // Light Blue
      case BusinessType.coffeeShop:
        return const Color(0xFFD2691E); // Chocolate/Light Brown
    }
  }

  // ========== DASHBOARD SPECIFIC LABELS ==========

  /// Get "Popular Items" label based on business type
  static String getPopularItemsLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'popular_dishes'.tr;
      case BusinessType.supermarket:
        return 'best_sellers'.tr;
      case BusinessType.pharmacy:
        return 'frequently_ordered'.tr;
      case BusinessType.coffeeShop:
        return 'popular_drinks'.tr;
    }
  }

  /// Get "Low Stock Alert" label based on business type
  static String getLowStockLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'low_ingredient_stock'.tr;
      case BusinessType.supermarket:
        return 'low_stock_products'.tr;
      case BusinessType.pharmacy:
        return 'low_stock_medicines'.tr;
      case BusinessType.coffeeShop:
        return 'low_ingredient_stock'.tr;
    }
  }

  /// Get inventory management label
  static String getInventoryLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.supermarket:
        return 'inventory_management'.tr;
      case BusinessType.pharmacy:
        return 'medicine_inventory'.tr;
      default:
        return 'stock_management'.tr;
    }
  }

  /// Get expiry tracking label
  static String getExpiryLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.pharmacy:
        return 'medicine_expiry'.tr;
      default:
        return 'expiry_tracking'.tr;
    }
  }

  /// Get unit label for stock/inventory
  static String getUnitLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.pharmacy:
        return 'units'.tr;
      case BusinessType.supermarket:
        return 'pcs'.tr;
      default:
        return 'qty'.tr;
    }
  }

  /// Get order processing status label (Cooking/Preparing/Processing)
  static String getProcessingStatusLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'cooking'.tr;
      case BusinessType.supermarket:
        return 'preparing'.tr;
      case BusinessType.pharmacy:
        return 'processing'.tr;
      case BusinessType.coffeeShop:
        return 'brewing'.tr;
    }
  }

  /// Get display label for order status (handles business-specific labels)
  /// For 'cooking' status, returns Cooking/Preparing/Processing based on business type
  static String getOrderStatusLabel(String status, {BusinessType? type}) {
    if (status == 'cooking') {
      return getProcessingStatusLabel(type: type);
    }
    // For all other statuses, use the translation key directly
    return status.tr;
  }

  /// Get "Swipe to Cooking/Preparing/Processing/Brewing" label based on business type
  static String getSwipeToProcessingLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'swipe_to_cooking'.tr;
      case BusinessType.supermarket:
        return 'swipe_to_preparing'.tr;
      case BusinessType.pharmacy:
        return 'swipe_to_processing'.tr;
      case BusinessType.coffeeShop:
        return 'swipe_to_brewing'.tr;
    }
  }

  /// Get "Temporarily Closed" label based on business type
  static String getTemporarilyClosedLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'restaurant_temporarily_closed'.tr;
      case BusinessType.supermarket:
        return 'store_temporarily_closed'.tr;
      case BusinessType.pharmacy:
        return 'pharmacy_temporarily_closed'.tr;
      case BusinessType.coffeeShop:
        return 'coffee_shop_temporarily_closed'.tr;
    }
  }

  // ========== MENU VISIBILITY ==========

  /// Get list of visible menu item keys for business type
  static List<String> getVisibleMenuItems({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();

    // Common items for all business types
    List<String> commonItems = [
      'profile',
      'orders',
      'wallet',
      'campaigns',
      'addons',
      'categories',
      'coupons',
      'reviews',
      'reports',
      'chat',
    ];

    switch (businessType) {
      case BusinessType.restaurant:
        return [...commonItems, 'cuisines', 'delivery_time'];
      case BusinessType.supermarket:
        return [...commonItems, 'inventory', 'stock_alerts', 'expiry_tracking'];
      case BusinessType.pharmacy:
        return [...commonItems, 'prescriptions', 'inventory', 'expiry_tracking'];
      case BusinessType.coffeeShop:
        return [...commonItems, 'queue', 'loyalty', 'quick_order'];
    }
  }

  /// Check if specific menu item should be visible
  static bool isMenuItemVisible(String menuItem, {BusinessType? type}) {
    return getVisibleMenuItems(type: type).contains(menuItem);
  }

  // ========== REPORT LABELS ==========

  /// Get inventory report subtitle
  static String getInventoryReportSubtitle({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.supermarket:
        return 'track_stock_levels_and_inventory_value'.tr;
      case BusinessType.pharmacy:
        return 'track_medicine_stock_and_inventory'.tr;
      default:
        return 'track_stock_levels'.tr;
    }
  }

  /// Get item report subtitle
  static String getItemReportSubtitle({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return 'check_detailed_reports_on_food_items_sold'.tr;
      case BusinessType.supermarket:
        return 'check_detailed_reports_on_products_sold'.tr;
      case BusinessType.pharmacy:
        return 'check_detailed_reports_on_medicines_sold'.tr;
      case BusinessType.coffeeShop:
        return 'check_detailed_reports_on_drinks_sold'.tr;
    }
  }

  /// Check if Finance Management should be shown (Supermarket only)
  static bool showFinanceManagement({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    return businessType == BusinessType.supermarket;
  }

  /// Check if business type is coffee shop
  static bool isCoffeeShop({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    return businessType == BusinessType.coffeeShop;
  }

  // ========== COFFEE SHOP SPECIFIC FEATURES ==========

  /// Check if quick order mode should be shown (Coffee Shop)
  static bool showQuickOrderMode({BusinessType? type}) {
    return isCoffeeShop(type: type);
  }

  /// Check if drink customizations should be shown (Coffee Shop)
  static bool showDrinkCustomizations({BusinessType? type}) {
    return isCoffeeShop(type: type);
  }

  /// Check if loyalty/stamp card should be shown (Coffee Shop)
  static bool showLoyaltyProgram({BusinessType? type}) {
    return isCoffeeShop(type: type);
  }

  /// Check if pickup queue should be shown (Coffee Shop)
  static bool showPickupQueue({BusinessType? type}) {
    return isCoffeeShop(type: type);
  }

  /// Check if barista assignment should be shown (Coffee Shop)
  static bool showBaristaAssignment({BusinessType? type}) {
    return isCoffeeShop(type: type);
  }

  /// Get queue label based on business type
  static String getQueueLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.coffeeShop:
        return 'pickup_queue'.tr;
      case BusinessType.restaurant:
        return 'order_queue'.tr;
      default:
        return 'pending_orders'.tr;
    }
  }

  /// Get staff label based on business type
  static String getStaffLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.coffeeShop:
        return 'barista'.tr;
      case BusinessType.restaurant:
        return 'chef'.tr;
      case BusinessType.pharmacy:
        return 'pharmacist'.tr;
      default:
        return 'staff'.tr;
    }
  }

  /// Get quick order label
  static String getQuickOrderLabel({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.coffeeShop:
        return 'quick_order'.tr;
      default:
        return 'new_order'.tr;
    }
  }

  // ========== VENDOR TYPE COLORS (FULL PALETTE) ==========

  /// Get primary color for business type
  static Color getPrimaryColor({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return const Color(0xFFFF9E1B); // Orange
      case BusinessType.supermarket:
        return const Color(0xFF4CAF50); // Green
      case BusinessType.pharmacy:
        return const Color(0xFF2196F3); // Blue
      case BusinessType.coffeeShop:
        return const Color(0xFF8B4513); // Brown
    }
  }

  /// Get light primary color for backgrounds
  static Color getPrimaryLightColor({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return const Color(0xFFFFF3E0); // Light Orange
      case BusinessType.supermarket:
        return const Color(0xFFE8F5E9); // Light Green
      case BusinessType.pharmacy:
        return const Color(0xFFE3F2FD); // Light Blue
      case BusinessType.coffeeShop:
        return const Color(0xFFF5E6D3); // Light Brown
    }
  }

  /// Get dark primary color for emphasis
  static Color getPrimaryDarkColor({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return const Color(0xFFE68900); // Dark Orange
      case BusinessType.supermarket:
        return const Color(0xFF388E3C); // Dark Green
      case BusinessType.pharmacy:
        return const Color(0xFF1976D2); // Dark Blue
      case BusinessType.coffeeShop:
        return const Color(0xFF5D2906); // Dark Brown
    }
  }

  /// Get gradient colors for business type
  static List<Color> getGradientColors({BusinessType? type}) {
    final businessType = type ?? getCurrentBusinessType();
    switch (businessType) {
      case BusinessType.restaurant:
        return const [Color(0xFFFF9E1B), Color(0xFFFF6B35)];
      case BusinessType.supermarket:
        return const [Color(0xFF4CAF50), Color(0xFF2E7D32)];
      case BusinessType.pharmacy:
        return const [Color(0xFF2196F3), Color(0xFF1565C0)];
      case BusinessType.coffeeShop:
        return const [Color(0xFF8B4513), Color(0xFF5D2906)];
    }
  }
}
