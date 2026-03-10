import 'package:mnjood/common/models/product_model.dart';

class ProductHelper {

  static bool isAvailable(Product product) {
    // Only check backend availability flag - remove time check to fix "Item is not available!" issue
    return product.available ?? true;
  }

  static bool isInStock(Product product) {
    if (product.available == false) return false;
    if (product.stockType != null && product.stockType != 'unlimited' && (product.itemStock ?? 0) <= 0) return false;
    return true;
  }

  static double? getDiscount(Product product) => product.restaurantDiscount == 0 ? product.discount : product.restaurantDiscount;

  static String? getDiscountType(Product product) => product.restaurantDiscount == 0 ? product.discountType : 'percent';
}